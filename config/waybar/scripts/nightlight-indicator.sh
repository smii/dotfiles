#!/bin/bash
if systemctl --user is-active --quiet gammastep.service; then
  echo '{"text":"󰖔","tooltip":"Night light active","class":"active"}'
else
  echo '{"text":""}'
fi
