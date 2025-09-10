
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
A Helm chart for deploying the Matilda Kubernetes Agent with secure configuration management and API integration.

**Features:**
- Secure Configuration: Sensitive data stored in Kubernetes Secrets
- API Integration: Configurable API host and authentication
- Asset Management: Dynamic asset ID configuration
- Security Hardened: Non-root execution, read-only filesystem, dropped capabilities
- Resource Management: Configurable CPU and memory limits
- RBAC Support: Optional RBAC creation with read-only permissions
- Namespace Management: Automatic creation of matilda namespace

**Quick Start:**
```bash
# Install with required parameters (namespace will be created automatically)
helm install matilda-k8s-agent matilda/matilda-k8s-agent \
  --set api_host=https://api.matildacloud.com \
  --set api_key=YOUR_API_KEY \
  --set id=YOUR_CLUSTER_ASSET_ID
```

**Basic Installation:**
```bash
helm install matilda-k8s-agent matilda/matilda-k8s-agent
```

