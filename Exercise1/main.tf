
# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "my_rg" {
  name     = "myRG_1"
  location = var.region

  tags = {
    environment = var.env_tag
  }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "myVnet_1"
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  resource_group_name = azurerm_resource_group.my_rg.name

  tags = {
    environment = var.env_tag
  }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "mySubnet_1"
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  count               = 2
  name                = "myPublicIP${count.index}"
  location            = var.region
  resource_group_name = azurerm_resource_group.my_rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = var.env_tag
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = var.region
  resource_group_name = azurerm_resource_group.my_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.env_tag
  }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  count               = var.vm_count
  name                = "myNIC${count.index}"
  location            = var.region
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip[count.index].id
  }

  tags = {
    environment = var.env_tag
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.myterraformnic[count.index].id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.my_rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.my_rg.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.env_tag
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "tls_private_key" { value = "${tls_private_key.example_ssh.private_key_pem}" }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  count                 = var.vm_count
  name                  = var.vm_names[count.index]
  location              = var.region
  resource_group_name   = azurerm_resource_group.my_rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic[count.index].id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm${count.index}"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }

  tags = {
    environment = var.env_tag
  }
}

