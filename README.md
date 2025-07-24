
## Install Charts from the Repository

```bash
helm repo add matilda https://matildacloud.github.io/helm-charts/
helm repo update
helm search repo matilda
```

## Available Charts

### matilda-k8s-svc
A Helm chart for creating a Kubernetes service account with read-only permissions and generating kubeconfig.

```bash
helm install matilda-sa matilda/matilda-k8s-svc
```

### matilda-thanos
A Helm chart for deploying Thanos components on Kubernetes.

```bash
helm install thanos-release matilda/matilda-thanos
```

### matilda-prometheus
A Helm chart for Prometheus monitoring stack.

```bash
helm install prometheus-release matilda/prometheus
```

### matilda-k8s-agent
A Helm chart for Kubernetes agent.

```bash
helm install agent-release matilda/matilda-k8s-agent
```

