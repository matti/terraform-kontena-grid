resource "null_resource" "start" {
  provisioner "local-exec" {
    command = "echo depends_id=${var.depends_id}"
  }
}

locals {
  default_affinities = "${length(var.default_affinities) == 0 ?
    ""
    :
    "${join(" ", formatlist("--default-affinity %s", var.default_affinities))}"
    }"
}

locals {
  log_opts = "${length(var.log_opts) == 0 ?
    ""
    :
    "${join(" ", formatlist("--log-opt %s", var.log_opts))}"
    }"
}

resource "null_resource" "kontena_grid_create" {
  depends_on = ["null_resource.start"]

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
