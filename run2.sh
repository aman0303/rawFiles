k8DeploymentFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/deployment.yml";
appSettingsFileUrl="https://raw.githubusercontent.com/aman0303/rawFiles/main/appSettings.K8Pod.json";

k8DeploymentFile="toUpdateDeployment.yml";
appSettingsFile="toUpdateAppSettings.K8Pod.json";

wget -O $k8DeploymentFile $k8DeploymentFileUrl;
wget -O $appSettingsFile $appSettingsFileUrl;

updatedK8DeploymentFile="./deployment.yml";
updatedAppSettingsFile="./appSettings.K8Pod.json";

sed "s/##TEST_VALUE##/$3/g" $appSettingsFile > $updatedAppSettingsFile;

idsServiceImage=$4;
idsServiceImage=${idsServiceImage//\//\\/};

UUID=$(cat /proc/sys/kernel/random/uuid);
appSettingsConfigmap="app-settings-configmap-$UUID";

sed -e "s/##IDS_SERVICE_IMAGE##/$idsServiceImage/g ; s/##APP_SETTINGS_CONFIGMAP##/$appSettingsConfigmap/g" $k8DeploymentFile > $updatedK8DeploymentFile;

echo "---------------------------------------------------------------------------------------------";
cat $updatedK8DeploymentFile;
echo "---------------------------------------------------------------------------------------------";
cat $updatedAppSettingsFile;
echo "---------------------------------------------------------------------------------------------";

#Installs kubectl CLI
az aks install-cli;

PATH="$PATH:$HOME/bin:$PATH"

kubectl version --short;
