module "kusto_cluster" {
  source                   = "./kusto-cluster-module"
  resource_group_name      = "your-resource-group"
  location                 = "East US"
  cluster_name             = "your-kusto-cluster"
  sku_name                 = "Standard_D13_v2"
  sku_capacity             = 4

  tags = {
    Environment = "production"
    Project     = "data-explorer-project"
  }
}
