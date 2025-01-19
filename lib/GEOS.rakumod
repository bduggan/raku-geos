unit module GEOS;

=begin pod

=head1 NAME

GEOS - Raku bindings and wrappers for libgeos

=head1 SYNOPSIS

=begin code

use GEOS::Geometry;

my $polygon = GEOS::Geometry.from-geojson('{"type":"Polygon","coordinates":[[[0,0],[0,4],[4,4],[4,0],[0,0]]]}');
my $buffered = $polygon.buffer(2);

say $polygon.area;  # 16
say $buffered.area;  # 60

=end code

=head1 DESCRIPTION

This module provides Raku bindings and wrappers for the C<libgeos> library, L<https://libgeos.org/>.

GEOS provides numerous C functions for creating, manipulating, and analyzing geometric objects.

Some examples include properties like area, length, buffer, intersection, union, difference,
predicates like contains, intersects, within, touches, overlaps, equals, distance, hausdorff-distance,
and manipulations such as simplify, snap-to, reverse, normalize, make-valid, minimum-circle, oriented-envelope,
unary-union, shared-paths, project, project-normalized, frechet-distance, and more.

For a more complete list of functions available through this module, see the L<GEOS::Geometry|https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Geometry.md> module.

=head SEE ALSO

* L<GEOS::Geometry|https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Geometry.md>  -- GEOS geometries and methods that relate to them.

* L<GEOS::Native|https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Native.md> -- low-level interface to libgeos

* L<GEOS::Reader|https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Reader.md> -- high-level interface to libgeos routines for reading geometries

* L<GEOS::Writer|https://github.com/bduggan/raku-geos/blob/master/docs/lib/GEOS/Writer.md> -- high-level interface to libgeos routines for serializing geometries

=head1 AUTHOR

Brian Duggan

=end pod
