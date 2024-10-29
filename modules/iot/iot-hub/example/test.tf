module "iot_hub" {
  source              = "./azure_iot_hub_module"
  iot_hub_name        = "MyIoTHub"
  resource_group_name = "MyResourceGroup"
  location            = "East US"
  sku                 = "S1"
  capacity            = 1
  tags                = {
    environment = "test"
  }
}
