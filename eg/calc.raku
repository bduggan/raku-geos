#!raku

use GEOS::Geometry;

my $geom = GEOS::Geometry.from-geojson('{"type":"Point","coordinates" : [1,1]}');

say $geom.centroid.wkt;

