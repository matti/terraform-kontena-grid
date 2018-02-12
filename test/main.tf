module "grid" {
  source = ".."

  name = "test"

  default_affinities = [
    "node=first",
    "node!=second",
  ]

  log_opts = [
    "fluentd-address=myfluentd:9999",
  ]

  log_forwarder = "fluentd"
}
