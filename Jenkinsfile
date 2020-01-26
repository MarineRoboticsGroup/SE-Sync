pipeline {
	agent { 
		dockerfile {
			args '-e HOME=$WORKSPACE'
			additionalBuildArgs '--build-arg USER_ID=$(id -u)'
		}
	}
	stages {
		stage('Build') {
			steps {
				withCredentials([sshUserPrivateKey(credentialsId: "marineroboticsmit", keyFileVariable: 'keyfile')]) {
                                    sh '''mkdir -p ~/.ssh/
                                    cp $keyfile ~/.ssh/id_rsa
                                    echo $GIT_SSH_COMMAND
                                    echo 'Anything that has to deal with authentication?'
                                    rm -r ~/.ssh/
				'''
				}
				sh '''#!/bin/bash -l
        cd C++
				echo 'Building...'
        echo 'pwd:'
        pwd
        echo 'ls:'
        ls
        mkdir build
        cd build
        echo 'pwd:'
        pwd
        cmake ..
        make -j8
				'''
			}
		}
		stage('Test') {
			steps {
				echo 'Testing..'
				echo 'Run unit tests here'
        sh '''#!/bin/bash -l
        cd C++ 
        echo 'pwd:'
        pwd
        echo 'ls:'
        ls
        cd build
        ./bin/SE-Sync ../../data/intel.g2o
        '''
			}
		}
		stage('Deploy') {
			steps {
				echo 'Deploying....'
				echo 'Run on datasets (can this be done locally with docker?'
			}
		}
	}
}
		