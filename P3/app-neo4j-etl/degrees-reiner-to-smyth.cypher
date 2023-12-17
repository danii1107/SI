MATCH (director:Person {name: "Reiner, Carl"}), (actor:Person {name: "Smyth, Lisa (I)"}),
      path = shortestPath((director)-[:ACTED_IN|DIRECTED*]-(actor))
RETURN path
