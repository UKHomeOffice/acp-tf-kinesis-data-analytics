locals {
  namespaces = toset(split(".", replace(join(".", var.namespaces), "-", "_")))
  # replace hyphen with underscore for each string in var.namespaces
}