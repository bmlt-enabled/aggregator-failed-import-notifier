variable "slack_webhook" {
  type    = string
  default = ""
}

variable "tomato_cluster" {
  type    = string
  default = "arn:aws:ecs:us-east-1:766033189774:cluster/tomato"
}
