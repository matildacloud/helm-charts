# Matilda K8s Service Account Helm Chart

This Helm chart creates a Kubernetes service account with read-only permissions to all cluster resources and generates a kubeconfig file with a non-expiring token.

## Repository

This chart is part of the [Matilda Cloud Helm Charts](https://github.com/matildacloud/helm-charts) repository.

## Features

- **Service Account**: Creates a dedicated service account for read-only access
- **Cluster Role**: Defines read-only permissions for all cluster resources
- **Cluster Role Binding**: Binds the service account to the cluster role
- **Manual Kubeconfig Generation**: Simple commands to generate kubeconfig with non-expiring token

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Cluster admin permissions to create ClusterRole and ClusterRoleBinding

## Installation

### Basic Installation

```bash
# Add the Matilda Cloud Helm repository
helm repo add matilda https://matildacloud.github.io/helm-charts/
helm repo update

# Install the chart
helm install matilda-sa matilda/matilda-k8s-svc

# Or install with a custom release name
helm install my-release matilda/matilda-k8s-svc
```

### Local Installation

```bash
# Install from local chart directory
helm install matilda-sa ./

# Or install with a custom release name
helm install my-release ./
```

### Custom Values Installation

```bash
# Create a custom values file
cat > custom-values.yaml << EOF
serviceAccount:
  name: "my-readonly-sa"
  namespace: "my-namespace"

kubeconfig:
  clusterName: "my-cluster"
  clusterServer: "https://my-cluster.example.com"
EOF

# Install with custom values
helm install matilda-sa matilda/matilda-k8s-svc -f custom-values.yaml
```

## Configuration

### Service Account Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.name` | Service account name | `matilda-readonly-sa` |
| `serviceAccount.namespace` | Service account namespace | `default` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.labels` | Service account labels | `{}` |

### Cluster Role Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `clusterRole.create` | Create cluster role | `true` |
| `clusterRole.name` | Cluster role name | `matilda-readonly-role` |
| `clusterRole.rules` | RBAC rules for read-only access | See values.yaml |

### Kubeconfig Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `kubeconfig.clusterName` | Cluster name in kubeconfig | `kubernetes` |
| `kubeconfig.clusterServer` | Cluster server URL | Auto-detected |

## Usage

### After Installation

To generate kubeconfig for the service account:

1. **Extract and use the provided script** (recommended):
   ```bash
   # Extract the script from ConfigMap
   kubectl get configmap matilda-k8s-svc-scripts -n default -o jsonpath='{.data.generate-kubeconfig\.sh}' > generate-kubeconfig.sh
   chmod +x generate-kubeconfig.sh
   ./generate-kubeconfig.sh default matilda-readonly-sa
   ```

2. **Generate kubeconfig using one-liner**:
   ```bash
   TOKEN=$(kubectl create token matilda-readonly-sa -n default --duration=0) && \
   SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}') && \
   CA_CERT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}') && \
   cat > matilda-kubeconfig.yaml << EOF
   apiVersion: v1
   kind: Config
   clusters:
   - name: kubernetes
     cluster:
       server: $SERVER
       certificate-authority-data: $CA_CERT
   contexts:
   - name: kubernetes-context
     context:
       cluster: kubernetes
       namespace: default
       user: matilda-readonly-sa
   current-context: kubernetes-context
   users:
   - name: matilda-readonly-sa
     user:
       token: $TOKEN
   EOF
   ```

3. **Test the kubeconfig**:
   ```bash
   kubectl --kubeconfig=matilda-kubeconfig.yaml get nodes
   kubectl --kubeconfig=matilda-kubeconfig.yaml get pods --all-namespaces
   ```



### Using the Generated Kubeconfig

```bash
# Set the kubeconfig for your current session
export KUBECONFIG=./matilda-kubeconfig.yaml

# Or use it with kubectl commands
kubectl --kubeconfig=./matilda-kubeconfig.yaml get all --all-namespaces
```

## Permissions

The service account has read-only access to:

- **Core Resources**: pods, services, configmaps, secrets, etc.
- **Apps**: deployments, statefulsets, daemonsets, etc.
- **Batch**: jobs, cronjobs
- **Extensions**: ingresses, network policies
- **Networking**: network policies, ingress classes
- **RBAC**: roles, rolebindings, clusterroles, clusterrolebindings
- **Storage**: storage classes, persistent volumes

## Security Considerations

- The service account has read-only access only
- The token is non-expiring (set `tokenExpiration` to a value > 0 to enable expiration)
- Store the kubeconfig securely
- Rotate the service account token periodically in production

## Troubleshooting

### Permission Denied Errors

1. Verify cluster role binding:
   ```bash
   kubectl get clusterrolebinding matilda-readonly-binding
   ```

2. Check cluster role:
   ```bash
   kubectl get clusterrole matilda-readonly-role -o yaml
   ```

### Token Generation Issues

1. Verify service account exists:
   ```bash
   kubectl get serviceaccount matilda-readonly-sa -n default
   ```

2. Check if you have permission to create tokens:
   ```bash
   kubectl auth can-i create token --namespace default
   ```

### Kubeconfig Issues

1. Test the generated kubeconfig:
   ```bash
   kubectl --kubeconfig=matilda-kubeconfig.yaml get nodes
   ```

2. Verify token generation:
   ```bash
   kubectl create token matilda-readonly-sa -n default --duration=0
   ```

## Uninstallation

```bash
# Uninstall the chart
helm uninstall matilda-sa

# Clean up resources manually if needed
kubectl delete serviceaccount matilda-readonly-sa -n default
kubectl delete clusterrole matilda-readonly-role
kubectl delete clusterrolebinding matilda-readonly-binding
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
- [matilda-prometheus](https://github.com/matildacloud/helm-charts/tree/main/matilda-prometheus) - Prometheus monitoring stack
- [matilda-thanos](https://github.com/matildacloud/helm-charts/tree/main/matilda-thanos) - Thanos monitoring solution 