### Install Prometheus as Service (Docker Engine Metrics + cAdvisor)

- Docker engine + Container
- Enable prometheus to monitor docker engine + Containers
- Note: Prometheus will be installed as Service, Search for docker engine metrics + CAdvisor
----


#### This will be implemented in two (Automation) ways.

##### 1- Bash Script
##### 2- Ansible Playbook & Inventory



---
#### 1- Install Docker Engine
```
sudo apt update -y
sudo apt install -y docker.io
```

#### 2- Expose Docker daemon metrics
```
sudo tee /etc/docker/daemon.json <<EOF
{
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true
}
EOF
```
#### 3- install Prometheus as Service
**<ins>Create prometheus.yml**

```
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'docker-engine'
    static_configs:
      - targets: ['localhost:9323']  # IP Docker 
        # Linux: ['localhost:9323']  # IP

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['localhost:8080'] # IP
```

#### 4- Start Prometheus (Docker)

```
docker run -d \
  --name=prometheus \
  --network=host \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest
  ```

#### 5- Run cAdvisor to Collect Container Metrics

```
docker run -d \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  -p 8080:8080 \
  -v /:/rootfs:ro \
  -v /var/run:/var/run:rw \
  -v /sys:/sys:ro \
  -v /var/lib/docker:/var/lib/docker:ro \
  gcr.io/cadvisor/cadvisor:latest

  ```
---
#### Output

  ![Script](https://github.com/moustafamselim/Deploy-Prometheus-as-Service/blob/cc2cd79c54d9e9bacd39f8d504c86b401ac19678/IMG/cAdvisor.png)


  ![Script](https://github.com/moustafamselim/Deploy-Prometheus-as-Service/blob/cc2cd79c54d9e9bacd39f8d504c86b401ac19678/IMG/Prometheus.png)
