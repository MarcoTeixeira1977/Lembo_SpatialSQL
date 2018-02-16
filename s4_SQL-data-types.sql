SELECT asmt - land AS structvalue, parcelkey -- 'assessed value' incl everything on a property
FROM parcels                                 -- 'land' is just value of the land

--

SELECT asmt / land AS myratio, parcelkey
FROM parcels
WHERE land > 0                               -- to avoid #DIV/0 error

--

SELECT avg(asmt)
FROM parcels

--

(SELECT asmt / land AS valuepercdif, parcelkey
FROM parcels
WHERE land > 0)

--

SELECT * FROM
 (SELECT asmt / land AS valuepercdif, parcelkey
FROM parcels
WHERE land > 0) AS T1
WHERE valuepercdif > 1.25

--

SELECT avg(asmt), stddev(asmt), sum(asmt), stddev(asmt)/avg(asmt)
FROM parcels