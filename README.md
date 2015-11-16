# PhenoMeNal - Micro services
### IPO - V 0.1

usage

On the main directory, to build the image:
```
docker build -t ipo .
```

And then to run:

```
docker run ipo -i /complete/path/to/filesPaths -o /complete/path/to/out
```

On Mac OS X with docker-machine, because there is this intermediate VM, it is recommended to mount a high level directory on docker (as /Users, which will be already mounted on the docker-machine VM.

```
docker run -v /Users:/Users ipo -i /Users/yourUser/path/to/filesPaths -o /Users/yourUser/path/to/out
```

IPO has a number of options, which we have wrapped for you, to find them out please execute:

```
docker run ipo
```
