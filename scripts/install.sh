#!/bin/bash

set -e

echo "Preparando Ambiente (Aguarde...)"
apt-get update -y
apt-get upgrade -y

apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    python3-venv

systemctl enable amazon-ssm-agent || true
systemctl start amazon-ssm-agent || true

install -m 0755 -d /etc/apt/keyrings

echo "Baixando Docker (Aguarde...)"

apt install docker.io -y

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

docker rm -f kali-lab 2>/dev/null || true
docker network rm lab-network 2>/dev/null || true

docker network create lab-network

echo "Subindo Kali Linux (Aguarde...)"
docker run -d \
  --name kali-lab \
  --network lab-network \
  --privileged \
  -p 6901:6901 \
  -e VNC_PW=urubu100 \
  --shm-size=512m \
  kasmweb/kali-rolling-desktop:1.15.0

echo "Aguardando inicialização (30 segundos)"
sleep 30

docker exec -u 0 kali-lab sh -c "echo 'kasm_user:urubu100' | chpasswd"
docker exec -u 0 kali-lab sh -c "echo 'kasm_user ALL=(ALL) ALL' >> /etc/sudoers"
docker exec -u 0 kali-lab sh -c "echo 'kasm-user:urubu100' | chpasswd"
docker exec -u 0 kali-lab sh -c "echo 'kasm-user ALL=(ALL) ALL' >> /etc/sudoers"

docker exec -u 0 kali-lab apt update
docker exec -u 0 kali-lab apt install -y nmap autopsy sleuthkit hydra