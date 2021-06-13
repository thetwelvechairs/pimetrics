# Prevent issues with iptables on Raspbian
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC 648ACFD622F3D138
sudo apt-get update -y
sudo apt-get install iptables/buster-backports -y

sudo ARCH=arm64 GCLOUD_STACK_ID="" GCLOUD_API_KEY="" /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/grafana/agent/release/production/grafanacloud-install.sh)"

wget "https://github.com/prometheus/prometheus/releases/download/v2.27.1/prometheus-2.27.1.linux-armv7.tar.gz";
wget "https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-armv7.tar.gz";

tar vxfz prometheus-2.27.1.linux-armv7.tar.gz
tar vxfz node_exporter-1.1.2.linux-armv7.tar.gz 

sudo mv prometheus-2.27.1.linux-armv7/ prometheus/
sudo mv node_exporter-1.1.2.linux-armv7/ node_exporter/

sudo chown -R pi:pi /home/pi/prometheus
sudo chown -R pi:pi /home/pi/node_exporter

sudo rm prometheus-2.27.1.linux-armv7.tar.gz 
sudo rm node_exporter-1.1.2.linux-armv7.tar.gz 

echo "[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
User=pi
Restart=on-failure

ExecStart=/home/pi/prometheus/prometheus \
  --config.file=/home/pi/prometheus/prometheus.yml \
  --storage.tsdb.path=/home/pi/prometheus/data

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/prometheus.service

echo "[Unit]
Description=Node Exporter

[Service]
User=pi
ExecStart=/home/pi/node_exporter/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node_exporter.service

sudo systemctl daemon-reload

sudo systemctl start prometheus.service
sudo systemctl start node_exporter.service

sudo systemctl enable prometheus.service
sudo systemctl enable node_exporter.service

echo "

  - job_name: node
    static_configs:
    - targets: ['localhost:9100']
    " >> /home/pi/prometheus/prometheus.yml

sudo systemctl restart prometheus.service
