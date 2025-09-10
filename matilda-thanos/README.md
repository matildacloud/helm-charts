# Matilda Thanos Helm Chart

A Helm chart for deploying Thanos components on Kubernetes for long-term storage and querying of Prometheus metrics.

## Overview

This chart deploys a complete Thanos stack including:
- **Thanos Query**: Query layer that provides a unified query interface
- **Thanos Store**: Gateway to object storage (S3-compatible)
- **Thanos Receive**: Ingestor for remote write from Prometheus

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- An existing S3-compatible object storage bucket
- Prometheus Operator (optional, for ServiceMonitor resources)

## Installation

### Quick Start

1. **Add the Matilda Cloud Helm repository:**
```bash
helm repo add matilda https://matildacloud.github.io/helm-charts/
helm repo update
```

2. **Create S3 Object Storage Secret (REQUIRED):**
```bash
# Create the namespace
kubectl create namespace thanos

# Create S3 configuration file (replace with your actual values)
cat > thanos-s3-config.yaml << EOF
type: S3
config:
  bucket: your-s3-bucket-name
  endpoint: s3.amazonaws.com
  region: us-east-1
  access_key: your-access-key
  secret_key: your-secret-key
  insecure: false
  signature_version2: false
EOF

# Create the secret (REQUIRED - must be done before Helm install)
kubectl create secret generic thanos-objstore \
  --from-file=thanos.yaml=thanos-s3-config.yaml \
  --namespace thanos
```

3. **Install Thanos:**
```bash
helm install matilda-thanos matilda/matilda-thanos \
  --namespace thanos \
  --create-namespace \
  --set objstore.existingSecret=thanos-objstore
```

### Using Values File

Create a `my-values.yaml` file:

```yaml
# S3 Object Storage Configuration (secret must be created externally)
objstore:
  existingSecret: "thanos-objstore"

# Namespace configuration
namespace:
  create: true
  name: "thanos"

# Query configuration
query:
  replicaCount: 2
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi

# Store configuration
store:
  replicaCount: 1
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi

# Receive configuration
receiveIngestor:
  replicaCount: 1
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi
```

Then install with:

```bash
helm install matilda-thanos matilda/matilda-thanos \
  --namespace thanos \
  --create-namespace \
  -f my-values.yaml
```

## Configuration

### Required Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `objstore.existingSecret` | Name of the externally created S3 secret | `thanos-objstore` |
| `objstore.secretKey` | Key name in the secret | `thanos.yaml` |

### S3 Object Storage Configuration

**IMPORTANT**: For security reasons, S3 credentials must be created externally and never stored in Helm values or templates.

#### Required: External Secret Creation

The S3 secret must be created before deploying the Helm chart:

```bash
# Create S3 configuration file
cat > thanos-s3-config.yaml << EOF
type: S3
config:
  bucket: "your-s3-bucket"
  endpoint: "s3.amazonaws.com"
  region: "us-east-1"
  access_key: "your-access-key"
  secret_key: "your-secret-key"
  insecure: false
  signature_version2: false
EOF

# Create the secret
kubectl create secret generic thanos-objstore \
  --from-file=thanos.yaml=thanos-s3-config.yaml \
  --namespace thanos
```

#### Helm Values Configuration

```yaml
objstore:
  existingSecret: "thanos-objstore"  # Must match the secret created above
  secretKey: "thanos.yaml"           # Key name in the secret
```

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `NodePort` |
| `service.grpcPort` | gRPC port | `10901` |
| `service.httpPort` | HTTP port | `10902` |

### Resource Configuration

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|-------------|-----------|----------------|--------------|
| Query | 500m | 1000m | 1Gi | 2Gi |
| Store | 500m | 1000m | 1Gi | 2Gi |
| Receive | 500m | 1000m | 1Gi | 2Gi |

## Accessing Thanos

### Query UI

The Thanos Query UI provides a web interface for querying metrics:

