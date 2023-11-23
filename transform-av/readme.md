## Transform Audio or Video File


### Overview

This operator transforms sequentially audio/video files in a source directory.
The transform results are written into the source directory, whether into a subdirectory (`.fft`, `.interpolate`) or if collision, the original files are migrated into a backup directory (`.orig`).
````bash
$ bash transform-av/[command]/run -s source_directory
````

The transform commands are listed below:

| transform   | purpose                        | doc                           |
|-------------|--------------------------------|-------------------------------|
| chop        | recursive cut of an audio file | [here](chop/readme.md)        |
| compute     | compute the fourier transform  | [here](compute/readme.md)     |
| downsize    | reduce a video size            | [here](downsize/readme.md)    |
| interpolate | extrapolate an audio file      | [here](interpolate/readme.md) |
| reverse     | play in reverse an audio file  | [here](reverse/readme.md)     |


### Testing

Pay attention to the testcases passing, before pushing the code to the `main` branch. The testcases are a safety to net to ensure basic statement of the transforrm command won't break. 
Please keep in mind those testcases don't cover all scenarios. a-k-a "*it is not because the testcases passed that the overall statement is not broken.*" <br><br>
The logic behind those testcases is to check degraded statement. If the degraded statement is false, then the general statement is false.
If the degraded statement is true, we cannot say the general statement is true. 
See example: <br>
- general statetement: *"The brother of Paul is an hardworking person."*
- testcase statement: *"Paul has a brother."*

Testcases must pass the [ci](../.github/workflows/ci.yml):


| testcase              | purpose                                                                                                      | code                                                                                      |
|-----------------------|--------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------|
| dry-run               | run with no entry transform scripts <br> and check if no harm done.                                          | [here](../tests/dry-run.sh)                                                              |
| transform-reverse     | reverse two times audio sample <br> and checksum if is identical to original sample.                         | [here](../tests/av-transform-reverse.sh)                                                 |
| transform-interpolate | chop in small pieces an audio sample <br> and checksum if back interpolation.                                | [here](../tests/av-transform-interpolate.sh)                                             |
| compute*              | run expensive computation of Fourier Transforms <br> and check outputs file are in type and number expected. | [test1](../tests/av-testcase-compute.sh) <br> [test2](../tests/av-testcase-compute-2.sh) |

