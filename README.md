[![Actions Status](https://github.com/bduggan/raku-geos/actions/workflows/linux.yml/badge.svg)](https://github.com/bduggan/raku-geos/actions/workflows/linux.yml)
[![Actions Status](https://github.com/bduggan/raku-geos/actions/workflows/macos.yml/badge.svg)](https://github.com/bduggan/raku-geos/actions/workflows/macos.yml)

NAME
====

GEOS::Native - Native bindings to the GEOS library

SYNOPSIS
========

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

DESCRIPTION
===========

This module provides native bindings to libgeos: https://libgeos.oeg

The status of this module is EXPERIMENTAL. Everything may change, and some things might not work. Consult the test suite to see what is currently implemented.

Currently the thread-safe bindings have been implemented, and there are even a few tests that verify that they work.

AUTHOR
======

Brian Duggan

