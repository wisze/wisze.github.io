ALTER TABLE newtracks ADD COLUMN length float;
ALTER TABLE newtracks ADD COLUMN distance float;

UPDATE  newtracks AS nt
SET     length = aggr.length, distance = aggr.distance
FROM    ( SELECT newtracks.ogc_fid,
                 ST_LengthSpheroid(wkb_geometry,
                    'SPHEROID["WGS 84",6378137,298.257223563]')/1000.0 AS length,
                 ST_DistanceSpheroid(ST_StartPoint(wkb_geometry),ST_EndPoint(wkb_geometry),
                    'SPHEROID["WGS 84",6378137,298.257223563]')/1000.0 AS distance
        FROM newtracks 
        GROUP BY newtracks.ogc_fid
        ) AS aggr
WHERE   nt.ogc_fid = aggr.ogc_fid
