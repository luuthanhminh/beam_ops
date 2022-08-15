# DevOps

Folder structure
```
.
├── README.md
├── charts
│   ├── mixer-nginx
│   ├── react-app
│   └── server-api
├── cicd
│   └── argocd
├── docs
│   ├── core_concepts.md
│   ├── get_started.md
│   ├── images
│   └── infrastructure.md
├── manual-operator
│  ├── argocd-ingress.yaml
│  ├── grafana-ingress.yaml
│  ├── grafana.yaml
│  ├── nginx-ingress-controller.yaml
│  ├── rancher-ingress.yaml
│  ├── rancher.md
│  └── sealed-secrets-controller.yaml
├── scripts
└── terraform
    ├── modules
    └── ...
```

## Charts
```
├── charts
│   ├── mixer-nginx
│   ├── react-app
│   └── server-api
```
Contains helm charts material for 3 applications which is using in Gitops flow to deploy applications to EKS

## CI/CD

```
├── cicd
│   └── argocd
```
Contains SealedSecret which can be used in Argocd to configure the credential for Git repositories

## Mannual Operators

```
├── manual-operator
│  ├── argocd-ingress.yaml
│  ├── grafana-ingress.yaml
│  ├── grafana.yaml
│  ├── nginx-ingress-controller.yaml
│  ├── rancher-ingress.yaml
│  ├── rancher.md
│  └── sealed-secrets-controller.yaml
```

Contains manual resources which is need to be deloyed in EKS such as dashboard, ingress for add-on...

## Terraform

```
└── terraform
    ├── modules
    └── ...
```
Using to build EKS infrastructure