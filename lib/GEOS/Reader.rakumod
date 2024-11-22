unit class GEOS::Reader;

=begin pod

=head NAME

GEOS::Reader - Read geometries from WKT, WKB, and GEOJSON

=head SYNOPSIS

    use GEOS::Reader;

    my $reader = GEOS::Reader.new;

    my $point = $reader.read-wkt('POINT(1 2)');
    my $point = $reader.read-wkb($wkb-bytes);
    my $point = $reader.read-geojson($geojson-string);

=head DESCRIPTION

This module provides a simple interface for reading geometries from WKT, WKB, and GEOJSON.

=end pod

use GEOS::Native;
use GEOS::Geometry;

has $.ctx = GEOS_init_r();
has $.wkt-reader;

#| Read a geometry from WKB
method read-wkt(Str $wkt --> GEOS::Geometry)  {
    $!wkt-reader //= GEOSWKTReader_create_r($!ctx);
    GEOS::Geometry.new( geom => GEOSWKTReader_read_r($!ctx, $!wkt-reader, $wkt), :$!ctx );
}

submethod DESTROY {
    GEOSWKTReader_destroy_r($!ctx, $!wkt-reader) if $!wkt-reader;
    GEOS_finish_r($!ctx);
}

