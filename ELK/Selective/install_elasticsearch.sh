# -- elastic search
# -- https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html
# -- es has default bundled java

#Install ElasticSearch
cd /home/ubuntu
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.12.1-amd64.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.12.1-amd64.deb.sha512
shasum -a 512 -c elasticsearch-8.12.1-amd64.deb.sha512 
sudo dpkg -i elasticsearch-8.12.1-amd64.deb > install_elastic.log


#Configure Elasticsearch
sudo sed -i '/cluster.name*/s/.*/cluster.name: "elastic-master"/g' /etc/elasticsearch/elasticsearch.yml ;

sudo sed -i '/network.host*/s/.*/network.host: "0.0.0.0"/g' /etc/elasticsearch/elasticsearch.yml ;

sudo sed -i '/http.port*/s/.*/http.port: 9200/g' /etc/elasticsearch/elasticsearch.yml ;

echo "ElasticSearch Configured" >> config.log

echo "-Xms2g" >> /etc/elasticsearch/jvm.options.d/jvm.options
echo "-Xmx2g" >> /etc/elasticsearch/jvm.options.d/jvm.options
chmod 755 /etc/elasticsearch/jvm.options.d/jvm.options


#Start Elasticsearch
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service


#Certificate Push
sudo apt-get install zip unzip
cd /home/ubuntu/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws s3api create-bucket --bucket elk-shared --create-bucket-configuration LocationConstraint=ap-south-1
sudo cp /etc/elasticsearch/certs/http_ca.crt /home/ubuntu/
chmod 755 /home/ubuntu/http_ca.crt
sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node > enrollment_token.txt
chmod 755 /home/ubuntu/enrollment_token.txt

aws s3 cp /home/ubuntu/http_ca.crt s3://elk-shared/
aws s3 cp /home/ubuntu/enrollment_token.txt s3://elk-shared/


#Kibana Password Reset
password="PASSWORD"
echo "Result: $password" >> config.log

{ echo 'y' ; echo 'PASSWORD' ; echo 'PASSWORD'; } | sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u kibana_system ;

{ echo 'y' ; echo 'PASSWORD' ; echo 'PASSWORD'; } | sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u elastic ;


echo "Password Reset Done" >> config.log
