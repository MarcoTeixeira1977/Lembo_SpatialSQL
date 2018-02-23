--# coordinate system manipulation

-- http://www.spatialreference.org
-- SRID is a Spatial Reference system IDentifier

SELECT ST_SRID(geom) FROM states2;                     -- what is current projection ('geom' field)
                                                       -- ...'0' would mean 'it doesn't know'

--

SELECT UpdateGeometrySRID('states2','geometry',2796)   -- define a projection (the ref system)
                                                       -- ...doesn't transform the actual geometry

--

SELECT ST_Transform(geometry,3450) FROM states;        -- change a projection
SELECT ST_Transform(geometry,2796) FROM states;


SELECT name, ST_Transform(geometry,3450) AS geometry INTO states3
FROM states2;



ALTER TABLE states2
	ALTER COLUMN geometry
	TYPE Geometry(Multipolygon,2959)
	USING ST_Transform(geometry,2959);                  -- convert 'geometry' col (to value '2959')
