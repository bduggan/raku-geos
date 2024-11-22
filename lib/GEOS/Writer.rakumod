unit class GEOS::Writer;

=begin pod

=head NAME

GEOS::Writer - Serialize geometries to WKT, WKB, and GEOJSON

=head SYNOPSIS

    use GEOS::Writer;

    my $writer = GEOS::Writer.new;

    my $point = $writer.write-wkt('POINT(1 2)');
    my $point = $writer.write-wkb($wkb-bytes);
    my $point = $writer.write-geojson($geojson-string);

=head DESCRIPTION

This module provides a simple interface for writing geometries as WKT, WKB, and GEOJSON.

=head1 METHODS

=end pod

use GEOS::Native;
use GEOS::Geometry;

has $.ctx = GEOS_init_r();
has $.wkt-writer;

#| Generate a WKT string
method write-wkt(GEOS::Geometry $geom --> Str) {
    $!wkt-writer //= GEOSWKTWriter_create_r($!ctx);
    GEOSWKTWriter_write_r($!ctx, $!wkt-writer, $geom.geom);
}

submethod DESTROY {
    GEOSWKTWriter_destroy_r($!ctx, $!wkt-writer) if $!wkt-writer;
    GEOS_finish_r($!ctx);
}

