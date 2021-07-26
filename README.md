# WLIPV2-NOAPI



Voici une WhiteList ip ! 

Débrouillez vous sur le ratelimit jvais pas non plus vous le config lol

Ensuite pas besoin d'api juste add sa dans le server.cfg


endpoint_add_tcp "0.0.0.0:30120"
endpoint_add_udp "0.0.0.0:30120"

sv_requestParanoia 3

sv_endpointprivacy true

sv_useDirectListing true


Ensuite cela 

du côter serveur.lua d'un vos script 

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local _source = source
    local ip, guid = GetPlayerEP(_source), GetPlayerGuid(_source)
    os.execute("ipset add whitelist " .. ip)
    local color = "^"..math.random(0,9)
    print("[WhiteList IP] ^7- "..color.." ".. GetPlayerName(source) .." Connecté^0 - WITHELIST IP : " .. ip)

end)


AddEventHandler('playerDropped', function (reason)
    local _source = source
    local ip, guid = GetPlayerEP(_source), GetPlayerGuid(_source)
    os.execute("ipset del whitelist " .. ip)
    local color = "^"..math.random(0,9)
    print("[WhiteList IP] ^7- "..color.." ".. GetPlayerName(source) .." Déconnecté^0 - UN WITHELIST IP : " .. ip)
end)




OUBLIER PAS CELA N'EST PAS UN ANTIDDOS !!!!!!


Cela veut dire que si vous mettez cela sur une machine qui ne possède pas une vraie mitigation comme un OVH-GAME cela ne servira à rien !

Jdit sa pour les skids de 13 ans 

