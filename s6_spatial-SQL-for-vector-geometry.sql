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

SELECT ST_Transform(geom,3450) FROM states2;           -- change projection (but not perm in table)

--

SELECT name, ST_Transform(geom,3450) AS geometry INTO states3  -- change table to see in QGIS layer
FROM states2;

--

ALTER TABLE states2                   -- change existing table/layer, not create new (cf. 'states3')
	ALTER COLUMN geom
	TYPE Geometry(Multipolygon,2959)
	USING ST_Transform(geom,2959);    -- convert 'geom' col (to value '2959')



--# Spatial operations. (Adjacent, Buffer, Contains, Distance, Intersect, more...)

--http://postgis.net/docs/manual-1.3/ch06.html
--http://postgis.org/docs/reference.html

--Adjacent :

SELECT * FROM parcels
WHERE st_touches(parcels.geometry,
	(SELECT geometry FROM parcels WHERE parcelkey = '50070006200000010150000000')
	)

--

SELECT sum(asmt) FROM parcels                          -- get sum of the land values
WHERE st_touches(parcels.geometry,
	(SELECT geometry FROM parcels WHERE parcelkey = '50070006200000010150000000')
	)

--

SELECT sum(asmt) FROM parcels
WHERE st_touches(parcels.geometry,
	(SELECT geometry FROM parcels WHERE parcelkey = '50070006200000010150000000')
	)
AND asmt > 170000                                      -- 'find rich neighbours'









