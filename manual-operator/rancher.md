# Deploy rancher

## Add the Helm Chart Repository

```shell
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
```

## Create a Namespace for Rancher

```shell
kubectl create namespace cattle-system
```

## Install Rancher with Helm 

[Terminate SSL/TLS externally](https://rancher.com/docs/rancher/v2.5/en/installation/install-rancher-on-k8s/chart-options/#external-tls-termination)

```shell
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.beam.to \
  --set replicas=3 \
  --set tls=external
```