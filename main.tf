terraform {

  required_providers {
    configcat = {
        source = "configcat/configcat"
        version = "~> 1.0"
    }
  }
}

locals {
  FLAGS_X_ENVS = { for k, v in flatten([
      for f_k, f_v in var.flags : [
        for env in var.ENVs : {
          flag = f_k,
          env = env,
          name = f_v.name,
          type = f_v.type,
          tags = f_v.tags,
          value = f_v.initial_values[env]
        }
      ]
    ]) : "${v.flag}_${v.env}" => v
  }
  TAGS = distinct(flatten([ for k, v in local.FLAGS_X_ENVS : [ for k_tag in v.tags : k_tag ] ]))
}

resource "random_shuffle" "tag_color" {
  for_each = toset(distinct(local.TAGS))

  keepers = {
    "product_id" = data.configcat_products.main.products.0.product_id
    "tag" = each.value
  }

  input        = ["panther", "whale", "salmon", "lizard", "canary", "koala"]
  result_count = 1
}

// Produto
data "configcat_products" "main" {
  name_filter_regex = var.product
}

// Configs
data "configcat_configs" "main" {
  product_id = data.configcat_products.main.products.0.product_id
  name_filter_regex = var.config
}

// Envs
data "configcat_environments" "main" {
  for_each = toset(var.ENVs)
  product_id = data.configcat_products.main.products.0.product_id
  name_filter_regex = each.key
}

// Feature flag
resource "configcat_setting" "main" {
  for_each = var.flags
  config_id = data.configcat_configs.main.configs.0.config_id
  key = each.key
  name = each.value.name
  setting_type = each.value.type

  lifecycle {
    create_before_destroy = false
  }
}

// Tags
resource "configcat_tag" "main" {
  for_each = toset(distinct(local.TAGS))
  product_id = data.configcat_products.main.products.0.product_id
  color = (var.tag_random_color == true ? random_shuffle.tag_color[each.key].result[0] : "canary")
  name = each.value

  lifecycle {
    create_before_destroy = false
    prevent_destroy = false
    ignore_changes = [
      color
    ]
  }
}

// Initialize the Feature Flag/Setting's value
resource "configcat_setting_value" "main" {
  for_each = local.FLAGS_X_ENVS
  init_only = true # Garante que o valor não será alterado após sua criação
  environment_id = data.configcat_environments.main[each.value.env].environments.0.environment_id
  setting_id = configcat_setting.main[each.value.flag].id
  mandatory_notes = "Pipeline changes from Terraform"
  value = each.value.value
}

// Apply Tag to Flag
resource "configcat_setting_tag" "main" {
  for_each = { for k, v in flatten([ for k_flag, v_flag in var.flags : [ for k_tag, v_tag in v_flag.tags : { setting = k_flag, tag = v_tag } ] ]) : "${v.setting}_${v.tag}" => v }
  depends_on = [
    configcat_tag.main
  ]
  setting_id = configcat_setting.main[each.value.setting].id
  tag_id = configcat_tag.main[each.value.tag].id
  lifecycle {
    create_before_destroy = false
  }
}