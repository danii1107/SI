MATCH (hattie:Actor {name: "Winston, Hattie"})-[:ACTED_IN]->(m:Movie)
WITH hattie, collect(m) AS hattieMovies
MATCH (m)<-[:ACTED_IN]-(coactor:Actor)
WHERE NOT coactor = hattie
WITH coactor, hattie
MATCH (coactor)-[:ACTED_IN]->(m2:Movie)<-[:ACTED_IN]-(otherActor:Actor)
WHERE NOT (otherActor)-[:ACTED_IN]->()<-[:ACTED_IN]-(hattie)
AND NOT otherActor = hattie
RETURN DISTINCT otherActor.name AS ActorName
ORDER BY ActorName
LIMIT 10;