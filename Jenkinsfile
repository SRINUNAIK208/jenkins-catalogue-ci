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
       
       // SCANNER_HOME = tool 'Sonar'
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
        //     environment {
        //          scannerHome = tool "sonar"
        //     }
        //     steps{

                
        //         withSonarQubeEnv(installationName: 'sonar'){
        //             sh """
        //                 ${scannerHome}/bin/sonar-scanner
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
        stage('Dependabot Check') {
          environment{
            GITHUB_TOKEN = credentials('github-token')
          }
            steps {
                script {
                    def response = sh(
                        script: '''
                            curl -s \
                            -H "Accept: application/vnd.github+json" \
                            -H "Authorization: token ${GITHUB_TOKEN}" \
                            -H "X-GitHub-Api-Version: 2026-03-10" \
                            "https://api.github.com/repos/daws-84s/catalogue/dependabot/alerts"
                        ''',
                        returnStdout: true
                    ).trim()

                    def alerts = readJSON text: response

                    def criticalOrHigh = alerts.findAll { alert ->
                        def severity = alert?.security_vulnerability?.severity?.toLowerCase()
                        def state = alert?.state?.toLowerCase()

                        state == 'open' &&
                        (severity == 'critical' || severity == 'high')
                    }

                    if (criticalOrHigh) {
                        error "❌ Dependabot found ${criticalOrHigh.size()} open HIGH/CRITICAL alerts"
                    }

                    echo "✅ No open HIGH/CRITICAL Dependabot alerts"
                }
            }
        }
       
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
        // stage("tigger deployment"){
        //     steps{
        //         build job: 'catalogue-cd', 
        //         wait: false, 
        //         propagate: false
        //     }
        // } 

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