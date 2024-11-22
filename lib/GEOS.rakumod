unit module GEOS;

=begin pod

=head1 NAME

GEOS - Raku bindings and wrappers for libgeos

=head1 SYNOPSIS

=begin code

use GEOS::Reader;
use GEOS::Calculator 'c';

my $r = GEOS::Reader.new;
my $x = $r.read-wkt('POINT(1 1)');
my $y = $r.read-wkt('POINT(1 2)');
my $d = c.distance($x,$y);

say $d; # 1

=end code

=head1 DESCRIPTION

There are a few modules in this distribution: native bindings to libgeos,
and high-level wrappers to various functions.

For documentation, please see the individual modules.

* L<GEOS::Native|https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Native.md> -- low-level interface to libgeos

* L<GEOS::Reader|https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Reader.md> -- high-level interface to libgeos routines for reading geometries

* L<GEOS::Writer|https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Writer.md> -- high-level interface to libgeos routines for serializing geometries

* L<GEOS::Calculator|https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Calculator.md> -- high-level interface to geometry calculations, such as distance, area, etc.

=head1 AUTHOR

Brian Duggan

=end pod
