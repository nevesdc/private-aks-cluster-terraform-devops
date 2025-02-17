#!/bin/bash

# Variables
keyVaultName="DevOpsTerraformKeyVault"
keyVaultResourceGroupName="KeyVaultsRG"
keyVaultSku="Standard"
location="WestEurope"
storageAccountName="baboterraform"
storageAccountResourceGroupName="StorageAccountsRG"
containerName="tfstate"
sshPublicKey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDRHrICSTesKCNyH6vN4K3YwhDUO89cqnEDz2bcZ0sLn9mU6hwyXHna5vME8Y/A8Jbj4XiMyePbAJsX8R/Yyq5pZSiqYpPqSdRGOGqKxQPMBE8WFN1RZmrbrb0ElVQtdWWhlCis4PyMn76fbH6Q8zf/cPzzm9GTimVw62BGhdqdHHru7Sy3I+WRGVA3Z2xHqpda+4nd9LYQW3zkHP98TbIM5OW8kVhRUtmg3c0tOViU6CsGP9w4FU8TU7wLWoeig69kv6UgikwnJYXkItiLecCbVqOeGwbHZQmawcqEY674E3jgJkJ5nQVblCODR0ODNCtrCDVyT6pX0Hdt1ivIpkf"
subscriptionName=$(az account show --query name --output tsv)

# Get storage account key
echo "Retrieving the primary key of the [$storageAccountName] storage account..."
storageAccountKey=$(az storage account keys list \
    --resource-group $storageAccountResourceGroupName  \
    --account-name $storageAccountName \
    --query [0].value -o tsv)

if [[ -n $storageAccountKey ]]; then
    echo "Primary key of the [$storageAccountName] storage account successfully retrieved"
else
    echo "Failed to retrieve the primary key of the [$storageAccountName] storage account"
    exit
fi

# Check if the resource group already exists
echo "Checking if [$keyVaultResourceGroupName] resource group actually exists in the [$subscriptionName] subscription..."

az group show --name $keyVaultResourceGroupName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$keyVaultResourceGroupName] resource group actually exists in the [$subscriptionName] subscription"
    echo "Creating [$keyVaultResourceGroupName] resource group in the [$subscriptionName] subscription..."
    
    # create the resource group
    az group create --name $keyVaultResourceGroupName --location $location 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$keyVaultResourceGroupName] resource group successfully created in the [$subscriptionName] subscription"
    else
        echo "Failed to create [$keyVaultResourceGroupName] resource group in the [$subscriptionName] subscription"
        exit
    fi
else
	echo "[$keyVaultResourceGroupName] resource group already exists in the [$subscriptionName] subscription"
fi

# Check if the key vault already exists
echo "Checking if [$keyVaultName] key vault actually exists in the [$subscriptionName] subscription..."

az keyvault show --name $keyVaultName --resource-group $keyVaultResourceGroupName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$keyVaultName] key vault actually exists in the [$subscriptionName] subscription"
    echo "Creating [$keyVaultName] key vault in the [$subscriptionName] subscription..."
    
    # create the key vault
    az keyvault create \
    --name $keyVaultName \
    --resource-group $keyVaultResourceGroupName \
    --location $location \
    --enabled-for-deployment \
    --enabled-for-disk-encryption \
    --enabled-for-template-deployment \
    --sku $keyVaultSku 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$keyVaultName] key vault successfully created in the [$subscriptionName] subscription"
    else
        echo "Failed to create [$keyVaultName] key vault in the [$subscriptionName] subscription"
        exit
    fi
else
	echo "[$keyVaultName] key vault already exists in the [$subscriptionName] subscription"
fi

# Check if the secret already exists
terraformBackendResourceGroupNameSecretName="terraformBackendResourceGroupName"
terraformBackendResourceGroupNameSecretValue=$storageAccountResourceGroupName

echo "Checking if [$terraformBackendResourceGroupNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $terraformBackendResourceGroupNameSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$terraformBackendResourceGroupNameSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$terraformBackendResourceGroupNameSecretName] secret in the [$keyVaultName] key vault..."
    
    # Create the secret
    az keyvault secret set \
    --name $terraformBackendResourceGroupNameSecretName \
    --vault-name $keyVaultName \
    --value $terraformBackendResourceGroupNameSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$terraformBackendResourceGroupNameSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$terraformBackendResourceGroupNameSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$terraformBackendResourceGroupNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
terraformBackendStorageAccountNameSecretName="terraformBackendStorageAccountName"
terraformBackendStorageAccountNameSecretValue=$storageAccountName

echo "Checking if [$terraformBackendStorageAccountNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $terraformBackendStorageAccountNameSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$terraformBackendStorageAccountNameSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$terraformBackendStorageAccountNameSecretName] secret in the [$keyVaultName] key vault..."
    
    # Create the secret
    az keyvault secret set \
    --name $terraformBackendStorageAccountNameSecretName \
    --vault-name $keyVaultName \
    --value $terraformBackendStorageAccountNameSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$terraformBackendStorageAccountNameSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$terraformBackendStorageAccountNameSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$terraformBackendStorageAccountNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
terraformBackendStorageAccountKeySecretName="terraformBackendStorageAccountKey"
terraformBackendStorageAccountKeySecretValue=$storageAccountKey

echo "Checking if [$terraformBackendStorageAccountKeySecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $terraformBackendStorageAccountKeySecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$terraformBackendStorageAccountKeySecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$terraformBackendStorageAccountKeySecretName] secret in the [$keyVaultName] key vault..."
    
    # Create the secret
    az keyvault secret set \
    --name $terraformBackendStorageAccountKeySecretName \
    --vault-name $keyVaultName \
    --value $terraformBackendStorageAccountKeySecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$terraformBackendStorageAccountKeySecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$terraformBackendStorageAccountKeySecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$terraformBackendStorageAccountKeySecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
terraformBackendContainerNameSecretName="terraformBackendContainerName"
terraformBackendContainerNameSecretValue=$containerName

echo "Checking if [$terraformBackendContainerNameSecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $terraformBackendContainerNameSecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$terraformBackendContainerNameSecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$terraformBackendContainerNameSecretName] secret in the [$keyVaultName] key vault..."
    
    # Create the secret
    az keyvault secret set \
    --name $terraformBackendContainerNameSecretName \
    --vault-name $keyVaultName \
    --value $terraformBackendContainerNameSecretValue 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$terraformBackendContainerNameSecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$terraformBackendContainerNameSecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$terraformBackendContainerNameSecretName] secret already exists in the [$keyVaultName] key vault"
fi

# Check if the secret already exists
sshPublicKeySecretName="sshPublicKey"
sshPublicKeySecretValue=$sshPublicKey

echo "Checking if [$sshPublicKeySecretName] secret actually exists in the [$keyVaultName] key vault..."

az keyvault secret show --name $sshPublicKeySecretName --vault-name $keyVaultName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$sshPublicKeySecretName] secret actually exists in the [$keyVaultName] key vault"
    echo "Creating [$sshPublicKeySecretName] secret in the [$keyVaultName] key vault..."
    
    # Create the secret
    az keyvault secret set \
    --name $sshPublicKeySecretName \
    --vault-name $keyVaultName \
    --value "$sshPublicKeySecretValue" 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$sshPublicKeySecretName] secret successfully created in the [$keyVaultName] key vault"
    else
        echo "Failed to create [$sshPublicKeySecretName] secret in the [$keyVaultName] key vault"
        exit
    fi
else
	echo "[$sshPublicKeySecretName] secret already exists in the [$keyVaultName] key vault"
fi