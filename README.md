
## Install Charts from the Repository

```bash
helm repo add matilda https://matildacloud.github.io/helm-charts/
helm repo update
helm search repo matilda

To install thanos
helm install thanos-release matilda/matilda-thanos
To install prometheus
helm install prometheus-release matilda/prometheus
```

