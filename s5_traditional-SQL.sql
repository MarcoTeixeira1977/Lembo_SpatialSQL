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
FROM states

--

SELECT	sum(st_x(st_centroid(geometry)) * ob_2000)/sum(ob_2000) AS X,   -- Weighted Mean Centre
		sum(st_y(st_centroid(geometry)) * ob_2000)/sum(ob_2000) AS Y
FROM states



