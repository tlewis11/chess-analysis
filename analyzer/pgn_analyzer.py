import io
import chess.pgn

import pystockfish

def suggest_move(fen=None, pgn=None):
  print(pgn)
  print(fen)

  deep = pystockfish.Engine(depth=20)
  
  if fen is not None:
    deep.setfenposition(fen)
  elif pgn is not None:
    pgn_io = io.StringIO(pgn)
    first_game = chess.pgn.read_game(pgn_io)
    moves=[move.uci() for move in first_game.mainline_moves()]
    deep.setposition(moves)
  else:
    return 'error: pgn or fen is required.'

  best_move = deep.bestmove()['move']
  return best_move

if __name__ == '__main__':
  # parse a pgn file
  pgn = open('Emptyseat_vs_slfotg_2022.01.21.pgn', 'r')
  first_game = chess.pgn.read_game(pgn)
  fen_string = 'r1bqk1nr/p4pbp/2p1p1p1/2p5/4P3/2N2N2/PP1P1PPP/R1BQ1RK1 w kq - 0 10'
  stockfish_move = suggest_move(fen=fen_string)
  

  print(stockfish_move)
  
  #board = first_game.board()
  #for move in first_game.mainline_moves():
  #  board.push(move)
  #print(board)
  #print(board.fen())
  
  # do an analysis of the game
  # get the current position and game info
  # recommend the best move(s)