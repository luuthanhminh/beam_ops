# Core Concepts

This repository uses to manage all things related to CI/CD, infrastructure as code, kubeneters.

## Terraform
We use terraform to provision the infrastructure on AWS and Kubenetes addons at deploy time.

### AWS resources

| Name | Description |
|------|--------|
| VPC | Provide network for the system |
| EKS | Kubenetes cluster |
| EC2 | Worker node to handle workload in K8s |
| Auto Scalling Group | Managed and scale woker nodes in a node group |

### K8s addons

| Name | Description |
|------|--------|
| aws_efs | provisioning persistent volume using AWS EFS  |
| aws_ebs | provisioning persistent volume using AWS EBS  |
| prometheus | monitoring resources on EKS |
| grafana | visualization dashboard to analytics & monitoring, |
| ingress-nginx | revert proxy and routing tracfic in K8s |

## Helm

Package the application to single chart and deploy to k8s

## Jenkins

CI/CD server to build application images and deploy application into k8s cluster


