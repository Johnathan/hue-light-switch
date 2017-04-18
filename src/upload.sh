#/bin/sh
if [ -z "$1" ]; then
 echo "This script requires an argument: USB device port"
 exit 1;
fi

if [[ $* == *--from-scratch* ]]; then
    nodemcu-tool mkfs --port $1
fi

nodemcu-tool upload ./init.lua --port $1 --connection-delay 500

#Routes
nodemcu-tool upload ./persistence.lua --port $1 --connection-delay 500 --compile --optimize
nodemcu-tool upload ./StatusLight.lua --port $1 --connection-delay 500 --compile --optimize
nodemcu-tool upload ./routes/ping.get.lua -k --port $1 --connection-delay 500 --compile --optimize
nodemcu-tool upload ./routes/access-points.get.lua -k --port $1 --connection-delay 500 --compile --optimize
nodemcu-tool upload ./routes/access-points.post.lua -k --port $1 --connection-delay 500 --compile --optimize

if [[ $* == *--upload-espress* ]]; then
    cd espress && sh upload.sh $1 && cd -
fi

#Log
nodemcu-tool fsinfo --port $1 --connection-delay 500