#!/bin/bash
#This part will download the repository with the bash script and docker file
comand_var="$1"
server_image="code-server-image"
container_id=$(docker ps -a | grep "$server_image" | awk '{print $1}')
host_name=$(hostname)
if [ "$comand_var" = "create" ]; then
	mkdir -p $HOME/CodeServer/share
	mkdir -p $HOME/CodeServer/DockFile && cp Dockerfile $HOME/CodeServer/DockFile
	docker build -t code-server-image $HOME/CodeServer/DockFile
# This part of the code is to start the sever
elif [ "$comand_var" = "start" ]; then
	docker run --rm -d -v $HOME/CodeServer/share:/root/.local/share -p 8080:8080 $server_image
	echo "A container with a codeserver is running... give it a few seconds and you
	will be able to log in with the following link: http/$host_name.local:8080"
# This part of the code is to stop the container
elif [ "$comand_var" = "stop" ]; then
	if [ -n "$container_id" ]; then
		echo "The container with the ID: $container_id will be stop"
		docker stop "$container_id"
	else
		echo "There is no container running for the Code server image: $server_image
		you may want to create one with Docker.sh create"
	fi

else
	echo "wrong command, you maybe want to use one of the following comands, 
	create, start and stop"
fi
# TODO add the dirs for share the files
# TODO add them into the docker file so it gets created here and in the docker
# TODO upload to github the dockerfile
# TODO add the rutine for automatic DL of git hub and copy all the necessary