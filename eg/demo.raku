use GEOS::Native;
use NativeCall;

my $wkt = "POINT(1 1)";
my $ctx = GEOS_init_r();
GEOSContext_setNoticeHandler_r($ctx, &dummy_handler);
GEOSContext_setErrorHandler_r($ctx, &dummy_handler);

my $wkt-out;
my $geojson-out;

try {
  my $reader = GEOSWKTReader_create_r($ctx) or die "Could not create reader";
  my $geom-a = GEOSWKTReader_read_r($ctx, $reader, $wkt) or die "Could not read geometry '$wkt'";
  my $writer = GEOSWKTWriter_create_r($ctx) or die "Could not create writer";
  my $wkt-ptr = GEOSWKTWriter_write_r($ctx, $writer, $geom-a) or die "Could not write geometry";
  $wkt-out = nativecast(Str, $wkt-ptr) or die "Could not cast to Str";

  my $geojson-writer = GEOSGeoJSONWriter_create_r($ctx) or die "Could not create GeoJSON writer";
  $geojson-out = GEOSGeoJSONWriter_writeGeometry_r($ctx, $geojson-writer, $geom-a, 1) or die "Could not write GeoJSON";

  CATCH {
    default {
      say "Error: $_";
      GEOSFree_r($ctx, $wkt-ptr) if $wkt-ptr;
      GEOSWKTWriter_destroy_r($ctx, $writer) if $writer;
      GEOSGeom_destroy_r($ctx, $geom-a) if $geom-a;
      GEOSWKTReader_destroy_r($ctx, $reader) if $reader;
      GEOSGeoJSONWriter_destroy_r($ctx, $geojson-writer) if $geojson-writer;
      GEOS_finish_r($ctx) if $ctx;
    }
  }
}

exit unless $wkt-out;

say "Geometry: $wkt-out";
say "GeoJSON: $geojson-out";
