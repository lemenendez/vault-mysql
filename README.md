# vault / docker / docker compose / mysql server

git clone git@github.com:lemenendez/vault-mysql.git

`cd vault-mysql`

## Build images

`docker-compose build`

## run the containers

`docker-compose up -d`

## Enter into valault server

`docker-compose exec vault-server sh`

## Init vault server

If it is the first time you need to generate the initial keys.

`vault operator init -key-shares=6 -key-threshold=3`

It will generate the Inital Root Token and 6 Keys

`Unseal Key 1: fdS3QxWsvgekCebSeu6x1IyaL7T0PJ4YsSLGqrMc7fzi
Unseal Key 2: WB8E2E50GuZAhl9LAy6ThchZNvZTNAFe9NwUD0Bnrw89
Unseal Key 3: su0Rsvb2FPR+B0dlKiI7fT/ql6mT6v4moniN/+ARsL1j
Unseal Key 4: fBrSl5qNuexLf1SdM8Q3GBghozDIBFJqcvwW2f2vugXm
Unseal Key 5: 6B7QPmpXmf6XBkHHfrkuRG/Yg2QZ/keSXI6l5OIcJuVd

Initial Root Token: s.zfkbX2Rma4y0LOrMyBNNAFDq

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 3 keys to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.`

## Unseal the vault server

When a Vault server is started, it starts in a sealed state. In this state, Vault is configured to know where and how to access the physical storage, but doesn't know how to decrypt any of it <https://www.vaultproject.io/docs/concepts/seal>

If the server was down, we need to unsealed it. Run the command to unslead the server.
`vault operator unseal <GENERATED KEY 1>`
`vault operator unseal <GENERATED KEY 2>`
`vault operator unseal <GENERATED KEY 3>`

## Config database secrets engine

Enable database secret engine: `vault secrets enable database`

`Success! Enabled the database secrets engine at: database/`

Setup mysql database secret management plugin:
`vault write database/config/my-mysql-database \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(mysql.server:3306)/" \
    allowed_roles="my-role" \
    username="root" \
    password="devsecret"
`

important note:After configuring the root user, it is highly recommended you rotate that user's password such that the vault user is not accessible by any users other than Vault itself
`vault write -force database/rotate-root/my-database`

Create my-role role that will create mysql users:

`vault write database/roles/my-role \
    db_name=my-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"
`

Success! Data written to: database/roles/my-role

## Usage

Gets credentials for mysql with a duration of 1h

`vault read database/creds/my-role`

`
Key                Value
---                -----
lease_id           database/creds/my-role/k9G07KDhYefPeNHZ4xdNBk0D
lease_duration     1h
lease_renewable    true
password           hiNpVra-KDiYMsNj9Ksl
username           v-root-my-role-RTxaDMHlb2B0zx2vl
`

Check user list
`SELECT user FROM mysql.user`

`docker-compose build vault-client`

## Commands

`vault stat`
`vault init`
`vault operator unseal` 3 times to unseal
`vault login` login into the sever
`vault secrets enable database`
