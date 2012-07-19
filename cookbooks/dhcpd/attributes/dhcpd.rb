default[:dhcpd][:version] = false
default[:dhcpd][:service] = "isc-dhcp-server"
default[:dhcpd][:package] = "isc-dhcp-server"
default[:dhcpd][:default_file] = "/etc/default/isc-dhcp-server"
default[:dhcpd][:dhcpd_conf_file] = "/etc/dhcp/dhcpd.conf"


default[:dhcpd][:authoritative] = false
default[:dhcpd][:interfaces] = [ 'eth0' ]
default[:dhcpd][:next_server] = false
default[:dhcpd][:routers] = "10.0.27.1"
default[:dhcpd][:netmask] = "255.255.248.0"
default[:dhcpd][:subnet] = '10.0.24.0'
default[:dhcpd][:range] = [ '10.0.29.1', '10.0.29.254' ]
default[:dhcpd][:default_lease_time] = "600"
default[:dhcpd][:max_lease_time] = "7200"
default[:dhcpd][:filename] = "pxelinux.0"
default[:dhcpd][:nameservers] = [ '10.0.27.102', '10.0.28.2' ]
default[:dhcpd][:domain] = "bos1"
default[:dhcpd][:dynamicbootp] = false
default[:dhcpd][:staticroutes] = nil

#ddns
default[:dhcp][:revdomainname] = false
default[:dhcp][:ignore_clientupdates] = true
