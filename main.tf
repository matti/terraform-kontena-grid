resource "null_resource" "start" {
  provisioner "local-exec" {
    command = "echo depends_id=${var.depends_id}"
  }
}

locals {
  default_affinities_or_none = "${length(var.default_affinities) == 0 ?
    ""
    :
    "${join(" ", formatlist("--default-affinity %s", var.default_affinities))}"
    }"
}

locals {
  log_opts_or_none = "${length(var.log_opts) == 0 ?
    ""
    :
    "${join(" ", formatlist("--log-opt %s", var.log_opts))}"
    }"
}

resource "null_resource" "kontena_grid" {
  depends_on = ["null_resource.start"]

  provisioner "local-exec" {
    command = <<EOF
kontena grid create \
  --initial-size ${var.initial_size} \
  ${var.token == "" ? "" : "--token ${var.token}"} \
  ${var.subnet == "" ? "" : "--subnet ${var.subnet}"} \
  ${var.supernet == "" ? "" : "--supernet ${var.supernet}"} \
  ${var.name}
EOF
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kontena grid rm --force ${var.name}"
  }
}

resource "null_resource" "kontena_grid_unsetter" {
  depends_on = ["null_resource.kontena_grid"]

  triggers = {
    log_forwarder      = "${var.log_forwarder}"
    log_opts_or_none   = "${local.log_opts_or_none}"
    default_affinities = "${local.default_affinities_or_none}"
    statsd_server      = "${var.statsd_server}"
  }

  provisioner "local-exec" {
    command = <<EOF
kontena grid update \
  --log-forwarder none \
  --no-default-affinity \
  --no-statsd-server \
  ${var.name}
EOF
  }
}

resource "null_resource" "kontena_grid_update" {
  depends_on = ["null_resource.kontena_grid_unsetter"]

  triggers = {
    log_forwarder      = "${var.log_forwarder}"
    log_opts_or_none   = "${local.log_opts_or_none}"
    default_affinities = "${local.default_affinities_or_none}"
    statsd_server      = "${var.statsd_server}"
  }

  provisioner "local-exec" {
    command = <<EOF
kontena grid update \
  ${local.default_affinities_or_none} \
  ${var.statsd_server == "" ? "" : "--statsd-server ${var.statsd_server}"} \
  ${var.log_forwarder == "" ? "" : "--log-forwarder ${var.log_forwarder}"} \
  ${local.log_opts_or_none} \
  ${var.name}
EOF
  }
}
