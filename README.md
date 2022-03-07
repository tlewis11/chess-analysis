This repo allows you to play against stockfish.
engine service - Flask App that leverages pystockfish to analyze fen or pgn strings.
frontend service - React App that allows a player to play against Stockfish

# required tools:
docker compose
make

# Quick Start: 

build docker images and run services with docker-compose
```
make build
make run
```

Browse to localhost:3000 and play as white against Stockfish. 

Access Stockfish API directly at localhost:5000 
