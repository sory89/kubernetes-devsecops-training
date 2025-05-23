#!/bin/bash

#k8s-deployment-rollout-status.sh

sleep 60s

if [[ $(sudo -u vagrant kubectl -n default rollout status deploy ${deploymentName} --timeout 5s) != *"successfully rolled out"* ]]; 
then     
	echo "Deployment ${deploymentName} Rollout has Failed"
        sudo -u vagrant kubectl -n default rollout undo deploy ${deploymentName}
    exit 1;
else
	echo "Deployment ${deploymentName} Rollout is Success"
fi
