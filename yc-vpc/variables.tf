variable "folder_id" {
  description = <<EOF
  (Optional) - The folder id in which the resources will be created, 
  if not specified, will be taken from `yandex_client_config`
  EOF

  type    = string
  default = null
}

variable "networks" {
  description = <<EOF
  Networks with subnets configuration.

  ---Important information---
  If you want to specify a user's network, 
  then specify its ID and not its name as the map() key.
  ---------------------------

  Placeholders explain where you should insert/come up with 
  your own values for resources, in this case for network and subnet names.
  Example: `<network-name>`

  `<network-name|exist-network-id>`: The name of the network to be created or the ID of an existing network
    `folder_id`: ID of the folder where the network will be hosted
    `user_net`: If you specify an already created network, that is, its identifier, then you must specify (true), 
                as if to say that this is a user network, for the networks that need to be created, use (false)
    `subnets` Block for subnets configuration
      `zone`: The availability zone where the subnet will be located
      `v4_cidr_blocks`: IPv4 CIDR blocks for this subnet
      `folder_id`: Id of the folder where the subnet will be located. If folder_id is specified for the network, 
                   the ID will be taken from there, otherwise from var.folder_id
      `public`: Whether this subnet is public, you can choose to create a NAT gateway for public networks.
      `labels`: Labels for this subnet. 

  EOF

  type = map(object({
    folder_id = optional(string)
    user_net  = bool
    subnets = optional(map(object({
      zone           = string
      v4_cidr_blocks = list(string)
      folder_id      = optional(string)
      public         = bool
      labels         = optional(map(string))
    })), null)
  }))
  default = null
}