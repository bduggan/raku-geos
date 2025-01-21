#!/usr/bin/env raku

use JSON::Fast;
use GEOS::Geometry;

my $g = GEOS::Geometry.from-wkt('POINT(1 1)');
say from-json( $g.geojson );
say $g.get-coordinates;

$g = GEOS::Geometry.from-wkt('LINESTRING(0 0, 1 1, 2 2)');
say from-json( $g.geojson );
say $g.get-coordinates;

$g = GEOS::Geometry.from-wkt('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))');
say from-json( $g.geojson );
say  $g.get-coordinates;


