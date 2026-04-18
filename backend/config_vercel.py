"""Modified config for Vercel deployment with cloud services."""
import os
from dotenv import load_dotenv

load_dotenv()

# API Keys
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile")

# JWT
JWT_SECRET = os.getenv("JWT_SECRET", "change-this-in-production")
JWT_ALGORITHM = "HS256"
JWT_EXPIRY_HOURS = 24

# Qdrant Cloud (instead of local Docker)
QDRANT_URL = os.getenv("QDRANT_URL", "")  # e.g., https://xxx.aws.cloud.qdrant.io:6333
QDRANT_API_KEY = os.getenv("QDRANT_API_KEY", "")  # Add API key for cloud

# Database - Use environment variable for cloud DB
DATABASE_URL = os.getenv("DATABASE_URL", "")  # Postgres/MongoDB connection string
USERS_DB_FILE = "users.json"  # Fallback for local dev

# Email
SMTP_SERVER = os.getenv("SMTP_SERVER", "smtp.gmail.com")
SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))
SMTP_EMAIL = os.getenv("SMTP_EMAIL", "")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")

# Storage - Use Vercel Blob or S3 for production
STORAGE_TYPE = os.getenv("STORAGE_TYPE", "local")  # "local", "vercel_blob", "s3"
VERCEL_BLOB_TOKEN = os.getenv("BLOB_READ_WRITE_TOKEN", "")
AWS_S3_BUCKET = os.getenv("AWS_S3_BUCKET", "")
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID", "")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY", "")

# Paths (for local development only)
UPLOADS_DIR = "/tmp/uploads" if os.getenv("VERCEL") else "uploads"
CHAT_HISTORY_DIR = "/tmp/chat_history" if os.getenv("VERCEL") else "chat_history"
CACHE_DIR = "/tmp/cache" if os.getenv("VERCEL") else "cache"

# RAG Parameters
DEFAULT_QUERY_QUOTA = 50
DEFAULT_TOP_K = 5
EMBEDDING_DIM = 384
COLLECTION_NAME = "docs"
CHUNK_SIZE = 512
CHUNK_OVERLAP = 50
SCORE_THRESHOLD = 0.3

# Context confidence thresholds
MIN_CONTEXT_CHUNKS = 1
MIN_SIMILARITY_SCORE = 0.35
FALLBACK_THRESHOLD = 0.4

# CORS
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "*").split(",")

# Vercel-specific settings
IS_VERCEL = os.getenv("VERCEL") == "1"
VERCEL_URL = os.getenv("VERCEL_URL", "")
