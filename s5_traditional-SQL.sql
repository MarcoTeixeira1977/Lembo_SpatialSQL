--# SELECT

SELECT parcels.*
FROM parcels
WHERE propclass = 210

--

SELECT
		parcels.*
FROM
		parcels
WHERE
		propclass = 210

--

SELECT parcels.swis, propclas.description
FROM parcels, propclas
WHERE parcels.propclass::text = propclas.value -- or parcels.propclass = propclas.value::integer

--

SELECT parcels.swis, propclas.description
FROM parcels
RIGHT JOIN propclas ON
parcels.propclass = propclas.value::numeric



--# GROUP BY. (Performs aggregate computations on data, and groups them by one or more columns)

SELECT acres, propclass FROM parcels

--

SELECT sum(acres) AS sumacres, propclass       -- How many acres are in each property class?
FROM parcels
GROUP BY propclass       -- 'If you're going to use an aggregate function, with >2 records,
                         -- ...you're going to have to use the GROUP BY' ...12min47-12min52 (?)

--

SELECT sum(acres) AS sumacres, sum(asmt)::numeric::money AS sumasmt,
		avg(asmt)::numeric::money AS avgasmt, propclass
FROM parcels
GROUP BY propclass
ORDER BY propclass

--

SELECT count(*) AS NumProps, propclass
FROM parcels
GROUP BY propclass

--

SELECT sum(asmt)::numeric::money AS sumasmt, propclass
FROM parcels, firm
WHERE st_contains(firm.geometry, parcels.geometry) -- value of parcels inside the 'X' floodzone
AND firm.zone = 'X'
GROUP BY propclass

--

SELECT sum(asmt)::numeric::money AS sumasmt, propclass
FROM parcels, firm
WHERE st_contains(firm.geometry, parcels.geometry)
AND firm.zone = 'X'
AND propclass > 200 AND propclass < 300
GROUP BY propclass
ORDER BY propclass

--

SELECT sum(asmt)::numeric::money AS sumasmt, propclass
FROM parcels, firm
WHERE st_contains(firm.geometry, parcels.geometry)
AND left(propclass::text,1) = '2'         -- With only one AND. But slow, to convert to text
GROUP BY propclass
ORDER BY propclass

--

SELECT * FROM propclas                    -- NYState classification codes: 100s Agriculture etc

--

SELECT parcels.parcelkey, parcels.propclass, propclas.description, propclas.value
FROM parcels, propclas
WHERE
	left(parcels.propclass::text,1) = left(propclas.value,1)
	AND right(propclas.value,2) = '00'
ORDER BY value

--

DROP TABLE qlayer;

SELECT st_union(geometry) AS geometry, propclas.description  -- 'perform a merging of the data'
INTO qlayer              -- st_union() is an aggregate function for geometries ...cf. sum(asmt)
FROM parcels, propclas
WHERE
	left(parcels.propclass::text,1) = left(propclas.value,1)
	AND right(propclas.value,2) = '00'
GROUP BY propclas.description;           -- "union the geometries, based upon these descriptions"

SELECT * FROM qlayer                     -- 8 rows (geometries/ categories). Can view in QGIS



--# CASE statements. (A generic conditional expression, similar to if/else in other languages)

SELECT parcelkey, asmt
FROM parcels

--

SELECT parcelkey, asmt,
	CASE                                         -- CASE statement with mathematical operations
		WHEN asmt = 0 then 0
		WHEN asmt BETWEEN 1 AND 100000 THEN asmt * 0.07        -- 7% tax
		WHEN asmt BETWEEN 100001 AND 500000 THEN asmt * 0.09   -- 9% tax
		ELSE asmt * 0.11
	END AS taxbill
FROM parcels                                                   -- parcelkey, asmt, taxbill cols

--

DROP TABLE qlayer;

SELECT geometry, parcelkey, asmt,
	CASE                                         -- CASE statement with text operations
		WHEN left(propclass::text,1) = '2' THEN 'Residential'
		WHEN left(propclass::text,1) = '3' THEN 'Vacant'
		WHEN left(propclass::text,1) = '4' THEN 'Commercial'
		WHEN left(propclass::text,1) = '5' THEN 'Amusement'
		WHEN left(propclass::text,1) = '6' THEN 'Community Service'
		ELSE 'Other'
	END AS prototype
