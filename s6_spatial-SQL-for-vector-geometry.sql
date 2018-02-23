--# coordinate system manipulation

-- http://www.spatialreference.org
-- SRID is a Spatial Reference system IDentifier

SELECT ST_SRID(geom) FROM states2;                     -- what is current projection ('geom' field)
                                                       -- ...'0' means 'don't know' (where in space)

--

SELECT UpdateGeometrySRID('states2','geom',2796)   -- define a projection (the ref system)
                                                       -- ...doesn't transform the actual geometry
                                                       -- (layer name, field name, new SRID)

--

SELECT ST_Transform(geom,3450) FROM states;            -- change a projection
SELECT ST_Transform(geom,2796) FROM states;


SELECT name, ST_Transform(geom,3450) AS geometry INTO states3
FROM states2;



ALTER TABLE states2                                    -- no need to create new table (cf. 'states3')
	ALTER COLUMN geom
	TYPE Geometry(Multipolygon,2959)
	USING ST_Transform(geom,2959);                     -- convert 'geom' col (to value '2959')
