unit class GEOS::Geometry;
use GEOS::Native;

has $.geom;
has $.ctx;

submethod DESTROY {
  GEOSGeom_destroy_r($!ctx, $!geom);
}