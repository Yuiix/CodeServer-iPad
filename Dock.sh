#!/bin/bash
comand_var="$1"
server_image="code-server-image"
host_name=$(hostname)
docker -v > /dev/null 2>&1
#This part of the code will check id docker is present and install it otherwise
if [ "$?" = 0 ]; then 
	echo "The script is runing"
else
	echo "Seems like you dont have Docker installed, would you like to install it y/n?"
	read install_docker
		if [ "$install_docker" = "y" ]; then
			echo "installing Docker...."
			sudo apt-get update > /dev/null 2>&1
			sudo apt install docker.io -y > /dev/null 2>&1
			docker -v > /dev/null 2>&1
			if [ "$?" = 0 ]; then
				echo "the installation has been succesfull, the script will continue"
				systemctl start docker > /dev/null 2>&1
				sudo gpasswd -a $USER docker
			else
				echo "the installation failed you may want to try manually"
				exit 1			
			fi

		else
			echo "you need to install docker before running this script"
			echo "The script has finished due the need of docker installation, you maybe want to install it manually"
			exit 1
		fi
fi
#This part of the code will create/start and stop the code server, including the options of the certificate and password

container_id=$(docker ps -a | grep "$server_image" | awk '{print $1}')
if [ "$comand_var" = "create" ]; then
	echo "would you like to create a password for your server? y/n"
	read pw_confirmation
	mkdir -p $HOME/CodeServer/share
	mkdir -p $HOME/CodeServer/DockFile && cp Dockerfile $HOME/CodeServer/DockFile
	echo "do you want the secure certificate? y/n"
	read sec_certi
	mkdir -p $HOME/CodeServer/Certificate
	if [ "$pw_confirmation" = "y" ]; then
		echo "Introduce the password:"
		read password
		sed -i "s|password: no.*|password: $password/' config.yaml;\\\\|" $HOME/CodeServer/DockFile/Dockerfile
		sed -i "s|auth: no.*|auth: password/' config.yaml;\\\\|" $HOME/CodeServer/DockFile/Dockerfile
		echo "The pasword has been set to $password"
		cat $HOME/CodeServer/DockFile/Dockerfile
	elif [ "$pw_confirmation" = "n" ];then
		echo "the password has been set to none"
	else
		echo "you did not introduce a valid option the password has been set to none"
	fi
	if [ "$sec_certi" = "y" ]; then
		echo "the certification file will be generated" 
		sed -i "s|cert: fa.*|cert: true/' config.yaml;\\\\|" $HOME/CodeServer/DockFile/Dockerfile
		sed -i "s|cert-host: .*|cert-host: $(hostname).local' >> config.yaml;\\\\|" $HOME/CodeServer/DockFile/Dockerfile
	else
		echo "Certification file wont be generated"
	fi
	#cat $HOME/CodeServer/DockFile/Dockerfile
	docker build -t code-server-image $HOME/CodeServer/DockFile
# This part of the code is to start the sever
elif [ "$comand_var" = "start" ]; then
	docker run --rm -d -v $HOME/CodeServer/share:/root/.local/share -v $HOME:$HOME -p 8080:8080 $server_image
	echo "A container with a codeserver is running... give it a few seconds and you
	will be able to log in with the following link: http:/$host_name.local:8080"
# This part of the code is to stop the container
elif [ "$comand_var" = "stop" ]; then
	if [ -n "$container_id" ]; then
		echo "The container with the ID: $container_id will be stop"
		docker stop "$container_id"
		#docker rm --force "$container_id"
		#echo "$?"
		if [ "$?" = 1 ]; then
			echo "the container was already removed"
		fi
	else
		echo "There is no container running for the Code server image: $server_image
		you may want to create one with Docker.sh create"
	fi

else
	echo "wrong command, you maybe want to use one of the following comands, 
	create, start and stop"
fi
# TODO Copy the certificate to other location
# TODO add more ports to expose if they want to
# TODO create a utility docker for any other tool needed that wont affect the server
# TODO create the script that will generate that docker file
# TODO Add an option for automatic configuration right after boot theRPI or any linux machine
