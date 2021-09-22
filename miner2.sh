#!/bin/bash
#Start asking for miner node number
echo "#######################################"
echo "Install of EVA-Miner-node is about to start. Press any key to continue ..."
echo "#######################################"
echo "#######################################"
read -p "Type the node number you are installing (ex. 02): " varnode
##Home folder
vardirhome=$HOME
##Logs Folder & Log file full path
vardirlog="/var/log/eva"
vardirlogfull="${vardirlog}/miner${varnode}.log"
##Miner Node Number & Miner Folder
vardirnode="miner${varnode}"
vardirminerfull="${vardirhome}/${vardirnode}"

#Miner Logs
echo "#######################################"
echo "Creating EVA Miner Service Log dir and files\n\n"
echo "#######################################"
sudo mkdir -p $vardirlog
sudo cp /dev/null ${vardirlogfull} ; sudo chown pepe_orozco:pepe_orozco ${vardirlogfull} ;   sudo chmod 644 ${vardirlogfull}
ls -la $vardirlog
read -p "Press enter to continue ..."

#Basic updates and setup
echo "#######################################"
echo "Updating, Upgrading and setting up local timeZone to americas\n\n"
echo "#######################################"
sudo apt update; 
sudo apt install git make nano gcc unzip -y
sudo apt update; sudo apt upgrade -y; sudo apt autoremove -y
sudo timedatectl set-timezone America/Mexico_City
read -p "Press enter to continue ..."

#Download Eva Miner from GitHub and compile it
echo "#######################################"
echo "Downloading and building Eva Miner\n\n"
echo "#######################################"
cd ~ 
wget -nc https://ipfs.io/ipfs/QmNpJg4jDFE4LMNvZUzysZ2Ghvo4UJFcsjguYcx4dTfwKx
git clone https://github.com/Evanesco-Labs/miner.git $vardirminerfull
cd $vardirminerfull
make
read -p "Press enter to continue ..."

#Import keyfile
echo "#######################################"
echo "Importing keyfile\n\n"
echo "#######################################"
read -p "Type the full path of your keyfile (ej. /tmp/keyfile.json): " varkeyfile
cp $varkeyfile keyfile.json
ls -la .
read -p "Press enter to continue ..."

#Creating Miner Service 
echo "#######################################"
echo "Creating and configuring Eva Miner Service\n\n"
echo "#######################################"
cd
varOrigin="${vardirhome}/eva/runminer"
cp $varOrigin "${vardirminerfull}/runminer${varnode}"
varRunMiner="${vardirminerfull}/runminer${varnode}"
sed -i "s,xxx,${vardirminerfull},g" ${varRunMiner}
sed -i "s,yyy,${HOME},g" ${varRunMiner}
sed -i "s,nnn,${varnode},g" $varRunMiner
sudo chown root:root $varRunMiner; sudo chmod 700 $varRunMiner
sudo cat $varRunMiner
ls -la $vardirminerfull
read -p "Press enter to continue ..."

#Creates service script
echo "#######################################"
echo "Creating service script\n\n"
echo "#######################################"
varMinerService="/etc/systemd/system/miner${varnode}.service"
sudo cp eva/miner.service $varMinerService
sudo sed -i "s,xxx,${vardirminerfull},g" $varMinerService
sudo sed -i "s,nnn,${varnode},g" $varMinerService
sudo sed -i "s,zzz,${vardirlogfull},g" $varMinerService
sudo chown root:root $varMinerService ; sudo chmod 644 $varMinerService
sudo systemctl daemon-reload
sudo systemctl start "miner${varnode}.service"
sudo systemctl enable "miner${varnode}.service"
ls -la /etc/systemd/system/
sudo cat $varMinerService
read -p "Press enter to continue ..."

echo "#######################################"
echo -e "Configuring keyfile password in service file.\n"
echo "#######################################"
echo -e "Enter your keyfile password and press enter: " 
read -s varpass
cp /dev/null "${vardirminerfull}/pp${varnode}"
varPassFile="${vardirminerfull}/pp${varnode}"
echo $varpass >> $varPassFile
sudo chmod 400 $varPassFile ; sudo chown root:root $varPassFile
echo -e "keyfile.json password updated ...\n\n"
ls -la $vardirminerfull
read -p "Press enter to continue ..."

echo "#######################################"
echo -e "Configuring log rotation\n\n"
echo "#######################################"
varLogRotation="/etc/logrotate.d/miner${varnode}"
sudo cp eva/miner.logrotate $varLogRotation
sudo sed -i "s,nnn,${varnode},g" $varLogRotation
sudo chown root:root $varLogRotation
sudo chmod 644 $varLogRotation
sudo cat $varLogRotation
read -p "Press enter to continue ...\n\n"

echo "#######################################"
echo -e "Starting Services"
echo "#######################################"
sudo systemctl start ${vardirnode}
sudo systemctl status ${vardirnode}
read -p "Press enter to continue ...\n\n"

#######################################
####################################### AQUI VOY
####################################### AQUI VOY
#######################################
echo "#######################################"
echo -e "Installing monitoring agent\n\n"
echo "#######################################"
read -p "Introduce your RS Monitoring API Key:" varapikey
cd
sudo sh -c "echo 'deb http://stable.packages.cloudmonitoring.rackspace.com/ubuntu-$(lsb_release -rs)-x86_64 cloudmonitoring main' > /etc/apt/sources.list.d/rackspace-monitoring-agent.list"
wget -qO- https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc | sudo apt-key add -
sudo apt-get update && sudo apt-get install rackspace-monitoring-agent
sudo mv eva/monitoring.* /etc/rackspace-monitoring-agent.conf.d/
sudo mv checkeva /usr/lib/rackspace-monitoring-agent/plugins/
sudo chmod 771 /usr/lib/rackspace-monitoring-agent/plugins/checkeva
sudo rackspace-monitoring-agent --setup --username pepeorozco99 --apikey $varapikey
sudo rackspace-monitoring-agent start -D
read -p "Press any key to continue ...\n\n"



echo -e "Just remember to control the service with the following command:\n\n     sudo systemctl start sudo systemctl [start,stop,status] ${vardirnode}\n\n"
echo -e "THE END"


##Falta cleanup
