#!/bin/bash
#===============================
#Usage: ./setup_session.sh [session-name]
#===============================

SESSION_NAME="${1:-ops}"
IFACE="eth0"

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
	echo "Session '$SESSION_NAME' already exists. Attaching..."
	tmux attach-session -t "$SESSION_NAME"
	exit 0
fi

# Create session and first window - MAIN
tmux new-session -d -s "$SESSION_NAME" -n "MAIN"

# Set iptables rule to allow ssh, http, https, and icmp. Drop all other traffic
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -F" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -P INPUT DROP" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -P FORWARD DROP" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -P OUTPUT DROP" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A INPUT -i lo -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A OUTPUT -o lo -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A INPUT -p tcp --sport 22 -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A INPUT -p tcp --dport 22 -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A INPUT -p tcp --dport 80 -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A INPUT -p tcp --dport 443 -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A OUTPUT -p tcp --sport 443 -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A INPUT -p icmp -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A OUTPUT -p icmp -j ACCEPT" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A INPUT -j LOG --log-prefix 'IPT-DROP-IN: ' --log-level 4" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -A OUTPUT -j LOG --log-prefix 'IPT-DROP-OUT: ' --log-level 4" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "iptables -L -vn" Enter
tmux send-keys -t "$SESSION_NAME:MAIN" "su kali; firefox &" Enter

# Create tunneling windows - 4 panes, one per quadrant
tmux new-window -t "$SESSION_NAME:1" -n "TUNNELING"

tmux split-window -t "$SESSION_NAME:TUNNELING" -h
tmux split-window -t "$SESSION_NAME:TUNNELING.0" -v
tmux split-window -t "$SESSION_NAME:TUNNELING.2" -v

# Create logging windows - 4 pantes, one per quadrant
tmux new-window -t "$SESSION_NAME:2" -n "LOGGING"

tmux split-window -t "$SESSION_NAME:LOGGING" -h
tmux split-window -t "$SESSION_NAME:LOGGING.0" -v
tmux split-window -t "$SESSION_NAME:LOGGING.2" -v

# Logging Pane keys
# Set watch on interfaces
tmux send-keys -t "$SESSION_NAME:LOGGING.0" "watch -n 2 ip -br a" Enter

#Set tcp dump on outbound interface
tmux send-keys -t "$SESSION_NAME:LOGGING.1" "tcpdump -i $IFACE -n" Enter

# Set watch on iptables hits
tmux send-keys -t "$SESSION_NAME:LOGGING.2" "watch -n 2 'echo "===IPT DROPS==="; dmesg | grep "IPT-DROP-IN" | tail -20'" Enter

# Set a last on btmp files
tmux send-keys -t "$SESSION_NAME:LOGGING.3" "watch -n 2 'last -f /var/log/btmp'" Enter

# Create msfconsole window
tmux new-window -t "$SESSION_NAME:3" -n "MSFCONSOLE"

# msfconsole window
tmux send-keys -t "$SESSION_NAME:MSFCONSOLE" "systemctl start postgresql" Enter
tmux send-keys -t "$SESSION_NAME:MSFCONSOLE" "systemctl enable postgresql" Enter

tmux send-keys -t "$SESSION_NAME:MSFCONSOLE" "msfdb init" Enter
tmux send-keys -t "$SESSION_NAME:MSFCONSOLE" "msfdb start && msfconsole -q" Enter

# While loop to wait for msfconsole to start
echo "Waiting for msfconsole..."
while ! tmux capture-pane -t "$SESSION_NAME:MSFCONSOLE" -p | grep -q "msf"; do
	sleep 2
done
echo "msfconsole ready"

# Configuring MSFCONSOLE 
tmux send-keys -t "$SESSION_NAME:MSFCONSOLE" "db_status" Enter
tmux send-keys -t "$SESSION_NAME:MSFCONSOLE" "setg lhost $IFACE" Enter
tmux send-keys -t "$SESSION_NAME:MSFCONSOLE" "setg lport 4444" Enter
tmux send-keys -t "$SESSION_NAME:MSFCONSOLE" "setg verbose true" Enter

# Land inside the main window
#tmux select-window -t "$SESSION_NAME:MAIN"
tmux attach-session -t "$SESSION_NAME:MAIN"
