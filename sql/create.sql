create user edwin with password 'onkel-x';
create database satnav;
\connect satnav;
-- Enable PostGIS (includes raster)
CREATE EXTENSION postgis;
-- Enable Topology
CREATE EXTENSION postgis_topology;
-- Enable PostGIS Advanced 3D 
-- and other geoprocessing algorithms
grant ALL on satnav to edwin;

