#!/bin/bash
echo "$(date) Running Morpheus reconfigure" | tee -a /var/log/morpheus_install.log
morpheus-ctl reconfigure
if [ $? -ne 0 ]; then
  echo "$(date) Running Morpheus reconfigure part 2" | tee -a /var/log/morpheus_install.log
  morpheus-ctl reconfigure
fi
echo "$(date) Waiting for 1 minute" | tee -a /var/log/morpheus_install.log
sleep 60
echo "$(date) Waiting for Morpheus UI ping" | tee -a /var/log/morpheus_install.log
morphup=0
while [ $morphup -ne 1 ]; do
  sleep 5
  echo "$(date) Still waiting..." | tee -a /var/log/morpheus_install.log
  if [[ "$(curl -k -s -o /dev/null -w ''%{http_code}'' https://localhost:443/ping)" == "200" ]]; then
    morphup=1
    curl -k -s -w ''%{http_code}'' https://localhost:443/ping 1 | tee -a /var/log/morpheus_install.log
    echo "" | tee -a /var/log/morpheus_install.log
  fi
done
echo "$(date) Waiting 30 seconds for Morpheus initial setup to complete" | tee -a /var/log/morpheus_install.log
sleep 30
morpheus-ctl stop
while [ $? -ne 0 ]; do
  echo "$(date) Shutting down Morpheus" | tee -a /var/log/morpheus_install.log
  morpheus-ctl stop
  sleep 10
done
echo "$(date) Morpheus stopped" | tee -a /var/log/morpheus_install.log
echo "$(date) Disabling supervisor" | tee -a /var/log/morpheus_install.log
systemctl disable morpheus-runsvdir | tee -a /var/log/morpheus_install.log
