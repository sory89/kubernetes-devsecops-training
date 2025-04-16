#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.60.0 -q image --exit-code 0 --severity HIGH $dockerImageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.60.0 -q image --exit-code 0 --severity CRITICAL $dockerImageName

# Trivy scan result processing
exit_code=$?
echo "Exit Code : $exit_code"

# Check scan results
if [[ "${exit_code}" == 1 ]]; then
   echo "Image scanning failed. Vulnerabilities found"
   exit 1;
else
   echo "Image scanning passed. No CRITICAL vulnerabilities found"
fi;
