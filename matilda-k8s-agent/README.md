# K8s Agent Helm Chart

A Helm chart for deploying the Matilda Kubernetes Agent with secure configuration management, API integration, and network monitoring capabilities.

**Chart Version:** 0.4.1  
**App Version:** v2

## Features

- **Dual Deployment**: Main agent deployment + network monitoring daemonset
- **Secure Configuration**: Sensitive data stored in Kubernetes Secrets
- **API Integration**: Configurable API host and authentication
- **Asset Management**: Dynamic asset ID configuration
- **Network Monitoring**: DaemonSet for comprehensive network packet analysis
- **Security Hardened**: Non-root execution, read-only filesystem, dropped capabilities
- **Resource Management**: Configurable CPU and memory limits
- **RBAC Support**: Optional RBAC creation with read-only permissions
- **Namespace Management**: Automatic creation of matilda namespace
- **Host Network Support**: Optional host networking for enhanced monitoring capabilities

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
helm install matilda-k8s-agent matilda/matilda-k8s-agent \
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
helm install matilda-k8s-agent matilda/matilda-k8s-agent \
  --namespace matilda \
  --create-namespace \
  -f my-values.yaml
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
| `image.repository` | Main agent container image repository | `docker.io/matilda1/matilda-k8s-agent` |
| `image.tag` | Main agent container image tag | `v2` |
| `image.pullPolicy` | Main agent image pull policy | `IfNotPresent` |
| `image.daemonset.repository` | Network agent daemonset image repository | `docker.io/matilda1/matilda-k8s-network` |
| `image.daemonset.tag` | Network agent daemonset image tag | `v2` |
| `image.daemonset.pullPolicy` | Network agent daemonset image pull policy | `IfNotPresent` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `rbac.create` | Create RBAC resources | `true` |
| `secret.create` | Create secret for sensitive data | `true` |
| `network.hostNetwork` | Use host network for the pod | `true` |
| `network.dnsPolicy` | DNS policy when using host network | `ClusterFirstWithHostNet` |
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

## Deployment Architecture

This chart deploys two components:

### 1. Main Agent Deployment
- **Purpose**: Primary Kubernetes agent for cluster monitoring and management
- **Type**: Deployment with configurable replicas
- **Image**: `docker.io/matilda1/matilda-k8s-agent:v2`
- **Port**: 8080 (configurable)

### 2. Network Monitoring DaemonSet
- **Purpose**: Network packet analysis and monitoring on all nodes
- **Type**: DaemonSet (runs on every node)
- **Image**: `docker.io/matilda1/matilda-k8s-network:v2`
- **Port**: 9184 (metrics endpoint)
- **Privileged**: Runs with privileged access for network monitoring

## Network Configuration

The agent uses host networking by default, which provides several benefits:

### Host Network Benefits
- **Direct Node Access**: Agent can access node-level resources and metrics
- **Simplified Networking**: Bypasses Kubernetes network policies for monitoring
- **Better Performance**: Reduced network overhead for data collection
- **Node Discovery**: Can discover and monitor all nodes in the cluster
- **Network Monitoring**: DaemonSet can capture packets from node network interfaces

### Configuration Options
```yaml
network:
  hostNetwork: true                    # Use host network (recommended)
  dnsPolicy: ClusterFirstWithHostNet  # DNS resolution policy

# DaemonSet specific configuration
image:
  daemonset:
    repository: docker.io/matilda1/matilda-k8s-network
    tag: v2
    pullPolicy: IfNotPresent
```

### Security Considerations
- **Privileged Access**: Host network provides broader access to node resources
- **DaemonSet Privileges**: Network monitoring daemonset requires privileged access
- **RBAC Required**: Ensure proper RBAC permissions are configured
- **Network Policies**: May bypass some Kubernetes network policies

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
# Check main agent deployment
kubectl get pods -l app.kubernetes.io/name=matilda-k8s-agent -n matilda-k8s-agent

# Check network monitoring daemonset
kubectl get pods -l app.kubernetes.io/component=network-agent -n matilda-k8s-agent

# Check all pods
kubectl get pods -n matilda-k8s-agent
```

### View Logs
```bash
# Main agent logs
kubectl logs -f deployment/matilda-k8s-agent -n matilda-k8s-agent

# Network agent daemonset logs (on specific node)
kubectl logs -f daemonset/matilda-k8s-agent-network-agent -n matilda-k8s-agent

# All network agent pods logs
kubectl logs -f -l app.kubernetes.io/component=network-agent -n matilda-k8s-agent
```

### Check Configuration
```bash
# Verify Secret
kubectl get secret matilda-k8s-agent -n matilda-k8s-agent -o yaml

# Verify Service
kubectl get svc matilda-k8s-agent -n matilda-k8s-agent

# Verify RBAC
kubectl get clusterrole matilda-k8s-agent-clusterrole
kubectl get clusterrolebinding matilda-k8s-agent-clusterrolebinding

# Verify Namespace
kubectl get namespace matilda-k8s-agent
```

### Common Issues

1. **Missing required parameters**
   ```bash
   # Check if all required values are set
   helm get values matilda-k8s-agent -n matilda
   ```

2. **Pod not starting**
   ```bash
   # Check pod events
   kubectl describe pod -l app.kubernetes.io/name=matilda-k8s-agent -n matilda-k8s-agent
   ```

3. **API connection issues**
   - Verify API host URL is correct and accessible
   - Check API key is valid
   - Ensure network connectivity from cluster to API

4. **Permission issues**
   ```bash
   # Check service account permissions
   kubectl auth can-i get pods --as=system:serviceaccount:matilda-k8s-agent:matilda-k8s-agent
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
helm uninstall matilda-k8s-agent
```

To also remove the namespace:

```bash
kubectl delete namespace matilda-k8s-agent
```

## Contributing

1. Fork the [Matilda Cloud Helm Charts](https://github.com/matildacloud/helm-charts) repository
2. Create a feature branch
3. Make your changes
4. Test the chart
5. Submit a pull request

## License

This project is licensed under the MIT License.
