#!/bin/bash

# Starting EaglerCraft Server
echo "---------------"
echo "Starting EaglerCraft Server"

# Function to display previous logs
display_previous_logs() {
    echo "Displaying previous logs..."
    if [ -f "server.log" ]; then  # Assuming logs are stored in server.log
        tail -n 50 server.log  # Display the last 50 lines of the log
    else
        echo "No previous logs found."
    fi
}

# Setting up tmux mouse mode
echo "Setting up tmux mouse mode..."
# (Your existing tmux setup commands here)

# Stopping any existing tmux session
echo "Stopping any existing tmux session..."
# (Your existing tmux session stop commands here)

# Checking if Caddy is running
echo "Checking if Caddy is running..."
# (Your existing Caddy check commands here)

# Stopping Caddy
echo "Stopping Caddy..."
# (Your existing Caddy stop commands here)

# Preparing files
echo "Preparing files..."
# (Your existing file preparation commands here)

# Display previous logs
display_previous_logs

# Starting Caddy server
echo "Starting Caddy server..."
# (Your existing Caddy start commands here)

# Starting Minecraft server
echo "Starting Minecraft server..."
# (Your existing Minecraft server start commands here)

echo "EaglerCraft Server has been started!"
