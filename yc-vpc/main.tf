data "yandex_client_config" "client" {}

locals {
  folder_id = var.folder_id != null ? var.folder_id : data.yandex_client_config.client.folder_id
}

resource "yandex_vpc_network" "network" {

  for_each = var.networks != null ? {
    for net_key, net in var.networks : net_key => {
      folder_id = net.folder_id
    } if net.user_net != true
  } : {}

  name = each.key
  folder_id = each.value.folder_id
}

resource "yandex_vpc_subnet" "subnets" {

  for_each = var.networks != null ? tomap({
    for subnet in flatten([
      for net_key, net in var.networks : [ try(net.subnets, null) != null ?
        [ for sub_key, sub in net.subnets : {
          network          = net_key
          subnet_name      = sub_key
          zone             = sub.zone
          network_id       = net.user_net ? net_key : yandex_vpc_network.network[net_key].id
          v4_cidr_blocks   = sub.v4_cidr_blocks
          subnet_is_public = sub.public
          folder_id        = lookup(net, "folder_id", lookup(sub, "folder_id", local.folder_id))
          labels           = sub.labels
        } ] : [] ]
    ]) : "${subnet.network}.${subnet.subnet_name}" => subnet
  }) : {}

  name           = "${each.value.subnet_name}-${substr(each.value.zone, -1, 0)}"
  zone           = each.value.zone
  v4_cidr_blocks = each.value.v4_cidr_blocks
  network_id     = each.value.network_id
  folder_id      = each.value.folder_id
  labels = each.value.labels
}