# Getting Started

This getting started guide will help to deploy the system

## Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
4. [helm](https://helm.sh/docs/helm/helm_install/)

## Deployment Steps


### Run Terraform INIT

CD into the terraform directory.

```shell script
cd terraform
```

Initialize the working directory with configuration files.

```shell script
terraform init
```

### Run Terraform PLAN

Verify the resources that will be created by this execution.

```shell script
terraform plan
```

### Finally, Terraform APPLY

Deploy your EKS environment.

```shell script
terraform apply
```

### Configure kubectl and test cluster

Details for your EKS Cluster can be extracted from terraform output or from AWS Console to get the name of cluster.

This following command used to update the `kubeconfig` in your local machine where you run `kubectl` commands to interact with your EKS Cluster.

```
$ aws eks --region <region> update-kubeconfig --name <cluster-name>
```

## Validation

### List all the worker nodes by running the command below

```
$ kubectl get nodes
```

### List all the pods running in kube-system namespace

```
$ kubectl get pods -n kube-system
```

## Deploy shared manifests

### Nginx Ingress Controler (Terminating TLS in the Load Balancer)

Create SSL from Cloudflare and import to AWS ACM

CD into the manual-operator directory.

```shell script
cd manual-operator
```

Change the VPC CIDR in `nginx-ingress-controller.yaml`

```
proxy-real-ip-cidr: XXX.XXX.XXX/XX
```

Change the AWS Certificate Manager (ACM) ID in `nginx-ingress-controller.yaml`

```
arn:aws:acm:us-west-2:XXXXXXXX:certificate/XXXXXX-XXXXXXX-XXXXXXX-XXXXXXXX
```

Deploy the manifest

```
$ kubectl apply -f nginx-ingress-controller.yaml
```

### EFS peristent volume claim

CD into the manual-operator directory.

```shell script
cd manual-operator
```

Deploy the manifest

```
$ kubectl apply -f beam-efs-pvc.yaml
```

### Ingress with AWS NLB


CD into the manual-operator directory.

```shell script
cd manual-operator
```

Deploy the manifest

```
$ kubectl apply -f beam-ingress.yaml
```

## Deploy applications

### Frontend (react-app)

CD into the charts/react-app directory.

```shell script
cd charts
```

Change the repository in `values.yaml` to the ECR repository

```
repository: 462068371076.dkr.ecr.eu-west-2.amazonaws.com/beam/react-app
```

Change the tag in `values.yaml` to the version of image to deploy

```
tag: "demo-9"
```

Change the nodeSelector in `values.yaml` to app node group

```
nodeSelector:
  zone-a

Validate the template

```shell script
helm template .
```

Deploy a helm release

`helm install <name-of-release> . -n <namespace>`

```shell script
helm install react-app . -n services
```

### Backend (server-api)

CD into the charts/server-api directory.

```shell script
cd server-api
```

Change the repository in `values.yaml` to the ECR repository

```
repository: 462068371076.dkr.ecr.eu-west-2.amazonaws.com/beam/server-api
```

Change the tag in `values.yaml` to the version of image to deploy

```
tag: "demo-9"
```

Change the nodeSelector in `values.yaml` to app node group

```
nodeSelector:
  zone-app: 'true'
```

Validate the template

```shell script
helm template .
```

Deploy a helm release

`helm install <name-of-release> . -n <namespace>`

```shell script
helm install server-api . -n services
```

### Storage server (mixer-nginx)

CD into the charts/mixer-nginx directory.

```shell script
cd mixer-nginx
```

Change the nodeSelector in `values.yaml` to app node group

```
nodeSelector:
  zone-app: 'true'
```

Validate the template

```shell script
helm template .
```

Deploy a helm release

`helm install <name-of-release> . -n <namespace>`

```shell script
helm install mixer-nginx . -n services
```
