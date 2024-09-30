### Steps to deploy the docker compose

#### 1. Create .env file

Fill it with the following variables:
- MONGODB_DATABASE_NAME
- MONGODB_USERNAME
- MONGODB_PASSWORD
- DDNS_RUNNER_TOKEN
- DDNS_RUNNER_POSTGRES_URI
- DDNS_RUNNER_POSTGRES_PASSWORD
- DDNS_RUNNER_POSTGRES_USER
- DDNS_RUNNER_POSTGRES_DB
- GRAFANA_USER
- GRAFANA_PASSWORD

#### 2. Run certbot to get certificate

`sudo snap install certbot --classic`
`sudo certbot obtain -d phdwebsite.duckdns.org`

#### 3. Prepare soft links to certificate and private key

`sudo ln -s <path-to-private-key> privatekey.pem`
`sudo ln -s <path-to-cert> fullchain.pem`
