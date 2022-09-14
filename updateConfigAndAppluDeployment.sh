k8DeploymentFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/deploymentMDS.yml";
appSettingsFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/appsettings.prod.json";

k8DeploymentFile="toUpdateDeployment.yml";
appSettingsFile="toUpdateAppSettings.prod.json";

wget -O $k8DeploymentFile $k8DeploymentFileUrl;
wget -O $appSettingsFile $appSettingsFileUrl;

updatedK8DeploymentFile="./deploymentMDS.yml";
updatedAppSettingsFile="./appsettings.prod.json";

DatabaseServiceEndpoint="http://localhost/8080";

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
          -e "s%##JOB_MANAGEMENT_QUEUE_CONNECTION_STRING##%$JobManagementQueueConnectionString%g" \
          -e "s%##JOB_MANAGEMENT_SERVICE_ENDPOINT##%$JobManagementServiceEndpoint%g" \
          -e "s%##JOB_MANAGEMENT_ACCOUNT_URI##%$JobManagementAccountUri%g" \
          -e "s%##JOB_MANAGEMENT_DATABASE_NAME##%$JobManagementDatabaseName%g" \
          -e "s%##JOB_MANAGEMENT_COLLECTION_NAME##%$JobManagementCollectionName%g" \
          -e "s%##JOB_MANAGEMENT_QUEUE_NAME_PREFIX##%$JobManagementQueueNamePrefix%g" \
          -e "s%##APP_INSIGHTS_INSTRUMENTATION_KEY##%$AppInsightsInstrumentationKey%g" \
          -e "s%##HOSTED_ENV_MSI_CLIENT_ID##%$HostedEnvMsiVlientId%g" $appSettingsFile > $updatedAppSettingsFile;

UUID=$(cat /proc/sys/kernel/random/uuid);
AppSettingsConfigmap="mds-app-settings-configmap-$UUID";

cat $k8DeploymentFile;
echo "---------------------------------------------------------------------------------------------";
cat $appSettingsFile;
echo "---------------------------------------------------------------------------------------------";

sed -r -E -e "s%##MDS_SERVICE_IMAGE_NAME##%$IdsServiceImageName%g" \
          -e "s%##MDS_APP_SETTINGS_CONFIGMAP##%$AppSettingsConfigmap%g" $k8DeploymentFile > $updatedK8DeploymentFile;

cat $updatedK8DeploymentFile;
echo "---------------------------------------------------------------------------------------------";
cat $updatedAppSettingsFile;
echo "---------------------------------------------------------------------------------------------";

# # Installs kubectl CLI
# az aks install-cli;
# PATH="$PATH:$HOME/bin:$PATH"
# kubectl version --short;
# # Merge credentials into .kube/config
# az aks get-credentials --resource-group $AksResourceGroupName --name $AksClusterName;
# # Default namespace will be used from here
# kubectl create configmap $appSettingsConfigmap --from-file=$updatedAppSettingsFile;
# kubectl apply -f $updatedK8DeploymentFile;
# kubectl get deployments;
# kubectl get services;
