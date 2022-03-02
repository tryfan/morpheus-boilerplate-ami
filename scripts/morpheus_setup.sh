#!/bin/bash
sleep 30
instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id)
fqdn=$(curl http://169.254.169.254/latest/meta-data/tags/instance/morpheus_fqdn)
appliance_url="https://${fqdn}"
echo "appliance_url '${appliance_url}'" > /etc/morpheus/morpheus.rb
echo "$(date) Enabling and starting supervisor" >> /var/log/morpheus_install.log
systemctl enable --now morpheus-runsvdir >> /var/log/morpheus_install.log
morphup=0
while [ $morphup -ne 1 ]; do
  sleep 5
  echo "$(date) Still waiting..." >> /var/log/morpheus_install.log
  if [[ "$(curl -k -s -o /dev/null -w ''%{http_code}'' https://localhost:443/ping)" == "200" ]]; then
    morphup=1
    curl -k -s -w ''%{http_code}'' https://localhost:443/ping 1>>/var/log/morpheus_install.log
    echo "" >> /var/log/morpheus_install.log
  fi
done
echo "$(date) Running Morpheus reconfigure" >> /var/log/morpheus_install.log
morpheus-ctl reconfigure
echo "$(date) Restarting nginx" >> /var/log/morpheus_install.log
morpheus-ctl restart nginx
echo "$(date) Restarting morpheus-ui" >> /var/log/morpheus_install.log
morpheus-ctl restart morpheus-ui

echo "$(date) Waiting for 1 minute" >> /var/log/morpheus_install.log
sleep 60
echo "$(date) Waiting for Morpheus UI ping" >> /var/log/morpheus_install.log
morphup=0
while [ $morphup -ne 1 ]; do
  sleep 5
  echo "$(date) Still waiting..." >> /var/log/morpheus_install.log
  if [[ "$(curl -k -s -o /dev/null -w ''%{http_code}'' https://localhost:443/ping)" == "200" ]]; then
    morphup=1
    curl -k -s -w ''%{http_code}'' https://localhost:443/ping 1>>/var/log/morpheus_install.log
    echo "" >> /var/log/morpheus_install.log
  fi
done
echo "$(date) Waiting 30 seconds for Morpheus initial setup to complete" >> /var/log/morpheus_install.log
sleep 30
echo "$(date) Running intial setup API call" >> /var/log/morpheus_install.log
curl -k -XPOST "${appliance_url}/api/setup/init" \
  -H "Content-Type: application/json" \
  -d "{
  'applianceName': 'Morpheus',
  'applianceUrl': '${appliance_url}',
  'accountName': 'root',
  'username': 'admin',
  'password': '${instance_id}@AWS',
  'email': 'admin@example.com',
  'firstName': 'Admin'
  }
}" >> /var/log/morpheus_install.log
echo "" >> /var/log/morpheus_install.log
echo "$(date) Complete" >> /var/log/morpheus_install.log