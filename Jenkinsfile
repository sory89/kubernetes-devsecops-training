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

    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'printenv'
          sh 'docker build -t sorydiallo89/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push sorydiallo89/numeric-app:""$GIT_COMMIT""'
        }
      }
    }
   
    stages {
     stage('Deploy') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
          sh '''
            sed -i 's#REPLACE_ME#sorydiallo89/numeric-app:6d238ae6f68f97b5b54f8eb4afd740c133927d84#g' k8s_deployment_service.yaml
            kubectl apply -f k8s_deployment_service.yaml
          '''
        }
      }
    }
   }
  }
}
