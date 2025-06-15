#!/bin/bash

# Test script for MinIO and NCA-Toolkit services
set -e

echo "🧪 Testing N8N-Tools Services..."

# Check if services are running
echo "📊 Checking service status..."
docker-compose ps

echo ""
echo "🔍 Testing MinIO..."

# Test MinIO health
if curl -s http://localhost:9000/minio/health/live > /dev/null; then
    echo "✅ MinIO API is healthy"
else
    echo "❌ MinIO API is not responding"
fi

# Test MinIO console
if curl -s http://localhost:9001 > /dev/null; then
    echo "✅ MinIO Console is accessible"
else
    echo "❌ MinIO Console is not responding"
fi

echo ""
echo "🔍 Testing NCA-Toolkit..."

# Test NCA-Toolkit API
if curl -s http://localhost:8080/v1/toolkit/test > /dev/null; then
    echo "✅ NCA-Toolkit API is responding"
else
    echo "❌ NCA-Toolkit API is not responding"
fi

echo ""
echo "🔍 Testing other services..."

# Test N8N
if curl -s http://localhost:5678 > /dev/null; then
    echo "✅ N8N is accessible"
else
    echo "❌ N8N is not responding"
fi

# Test Qdrant
if curl -s http://localhost:6333 > /dev/null; then
    echo "✅ Qdrant API is responding"
else
    echo "❌ Qdrant API is not responding"
fi

# Test Typhoon OCR
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ Typhoon OCR is responding"
else
    echo "❌ Typhoon OCR is not responding"
fi

echo ""
echo "🗂️ Checking MinIO Access Keys..."
echo "To view generated MinIO keys, run:"
echo "  docker-compose logs minio-init"
echo ""
echo "📋 Service URLs:"
echo "  - N8N: http://localhost:5678"
echo "  - MinIO Console: http://localhost:9001 (admin/miniopassword)"
echo "  - NCA-Toolkit: http://localhost:8080"
echo "  - Qdrant Dashboard: http://localhost:6334"
echo "  - Typhoon OCR: http://localhost:8000"
echo ""
echo "🎯 Testing completed!" 