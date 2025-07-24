# Matilda Kubernetes Agent Helm Chart

A Helm chart for deploying the Matilda Kubernetes Agent with secure configuration management and RabbitMQ integration.

## Features

- **Secure Configuration**: Sensitive data stored in Kubernetes Secrets
- **RabbitMQ Integration**: Configurable message queue connectivity
- **Asset Management**: Dynamic assetid and integrationid configuration
- **Security Hardened**: Non-root execution, read-only filesystem, dropped capabilities
- **Health Monitoring**: Liveness and readiness probes
- **Resource Management**: Configurable CPU and memory limits
- **RBAC Support**: Optional RBAC creation with read-only permissions

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- RabbitMQ server accessible from the cluster

## Quick Start

### Basic Installation

```bash
# Add the Matilda Cloud Helm repository
helm repo add matilda https://matildacloud.github.io/helm-charts/
helm repo update

# Install with required parameters (only assetid and integrationid are required at install time)
helm install matilda-agent matilda/matilda-k8s-agent \
  --set assetid=YOUR_ASSET_ID \
  --set integrationid=YOUR_INTEGRATION_ID
```

**Prerequisites:**
- Ensure you have the required image pull secret (`k8s-agent-docker-secret`) created for private registry access
- Ensure you have the RabbitMQ secret (`rabbitmq-secret`) created with username and password keys

### Customizing RabbitMQ Connection

By default, RabbitMQ host, port, vhost, and other connection settings are configured in `values.yaml`. If you need to override these for a specific environment, create a custom values file:

```yaml
# my-values.yaml
rabbitMQ:
  host: "rabbitmq.example.com"
  port: "5672"
  vhost: "/customvhost"
```

Then install with:

```bash
helm install matilda-agent matilda/matilda-k8s-agent \
  --set assetid=YOUR_ASSET_ID \
  --set integrationid=YOUR_INTEGRATION_ID \
  -f my-values.yaml
```

> **Note:** Do not pass RabbitMQ host/port/vhost as `--set` flags unless you need to override for a specific environment. The recommended approach is to use a custom values file for infrastructure configuration.

### Creating Required Secrets

#### Image Pull Secret
```bash
kubectl create secret docker-registry k8s-agent-docker-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=your-username \
  --docker-password=your-password
```

#### RabbitMQ Secret
```bash
kubectl create secret generic rabbitmq-secret \
  --from-literal=username=your-rabbitmq-username \
  --from-literal=password=your-rabbitmq-password
```

## Configuration

### Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `assetid` | Asset ID for the Kubernetes cluster | `Uyqgpe8074kVtb4GuoFcFzp99k6hCf` |
| `integrationid` | Integration ID for the agent | `xyz123` |

### RabbitMQ Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `rabbitMQ.host` | RabbitMQ server host/IP | `10.10.10.10` |
| `rabbitMQ.port` | RabbitMQ server port | `32021` |
| `rabbitMQ.vhost` | RabbitMQ virtual host | `/` |
| `rabbitMQ.connectionTimeout` | Connection timeout (seconds) | `30` |
| `rabbitMQ.heartbeat` | Heartbeat interval (seconds) | `60` |
| `rabbitMQ.secret.name` | Name of existing RabbitMQ secret | `rabbitmq-secret` |
| `rabbitMQ.secret.usernameKey` | Key for username in secret | `username` |
| `rabbitMQ.secret.passwordKey` | Key for password in secret | `password` |

### Security Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `securityContext.enabled` | Enable pod security context | `true` |
| `securityContext.runAsNonRoot` | Run as non-root user | `true` |
| `securityContext.runAsUser` | User ID to run as | `1000` |
| `containerSecurityContext.enabled` | Enable container security context | `true` |
| `containerSecurityContext.readOnlyRootFilesystem` | Read-only root filesystem | `true` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |

## Security Features

### Secrets Management
- RabbitMQ credentials stored in Kubernetes Secrets
- assetid and integrationid encrypted in Secrets
- Docker registry credentials secured

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

### RabbitMQ Configuration
- `RABBIT_MQ_HOST`: RabbitMQ server host
- `RABBIT_MQ_PORT`: RabbitMQ server port
- `RABBIT_MQ_USER`: RabbitMQ username (from Secret)
- `RABBIT_MQ_PASSWORD`: RabbitMQ password (from Secret)
- `RABBIT_MQ_VHOST`: RabbitMQ virtual host
- `RABBIT_MQ_CONNECTION_TIMEOUT`: Connection timeout
- `RABBIT_MQ_HEARTBEAT`: Heartbeat interval

### Asset Configuration
- `CLUSTER_ASSET_ID`: assetid (from Secret)
- `INTEGRATION_ID`: integrationid (from Secret)

### Application Configuration
- `APP_NAME`: Application name
- `APP_VERSION`: Application version
- `LOG_LEVEL`: Logging level
- `LOG_FORMAT`: Logging format

## Monitoring

### Health Probes
- **Liveness Probe**: HTTP GET `/health` endpoint
- **Readiness Probe**: HTTP GET `/ready` endpoint

### Resource Monitoring
- CPU and memory usage tracking
- Configurable resource limits and requests
- Horizontal Pod Autoscaler support (optional)

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -l app.kubernetes.io/name=matilda-k8s-agent
```

### View Logs
```bash
kubectl logs -f deployment/matilda-agent -n default
```

### Check Configuration
```bash
# Verify ConfigMap
kubectl get configmap matilda-agent-config -o yaml

# Verify Secrets (base64 encoded)
kubectl get secret matilda-agent-secret -o yaml
```

### Common Issues

1. **assetid not configured**
   ```bash
   helm upgrade matilda-agent matilda/matilda-k8s-agent --set assetid=YOUR_ASSET_ID
   ```

2. **RabbitMQ connection failed**
   - Verify RabbitMQ server is accessible (host/port/vhost in values file)
   - Check credentials in the secret
   - Verify network connectivity

3. **Pod security context issues**
   - Ensure the image supports non-root execution
   - Check if the user ID 1000 exists in the container

## Uninstallation

```bash
helm uninstall matilda-agent
```

## Contributing

1. Fork the [Matilda Cloud Helm Charts](https://github.com/matildacloud/helm-charts) repository
2. Create a feature branch
3. Make your changes
4. Test the chart
5. Submit a pull request

## License

This project is licensed under the MIT License. 