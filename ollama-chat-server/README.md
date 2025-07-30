# Ollama Chat Server for SpeakMate

This is a Node.js server that provides a chat API endpoint for the SpeakMate English learning app. It uses Ollama to run language models locally.

## Prerequisites

1. **Install Ollama** - Download from [ollama.ai](https://ollama.ai/)
2. **Install Node.js** - Version 18 or higher recommended
3. **Pull a language model** - At least one model must be installed

## Quick Start

### 1. Install dependencies
```bash
npm install
```

### 2. Check available Ollama models
```bash
npm run list-models
```

If no models are installed, install the recommended model:
```bash
ollama pull gemma2:2b
```

Other good models for English learning:
- `phi3:mini` - Very fast and efficient
- `mistral:7b-instruct` - Great for following instructions
- `llama3.2:3b` - Latest model with good capabilities

### 3. Start the server
```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

## Configuration

Create a `.env` file (copy from `.env.example`):
```bash
cp .env.example .env
```

Default configuration:
- Port: 5000
- Ollama Host: http://localhost:11434

## API Endpoints

### POST /chat
Send a message to the AI assistant.

Request:
```json
{
  "message": "Hello, how are you?"
}
```

Response:
```json
{
  "response": "Hello! I'm doing great, thank you for asking! How are you doing today?"
}
```

### GET /health
Check server status.

### GET /models
List available models.

## Features

- **Auto Model Selection**: Automatically selects the best available model
- **English Learning Focus**: System prompt optimized for English language learning
- **Grammar Correction**: Gentle corrections with explanations
- **Conversation Practice**: Natural, encouraging responses

## Troubleshooting

### "No models found!"
Make sure you have at least one model installed:
```bash
ollama list
ollama pull gemma2:2b
```

### "Error connecting to Ollama"
Make sure Ollama is running:
```bash
ollama serve
```

### Port already in use
Change the port in `.env` file:
```
PORT=3001
```

## Using with SpeakMate Flutter App

The Flutter app expects the server to run on `http://localhost:5000`. If you change the port, update the API URL in the Flutter app's `api_service.dart` file.
