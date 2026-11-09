#!/usr/bin/env bash
# Novatrix v45: kör PÅ EC2, först när EFS är monterat på wp-content.
set -euo pipefail
WEBROOT=/var/www/html
if ! mountpoint -q "$WEBROOT/wp-content"; then
  echo "AVBRYT: EFS är inte monterat på $WEBROOT/wp-content" >&2
  exit 1
fi
if [[ -e "$WEBROOT/wp-config.php" ]]; then
  echo "AVBRYT: WordPress har redan wp-config.php. Ingen överskrivning." >&2
  exit 1
fi
sudo dnf install -y php php-mysqlnd php-gd php-mbstring php-xml mariadb105 curl tar
cd /tmp
curl --fail --location --retry 3 https://wordpress.org/latest.tar.gz -o wordpress-v45.tar.gz
mkdir -p wordpress-v45-extracted
tar -xzf wordpress-v45.tar.gz -C wordpress-v45-extracted
if [[ -f "$WEBROOT/index.html" ]]; then
  sudo mv "$WEBROOT/index.html" "$WEBROOT/index-v42.html"
fi
sudo cp -a wordpress-v45-extracted/wordpress/. "$WEBROOT/"
sudo chown -R apache:apache "$WEBROOT"
printf 'DirectoryIndex index.php index.html\n' | sudo tee /etc/httpd/conf.d/novatrix-wordpress-index.conf >/dev/null
sudo systemctl enable --now php-fpm
sudo apachectl configtest
sudo systemctl restart httpd
echo "Klar. Öppna http://<EC2-PUBLIK-IP>/ och kör WordPress-guiden."
