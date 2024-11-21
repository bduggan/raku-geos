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

has $.context = GEOS_init_r();
has $.wkt-reader;

method read-wkt(Str $wkt) {
    $!wkt-reader //= GEOSWKTReader_create_r($!context);
    GEOSWKTReader_read_r($!context, $!wkt-reader, $wkt);
}

submethod DESTROY {
    GEOSWKTReader_destroy_r($!context, $!wkt-reader) if $!wkt-reader;
    GEOS_finish_r($!context);
}

