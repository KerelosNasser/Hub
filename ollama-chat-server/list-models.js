import { Ollama } from 'ollama';

const ollama = new Ollama({ host: 'http://localhost:11434' });

async function listModels() {
  try {
    console.log('Fetching available Ollama models...\n');
    
    const response = await ollama.list();
    const models = response.models;
    
    if (models.length === 0) {
      console.log('No models found. Please pull some models first using:');
      console.log('ollama pull gemma2:2b');
      console.log('ollama pull phi3');
      console.log('ollama pull mistral');
      return;
    }
    
    console.log('Available Models:');
    console.log('=================');
    
    // Group models by base name
    const modelGroups = {};
    
    models.forEach(model => {
      const baseName = model.name.split(':')[0];
      if (!modelGroups[baseName]) {
        modelGroups[baseName] = [];
      }
      modelGroups[baseName].push(model);
    });
    
    // Display models grouped by base name
    Object.entries(modelGroups).forEach(([baseName, modelList]) => {
      console.log(`\n${baseName}:`);
      modelList.forEach(model => {
        const sizeInGB = (model.size / 1e9).toFixed(2);
        console.log(`  - ${model.name} (${sizeInGB} GB)`);
        console.log(`    Modified: ${new Date(model.modified_at).toLocaleString()}`);
      });
    });
    
    // Recommendations for English learning
    console.log('\n\nRecommended models for English learning:');
    console.log('========================================');
    
    const recommendations = [
      { name: 'gemma2:2b', reason: 'Fast, efficient, good for conversations' },
      { name: 'phi3:mini', reason: 'Compact but powerful for language tasks' },
      { name: 'mistral:7b-instruct', reason: 'Excellent instruction following' },
      { name: 'llama3.2:3b', reason: 'Latest model with good language understanding' }
    ];
    
    recommendations.forEach(rec => {
      const found = models.find(m => m.name.startsWith(rec.name.split(':')[0]));
      if (found) {
        console.log(`✓ ${rec.name} - ${rec.reason}`);
      } else {
        console.log(`✗ ${rec.name} - ${rec.reason} (Not installed)`);
      }
    });
    
    // Check if gemma2:2b is available (your suggested model)
    const hasGemma = models.some(m => m.name.includes('gemma'));
    if (!hasGemma) {
      console.log('\n\nTo install the recommended gemma2:2b model, run:');
      console.log('ollama pull gemma2:2b');
    }
    
  } catch (error) {
    console.error('Error listing models:', error.message);
    console.log('\nMake sure Ollama is running with: ollama serve');
  }
}

listModels();
