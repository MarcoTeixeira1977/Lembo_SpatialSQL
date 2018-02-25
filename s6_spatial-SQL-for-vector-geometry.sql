--# coordinate system manipulation

--http://www.spatialreference.org
--SRID is a Spatial Reference system IDentifier

SELECT ST_SRID(geom) FROM states2;                     -- what is current projection ('geom' field)
                                                       -- ...'0' means 'don't know' (where in space)

--

SELECT UpdateGeometrySRID('states2','geom',2796)       -- define a projection (the ref system)
                                                       -- ...doesn't transform the actual geometry
                                                       -- (layer name, field name, new SRID)

--

SELECT ST_transform(geom,3450) FROM states2;           -- change projection (but not perm in table)

--

SELECT name, ST_transform(geom,3450) AS geometry INTO states3  -- change table to see in QGIS layer
FROM states2;

--

ALTER TABLE states2                   -- change existing table/layer, not create new (cf. 'states3')
	ALTER COLUMN geom
	TYPE Geometry(Multipolygon,2959)
	USING ST_transform(geom,2959);    -- convert 'geom' col (to value '2959')



--# Spatial operations. (Adjacent, Buffer, Contains, Distance, Intersect)

--http://postgis.net/docs/manual-1.3/ch06.html
--http://postgis.org/docs/reference.html

--Adjacent :

SELECT * FROM parcels
WHERE ST_touches(parcels.geometry,
	(SELECT geometry
	FROM parcels
	WHERE parcelkey = '50070006200000010150000000')     -- Parcels touching specific one. (9 rows)
	)

--

DROP TABLE qlayer

SELECT * INTO qlayer FROM parcels
WHERE ST_touches(parcels.geometry,
	(SELECT geometry
	FROM parcels
	WHERE parcelkey = '50070006200000010150000000')
	)

--

SELECT sum(asmt)::numeric::money AS sumasmt, sum(land)::numeric::money AS sumland
FROM parcels
WHERE ST_touches(parcels.geometry,
	(SELECT geometry
	FROM parcels
	WHERE parcelkey = '50070006200000010150000000')    -- get value of adjacent assessments/land
	)

--

SELECT addrno || ' ' || addrstreet AS address
FROM parcels
WHERE ST_touches(parcels.geometry,
	(SELECT geometry
	FROM parcels
	WHERE parcelkey = '50070006200000010150000000')    -- addresses of adjacent parcels
	)
--|| represents string concatenation. Unfortunately, not portable across all sql dialects
--https://stackoverflow.com/questions/23372550/what-does-sql-select-symbol-mean
	
--

SELECT addrno || ' ' || addrstreet AS address
FROM parcels
WHERE ST_touches(parcels.geometry,
	(SELECT geometry
	FROM parcels
	WHERE parcelkey = '50070006200000010150000000')
	)
AND asmt > 210000                                      -- 'find rich neighbours' (5 rows)

--Buffer :

DROP TABLE qlayer;

SELECT parcels.parcel_id, ST_buffer(geometry,100) AS geometry
INTO qlayer
FROM parcels
WHERE parcelkey = '50070000900000040130000000'

--Contains :

DROP TABLE qlayer;

SELECT parcels.*
INTO qlayer
FROM parcels,firm
WHERE ST_contains(firm.geometry,parcels.geometry)
AND firm.zone = 'AE'                           -- parcel is fully-contained inside flood zone 'AE' 
                                               -- ...107 rows

--

DROP TABLE qlayer;

SELECT parcels.*
INTO qlayer
FROM parcels,firm
WHERE ST_intersects(firm.geometry,parcels.geometry) -- cf. 'Contains' [to help understanding that]
AND firm.zone = 'AE'                                -- parcel fully or partly in flood zone 'AE' 
                                                    -- ...320 rows

--

SELECT sum(asmt)::numeric::money, left(propclass::text,1) AS pc
FROM parcels,firm
WHERE ST_contains(firm.geometry,parcels.geometry)
GROUP BY pc                                         -- 9 rows (0-9, but no '1')


--create a convex hull around the geometries in 'those 6 cities' in upstate New York

DROP TABLE qlayer;
SELECT ST_ConvexHull(geometry) AS geometry
INTO qlayer
FROM upstate

--...That gave 6 points. Instead we have to turn those 6 geometries into a multi-part geometry
--ST_Collect() turns a set of geometries (polygons/points/lines) into a collection,
--so it becomes a multi-part object
DROP TABLE qlayer;
SELECT ST_ConvexHull(ST_collect(geometry)) AS geometry -- 4-sided shape, other 2 points inside it
INTO qlayer
FROM upstate

--Distance :

SELECT ST_distance(parcels.geometry,firm.geometry)::integer as dist, parcels.parcel_id
FROM parcels, firm
WHERE ST_distance(parcels.geometry,firm.geometry) < 300     -- parcel and flood map < 300ft apart
AND zone = 'X'                                              -- 7468 rows

--

SELECT ST_distance(parcels.geometry,firm.geometry)::integer as dist, parcels.parcel_id
FROM parcels, firm
WHERE ST_DWithin(parcels.geometry,firm.geometry,300)        -- (uses indexes, much faster)
AND zone = 'X'                                              -- 7468 rows

--

SELECT sum(asmt)::numeric::money
FROM parcels, firm
WHERE ST_DWithin(parcels.geometry,firm.geometry,300)
AND zone = 'X'                                              -- 1 row, total sum

--Intersects :

DROP TABLE qlayer;
SELECT parcels.geometry AS g, parcels.parcelkey             -- whole parcels
INTO qlayer
FROM parcels, firm
WHERE ST_intersects(parcels.geometry,firm.geometry)
AND firm.zone = 'AE'                                        -- 320 rows

--

DROP TABLE qlayer;
SELECT ST_intersection(parcels.geometry,firm.geometry) AS geometry, parcels.parcelkey  -- cuts parcels
INTO qlayer
FROM parcels, firm
WHERE ST_intersects(parcels.geometry,firm.geometry)
AND firm.zone = 'AE'                                        -- 320 rows



--# Spatial operations: Topological Overlay. (ERASE, INTERSECT, IDENTITY.) [Using supplied 'overlay.qgs' file]
--Erase :

DROP TABLE qlayer;
SELECT leftsquare.side, ST_difference(leftsquare.geometry,middle.geometry) AS geometry
INTO qlayer
FROM leftsquare, middle

--Intersect :

DROP TABLE qlayer;
SELECT leftsquare.side AS l_side, rightsquare.side AS r_side,
		ST_intersection(leftsquare.geometry,rightsquare.geometry) AS geometry
INTO qlayer
FROM leftsquare, rightsquare
WHERE ST_intersects(leftsquare.geometry,rightsquare.geometry)  -- to run faster, not return NULLs

--Identity. (This is a bit more complex ...Diagram in 'ArcGIS Help' [resources.arcgis.com]) :











