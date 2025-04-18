#!/bin/bash


echo "🔍 Scan Trivy de l'image : $IMAGE_NAME"

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.60.0 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH $imageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.60.0 -q image --exit-code 1 --severity CRITICAL $imageName

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
