k8DeploymentFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/deployment.yml";
appSettingsFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/appSettings.K8Pod.json";

k8DeploymentFile="toUpdateDeployment.yml";
appSettingsFile="toUpdateAppSettings.K8Pod.json";

wget -O $k8DeploymentFile $k8DeploymentFileUrl;
wget -O $appSettingsFile $appSettingsFileUrl;

updatedK8DeploymentFile="./deployment.yml";
updatedAppSettingsFile="./appSettings.K8Pod.json";

sed "s/##TEST_VALUE##/New-Value/g" $appSettingsFile > $updatedAppSettingsFile;

sed "s/##IDS_SERVICE_IMAGE##/New-Image/g" $k8DeploymentFile > $updatedK8DeploymentFile;
sed "s/##APP_SETTINGS_CONFIGMAP##/New-Configmap/g" $k8DeploymentFile > $updatedK8DeploymentFile;

cat $updatedK8DeploymentFile;
cat $updatedAppSettingsFile;
