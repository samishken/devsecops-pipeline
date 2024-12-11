pipeline {
  agent any

  stages {
      stage('test') {
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
      stage('unit Test') {
        steps {
          sh 'mvn test'
        }
        post {
          always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
          }
        }
      } 
      // stage('Mutation Tests - PIT') {
      //   steps {
      //     sh 'mvn org.pitest:pitest-maven:mutationCoverage'
      //   }
      //   post {
      //     always {
      //         pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
      //     }
      //   }
      // }
      // stage('SonarQube - STAT') {
      //   steps {
      //     withSonarQubeEnv('SonarQube') {
      //       sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName='numeric-application' -Dsonar.host.url=http://devsecops-westus.westus.cloudapp.azure.com:9000"
      //     }
      //     timeout(time: 2, unit: 'MINUTES'){
      //       script {
      //         waitForQualityGate abortPipeline: true
      //       }
      //     }
      //   }    
      // }
      // stage('Vulnerability Scan - Docker') {
      //   steps {
      //     sh "mvn dependency-check:check"
      //   }
      //   post {
      //     always {
      //       dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
      //     }
      //   }
      // }
    //   stage('Docker Build and Push') {
    //     steps {
    //       withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
    //         sh 'printenv'
    //         sh 'docker build -t samishken/numeric-app:""$GIT_COMMIT"" .'
    //         sh 'docker push samishken/numeric-app:""$GIT_COMMIT""'
    //       }
    //     }
    //   }
    //   stage('Kubernetes Deployment - DEV') {
    //     steps {
    //       withKubeConfig([credentialsId: 'kubeconfig']) {
    //         echo env.GIT_COMMIT
    //         sh "sed -i 's#replace#samishken/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
    //         sh "kubectl apply -f k8s_deployment_service.yaml"
    //       }
    //     }
    //   }
  }
}