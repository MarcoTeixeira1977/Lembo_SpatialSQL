--# spatial interaction : Distance, Adjacency and Interaction matrices

SELECT * FROM upstate

--

SELECT a.name, b.name ST_distance(a.geometry,b.geometry) AS dist
FROM upstate AS a, upstate AS b




--# geographic analysis : Nearest Neighbor Index


