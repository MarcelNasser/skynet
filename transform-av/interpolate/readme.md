## Interpolate Audio Files

Augment all audio files from a `source` directory into `source/.interpolated`. 

The augmentation method is an interpolation (not really sure of the algorithm right now).

Assume original files are (a-b-c-d), the augmented files of given factors are:
- **x 2**: (a-b-c-d-a'-b'-c'-d')
- **x 3**: (a-b-c-d-a'-b'-c'-d'-a"-b"-c"-d")

Augmented files are suffixed by `.x.wav`

*Note: only .wav files are supported.*
 
**Run the script**
```bash
$ bash transform-av/interpolate/run -s source_directory -l N 
```

**Example**
```bash
## s) source directory
## l) augmentation factor
$ bash transform-av/interpolate/run -s /c/Users/marce/Maths/Data/Audio/Unittest -l 2 -m "linear"
```

**Example**
```bash
## s) source directory
## l) chopping factor
$ bash transform-av/interpolate/run -s /c/Users/marce/Maths/Data/Audio/Unittest -l 2 -m "palindromic"
```