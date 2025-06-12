set -eux

yum update -y
yum install -y java-21-amazon-corretto-headless jq

useradd -r -m -d /srv/minecraft -s /sbin/nologin minecraft || true
mkdir -p /srv/minecraft
chown minecraft:minecraft /srv/minecraft

cd /srv/minecraft
META_URL=https://launchermeta.mojang.com/mc/game/version_manifest.json
LATEST=$(curl -s $META_URL | jq -r .latest.release)
OBJ_URL=$(curl -s $META_URL \
  | jq -r ".versions[] | select(.id==\"$LATEST\") | .url" \
  | xargs curl -sL \
  | jq -r .downloads.server.url)
curl -sSL -o server.jar "$OBJ_URL"
chown minecraft:minecraft server.jar

echo "eula=true" > eula.txt
chown minecraft:minecraft eula.txt

cat >/etc/systemd/system/minecraft.service << 'UNIT'
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
WorkingDirectory=/srv/minecraft
ExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui
ExecStop=/bin/kill -SIGINT $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable minecraft
systemctl start minecraft
