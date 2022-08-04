module "vpc_module" {
  source                    = "./vpc"
  vpc_cidr_block            = "10.0.0.0/16"
  private_subnets_cidr_list = ["10.0.2.0/24", "10.0.3.0/24"]
  public_subnets_cidr_list  = ["10.0.5.0/24", "10.0.6.0/24"]
}
