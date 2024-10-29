module "eventhub" {
  source              = "./eventhub-module"
  resource_group_name = "your-resource-group"
  location            = "East US"
  namespace_name      = "your-namespace-name"
  eventhub_name       = "your-eventhub-name"
  partition_count     = 4
  message_retention   = 7
  tags                = {
    Environment = "dev"
    Project     = "my-eventhub-project"
  }
}
