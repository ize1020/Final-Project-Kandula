
pipeline {
    agent {label "node1"}
    stages {
        stage('slack massage') {
            steps{
                script{
                slackSend color: "#6a0dad", message: "Build Started: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
                end = "failure"
                customImage = ""}
            }
            }
        stage("install docker") {
            steps{
                script {
                    sh '''sudo apt install docker.io -y
                          sudo systemctl start docker
                          sudo systemctl enable docker
                          sudo usermod -aG docker ubuntu
                          sudo chmod 666 /var/run/docker.sock'''

                    end = "success"
                }
            }
        }
        stage("build docker") {
            steps{
                script {
                    end = "failure"
                    customImage =
                        docker.build("isaac1020/jenkins1:kandula-appv2:${env.BUILD_NUMBER}")
                    end = "success"
                }
             }
        }
        stage("verify dockers") {
            steps{
                sh "docker images"
            }
        }
        stage("push docker") {
            steps{
                script{
                    end = "failure"
                    withDockerRegistry(credentialsId: 'dockerhub.isaac1020') {
                        customImage.push()
                    }
                    end = "success"
                }
            }
        }
        stage("update yaml") {
            steps{
                script{
                end = "failure"
                sh """
                tee ~/k8s/pod-kandula.yaml > /dev/null <<'EOF'
                # Create a pod and expose port 8080
                apiVersion: v1
                kind: Pod
                metadata:
                  name: kandula-pod
                  labels:
                    app: backend
                spec:
                  containers:
                    - image: isaac1020/jenkins1:kandula-appv2:${env.BUILD_NUMBER}
                      name: kandula
                      ports:
                        - containerPort: 5000
                          name: http
                          protocol: TCP
                      env:
                        - name: FLASK_ENV
                          value: development

                      envFrom:
                        - secretRef:
                            name: test
                EOT
                """
               end = "success"
                }
            }
        }

        stage("delete docker") {
           steps{
                script {
                    end = "failure"
                    sh "docker image rm isaac1020/jenkins1:kandula-appv2:${env.BUILD_NUMBER}"
                    end = "success"
                }
           }
        }
    }
    post{
        always{
            script{
                if (end == "success"){
                    slackSend color: "#00FF00", message: "Build ended successfully: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
                    slackSend color: "#00FF00", message: "results: ${env.BUILD_URL}"}
                else{
                    slackSend color: "#FF0000", message: "Build ended with errors: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
                    slackSend color: "#FF0000", message: "results: ${env.BUILD_URL}"}

            }

        }
    }

}
