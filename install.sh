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
mkdir avisnode data
cp ./build/bin/eva ./avisnode
cp ./verifykey.txt ./avisnode
cp ./avis.json ./avisnode
cp ./avis.toml ./avisnode
ln -s ./build/bin/eva .
wget https://public.sn.files.1drv.com/y4mtOXJlVM0cPCoLJOMvMEGFGz4k_8QKxqe4F9EnETH7KWQacQyPgR3zoscpVi64A18e_h4Wou4_OjRB92zYMN3qONvwNYXkhSJTkyZSDhx_4OKm0ghm3ieay5F5Kbh9aKY6xNG
77rRo96ERXKkaEaQttrouwbAmtzuCNq4dTi_vyKPfLm7wvHkt8J9kmH7Jt5m4HIEM48U-CcCOeDO_ggu9w3ciDnwurJkC2C7YQ4EF8g?access_token=EwAIA61DBAAU2kADSankulnKv2PwDjfenppNXFIAASDhlICqyB7qiXji8qJKFhvHXdDkuhAQ%2bW%
2bIkp2Ap%2bxMLsuStPD4Wz3cQRN269DBbH3uSbNsixrA/dESBRTvPcKPSia7Ofl2HszM66/FWUh8j09rRswR4EzW5gPS3gm/muzGQLAXK167hYyqK0b6fL%2bq%2b5bWvvTuYuAQ7niUEXf%2b3ZN6oJYZnYYKb%2b/nf9Afw4RgaxfwH/2R1jOilnbbIvBoo
ICPjLRZAJXtWZsu5xSnN/TggqzT3vhZ0KTv4e2XBi2hZTY8RPO3ta0QOgLiowHefBmuVL2fX9pV%2bejwzWLffjUDLMOO7JVgDvLwqXZ4XrO5m1bPJFKOP92IIDTWF6EDZgAACBjzlFsUBp%2bA2AFcmR6VAuCzJFeHeA7td2PX29c2FoQNJV8vx6vAW3zz4q8
2/C%2bbM0eDgBPMnUpAVI3C9IIbyo93PAxVUY5BFPKccZoxG/27N9rh/d6g7q4ADk3iYnRAa/8NTVjrDa3sQbHZn3RRpeEmLfzl9XRDpRaKlmj0SHOCbSXKEtl4K3nAZJ7cMwFK/GkL/EKk0X45tnG3WkjYN22dIQVuraoGzWoTCn7b/WENIIQ9JYh3nQtk67l
YAPb4bBuC1R2K5p/zMDRi0BEaYSAex124G59wWX77g5riP/x6VTs9AiyBhwtJ0XPiGbZXPeA%2bYrsbn8o97xTKyg2arRDZGqrzHK42P8a4ETlYVsaQu0sSR/qkkiTRUVvTXYADft4A2/hzFxLh%2bFdmdPUHsn9tXFAEqmp3J7XUXpsxvhVFgIWP%2bfOJEXF
ux70/hC4a1r%2b1OEu%2bSOaiZzeGTfntPVDLOtJbl6Q2dFHk8gWHiCBfbOWZcLl0IvFgi27hKHTyg4CyCgo3jSoQO2fqEBA/G15GwGAPiID6LLR%2bBaZzWrJH4CbXBeHc/VwxzbjzAJrsLU/YksuoWsZX1fAxXxCN9J6SMBqsML44IvClZeAk8GzdLGkjYp5
izB27JFaceDLM0Kun%2bQE%3d -O QmNpJg4jDFE4LMNvZUzysZ2Ghvo4UJFcsjguYcx4dTfwKx

echo -e "Importing keyfile and creating genesis block\n\n"
echo -e "Type the full path of your keyfile (ej. /tmp/keyfile.json): "
read varkeyfile
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


##Falta instalar el agente de rackspace


echo -e "Final step, start services\n\n"
sudo systemctl daemon-reload
sudo systemctl enable evanesco

echo -e "Just remember to start the service with the following command:\n\n     sudo systemctl start evanesco\n\n"
echo -e "THE END"


##Falta cleanup
