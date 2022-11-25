#!/usr/bin/env bash

is_on() {
  app=$1
  port=$2
  if nc -z 127.0.0.1 $port 2>/dev/null && ssh root@localhost -o ConnectTimeout=1 -p $port exit >/dev/null; then
    echo "$app"
  else
    echo ""
  fi
}

result=""
res=$(is_on 'ADMIN (22)' '8022')
if [ "$res" != "" ]; then
  result="$result $res  |"
fi

res=$(is_on 'SHOP (23)' '8023')
if [ "$res" != "" ]; then
  result="$result $res  |"
fi

res=$(is_on 'API (24)' '8024')
if [ "$res" != "" ]; then
  result="$result $res  |"
fi

if [ "$result" == "" ]; then
  echo "no port available"
else
  echo $result | sed -E 's/.$//'
fi
