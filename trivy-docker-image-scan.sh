#!/bin/bash

# Get docker image from docker file
dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)  
echo $dockerImageName

# light is a parameter of trivy
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.55.1 -q image --exit-code 0 --severity HIGH --light $dockerImageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.55.1 -q image --exit-code 1 --severity CRITICAL --light $dockerImageName

    # check the exit code and continue to send the message
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