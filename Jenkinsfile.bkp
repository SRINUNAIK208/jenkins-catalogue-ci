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
     parameters {
       
        booleanParam(name: 'deploy', defaultValue: false, description: 'Toggle to enable or disable tests')
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
    //    stage('Dependabot Check') {
    //         environment {
    //             GITHUB_TOKEN = credentials('github-token')
    //         }

    //         steps {
    //             script {

    //                 def response = sh(
    //                     script: '''
    //                         curl -s \
    //                         -H "Accept: application/vnd.github+json" \
    //                         -H "Authorization: token ${GITHUB_TOKEN}" \
    //                         -H "X-GitHub-Api-Version: 2026-03-10" \
    //                         "https://api.github.com/repos/daws-84s/catalogue/dependabot/alerts?state=open&severity=high,critical"
    //                     ''',
    //                     returnStdout: true
    //                 ).trim()

    //                 def alerts = readJSON text: response

    //                 // if (alerts instanceof Map && alerts.message) {
    //                 //     error "❌ GitHub API error: ${alerts.message}"
    //                 // }

    //                 echo "Dependabot OPEN HIGH/CRITICAL alerts: ${alerts.size()}"

    //                 if (alerts.size() > 0) {
    //                     error "❌ Dependabot found ${alerts.size()} open HIGH/CRITICAL alerts"
    //                 }

    //                 echo "✅ No open HIGH/CRITICAL Dependabot alerts"
    //             }
    //         }
    //     }
       
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
         stage('ECR Scan'){
            steps{
                script{
                    withAWS(credentials: 'aws-cred', region: 'us-east-1'){
                        def findings = sh(
                            script: """
                              aws ecr describe-image-scan-findings \
                              --repository-name roboshop/catalogue \
                              --image-id imageDigest=sha256:be555a9f8dd81cd3fefdbb0d144216d5249cc2464ae522d64e29a8a44393f00e \
                              --region us-east-1 \
                              --output json

                            """, 
                            returnStdout: true
                            
                         ).trim();
                         def json = readJSON text: findings
                         def highCritical = json.imageScanFindings.findings.findAll {
                            it.severity == "HiGH" || it.severity == "CRITICAL"
                         }
                         if (highCritical.size() > 0)
                         {
                             echo "❌ Found ${highCritical.size()} HIGH/CRITICAL vulnerabilities!"
                            currentBuild.result = 'FAILURE'
                            error("Build failed due to vulnerabilities")
                        } else {
                            echo "✅ No HIGH/CRITICAL vulnerabilities found."
                        }
                         
                    }
                }
            }
        }
        stage("tigger deployment"){
            steps{
                build job: 'catalogue-cd',
                 parameters: [
                    string(name: 'appVersion', value: "${appVersion}"), 
                    string(name: 'deploy_to', value: 'qa')
                 ],
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