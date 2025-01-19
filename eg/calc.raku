#!raku

use GEOS::Calculator 'c';
use GEOS::Geometry;

my $geom = GEOS::Geometry.from-geojson('{"type":"Point","coordinat[1,1]}');

my $centroid = c.centroid($geom);
say $centroid.wkt;
say $centroid.geojson;

