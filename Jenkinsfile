pipeline {
    agent none
    stages {
        stage('Build and Test') {
            parallel {
                stage('Linux Run') {
                    agent {
                        docker {
                            image 'swift:latest'
                        }
                    }
                    stages {
                        stage('Update Package') {
                            steps {
                                sh 'swift package update'
                            }
                        }
                        stage('Build') {
                            steps {
                                sh 'swift package clean'
                                sh 'swift build'
                            }
                        }
                        stage('Test') {
                            steps {
                                sh 'swift test'
                            }
                        }
                    }
                }
                stage('Mac Run') {
                    when {
                        expression { params.SHOULD_DEPLOY == false }
                    }
                    agent {
                        label 'ios-slave'
                    }
                    environment {
                        PATH = "/usr/local/bin:/usr/local/sbin:$PATH"
                    }
                    post {
                        always {
                            junit 'build/reports/junit.xml'
                        }
                    }
                    stages {
                        stage('Update Package') {
                            steps {
                                sh 'swift package update'
                            }
                        }
                        stage('Mac Generate Xcode') {
                            steps {
                                sh 'swift package generate-xcodeproj'
                            }
                        }
                        stage('Build and Test') {
                            steps {
                                script {
                                    xcodeproj = sh(
                                        script: 'echo *.xcodeproj',
                                        returnStdout: true
                                    ).trim()
                                }
                                sh """
                                xcodebuild \
                                -project ${ xcodeproj } \
                                -scheme Run \
                                -destination 'platform=macOS' \
                                clean \
                                build \
                                test \
                                | xcpretty -r junit
                                """
                            }
                        }
                    }
                }
                stage('Mac Build and Deploy') {
                    when {
                        expression { params.SHOULD_DEPLOY == true }
                    }
                    agent {
                        label 'ios-slave'
                    }
                    environment {
                        PATH = "/usr/local/bin:/usr/local/sbin:$PATH"
                    }
                    post {
                        always {
                            junit 'build/reports/junit.xml'
                            sh 'rm -rf releases'
                            sh 'mkdir releases'
                            sh 'mkdir releases/${Release_Version}'
                            sh 'cp .build/debug/Run releases/${Release_Version}'
                            sh 'cd releases; zip -r ${Release_Version}.zip ${Release_Version}'
                            archiveArtifacts artifacts: 'releases/${Release_Version}.zip', fingerprint: true
                        }
                    }
                    stages {
                        stage('Checkout') {
                            steps {
                                // Checkout files.
                                checkout([
                                    $class: 'GitSCM',
                                    branches: [[name: 'master']],
                                    doGenerateSubmoduleConfigurations: false,
                                    extensions: [],
                                    submoduleCfg: [],
                                    userRemoteConfigs: [[
                                        name: 'github',
                                        url: 'https://github.com/kevcodex/${GITHUB_PROJECT}'
                                    ]]
                                ])
                            }
                        }
                        stage('Update Package') {
                            steps {
                                sh 'swift package update'
                            }
                        }
                        stage('Swift Build') {
                            steps {
                                sh 'swift package clean'
                                sh 'swift build'
                            }
                        }
                        stage('Mac Generate Xcode') {
                            steps {
                                sh 'swift package generate-xcodeproj'
                            }
                        }
                        stage('Build and Test') {
                            steps {
                                script {
                                    xcodeproj = sh(
                                        script: 'echo *.xcodeproj',
                                        returnStdout: true
                                    ).trim()
                                }
                                sh """
                                xcodebuild \
                                -project ${ xcodeproj } \
                                -scheme Run \
                                -destination 'platform=macOS' \
                                clean \
                                build \
                                test \
                                | xcpretty -r junit
                                """
                            }
                        }
                    }
                }
            }
        }
    }
}