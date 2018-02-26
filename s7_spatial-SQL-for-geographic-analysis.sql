--# spatial interaction : Distance, Adjacency and Interaction matrices
--Distance :

SELECT * FROM upstate                                                  -- 6 rows

--

SELECT a.name, b.name, ST_distance(a.geometry,b.geometry) AS dist
FROM upstate AS a, upstate AS b                                        -- 36 rows

--

SELECT a.name, b.name, (ST_distance(a.geometry,b.geometry,true)*0.00062)::text AS dist
FROM upstate AS a, upstate AS b
--The 0.00062 converts ft-to-miles. 'true' relates to use of ellipsoid
--"However, this SQL declaration simply returns a table, and not a matrix.
--To create a distance matrix, a pivot table is used to show distances between each city"

--

SELECT name
FROM upstate
ORDER BY name                                             -- 6 rows. Use them as categories, below

--

--www.postgresql.org/docs/9.2/static/tablefunc.html
--crosstab(text source_sql, text category_sql)
--"Produces a 'pivot table' with the value columns specified by a second query"
SELECT *
FROM
CROSSTAB
		('SELECT a.name::text, b.name::text,
			(ST_distance(a.geometry,b.geometry,true)*0.00062)::text
		FROM upstate AS a, upstate AS b
		ORDER BY 1,2'
		) AS
		CT(row_name text, Auburn text, Binghamton text, Elmira text,
			Ithaca text, Rochester text, Syracuse text);               -- 6x6 matrix (distance)



--Adjacency :

--"An adjacency matrix is similar to the distance matrix except the matrix elements are 1's or 0's"
--Let's say that if 2 cities are within 50 miles of each other, they're adjacent
--"This one is a little trickier [than distance matrix], but we'll work through this"
SELECT * FROM
CROSSTAB
		('SELECT a.name::text, b.name::text, CASE
				WHEN
					ST_distance(a.geometry,b.geometry,true)*0.00062 < 50 THEN 1::text
				ELSE 0::text
				END AS dist
		FROM upstate AS a, upstate AS b
		ORDER BY 1,2'
		) AS
		CT(row_name text, Auburn text, Binghamton text, Elmira text,
			Ithaca text, Rochester text, Syracuse text);               -- 6x6 matrix (adjacency)

--

--'Similarly, an ST_touches() spatial qualifier can be included to find actually adjacent areas'
SELECT * FROM
CROSSTAB
		('SELECT a.name::text, b.name::text,
			ST_touches(a.geometry,b.geometry)::integer::text AS tt     -- TRUE/FALSE
		FROM states AS a, states AS b
		WHERE a.name IN (''Alabama'',''California'',''Nevada'',''Oregon'',''Mississippi'')
		AND   b.name IN (''Alabama'',''California'',''Nevada'',''Oregon'',''Mississippi'')
		ORDER BY 1,2'                                                  -- why '1,2' not '1' ?
		) AS
		CT(row_name text, Alabama text, California text, Mississippi text,
			Nevada text, Oregon text);                                 -- alphabetic (re. ORDER BY)



--Interaction :

--'We can adapt the SQL to create an _interaction_ or _weights_ matrix, W.
--eg. An inverse distance weight (1/d) ...using a single character change from previous query'
--A 'larger' value (eg. 0.05) means more interaction (ie. those 2 cities closer than others)
SELECT * FROM
CROSSTAB
		('SELECT a.name::text, b.name::text, CASE             -- need CASE, in case distance is 0
				WHEN
					ST_distance(a.geometry,b.geometry,true)*0.00062 = 0 THEN 0::text
				ELSE (1/(ST_distance(a.geometry,b.geometry,true)*0.00062))::text  -- or (1/d^2) etc
				END AS dist
		FROM upstate AS a, upstate AS b
		ORDER BY 1,2'
		) AS
		CT(row_name text, Auburn text, Binghamton text, Elmira text,
			Ithaca text, Rochester text, Syracuse text);



--# geographic analysis : Nearest Neighbor Index

--"...it looks at the distance from each point to its nearest neighbour, and then
--it takes the average..." [average of the 6 distances]"
SELECT a.geometry, ST_distance(a.geometry,b.geometry,true)*0.00062 AS dist,
		a.name AS aname, b.name AS bname
FROM upstate AS a, upstate AS b
WHERE a.name <> b.name
ORDER BY aname, dist ASC                                      -- 30 rows
--Distance from every city to every other city (in ascending order). Not what we want

--

SELECT aname, min(dist) AS mindist                            -- will need to group the aggregate
FROM
		(SELECT a.geometry, ST_distance(a.geometry,b.geometry,true)*0.00062 AS dist,
				a.name AS aname, b.name AS bname
		FROM upstate AS a, upstate AS b
		WHERE a.name <> b.name
		ORDER BY aname, dist ASC
		) AS T1
GROUP BY aname                                                -- 6 rows (grouping the aggregate)
--For every city : minimum distance to its nearest neighbour. Still not what we want

--

SELECT avg(mindist) AS avgNND                                 -- avg Nearest Neighbor Distance
FROM
		(SELECT aname, min(dist) AS mindist
		FROM
				(SELECT a.geometry, ST_distance(a.geometry,b.geometry,true)*0.00062 AS dist,
						a.name AS aname, b.name AS bname
				FROM upstate AS a, upstate AS b
				WHERE a.name <> b.name
				ORDER BY aname, dist ASC
				) AS T1
		GROUP BY aname
		) AS A2                                               -- 1 row







