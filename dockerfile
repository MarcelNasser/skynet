### stage 1: building python
FROM marcelndeffo/tools:ffmpeg as pre-build

WORKDIR /src/

#building python
#python virtual env
RUN apt install -y python3-venv
RUN python3 -m venv /venv
ENV PATH=/venv/bin:$PATH
#sources dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

### stage 2: final image
FROM marcelndeffo/tools:ffmpeg

USER root

ENV VERBOSE 'TRUE'

WORKDIR /src/

# Fix font config warning
RUN apt-get update

RUN apt-get install fontconfig -y

#copying python binaries
COPY --from=pre-build /venv /venv
ENV PATH=/venv/bin:$PATH

#set entrypoint to bash
ENTRYPOINT '/bin/sh'
