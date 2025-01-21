NAME
====

GEOS::Geometry - GEOS geometries.

DESCRIPTION
===========

This class provides methods for creating and manipulating GEOS geometries.

These are a slightly higher level interface to the GEOS C API than the direct bindings that can be found in GEOS::Native.

Note that every object has its own thread context object for thread safety.

METHODS
=======

### method from-geojson

```raku
method from-geojson(
    Str $geojson
) returns Mu
```

Create a geometry from GeoJSON

### method from-wkt

```raku
method from-wkt(
    Str $wkt
) returns Mu
```

Create a geometry from WKT

### method geojson

```raku
method geojson(
    Bool :$indent = Bool::False
) returns Mu
```

Serialize the geometry to GeoJSON

### method wkt

```raku
method wkt() returns Mu
```

Serialize the geometry to WKT

### method x

```raku
method x() returns Mu
```

Get the X coordinate of the first point in the geometry

### method y

```raku
method y() returns Mu
```

Get the Y coordinate of the first point in the geometry

### method z

```raku
method z() returns Mu
```

Get the Z coordinate of the first point in the geometry, or NaN if not available

Basic properties
----------------

### method area

```raku
method area() returns Num
```

Area

### method length

```raku
method length() returns Num
```

Length

### method dimension

```raku
method dimension() returns Int
```

Number of dimensions (e.g. 0 for points, 2 for polygons)

### method geometry-type

```raku
method geometry-type() returns Str
```

Geometry type (e.g. "POINT", "LINESTRING", "POLYGON")

### method is-empty

```raku
method is-empty() returns Bool
```

Check if the geometry is empty

### method is-valid

```raku
method is-valid() returns Bool
```

Check if the geometry is valid

### method is-simple

```raku
method is-simple() returns Bool
```

Check if the geometry is simple (i.e., does not self-intersect)

Geometric Operations
--------------------

### method envelope

```raku
method envelope() returns GEOS::Geometry
```

Get the envelope of the geometry

### method boundary

```raku
method boundary() returns GEOS::Geometry
```

Get the boundary of the geometry

### method convex-hull

```raku
method convex-hull() returns GEOS::Geometry
```

Get the convex hull of the geometry

### method centroid

```raku
method centroid() returns GEOS::Geometry
```

Get the centroid of the geometry

### method buffer

```raku
method buffer(
    Num(Any) $distance,
    Int :$segments = 8
) returns GEOS::Geometry
```

Buffer the geometry by a specified distance

### method simplify

```raku
method simplify(
    Num(Any) $tolerance
) returns GEOS::Geometry
```

Simplify the geometry by a specified tolerance

### method intersection

```raku
method intersection(
    GEOS::Geometry $other
) returns GEOS::Geometry
```

Get the intersection of two geometries

### method union

```raku
method union(
    GEOS::Geometry $other
) returns GEOS::Geometry
```

Get the union of two geometries

### method difference

```raku
method difference(
    GEOS::Geometry $other
) returns GEOS::Geometry
```

Get the difference between two geometries

### method sym-difference

```raku
method sym-difference(
    GEOS::Geometry $other
) returns GEOS::Geometry
```

Get the symmetric difference between two geometries

### method contains

```raku
method contains(
    GEOS::Geometry $other
) returns Bool
```

Check if the geometry contains another geometry

### method intersects

```raku
method intersects(
    GEOS::Geometry $other
) returns Bool
```

Check if the geometry intersects another geometry

### method within

```raku
method within(
    GEOS::Geometry $other
) returns Bool
```

Check if the geometry is within another geometry

### method touches

```raku
method touches(
    GEOS::Geometry $other
) returns Bool
```

Check if the geometry touches another geometry

### method overlaps

```raku
method overlaps(
    GEOS::Geometry $other
) returns Bool
```

Check if the geometry overlaps another geometry

### method equals

```raku
method equals(
    GEOS::Geometry $other
) returns Bool
```

Check if the geometry is equal to another geometry

### method distance-to

```raku
method distance-to(
    GEOS::Geometry $other
) returns Num
```

Get the distance to another geometry

### method hausdorff-distance

```raku
method hausdorff-distance(
    GEOS::Geometry $other
) returns Num
```

Get the Hausdorff distance to another geometry

### method oriented-envelope

```raku
method oriented-envelope() returns GEOS::Geometry
```

Get the oriented envelope of the geometry

### method minimum-circle

```raku
method minimum-circle() returns GEOS::Geometry
```

Get the minimum bounding circle of the geometry

### method unary-union

```raku
method unary-union() returns GEOS::Geometry
```

Get the unary union of the geometry

### method snap-to

```raku
method snap-to(
    GEOS::Geometry $other,
    Num(Any) $tolerance
) returns GEOS::Geometry
```

Snap the geometry to another geometry within a specified tolerance

### method shared-paths

```raku
method shared-paths(
    GEOS::Geometry $other
) returns GEOS::Geometry
```

Get the shared paths between two geometries

### method get-num-geometries

```raku
method get-num-geometries() returns Int
```

Get the number of geometries in a geometry collection

### method get-geometry-n

```raku
method get-geometry-n(
    Int $n
) returns GEOS::Geometry
```

Get a specific geometry from a geometry collection

### method get-exterior-ring

```raku
method get-exterior-ring() returns GEOS::Geometry
```

Get the exterior ring of a polygon

### method get-num-interior-rings

```raku
method get-num-interior-rings() returns Int
```

Get the number of interior rings of a polygon

### method get-interior-ring-n

```raku
method get-interior-ring-n(
    Int $n
) returns GEOS::Geometry
```

Get a specific interior ring of a polygon

### method covers

```raku
method covers(
    GEOS::Geometry $other
) returns Bool
```

Check if the geometry covers another geometry

### method covered-by

```raku
method covered-by(
    GEOS::Geometry $other
) returns Bool
```

Check if the geometry is covered by another geometry

### method crosses

```raku
method crosses(
    GEOS::Geometry $other
) returns Bool
```

Check if the geometry crosses another geometry

### method disjoint

```raku
method disjoint(
    GEOS::Geometry $other
) returns Bool
```

Check if the geometry is disjoint from another geometry

### method project

```raku
method project(
    GEOS::Geometry $other
) returns Num
```

Distance of a point projected onto a line from the start of a line

### method project-normalized

```raku
method project-normalized(
    GEOS::Geometry $other
) returns Num
```

Measuring from the start of a line, return a point that is a proportion from the start. The geometry must be a line.

### method frechet-distance

```raku
method frechet-distance(
    GEOS::Geometry $other
) returns Num
```

Frechet distance between two geometries

### method make-valid

```raku
method make-valid() returns GEOS::Geometry
```

Make the geometry valid

### method normalize

```raku
method normalize() returns Bool
```

Normalize the geometry

### method reverse

```raku
method reverse() returns GEOS::Geometry
```

Reverse the geometry

### method get-precision

```raku
method get-precision() returns Num
```

Get the precision of the geometry

### method set-precision

```raku
method set-precision(
    Num(Any) $precision,
    Bool :$preserve-topology = Bool::True
) returns GEOS::Geometry
```

Set the precision of the geometry

### method get-coordinates

```raku
method get-coordinates() returns List
```

Get the coordinates of the geometry

