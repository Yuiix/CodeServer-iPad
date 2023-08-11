#!/bin/bash
#This part will download the repository with the bash script and docker file
comand_var="$1"
server_image="code-server-image"
container_id=$(docker ps -a | grep "$server_image" | awk '{print $1}')
host_name=$(hostname)
if [ "$comand_var" = "create" ]; then
	echo "would you like to create a password for your server? y/n"
	read pw_confirmation
	mkdir -p $HOME/CodeServer/share
	mkdir -p $HOME/CodeServer/DockFile && cp Dockerfile $HOME/CodeServer/DockFile
	if [ "$pw_confirmation" = "y" ]; then
		echo "Introduce the password:"
		read password
		sed -i "s|password: no.*|password: $password/' config.yaml|" $HOME/CodeServer/DockFile/Dockerfile
		sed -i "s|auth: no.*|auth: password/' config.yaml;\\\\|" $HOME/CodeServer/DockFile/Dockerfile
		echo "The pasword has been set to $password"
		cat $HOME/CodeServer/DockFile/Dockerfile
	elif [ "$pw_confirmation" = "n" ];then
		echo "the password has been set to none"
	else
		echo "you did not introduce a valid option the password has been set to none"
	fi
	docker build -t code-server-image $HOME/CodeServer/DockFile
# This part of the code is to start the sever
elif [ "$comand_var" = "start" ]; then
	docker run --rm -d -v $HOME/CodeServer/share:/root/.local/share -v $HOME:$HOME -p 8080:8080 $server_image
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
# TODO add the volum for code
# TODO add the posibility for the secure certificate
# TODO add the file for the password and certificate if they want to
# TODO add more ports to expose if they want to
# TODO create a utility docker for any other tool needed that wont affect the server
# TODO Add an option for automatic configuration right after boot theRPI or any linux machine
