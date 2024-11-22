[![Actions Status](https://github.com/bduggan/raku-geos/actions/workflows/linux.yml/badge.svg)](https://github.com/bduggan/raku-geos/actions/workflows/linux.yml)
[![Actions Status](https://github.com/bduggan/raku-geos/actions/workflows/macos.yml/badge.svg)](https://github.com/bduggan/raku-geos/actions/workflows/macos.yml)

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

* [GEOS::Native](https://github.com/bduggan/raku-geos/blob/master/lib/GEOS/Native.rakumod)> -- low-level interface to libgeos

* [GEOS::Reader](https://github.com/bduggan/raku-geos/blob/master/lib/GEOS/Reader.rakumod) -- high-level interface to libgeos routines for reading geometries

* [GEOS::Writer](https://github.com/bduggan/raku-geos/blob/master/lib/GEOS/Writer.rakumod) -- high-level interface to libgeos routines for serializing geometries

* [GEOS::Calculator](https://github.com/bduggan/raku-geos/blob/master/lib/GEOS/Calculator.rakumod) -- high-level interface to geometry calculations, such as distance, area, etc.

AUTHOR
======

Brian Duggan

