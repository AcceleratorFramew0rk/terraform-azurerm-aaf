resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = "osint-cosmosdb-${var.random_string}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  tags                = var.tags

  enable_automatic_failover     = true
  public_network_access_enabled = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "articles" {
  name                = "Articles"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
}

resource "azurerm_cosmosdb_sql_database" "normalized" {
  name                = "OSINTNormalized"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
}

resource "azurerm_cosmosdb_sql_container" "ingest" {
  name                = "Ingest"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.articles.name
  partition_key_path  = "/artifact_type"
  throughput          = 10000
  default_ttl         = 5184000
  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }
}

resource "azurerm_cosmosdb_sql_container" "inspection" {
  name                = "Inspection"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.articles.name
  partition_key_path  = "/artifact_type"
  throughput          = 4000
  default_ttl         = 5184000
  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }
}

resource "azurerm_cosmosdb_sql_container" "processed" {
  name                = "Processed"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.articles.name
  partition_key_path  = "/artifact_type"
  throughput          = 4000
  default_ttl         = 5184000
  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }
}

resource "azurerm_cosmosdb_sql_container" "normalized" {
  name                = "NormalizedRSS"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.normalized.name
  partition_key_path  = "/artifact_type"
  throughput          = 4000
  default_ttl         = 15768000
  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }
}