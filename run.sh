k8DeploymentFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/deployment.yml";
appSettingsFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/appSettings.K8Pod.json";

k8DeploymentFile="toUpdateDeployment.yml";
appSettingsFile="toUpdateAppSettings.K8Pod.json";

wget -O $k8DeploymentFile $k8DeploymentFileUrl;
wget -O $appSettingsFile $appSettingsFileUrl;

updatedK8DeploymentFile="./deployment.yml";
updatedAppSettingsFile="./appSettings.K8Pod.json";

sed "s/##TEST_VALUE##/New-Value/g" $appSettingsFile > $updatedAppSettingsFile;

sed -e "s/##IDS_SERVICE_IMAGE##/New-Image/g ; s/##APP_SETTINGS_CONFIGMAP##/New-Configmap/g" $k8DeploymentFile > $updatedK8DeploymentFile;

echo "---------------------------------------------------------------------------------------------";
cat $updatedK8DeploymentFile;
echo "---------------------------------------------------------------------------------------------";
cat $updatedAppSettingsFile;
echo "---------------------------------------------------------------------------------------------";
