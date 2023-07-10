## Reverse Audio Files

Convert audio files from a`source` directory (a-b-c-d) to:
- `source/.reversed` (d-c-b-a)
- `source/.palindromic` (a-b-c-d-d-c-b-a)

*Note: only .wav files are supported.*
 
**Run the script**
```bash
$ bash transform-av/reverse/run -s target_directory
```

**Example**
```bash
$ bash transform-av/reverse/run -s /c/Users/marce/Maths/Data/Audio/Unittest
```