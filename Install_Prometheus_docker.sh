#!/bin/bash
sudo apt update -y
sudo apt install -y docker.io

#Expose Docker daemon metrics on port
# Create/Edit Docker configuration
sudo tee /etc/docker/daemon.json <<EOF
{
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true
}
EOF

# Restart Docker service
sudo systemctl restart docker

###############################################
#Deploy prometheus as Service
################################################
# Create prometheus.yml with correct targets
mkdir -p prometheus && cd prometheus
cat <<EOF > prometheus.yml
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
EOF

# Start Prometheus with proper network access
docker run -d \
  --name=prometheus \
  --network=host \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest
########################################################################
#Run cAdvisor to Collect Container Metrics
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


