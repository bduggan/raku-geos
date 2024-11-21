unit class GEOS::Writer;

=begin pod

=head NAME

GEOS::Writer - Read geometries from WKT, WKB, and GEOJSON

=head SYNOPSIS

    use GEOS::Writer;

    my $writer = GEOS::Writer.new;

    my $point = $writer.write-wkt('POINT(1 2)');
    my $point = $writer.write-wkb($wkb-bytes);
    my $point = $writer.write-geojson($geojson-string);

=head DESCRIPTION

This module provides a simple interface for writing geometries as WKT, WKB, and GEOJSON.

=end pod

use GEOS::Native;

has $.context = GEOS_init_r();
has $.wkt-writer;

method write-wkt($geom) {
    $!wkt-writer //= GEOSWKTWriter_create_r($!context);
    GEOSWKTWriter_write_r($!context, $!wkt-writer, $geom);
}

submethod DESTROY {
    GEOSWKTWriter_destroy_r($!context, $!wkt-writer) if $!wkt-writer;
    GEOS_finish_r($!context);
}

