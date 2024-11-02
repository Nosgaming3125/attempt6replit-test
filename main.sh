#!/bin/bash


echo ---------------
echo -e "\e[1;34mStarting EaglerCraft Server\e[0m"
echo ---------------
unset DISPLAY

echo "set -g mouse on" > ~/.tmux.conf

tmux kill-session -t server
caddy stop

rm -f web/README.md
cp README.md web/README.md

if [ -f "base.repl" ] && ! { [ "$REPL_OWNER" == "AndreGames5" ] && [ "$REPL_SLUG" == "eagler-craft" ]; }; then
  rm base.repl
  rm -rf server/world
  rm -rf server/world_nether
  rm -rf server/world_the_end
  rm -rf server/logs
  rm -rf server/plugins/bStats
  rm -f server/usercache.json
  rm -rf bungee/logs
  rm -f bungee/eaglercraft_skins_cache.db
  rm -f bungee/eaglercraft_auths.db
  rm -f oldgee/proxy.log.0
  rm -f oldgee/proxy.log.0.lck
  sed -i '/^stats: /d' bungee/config.yml
  sed -i "s/^stats: .*\$/stats: $(cat /proc/sys/kernel/random/uuid)/" oldgee/config.yml
  sed -i "s/^server_uuid: .*\$/server_uuid: $(cat /proc/sys/kernel/random/uuid)/" bungee/plugins/EaglercraftXBungee/settings.yml
fi

if [ -f "base.repl" ]; then
  rm -rf server/logs
  rm -f server/usercache.json
  rm -rf bungee/logs
  rm -f bungee/eaglercraft_skins_cache.db
  rm -f bungee/eaglercraft_auths.db
  rm -f oldgee/proxy.log.0
  rm -f oldgee/proxy.log.0.lck
fi

sed -i "s/^  redirect_legacy_clients_to: .*\$/  redirect_legacy_clients_to: 'wss:\/\/$REPL_SLUG.$REPL_OWNER.repl.co\/old'/" bungee/plugins/EaglercraftXBungee/listeners.yml

caddy start --config ./Caddyfile > /dev/null 2>&1

cd server
tmux new -d -s server "java -Djline.terminal=jline.UnsupportedTerminal -Xmx512M -jar server.jar nogui; tmux kill-session -t server"
cd ..

cd oldgee
tmux splitw -t server -v "java -Xmx512M -Xms512M -jar bungee-dist.jar; tmux kill-session -t server"
cd ..

cd bungee
tmux splitw -t server -h "java -Xmx512M -Xms512M -jar bungee.jar; tmux kill-session -t server"
cd ..

while tmux has-session -t server
do
  tmux a -t server
done

caddy stop