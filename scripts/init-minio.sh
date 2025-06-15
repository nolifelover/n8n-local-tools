#!/bin/sh

# MinIO initialization script
set -e

echo "🚀 Starting MinIO initialization..."

# Give MinIO some time to start
echo "⏳ Waiting for MinIO to start..."
sleep 10

# Wait for MinIO to be ready
echo "⏳ Waiting for MinIO to be ready..."
RETRY_COUNT=0
MAX_RETRIES=24  # 2 minutes total

until mc alias set minio http://minio:9000 "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}" > /dev/null 2>&1; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "❌ Failed to connect to MinIO after $MAX_RETRIES attempts"
    exit 1
  fi
  echo "MinIO is not ready yet. Retrying in 5 seconds... ($RETRY_COUNT/$MAX_RETRIES)"
  sleep 5
done

echo "✅ MinIO is ready!"

# Create bucket if it doesn't exist
BUCKET_NAME="${S3_BUCKET_NAME:-nca-toolkit}"
echo "📦 Creating bucket: ${BUCKET_NAME}"

# Check if bucket exists by trying to list it
if mc ls "minio/${BUCKET_NAME}" > /dev/null 2>&1; then
  echo "📦 Bucket '${BUCKET_NAME}' already exists"
else
  mc mb "minio/${BUCKET_NAME}"
  echo "✅ Bucket '${BUCKET_NAME}' created successfully"
fi

# Set bucket policy to public (optional)
if [ "${MINIO_BUCKET_PUBLIC:-false}" = "true" ]; then
  echo "🌐 Setting bucket '${BUCKET_NAME}' to public access"
  mc anonymous set public "minio/${BUCKET_NAME}"
  echo "✅ Bucket '${BUCKET_NAME}' is now publicly accessible"
fi

# Use access keys from environment variables
echo "🔑 Setting up access keys for API usage..."
ACCESS_KEY="${S3_ACCESS_KEY}"
SECRET_KEY="${S3_SECRET_KEY}"

if [ -z "${ACCESS_KEY}" ] || [ -z "${SECRET_KEY}" ]; then
  echo "❌ S3_ACCESS_KEY or S3_SECRET_KEY not provided in environment"
  exit 1
fi

# Create access key with values from environment
echo "🔑 Creating MinIO user with access key..."
mc admin user add minio "${ACCESS_KEY}" "${SECRET_KEY}"
mc admin policy attach minio readwrite --user "${ACCESS_KEY}"

# Save keys to a file for reference
echo "💾 Saving access keys to /tmp/minio-keys.txt"
cat > /tmp/minio-keys.txt << EOF
MinIO Access Keys
=================
Access Key: ${ACCESS_KEY}
Secret Key: ${SECRET_KEY}
Bucket Name: ${BUCKET_NAME}
Endpoint: http://localhost:9000
Console: http://localhost:9001

Environment Variables for applications:
S3_ACCESS_KEY=${ACCESS_KEY}
S3_SECRET_KEY=${SECRET_KEY}
S3_BUCKET_NAME=${BUCKET_NAME}
S3_ENDPOINT=http://minio:9000
EOF

# Note: S3 credentials are now loaded from environment variables
# No need to save to shared directory

echo "✅ MinIO initialization completed!"
echo "📋 Access keys saved to /tmp/minio-keys.txt"
echo "🔑 Access Key: ${ACCESS_KEY}"
echo "🔒 Secret Key: ${SECRET_KEY}"
echo "📦 Bucket: ${BUCKET_NAME}"
echo "🌐 Endpoint: http://localhost:9000"
echo "🖥️  Console: http://localhost:9001" 