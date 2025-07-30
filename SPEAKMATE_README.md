# SpeakMate - AI-Powered English Learning Companion

SpeakMate is a voice-enabled English learning feature integrated into the Daily Lessons section of Farah's Hub. It provides real-time conversation practice with an AI assistant running locally on your machine.

## Features

- 🎤 **Speech-to-Text**: Record your voice and convert it to text
- 🤖 **AI Conversations**: Chat with a local AI model optimized for English learning
- 🔊 **Text-to-Speech**: Listen to AI responses with natural English pronunciation
- 💬 **Chat Interface**: Modern, animated chat UI with message history
- 🌐 **Offline Operation**: Works completely offline with local AI models
- 📱 **Android Optimized**: Designed specifically for Android devices

## Setup Instructions

### 1. Install Ollama

1. Download Ollama from [https://ollama.ai/](https://ollama.ai/)
2. Install it on your Windows machine
3. Open a terminal and run: `ollama serve`

### 2. Install an AI Model

In a new terminal, install the recommended model:
```bash
ollama pull gemma2:2b
```

You already have these models installed:
- `gemma3n:e4b` (7.5 GB) - Recommended for best performance
- `gemma3:4b` (3.3 GB) - Good balance of size and performance
- `llama3.2:latest` (2.0 GB) - Fast and efficient

### 3. Start the Chat Server

Navigate to the chat server directory:
```bash
cd ollama-chat-server
```

Install dependencies (first time only):
```bash
npm install
```

Start the server:
```bash
npm start
```

Or use the batch file:
```bash
start-server.bat
```

The server will:
- Automatically detect and use the best available model
- Run on http://localhost:5000
- Show which model is being used

### 4. Run the Flutter App

In a new terminal, from the main project directory:
```bash
flutter run
```

### 5. Access SpeakMate

1. Open the app on your Android device/emulator
2. Navigate to "Daily Lessons" (third tab)
3. Tap the floating "Practice Speaking" button or the chat icon in the app bar
4. Grant microphone permissions when prompted

## Usage

1. **Start a Conversation**: Tap the microphone button and speak in English
2. **Get Corrections**: The AI will gently correct grammar mistakes
3. **Learn Phrases**: Ask for common phrases or vocabulary tips
4. **Practice Pronunciation**: Listen to the AI's responses

## Server Endpoints

- `POST http://localhost:5000/chat` - Send messages to AI
- `GET http://localhost:5000/health` - Check server status
- `GET http://localhost:5000/models` - List available models

## Troubleshooting

### "AI server not reachable"
- Make sure Ollama is running: `ollama serve`
- Check that the chat server is running: `npm start` in ollama-chat-server
- Verify the server is accessible: http://localhost:5000/health

### "Speech recognition not available"
- Grant microphone permissions in Android settings
- Check that your device has speech recognition support

### "No models found"
- Install at least one model: `ollama pull gemma2:2b`
- Run `ollama list` to see installed models

### Flutter Dependencies Issues
If you get dependency conflicts:
```bash
flutter clean
flutter pub get
```

## Testing the Server

Test the chat server independently:
```bash
cd ollama-chat-server
npm test
```

## Development

### Changing the AI Model
Edit `ollama-chat-server/server.js` and modify the `preferredModels` array.

### Adjusting the System Prompt
The AI's behavior can be customized by editing the `systemPrompt` in `server.js`.

### Changing the Server Port
1. Edit `ollama-chat-server/.env`
2. Update `lib/daily_lessons/speak_mate/services/api_service.dart`

## Project Structure

```
farahs_hub/
├── lib/daily_lessons/
│   ├── speak_mate/
│   │   ├── models/
│   │   │   └── chat_message.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   └── speech_service.dart
│   │   ├── controllers/
│   │   │   └── speak_mate_controller.dart
│   │   └── pages/
│   │       └── speak_mate_page.dart
│   └── LessonPage.dart (with SpeakMate navigation)
└── ollama-chat-server/
    ├── server.js
    ├── list-models.js
    ├── test-chat.js
    ├── package.json
    └── README.md
```

## Next Steps

1. Start Ollama: `ollama serve`
2. Start the chat server: `cd ollama-chat-server && npm start`
3. Run the Flutter app: `flutter run`
4. Navigate to Daily Lessons → Practice Speaking
5. Start practicing English!

Enjoy learning English with SpeakMate! 🎉
