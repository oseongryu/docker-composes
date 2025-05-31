FROM ubuntu:latest

ENV USER="user" \
    PASSWORD="password"

RUN apt-get update && apt-get install -y sudo curl wget

RUN useradd -m ${USER} && echo "${USER}:${PASSWORD}" | chpasswd && usermod -aG sudo ${USER}

# # code-server 설치 및 세팅
ENV WORKINGDIR="/home/${USER}/vscode"
# RUN curl -fsSL https://code-server.dev/install.sh | sh && \
#     mkdir ${WORKINGDIR}

RUN wget -O code-server_4.100.2_amd64.deb "https://github.com/coder/code-server/releases/download/v4.100.2/code-server_4.100.2_amd64.deb" && \
    dpkg -i code-server_4.100.2_amd64.deb && \
    mkdir ${WORKINGDIR}

# Install extensions
RUN code-server --install-extension "ms-python.python" \
                --install-extension "ms-azuretools.vscode-docker"

# code-server 시작
ENTRYPOINT nohup code-server --bind-addr 0.0.0.0:8080 --auth password  ${WORKINGDIR}

# docker build --no-cache -t vscode-docker .
# docker run -it --name vscode-container -p 8080:8080 vscode-docker