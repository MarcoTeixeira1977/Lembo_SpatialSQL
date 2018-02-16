--# Numeric Operations. (Would be much more difficult to perform in a traditional GIS)

SELECT asmt - land AS structvalue, parcelkey   -- 'assessed value' incl everything on a property
FROM parcels                                   -- 'land' is just value of the land

--

SELECT asmt / land AS myratio, parcelkey
FROM parcels
WHERE land > 0                                 -- to avoid #DIV/0 error

--

SELECT avg(asmt)
FROM parcels

--

(SELECT asmt / land AS valuepercdif, parcelkey -- computation 'in memory'; no need to create col
FROM parcels
WHERE land > 0)

--

SELECT * FROM
    (SELECT asmt / land AS valuepercdif, parcelkey
    FROM parcels
    WHERE land > 0) AS T1
WHERE valuepercdif > 1.25                      -- from virtual table, subject to constraint

--

﻿SELECT asmt / land AS valuepercdif, parcelkey
    FROM parcels
    WHERE land > 0
    AND asmt / land > 1.25                     -- same result as above, but 'less elegant'

--

SELECT avg(asmt), stddev(asmt), sum(asmt), stddev(asmt)/avg(asmt) AS CoeffOfVariation
FROM parcels

--# Boolean Operations

SELECT *
FROM parcels
WHERE acres > 3

--

SELECT *
FROM parcels
WHERE acres > 3
AND propclass = 210

--# Character Operations

DROP TABLE qlayer;                      -- delete the 'qlayer' table, to then create new query

SELECT * INTO qlayer                    -- new table, to display as a separate layer in QGIS
FROM parcels WHERE left(addrstreet,2) = 'BU'

--

DROP TABLE qlayer;

SELECT * INTO qlayer
FROM parcels WHERE left(addrstreet,2) = 'BU'
AND right(addrstreet,1) = 'E'            -- picks up (just) the 'Buffalo St E' properties

--

DROP TABLE qlayer;

SELECT * INTO qlayer
FROM parcels
WHERE lower(addrstreet) = 'buffalo st e'

--

SELECT concat(addrno, ' ', addrstreet) FROM parcels
WHERE asmt > 100000

--

SELECT asmt::text FROM parcels            -- changes format from 'real' (floating point) to text

--

SELECT asmt::text::numeric FROM parcels   -- numeric -> text -> numeric

--

SELECT asmt::numeric::money::text FROM parcels

--

SELECT concat('assessed value is', '   ', asmt::numeric::money::text) FROM parcels
WHERE propclass = 210

--

SELECT concat('assessed value is', '   ', asmt::numeric::money::text), parcelkey
FROM parcels, floodarea
WHERE propclass = 210
AND st_intersects(parcels.geometry, floodarea.geometry)

--# Date & Time Operations

SELECT gps_date FROM trees

--

SELECT date_part('day', gps_date)  FROM trees           -- (opposite order of arg's gives error)

--

SELECT gps_date, to_char(gps_date, 'DAY') FROM trees    -- (opposite order of arg's gives error)

--

SELECT * FROM trees WHERE gps_date > '6/03/2001'

--

SELECT inv_date - '6/03/2001' FROM trees

--

SELECT site_id, maint                                       -- maintenance recommendation
FROM trees
WHERE to_char(inv_date - '6/03/2001', 'DD')::numeric > 400  -- >400 days since inventory

--

SELECT extract(month from gps_date), site_id
FROM trees

--

SELECT to_char(gps_date, 'D Month YYYY '), site_id
FROM trees

--# Spatial Operations (perform functions like buffer, containment, intersection and distance)
                        -- postgis.net/docs/reference.html

DROP TABLE qlayer;

SELECT parcels.*
INTO qlayer
FROM parcels, parks
WHERE st_intersects(parcels.geometry, parks.geometry)   -- a spatial transform (an intersect tf)

--

SELECT parcels.parcelkey, parks.name
FROM parcels, parks
WHERE st_intersects(parcels.geometry, parks.geometry)

--

DROP TABLE qlayer;

SELECT st_intersectsection(parcels.geometry, firm.geometry) AS geometry   -- intersectION
INTO qlayer
FROM parcels, firm
WHERE firm.zone = 'X500'
AND st_intersects(parcels.geometry, firm.geometry)                        -- intersectS

       -- intersectS() is a True/False. intersectION() returns geometry of shared portion
       -- ...which will be jagged fractions of parcels, not neatly along borders!

