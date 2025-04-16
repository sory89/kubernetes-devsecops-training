#!/bin/bash


echo "🔍 Scan Trivy de l'image : $IMAGE_NAME"

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.48.4 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.48.4 -q image --exit-code 1 --severity CRITICAL --light $imageName

# Trivy scan result processing
exit_code=$?
echo "Exit Code : $exit_code"

# Check scan results
if [[ ${exit_code} == 1 ]]; then
   echo "Image scanning failed. Vulnerabilities found"
   exit 1; 
else
   echo "Image scanning passed. No vulnerabilities found"
fi;
