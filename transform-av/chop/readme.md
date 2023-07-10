## Slice Audio Files

Chop recursively by half, all audio files from a `source` directory into `source/.chopped` 

Chopped files are suffixed by `.y.wav`

*Note: only .wav files are supported.*
 
**Run the script**
```bash
bash transform-av/chop/run -s target_directory -l N
```

**Example**
```bash
## s) source directory
## l) level of recursive cutting
$ bash transform-av/chop/run -s /c/Users/marce/Maths/Data/Audio/Unittest -l 5
```