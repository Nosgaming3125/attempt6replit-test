#!/bin/bash

echo "---------------"
echo -e "\e[1;34mStarting EaglerCraft Server\e[0m"
echo "---------------"
unset DISPLAY

# Enable mouse mode in tmux
echo "Setting up tmux mouse mode..."
echo "set -g mouse on" > ~/.tmux.conf

# Stop existing tmux session if any
echo "Stopping any existing tmux session..."
tmux kill-session -t server 2>/dev/null

# Check if Caddy is running before stopping it
echo "Checking if Caddy is running..."
if pgrep -x "caddy" > /dev/null; then
  echo "Stopping Caddy..."
  caddy stop
else
  echo "Caddy is not running, skipping stop."
fi

# Remove and copy files
echo "Preparing files..."
rm -f web/README.md
cp README.md web/README.md

# Only reset data if not running under specific REPL settings
if [ -f "base.repl" ] && ! { [ "$REPL_OWNER" == "AndreGames5" ] && [ "$REPL_SLUG" == "eagler-craft" ]; }; then
  echo "Resetting server data..."
  rm -f base.repl
  rm -rf server/world server/world_nether server/world_the_end server/logs server/plugins/bStats
  rm -f server/usercache.json bungee/eaglercraft_skins_cache.db bungee/eaglercraft_auths.db
  rm -f oldgee/proxy.log.0 oldgee/proxy.log.0.lck
  sed -i '/^stats: /d' bungee/config.yml
  sed -i "s/^stats: .*\$/stats: $(cat /proc/sys/kernel/random/uuid)/" oldgee/config.yml
  sed -i "s/^server_uuid: .*\$/server_uuid: $(cat /proc/sys/kernel/random/uuid)/" bungee/plugins/EaglercraftXBungee/settings.yml
fi

# Clean logs and cache if "base.repl" exists
if [ -f "base.repl" ]; then
  echo "Cleaning logs and cache..."
  rm -rf server/logs bungee/logs
  rm -f server/usercache.json bungee/eaglercraft_skins_cache.db bungee/eaglercraft_auths.db oldgee/proxy.log.0 oldgee/proxy.log.0.lck
fi

# Update redirect in listeners.yml
echo "Updating listeners configuration..."
sed -i "s/^  redirect_legacy_clients_to: .*\$/  redirect_legacy_clients_to: 'wss:\/\/$REPL_SLUG.$REPL_OWNER.repl.co\/old'/" bungee/plugins/EaglercraftXBungee/listeners.yml

# Start Caddy in the background
echo "Starting Caddy server..."
caddy start --config ./Caddyfile > caddy.log 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to start Caddy. Check caddy.log for details."
  cat caddy.log  # Display the Caddy log
  read -p "Press enter to exit..."  # Pause to allow the user to read the log
  exit 1
fi

# Start tmux session for each server component with logging
echo "Starting server components in tmux..."
cd server
tmux new -d -s server "java -Djline.terminal=jline.UnsupportedTerminal -Xmx512M -jar server.jar nogui > ../server.log 2>&1; read -p 'Press enter to exit...' "
cd ..

cd oldgee
tmux splitw -t server -v "java -Xmx512M -Xms512M -jar bungee-dist.jar > ../oldgee.log 2>&1; read -p 'Press enter to exit...' "
cd ..

cd bungee
tmux splitw -t server -h "java -Xmx512M -Xms512M -jar bungee.jar > ../bungee.log 2>&1; read -p 'Press enter to exit...' "
cd ..

# Attach to tmux session or wait if it can’t attach
echo "Attaching to tmux session..."
while tmux has-session -t server 2>/dev/null; do
  tmux attach -t server || break
done

# Stop Caddy after tmux session ends
echo "Stopping Caddy..."
caddy stop
