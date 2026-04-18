# Vercel Deployment Guide for RAG PDF Chat

## ⚠️ Critical Changes Required

Your app uses **local file storage** and **Qdrant Docker**, which won't work on Vercel's serverless platform. You MUST migrate to cloud services:

### Required Migrations:

1. **Qdrant Vector DB** → Use Qdrant Cloud (https://cloud.qdrant.io)
   - Sign up for free tier
   - Get cloud cluster URL and API key
   - Update `QDRANT_URL` in environment variables

2. **File Storage** (uploads/, chat_history/, cache/) → Use cloud storage:
   - **Option A**: Vercel Blob Storage (https://vercel.com/docs/storage/vercel-blob)
   - **Option B**: AWS S3
   - **Option C**: Cloudinary for PDFs

3. **users.json** → Use cloud database:
   - **Option A**: Vercel Postgres (https://vercel.com/docs/storage/vercel-postgres)
   - **Option B**: MongoDB Atlas
   - **Option C**: Supabase

## 📋 Deployment Steps

### 1. Setup Qdrant Cloud

```bash
# Sign up at https://cloud.qdrant.io
# Create a cluster (free tier available)
# Get your cluster URL: https://xxx-xxx.aws.cloud.qdrant.io:6333
# Get your API key from dashboard
```

### 2. Update backend/config.py

```python
# Add for Qdrant Cloud authentication
QDRANT_API_KEY = os.getenv("QDRANT_API_KEY", "")
```

### 3. Update backend/rag/vector_db.py

```python
from qdrant_client import QdrantClient

# Change initialization to:
client = QdrantClient(
    url=QDRANT_URL,
    api_key=QDRANT_API_KEY,  # Add this
    timeout=60
)
```

### 4. Install Vercel CLI

```bash
npm install -g vercel
```

### 5. Login to Vercel

```bash
vercel login
```

### 6. Set Environment Variables

```bash
vercel env add GROQ_API_KEY
# Paste your Groq API key

vercel env add QDRANT_URL
# Paste your Qdrant Cloud URL

vercel env add QDRANT_API_KEY
# Paste your Qdrant API key

vercel env add JWT_SECRET
# Generate: openssl rand -hex 32

vercel env add SMTP_SERVER
vercel env add SMTP_PORT
vercel env add SMTP_EMAIL
vercel env add SMTP_PASSWORD
```

### 7. Deploy

```bash
cd /home/user/Downloads/RAG
vercel --prod
```

## 🔧 Code Changes Needed

### A. Replace Local File Storage

**Before (current):**
```python
# backend/user/user_data.py
with open("users.json", "r") as f:
    users = json.load(f)
```

**After (use Vercel Postgres):**
```python
import psycopg2
conn = psycopg2.connect(os.getenv("POSTGRES_URL"))
```

### B. Replace PDF Upload Storage

**Before:**
```python
# Saves to local uploads/ directory
file_path = f"uploads/{username}/{filename}"
```

**After (use Vercel Blob):**
```python
from vercel_blob import put

blob = await put(f"{username}/{filename}", file_content, {
    'access': 'public',
})
```

### C. Handle Serverless Timeout

PDF processing takes time. Split into:
1. Upload endpoint (returns immediately)
2. Background processing (use Vercel Cron or external queue)

## 📁 Project Structure for Vercel

```
RAG/
├── api/
│   └── index.py          # Vercel entry point (created)
├── backend/              # Your FastAPI code
├── frontend/             # Static HTML/CSS/JS
├── vercel.json           # Vercel config (created)
├── requirements-vercel.txt  # Python deps (created)
└── VERCEL_DEPLOY.md      # This guide
```

## 🚨 Limitations on Vercel

1. **10-second timeout** (free) / 60-second (pro) for serverless functions
   - PDF processing may timeout
   - Need to implement async processing

2. **No persistent filesystem**
   - Files uploaded are lost after function execution
   - Must use external storage

3. **Cold starts**
   - First request may be slow (loading ML models)
   - Consider keeping functions warm

4. **No Docker**
   - Cannot run Qdrant locally
   - Must use Qdrant Cloud

## 💰 Cost Estimate

- Vercel: Free tier (hobby projects)
- Qdrant Cloud: Free tier (1GB storage)
- Vercel Blob: $0.15/GB
- Vercel Postgres: Free tier (256MB)

**Total for small usage: $0-5/month**

## 🔄 Alternative: Hybrid Approach

Deploy frontend on Vercel, backend elsewhere:

1. **Frontend**: Deploy to Vercel (static files)
2. **Backend**: Deploy to Railway/Render (supports Docker)
3. Update frontend API calls to point to backend URL

This is MUCH easier and recommended.

## 📞 Next Steps

1. Choose migration path (full Vercel vs hybrid)
2. Set up Qdrant Cloud account
3. Choose database solution (Postgres/MongoDB)
4. Implement storage changes
5. Test locally with cloud services
6. Deploy to Vercel

## ⚡ Quick Deploy (Frontend Only)

If you just want to deploy the frontend:

```bash
# Create new vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "frontend/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "frontend/$1"
    }
  ]
}

# Deploy
vercel --prod

# Update frontend/js/*.js to point to your backend URL
const API_URL = "https://your-backend.railway.app";
```

---

**Recommendation**: Use Railway for backend + Vercel for frontend, or deploy everything on Railway. Vercel alone requires significant refactoring.
