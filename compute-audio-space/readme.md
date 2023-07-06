## Compute Invariant Space From Audio
Compute Fourier Transform of:
- the original sample (a-b-c-d)
- the reversed sample (d-c-b-a)
- the palindromic sample (a-b-c-d-d-c-b-a)


**run the script**
```bash
bash compute-audio-space/run -s target_directory

#Compute FFt of audio file / reversed / palindromic
bash compute-audio-space/run -s /c/Users/marce/Maths/Data/Audio/Unittest

#Compute FFt of audio file / chop #1 / chop #2 / chop #3 .. / chop #N
## 0: |----------------------------------------------------------------|
## 1: |--------------------------------|
## 2: |----------------|
## 3: |--------|
bash compute-audio-space/run -s /c/Users/marce/Maths/Data/Audio/Unittest -m fractal -l 5
```