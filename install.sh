read -p "Install of EVA is about to start. Press any key to continue ..."

echo -e "Updating, Upgrading and setting up local timeZone to americas\n\n"
sudo apt update; 
sudo apt install git make nano gcc unzip -y
sudo apt update; apt-get upgrade -y
sudo timedatectl set-timezone America/Mexico_City

read -p "Press any key to continue ..."

echo -e "Creating EVA Service Log dir and files\n\n"
sudo mkdir /var/log/eva
sudo cp /dev/null /var/log/eva/error.log; sudo chown pepe_orozco:pepe_orozco /var/log/eva/error.log; sudo chmod 644 /var/log/eva/eva.log
sudo cp /dev/null /var/log/eva/eva.log;    sudo chown pepe_orozco:pepe_orozco /var/log/eva/eva.log;    sudo chmod 644 /var/log/eva/eva.log

read -p "Press any key to continue ..."

echo -e "Installing GoLang\n\n"
cd ~
wget https://golang.org/dl/go1.17.linux-amd64.tar.gz
tar xvf go1.17.linux-amd64.tar.gz 
sudo chown -R root:root ./go
sudo mv go /usr/local
sudo echo -e "\n\nexport GOPATH=\$HOME/work\nexport PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> ~/.profile
source ~/.profile
go version

read -p "Press any key to continue ..."

echo -e "Downloading and building Eva\n\n"
cd ~ ; git clone https://github.com/Evanesco-Labs/go-evanesco.git ; cd go-evanesco
make all
echo -e "Creating Avisnode instance"
mkdir -p ./avisnode/data 
cp ./build/bin/eva ./avisnode
cp ./verifykey.txt ./avisnode
cp ./avis.json ./avisnode
cp ./avis.toml ./avisnode
ln -s ./build/bin/eva ./avisnode/eva
ln -s ./build/bin/eva .
wget https://ipfs.io/ipfs/QmNpJg4jDFE4LMNvZUzysZ2Ghvo4UJFcsjguYcx4dTfwKx -O QmNpJg4jDFE4LMNvZUzysZ2Ghvo4UJFcsjguYcx4dTfwKx

echo -e "Importing keyfile and creating genesis block\n\n"
echo -e "Type the full path of your keyfile (ej. /tmp/keyfile.json): "
read varkeyfile
cd ./avisnode
./eva --datadir data account import $varkeyfile
./eva --datadir data init ./avis.json

read -p "Press any key to continue ..."

echo -e "Creating and configuring Eva Service\n\n"
cd ~
mv eva/runeva go-evanesco/
sudo chown root:root go-evanesco/runeva
sudo chmod 700 go-evanesco/runeva
sudo mv eva/evanesco.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/evanesco.service
sudo chmod 644 /etc/systemd/system/evanesco.service

echo -e "Configuring keyfile password in service file. Please enter your keyfile.json password:"
read -s varpass
sudo sed -i "s/REPLACE/$varpass/g" go-evanesco/runeva
echo -e "keyfile.json password updated ...\n\n"

read -p "Press any key to continue ..."

echo -e "Configuring log rotation\n\n"
sudo eva/evanesco.logrotate /etc/logrotate.d/evanesco
sudo chown root:root /etc/logrotate.d/evanesco
sudo chmod 644 /etc/logrotate.d/evanesco

read -p "Press any key to continue ...\n\n"


echo -e "Installing monitoring agent\n\n"
echo -e "Introduce your RS Monitoring API Key:"
read varapikey
cd ~
sudo sh -c "echo 'deb http://stable.packages.cloudmonitoring.rackspace.com/ubuntu-$(lsb_release -rs)-x86_64 cloudmonitoring main' > /etc/apt/sources.list.d/rackspace-monitoring-agent.list"
wget -qO- https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc | sudo apt-key add -
sudo apt-get update && sudo apt-get install rackspace-monitoring-agent
sudo mv eva/monitoring.* /etc/rackspace-monitoring-agent.conf.d/
sudo mv checkeva /usr/lib/rackspace-monitoring-agent/plugins/
sudo chmod 771 /usr/lib/rackspace-monitoring-agent/plugins/checkeva
sudo rackspace-monitoring-agent --setup --username pepeorozco99 --apikey $varapikey
sudo rackspace-monitoring-agent start -D

read -p "Press any key to continue ...\n\n"

echo -e "Final step, start services\n\n"
sudo systemctl daemon-reload
sudo systemctl enable evanesco

echo -e "Just remember to start the service with the following command:\n\n     sudo systemctl start evanesco\n\n"
echo -e "THE END"


##Falta cleanup
