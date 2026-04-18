"""Vercel serverless function entry point."""
from backend.main import app

# Vercel expects a variable named 'app' or 'handler'
handler = app
