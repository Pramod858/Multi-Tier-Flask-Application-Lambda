module "vpc" {
    source         = "./modules/vpc"

    environment    = var.environment
    region         = var.region
    container_port = var.container_port
    host_port      = var.host_port
}

module "iam" {
    source = "./modules/iam"

    environment = var.environment
    source_bucket = var.source_bucket
    target_bucket = var.target_bucket
}

module "rds" {
    source               = "./modules/rds"

    depends_on           = [ module.vpc ]
    environment          = var.environment
    region               = var.region 
    private_subnet_3_id  = module.vpc.private_subnet_3_id
    private_subnet_4_id  = module.vpc.private_subnet_4_id
    db_security_group_id = module.vpc.db_security_group_id

    db_name              = var.db_name
    db_username          = var.db_username
    db_password          = var.db_password
}

module "acm" {
    source             = "./modules/acm"
    depends_on         = [ module.vpc ]
    domain_name        = var.domain_name
    my_domain_name     = var.my_domain_name
    custom_domain_name = var.custom_domain_name
}

module "ecs" {
    source                    = "./modules/ecs"

    depends_on                = [ module.vpc, module.vpc, module.acm , module.api-gateway] 
    region                    = var.region
    environment               = var.environment
    vpc_id                    = module.vpc.vpc_id
    public_subnet_1_id        = module.vpc.public_subnet_1_id
    public_subnet_2_id        = module.vpc.public_subnet_2_id
    private_subnet_1_id       = module.vpc.private_subnet_1_id
    private_subnet_2_id       = module.vpc.private_subnet_2_id
    alb_security_group_id     = module.vpc.alb_security_group_id
    ecs_security_group_id     = module.vpc.ecs_security_group_id

    ecsTaskExecutionRole_arn  = module.iam.ecsTaskExecutionRole_arn
    ecsTaskRole_arn           = module.iam.ecsTaskRole_arn
    acm_certificate_arn       = module.acm.acm_certificate_arn
    container_port            = var.container_port
    host_port                 = var.host_port

    container_env_vars_config = <<EOF
        "environment" : [
            {"name": "MYSQL_HOST", "value": "${module.rds.db_endpoint}"},
            {"name": "MYSQL_USERNAME", "value": "${var.db_username}"},
            {"name": "MYSQL_PASSWORD", "value": "${var.db_password}"},
            {"name": "MYSQL_DATABASE", "value": "${var.db_name}"},
            {"name": "SOURCE_BUCKET", "value": "${var.source_bucket}"},
            {"name": "TARGET_BUCKET", "value": "${var.target_bucket}"},
            {"name": "API_GATEWAY_URL", "value": "${module.api-gateway.api_gateway_invoke_url}"}
        ],
    EOF
}

module "ec2" {
    source                     = "./modules/ec2"

    depends_on                 = [ module.vpc ]
    environment                = var.environment
    vpc_id                     = module.vpc.vpc_id
    public_subnet_1_id         = module.vpc.public_subnet_1_id
    public_subnet_2_id         = module.vpc.public_subnet_2_id
    bastion_security_group_id  = module.vpc.bastion_secuity_group_id
    key_name                   = var.key_name
}

module "route53" {
    source          = "./modules/route53"

    depends_on      = [ module.ecs, module.acm ]
    environment     = var.environment
    domain_name     = var.domain_name
    my_domain_name  = var.my_domain_name
    route53_zone_id = module.acm.route53_zone_id
    alb_dns_name    = module.ecs.alb_dns_addr
    alb_zone_id     = module.ecs.alb_zone_id 
}

module "lambda" {
    source                   = "./modules/lambda"

    depends_on               = [ module.iam ]
    environment              = var.environment
    lambda_function_role_arn = module.iam.lambda_function_role_arn
}

module "api-gateway" {
    source = "./modules/api-gateway"

    depends_on                 = [ module.lambda ]
    environment                = var.environment
    lambda_function_invoke_arn = module.lambda.lambda_function_invoke_arn
    lambda_function_name       = module.lambda.lambda_function_name
    acm_certificate_arn        = module.acm.custom_domain_cert_arn
    custom_domain_name         = var.custom_domain_name
}