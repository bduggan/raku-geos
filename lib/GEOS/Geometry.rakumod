=begin pod

=head1 NAME

GEOS::Geometry - GEOS geometries.

=head1 DESCRIPTION

This class provides methods for creating and manipulating GEOS geometries.

These are a slightly higher level interface to the GEOS C API than the
direct bindings that can be found in GEOS::Native.

Note that every object has its own thread context object for thread safety.

=head1 METHODS

=end pod

unit class GEOS::Geometry;
use GEOS::Native;

has $.geom;
has $!ctx = GEOS_init_r();

submethod DESTROY {
  GEOSGeom_destroy_r($!ctx, $!geom);
  GEOS_finish_r($!ctx);
}

#| Create a geometry from GeoJSON
method from-geojson(Str $geojson) {
    my $ctx = GEOS_init_r();
    my $reader = GEOSGeoJSONReader_create_r($ctx);
    my $geom = GEOSGeoJSONReader_readGeometry_r($ctx, $reader, $geojson);
    die "Failed to parse GeoJSON" unless $geom;
    GEOSGeoJSONReader_destroy_r($ctx, $reader);
    GEOS_finish_r($ctx);
    self.new(:geom($geom));
}

#| Serialize the geometry to GeoJSON
method geojson(Bool :$indent = False) {
    my $writer = GEOSGeoJSONWriter_create_r($!ctx);
    my $geojson = GEOSGeoJSONWriter_writeGeometry_r($!ctx, $writer, $.geom, $indent ?? 1 !! 0);
    GEOSWKTWriter_destroy_r($!ctx, $writer);
    $geojson;
}

#| Serialize the geometry to WKT
method wkt {
    my $writer = GEOSWKTWriter_create_r($!ctx);
    my $wkt = GEOSWKTWriter_write_r($!ctx, $writer, $.geom);
    GEOSWKTWriter_destroy_r($!ctx, $writer);
    $wkt;
}

#| Get the X coordinate of the first point in the geometry
method x {
    my num64 $x;
    GEOSGeomGetX_r($!ctx, $.geom, $x);
    $x;
}

#| Get the Y coordinate of the first point in the geometry
method y {
    my num64 $y;
    GEOSGeomGetY_r($!ctx, $.geom, $y);
    $y;
}

#| Get the Z coordinate of the first point in the geometry, or NaN if not available
method z {
    my num64 $z;
    GEOSGeomGetZ_r($!ctx, $.geom, $z);
    $z;
}

=begin pod

=head2 Basic properties

=end pod

#|  Area
method area(--> Num) {
    my num64 $area;
    GEOSArea_r($!ctx, $!geom, $area) == 1 or fail "Failed to compute area";
    $area;
}

#| Length
method length(--> Num) {
    my num64 $length;
    GEOSLength_r($!ctx, $!geom, $length) == 1 or fail "Failed to compute length";
    $length;
}

#| Number of dimensions (e.g. 0 for points, 2 for polygons)
method dimension(--> Int) {
    GEOSGeom_getDimensions_r($!ctx, $!geom);
}

#| Geometry type (e.g. "POINT", "LINESTRING", "POLYGON")
method geometry-type(--> Str) {
    my $type = GEOSGeomType_r($!ctx, $!geom);
    $type;
}

#| Check if the geometry is empty
method is-empty(--> Bool) {
    so GEOSisEmpty_r($!ctx, $!geom) eq 'True';
}

#| Check if the geometry is valid
method is-valid(--> Bool) {
    so GEOSisValid_r($!ctx, $!geom);
}

#| Check if the geometry is simple (i.e., does not self-intersect)
method is-simple(--> Bool) {
    given GEOSisSimple_r($!ctx, $!geom) {
      when 1 { True }
      when 0 { False }
      default { fail "Exception in GEOSisSimple_r"; }
    }
}

=begin pod

=head2 Geometric Operations

=end pod

