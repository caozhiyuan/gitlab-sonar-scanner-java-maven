#!/usr/bin/env bash

echo "========================="
echo "Docker push: started..."
echo "========================="

echo "Docker build image"
docker build -t caozhiyuan/gitlab-sonar-scanner-java-maven:latest .

echo "Docker tag image"
docker tag caozhiyuan/gitlab-sonar-scanner-java-maven:latest caozhiyuan/gitlab-sonar-scanner-java-maven:latest

echo "Docker push image"
docker push caozhiyuan/gitlab-sonar-scanner-java-maven:latest

echo "========================="
echo "Docker push: completed..."
echo "========================="
