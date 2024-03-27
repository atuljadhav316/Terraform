#Download Elasticsearch deb file
cd /home/ubuntu
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.12.1-amd64.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.12.1-amd64.deb.sha512
shasum -a 512 -c elasticsearch-8.12.1-amd64.deb.sha512 
sudo dpkg -i elasticsearch-8.12.1-amd64.deb > install_elastic.log

#Start the service and enable as systemd service
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service

#Download Kibana deb file
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.12.1-amd64.deb
shasum -a 512 kibana-8.12.1-amd64.deb 
sudo dpkg -i kibana-8.12.1-amd64.deb > install_kibana.log

#Start the Kibana  service and enable as systemd service
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service
sudo systemctl start kibana.service

#Download Logstash deb file
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update  
sudo apt-get install logstash > install_logstash.sh

#Start the Logstash
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable logstash.service
sudo systemctl start logstash.service
