NAME
====

GEOS::Calculator -- geospatial calculations using libgeos

SYNOPSIS
========

    use GEOS::Reader;
    use GEOS::Calculator 'c';

    my $r = GEOS::Reader.new;
    my $x = $r.read-wkt('POINT(1 1)');
    my $y = $r.read-wkt('POINT(1 2)');
    my $d = c.distance($x,$y);

### method distance

```raku
method distance(
    GEOS::Geometry $x,
    GEOS::Geometry $y
) returns Mu
```

Calculate the distance between two geometries

