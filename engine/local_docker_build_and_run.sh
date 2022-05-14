#!/bin/bash

docker build -t stockfish-engine .
docker run -it -p 5000:5000 stockfish-engine