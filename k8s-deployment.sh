#!/bin/bash

#k8s-deployment.sh

sed -i "s#replace#${imageName}#g" k8s_deployment_service.yaml
sudo -u vagrant kubectl -n default get deployment ${deploymentName} > /dev/null

if [[ $? -ne 0 ]]; then
    echo "deployment ${deploymentName} doesnt exist"
   sudo -u vagrant kubectl -n default apply -f k8s_deployment_service.yaml
else
    echo "deployment ${deploymentName} exist"
    echo "image name - ${imageName}"
    sudo -u vagrant kubectl -n default set image deploy ${deploymentName} ${containerName}=${imageName} --record=true
fi
