#!/usr/bin/env bash

# Build script for word2mp3 - Compile Python script to executable binary

# Set a virtual environment.
VENV_DIR=".venv_word2mp3"
BUILD_DIR="build"
DIST_DIR="dist"
OUTPUT_NAME="word2mp3"

echo "Starting build process for word2mp3"
echo ""

echo "[Step 1/5] Checking system requirements..."

# Check if Python is available
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    echo "[Info] Detected: $(python3 --version)"
elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version 2>&1)
    if [[ $PYTHON_VERSION == *"Python 3"* ]]; then
        PYTHON_CMD="python"
        echo "[Info] Detected: $PYTHON_VERSION"
    else
        echo "[Error] Python 3 is required, but found: $PYTHON_VERSION"
        echo "Please install Python 3.6 or later."
        exit 1
    fi
else
    echo "[Error] Python 3 not found in PATH."
    echo "Please install Python 3.6 or later and ensure it is accessible."
    echo ""
    echo "Installation instructions:"
    echo "  - Windows: Download from https://python.org"
    echo "  - macOS:   brew install python3"
    echo "  - Linux:   sudo apt install python3 python3-venv"
    exit 1
fi

echo ""
echo "[Step 2/5] Setting up virtual environment..."

# Detect OS and set appropriate paths
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    # Windows environment
    VENV_BIN_DIR="$VENV_DIR/Scripts"
    VENV_PIP="$VENV_DIR/Scripts/pip"
    VENV_PYINSTALLER="$VENV_DIR/Scripts/pyinstaller"
else
    # Unix-like environment (Linux, macOS)
    VENV_BIN_DIR="$VENV_DIR/bin"
    VENV_PIP="$VENV_DIR/bin/pip"
    VENV_PYINSTALLER="$VENV_DIR/bin/pyinstaller"
fi

if [ ! -d "$VENV_DIR" ]; then
  echo "[Info] Creating new virtual environment..."
  $PYTHON_CMD -m venv $VENV_DIR
  $VENV_PIP install --upgrade pip > /dev/null
else
  echo "[Info] Reusing existing virtual environment."
fi

echo ""
echo "[Step 3/5] Installing dependencies..."
$VENV_PIP install --quiet --upgrade gTTS click pyinstaller
echo "[Info] Dependencies installed."

echo ""
echo "[Step 4/5] Cleaning previous builds..."
rm -rf $BUILD_DIR $DIST_DIR *.spec
echo "[Info] Old build artifacts removed."

echo ""
echo "[Step 5/5] Building executable..."
$VENV_PYINSTALLER \
    --onefile \
    --name $OUTPUT_NAME \
    --clean \
    word2mp3.py

echo ""
# Check if build was successful
if [ -f "$DIST_DIR/$OUTPUT_NAME" ]; then
    echo "[Result] Build completed successfully."
    echo "Executable created: $DIST_DIR/$OUTPUT_NAME"
    echo ""
    echo "Usage examples:"
    echo "  ./$DIST_DIR/$OUTPUT_NAME \"hello world\""
    echo "  ./$DIST_DIR/$OUTPUT_NAME \"hello world\" -o output_folder"
    echo ""
    echo "To install globally (Linux/macOS):"
    echo "  sudo cp $DIST_DIR/$OUTPUT_NAME /usr/local/bin/"
else
    echo "[Result] Build failed."
    echo "Please check error messages above."
    exit 1
fi
