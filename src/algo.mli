open Graph
(*open Tools*)
(*open Gfile*)

val init_graph_ecart: int graph -> int graph(*genere le premier graph d'ecart*)

val floyd_fulkerson: int graph -> id -> id -> int graph

val flot_max : int graph -> id -> int