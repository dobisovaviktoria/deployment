#!/bin/bash

VIRTUAL_MACHINE="vm-infra3-groceryapp"
RESOURCE_GROUP="rg-infra3"
LOCATION="westeurope"
USER="student"
VM_SIZE="Standard_B2ts_v2"
IMAGE="Ubuntu2204"
SSH_KEY="$HOME/.ssh/infra3_key.pub"
DUCKDNS_DOMAIN="groceryappvd"

if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed. Please install before running the script."
    exit 1
fi

if [ ! -f "$SSH_KEY" ]; then
    echo "Error: Missing SSH public key."
    exit 1
fi

echo "CREATING RESOURCE GROUP: $RESOURCE_GROUP"
if ! az group create --name "$RESOURCE_GROUP" --location "$LOCATION" > /dev/null; then
    echo "Error: Failed to create resource group."
    exit 1
fi

echo "CREATING VM: $VIRTUAL_MACHINE"
if ! az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VIRTUAL_MACHINE" \
    --image "$IMAGE" \
    --admin-username "$USER" \
    --ssh-key-values "$SSH_KEY" \
    --size "$VM_SIZE" \
    --public-ip-sku Standard \
    --public-ip-address-dns-name "$DUCKDNS_DOMAIN"; then
    echo "Error: Failed to create VM."
    exit 1
fi

echo "INSTALLING DOCKER"
INSTALL_SCRIPT='
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker azureuser
docker compose version
'
if ! az vm run-command invoke --resource-group "$RESOURCE_GROUP" --name "$VIRTUAL_MACHINE" --command-id RunShellScript --scripts "$INSTALL_SCRIPT" > /dev/null; then
    echo "Docker setup failed."
    exit 1
fi

echo "RETRIEVING PUBLIC IP"
PUBLIC_IP=$(az vm list-ip-addresses \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VIRTUAL_MACHINE" \
    --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
    -o tsv 2>/dev/null)

if [ -z "$PUBLIC_IP" ]; then
    echo "Error: Failed to retrieve public IP for VM $VIRTUAL_MACHINE in resource group $RESOURCE_GROUP."
    exit 1
fi

echo "OPENING PORTS"
PORTS=(22 80 443 8082)
for port in "${!PORTS[@]}"; do
    PORT=${PORTS[$port]}
    PRIORITY=$((900 + port))
    if ! az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VIRTUAL_MACHINE" --port "$PORT" --priority "$PRIORITY" > /dev/null; then
        echo "Could not open port $PORT."
    fi
done

FULL_DNS="https://${DUCKDNS_DOMAIN}.duckdns.org"

echo "VM setup successful"
echo "Public IP Address: $PUBLIC_IP"
echo "DNS Address: $FULL_DNS"
echo "SSH Connection: ssh -i ~/.ssh/infra3_key $USER@$PUBLIC_IP"