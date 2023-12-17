MATCH (p1:Person)-[:ACTED_IN|DIRECTED]->(m:Movie)<-[:ACTED_IN|DIRECTED]-(p2:Person)
WHERE id(p1) < id(p2)
WITH p1, p2, COLLECT(m.title) AS sharedMovies
WHERE SIZE(sharedMovies) > 1
RETURN p1.name AS Person1, p2.name AS Person2, sharedMovies
ORDER BY SIZE(sharedMovies) DESC, Person1, Person2;
