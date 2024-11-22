unit class GEOS::Writer;

=begin pod

=head1 NAME

GEOS::Writer - Serialize geometries into various formats

=head1 SYNOPSIS

    use GEOS::Writer;

    my $writer = GEOS::Writer.new;

    say $writer.write-wkt($geometry);
    say $writer.write-geojson($geometry);

=head1 DESCRIPTION

This module provides a simple interface for converting geometry objects into different foramts.

=head1 METHODS

=end pod

use GEOS::Native;
use GEOS::Geometry;

has $.ctx = GEOS_init_r();
has $.wkt-writer;
has $.json-writer;

#| Generate a WKT string
method write-wkt(GEOS::Geometry $geom --> Str) {
    $!wkt-writer //= GEOSWKTWriter_create_r($!ctx);
    GEOSWKTWriter_write_r($!ctx, $!wkt-writer, $geom.geom);
}

#| Generate a geojson string
method write-geojson(GEOS::Geometry $geom, Bool :$indent = True --> Str) {
    $!json-writer = GEOSGeoJSONWriter_create_r($!ctx);
    GEOSGeoJSONWriter_writeGeometry_r($!ctx, $!json-writer, $geom.geom, $indent ?? 1 !! 0);
}

submethod DESTROY {
    GEOSWKTWriter_destroy_r($!ctx, $!wkt-writer) if $!wkt-writer;
    GEOS_finish_r($!ctx);
}

