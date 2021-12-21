# DNS Utilities

## dnsnap.sh "DNS snapshot"

Test the default DNS server list (see $default_servers):

`curl -sL https://git.io/dnsnap | sh`

Test a server (or multiple servers):

`curl -sL https://git.io/dnsnap | sh -s 1.1.1.1 ns1.google.com`
