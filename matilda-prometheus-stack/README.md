# Matilda Prometheus Stack

A comprehensive monitoring solution for Kubernetes clusters, providing Prometheus, AlertManager, and supporting components with Matilda Cloud integration.

## Overview

The Matilda Prometheus Stack is a Helm chart that deploys a complete monitoring stack including:

- **Prometheus Server**: Metrics collection and storage
- **AlertManager**: Alert handling and routing
- **Kube State Metrics**: Kubernetes cluster state metrics
- **Node Exporter**: Node-level metrics
- **Pushgateway**: Metrics push endpoint

## Features

- **Matilda Cloud Integration**: Automatic remote write to Matilda Cloud
- **Production Ready**: Resource limits, security contexts, and persistent storage
- **Highly Configurable**: Extensive customization options
- **RBAC Support**: Proper Kubernetes RBAC configuration
- **Multi-Component**: Complete monitoring stack in one chart

## Prerequisites

- Kubernetes 1.19+
- Helm 3.7+
- Cluster admin permissions for RBAC resources
- Persistent volume support (for data retention)

## Installation

### From Matilda Helm Repository

```bash
# Add the Matilda Cloud Helm repository
helm repo add matilda https://matildacloud.github.io/helm-charts/
helm repo update

# Install the chart
helm install matilda-prometheus matilda/matilda-prometheus-stack

# Or install with a custom release name
helm install my-monitoring matilda/matilda-prometheus-stack
```

### Local Installation

```bash
# Install from local chart directory
helm install matilda-prometheus ./

# Or install with a custom release name
helm install my-monitoring ./
```

### Custom Configuration

```bash
# Create a custom values file
cat > custom-values.yaml << EOF
matilda:
  clusterId: "my-cluster"
  endpoint: "https://my-matilda-endpoint.com/api/v1/receive"

server:
  persistentVolume:
    size: 100Gi
  resources:
    limits:
      memory: 4Gi
      cpu: 2000m

alertmanager:
  enabled: true
  persistentVolume:
    size: 20Gi
EOF

# Install with custom values
helm install matilda-prometheus matilda/matilda-prometheus-stack -f custom-values.yaml
```

## Configuration

### Matilda Cloud Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `matilda.enabled` | Enable Matilda Cloud integration | `true` |
| `matilda.clusterId` | Cluster identifier for Matilda Cloud | `optimize-global` |
| `matilda.endpoint` | Matilda Cloud remote write endpoint | `http://3.133.88.149:30003/api/v1/receive` |

### Prometheus Server Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `server.enabled` | Enable Prometheus server | `true` |
| `server.image.repository` | Prometheus image repository | `prom/prometheus` |
| `server.image.tag` | Prometheus image tag | `v3.3.1` |
| `server.persistentVolume.enabled` | Enable persistent volume | `true` |
| `server.persistentVolume.size` | Persistent volume size | `50Gi` |
| `server.resources.limits.memory` | Memory limit | `2Gi` |
| `server.resources.limits.cpu` | CPU limit | `1000m` |

### AlertManager Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `alertmanager.enabled` | Enable AlertManager | `true` |
| `alertmanager.image.repository` | AlertManager image repository | `prom/alertmanager` |
| `alertmanager.image.tag` | AlertManager image tag | `v0.27.0` |
| `alertmanager.persistentVolume.enabled` | Enable persistent volume | `true` |
| `alertmanager.persistentVolume.size` | Persistent volume size | `10Gi` |

### Component Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `kube-state-metrics.enabled` | Enable kube-state-metrics | `true` |
| `prometheus-node-exporter.enabled` | Enable node exporter | `true` |
| `prometheus-pushgateway.enabled` | Enable pushgateway | `true` |

## Usage

### Accessing Prometheus

After installation, Prometheus will be available via port-forward:

```bash
# Port forward to Prometheus server
kubectl port-forward svc/matilda-prometheus-server 9090:80

# Access Prometheus UI
open http://localhost:9090
```

### Accessing AlertManager

