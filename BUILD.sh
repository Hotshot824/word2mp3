#!/usr/bin/env bash

# Build script for word2mp3 - Compile Python script to executable binary

# Set a virtual environment.
VENV_DIR=".venv_word2mp3"
BUILD_DIR="build"
DIST_DIR="dist"
OUTPUT_NAME="word2mp3"
USE_VENV=0

echo "Starting build process for word2mp3"
echo ""

echo "[Step 1/5] Checking system requirements..."

# Check if Python is available and prefer ones with shared library support
PYTHON_CMD=""
PYTHON_FOUND=0

# Function to check if Python has shared library support
check_shared_lib() {
    local py_cmd="$1"
    if $py_cmd -c "import sysconfig; exit(0 if sysconfig.get_config_var('Py_ENABLE_SHARED') else 1)" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Try different Python commands in order of preference
for py_candidate in python3 python /usr/bin/python3; do
    if command -v "$py_candidate" &> /dev/null; then
        PYTHON_VERSION=$($py_candidate --version 2>&1)
        if [[ $PYTHON_VERSION == *"Python 3"* ]]; then
            if check_shared_lib "$py_candidate"; then
                PYTHON_CMD="$py_candidate"
                echo "[Info] Using: $PYTHON_VERSION (with shared library support)"
                PYTHON_FOUND=1
                break
            else
                echo "[Warning] Found $PYTHON_VERSION but without shared library support"
            fi
        fi
    fi
done

# If no Python with shared lib found, use any available Python 3 and warn
if [ $PYTHON_FOUND -eq 0 ]; then
    for py_candidate in python3 python; do
        if command -v "$py_candidate" &> /dev/null; then
            PYTHON_VERSION=$($py_candidate --version 2>&1)
            if [[ $PYTHON_VERSION == *"Python 3"* ]]; then
                PYTHON_CMD="$py_candidate"
                echo "[Warning] Using: $PYTHON_VERSION (without shared library support)"
                echo "[Warning] PyInstaller might fail. Consider using Python built with --enable-shared"
                PYTHON_FOUND=1
                break
            fi
        fi
    done
fi

if [ $PYTHON_FOUND -eq 0 ]; then
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
    VENV_PYTHON="$VENV_DIR/Scripts/python"
else
    # Unix-like environment (Linux, macOS)
    VENV_BIN_DIR="$VENV_DIR/bin"
    VENV_PIP="$VENV_DIR/bin/pip"
    VENV_PYINSTALLER="$VENV_DIR/bin/pyinstaller"
    VENV_PYTHON="$VENV_DIR/bin/python"
fi

# Try to create virtual environment, fallback to user install if it fails
if $PYTHON_CMD -m venv $VENV_DIR 2>/dev/null; then
    echo "[Info] Created virtual environment successfully"
    $VENV_PIP install --upgrade pip --quiet 2>/dev/null
    USE_VENV=1
else
    echo "[Warning] Could not create virtual environment, will install packages to user directory"
    USE_VENV=0
fi

echo ""
echo "[Step 3/5] Installing dependencies..."

if [ $USE_VENV -eq 1 ]; then
    echo "[Info] Installing packages in virtual environment..."
    $VENV_PIP install --upgrade gTTS click pyinstaller --quiet
    PYINSTALLER_CMD="$VENV_PYINSTALLER"
    echo "[Info] Using virtual environment packages"
else
    echo "[Info] Installing packages to user directory..."
    # Try different pip install methods
    if $PYTHON_CMD -m pip install --user --upgrade gTTS click pyinstaller --quiet 2>/dev/null; then
        echo "[Info] Packages installed successfully"
    elif $PYTHON_CMD -m pip install --user --upgrade gTTS click pyinstaller --quiet --break-system-packages 2>/dev/null; then
        echo "[Info] Packages installed successfully (with --break-system-packages)"
    else
        echo "[Warning] Could not install via pip, trying to continue..."
    fi
    PYINSTALLER_CMD="$PYTHON_CMD -m PyInstaller"
fi
echo "[Info] Dependencies ready."

echo ""
echo "[Step 4/5] Cleaning previous builds..."
rm -rf $BUILD_DIR $DIST_DIR *.spec
echo "[Info] Old build artifacts removed."

echo ""
echo "[Step 5/5] Building executable..."
$PYINSTALLER_CMD \
    --onefile \
    --name $OUTPUT_NAME \
    --clean \
    word2mp3.py

echo ""
# Check if build was successful
EXE_EXT=""
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    EXE_EXT=".exe"
fi

if [ -f "$DIST_DIR/$OUTPUT_NAME$EXE_EXT" ]; then
    echo "[Result] Build completed successfully."
    echo "Executable created: $DIST_DIR/$OUTPUT_NAME$EXE_EXT"
    echo ""
    echo "Usage examples:"
    echo "  ./$DIST_DIR/$OUTPUT_NAME$EXE_EXT \"hello world\""
    echo "  ./$DIST_DIR/$OUTPUT_NAME$EXE_EXT \"hello world\" -o output_folder"
    echo "  ./$DIST_DIR/$OUTPUT_NAME$EXE_EXT                (for interactive mode)"
    echo ""
    if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "cygwin" && "$OSTYPE" != "win32" ]]; then
        echo "To install globally (Linux/macOS):"
        echo "  sudo cp $DIST_DIR/$OUTPUT_NAME /usr/local/bin/"
    fi
else
    echo "[Result] Build failed."
    echo "Please check error messages above."
    exit 1
fi
