terraform {
  backend "s3" {
    bucket  = "beam-462068371076-eks-dev"
    key     = "beam-462068371076-dev.tfstate"
    region  = "eu-west-2"
    profile = "beam"
  }
}
