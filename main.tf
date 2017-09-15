# Configure the Amazon Web Service Provider
provider "aws" {
  region  = "${var.region}"
}

data "template_file" "url_format" {
  template = "${file("url.tpl")}"
  vars {
    cloud_provider = "aws"
  }
}

data "http" "aws_template" {
  url = "${data.template_file.url_format.rendered}"
}

data "template_file" "aws-cloudformation" {
	#template = "${file("${path.module}/aws/Docker.tmpl")}"
  template = "${http.aws_template.body}"
}
data "template_file" "azure-arm" {
  # template = "${file("https://editions-stage-us-east-1-150610-005505.s3.amazonaws.com/azure/test/304bf7e8c50ef496298d1e035348c8b25a08c643/19/Docker.tmpl")}"
	template = "${file("${path.module}/azure/Docker.tmpl")}"
}

resource "aws_cloudformation_stack" "d4aws" {
  name = "${var.stack_name}"
	capabilities = ["CAPABILITY_IAM"]

  parameters {
    KeyName           = "aws_docker"
  }

  template_body = "${data.template_file.aws-cloudformation.rendered}"
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "..."
  client_id       = "..."
  client_secret   = "..."
  tenant_id       = "..."
}

resource "azurerm_resource_group" "d4azure" {
  name     = "${var.stack_name}"
  location = "South Central US"
}

resource "azurerm_template_deployment" "d4azure" {
  name                = "acctesttemplate-01"
  resource_group_name = "${azurerm_resource_group.d4azure.name}"

  template_body = "${data.template_file.azure-cloudformation.rendered}"
  deployment_mode = "Incremental"
}

output "storageAccountName" {
  value = "${azurerm_template_deployment.test.outputs["storageAccountName"]}"
}