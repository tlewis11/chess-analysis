from pystockfish import *
fen_string = "r1bqkbnr/pp3p1p/2n1p1p1/2p5/2B1P3/2N2N2/PP1P1PPP/R1BQ1RK1 w kq - 0 8"

deep = pystockfish.Engine(depth=20)
deep.setposition(fen_string)
print(deep.bestmove())