```bash
# Port forward to AlertManager
kubectl port-forward svc/matilda-prometheus-alertmanager 9093:80

# Access AlertManager UI
open http://localhost:9093
```

### Viewing Metrics

```bash
# Check Prometheus targets
kubectl exec -it deployment/matilda-prometheus-server -- promtool query targets

# Check Prometheus configuration
kubectl exec -it deployment/matilda-prometheus-server -- promtool query config

# View Prometheus logs
kubectl logs deployment/matilda-prometheus-server
```

### Matilda Cloud Integration

The chart automatically configures Prometheus to send metrics to Matilda Cloud:

- **Remote Write**: Configured to send all metrics to Matilda Cloud
- **External Labels**: Includes cluster ID and environment labels
- **Retention**: Local retention configured for backup purposes

## Monitoring Components

### Prometheus Server
- Collects metrics from all configured targets
- Stores time-series data locally
- Forwards metrics to Matilda Cloud via remote write
- Provides web UI for querying metrics

### AlertManager
- Handles alerts from Prometheus
- Routes alerts based on configuration
- Supports multiple notification channels
- Provides alert management UI

### Kube State Metrics
- Exposes Kubernetes cluster state as metrics
- Provides insights into cluster resources
- Essential for Kubernetes monitoring

### Node Exporter
- Exposes node-level hardware and OS metrics
- Runs as DaemonSet on all nodes
- Provides system-level monitoring data

### Pushgateway
- Accepts metrics pushed from batch jobs
- Bridges short-lived jobs with Prometheus
- Useful for job-based monitoring

## Security Considerations

- **RBAC**: Proper service accounts and permissions configured
- **Security Context**: Non-root user execution
- **Network Policies**: Can be enabled for additional security
- **TLS**: Supports TLS termination for external access
- **Secrets**: Sensitive data stored in Kubernetes secrets

## Troubleshooting

### Common Issues

1. **Prometheus not starting**:
   ```bash
   kubectl describe pod -l app.kubernetes.io/name=prometheus
   kubectl logs -l app.kubernetes.io/name=prometheus
   ```

2. **Remote write failures**:
   ```bash
   kubectl logs deployment/matilda-prometheus-server | grep remote_write
   ```

3. **Storage issues**:
   ```bash
   kubectl get pvc
   kubectl describe pvc prometheus-server-storage
   ```

4. **RBAC issues**:
   ```bash
   kubectl auth can-i get pods --as=system:serviceaccount:default:matilda-prometheus-server
   ```

### Debugging Commands

```bash
# Check all components status
kubectl get pods -l app.kubernetes.io/instance=matilda-prometheus

# Check service endpoints
kubectl get svc -l app.kubernetes.io/instance=matilda-prometheus

# Check persistent volumes
kubectl get pv,pvc -l app.kubernetes.io/instance=matilda-prometheus

# Check RBAC resources
kubectl get clusterrole,clusterrolebinding -l app.kubernetes.io/instance=matilda-prometheus
```

## Upgrading

```bash
# Upgrade to latest version
helm upgrade matilda-prometheus matilda/matilda-prometheus-stack

# Upgrade with custom values
helm upgrade matilda-prometheus matilda/matilda-prometheus-stack -f custom-values.yaml
```

## Uninstallation

```bash
# Uninstall the chart
helm uninstall matilda-prometheus

# Clean up persistent volumes (optional)
kubectl delete pvc -l app.kubernetes.io/instance=matilda-prometheus
```

## Contributing

1. Fork the [Matilda Cloud Helm Charts](https://github.com/matildacloud/helm-charts) repository
2. Create a feature branch
3. Make your changes
4. Test the chart
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Related Charts

- [matilda-k8s-agent](https://github.com/matildacloud/helm-charts/tree/main/matilda-k8s-agent) - Kubernetes agent for Matilda Cloud
- [matilda-k8s-svc](https://github.com/matildacloud/helm-charts/tree/main/matilda-k8s-svc) - Service account with read-only permissions
- [matilda-thanos](https://github.com/matildacloud/helm-charts/tree/main/matilda-thanos) - Thanos monitoring solution