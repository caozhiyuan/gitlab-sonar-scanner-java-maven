# gitlab-sonar-scanner-java-maven
### NO LONGER SUPPORTED

Gitlab docker container to execute sonar-scanner analysis (Java, Apache Maven based applications) 

## Usage
Create/Update `.gitlab-ci.yml`

~~~yaml
stages:
- quality

sonarqube:
  stage: quality
  image: forcelate/gitlab-sonar-scanner-java-maven
  variables:
    SONAR_HOST_URL: http://sonarqube.ipaddress
    SONAR_LOGIN: sonarqube_login
    SONAR_PASSWORD: sonarqube_password
  script:
  # know issues in java, apache maven based application
  # apk add --no-cache procps
 script:
  - mvn clean install -U -Dmaven.test.skip=true -Dspring.profiles.active=test 
  - sonar-scanner -Dsonar.java.binaries=. -Dsonar.sources=. -Dsonar.language=java -Dsonar.links.homepage=$CI_REPOSITORY_URL -Dsonar.host.url=$SONAR_URL -Dsonar.login=$SONAR_LOGIN -Dsonar.projectKey=$CI_PROJECT_NAME -Dsonar.gitlab.project_id=$CI_PROJECT_NAME -Dsonar.gitlab.commit_sha=$CI_COMMIT_SHA -Dsonar.gitlab.ref_name=$CI_COMMIT_REF_NAME -Dsonar.gitlab.failure_notification_mode=commit-status
  - |
  
    REPORT_PATH=".scannerwork/report-task.txt"
    CE_TASK_ID_KEY="ceTaskId="

    SONAR_INSTANCE="$SONAR_URL"
    SONAR_ACCESS_TOKEN="$SONAR_LOGIN"
    SLEEP_TIME=3
      
    # get the compute engine task id
    ce_task_id=$(cat $REPORT_PATH | grep $CE_TASK_ID_KEY | cut -d'=' -f2)
    echo "QG Script --> Using task id of ${ce_task_id}"
    
    if [ -z "$ce_task_id" ]; then
       echo "QG Script --> No task id found"
       exit 1
    fi
    
    # grab the status of the task
    # if CANCELLED or FAILED, fail the Build
    # if SUCCESS, stop waiting and grab the analysisId
    wait_for_success=true
    
    while [ "${wait_for_success}" = "true" ]
    do
      ce_status=$(curl -s -u "${SONAR_ACCESS_TOKEN}": "${SONAR_INSTANCE}"/api/ce/task?id=${ce_task_id} | jq -r .task.status)
    
      echo "QG Script --> Status of SonarQube task is ${ce_status}"
    
      if [ "${ce_status}" = "CANCELLED" ]; then
        echo "QG Script --> SonarQube Compute job has been cancelled - exiting with error"
        exit 1
      fi
    
      if [ "${ce_status}" = "FAILED" ]; then
        echo "QG Script --> SonarQube Compute job has failed - exiting with error"
        exit 1
      fi
    
      if [ "${ce_status}" = "SUCCESS" ]; then
        wait_for_success=false
      fi
    
      sleep "${SLEEP_TIME}"
    
    done
    
    ce_analysis_id=$(curl -s -u $SONAR_ACCESS_TOKEN: $SONAR_INSTANCE/api/ce/task?id=$ce_task_id | jq -r .task.analysisId)
    echo "QG Script --> Using analysis id of ${ce_analysis_id}"
    
    # get the status of the quality gate for this analysisId
    qg_status=$(curl -s -u $SONAR_ACCESS_TOKEN: $SONAR_INSTANCE/api/qualitygates/project_status?analysisId="${ce_analysis_id}" | jq -r .projectStatus.status)
    echo "QG Script --> Quality Gate status is ${qg_status}"
    
    if [ "${qg_status}" != "OK" ]; then
      echo "QG Script --> Quality gate is not OK - exiting with error"
      exit 1
    fi

~~~

3) Install [Sonar GitLab Plugin](https://github.com/gabrie-allaigre/sonar-gitlab-plugin) in your SonarQube 
<p align="center">
	<img src="https://github.com/forcelate/gitlab-sonar-scanner-java-maven/blob/master/img/sonar-gitlab-plugin-installation.png?raw=true" alt=""/>
</p>

4) Create SonarQube user
5) Grant **Execute Analysis** permission on SonarQube project

### Known issues
issue: maven-surefire-plugin issue: [JIRA-1422](https://issues.apache.org/jira/browse/SUREFIRE-1422)  
solution: install `procps` or downgrade to version: 2.20

## Any ideas?
If you have any ideas, questions or suggestions, please don't hesitate to contact us at <info@forcelate.com> or submit new [Github issue](https://github.com/forcelate/gitlab-sonar-scanner-java-maven/issues/new).

## License (GNU-GPLv3)
Copyright (c) 2018 Forcelate <info@forcelate.com>
