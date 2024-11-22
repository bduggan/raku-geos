head
====

NAME

GEOS::Writer - Serialize geometries to WKT, WKB, and GEOJSON

head
====

SYNOPSIS

    use GEOS::Writer;

    my $writer = GEOS::Writer.new;

    my $point = $writer.write-wkt('POINT(1 2)');
    my $point = $writer.write-wkb($wkb-bytes);
    my $point = $writer.write-geojson($geojson-string);

head
====

DESCRIPTION

This module provides a simple interface for writing geometries as WKT, WKB, and GEOJSON.

METHODS
=======

### method write-wkt

```raku
method write-wkt(
    GEOS::Geometry $geom
) returns Str
```

Generate a WKT string

