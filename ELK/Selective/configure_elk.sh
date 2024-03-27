cd /home/ubuntu

echo "Starting Configuration" >>config.sh
sleep 300

#Configure Elasticsearch

sudo sed -i '/cluster.name*/s/.*/cluster.name: "elastic-master"/g' /etc/elasticsearch/elasticsearch.yml ;

sudo sed -i '/network.host*/s/.*/network.host: "0.0.0.0"/g' /etc/elasticsearch/elasticsearch.yml ;

sudo sed -i '/http.port*/s/.*/http.port: 9200/g' /etc/elasticsearch/elasticsearch.yml ;

echo "ElasticSearch Configured" >> config.log

#Configure Kibana

ip_address=$(hostname -I | tr -d '[:space:]')

sudo sed -i '/server.port*/s/.*/server.port: 5601/g' /etc/kibana/kibana.yml ;
sudo sed -i '/server.host*/s/.*/server.host: "0.0.0.0"/g' /etc/kibana/kibana.yml ;

echo "IP Address: $ip_address:9200" >> config.log

sudo sed -i "/elasticsearch.hosts*/s/.*/elasticsearch.hosts: [\"https:\/\/$ip_address:9200\"]/g" /etc/kibana/kibana.yml ; 


sudo sed -i '/elasticsearch.username*/s/.*/elasticsearch.username: "kibana_system"/g' /etc/kibana/kibana.yml ;

password="PASSWORD"
echo "Result: $password" >> config.log

{ echo 'y' ; echo 'PASSWORD' ; echo 'PASSWORD'; } | sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u kibana_system ;

{ echo 'y' ; echo 'PASSWORD' ; echo 'PASSWORD'; } | sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u elastic ;

echo "Password Reset Done"

sudo sed -i "/elasticsearch.password*/s/.*/elasticsearch.password: \"$password\" /g" /etc/kibana/kibana.yml ;

sudo cp -r /etc/elasticsearch/certs /etc/kibana/
sudo chmod 777 /etc/kibana/certs
sudo chmod 777 /etc/kibana/certs/http_ca.crt

sudo sed -i '/elasticsearch.ssl.certificateAuthorities*/s/.*/elasticsearch.ssl.certificateAuthorities: ["\/etc\/kibana\/certs\/http_ca.crt"]/g' /etc/kibana/kibana.yml ;

echo "Kibana Configured" >> config.log

#Configure Logstash
sudo cp -r /etc/elasticsearch/certs /etc/logstash/
sudo chmod 777 /etc/logstash/certs
sudo chmod 777 /etc/logstash/certs/http_ca.crt

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
    index => "index_name"
    action => "create"
  }
}
EOF

sudo cp /home/ubuntu/logstash_config.conf /etc/logstash/conf.d/logstash_config.conf

echo "Logstash Configured" >> config.log


#Restart Services 
sudo /bin/systemctl daemon-reload

echo "Restarting Elasticsearch" >> config.log
sudo systemctl restart elasticsearch.service

echo "Restarting Kibana" >> config.log
sudo systemctl restart kibana.service

echo "Restarting Logstash" >> config.log
sudo systemctl restart logstash.service
