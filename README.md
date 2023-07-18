# Skynet (*Ops-Scripts*)
[![Build Status](https://img.shields.io/github/actions/workflow/status/docker/buildx/build.yml?branch=master&label=build&logo=github&style=flat-square)](https://github.com/MarcelNasser/ops-script/actions?query=workflow%3Abuild)

The philosophy of this repo is to provide handy scripts no more complex than a `curl` command. Please keep in mind, the scripts are executed on random machines with unsure environments.
The scripts must require minimum stuff to compile and run. 

## Practical example of the philosophy
Let's take the example of a Python script.<br><br>
Whenever you write a python script, we strongly recommend built-in libraries to external libraries. This avoids the introduction of an additional layer of complexity to the script compilation. 
If you write your python script with only built-in libraries, the only requirement is that the python's version corresponds to the version you implemented and tested your script.<br><br> 
At the script's entrypoint, you must check if the python version is present on the machine. Therefore, your script has good chances to run smoothly on the given machine. If your script is not too complex even a compatible major version will do...

## Scripts structure 
All scripts have the same structure:
````
script-abc/
 |_ run
 |_ shared/ 
    |_ scripts.py
    |_ args.sh
````

Below some details about the scripts structure:
- *run*: entrypoint main `bash` script handling high-level calls of other scripts and passing arguments
- *shared*: utility scripts in `python` that handle data and datastructures
- *external*: external program calls. Those programs must be installed on the machine where the script is executed. 

The main script must run dependencies check and warn if something is missing. For example, below we check python version with a regex and crash if the check fails:
````bash
python3 --version | grep -E "Python 3.([7-9]|1[0-1])\..*" >/dev/null \
||  { echo "Python version is not between 3.7 and 3.11"; exit 2; }
````

## Scripts List 
Here is a non-exhaustive list of scripts implemented in the repos and their main purpose. 
There are additional readme files into scripts directory. Those readmes explain scripts fine-graded manipulation:
- **transform-av** => handle audio/videos for scientific computation 
- **backup-registry** => archive all docker container(s) from a docker registry to google drive
- **azure-cleanup** => remove azure resource groups
- **azure-filesystem** => install azurefile and start the service
- **upload-logs** => push logs files to a data store
- **browse-github** => scrap GitHub public repos from a specific company


## Testing
Tests Suite is written in Bash.
- test case `dry-run.sh`: run scripts with arguments to zero and check if nothing is done and no error thrown
- test case `compute-audio.sh`: check if the computational scripts output files in expected types 
- test case `browse-github.sh`: check 'docker' has at least 100 public repos on GitHub
- test case `reverse-audio.sh`: check if a two times reversal of an audio file gives the same audio file.
- test case `heavy-compute-audio.sh`: run expensive computation and check outputs file are in type and number expected
- test case `chop-and-interpolate.sh`: check if an original audio can back interpolated 

## Build & Automation
A docker image is built to ease the run of scripts herein on remote machines. 

The docker image is released on docker-hub: **marcelndeffo/tools:ops-scripts**

- pull public docker image (no login)
````bash
docker pull marcelndeffo/tools:ops-scripts
````
- open a bash terminal in the container
````bash
docker run -t -i marcelndeffo/tools:ops-scripts bash
````
- run the script into docker
````bash
# browse facebook
root@d9efa96261a9:/src# browse-github/run -o facebook
repos 127
# do some stuff...
root@d9efa96261a9:/src# tests/dry-run.sh
root@d9efa96261a9:/src# tests/heavy-compute-audio.sh
#exit
root@d9efa96261a9:/src# exit
````
- build and test your local changes (**must do this before all git push**)
````bash
# build
docker compose build
# jump in the container for advanced testing
docker compose run ops-scripts
````

- inside the docker container the filestructure is:
````txt
/src/
 |__ script-a
    |__ run
 |__ script-b
    |__ run
/data/
 |__ audio
````

*Note: Do not forget the edit docker-compose file your local data into the docker container.*
````yaml
    volumes:
      - type: bind
        source: $PWD/tests/data/audio  # Replace here with your local data
        target: /data/audio
````
