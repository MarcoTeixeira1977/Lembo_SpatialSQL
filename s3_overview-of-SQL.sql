SELECT propclass
FROM parcels                   -- parcels of land
WHERE acres > 44

--

SELECT *
INTO qlayer                    -- new table, to display as a separate layer in QGIS
FROM parcels
WHERE acres > 44

--

DROP TABLE qlayer;

SELECT parcels.* INTO qlayer   -- delete the 'qlayer' table and create a new one from this query
FROM parcels, firm             -- FIRM is "Flood Insurance Rate Map" ('flood zone map')
WHERE ST_intersects(parcels.geometry,firm.geometry) -- a spatial function()
AND firm.zone = 'X'            -- parcels that intersect the FIRM in zones designated 'X'

--

DROP TABLE qlayer;

SELECT parcels.* INTO qlayer
FROM parcels, firm, hydro                              -- hydro has the rivers & streams
WHERE ST_intersects(parcels.geometry,firm.geometry)
AND firm.zone = 'AE'                                   -- zones designated 'AE'
AND parcels.asmt > 500000                              -- $assessment value of parcel
AND ST_distance(parcels.geometry,hydro.geometry) < 600 -- parcels <600ft from hydrology