open Graph
(*open Tools*)
(*open Gfile*)

(*on considere que le label sur les arc du graph d'origine est le flot max quils peuvent supporté*)
(*le labels sur les graphs d'ecart sera la valeur de flot actuelle*)

let init_graph_ecart (g_origine : int graph) =
  let g2 =g_origine in
  let transfo g arc=new_arc g {src = arc.tgt ;tgt=arc.src; lbl=0 }in
  e_fold g2 transfo (g2);



  (*On boucle sur chaque arc pour calculer l'ecart dispo pour le mettre dans notre nouveau graph*)