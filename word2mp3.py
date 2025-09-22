import click
import os
from enum import Enum
from gtts import gTTS
from typing import Optional


class Language(Enum):
    """Supported language enumeration"""
    ENGLISH = "en"
    CHINESE = "zh-tw"
    CHINESE_SIMPLIFIED = "zh-cn"
    JAPANESE = "ja"
    KOREAN = "ko"
    SPANISH = "es"
    FRENCH = "fr"
    GERMAN = "de"


def text_to_mp3(text: str, output_path: Optional[str] = None, 
                language: Language = Language.ENGLISH) -> str:
    """
    Convert text to MP3 file using Google Text-to-Speech
    
    Args:
        text: Text to convert to speech
        output_path: Output directory (optional, defaults to current directory)
        language: Language setting (defaults to English)
    
    Returns:
        str: Path to the generated MP3 file
    """
    tts = gTTS(text, lang=language.value)
    
    # Create safe filename by replacing problematic characters
    safe_text = "".join(c for c in text if c.isalnum() or c in (' ', '-', '_')).rstrip()
    safe_text = safe_text.replace(' ', '_')
    
    # Handle output path
    if output_path:
        # Ensure output directory exists
        os.makedirs(output_path, exist_ok=True)
        filename = os.path.join(output_path, f"{safe_text}.mp3")
    else:
        filename = f"{safe_text}.mp3"
    
    tts.save(filename)
    return filename


def run_repl():
    """Run interactive REPL mode"""
    print("=== Word2MP3 Interactive Mode ===")
    print("Enter text to convert, type 'quit()' or 'exit()' to leave")
    print("Supported languages: en (English), zh-tw (Traditional Chinese), zh-cn (Simplified Chinese), ja (Japanese), ko (Korean)")
    print("Format: <text> [language_code] [output_directory]")
    print("Example: hello world en /tmp/output")
    print("Note: Use quotes for text with spaces if you need to specify language/output")
    print("-" * 50)
    
    while True:
        try:
            user_input = input(">>> ").strip()
            
            if user_input.lower() in ['quit()', 'exit()']:
                print("Goodbye!")
                break
                
            if not user_input:
                continue
                
            # Parse input - improved parsing logic
            parts = user_input.split()
            text = None
            lang = Language.ENGLISH
            output = None
            
            # Check if input starts with quotes (for text with spaces)
            if user_input.startswith('"') and '"' in user_input[1:]:
                # Handle quoted text
                quote_end = user_input.index('"', 1)
                text = user_input[1:quote_end]
                remaining = user_input[quote_end+1:].strip().split()
                
                # Parse language and output from remaining parts
                if len(remaining) > 0:
                    try:
                        lang = next(l for l in Language if l.value == remaining[0])
                    except StopIteration:
                        print(f"Warning: Unsupported language code '{remaining[0]}', using English")
                
                if len(remaining) > 1:
                    output = remaining[1]
                    
            else:
                # Check if last parts are language codes or paths
                valid_langs = [l.value for l in Language]
                
                # Default: treat entire input as text
                text = user_input
                
                # But check if last 1 or 2 parts could be lang/output
                if len(parts) >= 2:
                    # Check if last part could be output directory and second-to-last is language
                    if len(parts) >= 3 and parts[-2] in valid_langs:
                        lang = next(l for l in Language if l.value == parts[-2])
                        output = parts[-1]
                        text = " ".join(parts[:-2])
                    # Check if last part is language code
                    elif parts[-1] in valid_langs:
                        lang = next(l for l in Language if l.value == parts[-1])
                        text = " ".join(parts[:-1])
            
            if not text:
                print("Error: No text provided")
                continue
            
            # Convert
            filename = text_to_mp3(text, output, lang)
            print(f"✓ Saved: {filename}")
            
        except KeyboardInterrupt:
            print("\nGoodbye!")
            break
        except Exception as e:
            print(f"Error: {e}")


@click.command()
@click.argument("text", required=False)
@click.option("-o", "--output", help="Output directory (default: current directory)")
@click.option("-l", "--lang", 
              type=click.Choice([lang.value for lang in Language]),
              default=Language.ENGLISH.value,
              help="Language setting")
def main(text, output, lang):
    """Word2MP3: Convert text to MP3 audio files
    
    Usage:
      word2mp3 "hello"           - Convert text to hello.mp3 in current directory
      word2mp3 "hello" -o /path  - Convert text to hello.mp3 in specified directory
      word2mp3                   - Start interactive REPL mode
    """
    
    # If no text provided, start REPL mode
    if not text:
        run_repl()
        return
    
    # Direct conversion mode
    try:
        # Find corresponding language enum
        language = next(l for l in Language if l.value == lang)
        filename = text_to_mp3(text, output, language)
        print(f"✓ Saved: {filename}")
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
