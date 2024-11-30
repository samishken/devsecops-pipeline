pipeline {
  agent any

  stages {
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
      //     steps {
      //       sh "mvn org.pitest:pitest-maven:mutationCoverage"
      //     }
      //     post {
      //       always {
      //           pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
      //       }
      //     }
      // }
      stage('Docker Build and Push') {
        steps {
          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh 'docker build -t samishken/numeric-app:""$GIT_COMMIT"" .'
            sh 'docker push samishken/numeric-app:""$GIT_COMMIT""'
          }
        }
      }

    }
}