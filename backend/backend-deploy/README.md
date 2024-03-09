### Steps to deploy the docker compose

#### 1. Create .env file

Fill it with the following variables:
- MONGODB_DATABASE_NAME
- MONGODB_USERNAME
- MONGODB_PASSWORD
- DDNS_RUNNER_TOKEN

#### 2. Prepare soft links to certificate and private key

`sudo ln -s <path-to-private-key> privatekey.pem`
`sudo ln -s <path-to-cert> fullchain.pem`
