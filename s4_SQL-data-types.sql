--Numeric Operations. (Would be much more difficult to perform in a traditional GIS)

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

-- Boolean Operations

SELECT *
FROM parcels
WHERE acres > 3

--

SELECT *
FROM parcels
WHERE acres > 3
AND propclass = 210

--Character Operations

DROP TABLE qlayer;
SELECT * INTO qlayer

FROM parcels WHERE left(addrstreet,2) = 'BU'

--

SELECT * FROM parcels
WHERE lower(addrstreet) = 'buffalo st e'

SELECT asmt::text FROM parcels

SELECT asmt::text::numeric FROM parcels