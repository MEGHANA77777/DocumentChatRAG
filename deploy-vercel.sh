#!/bin/bash

echo "🚀 Vercel Deployment Setup Script"
echo "=================================="
echo ""

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI not found. Installing..."
    npm install -g vercel
else
    echo "✅ Vercel CLI found"
fi

echo ""
echo "📋 Pre-deployment Checklist:"
echo ""
echo "1. ☐ Created Qdrant Cloud account (https://cloud.qdrant.io)"
echo "2. ☐ Got Qdrant Cloud URL and API key"
echo "3. ☐ Decided on database solution (Vercel Postgres/MongoDB Atlas)"
echo "4. ☐ Decided on file storage (Vercel Blob/AWS S3)"
echo "5. ☐ Have Groq API key ready"
echo ""

read -p "Have you completed all items above? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Please complete the checklist first. See VERCEL_DEPLOY.md for details."
    exit 1
fi

echo ""
echo "🔐 Setting up environment variables..."
echo ""

# Login to Vercel
echo "Logging into Vercel..."
vercel login

echo ""
echo "Now we'll set up environment variables."
echo "Press Enter after pasting each value."
echo ""

# Set environment variables
echo "Enter your GROQ_API_KEY:"
read -r GROQ_KEY
vercel env add GROQ_API_KEY production <<< "$GROQ_KEY"

echo "Enter your QDRANT_URL (e.g., https://xxx.aws.cloud.qdrant.io:6333):"
read -r QDRANT_URL
vercel env add QDRANT_URL production <<< "$QDRANT_URL"

echo "Enter your QDRANT_API_KEY:"
read -r QDRANT_KEY
vercel env add QDRANT_API_KEY production <<< "$QDRANT_KEY"

echo "Enter your JWT_SECRET (or press Enter to generate):"
read -r JWT_SECRET
if [ -z "$JWT_SECRET" ]; then
    JWT_SECRET=$(openssl rand -hex 32)
    echo "Generated: $JWT_SECRET"
fi
vercel env add JWT_SECRET production <<< "$JWT_SECRET"

echo ""
echo "Optional: Email configuration (press Enter to skip)"
echo "Enter SMTP_EMAIL (or press Enter to skip):"
read -r SMTP_EMAIL
if [ ! -z "$SMTP_EMAIL" ]; then
    vercel env add SMTP_EMAIL production <<< "$SMTP_EMAIL"
    
    echo "Enter SMTP_PASSWORD:"
    read -s SMTP_PASSWORD
    vercel env add SMTP_PASSWORD production <<< "$SMTP_PASSWORD"
    
    vercel env add SMTP_SERVER production <<< "smtp.gmail.com"
    vercel env add SMTP_PORT production <<< "587"
fi

echo ""
echo "✅ Environment variables configured!"
echo ""
echo "🚀 Deploying to Vercel..."
echo ""

# Deploy
vercel --prod

echo ""
echo "✅ Deployment complete!"
echo ""
echo "⚠️  IMPORTANT: Your app will NOT work fully until you:"
echo "1. Migrate users.json to a cloud database"
echo "2. Implement cloud storage for file uploads"
echo "3. Handle serverless function timeouts"
echo ""
echo "See VERCEL_DEPLOY.md for detailed migration guide."
echo ""
