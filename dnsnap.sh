#!/bin/sh
# dnsnap.sh "DNS snapshot"
# https://github.com/natesales/dns-utils
#
# Test the default DNS server list (see $default_servers):
# curl -sL https://git.io/dnsnap | sh
#
# Test a server (or multiple servers):
# curl -sL https://git.io/dnsnap | sh -s 1.1.1.1 ns1.google.com

root_servers="a.root-servers.net b.root-servers.net c.root-servers.net d.root-servers.net e.root-servers.net f.root-servers.net g.root-servers.net h.root-servers.net i.root-servers.net j.root-servers.net k.root-servers.net l.root-servers.net m.root-servers.net"
default_servers="prisoner.iana.org anyns.pch.net 9.9.9.9 1.1.1.1 8.8.8.8 $root_servers"

# test_server tests a DNS server by hostname or IP
test_server() {
  dig_results=$(dig +time=5 +tries=1 +nsid CH id.server TXT @"$1")
  if echo "$dig_results" | grep -q "no servers could be reached"; then
    echo "$1 unreachable"
    return
  fi

  identities=$(echo "$dig_results" | grep -o -P '(?<=").*(?=")')
  latency=$(echo "$dig_results" | grep -o -P '(?<=time: ).*(?= msec)')
  nsid=$(echo "$identities" | head -1)
  id_server=$(echo "$identities" | tail -1)
  if [ "$nsid" != "$id_server" ]; then
    echo "$1 ${latency}ms $id_server $nsid"
  else
    echo "$1 ${latency}ms $id_server"
  fi
}

if [ $# -eq 0 ]; then
  servers=$default_servers
else
  servers=$*
fi

echo "Starting dnsnap at $(date)"

{
  printf "\e[4mServer\e[0m \e[4mLatency\e[0m \e[4mid.server\e[0m \e[4mNSID\e[0m\n"
  for i in $servers; do
    test_server "$i" &
  done | sort
} | column -t
wait
