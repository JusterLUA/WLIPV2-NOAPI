	iptables -F
	iptables -X
	iptables -t nat -F
	iptables -t nat -X
	ipset destroy
	ipset create whitelist hash:net

	ipset add whitelist 45.145.167.72
	ipset add whitelist 5.135.143.71
	ipset add whitelist 45.145.167.47
	ipset add whitelist 77.199.56.27
	ipset add whitelist 51.91.214.112
	ipset add whitelist 127.0.0.1
	ipset add whitelist 194.9.172.103
	ipset add whitelist 194.9.172.213
	ipset add whitelist 194.9.172.216
	ipset add whitelist 194.9.172.101
	ipset add whitelist 194.9.172.247
	ipset add whitelist 194.9.172.214
	ipset add whitelist 194.9.172.102
	ipset add whitelist 194.9.172.220
	ipset add whitelist 104.18.26.120
	ipset add whitelist 51.91.214.112
	ipset add whitelist 51.91.21.55
	ipset add whitelist 51.91.22.57
	ipset add whitelist 51.91.21.135
	ipset add whitelist 51.91.139.192
	ipset add whitelist 51.159.31.33
	ipset add whitelist 104.22.46.177
	ipset add whitelist 46.105.28.192
	ipset add whitelist 144.76.27.28
	ipset add whitelist 172.67.38.114
	ipset add whitelist 176.31.236.143
	ipset add whitelist 178.32.9.100
	ipset add whitelist 178.33.224.212
	ipset add whitelist 146.59.193.195
	ipset add whitelist 51.210.126.15
	ipset add whitelist 146.59.204.24
	ipset add whitelist 51.178.63.83
	ipset add whitelist 51.91.137.120
	ipset add whitelist 146.59.204.24
	ipset add whitelist 51.91.139.192
	ipset add whitelist 51.210.127.214




	iptables -A INPUT -i lo -j ACCEPT
	iptables -A INPUT -p udp --sport 53 -j ACCEPT


	iptables -N FIVEM-FREEACCES
	iptables -A FIVEM-FREEACCES -m set --match-set whitelist src -j ACCEPT
	iptables -A FIVEM-FREEACCES -j DROP


	iptables -N FIVEM-QUERY
	iptables -A FIVEM-QUERY -m u32 --u32 "0x1D&0xFF=0x67" -m hashlimit --hashlimit 3/sec --hashlimit-burst 5 --hashlimit-mode srcip --hashlimit-name query-getinfo -j ACCEPT
	iptables -A FIVEM-QUERY -m limit --limit 3/min -j LOG --log-prefix "[FIREWALL] FIVEM-QUERY : " --log-level warning
	iptables -A FIVEM-QUERY -j ACCEPT


	iptables -N FIVEM-UDP
	iptables -A FIVEM-UDP -m u32 --u32 "0x1C=0xffffffff" -j FIVEM-QUERY
	iptables -A FIVEM-UDP -m u32 --u32 "0x1A&0xffff=0x8fff" -j SET --add-set whitelist src
	iptables -A FIVEM-UDP -j FIVEM-FREEACCES

	iptables -N FIVEM-EXEPTION
	iptables -A FIVEM-EXEPTION -s 178.32.9.100 -j ACCEPT
	iptables -A FIVEM-EXEPTION -j DROP

	iptables -N FIVEM-TCP-GET
	iptables -A FIVEM-TCP-GET -m u32 --u32 "0x2C=0x2f776562" -j DROP #FIVEM-WEBADMIN
	iptables -A FIVEM-TCP-GET -m u32 --u32 "0x2C=0x2f706c61" -j FIVEM-EXEPTION #FIVEM-PLAYERS-JSON
	iptables -A FIVEM-TCP-GET -m u32 --u32 "0x2C=0x2f204854" -j FIVEM-EXEPTION #FIVEM-INDEX
	iptables -A FIVEM-TCP-GET -m u32 --u32 "0x2C=0x2f696e66" -j RETURN #FIVEM-INFO-JSON
	iptables -A FIVEM-TCP-GET -j RETURN

	iptables -N FIVEM-TCP-POST
	iptables -A FIVEM-TCP-POST -m u32 --u32 "0x2D=0x2f636c69" -m hashlimit --hashlimit-above 1/second --hashlimit-burst 2 --hashlimit-mode srcip --hashlimit-name client_limit -j DROP
	iptables -A FIVEM-TCP-POST -m u32 --u32 "0x2D=0x2f636c69" -j SET --add-set whitelist src
	iptables -A FIVEM-TCP-POST -j ACCEPT

	iptables -N FIVEM-TCP
	iptables -A FIVEM-TCP -m length --length 40 -j ACCEPT
	iptables -A FIVEM-TCP -m u32 --u32 "0x27&0xffffff=0x160301" -j SET --add-set whitelist src
	iptables -A FIVEM-TCP -m u32 --u32 "0x28=0x504f5354" -j FIVEM-TCP-POST
	iptables -A FIVEM-TCP -m u32 --u32 "0x28=0x47455420" -j FIVEM-TCP-GET
	iptables -A FIVEM-TCP -j FIVEM-FREEACCES
	 iptables -A FIVEM-TCP -j RETURN

	 iptables -A INPUT -p udp --dport 30120 -j FIVEM-FREEACCES
	 iptables -A INPUT -p tcp --dport 30120 -j FIVEM-FREEACCES
	 iptables -A INPUT -p tcp --dport 22 -j FIVEM-FREEACCES
	 iptables -A INPUT -p tcp --dport 80 -j FIVEM-FREEACCES
	 iptables -A INPUT -p udp -j FIVEM-FREEACCES

	 iptables -A INPUT -p tcp --dport 30120 -m string --algo bm --string '/client' -j SET --add-set whitelist src

	iptables -N SYN-LIMIT
	iptables -A SYN-LIMIT -m hashlimit --hashlimit 10/second --hashlimit-burst 10 --hashlimit-mode srcip,dstport --hashlimit-name SYN-LIMIT -j ACCEPT
	iptables -A SYN-LIMIT -m limit --limit 3/min -j LOG --log-prefix "[FIREWALL] SYN-LIMIT : " --log-level warning
	iptables -A SYN-LIMIT -j DROP

	iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
	iptables -A INPUT -p tcp -m state --state INVALID -j DROP
	iptables -A INPUT -p tcp --syn -m length --length 0:47 -j DROP
	iptables -A INPUT -p tcp --syn -m length --length 49:51 -j DROP
	iptables -A INPUT -p tcp --syn -m length --length 53:55 -j DROP
	iptables -A INPUT -p tcp --syn -m length --length 57:59 -j DROP
	iptables -A INPUT -p tcp --syn -m length --length 61:0xFFFF -j DROP

	iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL FIN -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
	iptables -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j DROP
	iptables -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP
	iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
	iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
	iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

	iptables -A INPUT -p tcp --syn -j SYN-LIMIT

	iptables -A INPUT -p udp --dport 30120 -j FIVEM-UDP
	iptables -A INPUT -p tcp --dport 30120 --tcp-flags SYN,ACK,FIN,RST ACK -j FIVEM-TCP


	iptables -A INPUT -p tcp -m tcp --dport 30120 -j ACCEPT
