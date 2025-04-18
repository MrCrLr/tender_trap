# This tag block will be reused across resources using a local variable
locals {
  common_tags = {
    Project     = "tender-trap"
    Environment = "research"
    Owner       = "chance.basin"
    ManagedBy   = "terraform"
  }
}