INTO qlayer
FROM parcels

--

DROP TABLE qlayer;

SELECT zone,
	CASE                                         -- CASE statement with spatial operations
		WHEN zone = 'X' THEN st_buffer(geometry,10)       -- buffer the zone by 10
		WHEN zone = 'AE' THEN st_buffer(geometry,20)      -- buffer the zone by 20
		WHEN zone = 'X500' THEN st_buffer(geometry,30)    -- buffer the zone by 30
		ELSE geometry                                     -- no buffer
	END AS geometry
INTO qlayer
FROM firm



--# Aggregate Functions

SELECT * FROM states                                      -- a new table, about obesity levels

--

SELECT avg(ob_1995) AS avg_obs_1995 FROM states

--

SELECT corr(ob_1995,ob_2000) AS pearson FROM states       -- Pearson correlation coefficient

--

SELECT min(ob_2000) AS min_obs_2000 FROM states
WHERE ob_2000 > 0                                         -- avoids 'bogus' blank record here

--

SELECT avg(ob_1995), avg(ob_2000), avg(ob_2009) FROM states

--

SELECT stddev(ob_2009)/avg(ob_2009) AS CV FROM states     -- coefficient of variation

--

SELECT '2009' AS yr, stddev(ob_2009)/avg(ob_2009) AS CV FROM states

Union All                                                 -- add results of 2nd query to bottom

SELECT '2000' AS yr, stddev(ob_2000)/avg(ob_2000) AS CV FROM states

Union All                                                 -- add results of 3rd query (same cols)

SELECT '1995' AS yr, stddev(ob_1995)/avg(ob_1995) AS CV FROM states

--

SELECT	st_centroid(geometry),                            -- centroid for each state (49 rows)
		st_centroid(geometry)
FROM states

--

SELECT	st_x(st_centroid(geometry)),                      -- X coord for each state (49 rows)
		st_y(st_centroid(geometry))
FROM states

--

SELECT	avg(st_x(st_centroid(geometry))) AS X,            -- average X of all states (1 row)
		avg(st_y(st_centroid(geometry))) AS Y             -- ...and Y. The mean centre of USA
FROM states

--

DROP TABLE qlayer;

SELECT	st_point(avg(st_x(st_centroid(geometry))),        -- convert x,y into an actual point
		avg(st_y(st_centroid(geometry)))) AS geometry     -- ...'Kansas North' coord system
INTO qlayer
FROM states                                               -- (Also show 'states' layer in QGIS)

--
-- Weighted Mean Centre ...weighted by obesity

SELECT	sum(st_x(st_centroid(geometry)) * ob_2000)/sum(ob_2000) AS X,
		sum(st_y(st_centroid(geometry)) * ob_2000)/sum(ob_2000) AS Y
FROM states

--

DROP TABLE qlayer;

SELECT	st_point(sum(st_x(st_centroid(geometry)) * ob_2000)/sum(ob_2000),
		sum(st_y(st_centroid(geometry)) * ob_2000)/sum(ob_2000)) AS geometry
INTO qlayer
FROM states



--# Potpourri. (SORT; LIMIT; OFFSET; IN; BETWEEN)

SELECT ob_2009, name
FROM states
ORDER BY ob_2009 DESC
LIMIT 10

--

SELECT ob_2009, name
FROM states
ORDER BY ob_2009                                      -- default is 'ASC'
OFFSET 9                                              -- skip the first 9 results
LIMIT 10                                              -- return the next 10 (rows 21-30)

--

SELECT ob_2009, name
FROM states
WHERE name IN('New York', 'California', 'Maine')      -- to avoid lots of 'OR' statements

--

SELECT name FROM states WHERE left(name,1) = 'M'

--

SELECT ob_2009, name
FROM states
WHERE name IN(SELECT name FROM states WHERE left(name,1) = 'M')   -- 8 rows

--

SELECT ob_2009, name
FROM states
WHERE ob_2009 BETWEEN 25 AND 30                                   -- 9 rows. (Indiana _is_ '30')
ORDER BY ob_2009 DESC

--
-- Are any States consistently in the Top10 obese, all 3 years?

