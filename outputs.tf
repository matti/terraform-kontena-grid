output "id" {
  value = "${null_resource.kontena_grid.id}-${null_resource.kontena_grid_unsetter.id}-${null_resource.kontena_grid_update.id}"
}
