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

locals {
  default_affinities = "${length(var.default_affinities) == 0 ?
    ""
    :
    "${join(" ", formatlist("--default-affinity %s", var.default_affinities))}"
    }"
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

locals {
  log_opts = "${length(var.log_opts) == 0 ?
    ""
    :
    "${join(" ", formatlist("--log-opt %s", var.log_opts))}"
    }"
}

resource "null_resource" "kontena_grid_create" {
  provisioner "local-exec" {
    command = <<EOF
kontena grid create \
  --initial-size ${var.initial_size} \
  ${var.token == "" ? "" : "--token ${var.token}"} \
  ${var.subnet == "" ? "" : "--subnet ${var.subnet}"} \
  ${var.supernet == "" ? "" : "--supernet ${var.supernet}"} \
  ${local.default_affinities} \
  ${var.statsd_server == "" ? "" : "--statsd-server ${var.statsd_server}"} \
  ${var.log_forwarder == "" ? "" : "--log-forwarder ${var.log_forwarder}"} \
  ${local.log_opts} \
  ${var.name}
EOF
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kontena grid rm --force ${var.name}"
  }
}
