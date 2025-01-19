use GEOS::Geometry;
use Map::Leaflet;

my $map = Map::Leaflet.new;

my $polygon = GEOS::Geometry.from-geojson('{"type":"Polygon","coordinates":[[[0,0],[0,4],[4,4],[4,0],[0,0]]]}');
my $buffered = $polygon.buffer(2);

say $polygon.area;
say $buffered.area;

