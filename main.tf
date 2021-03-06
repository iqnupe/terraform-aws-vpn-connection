locals {
  enabled = module.this.enabled
}

# https://www.terraform.io/docs/providers/aws/r/vpn_gateway.html
resource "aws_vpn_gateway" "default" {
  provider        = aws3
  count           = local.enabled ? 1 : 0
  vpc_id          = var.vpc_id
  amazon_side_asn = var.vpn_gateway_amazon_side_asn
  tags            = module.this.tags
}

# https://www.terraform.io/docs/providers/aws/r/customer_gateway.html
resource "aws_customer_gateway" "default" {
  provider   = aws3
  count      = local.enabled ? 1 : 0
  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.customer_gateway_ip_address
  type       = "ipsec.1"
  tags       = module.this.tags
}

# https://www.terraform.io/docs/providers/aws/r/vpn_connection.html
resource "aws_vpn_connection" "default" {
  provider                             = aws3
  count                                = local.enabled ? 1 : 0
  vpn_gateway_id                       = join("", aws_vpn_gateway.default.*.id)
  customer_gateway_id                  = join("", aws_customer_gateway.default.*.id)
  type                                 = "ipsec.1"
  static_routes_only                   = var.vpn_connection_static_routes_only
  tunnel1_inside_cidr                  = var.vpn_connection_tunnel1_inside_cidr
  tunnel1_preshared_key                = var.vpn_connection_tunnel1_preshared_key
  tunnel1_ike_versions                 = ["ikev1", "ikev2"]
  tunnel1_phase1_dh_group_numbers      = [2, 14, 15, 16, 17, 18, 22, 23, 24]
  tunnel1_phase1_encryption_algorithms = ["AES128", "AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA1", "SHA2-256"]
  tunnel1_phase2_dh_group_numbers      = [2, 5, 14, 15, 16, 17, 18, 22, 23, 24]
  tunnel1_phase2_encryption_algorithms = ["AES128", "AES256"]
  tunnel1_phase2_integrity_algorithms  = ["SHA1", "SHA2-256"]
  tunnel2_inside_cidr                  = var.vpn_connection_tunnel2_inside_cidr
  tunnel2_preshared_key                = var.vpn_connection_tunnel2_preshared_key
  tunnel2_ike_versions                 = ["ikev1", "ikev2"]
  tunnel2_phase1_dh_group_numbers      = [2, 14, 15, 16, 17, 18, 22, 23, 24]
  tunnel2_phase1_encryption_algorithms = ["AES128", "AES256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA1", "SHA2-256"]
  tunnel2_phase2_dh_group_numbers      = [2, 5, 14, 15, 16, 17, 18, 22, 23, 24]
  tunnel2_phase2_encryption_algorithms = ["AES128", "AES256"]
  tunnel2_phase2_integrity_algorithms  = ["SHA1", "SHA2-256"]
  tags                                 = module.this.tags
}

# https://www.terraform.io/docs/providers/aws/r/vpn_gateway_route_propagation.html
resource "aws_vpn_gateway_route_propagation" "default" {
  count          = local.enabled ? length(var.route_table_ids) : 0
  vpn_gateway_id = join("", aws_vpn_gateway.default.*.id)
  route_table_id = element(var.route_table_ids, count.index)
}

# https://www.terraform.io/docs/providers/aws/r/vpn_connection_route.html
resource "aws_vpn_connection_route" "default" {
  count                  = local.enabled && var.vpn_connection_static_routes_only == "true" ? length(var.vpn_connection_static_routes_destinations) : 0
  vpn_connection_id      = join("", aws_vpn_connection.default.*.id)
  destination_cidr_block = element(var.vpn_connection_static_routes_destinations, count.index)
}
