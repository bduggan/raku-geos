[![Actions Status](https://github.com/bduggan/raku-geos/actions/workflows/linux.yml/badge.svg)](https://github.com/bduggan/raku-geos/actions/workflows/linux.yml)
[![Actions Status](https://github.com/bduggan/raku-geos/actions/workflows/macos.yml/badge.svg)](https://github.com/bduggan/raku-geos/actions/workflows/macos.yml)

NAME
====

GEOS::Native - Native bindings to the GEOS library

SYNOPSIS
========

Read a WKT string and write it as GeoJSON:

    use GEOS::Native;

    my $wkt = "POINT(1 1)";
    my $ctx = GEOS_init_r();
    my $reader = GEOSWKTReader_create_r($ctx);
    my $geom-a = GEOSWKTReader_read_r($ctx, $reader, $wkt);
    my $geojson-writer = GEOSGeoJSONWriter_create_r($ctx);
    say GEOSGeoJSONWriter_writeGeometry_r($ctx, $geojson-writer, $geom-a, 1);

    # {
    #  "type": "Point",
    #  "coordinates": [
    #   1.0,
    #   1.0
    #  ]
    # }

Create two squares and calculate their intersection:

    use GEOS::Native;

    my $context = GEOS_init_r();
    my $reader = GEOSWKTReader_create_r($context);
    my $writer = GEOSWKTWriter_create_r($context);
    
    my $square1 = GEOSWKTReader_read_r($context, $reader, 'POLYGON((0 0, 2 0, 2 2, 0 2, 0 0))');
    my $square2 = GEOSWKTReader_read_r($context, $reader, 'POLYGON((1 1, 3 1, 3 3, 1 3, 1 1))');
 
    my $intersection = GEOSIntersection_r($context, $square1, $square2);
    say GEOSWKTWriter_write_r($context, $writer, $intersection);
    # POLYGON ((2 2, 2 1, 1 1, 1 2, 2 2))

    for $square1, $square2, $intersection -> $geom {
        GEOSGeom_destroy_r($context, $geom);
    }

    GEOSWKTReader_destroy_r($context, $reader);
    GEOSWKTWriter_destroy_r($context, $writer);

    GEOS_finish_r($context);



DESCRIPTION
===========

This module provides native bindings to libgeos: https://libgeos.oeg

The status of this module is EXPERIMENTAL. Everything may change, and some things might not work. Consult the test suite to see what is currently implemented.

Currently the thread-safe bindings have been implemented, and there are even a few tests that verify that they work.

AUTHOR
======

Brian Duggan

