## Compute Invariant Space From Audio
Compute Fourier Transform of:
- the original sample (a-b-c-d)
- the reversed sample (d-c-b-a)
- the palindromic sample (a-b-c-d-d-c-b-a)
- the recursive chops  (a-b-c-d) -> (a-b) -> (a)

Three computation methods:

- method 1: `default`
```bash
#
#Compute FFt of audio file / reversed / palindromic
## 0: |-a-b-c-d-|
## 1: |-d-c-b-a-|
## 2: |-a-b-c-d-d-c-b-a-|
#
$ bash compute-audio-space/run -s /c/Users/marce/Maths/Data/Audio/Unittest -m default 
```

- method 2: `expensive`
```bash
#
#Chop the Sample in N part
#And compute method #1 above
#
$ bash compute-audio-space/run -s /c/Users/marce/Maths/Data/Audio/Unittest -m expensive -l 3
```

- method 3: `fractal`
```bash
#
#Compute FFt of audio file / chop #1 / chop #2 / chop #3 .. / chop #N
## 0: |----------------------------------------------------------------|
## 1: |--------------------------------|
## 2: |----------------|
## 3: |--------|
#
$ bash compute-audio-space/run -s /c/Users/marce/Maths/Data/Audio/Unittest -m fractal -l 3
```