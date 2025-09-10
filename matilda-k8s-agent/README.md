# K8s Agent Helm Chart

A Helm chart for deploying the Matilda Kubernetes Agent with secure configuration management and API integration.

**Chart Version:** 0.1.0  
**App Version:** 1.0.0

## Features

- **Secure Configuration**: Sensitive data stored in Kubernetes Secrets
- **API Integration**: Configurable API host and authentication
- **Asset Management**: Dynamic asset ID configuration
- **Security Hardened**: Non-root execution, read-only filesystem, dropped capabilities
- **Resource Management**: Configurable CPU and memory limits
- **RBAC Support**: Optional RBAC creation with read-only permissions
- **Namespace Management**: Automatic creation of matilda namespace

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- API access to Matilda Cloud platform

## Quick Start

### Basic Installation

```bash
# Add the Matilda Cloud Helm repository
helm repo add matilda https://matildacloud.github.io/helm-charts/
helm repo update

# Install with required parameters (namespace will be created automatically)
helm install k8s-agent ./k8s-agent \
  --set api_host=https://api.matildacloud.com \
  --set api_key=YOUR_API_KEY \
  --set id=YOUR_CLUSTER_ASSET_ID
```

### Using Values File

Create a `my-values.yaml` file:

```yaml
# my-values.yaml
api_host: "https://api.matildacloud.com"
api_key: "your-api-key-here"
id: "your-cluster-asset-id"

# Optional: Override namespace
namespace:
  create: true
  name: "matilda"

# Optional: Resource limits
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 256Mi

# Optional: Global configuration
global:
  imageRegistry: "your-registry.com"
  imagePullSecrets:
    - name: your-registry-secret

# Optional: Pod configuration
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
podLabels:
  environment: "production"

# Optional: Advanced configuration
nodeSelector:
  kubernetes.io/os: linux
tolerations:
  - key: "node-role.kubernetes.io/master"
    operator: "Exists"
    effect: "NoSchedule"
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/arch
          operator: In
          values:
          - amd64
```

Then install with:

```bash
helm install k8s-agent matilda/matilda-k8s-agent -f my-values.yaml
```

## Configuration

### Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `api_host` | API host URL for Matilda Cloud | `https://api.matildacloud.com` |
| `api_key` | API key for authentication | `abc123def456` |
| `id` | Cluster asset ID | `cluster-12345` |

### Optional Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace.create` | Create matilda namespace automatically | `true` |
| `namespace.name` | Namespace name (automatically set to matilda) | `matilda` |
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `docker.io/matilda1/matilda-k8s-agent` |
| `image.tag` | Container image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `rbac.create` | Create RBAC resources | `true` |
| `secret.create` | Create secret for sensitive data | `true` |
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.name` | Service account name | `""` (auto-generated) |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `configMap.create` | Create configmap | `false` |
| `configMap.name` | Configmap name | `""` (auto-generated) |

### Global Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global image registry | `""` |
| `global.imagePullSecrets` | Global image pull secrets | `[]` |

### Pod Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podAnnotations` | Pod annotations | `{}` |
| `podLabels` | Pod labels | `{}` |
| `podSecurityContext.fsGroup` | Pod security context fsGroup | `2000` |

### Advanced Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Pod tolerations | `[]` |
| `affinity` | Pod affinity | `{}` |
| `nameOverride` | Name override | `""` |
| `fullnameOverride` | Full name override | `""` |
| `extraLabels` | Additional labels for all resources | `{}` |
| `extraAnnotations` | Additional annotations for all resources | `{}` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |

### Security Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `securityContext.runAsNonRoot` | Run as non-root user | `true` |
| `securityContext.runAsUser` | User ID to run as | `1000` |
| `securityContext.readOnlyRootFilesystem` | Read-only root filesystem | `true` |
| `securityContext.capabilities.drop` | Drop capabilities | `["ALL"]` |

## Security Features

### Secrets Management
- API key and cluster asset ID stored in Kubernetes Secrets
- Sensitive data encrypted at rest
- No hardcoded credentials in deployment manifests

### Pod Security
- Non-root user execution (UID 1000)
- Read-only root filesystem
- Dropped capabilities (no privileged access)
- No privilege escalation allowed

### RBAC
- Optional RBAC creation with read-only permissions
- Service account with minimal required permissions
- Cluster-wide read access for discovery

## Environment Variables

The agent receives the following environment variables:

### API Configuration
- `API_HOST`: API host URL (from values)
- `API_KEY`: API key (from Secret)
- `CLUSTER_ASSET_ID`: Cluster asset ID (from Secret)

## Monitoring

### Resource Monitoring
- CPU and memory usage tracking
- Configurable resource limits and requests
- Horizontal Pod Autoscaler support (optional)

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -l app.kubernetes.io/name=k8s-agent -n matilda
```

### View Logs
```bash
kubectl logs -f deployment/k8s-agent -n matilda
```

### Check Configuration
```bash
# Verify Secret
kubectl get secret k8s-agent -n matilda -o yaml

# Verify Service
kubectl get svc k8s-agent -n matilda

# Verify RBAC
kubectl get clusterrole k8s-agent-clusterrole
kubectl get clusterrolebinding k8s-agent-clusterrolebinding

# Verify Namespace
kubectl get namespace matilda
```

### Common Issues

1. **Missing required parameters**
   ```bash
   # Check if all required values are set
   helm get values k8s-agent -n matilda
   ```

2. **Pod not starting**
   ```bash
   # Check pod events
   kubectl describe pod -l app.kubernetes.io/name=k8s-agent -n matilda
   ```

3. **API connection issues**
   - Verify API host URL is correct and accessible
   - Check API key is valid
   - Ensure network connectivity from cluster to API

4. **Permission issues**
   ```bash
   # Check service account permissions
   kubectl auth can-i get pods --as=system:serviceaccount:matilda:k8s-agent
   ```

## Advanced Configuration

### Custom Image Registry

```yaml
# Using global configuration (recommended)
global:
  imageRegistry: "your-registry.com"
  imagePullSecrets:
    - name: your-registry-secret

# Or using individual image configuration
image:
  repository: your-registry.com/matilda-k8s-agent
  tag: "v1.0.0"
  pullPolicy: Always

imagePullSecrets:
  - name: your-registry-secret
```

### Custom Resource Limits

```yaml
resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

### Custom Security Context

```yaml
securityContext:
  runAsUser: 2000
  runAsGroup: 2000
  fsGroup: 2000
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
```

## Uninstallation

```bash
helm uninstall k8s-agent
```

To also remove the namespace:

```bash
kubectl delete namespace matilda
```

## Contributing

1. Fork the [Matilda Cloud Helm Charts](https://github.com/matildacloud/helm-charts) repository
2. Create a feature branch
3. Make your changes
4. Test the chart
5. Submit a pull request

## License

This project is licensed under the MIT License.
