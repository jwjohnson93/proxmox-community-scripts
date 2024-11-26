#!/usr/bin/env bash
# Combined installation script for Sonarr, Radarr, Lidarr, and NZBGet

# Source the functions file
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"

# Call necessary functions
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# Function to install Sonarr
install_sonarr() {
  msg_info "Installing Sonarr v4"
  mkdir -p /var/lib/sonarr/
  chmod 775 /var/lib/sonarr/
  wget -q -O SonarrV4.tar.gz 'https://services.sonarr.tv/v1/download/main/latest?version=4&os=linux&arch=x64'
  tar -xzf SonarrV4.tar.gz
  mv Sonarr /opt
  rm -rf SonarrV4.tar.gz
  msg_ok "Installed Sonarr v4"

  msg_info "Creating Sonarr Service"
  cat <<EOF >/etc/systemd/system/sonarr.service
[Unit]
Description=Sonarr Daemon
After=syslog.target network.target
[Service]
Type=simple
ExecStart=/opt/Sonarr/Sonarr -nobrowser -data=/var/lib/sonarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
  systemctl enable -q --now sonarr.service
  msg_ok "Created Sonarr Service"
}

# Function to install Radarr
install_radarr() {
  msg_info "Installing Radarr"
  mkdir -p /var/lib/radarr/
  chmod 775 /var/lib/radarr/
  wget --content-disposition 'https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
  tar -xvzf Radarr.master.*.tar.gz
  mv Radarr /opt
  chmod 775 /opt/Radarr
  msg_ok "Installed Radarr"

  msg_info "Creating Radarr Service"
  cat <<EOF >/etc/systemd/system/radarr.service
[Unit]
Description=Radarr Daemon
After=syslog.target network.target
[Service]
UMask=0002
Type=simple
ExecStart=/opt/Radarr/Radarr -nobrowser -data=/var/lib/radarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
  systemctl -q daemon-reload
  systemctl enable --now -q radarr
  msg_ok "Created Radarr Service"
}

# Function to install Lidarr
install_lidarr() {
  msg_info "Installing Lidarr"
  mkdir -p /var/lib/lidarr/
  chmod 775 /var/lib/lidarr/
  wget --content-disposition 'https://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
  tar -xvzf Lidarr.master.*.tar.gz
  mv Lidarr /opt
  chmod 775 /opt/Lidarr
  msg_ok "Installed Lidarr"

  msg_info "Creating Lidarr Service"
  cat <<EOF >/etc/systemd/system/lidarr.service
[Unit]
Description=Lidarr Daemon
After=syslog.target network.target
[Service]
UMask=0002
Type=simple
ExecStart=/opt/Lidarr/Lidarr -nobrowser -data=/var/lib/lidarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
  systemctl -q daemon-reload
  systemctl enable --now -q lidarr
  msg_ok "Created Lidarr Service"
}

# Function to install NZBGet
install_nzbget() {
  msg_info "Installing NZBGet"
  mkdir -p /var/lib/nzbget/
  chmod 775 /var/lib/nzbget/
  wget --content-disposition 'https://nzbget.net/download/nzbget-latest-bin-linux.run'
  sh nzbget-latest-bin-linux.run --destdir /opt/nzbget
  chmod 775 /opt/nzbget
  msg_ok "Installed NZBGet"

  msg_info "Creating NZBGet Service"
  cat <<EOF >/etc/systemd/system/nzbget.service
[Unit]
Description=NZBGet Daemon
After=syslog.target network.target
[Service]
UMask=0002
Type=simple
ExecStart=/opt/nzbget/nzbget -D
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
  systemctl -q daemon-reload
  systemctl enable --now -q nzbget
  msg_ok "Created NZBGet Service"
}

# Main script execution
msg_info "Installing Dependencies"
$STD apt-get install -y curl sudo mc sqlite3
msg_ok "Installed Dependencies"

install_sonarr
install_radarr
install_lidarr
install_nzbget

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"