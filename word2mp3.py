import click
import os
from gtts import gTTS

@click.command()
@click.argument("word")
@click.option("-o", "--output", help="Output pahth (default: current folder)")
def main(word, output):
    tts = gTTS(word, lang="en")
    
    # Handle output path
    if output:
        # Ensure output directory exists
        os.makedirs(output, exist_ok=True)
        filename = os.path.join(output, f"{word}.mp3")
    else:
        filename = f"{word}.mp3"
    
    tts.save(filename)
    print(f"Saved {filename}")

if __name__ == "__main__":
    main()
