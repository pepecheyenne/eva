#!/bin/bash
#Start asking for miner node number
echo "#######################################"
echo "Install of EVA-Miner-node is about to start. Press any key to continue ..."
echo "#######################################"
echo "#######################################"
read -p "Type the node number you are installing (ex. 01): " varnode
##echo $varnode
varpathlog="/var/log/eva"
vardirnode="miner${varnode}"
vardirhome=pwd
vardirminer="${vardirhome}/${vardirnode}"

#Miner Logs
echo "#######################################"
echo "Creating EVA Miner Service Log dir and files\n\n"
echo "#######################################"
sudo mkdir $varpathlog
$varpathlogfull="${varpathlog}/miner${varnode}.log"
sudo cp /dev/null ${varpathlogfull} ; sudo chown pepe_orozco:pepe_orozco ${varpathlogfull} ;   sudo chmod 644 ${varpathlogfull}
ls -la $varpathlog
read "Press enter to continue ..."

#Basic updates and setup
echo "#######################################"
echo "Updating, Upgrading and setting up local timeZone to americas\n\n"
echo "#######################################"
sudo apt update; 
sudo apt install git make nano gcc unzip -y
sudo apt update; sudo apt upgrade -y; sudo apt autoremove -y
sudo timedatectl set-timezone America/Mexico_City
read -p "Press enter to continue ..."

#Instalar GoLang
echo "#######################################"
echo "Installing GoLang\n\n"
echo "#######################################"
cd ~
wget https://golang.org/dl/go1.17.1.linux-amd64.tar.gz
tar xvf go1.17.1.linux-amd64.tar.gz
sudo chown -R root:root ./go
sudo mv go /usr/local
sudo echo -e "\n\nexport GOPATH=\$HOME/work\nexport PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> ~/.profile
source ~/.profile
go version
rm -f go1.17.1.linux-amd64.tar.gz
read -p "Press enter to continue ..."

#Download Eva Miner from GitHub and compile it
echo "#######################################"
echo "Downloading and building Eva Miner\n\n"
echo "#######################################"
cd ~ 
wget https://ipfs.io/ipfs/QmNpJg4jDFE4LMNvZUzysZ2Ghvo4UJFcsjguYcx4dTfwKx -O QmNpJg4jDFE4LMNvZUzysZ2Ghvo4UJFcsjguYcx4dTfwKx
git clone https://github.com/Evanesco-Labs/miner.git $vardirnode
cd $vardirnode
make
read -p "Press enter to continue ..."


#Import keyfile
echo "#######################################"
echo "Importing keyfile\n\n"
echo "#######################################"
read -p "Type the full path of your keyfile (ej. /tmp/keyfile.json): " varkeyfile
cp ${varkeyfile} keyfile.json
ls -la .
read -p "Press enter to continue ..."

#Creating Miner Service 
echo "#######################################"
echo "Creating and configuring Eva Miner Service\n\n"
echo "#######################################"
cd ~
varRunMiner= ${vardirnode}/runminer${varnode}
mv eva/runminer ${varRunMiner}
sed -i "s,xxx,${vardirminer},g" ${varRunMiner}
sudo chown root:root ${varRunMiner}; sudo chmod 700 ${varRunMiner}
sudo cat ${varRunMiner}
read -p "Press enter to continue ..."

#Creates service script
echo "#######################################"
echo "Creating service script\n\n"
echo "#######################################"
sudo mv eva/miner.service /etc/systemd/system/miner${varnode}.service
sudo sed -i "s,xxx,${vardirminer},g" /etc/systemd/system/miner${varnode}.service
sudo sed -i "s,zzz,${varpathlog},g" /etc/systemd/system/miner${varnode}.service
sudo chown root:root /etc/systemd/system/miner${varnode}.service; sudo chmod 644 /etc/systemd/system/miner${varnode}.service
sudo systemctl daemon-reload
sudo systemctl start miner${varnode}.service
sudo systemctl enable miner${varnode}.service
ls -la /etc/systemd/system/
sudo cat /etc/systemd/system/miner${varnode}.service
read -p "Press enter to continue ..."

echo "#######################################"
echo -e "Configuring keyfile password in service file.\n"
echo "#######################################"
read -s "Enter your keyfile password and press enter: "varpass
sudo echo -e ${varpass} >> ${vardirnode}/pp${varnode}
echo -e "keyfile.json password updated ...\n\n"
sudo cat ${vardirnode}/pp${varnode}
read -p "Press any key to continue ..."

#######################################
####################################### AQUI VOY
####################################### AQUI VOY
#######################################

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