#| Get the envelope of the geometry
method envelope(--> GEOS::Geometry) {
    my $geom = GEOSEnvelope_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

#| Get the boundary of the geometry
method boundary(--> GEOS::Geometry) {
    my $geom = GEOSBoundary_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

#| Get the convex hull of the geometry
method convex-hull(--> GEOS::Geometry) {
    my $geom = GEOSConvexHull_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

#| Get the centroid of the geometry
method centroid(--> GEOS::Geometry) {
    my $geom = GEOSGetCentroid_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

#| Buffer the geometry by a specified distance
method buffer(Num() $distance, Int :$segments = 8 --> GEOS::Geometry) {
    my $geom = GEOSBuffer_r($!ctx, $!geom, $distance, $segments);
    GEOS::Geometry.new: :$geom;
}

#| Simplify the geometry by a specified tolerance
method simplify(Num() $tolerance --> GEOS::Geometry) {
    my $geom = GEOSSimplify_r($!ctx, $!geom, $tolerance);
    GEOS::Geometry.new: :$geom;
}

#| Get the intersection of two geometries
method intersection(GEOS::Geometry $other --> GEOS::Geometry) {
    my $geom = GEOSIntersection_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new: :$geom;
}

#| Get the union of two geometries
method union(GEOS::Geometry $other --> GEOS::Geometry) {
    my $geom = GEOSUnion_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new: :$geom;
}

#| Get the difference between two geometries
method difference(GEOS::Geometry $other --> GEOS::Geometry) {
    my $geom = GEOSDifference_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new: :$geom;
}

#| Get the symmetric difference between two geometries
method sym-difference(GEOS::Geometry $other --> GEOS::Geometry) {
    my $geom = GEOSSymDifference_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new :$geom;
}

# like so, but many functions return 1 on true, 0 on false, 2 on exception
sub soo($val) {
  return True if $val == 1;
  return False if $val == 0;
  fail "Unexpected return value: $val";
}

# Spatial Predicates
#| Check if the geometry contains another geometry
method contains(GEOS::Geometry $other --> Bool) {
    soo GEOSContains_r($!ctx, $!geom, $other.geom);
}

#| Check if the geometry intersects another geometry
method intersects(GEOS::Geometry $other --> Bool) {
   soo  GEOSIntersects_r($!ctx, $!geom, $other.geom);
}

#| Check if the geometry is within another geometry
method within(GEOS::Geometry $other --> Bool) {
   soo GEOSWithin_r($!ctx, $!geom, $other.geom);
}

#| Check if the geometry touches another geometry
method touches(GEOS::Geometry $other --> Bool) {
   soo GEOSTouches_r($!ctx, $!geom, $other.geom);
}

#| Check if the geometry overlaps another geometry
method overlaps(GEOS::Geometry $other --> Bool) {
   soo GEOSOverlaps_r($!ctx, $!geom, $other.geom);
}

#| Check if the geometry is equal to another geometry
method equals(GEOS::Geometry $other --> Bool) {
   soo GEOSEquals_r($!ctx, $!geom, $other.geom);
}

# Distance Operations

#| Get the distance to another geometry
method distance-to(GEOS::Geometry $other --> Num) {
    my num64 $distance;
    GEOSDistance_r($!ctx, $!geom, $other.geom, $distance);
    $distance;
}

#| Get the Hausdorff distance to another geometry
method hausdorff-distance(GEOS::Geometry $other --> Num) {
    my num64 $distance;
    GEOSHausdorffDistance_r($!ctx, $!geom, $other.geom, $distance);
    $distance;
}

# Additional Geometric Operations
#| Get the oriented envelope of the geometry
method oriented-envelope(--> GEOS::Geometry) {
    my $geom = GEOSMinimumRotatedRectangle_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

#| Get the minimum bounding circle of the geometry
method minimum-circle(--> GEOS::Geometry) {
    my $geom = GEOSMinimumBoundingCircle_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

#| Get the unary union of the geometry
method unary-union(--> GEOS::Geometry) {
    my $geom = GEOSUnaryUnion_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

#| Snap the geometry to another geometry within a specified tolerance
method snap-to(GEOS::Geometry $other, Num() $tolerance --> GEOS::Geometry) {
    my $geom = GEOSSnap_r($!ctx, $!geom, $other.geom, $tolerance);
    GEOS::Geometry.new: :$geom;
}

#| Get the shared paths between two geometries
method shared-paths(GEOS::Geometry $other --> GEOS::Geometry) {
    my $geom = GEOSSharedPaths_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new: :$geom;
}

# Topology operations

#| Get the number of geometries in a geometry collection
method get-num-geometries(--> Int) {
    GEOSGetNumGeometries_r($!ctx, $!geom);
}

#| Get a specific geometry from a geometry collection
method get-geometry-n(Int $n --> GEOS::Geometry) {
    my $geom = GEOSGetGeometryN_r($!ctx, $!geom, $n);
    GEOS::Geometry.new: :$geom;
}

#| Get the exterior ring of a polygon
method get-exterior-ring(--> GEOS::Geometry) {
    my $geom = GEOSGetExteriorRing_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

#| Get the number of interior rings of a polygon
method get-num-interior-rings(--> Int) {
    GEOSGetNumInteriorRings_r($!ctx, $!geom);
}

#| Get a specific interior ring of a polygon
method get-interior-ring-n(Int $n --> GEOS::Geometry) {
    my $geom = GEOSGetInteriorRingN_r($!ctx, $!geom, $n);
    GEOS::Geometry.new: :$geom;
}

# Additional spatial predicates
#| Check if the geometry covers another geometry
method covers(GEOS::Geometry $other --> Bool) {
    soo GEOSCovers_r($!ctx, $!geom, $other.geom);
}

#| Check if the geometry is covered by another geometry
method covered-by(GEOS::Geometry $other --> Bool) {
    soo GEOSCoveredBy_r($!ctx, $!geom, $other.geom);
}

#| Check if the geometry crosses another geometry
method crosses(GEOS::Geometry $other --> Bool) {
    ? GEOSCrosses_r($!ctx, $!geom, $other.geom);
}

#| Check if the geometry is disjoint from another geometry
method disjoint(GEOS::Geometry $other --> Bool) {
    soo GEOSDisjoint_r($!ctx, $!geom, $other.geom);
}

# Distance and other metrics

#| Distance of a point projected onto a line from the start of a line
method project(GEOS::Geometry $other --> Num) {
    my num64 $result = GEOSProject_r($!ctx, $!geom, $other.geom);
    $result;
}

#| Measuring from the start of a line, return a point that is a proportion from
#| the start. The geometry must be a line.
method project-normalized(GEOS::Geometry $other --> Num) {
    my num64 $result = GEOSProjectNormalized_r($!ctx, $!geom, $other.geom);
    $result;
}

#| Frechet distance between two geometries
method frechet-distance(GEOS::Geometry $other --> Num) {
    my num64 $distance;
    GEOSFrechetDistance_r($!ctx, $!geom, $other.geom, $distance);
    $distance;
}

# Validation and fixing
#| Make the geometry valid
method make-valid(--> GEOS::Geometry) {
    my $geom = GEOSMakeValid_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

#| Normalize the geometry
method normalize(--> Bool) {
    # GEOSNormalize_r modifies in place and returns an int status
    my $status = GEOSNormalize_r($!ctx, $!geom);
    return $status == 0;
}

method reverse(--> GEOS::Geometry) {
    my $result = GEOSReverse_r($!ctx, $!geom);
    GEOS::Geometry.new(:geom($result));
}

method get-precision(--> Num) {
    my num64 $precision;
    GEOSGeom_getPrecision_r($!ctx, $!geom, $precision);
    $precision;
}

method set-precision(Num() $precision, Bool :$preserve-topology = True --> GEOS::Geometry) {
    my $result = GEOSGeom_setPrecision_r($!ctx, $!geom, $precision, $preserve-topology ?? 1 !! 0);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

method get-coordinates(--> List) {
  my $coord_seq = GEOSGeom_getCoordSeq_r($!ctx, $!geom);
  my uint32 $size;
  GEOSCoordSeq_getSize_r($!ctx, $coord_seq, $size);
  my @coords;
  for ^$size -> $i {
    my num64 ($x, $y);
    GEOSCoordSeq_getX_r($!ctx, $coord_seq, $i, $x);
    GEOSCoordSeq_getY_r($!ctx, $coord_seq, $i, $y);
    @coords.push: [$x, $y];
  }
  @coords;
}

