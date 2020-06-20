FROM jenkins/jenkins:lts

USER root

# prerequisites for docker
RUN apt-get update \
    && apt-get -y install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
        python \
        python-pip

# docker repos
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    && apt-get update

# docker
RUN apt-get -y install docker-ce-cli

# Update PIP
RUN pip install --upgrade pip

# docker-compose
RUN pip install docker-compose

# give jenkins docker rights
RUN groupadd -g 994 docker && usermod -aG docker jenkins

USER jenkins
