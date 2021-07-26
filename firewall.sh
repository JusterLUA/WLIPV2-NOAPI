	iptables -F
	iptables -X
	iptables -t nat -F
	iptables -t nat -X
	ipset destroy
	ipset create whitelist hash:net

	ipset add whitelist 77.77.77.78



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
