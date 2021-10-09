#!/bin/bash

VAULT_RETRIES=20
echo "Vault is starting..."
until vault status > /dev/null 2>&1 || [ "$VAULT_RETRIES" -eq 0 ]; do
        echo "Waiting for vault to start...: $((VAULT_RETRIES--))"
        sleep 1
done

echo "Authenticating to vault..."
vault login token=s.xy13iL17boVI0xuhiD3TzP7C

echo "Initializing vault..."
vault secrets enable -version=2 -path=my.secrets kv

echo "Adding entries..."
vault kv put my.secrets/dev username=test_user
vault kv put my.secrets/dev password=test_password

echo "Complete..."
