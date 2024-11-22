head
====

NAME

GEOS::Reader - Read geometries from WKT, WKB, and GEOJSON

head
====

SYNOPSIS

    use GEOS::Reader;

    my $reader = GEOS::Reader.new;

    my $point = $reader.read-wkt('POINT(1 2)');
    my $point = $reader.read-wkb($wkb-bytes);
    my $point = $reader.read-geojson($geojson-string);

head
====

DESCRIPTION

This module provides a simple interface for reading geometries from WKT, WKB, and GEOJSON.

### method read-wkt

```raku
method read-wkt(
    Str $wkt
) returns GEOS::Geometry
```

Read a geometry from WKB

