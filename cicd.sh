#!/bin/bash

#We are using this block to abort the script based on exit level
#Start
trap "exit 1" TERM
export TOP_PID=$$
#End

#Function to create a log file and remove incase of multiple runs
#Start
function create_log_file(){
    file_name=$2-$3-$4-$5.log
    if [ -e $file_name ];
        #echo "delete file $file_name "
        then rm -rf $file_name
    else
        echo "creating file"
    fi
    touch file_name
    start_date=`date`
    echo "$start_date \n" >> $file_name 2>&1
    echo "Created $file_name to capture logs" >> $file_name 2>&1
    echo "Valid parameter passed and we are building pipeline using below values" >> $file_name 2>&1
    echo "1. Github Repository URL $1" >> $file_name 2>&1
    echo "2. Github Repo name $2" >> $file_name 2>&1
    echo "3. Api microservice name $3" >> $file_name 2>&1
    echo "4. Tag name $4" >> $file_name 2>&1
    echo "5. Replicas requested $5" >> $file_name 2>&1
    echo "\n" >> $file_name 2>&1
}
#End

#Function to clone the github repository
#Start
function clone_git(){
    echo "Started Cloning $1 github Repository" >> $file_name 2>&1
    git clone --branch test-cicd $1  >> $file_name 2>&1
    [ $? -eq 0 ]  || kill -s TERM $TOP_PID
    echo "\n" >> $file_name 2>&1
}
#End

#Function to build and push docker image
#Start
function docker_build_push(){
    base_location=$1
    cd $1
    echo "Docker login sucessful" >> ../$file_name 2>&1
    docker login -u vasudevdchavan -p Passw0rd00 >> ../$file_name 2>&1
    docker build -t $2:$3 . >> ../$file_name 2>&1
    docker tag $2:$3 vasudevdchavan/$2:$3
    docker push vasudevdchavan/$2:$3  >> ../$file_name 2>&1
    docker logout
    echo "Docker push sucessful" >> ../$file_name 2>&1
    [ $? -eq 0 ]  || kill -s TERM $TOP_PID
    echo "\n" >> ../$file_name 2>&1
}
#End

#Function to deploy the application
#Start
function tanzu_deploy(){
    echo "We are deploying microserivce $1 with tag $2 with $3 replicas" >> ../$file_name 2>&1
    sed "s/sample:v1/vasudevdchavan\/$1:$2/g" deployment.yaml > final_deployment.yaml
    cat final_deployment.yaml >> ../$file_name 2>&1
    kubectl apply -f final_deployment.yaml >> ../$file_name 2>&1
    [ $? -eq 0 ]  || kill -s TERM $TOP_PID
    #kill -s TERM $TOP_PID
    echo "\n" >> ../$file_name 2>&1
}
#End


# Reading passed parameters
# cicd.sh GITHUB_URL GITHUB_REPO_NAME DOCKERFILE TAG REPLICAS
if [ $# -eq 5 ];
    then 
        create_log_file $1 $2 $3 $4 $5
        clone_git $1 
        docker_build_push $2 $3 $4
        tanzu_deploy $3 $4 $5
        cd ..
        #sleep 10
        echo "Removing directory $2" >> $file_name 2>&1
        rm -rf $2
else
    echo "Please pass valid parameters"
fi


