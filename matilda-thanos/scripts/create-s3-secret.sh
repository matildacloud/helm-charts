#!/bin/bash

# Script to create S3 object storage secret for Thanos
# Usage: ./create-s3-secret.sh <namespace> <secret-name> <bucket> <endpoint> <region> <access-key> <secret-key>

set -e

# Check if all required parameters are provided
if [ $# -ne 7 ]; then
    echo "Usage: $0 <namespace> <secret-name> <bucket> <endpoint> <region> <access-key> <secret-key>"
    echo ""
    echo "Example:"
    echo "  $0 thanos thanos-objstore my-bucket s3.amazonaws.com us-east-1 AKIAIOSFODNN7EXAMPLE wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    exit 1
fi

NAMESPACE=$1
SECRET_NAME=$2
BUCKET=$3
ENDPOINT=$4
REGION=$5
ACCESS_KEY=$6
SECRET_KEY=$7

# Create temporary directory for config file
TEMP_DIR=$(mktemp -d)
CONFIG_FILE="$TEMP_DIR/thanos.yaml"

# Create Thanos S3 configuration
cat > "$CONFIG_FILE" << EOF
type: S3
config:
  bucket: $BUCKET
  endpoint: $ENDPOINT
  region: $REGION
  access_key: $ACCESS_KEY
  secret_key: $SECRET_KEY
  insecure: false
  signature_version2: false
EOF

echo "Creating namespace '$NAMESPACE' if it doesn't exist..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Creating secret '$SECRET_NAME' in namespace '$NAMESPACE'..."
kubectl create secret generic "$SECRET_NAME" \
  --from-file=thanos.yaml="$CONFIG_FILE" \
  --namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

# Clean up temporary files
rm -rf "$TEMP_DIR"

echo "✅ Secret '$SECRET_NAME' created successfully in namespace '$NAMESPACE'"
echo ""
echo "You can now install Thanos with:"
echo "  helm install matilda-thanos matilda/matilda-thanos \\"
echo "    --namespace $NAMESPACE \\"
echo "    --create-namespace \\"
echo "    --set objstore.existingSecret=$SECRET_NAME"
