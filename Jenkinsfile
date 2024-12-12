pipeline {
  agent any

  stages {
      stage('Test-Pipeline') {
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