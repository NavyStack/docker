```yaml
#cloud-config
config:
  cloud-init.user-data: |
    #cloud-config
    package_upgrade: true
    packages:
      - gh
    timezone: Asia/Seoul

write_files:
  - path: /etc/docker/daemon.json
    content: |
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
        "dns": [
          "8.8.4.4",
          "8.8.8.8",
          "2001:4860:4860::8888",
          "2001:4860:4860::8844"
        ]
      }

runcmd:
  - apt-get update
  - apt-get install -y ca-certificates curl gnupg
  - install -m 0755 -d /etc/apt/keyrings
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  - chmod a+r /etc/apt/keyrings/docker.gpg
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  - chown root:docker /var/run/docker.sock
  - usermod -aG docker 1000
  - reboot
```