```bash
# Port forward to access locally
kubectl port-forward -n thanos svc/thanos-query 9090:10902

# Access at http://localhost:9090
```

### Store Gateway

The Store Gateway provides access to historical data:

```bash
# Port forward to access locally
kubectl port-forward -n thanos svc/thanos-store 9091:10902

# Access at http://localhost:9091
```

### Receive Ingestor

The Receive Ingestor accepts remote write from Prometheus:

```bash
# Port forward to access locally
kubectl port-forward -n thanos svc/thanos-receive-ingestor-default 9092:10902

# Access at http://localhost:9092
```

## Monitoring

### ServiceMonitor

The chart includes ServiceMonitor resources for Prometheus Operator:

```yaml
query:
  serviceMonitor:
    enabled: true

store:
  serviceMonitor:
    enabled: true

receiveIngestor:
  serviceMonitor:
    enabled: true
```

### Health Checks

All components include liveness and readiness probes:

- **Liveness Probe**: `GET /-/healthy`
- **Readiness Probe**: `GET /-/ready`

## Storage

### Persistent Volumes

The chart creates persistent volumes for:

- **Store**: Local caching of object storage data
- **Receive**: Temporary storage for incoming metrics

### Storage Classes

Configure storage classes in `values.yaml`:

```yaml
store:
  volume:
    storageClassName: "fast-ssd"
    storage: "50Gi"

receiveStatefulSet:
  storageClassName: "fast-ssd"
  storage: "20Gi"
```

## Security

### Secret Management

**CRITICAL**: S3 credentials are never stored in Helm values or templates for security reasons:

- ✅ **External Secret Creation**: S3 secrets must be created using `kubectl` before deployment
- ✅ **No Credentials in Git**: S3 credentials are never committed to version control
- ✅ **RBAC Protection**: Secrets can be protected with Kubernetes RBAC
- ✅ **Encryption at Rest**: Kubernetes secrets are encrypted at rest (if enabled)

### Security Context

All containers run with:

- Non-root user (65534)
- Read-only root filesystem
- Dropped capabilities
- Seccomp profile

### Network Policies

Configure network policies for additional security:

```yaml
networkPolicy:
  enabled: true
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: prometheus
      ports:
      - protocol: TCP
        port: 10901
```

### Secret Rotation

To rotate S3 credentials:

```bash
# Update the secret
kubectl create secret generic thanos-objstore \
  --from-file=thanos.yaml=thanos-s3-config.yaml \
  --namespace thanos \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart Thanos components to pick up new credentials
kubectl rollout restart deployment/thanos-query -n thanos
kubectl rollout restart statefulset/thanos-store -n thanos
kubectl rollout restart statefulset/thanos-receive -n thanos
```

## Troubleshooting

### Common Issues

1. **S3 Authentication Errors**
   - Verify S3 credentials and permissions
   - Check bucket exists and is accessible
   - Ensure correct endpoint URL

2. **Query Not Finding Data**
   - Verify store endpoints in query configuration
   - Check store component logs
   - Ensure data is being written to object storage

3. **Receive Not Accepting Data**
   - Check receive component logs
   - Verify network connectivity from Prometheus
   - Ensure correct remote write URL

### Logs

View component logs:

```bash
# Query logs
kubectl logs -n thanos -l app.kubernetes.io/name=thanos-query --tail=100

# Store logs
kubectl logs -n thanos -l app.kubernetes.io/name=thanos-store --tail=100

# Receive logs
kubectl logs -n thanos -l app.kubernetes.io/name=thanos-receive --tail=100
```

### Status Check

Check component status:

```bash
kubectl get pods -n thanos
kubectl get svc -n thanos
kubectl get pvc -n thanos
```

## Uninstallation

To uninstall the chart:

```bash
helm uninstall matilda-thanos -n thanos
```

**Note**: This will not delete the S3 object storage secret. Remove it manually if needed:

```bash
kubectl delete secret thanos-objstore -n thanos
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This chart is licensed under the Apache 2.0 License.
