#!/bin/sh
apt-get update
# installs wireguard, npm
apt-get install wireguard -y
apt-get install npm -y
# installs nvm (Node Version Manager)
/bin/bash -c "$(curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh)"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# download and install Node.js (you may need to restart the terminal)
nvm install 18
# verifies the right Node.js version is in the environment
node -v # should print `v18.20.5`
# verifies the right npm version is in the environment
npm -v # should print `10.8.2`
# allows ip forwarding in linux to access local network
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
echo net.ipv4.conf.all.src_valid_mark=1 >> /etc/sysctl.conf
sysctl -p
# clone this repository into a folder
git clone https://github.com/jonylentzmc/wg-easy-archive
cd wg-easy-archive
# move folders and compile
mv src /app
cd /app
# npm ci --production
npm ci --omit=dev
cp -r node_modules ..
npm audit fix
# set firewall rules
ufw allow 51821/tcp # (webui) Only for users of the UFW firewall
ufw allow 51820/udp # (wireguard listening port) Only for users of the UFW firewall
cd -
# creates wg-easy archive 
curl -Lo /etc/systemd/system/wg-easy.service https://raw.githubusercontent.com/jonylentzmc/wg-easy-archive/production/wg-easy.service
nano /etc/systemd/system/wg-easy.service
#[removed to simplify the config] nano /etc/systemd/system/wg-easy.service # Replace everything that is marked as 'REPLACEME' and tweak it to your liking
# start the service 
systemctl daemon-reload
systemctl enable --now wg-easy.service
systemctl start wg-easy.service
