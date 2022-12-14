k8DeploymentFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/deploymentLatest.yml";
appSettingsFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/appsettings.prod.json";
configmapFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/configmap.yml";

k8DeploymentFile="toUpdateDeployment.yml";
appSettingsFile="toUpdateAppSettings.prod.json";
configmapFile="toUpdateConfigmap.yml";

wget -O $k8DeploymentFile $k8DeploymentFileUrl;
wget -O $appSettingsFile $appSettingsFileUrl;
wget -O $configmapFile $configmapFileUrl;

updatedK8DeploymentFile="./deployment.yml";
updatedAppSettingsFile="./appsettings.prod.json";
updatedConfigmapFile="./configmap.yml";

sed -r -E -e "s%##DATABASE_ID##%$DatabaseId%g" \
          -e "s%##DATABASE_SERVICE_ENDPOINT##%$DatabaseServiceEndpoint%g" \
          -e "s%##DATABASE_ACCOUNT_URI##%$DatabaseAccountUri%g" \
          -e "s%##DATABASE_DATABASE_ID##%$DatabaseDatabaseId%g" \
          -e "s%##BLOB_STORAGE_PROVIDER_ID##%$BlobStorageProviderId%g" \
          -e "s%##BLOB_STORAGE_SUBSCRIPTION##%$BlobStorageSubscription%g" \
          -e "s%##BLOB_STORAGE_RESOURCE_GROUP##%$BlobStorageResourceGroup%g" \
          -e "s%##BLOB_STORAGE_ACCOUNT_NAME##%$BlobStorageAccountName%g" \
          -e "s%##BLOB_STORAGE_ACCOUNT_URL##%$BlobStorageAcountUrl%g" \
          -e "s%##SYNAPSE_WORKSPACE_NAME##%$SynapseWorkspaceName%g" \
          -e "s%##SYNAPSE_STORAGE_ACCOUNT_NAME##%$SynapseStorageAccountName%g" \
          -e "s%##SYNAPSE_FILE_SYSTEM_CONTAINER_NAME##%$SynapseFileSystemContainerName%g" \
          -e "s%##SYNAPSE_DATABASE_NAME##%$SynapseDatabaseName%g" \
          -e "s%##SYNAPSE_SPARK_POOL_NAME##%$SynapseSparkPoolName%g" \
          -e "s%##SYNAPSE_SPARK_JOB_FILES_PATH##%$SynapseSparkJobFilesPath%g" \
          -e "s%##COSMOS_LINKED_SERVICE_NAME##%$CosmosLinkedServiceName%g" \
          -e "s%##JOB_MANAGEMENT_QUEUE_CONNECTION_STRING##%$JobManagementQueueConnectionString%g" \
          -e "s%##JOB_MANAGEMENT_SERVICE_ENDPOINT##%$JobManagementServiceEndpoint%g" \
          -e "s%##JOB_MANAGEMENT_ACCOUNT_URI##%$JobManagementAccountUri%g" \
          -e "s%##JOB_MANAGEMENT_DATABASE_NAME##%$JobManagementDatabaseName%g" \
          -e "s%##JOB_MANAGEMENT_COLLECTION_NAME##%$JobManagementCollectionName%g" \
          -e "s%##JOB_MANAGEMENT_QUEUE_NAME_PREFIX##%$JobManagementQueueNamePrefix%g" \
          -e "s%##DEFAULT_JOB_TIMEOUT##%$DefaultJobTimeout%g" \
          -e "s%##APPLICATION_INSIGHTS_INSTRUMENTATION_KEY##%$AppInsightsInstrumentationKey%g" \
          -e "s%##APPLICATION_INSIGHTS_CONNECTION_STRING##%$AppInsightsConnectionString%g" \
          -e "s%##AUTHENTICATION_TENANT_ID##%$AuthenticationTenantId%g" \
          -e "s%##HOSTED_ENV_MSI_CLIENT_ID##%$HostedEnvMsiVlientId%g" $appSettingsFile > $updatedAppSettingsFile;

AppSettingsString="$(cat $updatedAppSettingsFile)";

AppSettingsString=`echo $AppSettingsString | perl -pe 's/\r\n//g'`;

sed -r -E -e "s%##PROD_SETTINGS##%$AppSettingsString%g" \
          -e "s%##PROD_JOB_SETTINGS##%$AppSettingsString%g" $configmapFile > $updatedConfigmapFile;

sed -r -E -e "s%##imagename##%$IdsServiceImageName%g" \
          -e "s%##workerimagename##%$WorkerServiceImageName%g" $k8DeploymentFile > $updatedK8DeploymentFile;

cat $updatedK8DeploymentFile;
echo "---------------------------------------------------------------------------------------------";
cat $updatedAppSettingsFile;
echo "---------------------------------------------------------------------------------------------";
cat $updatedConfigmapFile;
echo "---------------------------------------------------------------------------------------------";

# Installs kubectl CLI
az aks install-cli;

PATH="$PATH:$HOME/bin:$PATH";

kubectl version --short;

# Merge credentials into .kube/config
az account set -s $AksSubscriptionId;
az aks get-credentials --resource-group $AksResourceGroupName --name $AksClusterName;

kubectl apply -f $updatedConfigmapFile;
kubectl apply -f $updatedK8DeploymentFile;
kubectl get deployments;
kubectl get services;
