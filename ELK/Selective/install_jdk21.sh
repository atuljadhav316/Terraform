sudo apt-get update
sudo apt-get install -y openjdk-21-jdk
sudo -u ubuntu bash -c 'echo "JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64/" | tee -a ~/.bashrc'
sudo -u ubuntu bash -c 'echo "export JAVA_HOME=\$JAVA_HOME" | tee -a ~/.bashrc'
sudo -u ubuntu bash -c 'echo "export PATH=\$PATH:\$JAVA_HOME/bin" | tee -a ~/.bashrc'

sudo -u ubuntu bash -c 'echo "source /home/ubuntu/.bashrc"'
