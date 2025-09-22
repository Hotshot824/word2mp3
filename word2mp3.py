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
    
    # Handle output path
    if output_path:
        # Ensure output directory exists
        os.makedirs(output_path, exist_ok=True)
        filename = os.path.join(output_path, f"{text}.mp3")
    else:
        filename = f"{text}.mp3"
    
    tts.save(filename)
    return filename


def run_repl():
    """Run interactive REPL mode"""
    print("=== Word2MP3 Interactive Mode ===")
    print("Enter text to convert, type 'quit()' or 'exit()' to leave")
    print("Supported languages: en (English), zh-tw (Traditional Chinese), zh-cn (Simplified Chinese), ja (Japanese), ko (Korean)")
    print("Format: <text> [language_code] [output_directory]")
    print("Example: hello en /tmp/output")
    print("-" * 50)
    
    while True:
        try:
            user_input = input(">>> ").strip()
            
            if user_input.lower() in ['quit()', 'exit()']:
                print("Goodbye!")
                break
                
            if not user_input:
                continue
                
            # Parse input
            parts = user_input.split()
            text = parts[0]
            
            # Set language
            lang = Language.ENGLISH
            if len(parts) > 1:
                try:
                    lang_code = parts[1]
                    lang = next(l for l in Language if l.value == lang_code)
                except (StopIteration, IndexError):
                    print(f"Warning: Unsupported language code '{parts[1]}', using English")
            
            # Set output directory
            output = None
            if len(parts) > 2:
                output = parts[2]
            
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
