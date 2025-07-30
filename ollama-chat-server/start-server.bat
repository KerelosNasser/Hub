@echo off
echo Starting SpeakMate Chat Server...
echo.

REM Check if Node.js is installed
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if npm packages are installed
if not exist "node_modules" (
    echo Installing dependencies...
    npm install
    echo.
)

REM Check if Ollama is running
curl -s http://localhost:11434/api/version >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Ollama doesn't appear to be running!
    echo Please start Ollama in another terminal with: ollama serve
    echo.
    pause
)

REM Start the server
echo Starting server on http://localhost:5000
npm start
