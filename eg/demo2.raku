use GEOS::Native;

my $wkt = "POINT(1 1)";
my $ctx = GEOS_init_r();
my $reader = GEOSWKTReader_create_r($ctx) or die "Could not create reader";
my $geom-a = GEOSWKTReader_read_r($ctx, $reader, $wkt) or die "Could not read geometry '$wkt'";
my $geojson-writer = GEOSGeoJSONWriter_create_r($ctx) or die "Could not create GeoJSON writer";
say GEOSGeoJSONWriter_writeGeometry_r($ctx, $geojson-writer, $geom-a, 1) or die "Could not write GeoJSON";
# {
#  "type": "Point",
#  "coordinates": [
#   1.0,
#   1.0
#  ]
# }


