open Graph
open Tools
(*open Gfile*)

(*on considere que le label sur les arc du graph d'origine est le flot max quils peuvent supporté*)
(*le labels sur les graphs d'ecart sera la valeur de flot actuelle*)

let init_graph_ecart (g_origine : int graph) =
  let g2 = clone_nodes g_origine in
  let transfo g arc=
  let g = new_arc g arc in
  new_arc g {src = arc.tgt ;tgt=arc.src; lbl=0 }
  in
  e_fold g_origine transfo g2;;

let rec list_node_dest arcliste acu=
  match arcliste with
  | [] -> acu
  |{src=ids;tgt=idd;_}::rest->list_node_dest rest ((idd,ids)::acu);;

(*renvoi true si la node a ete visite false sinon*)
let rec is_visited (node,prec:id*id) (visited:(id*id)list)=
match visited with
| [] -> false
| (n,_)::rest ->(n=node) || (is_visited (node,prec) rest);;

let bfs gr s=
  let file =[(s,s)] in
  let visited=[(s,s)]in
  let rec action (liste_n:(id*id)list) (file:(id*id)list)  (visited:(id*id)list) = (*pour chaque node de liste_n si elle n'est pas visite on la met dans la file sinon rien*)
    match liste_n with
      |[]->(file,visited)
      |(n,p)::rest->if ((is_visited (n,p) visited)=false) then (action rest ((n,p)::file) ((n,p)::visited)) else action rest file visited
  in
  let rec boucle file visited =(*prend la premiere node de la file, regarde ses destination et les ajoute dans la file si elles ne sont pas visited (utilisation de action pour la decision)*)
    match file with
    |(n,_)::rest ->begin
      let (nv_file,visited)=action (list_node_dest (out_arcs gr n) []) [] visited in
      boucle (nv_file@rest) visited;
    end
    |[]->visited
  in
  boucle file visited
  ;;

(*renvois le duo (n,prec) avec n=node, si node n'est pas trouvé renvois (n,n)*)
let rec recup_node_visited visited node=
match visited with
|[]->(node,node)
| (n,p)::rest -> if (n=node) then (n,p) else recup_node_visited rest node;;

(*on met pas la source car elle est implicite c'est forcement la precedent de toutes les precedentes*)
(*A partir de la liste des notes visité (liste au format (node,precedente)) on retrouve le chemin menant a la node dest *)
(*si la node d n'est pas dans visited ie elle n'est pas atteinte on renvois []*)
let recup_chemin visited dest=
let rec boucle_while liste node_prec = 
    match node_prec with
    |(x,y)->if x=y then liste else (boucle_while ((x,y)::liste) (recup_node_visited visited y) )
in
let (d2,p2)=recup_node_visited visited dest in
if d2=p2 then [] else List.rev (boucle_while [(d2,p2)] (recup_node_visited visited p2))
;;

let trouve_chemin (gr : int graph) (source : id) (dest : id) =
  let visited = bfs gr source in
  recup_chemin visited dest;;

let trouve_arc gr ids idd=
match (find_arc gr ids idd) with
  |None->{src=ids ;tgt=idd ;lbl=0}(*arc fictif generer si il existe pas, notement arc src src*)
  |Some arci->{src=arci.src ;tgt=arci.tgt ;lbl=arci.lbl};;
;;

let rec capacite_min chemin c_min gr_ecart=(*recupere la valeur d'augmentation de flot du chemin*)
  match chemin with
  |[]->c_min
  |(n,p)::rest->capacite_min rest (min c_min (abs (trouve_arc gr_ecart p n).lbl) ) gr_ecart;;


let rec maj_flot chemin valeur gr2 gr_ecart=(*applique les changement de flot au graph gr2 le long du parcours*)
  match chemin with
  |[]->gr2
  |(n,p)::rest->begin
    let arc = trouve_arc gr_ecart p n in
    if (arc.lbl >0) then maj_flot rest valeur (add_arc gr2 p n valeur) gr_ecart
    else maj_flot rest valeur (add_arc gr2 n p (-valeur)) gr_ecart
  end;;

let graph_ecart gr2 gr0 =(*renvois le graph d'ecart*)
  let gr_vide=clone_nodes gr0 in

  let transfo gr arc_orig =
    let s =arc_orig.src in
    let d=arc_orig.tgt in
    let valeur=arc_orig.lbl in

    let flot =match find_arc gr2 s d with
      | Some a ->a.lbl
      | None ->0
    in

    let gr = if ((valeur-flot)>0) then new_arc gr {src=s;tgt=d;lbl=valeur-flot}
      else gr
    in

    let gr = if (flot > 0) then new_arc gr {src=d;tgt=s;lbl=flot}
      else gr
    in
    gr
  in
  e_fold gr0 transfo gr_vide;;

(*renvoi le flot max du graph, qui est la somme des label sortant de la source*)
let flot_max gr s=
  let rec boucle liste_arc acu=
    match liste_arc with
    |[]->acu
    |e::rest->boucle rest (acu+e.lbl)
  in
  boucle (out_arcs gr s) 0;;

let floyd_fulkerson(gr:int graph) (source:id) (dest:id)=
  let gr2=gmap gr (fun x->x*0) in 
  let gr_ecart0 = init_graph_ecart gr in
  let rec boucle_while gr2 gr_ecart source dest=
    let chemin = trouve_chemin gr_ecart source dest in
    if (chemin =[]) then gr2
    else
      let valeur = capacite_min chemin max_int gr_ecart in
      let nv_gr2 = maj_flot chemin valeur gr2 gr_ecart in
      let nv_gr_ecart = graph_ecart nv_gr2 gr in
      boucle_while nv_gr2 nv_gr_ecart source dest;
    in
  
  boucle_while gr2 gr_ecart0 source dest;;





  (*On boucle sur chaque arc pour calculer l'ecart dispo pour le mettre dans notre nouveau graph*)