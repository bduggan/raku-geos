use Test;
use lib 'lib';
use GEOS::Native;

plan 28;

# Test enum declarations
subtest 'GEOSGeomTypes enum', {
    plan 13;
    ok GEOS_POINT == 0, 'POINT type value is correct';
    ok GEOS_LINESTRING == 1, 'LINESTRING type value is correct';
    ok GEOS_LINEARRING == 2, 'LINEARRING type value is correct';
    ok GEOS_POLYGON == 3, 'POLYGON type value is correct';
    ok GEOS_MULTIPOINT == 4, 'MULTIPOINT type value is correct';
    ok GEOS_MULTILINESTRING == 5, 'MULTILINESTRING type value is correct';
    ok GEOS_MULTIPOLYGON == 6, 'MULTIPOLYGON type value is correct';
    ok GEOS_GEOMETRYCOLLECTION == 7, 'GEOMETRYCOLLECTION type value is correct';
    ok GEOS_CIRCULARSTRING == 8, 'CIRCULARSTRING type value is correct';
    ok GEOS_COMPOUNDCURVE == 9, 'COMPOUNDCURVE type value is correct';
    ok GEOS_CURVEPOLYGON == 10, 'CURVEPOLYGON type value is correct';
    ok GEOS_MULTICURVE == 11, 'MULTICURVE type value is correct';
    ok GEOS_MULTISURFACE == 12, 'MULTISURFACE type value is correct';
};

subtest 'GEOSWKBByteOrders enum', {
    plan 2;
    ok GEOS_WKB_XDR == 0, 'XDR byte order value is correct';
    ok GEOS_WKB_NDR == 1, 'NDR byte order value is correct';
};

subtest 'GEOSBufCapStyles enum', {
    plan 3;
    ok GEOSBUF_CAP_ROUND == 1, 'ROUND cap style value is correct';
    ok GEOSBUF_CAP_FLAT == 2, 'FLAT cap style value is correct';
    ok GEOSBUF_CAP_SQUARE == 3, 'SQUARE cap style value is correct';
};

subtest 'GEOSBufJoinStyles enum', {
    plan 3;
    ok GEOSBUF_JOIN_ROUND == 1, 'ROUND join style value is correct';
    ok GEOSBUF_JOIN_MITRE == 2, 'MITRE join style value is correct';
    ok GEOSBUF_JOIN_BEVEL == 3, 'BEVEL join style value is correct';
};

# Test class declarations
ok GEOSContextHandle.^can('new'), 'GEOSContextHandle class is declared';
ok GEOSGeometry.^can('new'), 'GEOSGeometry class is declared';
ok GEOSWKTReader.^can('new'), 'GEOSWKTReader class is declared';
ok GEOSWKTWriter.^can('new'), 'GEOSWKTWriter class is declared';

# Test basic context handling
{
    my $context = GEOS_init_r();
    ok $context ~~ GEOSContextHandle, 'GEOS_init_r returns a context handle';
    
    lives-ok { 
        GEOS_finish_r($context);
    }, 'GEOS_finish_r works without errors';
}

# Test error handling
{
    my $context = GEOS_init_r();
    my $handler = sub (Str $msg) { };
    
    lives-ok {
        GEOSContext_setErrorHandler_r($context, $handler);
    }, 'Can set error handler';
    
    lives-ok {
        GEOSContext_setNoticeHandler_r($context, $handler);
    }, 'Can set notice handler';
    
    GEOS_finish_r($context);
}

# Test WKT Reader/Writer functionality
{
    my $context = GEOS_init_r();
    
    my $reader = GEOSWKTReader_create_r($context);
    ok $reader ~~ GEOSWKTReader, 'Can create WKT reader';
    
    my $writer = GEOSWKTWriter_create_r($context);
    ok $writer ~~ GEOSWKTWriter, 'Can create WKT writer';
    
    my $point-wkt = 'POINT(0 0)';
    my $geom = GEOSWKTReader_read_r($context, $reader, $point-wkt);
    ok $geom ~~ GEOSGeometry, 'Can read WKT into geometry';
    
    lives-ok {
        GEOSWKTReader_destroy_r($context, $reader);
        GEOSWKTWriter_destroy_r($context, $writer);
        GEOSGeom_destroy_r($context, $geom);
    }, 'Can destroy readers, writers and geometries';
    
    GEOS_finish_r($context);
}

# Test basic geometry creation
{
    my $context = GEOS_init_r();
    
    my $empty-point = GEOSGeom_createEmptyPoint_r($context);
    ok $empty-point ~~ GEOSGeometry, 'Can create empty point';
    
    my $point = GEOSGeom_createPointFromXY_r($context, 1e0, 1e0);
    ok $point ~~ GEOSGeometry, 'Can create point from XY coordinates';
    
    my $empty-line = GEOSGeom_createEmptyLineString_r($context);
    ok $empty-line ~~ GEOSGeometry, 'Can create empty linestring';
    
    my $empty-polygon = GEOSGeom_createEmptyPolygon_r($context);
    ok $empty-polygon ~~ GEOSGeometry, 'Can create empty polygon';
    
    lives-ok {
        GEOSGeom_destroy_r($context, $_) for $empty-point, $point, $empty-line, $empty-polygon;
    }, 'Can destroy all created geometries';
    
    GEOS_finish_r($context);
}

# Test geometry operations
{
    my $context = GEOS_init_r();
    my $reader = GEOSWKTReader_create_r($context);
    
    my $geom1 = GEOSWKTReader_read_r($context, $reader, 'POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))');
    my $geom2 = GEOSWKTReader_read_r($context, $reader, 'POLYGON((0.5 0.5, 1.5 0.5, 1.5 1.5, 0.5 1.5, 0.5 0.5))');
    
    my $intersection = GEOSIntersection_r($context, $geom1, $geom2);
    ok $intersection ~~ GEOSGeometry, 'Can compute intersection';
    
    my $union = GEOSUnion_r($context, $geom1, $geom2);
    ok $union ~~ GEOSGeometry, 'Can compute union';
    
    my $difference = GEOSDifference_r($context, $geom1, $geom2);
    ok $difference ~~ GEOSGeometry, 'Can compute difference';
    
    my $sym_difference = GEOSSymDifference_r($context, $geom1, $geom2);
    ok $sym_difference ~~ GEOSGeometry, 'Can compute symmetric difference';
    
    lives-ok {
        GEOSGeom_destroy_r($context, $_) for $geom1, $geom2, $intersection, $union, $difference, $sym_difference;
        GEOSWKTReader_destroy_r($context, $reader);
    }, 'Can destroy all operation results';
    
    GEOS_finish_r($context);
}

# Exception class
{
    my $ex = X::GEOS::Error.new(message => 'Test error');
    ok $ex ~~ Exception, 'X::GEOS::Error is an Exception';
    is $ex.message, 'GEOS Error: Test error', 'Error message is formatted correctly';
}

done-testing;
