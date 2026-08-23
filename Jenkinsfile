pipeline {
    agent {
        label 'AGENT-1'
    }
    options{
        timeout(time:30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    environment {
        appVersion = ''
        REGION = 'us-east-1'
        ACC_ID = '388343452532'
        project = 'roboshop'
        component = 'catalogue'
       // SCANNER_HOME = tool 'Sonar-scanner'
    }  
    stages{
        stage('read the package json'){
            steps{
                script {
                    def packageJson = readJSON file: 'package.json'
                    appVersion = packageJson.version
                    echo "application version ${appVersion}"
            
                }

            }
        }
        stage('install dependency'){
            steps{
                sh """
                   npm install 
                """
            }
        }
        // stage('sonarqube analysis'){
        //     steps{

                
        //         withSonarQubeEnv(credentialsId: 'sonar-credentialsId', installationName: 'Sonar'){
        //             sh """
        //                 $SCANNER_HOME/bin/sonar-scanner
        //             """
        //         }
        //     }
            
        // }
        // stage('sonarqube quality gates'){
        //     steps{
        //         timeout(time: 10, unit: 'MINUTES') {
        //            waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }
       
        stage('build docker image'){
            steps{
                withAWS(credentials: 'aws-cred', region: 'us-east-1'){
                    sh """
                       aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACC_ID}.dkr.ecr.us-east-1.amazonaws.com
                       docker build -t ${ACC_ID}.dkr.ecr.us-east-1.amazonaws.com/${project}/${component}:${appVersion} .
                       docker push ${ACC_ID}.dkr.ecr.us-east-1.amazonaws.com/${project}/${component}:${appVersion}
                    """
                }
            }
        }  
        stage("tigger deployment"){
            steps{
                build job: 'catalogue-cd', 
                wait: false, 
                propagate: false
            }
        } 

    }
    post {
        always {
            echo "hello i am always block"
        }
        success {
            echo "i am success"
        }
        failure {
            echo "i am failed"
        }
    }
}