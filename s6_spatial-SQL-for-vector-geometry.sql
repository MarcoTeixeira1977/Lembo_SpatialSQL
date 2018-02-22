--# coordinate system manipulation

-- http://www.spatialreference.org
-- SRID is a Spatial Reference system IDentifier

SELECT ST_SRID(geom) FROM states2;                       -- find a projection being used

--

SELECT UpdateGeometrySRID('states2','geometry',2796)     -- define a projection

--

SELECT ST_Transform(geometry,3450) FROM states;          -- change a projection
SELECT ST_Transform(geometry,2796) FROM states;





