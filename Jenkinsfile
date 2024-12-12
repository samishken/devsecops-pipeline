pipeline {
  agent any

  stages {
      stage('Test-Start-Pipeline') {
        steps {
          sh 'echo "Hello World"'
        }
      }
      stage('Build Artifact') {
        steps {
          sh "mvn clean package -DskipTests=true"
          archive 'target/*.jar' 
        }
      }
      stage('Unit Test') {
        steps {
          sh 'mvn test'
        }
      } 
      stage('Mutation Tests - PIT') {
        steps {
          sh 'mvn org.pitest:pitest-maven:mutationCoverage'
        }
      }
      stage('SonarQube - STAT') {
        steps {
          withSonarQubeEnv('SonarQube') {
            sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName='numeric-application' -Dsonar.host.url=http://devsecops-westus.westus.cloudapp.azure.com:9000"
          }
          timeout(time: 2, unit: 'MINUTES'){
            script {
              waitForQualityGate abortPipeline: true
            }
          }
        }    
      }
      // stage('Vulnerability Scan - Docker') {
      //   steps {
      //     sh "mvn dependency-check:check"
      //   }
      // }
      stage('Vulnerability Scan - Docker') {
        steps {
          parallel(
            "Dependency Scan": {
              sh "mvn dependency-check:check"
            },
            "Trivy Scan":{
                sh "bash trivy-docker-image-scan.sh"   // create this script
            },
            "OPA Conftest":{   // Open Policy Agent (OPA) is collection of rules to statically analyze Dockerfiles to improve security
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
			      }  	
      	  ) 
        }
      }
      stage('Docker Build and Push') {
        steps {
          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh 'sudo docker build -t samishken/numeric-app:""$GIT_COMMIT"" .'
            sh 'docker push samishken/numeric-app:""$GIT_COMMIT""'
          }
        }
      }

      stage('Vulnerability Scan - Kubernetes') {
        steps {
            "OPA Scan": {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
            }
        }
      }
      stage('Kubernetes Deployment - DEV') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            echo env.GIT_COMMIT
            sh "sed -i 's#replace#samishken/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
        }
      }
  }
  post {
    always {
      junit 'target/surefire-reports/*.xml'
      jacoco execPattern: 'target/jacoco.exec'
      pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml' //add folder pit-reports
      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
    }
  }
}