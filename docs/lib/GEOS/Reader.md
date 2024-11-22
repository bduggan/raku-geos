NAME
====

GEOS::Reader - Parse geometry strings into GEOS::Geometry objects

SYNOPSIS
========

    use GEOS::Reader;

    my $reader = GEOS::Reader.new;

    my $point = $reader.read-wkt('POINT(1 2)');
    my $point = $reader.read-geojson("{ 'type': 'Point', 'coordinates': [1, 2] }");

DESCRIPTION
===========

Read various forms of geometry representations into GEOS::Geometry objects.

### method read-wkt

```raku
method read-wkt(
    Str $wkt
) returns GEOS::Geometry
```

Read a geometry from WKT

### method read-geojson

```raku
method read-geojson(
    Str $geojson
) returns GEOS::Geometry
```

Read geojson

