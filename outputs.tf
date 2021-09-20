output "flags" {
  value = configcat_setting.main
  description = "All flags registered inside module"
}

output "flags_values" {
  value = configcat_setting_value.main
  description = "All flags values"
}

output "tags" {
  value = configcat_tag.main
  description = "All tags registered inside module"
}