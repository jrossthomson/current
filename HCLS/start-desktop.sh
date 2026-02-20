#!/bin/bash 

# 1. Clean up old locks or sessions
vncserver -kill :1 2>/dev/null
sudo rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# 2. Ensure the startup config is correct
mkdir -p ~/.vnc
cat <<EOF > ~/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export DISPLAY=:1

# Disable xiccd to stop the RandR and colord errors
export LC_ALL=C
lxsession -s LXDE -e LXDE &
EOF
chmod +x ~/.vnc/xstartup

# Pipe the password into the utility
echo "cloudshell" | vncpasswd -f > ~/.vnc/passwd

# Secure the file permissions (VNC will fail if it's too open)
chmod 600 ~/.vnc/passwd

# 3. Start VNC Server
vncserver :1 -geometry 1280x800 -depth 24

# 4. Start noVNC Proxy
echo "Starting noVNC on port 8080..."
/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 8080