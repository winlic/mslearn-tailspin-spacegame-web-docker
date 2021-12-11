#!/bin/bash

case $1 in

"Build an Docker image")
dockerfilePath=$2
RegistryShortName=$3
WebRepository=$4
tag=$5
buildContext=$6
docker build -t $RegistryShortName.azurecr.io/$WebRepository:$tag -f $dockerfilePath/Dockerfile $buildContext
;;


"Login to Azure Container Registry")
RegistryShortName=$2
RegistryPass=$3
docker login $RegistryShortName.azurecr.io --username $RegistryShortName --password $RegistryPass
;;


"Push Docker image to Azure Container Registry")
registryShortName=$2
webRepository=$3
tag=$4
docker push $registryShortName.azurecr.io/$webRepository:$tag
;;

"Create image pull secret")
RegistryShortName=$2
RegistryPass=$3
AKSNameSpace=$4
#echo "kubectl create secret docker-registry myregistrykey --docker-server=$RegistryShortName.azurecr.io --docker-username=$RegistryShortName --docker-password=$RegistryPass --namespace=$AKSNameSpace || true"
kubectl create secret docker-registry myregistrykey --docker-server=$RegistryShortName.azurecr.io --docker-username=$RegistryShortName --docker-password=$RegistryPass --namespace=$AKSNameSpace || true
;;


"Helm install or update Task")
applicationName=$2
buildContext=$3
RegistryShortName=$4
webRepository=$5
tag=$6
ResourceGroupName=$7
ClusterName=$8
AKSNameSpace=$9
#az login
az aks get-credentials --resource-group $ResourceGroupName --name $ClusterName --overwrite-existing
helm upgrade $applicationName $buildContext/Helm/ --set container.image=$RegistryShortName.azurecr.io/$webRepository:$tag --install --namespace $AKSNameSpace --create-namespace
;;


"Install Ingress")
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml
echo "If this External IP has no DNS name, please attach the DNS name to this IP:"
kubectl get service ingress-nginx-controller --namespace=ingress-nginx
;;


"Set Ingress rule")
WebAppName=$2
AKSNameSpace=$3
WebAppDNSName=$4
echo "kubectl create ingress $WebAppName --class=nginx --namespace=$AKSNameSpace --rule=$WebAppDNSName/*=$WebAppName-service:80"
kubectl create ingress $WebAppName --class=nginx --namespace=$AKSNameSpace --rule=$WebAppDNSName/*=$WebAppName-service:80 || true




esac
