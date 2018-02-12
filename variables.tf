variable "depends_id" {
  default = ""
}

variable "name" {}

variable "initial_size" {
  default = 1
}

variable "token" {
  default = ""
}

variable "subnet" {
  default = ""
}

variable "supernet" {
  default = ""
}

variable "default_affinities" {
  default = []
}

variable "statsd_server" {
  default = ""
}

variable "log_forwarder" {
  default = ""
}

variable "log_opts" {
  default = []
}
