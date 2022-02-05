#!/bin/bash

docker build -t pgn-analyzer .
docker run -it -p 5000:5000 pgn-analyzer