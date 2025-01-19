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

