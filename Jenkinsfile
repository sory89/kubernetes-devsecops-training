pipeline {
  agent any

  stages {

    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'
      }
    }

    stage('Unit Tests - JUnit and Jacoco') {
      steps {
        sh "mvn test"
      }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
        }
      }
    }

    stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      post {
        always {
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
      }
    }

    stage('SonarQube - SAST') {
      steps {
        sh "mvn sonar:sonar \
            -Dsonar.projectKey=numeric-application \
            -Dsonar.host.url=http://192.168.100.200:9000 \
            -Dsonar.login=cc332690ad8eef7b9477e16b6117c634f90e0856
        "
      }
    }
    
    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'printenv'
          sh 'docker build -t sorydiallo89/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push sorydiallo89/numeric-app:""$GIT_COMMIT""'
        }
      }
    }
   
   stage('Deploy on Kubernetes') {
    steps {
       withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
         sh '''
           sed -i 's#REPLACE_ME#sorydiallo89/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml
           sudo -u vagrant kubectl apply -f k8s_deployment_service.yaml
        '''
        }
     }
   }
  }
}
