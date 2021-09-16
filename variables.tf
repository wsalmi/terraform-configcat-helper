variable "product" {
  type = string
  description = "Product Name (Eg: My Product)"
  default = "Sandbox"
}

variable "config" {
  type = string
  description = "Config Name (Eg: Default)"
  default = "Default"
}

variable "ENVs" {
  type = list(string)
  description = "Enviroments List (Eg: [\"DEV\",\"UAT\",\"PRD\"])"
}

variable "flags" {
  type = map(object({
      name = string,
      type = string,
      tags = list(string),
      initial_values = map(any)
  }))

  default = {}

  validation {
      condition = alltrue([ for o in var.flags : contains(["boolean","string","int","double"], o.type) ])
      error_message = "Invalid flag type. Expected -> [boolean|string|int|double]."
  }

  validation {
      condition = alltrue([ for o in var.flags : length(o.name) > 4 ])
      error_message = "The length of flag name is less than 4 chars."
  }
}

variable "tag_random_color" {
  type = bool
  default = true
}