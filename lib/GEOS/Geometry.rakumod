=begin pod

=head1 NAME

GEOS::Geometry - Base class for GEOS geometries

=end pod

unit class GEOS::Geometry;
use GEOS::Native;

has $.geom;
has $.ctx = GEOS_init_r();

submethod DESTROY {
  GEOSGeom_destroy_r($!ctx, $!geom);
  GEOS_finish_r($!ctx);
}

method from-geojson(Str $geojson) {
    my $ctx = GEOS_init_r();
    my $reader = GEOSGeoJSONReader_create_r($ctx);
    my $geom = GEOSGeoJSONReader_readGeometry_r($ctx, $reader, $geojson);
    die "Failed to parse GeoJSON" unless $geom;
    GEOSGeoJSONReader_destroy_r($ctx, $reader);
    GEOS_finish_r($ctx);
    self.new(:geom($geom));
}

method geojson(Bool :$indent = False) {
    my $writer = GEOSGeoJSONWriter_create_r($!ctx);
    my $geojson = GEOSGeoJSONWriter_writeGeometry_r($!ctx, $writer, $.geom, $indent ?? 1 !! 0);
    GEOSWKTWriter_destroy_r($!ctx, $writer);
    $geojson;
}

method wkt {
    my $writer = GEOSWKTWriter_create_r($!ctx);
    my $wkt = GEOSWKTWriter_write_r($!ctx, $writer, $.geom);
    GEOSWKTWriter_destroy_r($!ctx, $writer);
    $wkt;
}

