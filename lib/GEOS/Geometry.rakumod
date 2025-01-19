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

method envelope(--> GEOS::Geometry) {
    my $geom = GEOSEnvelope_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

method boundary(--> GEOS::Geometry) {
    my $geom = GEOSBoundary_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

method convex-hull(--> GEOS::Geometry) {
    my $geom = GEOSConvexHull_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

method centroid(--> GEOS::Geometry) {
    my $geom = GEOSGetCentroid_r($!ctx, $!geom);
    GEOS::Geometry.new: :$geom;
}

method buffer(Num() $distance, Int :$segments = 8 --> GEOS::Geometry) {
    my $geom = GEOSBuffer_r($!ctx, $!geom, $distance, $segments);
    GEOS::Geometry.new: :$geom;
}

method simplify(Num() $tolerance --> GEOS::Geometry) {
    my $geom = GEOSSimplify_r($!ctx, $!geom, $tolerance);
    GEOS::Geometry.new: :$geom;
}

# Geometric Set Operations
method intersection(GEOS::Geometry $other --> GEOS::Geometry) {
    my $geom = GEOSIntersection_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new: :$geom;
}

method union(GEOS::Geometry $other --> GEOS::Geometry) {
    my $geom = GEOSUnion_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new: :$geom;
}

method difference(GEOS::Geometry $other --> GEOS::Geometry) {
    my $geom = GEOSDifference_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new: :$geom;
}

method sym-difference(GEOS::Geometry $other --> GEOS::Geometry) {
    my $geom = GEOSSymDifference_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new :$geom;
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


method unary-union(--> GEOS::Geometry) {
    my $result = GEOSUnaryUnion_r($!ctx, $!geom);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

method snap-to(GEOS::Geometry $other, Num() $tolerance --> GEOS::Geometry) {
    my $result = GEOSSnap_r($!ctx, $!geom, $other.geom, $tolerance);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

method shared-paths(GEOS::Geometry $other --> GEOS::Geometry) {
    my $result = GEOSSharedPaths_r($!ctx, $!geom, $other.geom);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

# Topology operations
method get-num-geometries(--> Int) {
    GEOSGetNumGeometries_r($!ctx, $!geom);
}

method get-geometry-n(Int $n --> GEOS::Geometry) {
    my $result = GEOSGetGeometryN_r($!ctx, $!geom, $n);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

method get-exterior-ring(--> GEOS::Geometry) {
    my $result = GEOSGetExteriorRing_r($!ctx, $!geom);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

method get-num-interior-rings(--> Int) {
    GEOSGetNumInteriorRings_r($!ctx, $!geom);
}

method get-interior-ring-n(Int $n --> GEOS::Geometry) {
    my $result = GEOSGetInteriorRingN_r($!ctx, $!geom, $n);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

# Additional spatial predicates
method covers(GEOS::Geometry $other --> Bool) {
    ? GEOSCovers_r($!ctx, $!geom, $other.geom);
}

method covered-by(GEOS::Geometry $other --> Bool) {
    ? GEOSCoveredBy_r($!ctx, $!geom, $other.geom);
}

method crosses(GEOS::Geometry $other --> Bool) {
    ? GEOSCrosses_r($!ctx, $!geom, $other.geom);
}

method disjoint(GEOS::Geometry $other --> Bool) {
    ? GEOSDisjoint_r($!ctx, $!geom, $other.geom);
}

# Distance and other metrics
method project(GEOS::Geometry $other --> Num) {
    my num64 $result = GEOSProject_r($!ctx, $!geom, $other.geom);
    $result;
}

method project-normalized(GEOS::Geometry $other --> Num) {
    my num64 $result = GEOSProjectNormalized_r($!ctx, $!geom, $other.geom);
    $result;
}

method frechet-distance(GEOS::Geometry $other --> Num) {
    my num64 $distance;
    GEOSFrechetDistance_r($!ctx, $!geom, $other.geom, $distance);
    $distance;
}

# Validation and fixing
method make-valid(--> GEOS::Geometry) {
    my $result = GEOSMakeValid_r($!ctx, $!geom);
    GEOS::Geometry.new(:geom($result), :ctx($!ctx));
}

method normalize(--> GEOS::Geometry) {
    # GEOSNormalize_r modifies in place and returns an int status
    my $status = GEOSNormalize_r($!ctx, $!geom);
    die "Normalization failed; $status" if $status != 0;
    
    # Return a new geometry that's a copy of the normalized one
    my $writer = GEOSWKTWriter_create_r($!ctx);
    my $wkt = GEOSWKTWriter_write_r($!ctx, $writer, $!geom);
    GEOSWKTWriter_destroy_r($!ctx, $writer);
    
    my $reader = GEOSWKTReader_create_r($!ctx);
    my $new_geom = GEOSWKTReader_read_r($!ctx, $reader, $wkt);
    GEOSWKTReader_destroy_r($!ctx, $reader);
    
    GEOS::Geometry.new(:geom($new_geom), :ctx($!ctx));
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

