#!/usr/bin/env bash

# Build script for word2mp3 - Compile Python script to executable binary

# Set a virtual environment.
VENV_DIR=".venv_word2mp3"  # Keep for compatibility but won't be used
BUILD_DIR="build"
DIST_DIR="dist"
OUTPUT_NAME="word2mp3"

echo "Starting build process for word2mp3"
echo ""

echo "[Step 1/5] Checking system requirements..."

# Check for system Python with shared library support first
if /usr/bin/python3 -c "import sysconfig; exit(0 if sysconfig.get_config_var('Py_ENABLE_SHARED') else 1)" 2>/dev/null; then
    PYTHON_CMD="/usr/bin/python3"
    echo "[Info] Using system Python: $(/usr/bin/python3 --version) (with shared library support)"
elif command -v python3 &> /dev/null; then
    # Check if the default python3 has shared library support
    if python3 -c "import sysconfig; exit(0 if sysconfig.get_config_var('Py_ENABLE_SHARED') else 1)" 2>/dev/null; then
        PYTHON_CMD="python3"
        echo "[Info] Detected: $(python3 --version) (with shared library support)"
    else
        echo "[Warning] Default python3 doesn't have shared library support, trying system python..."
        if /usr/bin/python3 -c "import sysconfig; exit(0 if sysconfig.get_config_var('Py_ENABLE_SHARED') else 1)" 2>/dev/null; then
            PYTHON_CMD="/usr/bin/python3"
            echo "[Info] Using system Python: $(/usr/bin/python3 --version) (with shared library support)"
        else
            echo "[Error] No Python with shared library support found."
            echo "PyInstaller requires Python built with --enable-shared"
            exit 1
        fi
    fi
elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version 2>&1)
    if [[ $PYTHON_VERSION == *"Python 3"* ]]; then
        if python -c "import sysconfig; exit(0 if sysconfig.get_config_var('Py_ENABLE_SHARED') else 1)" 2>/dev/null; then
            PYTHON_CMD="python"
            echo "[Info] Detected: $PYTHON_VERSION (with shared library support)"
        else
            echo "[Error] Python found but doesn't have shared library support."
            exit 1
        fi
    else
        echo "[Error] Python 3 is required, but found: $PYTHON_VERSION"
        exit 1
    fi
else
    echo "[Error] Python 3 not found in PATH."
    echo "Please install Python 3.6 or later and ensure it is accessible."
    exit 1
fi

echo ""
echo "[Step 2/5] Checking Python packages..."

# Check if required packages are available, install to user directory if needed
echo "[Info] Installing/updating required packages..."
$PYTHON_CMD -m pip install --user --upgrade gTTS click pyinstaller --quiet --break-system-packages 2>/dev/null || \
$PYTHON_CMD -m pip install --user --upgrade gTTS click pyinstaller --quiet 2>/dev/null || \
echo "[Warning] Could not install packages via pip, trying system packages..."

echo "[Info] Dependencies ready."

# Set paths for user-installed packages  
PYINSTALLER_CMD="$PYTHON_CMD -m PyInstaller"

echo ""
echo "[Step 3/5] Installing dependencies..."
$VENV_PIP install --quiet --upgrade gTTS click pyinstaller
echo "[Info] Dependencies installed."

echo ""
echo "[Step 3/5] Cleaning previous builds..."
rm -rf $BUILD_DIR $DIST_DIR *.spec
echo "[Info] Old build artifacts removed."

echo ""
echo "[Step 4/5] Building executable..."
$PYINSTALLER_CMD \
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
