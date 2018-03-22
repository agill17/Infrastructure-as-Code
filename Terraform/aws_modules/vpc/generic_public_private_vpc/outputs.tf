output "general" {
  value = [
    "ENV   =   ${var.env}",
    "APP   =   ${var.app_name}",
  ]
}

output "vpc" {
  value = [
    "ID    =   ${aws_vpc.vpc.id}",
    "IGW_ID =  ${aws_internet_gateway.igw.id}",
  ]
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "sg_id" {
  value = "${aws_security_group.sg.id}"
}

output "public_route_tables" {
  value = [
    "${join("   |    ", aws_route_table.public_rt.*.id)} ",
  ]
}

output "private_route_tables" {
  value = [
    "${join("   |    ", aws_route_table.nat_private_rt.*.id)} ",
  ]
}

output "public_subnets" {
  value = [
    "${join("   |    ", aws_subnet.subnet_public.*.id)} ",
    "${join("       |    ", aws_subnet.subnet_public.*.cidr_block)}",
    "${join("        |    ", aws_subnet.subnet_public.*.availability_zone)}",
  ]
}

output "public_subnet_ids" {
  value = "${aws_subnet.subnet_public.*.id}"
}

output "private_subnet_ids" {
  value = "${aws_subnet.subnet_private.*.id}"
}


output "private_subnets" {
  value = [
    "${join("   |    ", aws_subnet.subnet_private.*.id)} ",
    "${join("       |    ", aws_subnet.subnet_private.*.cidr_block)}",
    "${join("        |    ", aws_subnet.subnet_private.*.availability_zone)}",
  ]
}
