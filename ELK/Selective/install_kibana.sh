cd /home/ubuntu

#Install Kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.12.1-amd64.deb
shasum -a 512 kibana-8.12.1-amd64.deb 
sudo dpkg -i kibana-8.12.1-amd64.deb > install_kibana.log

sleep 300

#Configure Kibana

ip_address=$(grep "Elasticsearch-IP: " /home/ubuntu/user_data_output.txt | cut -d ':' -f 2 | awk '{$1=$1};1')

sudo sed -i '/server.port*/s/.*/server.port: 5601/g' /etc/kibana/kibana.yml ;
sudo sed -i '/server.host*/s/.*/server.host: "0.0.0.0"/g' /etc/kibana/kibana.yml ;

echo "IP Address: $ip_address:9200" >> config.log

sudo sed -i "/elasticsearch.hosts*/s/.*/elasticsearch.hosts: [\"https:\/\/$ip_address:9200\"]/g" /etc/kibana/kibana.yml ; 
sudo sed -i '/elasticsearch.username*/s/.*/elasticsearch.username: "kibana_system"/g' /etc/kibana/kibana.yml ;

password="PASSWORD"
echo "Result: $password" >> config.log
sudo sed -i "/elasticsearch.password*/s/.*/elasticsearch.password: \"$password\" /g" /etc/kibana/kibana.yml ;


#Pull Certificates
sudo apt-get install zip unzip
cd /home/ubuntu/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws s3 cp s3://elk-shared/http_ca.crt /home/ubuntu/


sudo mkdir /etc/kibana/certs
sudo chmod 777 /etc/kibana/certs
sudo cp /home/ubuntu/http_ca.crt /etc/kibana/certs/http_ca.crt
sudo chmod 777 /etc/kibana/certs/http_ca.crt

sudo sed -i '/elasticsearch.ssl.certificateAuthorities*/s/.*/elasticsearch.ssl.certificateAuthorities: ["\/etc\/kibana\/certs\/http_ca.crt"]/g' /etc/kibana/kibana.yml ;

echo "Kibana Configured" >> config.log


#Start Kibana
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service
sudo systemctl start kibana.service