SELECT name FROM
	(SELECT name, count(name) AS numstates FROM     -- start virtual table T2 (13 rows; no dup)
		(                                           -- start virtual table T1 (30 rows; duplicn)
			(SELECT name, ob_2009 AS ob
			FROM states
			ORDER BY ob_2009 DESC                   -- **** ORDER BY 'ob' ?
			LIMIT 10)                               -- Top10 states in 2009
			
			UNION ALL
			
			(SELECT name, ob_1995 AS ob
			FROM states
			ORDER BY ob_1995 DESC                   -- **** ORDER BY 'ob' ?
			LIMIT 10)                               -- Top10 states in 1995
			
			UNION ALL
			
			(SELECT name, ob_2000 AS ob
			FROM states
			ORDER BY ob_2000 DESC                   -- **** ORDER BY 'ob' ?
			LIMIT 10)                               -- Top10 states in 2000
		) AS T1                                     -- end virtual table T1 (30 rows; duplicn)
	GROUP BY name
	) AS T2                                         -- end virtual table T2 (13 rows; no dup)
WHERE numstates = 3                                 -- in Top10 all 3 years (7 rows)

--

DROP TABLE qlayer;

SELECT geometry, name
INTO qlayer
FROM states WHERE name IN
(SELECT name FROM                                   -- start virtual table #3 (7 rows)
	(SELECT name, count(name) AS numstates FROM
		(
			(SELECT name, ob_2009 AS ob
			FROM states
			ORDER BY ob_2009 DESC
			LIMIT 10)
			
			UNION ALL
			
			(SELECT name, ob_1995 AS ob
			FROM states
			ORDER BY ob_1995 DESC
			LIMIT 10)
			
			UNION ALL
			
			(SELECT name, ob_2000 AS ob
			FROM states
			ORDER BY ob_2000 DESC
			LIMIT 10)
		) AS T1
	GROUP BY name
	) AS T2
WHERE numstates = 3  
)                                                  -- end virtual table #3



--# Changing data. (DROP; CREATE; INSERT; ALTER; UPDATE) [??? v's SELECT ... INTO qlayer ???]

CREATE TABLE mytable (name text, geometry geometry(Geometry,2261));  -- '2261' is coord system

SELECT * FROM mytable;                             -- 2 column headers (no rows exist yet)

INSERT INTO mytable (name, geometry)               -- add some rows to 'mytable' (2 cols)
SELECT name, geometry FROM parks WHERE size > 1;   -- ...(result of an SQL statement (1 acre))

SELECT * FROM mytable                              -- 10 rows

--

DROP TABLE mytable;                                -- (use after 'mytable' created, else error)

CREATE TABLE mytable (name text, geometry geometry(Geometry,2261));

INSERT INTO mytable (name, geometry)
SELECT name, st_buffer(geometry,500) FROM parks;   -- 500m buffer around each park (23 rows)

SELECT * FROM mytable

--

DROP TABLE mytable;

CREATE TABLE mytable (name text, geometry geometry(Geometry,2261));

INSERT INTO mytable (name, geometry)
SELECT name, geometry FROM parks;                   -- 23 rows

ALTER TABLE mytable                                 -- ALTER
ADD column parksize double precision;               -- add new column, (but no data in it yet)

--UPDATE mytable                                    -- entering some data into the new column
--SET parksize = 1.3
--WHERE name = 'Baker Park';
UPDATE mytable                                      -- 'a little more sophisticated UPDATE stmt'
SET parksize = parks.size
FROM parks                                          -- (this is still necessary)
WHERE parks.name = mytable.name;

SELECT * FROM mytable                               -- 23 rows



--# Writing SQL Functions

CREATE FUNCTION __aaa_getfloodgeom (x text)         -- expecting a text value passed-in (variable)
RETURNS TABLE(mygeom geometry) AS                   -- return a geometry (that's in a table)
$$
	SELECT st_intersection(parcels.geometry,firm.geometry) AS geometry
	FROM parcels,firm
	WHERE st_intersects(parcels.geometry,firm.geometry) 
	AND firm.zone = $1	;                           -- 'equal to 1st variable I passed-in' (x)
$$ LANGUAGE SQL;

SELECT __aaa_getfloodgeom('AE')                   -- so no need to write a full query each time

--

DROP TABLE qlayer;
SELECT __aaa_getfloodgeom('AE') INTO qlayer



