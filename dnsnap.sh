#!/bin/bash

# test_server tests a DNS server by hostname or IP
function test_server() {
  latency=$(ping -c 1 "$1" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)

  if [[ -z "$latency" ]]; then
    echo "$1 UNREACHABLE"
  else
    identities=$(dig +nsid CH id.server TXT @"$1" | grep -o -P '(?<=").*(?=")')
    nsid=$(echo "$identities" | head -1)
    id_server=$(echo "$identities" | tail -1)
    if [[ "$nsid" != "$id_server" ]]; then
      echo "$1 ${latency}ms $id_server $nsid"
    else
      echo "$1 ${latency}ms $id_server"
    fi
  fi
}

if [[ $# -eq 0 ]]; then
  servers="$(echo -e {a..m}.root-servers.net) prisoner.iana.org anyns.pch.net 9.9.9.9 1.1.1.1 8.8.8.8"
else
  servers=$*
fi

echo "Testing $servers at $(date)"

{
  echo -e "\e[4mServer\e[0m \e[4mLatency\e[0m \e[4mid.server\e[0m \e[4mNSID\e[0m"
  for i in $servers; do
    test_server "$i" &
  done | sort
} | column -t
wait
