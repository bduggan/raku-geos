=begin pod

=head1 NAME

GEOS::Geometry - Base class for GEOS geometries

=end pod

unit class GEOS::Geometry;
use GEOS::Native;

has $.geom;
has $.ctx = GEOS_init_r();

submethod DESTROY {
  GEOSGeom_destroy_r($!ctx, $!geom);
  GEOS_finish_r($!ctx);
}

method from-geojson(Str $geojson) {
    my $ctx = GEOS_init_r();
    my $reader = GEOSGeoJSONReader_create_r($ctx);
    my $geom = GEOSGeoJSONReader_readGeometry_r($ctx, $reader, $geojson);
    die "Failed to parse GeoJSON" unless $geom;
    GEOSGeoJSONReader_destroy_r($ctx, $reader);
    GEOS_finish_r($ctx);
    self.new(:geom($geom));
}

method geojson(Bool :$indent = False) {
    my $writer = GEOSGeoJSONWriter_create_r($!ctx);
    my $geojson = GEOSGeoJSONWriter_writeGeometry_r($!ctx, $writer, $.geom, $indent ?? 1 !! 0);
    GEOSWKTWriter_destroy_r($!ctx, $writer);
    $geojson;
}

method wkt {
    my $writer = GEOSWKTWriter_create_r($!ctx);
    my $wkt = GEOSWKTWriter_write_r($!ctx, $writer, $.geom);
    GEOSWKTWriter_destroy_r($!ctx, $writer);
    $wkt;
}


method x {
    my num64 $x;
    GEOSGeomGetX_r($!ctx, $.geom, $x);
    $x;
}

method y {
    my num64 $y;
    GEOSGeomGetY_r($!ctx, $.geom, $y);
    $y;
}

method z {
    my num64 $z;
    GEOSGeomGetZ_r($!ctx, $.geom, $z);
    $z;
}


# Basic Properties
method area(--> Num) {
    my num64 $area;
    GEOSArea_r($!ctx, $!geom, $area);
    $area;
}

method length(--> Num) {
    my num64 $length;
    GEOSLength_r($!ctx, $!geom, $length);
    $length;
}

method dimension(--> Int) {
    GEOSGeom_getDimensions_r($!ctx, $!geom);
}

method geometry-type(--> Str) {
    my $type = GEOSGeomType_r($!ctx, $!geom);
    $type;
}

method is-empty(--> Bool) {
    so GEOSisEmpty_r($!ctx, $!geom) eq 'True';
}

method is-valid(--> Bool) {
    ? GEOSisValid_r($!ctx, $!geom);
}

method is-simple(--> Bool) {
    ? GEOSisSimple_r($!ctx, $!geom);
}

# Geometric Operations
method envelope(--> GEOS::Geometry) {
    my $envelope = GEOSEnvelope_r($!ctx, $!geom);
    GEOS::Geometry.new(:geom($envelope), :ctx($!ctx));
}

method boundary(--> GEOS::Geometry) {
    my $boundary = GEOSBoundary_r($!ctx, $!geom);
    GEOS::Geometry.new(:geom($boundary), :ctx($!ctx));
}

method convex-hull(--> GEOS::Geometry) {
    my $hull = GEOSConvexHull_r($!ctx, $!geom);
    GEOS::Geometry.new(:geom($hull), :ctx($!ctx));
}

method centroid(--> GEOS::Geometry) {
    my $centroid = GEOSGetCentroid_r($!ctx, $!geom);
    GEOS::Geometry.new(:geom($centroid), :ctx($!ctx));
}

method buffer(Num() $distance, Int :$segments = 8 --> GEOS::Geometry) {
    my $buffered = GEOSBuffer_r($!ctx, $!geom, $distance, $segments);
    GEOS::Geometry.new(:geom($buffered), :ctx($!ctx));
}

method simplify(Num() $tolerance --> GEOS::Geometry) {
    my $simplified = GEOSSimplify_r($!ctx, $!geom, $tolerance);
    GEOS::Geometry.new(:geom($simplified), :ctx($!ctx));
}

# Geometric Set Operations
method intersection(GEOS::Geometry $other --> GEOS::Geometry) {
    my $result = GEOSIntersection_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

method union(GEOS::Geometry $other --> GEOS::Geometry) {
    my $result = GEOSUnion_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

method difference(GEOS::Geometry $other --> GEOS::Geometry) {
    my $result = GEOSDifference_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

method sym-difference(GEOS::Geometry $other --> GEOS::Geometry) {
    my $result = GEOSSymDifference_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

# Spatial Predicates
method contains(GEOS::Geometry $other --> Bool) {
    ? GEOSContains_r($!ctx, $!geom, $other.geom);
}

method intersects(GEOS::Geometry $other --> Bool) {
    ? GEOSIntersects_r($!ctx, $!geom, $other.geom);
}

method within(GEOS::Geometry $other --> Bool) {
    ? GEOSWithin_r($!ctx, $!geom, $other.geom);
}

method touches(GEOS::Geometry $other --> Bool) {
    ? GEOSTouches_r($!ctx, $!geom, $other.geom);
}

method overlaps(GEOS::Geometry $other --> Bool) {
    ? GEOSOverlaps_r($!ctx, $!geom, $other.geom);
}

method equals(GEOS::Geometry $other --> Bool) {
    ? GEOSEquals_r($!ctx, $!geom, $other.geom);
}

# Distance Operations
method distance-to(GEOS::Geometry $other --> Num) {
    my num64 $distance;
    GEOSDistance_r($!ctx, $!geom, $other.geom, $distance);
    $distance;
}

method hausdorff-distance(GEOS::Geometry $other --> Num) {
    my num64 $distance;
    GEOSHausdorffDistance_r($!ctx, $!geom, $other.geom, $distance);
    $distance;
}

# Additional Geometric Operations
method oriented-envelope(--> GEOS::Geometry) {
    my $result = GEOSMinimumRotatedRectangle_r($!ctx, $!geom);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

method minimum-circle(--> GEOS::Geometry) {
    my $result = GEOSMinimumBoundingCircle_r($!ctx, $!geom);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

