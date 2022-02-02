import chess.pgn

import pystockfish


def suggest_move(moves=[]):
  deep = pystockfish.Engine(depth=20)
  deep.setposition(moves)
  print(deep.bestmove())

# parse a pgn file
pgn = open('Emptyseat_vs_slfotg_2022.01.21.pgn', 'r')
first_game = chess.pgn.read_game(pgn)
suggest_move(moves=[move.uci() for move in first_game.mainline_moves()])
#board = first_game.board()
#for move in first_game.mainline_moves():
#  board.push(move)
#print(board)
#print(board.fen())

# do an analysis of the game
# get the current position and game info
# recommend the best move(s)