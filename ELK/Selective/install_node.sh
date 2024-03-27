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

#Pull Certificates
sudo apt-get install zip unzip
cd /home/ubuntu/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sleep 300

aws s3 cp s3://elk-shared/enrollment_token.txt /home/ubuntu/

# aws s3 rm s3://elk-shared --recursive
# aws s3api delete-bucket --bucket elk-shared

echo "y" | sudo /usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token $(cat /home/ubuntu/enrollment_token.txt) && {
	#Start Elasticsearch
	sudo /bin/systemctl daemon-reload
	sudo /bin/systemctl enable elasticsearch.service
	sudo systemctl start elasticsearch.service
	echo "Node Started" >> config.log
} || {
    	
    	echo "The node enrollment failed" >> config.log
}
