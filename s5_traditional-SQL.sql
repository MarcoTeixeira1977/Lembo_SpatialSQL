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

--# GROUP BY

SELECT sum(acres) AS sumacres, propclass
FROM parcels
GROUP BY propclass

--

SELECT sum(acres) AS sumacres, left(propclass::text,1)
FROM parcels
GROUP BY left(propclass::text,1)

--

SELECT count(*) AS NumProps, propclass
FROM parcels
GROUP BY propclass

--

SELECT sum(asmt) sumacres, propclass
FROM parcels, firm
WHERE propclass > 200 AND propclass < 300
AND st_contains(firm.geometry, parcels.geometry)
AND firm.zone = 'X'
GROUP BY propclass


