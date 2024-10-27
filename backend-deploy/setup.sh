set -e

sudo snap install certbot --classic

sudo certbot obtain -d phdwebsite.duckdns.org

sudo ln -s /etc/letsencrypt/live/phdwebsite.duckdns.org/privkey.pem privkey.pem
sudo ln -s /etc/letsencrypt/live/phdwebsite.duckdns.org/fullchain.pem fullchain.pem
