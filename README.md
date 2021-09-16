# ConfigCat Helper

Hello, I created this helper to speed up and facilitate the control of feature flags in ConfigCat.
Its construction is very complex and verbose, which makes us avoid using it.


# How to use? 🤔

Easy peasy lemon squeezy!!

```hcl
terraform {
	required_version  =  ">= 0.12"
	required_providers {
		configcat  =  {
			source = "configcat/configcat"
			version = "~> 1.0"
		}
	}
}

variable  "configcat_username" {
	type  =  string
	sensitive  =  false
}

variable  "configcat_password" {
	type  =  string
	sensitive  =  true
}	 

provider  "configcat" {
	// Get your ConfigCat Public API credentials at https://app.configcat.com/my-account/public-api-credentials
	basic_auth_username  =  var.configcat_username
	basic_auth_password  =  var.configcat_password
}

module  "product_default" {
	source  =  "wsalmi/helper/configcat"

	providers  =  { configcat = configcat }
	product =  "My Product Name"
	config =  "Default"
	ENVs = ["DEV", "HML", "PRD"]

	flags =  {
		example_bool =  { name = "Teste Boolean", type = "boolean", values = { DEV = true, HML = false, PRD = false }, tags =  ["My Flag 1", "My Flag 2"] }
		example_string =  { name = "Teste String", type = "string", values = { DEV = "dev", HML = "UAT", PRD = "Production" }, tags =  ["My Flag 2"] }
		example_int =  { name = "Teste Int", type = "int", values = { DEV = 1, HML = 2, PRD = 3 }, tags =  [] }
		example_double =  { name = "Teste Double", type = "double", values = { DEV = 1.2, HML = 2.2, PRD = 3.0 }, tags =  [] }
	}
}
```
