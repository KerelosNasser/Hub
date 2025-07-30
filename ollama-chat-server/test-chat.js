import fetch from 'node-fetch';

const SERVER_URL = 'http://localhost:5000';

const testMessages = [
  "Hello! I'm learning English. Can you help me?",
  "I go to school yesterday.",
  "What's the difference between 'make' and 'do'?",
  "Can you teach me some common phrases for shopping?",
  "How do I pronounce 'thoroughly'?"
];

async function testChat() {
  console.log('Testing SpeakMate Chat Server...\n');
  
  // Check health
  try {
    const healthResponse = await fetch(`${SERVER_URL}/health`);
    const health = await healthResponse.json();
    console.log('✓ Server is healthy');
    console.log(`  Model: ${health.model}\n`);
  } catch (error) {
    console.error('✗ Server is not running!');
    console.error('  Start it with: npm start');
    process.exit(1);
  }
  
  // Test chat messages
  for (const message of testMessages) {
    console.log(`User: ${message}`);
    
    try {
      const response = await fetch(`${SERVER_URL}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ message }),
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      const data = await response.json();
      console.log(`AI: ${data.response}\n`);
      
      // Wait a bit between messages
      await new Promise(resolve => setTimeout(resolve, 1000));
      
    } catch (error) {
      console.error(`✗ Error: ${error.message}\n`);
    }
  }
  
  console.log('\nTest complete!');
}

// Add node-fetch dynamically if not available
async function main() {
  if (typeof fetch === 'undefined') {
    const { default: nodeFetch } = await import('node-fetch');
    global.fetch = nodeFetch;
  }
  
  await testChat();
}

main().catch(console.error);
