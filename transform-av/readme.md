## Transform Audio or Video File

*Transforms list:*

| transform   | purpose                        | doc                           |
|-------------|--------------------------------|-------------------------------|
| chop        | recursive cut of an audio file | [here](chop/readme.md)        |
| compute     | compute the fourier transform  | [here](compute/readme.md)     |
| downsize    | reduce a video size            | [here](downsize/readme.md)    |
| interpolate | extrapolate an audio file      | [here](interpolate/readme.md) |
| reverse     | play in reverse an audio file  | [here](reverse/readme.md)     |



*Test cases (must pass the [ci](../.github/workflows/ci.yml)):*


| testcase              | purpose                                                                                                      | doc                                                                                      |
|-----------------------|--------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------|
| dry-run               | run with no entry transform scripts <br> and check if no harm done.                                          | [here](../tests/dry-run.sh)                                                              |
| transform-reverse     | reverse two times audio sample <br> and checksum if is identical to original sample.                         | [here](../tests/av-transform-reverse.sh)                                                 |
| transform-interpolate | chop in small pieces an audio sample <br> and checksum if back interpolation.                                | [here](../tests/av-transform-interpolate.sh)                                             |
| compute*              | run expensive computation of Fourier Transforms <br> and check outputs file are in type and number expected. | [test1](../tests/av-testcase-compute.sh) <br> [test2](../tests/av-testcase-compute-2.sh) |

