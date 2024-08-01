###########################################################################
#                    Resource Groups                                      #
###########################################################################


resource "azurerm_resource_group" "vnet1-rg" {
  name     = "vnet1-rg"
  location = "East US"
}

resource "azurerm_resource_group" "nsg1-rg" {
  name     = "nsg1-rg"
  location = "East US"
}

###########################################################################
#                     Network Security Groups                             #
###########################################################################


resource "azurerm_network_security_group" "Subnet1-NSG" {
  name                = "Subnet1-NSG"
  location            = azurerm_resource_group.nsg1-rg.location
  resource_group_name = azurerm_resource_group.nsg1-rg.name
}

resource "azurerm_network_security_group" "Subnet2-NSG" {
  name                = "Subnet2-NSG"
  location            = azurerm_resource_group.nsg1-rg.location
  resource_group_name = azurerm_resource_group.nsg1-rg.name
}

###########################################################################
#                     Virtual Networks                                    #
###########################################################################

resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  location            = "East US"
  resource_group_name = "vnet1-rg"
  address_space       = ["10.1.0.0/16", "10.2.0.0/16"]

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet2"
  location            = "East US"
  resource_group_name = "vnet1-rg"
  address_space       = ["10.4.0.0/16", "10.5.0.0/16"]

  tags = {
    environment = "Production"
  }
}

###########################################################################
#                          Subnets                                        #
###########################################################################


resource "azurerm_subnet" "subnet1" {
  name                                           = "subnet1"
  resource_group_name                            = azurerm_resource_group.vnet1-rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet1.name
  address_prefixes                               = ["10.1.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "subnet2" {
  name                                           = "subnet2"
  resource_group_name                            = azurerm_resource_group.vnet1-rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet1.name
  address_prefixes                               = ["10.2.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "subnet3" {
  name                                           = "subnet3"
  resource_group_name                            = azurerm_resource_group.vnet1-rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet1.name
  address_prefixes                               = ["10.1.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "subnet4" {
  name                                           = "subnet4"
  resource_group_name                            = azurerm_resource_group.vnet1-rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet2.name
  address_prefixes                               = ["10.4.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
}


###########################################################################
#                     Route Tables                                        #
###########################################################################


resource "azurerm_route_table" "routetable-01" {
  name                          = "routetable-01"
  location                      = azurerm_resource_group.vnet1-rg.location
  resource_group_name           = azurerm_resource_group.vnet1-rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "route1"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.1.1.1"
  }

  tags = {
    environment = "Production"
  }
}

###########################################################################
#                      VNet Peering                                       #
###########################################################################

resource "azurerm_virtual_network_peering" "vnet1-vnet2" {
  name                         = "vnet1-vnet2"
  resource_group_name          = azurerm_resource_group.vnet1-rg.name
  virtual_network_name         = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

}

resource "azurerm_virtual_network_peering" "vnet2-vnet1" {
  name                         = "vnet2-vnet1"
  resource_group_name          = azurerm_resource_group.vnet1-rg.name
  virtual_network_name         = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}