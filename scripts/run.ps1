$k8DeploymentFileUrl = "https://raw.githubusercontent.com/aman0303/rawFiles/main/deploymentLatest.yml";
$appSettingsFileUrl = "https://raw.githubusercontent.com/aman0303/rawFiles/main/Configs/appsettings.prod.json";
$configmapFileUrl = "https://raw.githubusercontent.com/aman0303/rawFiles/main/configmap.yml";

$k8DeploymentFilePath = ".\deployment.yml";
$appSettingsFilePath = ".\appsettings.prod.json";
$configmapFilePath = ".\configmap.yml";

Invoke-WebRequest $k8DeploymentFileUrl -OutFile $k8DeploymentFilePath;
Invoke-WebRequest $appSettingsFileUrl -OutFile $appSettingsFilePath;
Invoke-WebRequest $configmapFileUrl -OutFile $configmapFilePath;

$appSettings = (Get-Content $appSettingsFilePath | ConvertFrom-Json);

# update Database settings
Write-Host "updating Database settings";
$appSettings.Database.Id = ${Env:DatabaseId};
$appSettings.Database.ServiceEndpoint = ${Env:DatabaseServiceEndpoint};
$appSettings.Database.AccountUri = ${Env:DatabaseAccountUri};
$appSettings.Database.DatabaseId = ${Env:DatabaseDatabaseId};

# update JobManagement settings
Write-Host "updating JobManagement settings";
$appSettings.JobManagement.ServiceEndpoint = ${Env:JobManagementServiceEndpoint};
$appSettings.JobManagement.AccountUri = ${Env:JobManagementAccountUri};
$appSettings.JobManagement.DatabaseName = ${Env:JobManagementDatabaseName};
$appSettings.JobManagement.CollectionName = ${Env:JobManagementCollectionName};
$appSettings.JobManagement.QueueConnectionString = ${Env:JobManagementQueueConnectionString};
$appSettings.JobManagement.QueueNamePrefix = ${Env:JobManagementQueueNamePrefix};
$appSettings.JobManagement.DefaultJobTimeoutHours = ${Env:DefaultJobTimeout};

# update BlobStorageProvider settings
Write-Host "updating BlobStorageProvider settings";
$appSettings.BlobStorageProvider.Id = ${Env:BlobStorageProviderId};
$appSettings.BlobStorageProvider.BlobStorageSubscription = ${Env:BlobStorageSubscription};
$appSettings.BlobStorageProvider.BlobStorageResourceGroup = ${Env:BlobStorageResourceGroup};
$appSettings.BlobStorageProvider.BlobStorageAccountName = ${Env:BlobStorageAccountName};
$appSettings.BlobStorageProvider.BlobStorageAccountUrl = ${Env:BlobStorageAccountUrl};

# update SynapseProvider settings
Write-Host "updating SynapseProvider settings";
$appSettings.SynapseProvider.SynapseWorkspaceName = ${Env:SynapseWorkspaceName};
$appSettings.SynapseProvider.SynapseStorageAccountName = ${Env:SynapseStorageAccountName};
$appSettings.SynapseProvider.SynapseFileSystemContainerName = ${Env:SynapseFileSystemContainerName};
$appSettings.SynapseProvider.SynapseDatabaseName = ${Env:SynapseDatabaseName};
$appSettings.SynapseProvider.SparkPoolName = ${Env:SynapseSparkPoolName};
$appSettings.SynapseProvider.SparkJobFilesPath = ${Env:SynapseSparkJobFilesPath};
$appSettings.SynapseProvider.CosmosLinkedServiceName = ${Env:CosmosLinkedServiceName};

# update ApplicationInsights settings
Write-Host "updating ApplicationInsights settings";
$appSettings.ApplicationInsights.InstrumentationKey = ${Env:AppInsightsInstrumentationKey};
$appSettings.ApplicationInsights.ConnectionString = ${Env:AppInsightsConnectionString};

# update HostedEnvironment settings
Write-Host "updating HostedEnvironment settings";
$appSettings.HostedEnvironment.MsiClientId = ${Env:HostedEnvMsiVlientId};

# update AuthenticationSettings settings
Write-Host "updating AuthenticationSettings settings";
$appSettings.AuthenticationSettings.TenantId = ${Env:AuthenticationTenantId};
$appSettings.AuthenticationSettings.Audience = "46279754-c38c-4442-b929-b417587e14e7";

# update Bot framework settings
Write-Host "updating Bot framework settings";
$appSettings.MicrosoftAppId = "885e9612-f17b-47b5-9d22-946ec3423bc8";
$appSettings.MicrosoftAppPassword = "5fS8Q~V-m_laEgNeu681PttGQCkGEeYaj5wU6cmM";
$appSettings.BotConfiguration.AppId = "885e9612-f17b-47b5-9d22-946ec3423bc8";
$appSettings.BotConfiguration.Audience = "https://api.botframework.com";
$appSettings.BotConfiguration.TenantId = "72f988bf-86f1-41af-91ab-2d7cd011db47";

$appSettingsContent = ($appSettings | ConvertTo-Json -Compress);

Write-Host "updating configmap.yml file";

(Get-Content $configmapFilePath) -Replace '##PROD_SETTINGS##', $appSettingsContent | Set-Content $configmapFilePath;

(Get-Content $configmapFilePath) -Replace '##PROD_JOB_SETTINGS##', $appSettingsContent | Set-Content $configmapFilePath;

Write-Host "updating deployment.yml file";

(Get-Content $k8DeploymentFilePath) -Replace '##imagename##', ${Env:IdsServiceImageName} | Set-Content $k8DeploymentFilePath;

(Get-Content $k8DeploymentFilePath) -Replace '##workerimagename##', ${Env:WorkerServiceImageName} | Set-Content $k8DeploymentFilePath;

$toCompress = @{
Path = $configMapFilePath, $k8DeploymentFilePath
CompressionLevel = "Fastest"
DestinationPath = ".\FileAttachment.Zip"
};

Compress-Archive @toCompress -Update -Force;

Set-AzContext -Subscription ${Env:AksSubscriptionId};

$cmd = "chmod -R 777 /command-files && kubectl apply -f configmap.yml && kubectl apply -f deployment.yml";

Invoke-AzAksRunCommand -ResourceGroupName ${Env:AksResourceGroupName} -Name ${Env:AksClusterName} -Command $cmd -CommandContextAttachmentZip "FileAttachment.Zip" -Force;
