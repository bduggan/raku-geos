unit class GEOS::Reader;

=begin pod

=head NAME

GEOS::Reader - Parse geometry strings into GEOS::Geometry objects

=head SYNOPSIS

    use GEOS::Reader;

    my $reader = GEOS::Reader.new;

    my $point = $reader.read-wkt('POINT(1 2)');
    my $point = $reader.read-geojson("{ 'type': 'Point', 'coordinates': [1, 2] }");

=head DESCRIPTION

Read various forms of geometry representations into GEOS::Geometry objects.

=end pod

use GEOS::Native;
use GEOS::Geometry;

has $.ctx = GEOS_init_r();
has $.wkt-reader;
has $.geojson-reader;

#| Read a geometry from WKT
method read-wkt(Str $wkt --> GEOS::Geometry)  {
  $!wkt-reader //= GEOSWKTReader_create_r($!ctx);
  GEOS::Geometry.new( geom => GEOSWKTReader_read_r($!ctx, $!wkt-reader, $wkt), :$!ctx );
}

#| Read geojson
method read-geojson(Str $geojson --> GEOS::Geometry) {
   $!geojson-reader //= GEOSGeoJSONReader_create_r($!ctx);
   GEOS::Geometry.new( geom => GEOSGeoJSONReader_readGeometry_r($!ctx, $!geojson-reader, $geojson), :$!ctx );
}

submethod DESTROY {
    GEOSWKTReader_destroy_r($!ctx, $!wkt-reader) if $!wkt-reader;
    GEOSGeoJSONReader_destroy_r($!ctx, $!geojson-reader) if $!geojson-reader;
    GEOS_finish_r($!ctx);
}

