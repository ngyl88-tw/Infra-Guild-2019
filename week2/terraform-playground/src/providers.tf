provider "aws" {
  region  = "ap-southeast-1"
  version = "~> 2.35"
}

provider "tls" {
  version = "~> 2.1"
}
