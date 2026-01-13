open Graph

val clone_nodes: 'a graph -> 'b graph (*returns a new graph having the same nodes than gr, but no arc.*)
val gmap: 'a graph -> ('a -> 'b) -> 'b graph (* maps all arcs of gr by function f.*)
val add_arc: int graph -> id -> id -> int -> int graph (*adds n to the value of the arc between id1 and id2. If the arc does not exist, it is created.*)
val aff_visited: (id*id)list->unit
val count_nodes:int graph -> int