NAME
====

GEOS - Raku bindings and wrappers for libgeos

SYNOPSIS
========

    use GEOS::Reader;
    use GEOS::Calculator 'c';

    my $r = GEOS::Reader.new;
    my $x = $r.read-wkt('POINT(1 1)');
    my $y = $r.read-wkt('POINT(1 2)');
    my $d = c.distance($x,$y);

    say $d; # 1

DESCRIPTION
===========

There are a few modules in this distribution: native bindings to libgeos, and high-level wrappers to various functions.

For documentation, please see the individual modules.

* [GEOS::Native](https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Native.md) -- low-level interface to libgeos

* [GEOS::Reader](https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Reader.md) -- high-level interface to libgeos routines for reading geometries

* [GEOS::Writer](https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Writer.md) -- high-level interface to libgeos routines for serializing geometries

* [GEOS::Calculator](https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Calculator.md) -- high-level interface to geometry calculations, such as distance, area, etc.

AUTHOR
======

Brian Duggan

