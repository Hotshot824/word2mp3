# Word2MP3

A command-line tool to convert English text to MP3 audio files using Google Text-to-Speech.

## Features

- Convert text to MP3 audio files
- Custom output directory support  
- Standalone executable compilation
- Cross-platform compatibility

## Installation

### Prerequisites
- Python 3.6+
- Internet connection

### Build
```bash
./RUN.sh
```

## Usage

### Compiled Executable
```bash
# Basic usage
./dist/word2mp3 "Hello world"

# Specify output directory  
./dist/word2mp3 "Hello world" -o /path/to/output
```

### Python Script
```bash
python word2mp3.py "Hello world"
python word2mp3.py "Hello world" -o output_folder
```

## Options

- `-o, --output`: Output directory (default: current folder)
- `-h, --help`: Show help

## Dependencies

- gTTS - Google Text-to-Speech
- click - Command line interface
- PyInstaller - Executable compilation

## License

Open source project.