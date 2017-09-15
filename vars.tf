variable "region" {
  description = "The region in which to deploy the stack."
  default ="us-west-2"
}

variable "stack_name" {
  description = "The name of the stack to be deployed."
  # default ="docker-ce"
}

variable "key_name" {
  description = "The AWS Key Pair name to use."
  default ="aws_docker"
}
