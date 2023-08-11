#get the ubuntu image
FROM ubuntu:22.04

#install Python on the image
RUN \
	apt-get update && \
	apt-get install -y apt-utils && \
	apt-get install -y python3 && \
	apt-get install -y build-essential && \
	apt-get install -y cmake && \
	apt-get install -y vim && \
	apt-get install -y curl && \
	curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \ 
	apt-get install -y nodejs && \ 
	npm -g install yarn && \
	yarn global add code-server
#create the directory for the server
#WORKDIR /BearCS##
RUN set -ex;\
	code-server --version;\
	cd ~/.config/code-server/;\
	ls -la;\
	cat config.yaml;\
	sed -i 's/^bind-addr:.*/bind-addr: 0.0.0.0:8080/' config.yaml;\
	sed -i 's/^auth:.*/auth: none/' config.yaml;\
	sed -i 's/^password:.*/password: none/' config.yaml

CMD ["code-server"]
	
EXPOSE 8080
#Commands that will run when the container starts
