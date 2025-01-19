[![Actions Status](https://github.com/bduggan/raku-geos/actions/workflows/linux.yml/badge.svg)](https://github.com/bduggan/raku-geos/actions/workflows/linux.yml)
[![Actions Status](https://github.com/bduggan/raku-geos/actions/workflows/macos.yml/badge.svg)](https://github.com/bduggan/raku-geos/actions/workflows/macos.yml)

NAME
====

GEOS - Raku bindings and wrappers for libgeos

SYNOPSIS
========

    use GEOS::Geometry;

    my $polygon = GEOS::Geometry.from-geojson('{"type":"Polygon","coordinates":[[[0,0],[0,4],[4,4],[4,0],[0,0]]]}');
    my $buffered = $polygon.buffer(2);

    say $polygon.area;  # 16
    say $buffered.area;  # 60

DESCRIPTION
===========

This module provides Raku bindings and wrappers for the `libgeos` library, [https://libgeos.org/](https://libgeos.org/).

GEOS provides numerous C functions for creating, manipulating, and analyzing geometric objects.

A fraction of the functionality offered includes:

* creating geometries from WKT and GeoJSON

* computing properties like area and length

* performing set operations such as intersection, union, difference, and symmetric difference

* using predicates like contains, intersects, within, touches, overlaps, equals

* doing calculations like distance, hausdorff-distance, frechet-distance

* doing manipulations such as simplify, snap-to, reverse, normalize, make-valid, minimum-circle, oriented-envelope

For a more complete list of functions available through this module, see the [GEOS::Geometry](https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Geometry.md) module.

SEE ALSO
========

* [GEOS::Geometry](https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Geometry.md) -- GEOS geometries and methods that relate to them.

* [GEOS::Native](https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Native.md) -- low-level interface to libgeos

* [GEOS::Reader](https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Reader.md) -- high-level interface to libgeos routines for reading geometries

* [GEOS::Writer](https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Writer.md) -- high-level interface to libgeos routines for serializing geometries

AUTHOR
======

Brian Duggan

