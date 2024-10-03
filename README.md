# Docker

Docker 이미지만을 위한 저장소.

## Askfront.com

초보자도 자유롭게 질문할 수 있는 포럼을 만들었습니다. <br />
NavyStack의 가이드 뿐만 아니라, 아니라 모든 종류의 질문을 하실 수 있습니다.

검색해도 도움이 되지 않는 정보만 나오는 것 같고, 주화입마에 빠진 것 같은 기분이 들 때가 있습니다.<br />
그럴 때, 부담 없이 질문해 주세요. 같이 의논하며 생각해봅시다.

[AskFront.com (에스크프론트) 포럼](https://askfront.com/?github)

## Ubuntu Docker 설치

```bash
sudo apt-get update \
    && sudo apt-get install -y ca-certificates curl gnupg \
    && sudo install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && sudo chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Debian Docker 설치

```bash
sudo apt-get update \
    && sudo apt-get install -y ca-certificates curl gnupg \
    && sudo install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && sudo chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## CentOS, OL9 Docker 설치

```bash
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
    && sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y \
    && sudo systemctl enable docker.service \
    && sudo systemctl enable containerd.service \
    && sudo systemctl start docker
```

## 공통사항

### docker 그룹 부여하기

```bash
sudo chown root:docker /var/run/docker.sock && \
    sudo usermod -aG docker $USER
```

반드시 일반 유저로 실행

### Docker 볼륨 일괄제거하기

```bash
docker volume rm $(docker volume ls -f dangling=true -q)
```

### Docker 사용하지 않는 이미지, 빌드 캐시, 사용하지 않는 네트워크 설정등 한 방에 밀기

```bash
docker system prune -af
```

### Docker 빌드 캐시만 날리기

```bash
docker buildx prune -af
```

### Compile 관련

```bash
docker buildx build --platform linux/arm/v7 -t test -f Dockerfile . --load --progress=plain 2>&1 | grep "Run-time dependency"
```

### Autonomous Docker Image Build (Git Trigger)

```bash
git tag -f <tag-name>
```

```bash
git push origin <tag-name>
```

```bash
sudo apt-get update \
    && sudo apt-get install -y ca-certificates curl gnupg \
    && sudo install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && sudo chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && sudo chown root:docker /var/run/docker.sock \
    && sudo usermod -aG docker $USER \
    && sudo init 6
```

## /etc/docker/daemon.json

```json
{
    "mtu": 9000,
    "ipv6": true,
    "fixed-cidr-v6": "FC00::/7",
    "ip6tables": true,
    "experimental": true,
    "default-address-pools": [
      { "base": "172.30.0.0/16", "size": 16 },
      { "base": "172.31.0.0/16", "size": 16 },
      { "base": "172.32.0.0/16", "size": 16 },
      { "base": "172.33.0.0/16", "size": 16 },
      { "base": "172.34.0.0/16", "size": 16 },
      { "base": "172.35.0.0/16", "size": 16 },
      { "base": "172.36.0.0/16", "size": 16 },
      { "base": "172.37.0.0/16", "size": 16 },
      { "base": "172.38.0.0/16", "size": 16 },
      { "base": "172.39.0.0/16", "size": 16 },
      { "base": "172.40.0.0/16", "size": 16 },
      { "base": "172.41.0.0/16", "size": 16 },
      { "base": "172.42.0.0/16", "size": 16 },
      { "base": "172.43.0.0/16", "size": 16 },
      { "base": "172.44.0.0/16", "size": 16 },
      { "base": "172.45.0.0/16", "size": 16 },
      { "base": "2603:c024:0010:6400:d0c::/56", "size": 56 }
    ],
    "default-shm-size": "512M",
    "features": {
      "containerd-snapshotter": true
    },
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "5m",
      "max-file": "30",
      "labels": "production_status",
      "env": "os,customer"
    },
    "live-restore": true,
    "max-concurrent-downloads": 5,
    "max-concurrent-uploads": 5,
    "max-download-attempts": 5,
    "dns": ["8.8.4.4", "8.8.8.8", "2001:4860:4860::8888", "2001:4860:4860::8844"]
  }

```

「`org runner` のリファレンスは [こちら](https://github.com/netvpc/gnuboard6) にあります。」

「`semver` のリファレンスは [こちら](https://github.com/netvpc/nodebb) にあります。」
