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

--# CASE statements






