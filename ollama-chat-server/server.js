import express from 'express';
import { Ollama } from 'ollama';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;
const ollama = new Ollama({ host: process.env.OLLAMA_HOST || 'http://localhost:11434' });

// Enable CORS for all origins (adjust for production)
app.use(cors());
app.use(express.json());

// Model selection with fallbacks
let selectedModel = null;
const preferredModels = [
  'gemma3n:e4b',     // Your recommended model - 7.5 GB
  'gemma3:4b',       // Smaller Gemma model - 3.3 GB
  'llama3.2:latest', // Fast and efficient - 2.0 GB
  'qwen3:1.7b',      // Very small model - 1.4 GB
  'deepseek-r1:latest', // Powerful model - 5.2 GB
  'gemma2:2b',
  'phi3:mini',
  'mistral:7b-instruct'
];

// System prompt for English learning assistant
const systemPrompt = `You are an English language learning assistant called SpeakMate. Your role is to:
1. Help users practice conversational English
2. Correct grammar mistakes gently and explain why
3. Suggest better ways to express ideas in English
4. Provide vocabulary tips and common phrases
5. Be encouraging and supportive
6. Keep responses concise and easy to understand
7. Use simple language appropriate for English learners

Respond in a friendly, conversational tone. If the user makes grammar mistakes, correct them naturally within your response.`;

// Initialize and select best available model
async function initializeModel() {
  try {
    console.log('Checking available Ollama models...');
    const response = await ollama.list();
    const availableModels = response.models.map(m => m.name);
    
    if (availableModels.length === 0) {
      console.error('No models found! Please install a model first:');
      console.error('ollama pull gemma2:2b');
      process.exit(1);
    }
    
    // Find the best available model from our preference list
    for (const preferred of preferredModels) {
      const found = availableModels.find(m => m.startsWith(preferred));
      if (found) {
        selectedModel = found;
        break;
      }
    }
    
    // If no preferred model found, use the first available
    if (!selectedModel) {
      selectedModel = availableModels[0];
    }
    
    console.log(`Selected model: ${selectedModel}`);
    console.log('Available models:', availableModels.join(', '));
    
  } catch (error) {
    console.error('Error connecting to Ollama:', error.message);
    console.error('Make sure Ollama is running with: ollama serve');
    process.exit(1);
  }
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    model: selectedModel,
    timestamp: new Date().toISOString()
  });
});

// List available models endpoint
app.get('/models', async (req, res) => {
  try {
    const response = await ollama.list();
    res.json({
      selected: selectedModel,
      available: response.models.map(m => ({
        name: m.name,
        size: `${(m.size / 1e9).toFixed(2)} GB`
      }))
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to list models' });
  }
});

// Main chat endpoint
app.post('/chat', async (req, res) => {
  const { message } = req.body;
  
  if (!message) {
    return res.status(400).json({ error: 'Message is required' });
  }
  
  if (!selectedModel) {
    return res.status(503).json({ error: 'No model available' });
  }
  
  try {
    console.log(`User: ${message}`);
    
    const response = await ollama.chat({
      model: selectedModel,
      messages: [
        {
          role: 'system',
          content: systemPrompt
        },
        {
          role: 'user',
          content: message
        }
      ],
      stream: false,
      options: {
        temperature: 0.7,
        top_p: 0.9,
        max_tokens: 500
      }
    });
    
    const aiResponse = response.message.content;
    console.log(`AI: ${aiResponse}`);
    
    res.json({ response: aiResponse });
    
  } catch (error) {
    console.error('Chat error:', error);
    res.status(500).json({ 
      error: 'Failed to get response from AI',
      details: error.message 
    });
  }
});

// Start server
async function startServer() {
  await initializeModel();
  
  app.listen(port, '0.0.0.0', () => {
    console.log('\n=================================');
    console.log('SpeakMate Chat Server is running!');
    console.log('=================================');
    console.log(`Server URL: http://localhost:${port}`);
    console.log(`Using model: ${selectedModel}`);
    console.log('\nEndpoints:');
    console.log(`  POST http://localhost:${port}/chat`);
    console.log(`  GET  http://localhost:${port}/health`);
    console.log(`  GET  http://localhost:${port}/models`);
    console.log('\nPress Ctrl+C to stop the server');
  });
}

startServer().catch(console.error);

