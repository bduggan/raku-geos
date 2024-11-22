head
====

NAME

GEOS::Writer - Serialize geometries into various formats

head
====

SYNOPSIS

    use GEOS::Writer;

    my $writer = GEOS::Writer.new;

    say $writer.write-wkt($geometry);
    say $writer.write-geojson($geometry);

head
====

DESCRIPTION

This module provides a simple interface for converting geometry objects into different foramts.

METHODS
=======

### method write-wkt

```raku
method write-wkt(
    GEOS::Geometry $geom
) returns Str
```

Generate a WKT string

### method write-geojson

```raku
method write-geojson(
    GEOS::Geometry $geom,
    Bool :$indent = Bool::True
) returns Str
```

Generate a geojson string

