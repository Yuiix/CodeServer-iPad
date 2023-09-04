#get the ubuntu image
FROM ubuntu:22.04

#install Python on the image
ARG DEBIAN_FRONTEND=noninteractive
RUN \
	apt-get update && \
	apt-get install -y apt-utils && \
	apt-get install -y python3 && \
	apt-get install -y build-essential && \
	apt-get install -y curl && \
	curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \ 
	apt-get install -y nodejs && \ 
	npm -g install yarn && \
	yarn global add code-server
#This little rutine will just modify the config.yaml to add the pw or certificate if requested by user
RUN set -ex;\
	code-server --version > /dev/null 2>&1;\
	cd ~/.config/code-server/;\
	sed -i 's/^bind-addr:.*/bind-addr: 0.0.0.0:8080/' config.yaml;\
	sed -i 's/^auth:.*/auth: none/' config.yaml;\
	sed -i 's/^password:.*/password: none/' config.yaml;\
	sed -i 's/^cert: .*/cert: false/' config.yaml;\
	echo 'cert-host: ' >> config.yaml;\
	code-server --version > /dev/null 2>&1;

CMD ["code-server"]
	
EXPOSE 8080
#Commands that will run when the container starts
