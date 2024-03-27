cd /home/ubuntu

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update  
sudo apt-get install logstash > install_logstash.log

#Pull Certificates
sudo apt-get install zip unzip
cd /home/ubuntu/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sleep 500
cd /home/ubuntu

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update  
sudo apt-get install logstash > install_logstash.log

#Pull Certificates
sudo apt-get install zip unzip
cd /home/ubuntu/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sleep 500

aws s3 ls |grep elk >> s3.log
aws s3 cp s3://elk-shared/http_ca.crt /home/ubuntu/ >> config.log


aws s3 rm s3://elk-shared --recursive
aws s3api delete-bucket --bucket elk-shared


sudo mkdir /etc/logstash/certs
sudo chmod 777 /etc/logstash/certs
sudo cp /home/ubuntu/http_ca.crt /etc/logstash/certs/http_ca.crt
sudo chmod 777 /etc/logstash/certs/http_ca.crt

#Create Config File

ip_address=$(grep "Elasticsearch-IP: " /home/ubuntu/user_data_output.txt | cut -d ':' -f 2 | awk '{$1=$1};1')

echo "IP Address: $ip_address:9200" >> config.log

cat <<EOF > logstash_config.conf
input {
  beats {
    port => 5044
  }
}
output {
  elasticsearch {
    hosts => ["https://$ip_address:9200"] 
    cacert => "/etc/logstash/certs/http_ca.crt"
    user => "elastic"
    password => "PASSWORD"
    data_stream => false
    index => "PASSWORD"
    action => "create"
  }
}
EOF

sudo cp /home/ubuntu/logstash_config.conf /etc/logstash/conf.d/logstash_config.conf

echo "Logstash Configured" >> config.log


#Start Logstash Service
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable logstash.service
sudo systemctl start logstash.service

aws s3 ls |grep elk >> s3.log
aws s3 cp s3://elk-shared/http_ca.crt /home/ubuntu/ >> config.log


aws s3 rm s3://elk-shared --recursive
aws s3api delete-bucket --bucket elk-shared


sudo mkdir /etc/logstash/certs
sudo chmod 777 /etc/logstash/certs
sudo cp /home/ubuntu/http_ca.crt /etc/logstash/certs/http_ca.crt
sudo chmod 777 /etc/logstash/certs/http_ca.crt

#Create Config File

ip_address=$(grep "Elasticsearch-IP: " /home/ubuntu/user_data_output.txt | cut -d ':' -f 2 | awk '{$1=$1};1')

echo "IP Address: $ip_address:9200" >> config.log

cat <<EOF > logstash_config.conf
input {
  beats {
    port => 5044
  }
}
output {
  elasticsearch {
    hosts => ["https://$ip_address:9200"] 
    cacert => "/etc/logstash/certs/http_ca.crt"
    user => "elastic"
    password => "PASSWORD"
    data_stream => false
    index => "PASSWORD"
    action => "create"
  }
}
EOF

sudo cp /home/ubuntu/logstash_config.conf /etc/logstash/conf.d/logstash_config.conf

echo "Logstash Configured" >> config.log


#Start Logstash Service
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable logstash.service
sudo systemctl start logstash.service
