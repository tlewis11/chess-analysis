#!/bin/bash

docker build -t pgn-analyzer .
docker run -it pgn-analyzer
