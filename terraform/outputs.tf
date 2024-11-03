output "vpc_id" {
    value = module.vpc.vpc_id
}

output "ecs_alb_dns_addr" {
    value = module.ecs.alb_dns_addr
}

output "api_gateway_invoke_url" {
    value = module.api-gateway.api_gateway_invoke_url
}