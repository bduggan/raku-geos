unit class GEOS::Native;

=begin pod

=head1 NAME

GEOS::Native - Native bindings to the GEOS library

=head1 SYNOPSIS

    use GEOS::Native;

    my $wkt = "POINT(1 1)";
    my $ctx = GEOS_init_r();
    my $reader = GEOSWKTReader_create_r($ctx) or die "Could not create reader";
    my $geom-a = GEOSWKTReader_read_r($ctx, $reader, $wkt) or die "Could not read geometry '$wkt'";
    my $geojson-writer = GEOSGeoJSONWriter_create_r($ctx) or die "Could not create GeoJSON writer";
    say GEOSGeoJSONWriter_writeGeometry_r($ctx, $geojson-writer, $geom-a, 1) or die "Could not write GeoJSON";
    # {
    #  "type": "Point",
    #  "coordinates": [
    #   1.0,
    #   1.0
    #  ]
    # }

=head1 DESCRIPTION

This module provides native bindings to libgeos: https://libgeos.oeg

The status of this module is EXPERIMENTAL.  Everything may change, and
some things might not work.  Consult the test suite to see what is
currently implemented.

Currently the thread safe bindings have been implemented, and there
are even a few tests that verify that they work.

=head1 AUTHOR

Brian Duggan

=end pod

use NativeCall;

constant GEOS = 'geos_c';

# Opaque types
class GEOSContextHandle is repr('CPointer') is export { }
class GEOSGeometry is repr('CPointer') is export { }
class GEOSPreparedGeometry is repr('CPointer') is export { }
class GEOSWKTReader is repr('CPointer') is export { }
class GEOSWKTWriter is repr('CPointer') is export { }
class GEOSCoordSequence is repr('CPointer') is export { }
class GEOSStrTree is repr('CPointer') is export { }
class GEOSQueryCallback is repr('CPointer') is export { }
class GEOSDistanceCallback is repr('CPointer') is export { }
class GEOSMakeValidParams is repr('CPointer') is export { }
class GEOSTransformXYCallback is repr('CPointer') is export { }
class GEOSTransformXYZCallback is repr('CPointer') is export { }

# Message handler callback type
sub dummy_handler(Str) returns Pointer is export { Pointer }

class X::GEOS::Error is Exception {
    has $.message;
    method message() { "GEOS Error: $!message" }
}

sub GEOSContext_setNoticeHandler_r( GEOSContextHandle, &handler (Str)) returns Pointer is native(GEOS) is export { * }
sub GEOSContext_setErrorHandler_r( GEOSContextHandle, &handler (Str)) returns Pointer is native(GEOS) is export { * }
sub GEOSWKTReader_create_r(GEOSContextHandle) returns GEOSWKTReader is native(GEOS) is export { * }
sub GEOSWKTReader_read_r( GEOSContextHandle, GEOSWKTReader, Str) returns GEOSGeometry is native(GEOS) is export { * }
sub GEOSWKTReader_destroy_r(GEOSContextHandle, GEOSWKTReader) is native(GEOS) is export { * }
sub GEOSWKTWriter_create_r(GEOSContextHandle) returns GEOSWKTWriter is native(GEOS) is export { * }
sub GEOSWKTWriter_write_r( GEOSContextHandle, GEOSWKTWriter, GEOSGeometry) returns Pointer is native(GEOS) is export { * }
sub GEOSWKTWriter_destroy_r(GEOSContextHandle, GEOSWKTWriter) is native(GEOS) is export { * }

sub GEOSGeom_destroy_r(GEOSContextHandle, GEOSGeometry) is native(GEOS) is export { * }
sub GEOSFree_r(GEOSContextHandle, Pointer) is native(GEOS) is export { * }

enum GEOSGeomTypes is export (
    GEOS_POINT => 0,
    GEOS_LINESTRING => 1,
    GEOS_LINEARRING => 2,
    GEOS_POLYGON => 3,
    GEOS_MULTIPOINT => 4,
    GEOS_MULTILINESTRING => 5,
    GEOS_MULTIPOLYGON => 6,
    GEOS_GEOMETRYCOLLECTION => 7,
    GEOS_CIRCULARSTRING => 8,
    GEOS_COMPOUNDCURVE => 9,
    GEOS_CURVEPOLYGON => 10,
    GEOS_MULTICURVE => 11,
    GEOS_MULTISURFACE => 12,
); 
# /**
# * Well-known binary byte orders used when
# * writing to WKB.
# *
# * \see GEOSWKBWriter_setByteOrder
# */
# enum GEOSWKBByteOrders {
#     /** Big Endian */
#     GEOS_WKB_XDR = 0,
#     /** Little Endian */
#     GEOS_WKB_NDR = 1
# };
enum GEOSWKBByteOrders is export (
    GEOS_WKB_XDR => 0,
    GEOS_WKB_NDR => 1,
); 
# /**
# * Well-known binary flavors to use
# * when writing to WKB. ISO flavour is
# * more standard. Extended flavour supports
# * 3D and SRID embedding. GEOS reads both
# * transparently.
# *
# * \see GEOSWKBWriter_setFlavor
# */
# enum GEOSWKBFlavors {
#     /** Extended */
#     GEOS_WKB_EXTENDED = 1,
#     /** ISO */
#     GEOS_WKB_ISO = 2
# };
enum GEOSWKBFlavors is export (
    GEOS_WKB_EXTENDED => 0,
    GEOS_WKB_ISO => 1,
);

# /**
# * Callback function for use in spatial index search calls. Pass into
# * the query function and handle query results as the index
# * returns them.
# *
# * \see GEOSSTRtree_query
# */
# typedef void (*GEOSQueryCallback)(void *item, void *userdata);
sub GEOSQueryCallback(Pointer, Pointer) is export { * }

# /**
# * Callback function for use in spatial index nearest neighbor calculations.
# * Allows custom distance to be calculated between items in the
# * index. Is passed two items, and sets the calculated distance
# * between the items into the distance pointer. Extra data for the
# * calculation can be passed via the userdata.
# *
# * \param item1 first of the pair of items to calculate distance between
# * \param item2 second of the pair of items to calculate distance between
# * \param distance the distance between the items here
# * \param userdata extra data for the calculation
# *
# * \return 1 if distance calculation succeeds, 0 otherwise
# *
# * \see GEOSSTRtree_nearest_generic
# * \see GEOSSTRtree_iterate
# */
# typedef int (*GEOSDistanceCallback)(
#     const void* item1,
#     const void* item2,
#     double* distance,
#     void* userdata);
sub GEOSDistanceCallback(Pointer, Pointer, num64, Pointer) is export { * }

# 
# /**
# * Callback function for use in GEOSGeom_transformXY.
# * Allows custom function to be applied to x and y values for each coordinate
# * in a geometry.  Z and M values are unchanged by this function.
# * Extra data for the calculation can be passed via the userdata.
# *
# * \param x coordinate value to be updated
# * \param y coordinate value to be updated
# * \param userdata extra data for the calculation
# *
# * \return 1 if calculation succeeded, 0 on failure
# */
# typedef int (*GEOSTransformXYCallback)(
#     double* x,
#     double* y,
#     void* userdata);
sub GEOSTransformXYCallback(Pointer, Pointer, Pointer) is export { * } 
 
# /**
# * Callback function for use in GEOSGeom_transformXYZ.
# * Allows custom function to be applied to x, y and z values for each coordinate
# * in a geometry.  M values are unchanged by this function.
# * Extra data for the calculation can be passed via the userdata.
# *
# * \param x coordinate value to be updated
# * \param y coordinate value to be updated
# * \param z coordinate value to be updated
# * \param userdata extra data for the calculation
# *
# * \return 1 if calculation succeeded, 0 on failure
# */
# typedef int (*GEOSTransformXYZCallback)(
#     double* x,
#     double* y,
#     double* z,
#     void* userdata);
sub GEOSTransformXYZCallback(Pointer, Pointer, Pointer, Pointer) is export { * } 
 
# /* ========== Interruption ========== */
# 
# /**
# * Callback function for use in interruption. The callback will be invoked _before_ checking for
# * interruption, so can be used to request it.
# *
# * \see GEOS_interruptRegisterCallback
# * \see GEOS_interruptRequest
# * \see GEOS_interruptCancel
# */
# typedef void (GEOSInterruptCallback)(void);
sub GEOSInterruptCallback() is export { * } 

# /**
# * Register a function to be called when processing is interrupted.
# * \param cb Callback function to invoke
# * \return the previously configured callback
# * \see GEOSInterruptCallback
# * \since 3.4
# */
# extern GEOSInterruptCallback GEOS_DLL *GEOS_interruptRegisterCallback(
#     GEOSInterruptCallback* cb);
sub GEOS_interruptRegisterCallback(&handler ()) returns Pointer is native(GEOS) is export { * } 

# /**
# * Request safe interruption of operations
# * \since 3.4
# */
# extern void GEOS_DLL GEOS_interruptRequest(void);
sub GEOS_interruptRequest() is native(GEOS) is export { * } 

# /**
# * Cancel a pending interruption request
# * \since 3.4
# */
# extern void GEOS_DLL GEOS_interruptCancel(void);
sub GEOS_interruptCancel() is native(GEOS) is export { * } 

# /* ========== Initialization and Cleanup ========== */
# 
# /**
# * Allocate and initialize a context. Pass this context as the first argument
# * when calling other `*_r` functions. Contexts must only be used from a single
# * thread at a time.
# * \return a new GEOS context.
# *
# * \since 3.5
# */
# extern GEOSContextHandle_t GEOS_DLL GEOS_init_r(void);
sub GEOS_init_r() returns GEOSContextHandle is native(GEOS) is export { * } 

# /**
# * Free the memory associated with a \ref GEOSContextHandle_t
# * when you are finished calling GEOS functions.
# * \param handle to be freed
# *
# * \since 3.5
# */
# extern void GEOS_DLL GEOS_finish_r(GEOSContextHandle_t handle);

sub GEOS_finish_r(GEOSContextHandle) is native(GEOS) is export { * }

# extern GEOSMessageHandler_r GEOS_DLL GEOSContext_setNoticeMessageHandler_r(
#     GEOSContextHandle_t extHandle,
#     GEOSMessageHandler_r nf,
#     void *userData);
sub GEOSContext_setNoticeMessageHandler_r(GEOSContextHandle, &handler (Str), Pointer) returns Pointer is native(GEOS) is export { * }

# extern GEOSMessageHandler_r GEOS_DLL GEOSContext_setErrorMessageHandler_r(
#     GEOSContextHandle_t extHandle,
#     GEOSMessageHandler_r ef,
#     void *userData);
sub GEOSContext_setErrorMessageHandler_r(GEOSContextHandle, &handler (Str), Pointer) returns Pointer is native(GEOS) is export { * } 

# /* ========== Coordinate Sequence functions ========== */
# 
# /** \see GEOSCoordSeq_create */
# extern GEOSCoordSequence GEOS_DLL *GEOSCoordSeq_create_r(
#     GEOSContextHandle_t handle,
#     unsigned int size,
#     unsigned int dims);
sub GEOSCoordSeq_create_r(GEOSContextHandle, uint32, uint32) returns Pointer is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_copyFromBuffer */
# extern GEOSCoordSequence GEOS_DLL *GEOSCoordSeq_copyFromBuffer_r(
#         GEOSContextHandle_t handle,
#         const double* buf,
#         unsigned int size,
#         int hasZ,
#         int hasM);
sub GEOSCoordSeq_copyFromBuffer_r(GEOSContextHandle, Pointer, uint32, int32, int32) returns Pointer is native(GEOS) is export { * }

# /** \see GEOSCoordSeq_copyFromArrays */
# extern GEOSCoordSequence GEOS_DLL *GEOSCoordSeq_copyFromArrays_r(
#         GEOSContextHandle_t handle,
#         const double* x,
#         const double* y,
#         const double* z,
#         const double* m,
#         unsigned int size);
sub GEOSCoordSeq_copyFromArrays_r(GEOSContextHandle, Pointer, Pointer, Pointer, Pointer, uint32) returns Pointer is native(GEOS) is export { * }

# /** \see GEOSCoordSeq_copyToBuffer */
# extern int GEOS_DLL GEOSCoordSeq_copyToBuffer_r(
#         GEOSContextHandle_t handle,
#         const GEOSCoordSequence* s,
#         double* buf,
#         int hasZ,
#         int hasM);
sub GEOSCoordSeq_copyToBuffer_r(GEOSContextHandle, Pointer, Pointer, int32, int32) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_copyToArrays */
# extern int GEOS_DLL GEOSCoordSeq_copyToArrays_r(
#         GEOSContextHandle_t handle,
#         const GEOSCoordSequence* s,
#         double* x,
#         double* y,
#         double* z,
#         double* m);
sub GEOSCoordSeq_copyToArrays_r(GEOSContextHandle, Pointer, Pointer, Pointer, Pointer, Pointer) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_clone */
# extern GEOSCoordSequence GEOS_DLL *GEOSCoordSeq_clone_r(
#     GEOSContextHandle_t handle,
#     const GEOSCoordSequence* s);
sub GEOSCoordSeq_clone_r(GEOSContextHandle, Pointer) returns Pointer is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_destroy */
# extern void GEOS_DLL GEOSCoordSeq_destroy_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s);
sub GEOSCoordSeq_destroy_r(GEOSContextHandle, Pointer) is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_setX */
# extern int GEOS_DLL GEOSCoordSeq_setX_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s, unsigned int idx,
#     double val);
sub GEOSCoordSeq_setX_r(GEOSContextHandle, Pointer, uint32, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_setY */
# extern int GEOS_DLL GEOSCoordSeq_setY_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s, unsigned int idx,
#     double val);
sub GEOSCoordSeq_setY_r(GEOSContextHandle, Pointer, uint32, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_setZ */
# extern int GEOS_DLL GEOSCoordSeq_setZ_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s, unsigned int idx,
#     double val);
sub GEOSCoordSeq_setZ_r(GEOSContextHandle, Pointer, uint32, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_setXY */
# extern int GEOS_DLL GEOSCoordSeq_setXY_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s, unsigned int idx,
#     double x, double y);
sub GEOSCoordSeq_setXY_r(GEOSContextHandle, Pointer, uint32, num64, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_setXYZ */
# extern int GEOS_DLL GEOSCoordSeq_setXYZ_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s, unsigned int idx,
#     double x, double y, double z);
sub GEOSCoordSeq_setXYZ_r(GEOSContextHandle, Pointer, uint32, num64, num64, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_setOrdinate */
# extern int GEOS_DLL GEOSCoordSeq_setOrdinate_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s,
#     unsigned int idx,
#     unsigned int dim, double val);
sub GEOSCoordSeq_setOrdinate_r(GEOSContextHandle, Pointer, uint32, uint32, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_getX */
# extern int GEOS_DLL GEOSCoordSeq_getX_r(
#     GEOSContextHandle_t handle,
#     const GEOSCoordSequence* s,
#     unsigned int idx, double *val);
sub GEOSCoordSeq_getX_r(GEOSContextHandle, Pointer, uint32, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_getY */
# extern int GEOS_DLL GEOSCoordSeq_getY_r(
#     GEOSContextHandle_t handle,
#     const GEOSCoordSequence* s,
#     unsigned int idx, double *val);
sub GEOSCoordSeq_getY_r(GEOSContextHandle, Pointer, uint32, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_getZ */
# extern int GEOS_DLL GEOSCoordSeq_getZ_r(
#     GEOSContextHandle_t handle,
#     const GEOSCoordSequence* s,
#     unsigned int idx, double *val);
sub GEOSCoordSeq_getZ_r(GEOSContextHandle, Pointer, uint32, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_getXY */
# extern int GEOS_DLL GEOSCoordSeq_getXY_r(
#     GEOSContextHandle_t handle,
#     const GEOSCoordSequence* s,
#     unsigned int idx,
#     double *x, double *y);
sub GEOSCoordSeq_getXY_r(GEOSContextHandle, Pointer, uint32, Pointer, Pointer) returns int32 is native(GEOS) is export { * }

# /** \see GEOSCoordSeq_getXYZ */
# extern int GEOS_DLL GEOSCoordSeq_getXYZ_r(
#     GEOSContextHandle_t handle,
#     const GEOSCoordSequence* s,
#     unsigned int idx,
#     double *x, double *y, double *z);
sub GEOSCoordSeq_getXYZ_r(GEOSContextHandle, Pointer, uint32, Pointer, Pointer, Pointer) returns int32 is native(GEOS) is export { * }

# /** \see GEOSCoordSeq_getOrdinate */
# extern int GEOS_DLL GEOSCoordSeq_getOrdinate_r(
#     GEOSContextHandle_t handle,
#     const GEOSCoordSequence* s,
#     unsigned int idx,
#     unsigned int dim, double *val);
sub GEOSCoordSeq_getOrdinate_r(GEOSContextHandle, Pointer, uint32, uint32, Pointer) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_getSize */
# extern int GEOS_DLL GEOSCoordSeq_getSize_r(
#     GEOSContextHandle_t handle,
#     const GEOSCoordSequence* s,
#     unsigned int *size);
sub GEOSCoordSeq_getSize_r(GEOSContextHandle, Pointer, Pointer) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_getDimensions */
# extern int GEOS_DLL GEOSCoordSeq_getDimensions_r(
#     GEOSContextHandle_t handle,
#     const GEOSCoordSequence* s,
#     unsigned int *dims);
sub GEOSCoordSeq_getDimensions_r(GEOSContextHandle, Pointer, Pointer) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoordSeq_isCCW */
# extern int GEOS_DLL GEOSCoordSeq_isCCW_r(
#     GEOSContextHandle_t handle,
#     const GEOSCoordSequence* s,
#     char* is_ccw);
sub GEOSCoordSeq_isCCW_r(GEOSContextHandle, Pointer, Str) returns int32 is native(GEOS) is export { * } 

# /* ========= Linear referencing functions ========= */
# 
# /** \see GEOSProject */
# extern double GEOS_DLL GEOSProject_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *line,
#     const GEOSGeometry *point);
sub GEOSProject_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns num64 is native(GEOS) is export { * } 

# /** \see GEOSInterpolate */
# extern GEOSGeometry GEOS_DLL *GEOSInterpolate_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *line,
#     double d);
sub GEOSInterpolate_r(GEOSContextHandle, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSProjectNormalized */
# extern double GEOS_DLL GEOSProjectNormalized_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g,
#     const GEOSGeometry *p);
sub GEOSProjectNormalized_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns num64 is native(GEOS) is export { * } 

# /** \see GEOSInterpolateNormalized */
# extern GEOSGeometry GEOS_DLL *GEOSInterpolateNormalized_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g,
#     double d);
sub GEOSInterpolateNormalized_r(GEOSContextHandle, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /* ========== Buffer related functions ========== */
# 
# /** \see GEOSBuffer */
# extern GEOSGeometry GEOS_DLL *GEOSBuffer_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double width, int quadsegs);
sub GEOSBuffer_r(GEOSContextHandle, GEOSGeometry, num64, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /**
# * Cap styles control the ends of buffered lines.
# * \see GEOSBuffer
# */
# enum GEOSBufCapStyles {
# 
#     /** End is rounded, with end point of original line in the centre of the round cap. */
# 	GEOSBUF_CAP_ROUND = 1,
# 
#     /** End is flat, with end point of original line at the end of the buffer */
# 	GEOSBUF_CAP_FLAT = 2,
# 
#     /** End is flat, with end point of original line in the middle of a square enclosing that point */
# 	GEOSBUF_CAP_SQUARE = 3
# };
enum GEOSBufCapStyles is export (
    GEOSBUF_CAP_ROUND => 1,
    GEOSBUF_CAP_FLAT => 2,
    GEOSBUF_CAP_SQUARE => 3,
); 

# /**
# * Join styles control the buffer shape at bends in a line.
# * \see GEOSBuffer
# */
# enum GEOSBufJoinStyles {
#     /**
#     * Join is rounded, essentially each line is terminated
#     * in a round cap. Form round corner.
#     */
# 	GEOSBUF_JOIN_ROUND = 1,
#     /**
#     * Join is flat, with line between buffer edges,
#     * through the join point. Forms flat corner.
#     */
# 	GEOSBUF_JOIN_MITRE = 2,
#     /**
#     * Join is the point at which the two buffer edges intersect.
#     * Forms sharp corner.
#     */
# 	GEOSBUF_JOIN_BEVEL = 3
# };
enum GEOSBufJoinStyles is export (
    GEOSBUF_JOIN_ROUND => 1,
    GEOSBUF_JOIN_MITRE => 2,
    GEOSBUF_JOIN_BEVEL => 3,
); 

# /** \see GEOSBufferParams_create */
# extern GEOSBufferParams GEOS_DLL *GEOSBufferParams_create_r(
#     GEOSContextHandle_t handle);
sub GEOSBufferParams_create_r(GEOSContextHandle) returns Pointer is native(GEOS) is export { * } 

# /** \see GEOSBufferParams_destroy */
# extern void GEOS_DLL GEOSBufferParams_destroy_r(
#     GEOSContextHandle_t handle,
#     GEOSBufferParams* parms);
sub GEOSBufferParams_destroy_r(GEOSContextHandle, Pointer) is native(GEOS) is export { * } 

# /** \see GEOSBufferParams_setEndCapStyle */
# extern int GEOS_DLL GEOSBufferParams_setEndCapStyle_r(
#     GEOSContextHandle_t handle,
#     GEOSBufferParams* p,
#     int style);
sub GEOSBufferParams_setEndCapStyle_r(GEOSContextHandle, Pointer, int32) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSBufferParams_setJoinStyle */
# extern int GEOS_DLL GEOSBufferParams_setJoinStyle_r(
#     GEOSContextHandle_t handle,
#     GEOSBufferParams* p,
#     int joinStyle);
sub GEOSBufferParams_setJoinStyle_r(GEOSContextHandle, Pointer, int32) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSBufferParams_setMitreLimit */
# extern int GEOS_DLL GEOSBufferParams_setMitreLimit_r(
#     GEOSContextHandle_t handle,
#     GEOSBufferParams* p,
#     double mitreLimit);
sub GEOSBufferParams_setMitreLimit_r(GEOSContextHandle, Pointer, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSBufferParams_setQuadrantSegments */
# extern int GEOS_DLL GEOSBufferParams_setQuadrantSegments_r(
#     GEOSContextHandle_t handle,
#     GEOSBufferParams* p,
#     int quadSegs);
sub GEOSBufferParams_setQuadrantSegments_r(GEOSContextHandle, Pointer, int32) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSBufferParams_setSingleSided */
# extern int GEOS_DLL GEOSBufferParams_setSingleSided_r(
#     GEOSContextHandle_t handle,
#     GEOSBufferParams* p,
#     int singleSided);
sub GEOSBufferParams_setSingleSided_r(GEOSContextHandle, Pointer, int32) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSBufferWithParams */
# extern GEOSGeometry GEOS_DLL *GEOSBufferWithParams_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     const GEOSBufferParams* p,
#     double width);
sub GEOSBufferWithParams_r(GEOSContextHandle, GEOSGeometry, Pointer, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSBufferWithStyle */
# extern GEOSGeometry GEOS_DLL *GEOSBufferWithStyle_r(
#     GEOSContextHandle_t handle,
# 	const GEOSGeometry* g,
#     double width, int quadsegs, int endCapStyle,
# 	int joinStyle, double mitreLimit);
sub GEOSBufferWithStyle_r(GEOSContextHandle, GEOSGeometry, num64, int32, int32, int32, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSDensify */
# extern GEOSGeometry GEOS_DLL *GEOSDensify_r(
#     GEOSContextHandle_t handle,
# 	const GEOSGeometry* g,
#     double tolerance);
sub GEOSDensify_r(GEOSContextHandle, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSOffsetCurve */
# extern GEOSGeometry GEOS_DLL *GEOSOffsetCurve_r(
#     GEOSContextHandle_t handle,
# 	const GEOSGeometry* g, double width, int quadsegs,
# 	int joinStyle, double mitreLimit);
sub GEOSOffsetCurve_r(GEOSContextHandle, GEOSGeometry, num64, int32, int32, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /* ========= Geometry Constructors ========= */
# 
# /** \see GEOSGeom_createPoint */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createPoint_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s);
sub GEOSGeom_createPoint_r(GEOSContextHandle, Pointer) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createPointFromXY */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createPointFromXY_r(
#     GEOSContextHandle_t handle,
#     double x, double y);
sub GEOSGeom_createPointFromXY_r(GEOSContextHandle, num64, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createEmptyPoint */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createEmptyPoint_r(
#     GEOSContextHandle_t handle);
sub GEOSGeom_createEmptyPoint_r(GEOSContextHandle) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createLinearRing */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createLinearRing_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s);
sub GEOSGeom_createLinearRing_r(GEOSContextHandle, Pointer) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createLineString */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createLineString_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s);
sub GEOSGeom_createLineString_r(GEOSContextHandle, Pointer) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createEmptyLineString */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createEmptyLineString_r(
#     GEOSContextHandle_t handle);
sub GEOSGeom_createEmptyLineString_r(GEOSContextHandle) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createEmptyPolygon */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createEmptyPolygon_r(
#     GEOSContextHandle_t handle);
sub GEOSGeom_createEmptyPolygon_r(GEOSContextHandle) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createPolygon */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createPolygon_r(
#     GEOSContextHandle_t handle,
#     GEOSGeometry* shell,
#     GEOSGeometry** holes,
#     unsigned int nholes);
sub GEOSGeom_createPolygon_r(GEOSContextHandle, GEOSGeometry, Pointer, uint32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createCollection */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createCollection_r(
#     GEOSContextHandle_t handle,
#     int type,
#     GEOSGeometry* *geoms,
#     unsigned int ngeoms);
sub GEOSGeom_createCollection_r(GEOSContextHandle, int32, Pointer, uint32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_releaseCollection */
# extern GEOSGeometry GEOS_DLL ** GEOSGeom_releaseCollection_r(
#     GEOSContextHandle_t handle,
#     GEOSGeometry * collection,
#     unsigned int * ngeoms);
sub GEOSGeom_releaseCollection_r(GEOSContextHandle, GEOSGeometry, Pointer) returns Pointer is native(GEOS) is export { * } 

# /** \see GEOSGeom_createEmptyCollection */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createEmptyCollection_r(
#     GEOSContextHandle_t handle, int type);
sub GEOSGeom_createEmptyCollection_r(GEOSContextHandle, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createRectangle */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createRectangle_r(
#     GEOSContextHandle_t handle,
#     double xmin, double ymin,
#     double xmax, double ymax);
sub GEOSGeom_createRectangle_r(GEOSContextHandle, num64, num64, num64, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_clone */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_clone_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGeom_clone_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createCircularString */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createCircularString_r(
#     GEOSContextHandle_t handle,
#     GEOSCoordSequence* s);
sub GEOSGeom_createCircularString_r(GEOSContextHandle, Pointer) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createEmptyCircularString */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createEmptyCircularString_r(
#     GEOSContextHandle_t handle);
sub GEOSGeom_createEmptyCircularString_r(GEOSContextHandle) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createCompoundCurve */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createCompoundCurve_r(
#     GEOSContextHandle_t handle,
#     GEOSGeometry** curves,
#     unsigned int ncurves);
sub GEOSGeom_createCompoundCurve_r(GEOSContextHandle, Pointer, uint32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createEmptyCompoundCurve */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createEmptyCompoundCurve_r(
#     GEOSContextHandle_t handle);
sub GEOSGeom_createEmptyCompoundCurve_r(GEOSContextHandle) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createCurvePolygon */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createCurvePolygon_r(
#     GEOSContextHandle_t handle,
#     GEOSGeometry* shell,
#     GEOSGeometry** holes,
#     unsigned int nholes);
sub GEOSGeom_createCurvePolygon_r(GEOSContextHandle, GEOSGeometry, Pointer, uint32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_createEmptyCurvePolygon */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_createEmptyCurvePolygon_r(
#     GEOSContextHandle_t handle);
sub GEOSGeom_createEmptyCurvePolygon_r(GEOSContextHandle) returns GEOSGeometry is native(GEOS) is export { * } 

# /* ========= Coverages ========= */
# 
# /** \see GEOSCoverageUnion */
# extern GEOSGeometry GEOS_DLL *
# GEOSCoverageUnion_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSCoverageUnion_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSCoverageIsValid */
# extern int GEOS_DLL
# GEOSCoverageIsValid_r(
#     GEOSContextHandle_t extHandle,
#     const GEOSGeometry* input,
#     double gapWidth,
#     GEOSGeometry** output);
sub GEOSCoverageIsValid_r(GEOSContextHandle, GEOSGeometry, num64, Pointer) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoverageSimplifyVW */
# extern GEOSGeometry GEOS_DLL *
# GEOSCoverageSimplifyVW_r(
#     GEOSContextHandle_t extHandle,
#     const GEOSGeometry* input,
#     double tolerance,
#     int preserveBoundary);
sub GEOSCoverageSimplifyVW_r(GEOSContextHandle, GEOSGeometry, num64, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /* ========= Topology Operations ========= */
# 
# /** \see GEOSEnvelope */
# extern GEOSGeometry GEOS_DLL *GEOSEnvelope_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSEnvelope_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSIntersection */
# extern GEOSGeometry GEOS_DLL *GEOSIntersection_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSIntersection_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSIntersectionPrec */
# extern GEOSGeometry GEOS_DLL *GEOSIntersectionPrec_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     double gridSize);
sub GEOSIntersectionPrec_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSConvexHull */
# extern GEOSGeometry GEOS_DLL *GEOSConvexHull_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSConvexHull_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSConcaveHull */
# extern GEOSGeometry GEOS_DLL *GEOSConcaveHull_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double ratio,
#     unsigned int allowHoles);
sub GEOSConcaveHull_r(GEOSContextHandle, GEOSGeometry, num64, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSConcaveHullByLength */
# extern GEOSGeometry GEOS_DLL *GEOSConcaveHullByLength_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double ratio,
#     unsigned int allowHoles);
sub GEOSConcaveHullByLength_r(GEOSContextHandle, GEOSGeometry, num64, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSPolygonHullSimplify */
# extern GEOSGeometry GEOS_DLL *GEOSPolygonHullSimplify_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     unsigned int isOuter,
#     double vertexNumFraction);
sub GEOSPolygonHullSimplify_r(GEOSContextHandle, GEOSGeometry, int32, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSPolygonHullSimplifyMode */
# extern GEOSGeometry GEOS_DLL *GEOSPolygonHullSimplifyMode_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     unsigned int isOuter,
#     unsigned int parameterMode,
#     double parameter);
sub GEOSPolygonHullSimplifyMode_r(GEOSContextHandle, GEOSGeometry, int32, int32, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSConcaveHullOfPolygons */
# extern GEOSGeometry GEOS_DLL *GEOSConcaveHullOfPolygons_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double lengthRatio,
#     unsigned int isTight,
#     unsigned int isHolesAllowed);
sub GEOSConcaveHullOfPolygons_r(GEOSContextHandle, GEOSGeometry, num64, int32, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSMinimumRotatedRectangle */
# extern GEOSGeometry GEOS_DLL *GEOSMinimumRotatedRectangle_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSMinimumRotatedRectangle_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSMaximumInscribedCircle */
# extern GEOSGeometry GEOS_DLL *GEOSMaximumInscribedCircle_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double tolerance);
sub GEOSMaximumInscribedCircle_r(GEOSContextHandle, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSLargestEmptyCircle */
# extern GEOSGeometry GEOS_DLL *GEOSLargestEmptyCircle_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     const GEOSGeometry* boundary,
#     double tolerance);
sub GEOSLargestEmptyCircle_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSMinimumWidth */
# extern GEOSGeometry GEOS_DLL *GEOSMinimumWidth_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSMinimumWidth_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSMinimumClearanceLine */
# extern GEOSGeometry GEOS_DLL *GEOSMinimumClearanceLine_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSMinimumClearanceLine_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSMinimumClearance */
# extern int GEOS_DLL GEOSMinimumClearance_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double* distance);
sub GEOSMinimumClearance_r(GEOSContextHandle, GEOSGeometry, num64) returns int32 is native(GEOS) is export { * }

# /** \see GEOSDifference */
# extern GEOSGeometry GEOS_DLL *GEOSDifference_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSDifference_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSDifferencePrec */
# extern GEOSGeometry GEOS_DLL *GEOSDifferencePrec_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     double gridSize);
sub GEOSDifferencePrec_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSSymDifference */
# extern GEOSGeometry GEOS_DLL *GEOSSymDifference_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSSymDifference_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSSymDifferencePrec */
# extern GEOSGeometry GEOS_DLL *GEOSSymDifferencePrec_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     double gridSize);
sub GEOSSymDifferencePrec_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSBoundary */
# extern GEOSGeometry GEOS_DLL *GEOSBoundary_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSBoundary_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSUnion */
# extern GEOSGeometry GEOS_DLL *GEOSUnion_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSUnion_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * }

# /** \see GEOSUnionPrec */
# extern GEOSGeometry GEOS_DLL *GEOSUnionPrec_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     double gridSize);
sub GEOSUnionPrec_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSUnaryUnion */
# extern GEOSGeometry GEOS_DLL *GEOSUnaryUnion_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSUnaryUnion_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSUnaryUnionPrec */
# extern GEOSGeometry GEOS_DLL *GEOSUnaryUnionPrec_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double gridSize);
sub GEOSUnaryUnionPrec_r(GEOSContextHandle, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSDisjointSubsetUnion */
# extern GEOSGeometry GEOS_DLL *GEOSDisjointSubsetUnion_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSDisjointSubsetUnion_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSPointOnSurface */
# extern GEOSGeometry GEOS_DLL *GEOSPointOnSurface_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSPointOnSurface_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGetCentroid */
# extern GEOSGeometry GEOS_DLL *GEOSGetCentroid_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGetCentroid_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSMinimumBoundingCircle */
# extern GEOSGeometry GEOS_DLL *GEOSMinimumBoundingCircle_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double* radius,
#     GEOSGeometry** center);
sub GEOSMinimumBoundingCircle_r(GEOSContextHandle, GEOSGeometry, num64, Pointer) returns GEOSGeometry is native(GEOS) is export { * }
 
# /** \see GEOSNode */
# extern GEOSGeometry GEOS_DLL *GEOSNode_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSNode_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSClipByRect */
# extern GEOSGeometry GEOS_DLL *GEOSClipByRect_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double xmin, double ymin,
#     double xmax, double ymax);
sub GEOSClipByRect_r(GEOSContextHandle, GEOSGeometry, num64, num64, num64, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSPolygonize */
# extern GEOSGeometry GEOS_DLL *GEOSPolygonize_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *const geoms[],
#     unsigned int ngeoms);
sub GEOSPolygonize_r(GEOSContextHandle, Pointer, uint32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSPolygonize_valid */
# extern GEOSGeometry GEOS_DLL *GEOSPolygonize_valid_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *const geoms[],
#     unsigned int ngems);
sub GEOSPolygonize_valid_r(GEOSContextHandle, Pointer, uint32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSPolygonizer_getCutEdges */
# extern GEOSGeometry GEOS_DLL *GEOSPolygonizer_getCutEdges_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry * const geoms[],
#     unsigned int ngeoms);
sub GEOSPolygonizer_getCutEdges_r(GEOSContextHandle, Pointer, uint32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSPolygonize_full */
# extern GEOSGeometry GEOS_DLL *GEOSPolygonize_full_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* input,
#     GEOSGeometry** cuts,
#     GEOSGeometry** dangles,
#     GEOSGeometry** invalidRings);
sub GEOSPolygonize_full_r(GEOSContextHandle, GEOSGeometry, Pointer, Pointer, Pointer) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSBuildArea */
# extern GEOSGeometry GEOS_DLL *GEOSBuildArea_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSBuildArea_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSLineMerge */
# extern GEOSGeometry GEOS_DLL *GEOSLineMerge_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSLineMerge_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSLineMergeDirected */
# extern GEOSGeometry GEOS_DLL *GEOSLineMergeDirected_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSLineMergeDirected_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSLineSubstring */
# extern GEOSGeometry GEOS_DLL *GEOSLineSubstring_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double start_fraction,
#     double end_fdraction);
sub GEOSLineSubstring_r(GEOSContextHandle, GEOSGeometry, num64, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSReverse */
# extern GEOSGeometry GEOS_DLL *GEOSReverse_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSReverse_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSSimplify */
# extern GEOSGeometry GEOS_DLL *GEOSSimplify_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double tolerance);
sub GEOSSimplify_r(GEOSContextHandle, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSTopologyPreserveSimplify */
# extern GEOSGeometry GEOS_DLL *GEOSTopologyPreserveSimplify_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g, double tolerance);
sub GEOSTopologyPreserveSimplify_r(GEOSContextHandle, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_extractUniquePoints */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_extractUniquePoints_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGeom_extractUniquePoints_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSSharedPaths */
# extern GEOSGeometry GEOS_DLL *GEOSSharedPaths_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSSharedPaths_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSSnap */
# extern GEOSGeometry GEOS_DLL *GEOSSnap_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     double tolerance);
sub GEOSSnap_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSDelaunayTriangulation */
# extern GEOSGeometry GEOS_DLL * GEOSDelaunayTriangulation_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g,
#     double tolerance,
#     int onlyEdges);
sub GEOSDelaunayTriangulation_r(GEOSContextHandle, GEOSGeometry, num64, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSConstrainedDelaunayTriangulation */
# extern GEOSGeometry GEOS_DLL * GEOSConstrainedDelaunayTriangulation_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g);
sub GEOSConstrainedDelaunayTriangulation_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * }

# /** \see GEOSVoronoiDiagram */
# extern GEOSGeometry GEOS_DLL * GEOSVoronoiDiagram_r(
#     GEOSContextHandle_t extHandle,
#     const GEOSGeometry *g,
#     const GEOSGeometry *env,
#     double tolerance,
#     int flags);
sub GEOSVoronoiDiagram_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSSegmentIntersection */
# extern int GEOS_DLL GEOSSegmentIntersection_r(
#        GEOSContextHandle_t extHandle,
#        double ax0, double ay0,
#        double ax1, double ay1,
#        double bx0, double by0,
#        double bx1, double by1,
#        double* cx, double* cy);
sub GEOSSegmentIntersection_r(GEOSContextHandle, num64, num64, num64, num64, num64, num64, num64, num64, num64, num64) returns int32 is native(GEOS) is export { * } 

# /* ========= Binary predicates ========= */
# 
# /** \see GEOSDisjoint */
# extern char GEOS_DLL GEOSDisjoint_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSDisjoint_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSTouches */
# extern char GEOS_DLL GEOSTouches_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSTouches_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSIntersects */
# extern char GEOS_DLL GEOSIntersects_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSIntersects_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCrosses */
# extern char GEOS_DLL GEOSCrosses_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSCrosses_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSWithin */
# extern char GEOS_DLL GEOSWithin_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSWithin_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSContains */
# extern char GEOS_DLL GEOSContains_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSContains_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * }
 
# /** \see GEOSOverlaps */
# extern char GEOS_DLL GEOSOverlaps_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSOverlaps_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSEquals */
# extern char GEOS_DLL GEOSEquals_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSEquals_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * }
 
# /** \see GEOSEqualsExact */
# extern char GEOS_DLL GEOSEqualsExact_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     double tolerance);
sub GEOSEqualsExact_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSEqualsIdentical */
# extern char GEOS_DLL GEOSEqualsIdentical_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSEqualsIdentical_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCovers */
# extern char GEOS_DLL GEOSCovers_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSCovers_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSCoveredBy */
# extern char GEOS_DLL GEOSCoveredBy_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSCoveredBy_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /* ========= Prepared Geometry Binary Predicates ========== */
# 
# /** \see GEOSPrepare */
# extern const GEOSPreparedGeometry GEOS_DLL *GEOSPrepare_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSPrepare_r(GEOSContextHandle, GEOSGeometry) returns GEOSPreparedGeometry is native(GEOS) is export { * } 

# /** \see GEOSPreparedGeom_destroy */
# extern void GEOS_DLL GEOSPreparedGeom_destroy_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* g);
sub GEOSPreparedGeom_destroy_r(GEOSContextHandle, GEOSPreparedGeometry) is native(GEOS) is export { * } 

# /** \see GEOSPreparedContains */
# extern char GEOS_DLL GEOSPreparedContains_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedContains_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedContainsXY */
# extern char GEOS_DLL GEOSPreparedContainsXY_r(
#         GEOSContextHandle_t handle,
#         const GEOSPreparedGeometry* pg1,
#         double x,
#         double y);
sub GEOSPreparedContainsXY_r(GEOSContextHandle, GEOSPreparedGeometry, num64, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedContainsProperly */
# extern char GEOS_DLL GEOSPreparedContainsProperly_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedContainsProperly_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedCoveredBy */
# extern char GEOS_DLL GEOSPreparedCoveredBy_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedCoveredBy_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedCovers */
# extern char GEOS_DLL GEOSPreparedCovers_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedCovers_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedCrosses */
# extern char GEOS_DLL GEOSPreparedCrosses_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedCrosses_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedDisjoint */
# extern char GEOS_DLL GEOSPreparedDisjoint_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedDisjoint_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedIntersects */
# extern char GEOS_DLL GEOSPreparedIntersects_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedIntersects_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedIntersectsXY */
# extern char GEOS_DLL GEOSPreparedIntersectsXY_r(
#         GEOSContextHandle_t handle,
#         const GEOSPreparedGeometry* pg1,
#         double x,
#         double y);
sub GEOSPreparedIntersectsXY_r(GEOSContextHandle, GEOSPreparedGeometry, num64, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedOverlaps */
# extern char GEOS_DLL GEOSPreparedOverlaps_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedOverlaps_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedTouches */
# extern char GEOS_DLL GEOSPreparedTouches_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedTouches_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedWithin */
# extern char GEOS_DLL GEOSPreparedWithin_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedWithin_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedRelate */
# extern char GEOS_DLL * GEOSPreparedRelate_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedRelate_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns Str is native(GEOS) is export { * } 

# /** \see GEOSPreparedRelatePattern */
# extern char GEOS_DLL GEOSPreparedRelatePattern_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2,
#     const char* im);
sub GEOSPreparedRelatePattern_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry, Str) returns int32 is native(GEOS) is export { * }
  
# /** \see GEOSPreparedNearestPoints */
# extern GEOSCoordSequence GEOS_DLL *GEOSPreparedNearestPoints_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2);
sub GEOSPreparedNearestPoints_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry) returns GEOSCoordSequence is native(GEOS) is export { * } 

# /** \see GEOSPreparedDistance */
# extern int GEOS_DLL GEOSPreparedDistance_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2, double *dist);
sub GEOSPreparedDistance_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSPreparedDistanceWithin */
# extern char GEOS_DLL GEOSPreparedDistanceWithin_r(
#     GEOSContextHandle_t handle,
#     const GEOSPreparedGeometry* pg1,
#     const GEOSGeometry* g2, double dist);
sub GEOSPreparedDistanceWithin_r(GEOSContextHandle, GEOSPreparedGeometry, GEOSGeometry, num64) returns int32 is native(GEOS) is export { * } 
# /* ========== STRtree ========== */
# 
# /** \see GEOSSTRtree_create */
# extern GEOSSTRtree GEOS_DLL *GEOSSTRtree_create_r(
#     GEOSContextHandle_t handle,
#     size_t nodeCapacity);
sub GEOSSTRtree_create_r(GEOSContextHandle, size_t) returns GEOSStrTree is native(GEOS) is export { * }
 
# /** \see GEOSSTRtree_build */
# extern int GEOS_DLL GEOSSTRtree_build_r(
#     GEOSContextHandle_t handle,
#     GEOSSTRtree *tree);
sub GEOSSTRtree_build_r(GEOSContextHandle, GEOSStrTree) returns int32 is native(GEOS) is export { * }

# /** \see GEOSSTRtree_insert */
# extern void GEOS_DLL GEOSSTRtree_insert_r(
#     GEOSContextHandle_t handle,
#     GEOSSTRtree *tree,
#     const GEOSGeometry *g,
#     void *item);
sub GEOSSTRtree_insert_r(GEOSContextHandle, GEOSStrTree, GEOSGeometry, Pointer) is native(GEOS) is export { * }

# /** \see GEOSSTRtree_query */
# extern void GEOS_DLL GEOSSTRtree_query_r(
#     GEOSContextHandle_t handle,
#     GEOSSTRtree *tree,
#     const GEOSGeometry *g,
#     GEOSQueryCallback callback,
#     void *userdata);
sub GEOSSTRtree_query_r(GEOSContextHandle, GEOSStrTree, GEOSGeometry, GEOSQueryCallback, Pointer) is native(GEOS) is export { * } 

# /** \see GEOSSTRtree_nearest */
# extern const GEOSGeometry GEOS_DLL *GEOSSTRtree_nearest_r(
#     GEOSContextHandle_t handle,
#     GEOSSTRtree *tree,
#     const GEOSGeometry* geom);
sub GEOSSTRtree_nearest_r(GEOSContextHandle, GEOSStrTree, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSSTRtree_nearest_generic */
# extern const void GEOS_DLL *GEOSSTRtree_nearest_generic_r(
#     GEOSContextHandle_t handle,
#     GEOSSTRtree *tree,
#     const void* item,
#     const GEOSGeometry* itemEnvelope,
#     GEOSDistanceCallback distancefn,
#     void* userdata);
sub GEOSSTRtree_nearest_generic_r(GEOSContextHandle, GEOSStrTree, Pointer, GEOSGeometry, GEOSDistanceCallback, Pointer) returns Pointer is native(GEOS) is export { * } 

# /** \see GEOSSTRtree_iterate */
# extern void GEOS_DLL GEOSSTRtree_iterate_r(
#     GEOSContextHandle_t handle,
#     GEOSSTRtree *tree,
#     GEOSQueryCallback callback,
#     void *userdata);
sub GEOSSTRtree_iterate_r(GEOSContextHandle, GEOSStrTree, GEOSQueryCallback, Pointer) is native(GEOS) is export { * }
 
# /** \see GEOSSTRtree_remove */
# extern char GEOS_DLL GEOSSTRtree_remove_r(
#     GEOSContextHandle_t handle,
#     GEOSSTRtree *tree,
#     const GEOSGeometry *g,
#     void *item);
sub GEOSSTRtree_remove_r(GEOSContextHandle, GEOSStrTree, GEOSGeometry, Pointer) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSSTRtree_destroy */
# extern void GEOS_DLL GEOSSTRtree_destroy_r(
#     GEOSContextHandle_t handle,
#     GEOSSTRtree *tree);
sub GEOSSTRtree_destroy_r(GEOSContextHandle, GEOSStrTree) is native(GEOS) is export { * } 
 
# /* ========= Unary predicate ========= */
# 
# /** \see GEOSisEmpty */
# extern char GEOS_DLL GEOSisEmpty_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSisEmpty_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSisSimple */
# extern char GEOS_DLL GEOSisSimple_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSisSimple_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSisRing */
# extern char GEOS_DLL GEOSisRing_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSisRing_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSHasZ */
# extern char GEOS_DLL GEOSHasZ_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSHasZ_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSHasM */
# extern char GEOS_DLL GEOSHasM_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSHasM_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSisClosed */
# extern char GEOS_DLL GEOSisClosed_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g);
sub GEOSisClosed_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /* ========== Dimensionally Extended 9 Intersection Model ========== */
# 
# /**
# * Controls the behavior of the result of GEOSRelate when returning
# * DE9IM results for two geometries.
# */
# enum GEOSRelateBoundaryNodeRules {
#     /** See geos::algorithm::BoundaryNodeRule::getBoundaryRuleMod2() */
#     GEOSRELATE_BNR_MOD2 = 1,
#     /** Same as \ref GEOSRELATE_BNR_MOD2 */
#     GEOSRELATE_BNR_OGC = 1,
#     /** See geos::algorithm::BoundaryNodeRule::getBoundaryEndPoint() */
# 	GEOSRELATE_BNR_ENDPOINT = 2,
#     /** See geos::algorithm::BoundaryNodeRule::getBoundaryMultivalentEndPoint() */
# 	GEOSRELATE_BNR_MULTIVALENT_ENDPOINT = 3,
#     /** See geos::algorithm::BoundaryNodeRule::getBoundaryMonovalentEndPoint() */
# 	GEOSRELATE_BNR_MONOVALENT_ENDPOINT = 4
# };
enum GEOSRelateBoundaryNodeRules is export (
    GEOSRELATE_BNR_MOD2 => 1,
    GEOSRELATE_BNR_OGC => 1,
    GEOSRELATE_BNR_ENDPOINT => 2,
    GEOSRELATE_BNR_MULTIVALENT_ENDPOINT => 3,
    GEOSRELATE_BNR_MONOVALENT_ENDPOINT => 4
);

# /** \see GEOSRelatePattern */
# extern char GEOS_DLL GEOSRelatePattern_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     const char *imPattern);
sub GEOSRelatePattern_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, Str) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSRelate */
# extern char GEOS_DLL *GEOSRelate_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSRelate_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns Str is native(GEOS) is export { * } 

# /** \see GEOSRelatePatternMatch */
# extern char GEOS_DLL GEOSRelatePatternMatch_r(
#     GEOSContextHandle_t handle,
#     const char *intMatrix,
#     const char *imPattern);
sub GEOSRelatePatternMatch_r(GEOSContextHandle, Str, Str) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSRelateBoundaryNodeRule */
# extern char GEOS_DLL *GEOSRelateBoundaryNodeRule_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     int bnr);
sub GEOSRelateBoundaryNodeRule_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, int32) returns Str is native(GEOS) is export { * } 

# /* ========= Validity checking ========= */
# 
# /** Change behaviour of validity testing in \ref GEOSisValidDetail */
# enum GEOSValidFlags
# {
#     /** Allow self-touching rings to form a hole in a polygon. */
# 	GEOSVALID_ALLOW_SELFTOUCHING_RING_FORMING_HOLE = 1
# };
enum GEOSValidFlags is export (
    GEOSVALID_ALLOW_SELFTOUCHING_RING_FORMING_HOLE => 1
); 

# /** \see GEOSisValid */
# extern char GEOS_DLL GEOSisValid_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSisValid_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSisValidReason */
# extern char GEOS_DLL *GEOSisValidReason_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSisValidReason_r(GEOSContextHandle, GEOSGeometry) returns Str is native(GEOS) is export { * } 

# /** \see GEOSisValidDetail */
# extern char GEOS_DLL GEOSisValidDetail_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     int flags,
#     char** reason,
#     GEOSGeometry** location);
sub GEOSisValidDetail_r(GEOSContextHandle, GEOSGeometry, int32, Str, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /* ========== Make Valid ========== */
# 
# /**
# * Algorithm to use when repairing invalid geometries.
# *
# * \see GEOSMakeValidWithParams
# */
# enum GEOSMakeValidMethods {
#     /** Original method, combines all rings into
#         a set of noded lines and then extracts valid
#         polygons from that linework. */
#     GEOS_MAKE_VALID_LINEWORK = 0,
#     /** Structured method, first makes all rings valid
#         then merges shells and subtracts holes from
#         shells to generate valid result. Assumes that
#         holes and shells are correctly categorized. */
#     GEOS_MAKE_VALID_STRUCTURE = 1
# };
enum GEOSMakeValidMethods is export (
    GEOS_MAKE_VALID_LINEWORK => 0,
    GEOS_MAKE_VALID_STRUCTURE => 1
);

# /** \see GEOSMakeValidParams_create */
# extern GEOSMakeValidParams GEOS_DLL *GEOSMakeValidParams_create_r(
#     GEOSContextHandle_t extHandle);
sub GEOSMakeValidParams_create_r(GEOSContextHandle) returns GEOSMakeValidParams is native(GEOS) is export { * }

# /** \see GEOSMakeValidParams_destroy */
# extern void GEOS_DLL GEOSMakeValidParams_destroy_r(
#     GEOSContextHandle_t handle,
#     GEOSMakeValidParams* parms);
sub GEOSMakeValidParams_destroy_r(GEOSContextHandle, GEOSMakeValidParams) is native(GEOS) is export { * } 

# /** \see GEOSMakeValidParams_setKeepCollapsed */
# extern int GEOS_DLL GEOSMakeValidParams_setKeepCollapsed_r(
#     GEOSContextHandle_t handle,
#     GEOSMakeValidParams* p,
#     int style);
sub GEOSMakeValidParams_setKeepCollapsed_r(GEOSContextHandle, GEOSMakeValidParams, int32) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSMakeValidParams_setMethod */
# extern int GEOS_DLL GEOSMakeValidParams_setMethod_r(
#     GEOSContextHandle_t handle,
#     GEOSMakeValidParams* p,
#     enum GEOSMakeValidMethods method);
sub GEOSMakeValidParams_setMethod_r(GEOSContextHandle, GEOSMakeValidParams, int32) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSMakeValid */
# extern GEOSGeometry GEOS_DLL *GEOSMakeValid_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSMakeValid_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSMakeValidWithParams */
# extern GEOSGeometry GEOS_DLL *GEOSMakeValidWithParams_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     const GEOSMakeValidParams* makeValidParams);
sub GEOSMakeValidWithParams_r(GEOSContextHandle, GEOSGeometry, GEOSMakeValidParams) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSRemoveRepeatedPoints */
# extern GEOSGeometry GEOS_DLL *GEOSRemoveRepeatedPoints_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double tolerance);
sub GEOSRemoveRepeatedPoints_r(GEOSContextHandle, GEOSGeometry, num64) returns GEOSGeometry is native(GEOS) is export { * } 

# /* ========== Geometry info ========== */
# 
# /** \see GEOSGeomType */
# /* Return NULL on exception, result must be freed by caller. */
# extern char GEOS_DLL *GEOSGeomType_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGeomType_r(GEOSContextHandle, GEOSGeometry) returns Str is native(GEOS) is export { * } 

# /** \see GEOSGeomTypeId */
# extern int GEOS_DLL GEOSGeomTypeId_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGeomTypeId_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGetSRID */
# extern int GEOS_DLL GEOSGetSRID_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGetSRID_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSSetSRID */
# extern void GEOS_DLL GEOSSetSRID_r(
#     GEOSContextHandle_t handle,
#     GEOSGeometry* g, int SRID);
sub GEOSSetSRID_r(GEOSContextHandle, GEOSGeometry, int32) is native(GEOS) is export { * } 

# /** \see GEOSGeom_getUserData */
# extern void GEOS_DLL *GEOSGeom_getUserData_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGeom_getUserData_r(GEOSContextHandle, GEOSGeometry) returns Pointer is native(GEOS) is export { * } 

# /** \see GEOSGeom_setUserData */
# extern void GEOS_DLL GEOSGeom_setUserData_r(
#     GEOSContextHandle_t handle,
#     GEOSGeometry* g,
#     void* userData);
sub   GEOSGeom_setUserData_r(GEOSContextHandle, GEOSGeometry, Pointer) is native(GEOS) is export { * }

# /** \see GEOSGetNumGeometries */
# extern int GEOS_DLL GEOSGetNumGeometries_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGetNumGeometries_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGetGeometryN */
# extern const GEOSGeometry GEOS_DLL *GEOSGetGeometryN_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g, int n);
sub GEOSGetGeometryN_r(GEOSContextHandle, GEOSGeometry, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSNormalize */
# extern int GEOS_DLL GEOSNormalize_r(
#     GEOSContextHandle_t handle,
#     GEOSGeometry* g);
sub GEOSNormalize_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSOrientPolygons */
# extern int GEOS_DLL GEOSOrientPolygons_r(
#     GEOSContextHandle_t handle,
#     GEOSGeometry* g,
#     int exteriorCW);
sub GEOSOrientPolygons_r(GEOSContextHandle, GEOSGeometry, int32) returns int32 is native(GEOS) is export { * } 

# /**
# * Controls the behavior of GEOSGeom_setPrecision()
# * when altering the precision of a geometry.
# */
# enum GEOSPrecisionRules {
#     /** The output is always valid. Collapsed geometry elements (including both polygons and lines) are removed. */
#     GEOS_PREC_VALID_OUTPUT = 0,
#     /** Precision reduction is performed pointwise. Output geometry may be invalid due to collapse or self-intersection. (This might be better called "GEOS_PREC_POINTWISE" - the current name is historical.) */
#     GEOS_PREC_NO_TOPO = 1,
#     /** Like the default mode, except that collapsed linear geometry elements are preserved. Collapsed polygonal input elements are removed. */
#     GEOS_PREC_KEEP_COLLAPSED = 2
# };
enum GEOSPrecisionRules is export (
    GEOS_PREC_VALID_OUTPUT => 0,
    GEOS_PREC_NO_TOPO => 1,
    GEOS_PREC_KEEP_COLLAPSED => 2
); 

# /** \see GEOSGeom_setPrecision */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_setPrecision_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g,
#     double gridSize,
#     int flags);
sub GEOSGeom_setPrecision_r(GEOSContextHandle, GEOSGeometry, num64, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_getPrecision */
# extern double GEOS_DLL GEOSGeom_getPrecision_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g);
sub GEOSGeom_getPrecision_r(GEOSContextHandle, GEOSGeometry) returns num64 is native(GEOS) is export { * } 

# /** \see GEOSGetNumInteriorRings */
# extern int GEOS_DLL GEOSGetNumInteriorRings_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGetNumInteriorRings_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeomGetNumPoints */
# extern int GEOS_DLL GEOSGeomGetNumPoints_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGeomGetNumPoints_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeomGetX */
# extern int GEOS_DLL GEOSGeomGetX_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g,
#     double *x);
sub GEOSGeomGetX_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeomGetY */
# extern int GEOS_DLL GEOSGeomGetY_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g,
#     double *y);
sub GEOSGeomGetY_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeomGetZ */
# extern int GEOS_DLL GEOSGeomGetZ_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g,
#     double *z);
sub GEOSGeomGetZ_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeomGetM */
# extern int GEOS_DLL GEOSGeomGetM_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g,
#     double *m);
sub GEOSGeomGetM_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGetInteriorRingN */
# extern const GEOSGeometry GEOS_DLL *GEOSGetInteriorRingN_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g, int n);
sub GEOSGetInteriorRingN_r(GEOSContextHandle, GEOSGeometry, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGetExteriorRing */
# extern const GEOSGeometry GEOS_DLL *GEOSGetExteriorRing_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGetExteriorRing_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGetNumCoordinates */
# extern int GEOS_DLL GEOSGetNumCoordinates_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGetNumCoordinates_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeom_getCoordSeq */
# extern const GEOSCoordSequence GEOS_DLL *GEOSGeom_getCoordSeq_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGeom_getCoordSeq_r(GEOSContextHandle, GEOSGeometry) returns GEOSCoordSequence is native(GEOS) is export { * }


# /** \see GEOSGeom_getDimensions */
# extern int GEOS_DLL GEOSGeom_getDimensions_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGeom_getDimensions_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeom_getCoordinateDimension */
# extern int GEOS_DLL GEOSGeom_getCoordinateDimension_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g);
sub GEOSGeom_getCoordinateDimension_r(GEOSContextHandle, GEOSGeometry) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeom_getXMin */
# extern int GEOS_DLL GEOSGeom_getXMin_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double* value);
sub GEOSGeom_getXMin_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeom_getYMin */
# extern int GEOS_DLL GEOSGeom_getYMin_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double* value);
sub GEOSGeom_getYMin_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeom_getXMax */
# extern int GEOS_DLL GEOSGeom_getXMax_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double* value);
sub GEOSGeom_getXMax_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * }

# /** \see GEOSGeom_getYMax */
# extern int GEOS_DLL GEOSGeom_getYMax_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double* value);
sub GEOSGeom_getYMax_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * }

# /** \see GEOSGeom_getExtent */
# extern int GEOS_DLL GEOSGeom_getExtent_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double* xmin,
#     double* ymin,
#     double* xmax,
#     double* ymax);
sub GEOSGeom_getExtent_r(GEOSContextHandle, GEOSGeometry, num64 is rw, num64 is rw, num64 is rw, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeomGetPointN */
# extern GEOSGeometry GEOS_DLL *GEOSGeomGetPointN_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g,
#     int n);
sub GEOSGeomGetPointN_r(GEOSContextHandle, GEOSGeometry, int32) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeomGetStartPoint */
# extern GEOSGeometry GEOS_DLL *GEOSGeomGetStartPoint_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g);
sub GEOSGeomGetStartPoint_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeomGetEndPoint */
# extern GEOSGeometry GEOS_DLL *GEOSGeomGetEndPoint_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g);
sub GEOSGeomGetEndPoint_r(GEOSContextHandle, GEOSGeometry) returns GEOSGeometry is native(GEOS) is export { * } 

# /* ========= Misc functions ========= */
# 
# /** \see GEOSArea */
# extern int GEOS_DLL GEOSArea_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double *area);
sub GEOSArea_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * }

# /** \see GEOSLength */
# extern int GEOS_DLL GEOSLength_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     double *length);
sub GEOSLength_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSDistance */
# extern int GEOS_DLL GEOSDistance_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     double *dist);
sub GEOSDistance_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * }

# /** \see GEOSDistanceWithin */
# extern char GEOS_DLL GEOSDistanceWithin_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     double dist);
sub GEOSDistanceWithin_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSDistanceIndexed */
# extern int GEOS_DLL GEOSDistanceIndexed_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2,
#     double *dist);
sub GEOSDistanceIndexed_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * }

# /** \see GEOSHausdorffDistance */
# extern int GEOS_DLL GEOSHausdorffDistance_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g1,
#     const GEOSGeometry *g2,
#     double *dist);
sub GEOSHausdorffDistance_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSHausdorffDistanceDensify */
# extern int GEOS_DLL GEOSHausdorffDistanceDensify_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g1,
#     const GEOSGeometry *g2,
#     double densifyFrac, double *dist);
sub GEOSHausdorffDistanceDensify_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSFrechetDistance */
# extern int GEOS_DLL GEOSFrechetDistance_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g1,
#     const GEOSGeometry *g2,
#     double *dist);
sub GEOSFrechetDistance_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSFrechetDistanceDensify */
# extern int GEOS_DLL GEOSFrechetDistanceDensify_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g1,
#     const GEOSGeometry *g2,
#     double densifyFrac,
#     double *dist);
sub GEOSFrechetDistanceDensify_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, num64, num64 is rw) returns int32 is native(GEOS) is export { * } 
 
# /** \see GEOSHilbertCode */
# extern int GEOS_DLL GEOSHilbertCode_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *geom,
#     const GEOSGeometry* extent,
#     unsigned int level,
#     unsigned int *code
# );
sub GEOSHilbertCode_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry, uint32, uint32 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSGeomGetLength */
# extern int GEOS_DLL GEOSGeomGetLength_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry *g,
#     double *length);
sub GEOSGeomGetLength_r(GEOSContextHandle, GEOSGeometry, num64 is rw) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSNearestPoints */
# extern GEOSCoordSequence GEOS_DLL *GEOSNearestPoints_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g1,
#     const GEOSGeometry* g2);
sub GEOSNearestPoints_r(GEOSContextHandle, GEOSGeometry, GEOSGeometry) returns GEOSCoordSequence is native(GEOS) is export { * } 

# /** \see GEOSGeom_transformXY */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_transformXY_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     GEOSTransformXYCallback callback,
#     void* userdata);
sub GEOSGeom_transformXY_r(GEOSContextHandle, GEOSGeometry, GEOSTransformXYCallback, Pointer) returns GEOSGeometry is native(GEOS) is export { * } 

# /** \see GEOSGeom_transformXYZ */
# extern GEOSGeometry GEOS_DLL *GEOSGeom_transformXYZ_r(
#     GEOSContextHandle_t handle,
#     const GEOSGeometry* g,
#     GEOSTransformXYZCallback callback,
#     void* userdata);
sub GEOSGeom_transformXYZ_r(GEOSContextHandle, GEOSGeometry, GEOSTransformXYZCallback, Pointer) returns GEOSGeometry is native(GEOS) is export { * } 

# /* ========= Algorithms ========= */
# 
# /** \see GEOSOrientationIndex */
# extern int GEOS_DLL GEOSOrientationIndex_r(
#     GEOSContextHandle_t handle,
# 	double Ax, double Ay,
#     double Bx, double By,
#     double Px, double Py);
sub GEOSOrientationIndex_r(GEOSContextHandle, num64, num64, num64, num64, num64, num64) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSWKTWriter_setTrim */
# extern void GEOS_DLL GEOSWKTWriter_setTrim_r(
#     GEOSContextHandle_t handle,
#     GEOSWKTWriter *writer,
#     char trim);
sub GEOSWKTWriter_setTrim_r  is native('geos') { * }

# /** \see GEOSWKTWriter_setRoundingPrecision */
# extern void GEOS_DLL GEOSWKTWriter_setRoundingPrecision_r(
#     GEOSContextHandle_t handle,
#     GEOSWKTWriter *writer,
#     int precision);
sub GEOSWKTWriter_setRoundingPrecision_r  is native('geos') { * } 

# /** \see GEOSWKTWriter_setOutputDimension */
# extern void GEOS_DLL GEOSWKTWriter_setOutputDimension_r(
#     GEOSContextHandle_t handle,
#     GEOSWKTWriter *writer,
#     int dim);
sub GEOSWKTWriter_setOutputDimension_r  is native('geos') { * } 

# /** \see GEOSWKTWriter_getOutputDimension */
# extern int  GEOS_DLL GEOSWKTWriter_getOutputDimension_r(
#     GEOSContextHandle_t handle,
#     GEOSWKTWriter *writer);
sub GEOSWKTWriter_getOutputDimension_r  is native('geos') { * } 

# /** \see GEOSWKTWriter_setOld3D */
# extern void GEOS_DLL GEOSWKTWriter_setOld3D_r(
#     GEOSContextHandle_t handle,
#     GEOSWKTWriter *writer,
#     int useOld3D);
sub GEOSWKTWriter_setOld3D_r  is native('geos') { * } 

# /** Print the shortest representation of a double. Non-zero absolute values
#  * that are <1e-4 and >=1e+17 are formatted using scientific notation, and
#  * other values are formatted with positional notation with precision used for
#  * the max digits after decimal point.
#  * \param d The number to format.
#  * \param precision The desired precision.
#  * \param result The buffer to write the result to, with a suggested size 28.
#  * \return the length of the written string.
#  */
# extern int GEOS_DLL GEOS_printDouble(
#     double d,
#     unsigned int precision,
#     char *result
# );
sub GEOS_printDouble(num64, uint32, Str) returns int32 is native('geos') { * } 

# /* ========== WKB Reader ========== */
# 
# /** \see GEOSWKBReader_create */
# extern GEOSWKBReader GEOS_DLL *GEOSWKBReader_create_r(
#     GEOSContextHandle_t handle);
sub GEOSWKBReader_create_r(GEOSContextHandle) returns Pointer is native(GEOS) is export { * } 

# /** \see GEOSWKBReader_destroy */
# extern void GEOS_DLL GEOSWKBReader_destroy_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBReader* reader);
sub GEOSWKBReader_destroy_r(GEOSContextHandle, Pointer) is native(GEOS) is export { * } 

# /** \see GEOSWKBReader_setFixStructure */
# extern void GEOS_DLL GEOSWKBReader_setFixStructure_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBReader *reader,
#     char doFix);
sub GEOSWKBReader_setFixStructure_r(GEOSContextHandle, Pointer, int32) is native(GEOS) is export { * } 

# /** \see GEOSWKBReader_read */
# extern GEOSGeometry GEOS_DLL *GEOSWKBReader_read_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBReader* reader,
#     const unsigned char *wkb,
#     size_t size);
sub GEOSWKBReader_read_r(GEOSContextHandle, Pointer, Str, size_t) returns Pointer is native(GEOS) is export { * } 

# /** \see GEOSWKBReader_readHEX */
# extern GEOSGeometry GEOS_DLL *GEOSWKBReader_readHEX_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBReader* reader,
#     const unsigned char *hex,
#     size_t size);
sub GEOSWKBReader_readHEX_r(GEOSContextHandle, Pointer, Str, size_t) returns Pointer is native(GEOS) is export { * } 

# /* ========== WKB Writer ========== */
# 
# /** \see GEOSWKBWriter_create */
# extern GEOSWKBWriter GEOS_DLL *GEOSWKBWriter_create_r(
#     GEOSContextHandle_t handle);
sub GEOSWKBWriter_create_r(GEOSContextHandle) returns Pointer is native(GEOS) is export { * } 

# /** \see GEOSWKBWriter_destroy */
# extern void GEOS_DLL GEOSWKBWriter_destroy_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBWriter* writer);
sub GEOSWKBWriter_destroy_r(GEOSContextHandle, Pointer) is native(GEOS) is export { * } 

# /** \see GEOSWKBWriter_write */
# extern unsigned char GEOS_DLL *GEOSWKBWriter_write_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBWriter* writer,
#     const GEOSGeometry* g,
#     size_t *size);
sub GEOSWKBWriter_write_r(GEOSContextHandle, Pointer, GEOSGeometry, size_t is rw) returns Str is native(GEOS) is export { * }

# /** \see GEOSWKBWriter_writeHEX */
# extern unsigned char GEOS_DLL *GEOSWKBWriter_writeHEX_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBWriter* writer,
#     const GEOSGeometry* g,
#     size_t *size);
sub GEOSWKBWriter_writeHEX_r(GEOSContextHandle, Pointer, GEOSGeometry, size_t is rw) returns Str is native(GEOS) is export { * } 

# /** \see GEOSWKBWriter_getOutputDimension */
# extern int GEOS_DLL GEOSWKBWriter_getOutputDimension_r(
#     GEOSContextHandle_t handle,
#     const GEOSWKBWriter* writer);
sub GEOSWKBWriter_getOutputDimension_r(GEOSContextHandle, Pointer) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSWKBWriter_setOutputDimension */
# extern void GEOS_DLL GEOSWKBWriter_setOutputDimension_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBWriter* writer, int newDimension);
sub GEOSWKBWriter_setOutputDimension_r(GEOSContextHandle, Pointer, int32) is native(GEOS) is export { * } 

# /** \see GEOSWKBWriter_getByteOrder */
# extern int GEOS_DLL GEOSWKBWriter_getByteOrder_r(
#     GEOSContextHandle_t handle,
#     const GEOSWKBWriter* writer);
sub GEOSWKBWriter_getByteOrder_r(GEOSContextHandle, Pointer) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSWKBWriter_setByteOrder */
# extern void GEOS_DLL GEOSWKBWriter_setByteOrder_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBWriter* writer,
#     int byteOrder);
sub GEOSWKBWriter_setByteOrder_r(GEOSContextHandle, Pointer, int32) is native(GEOS) is export { * } 

# /** \see GEOSWKBWriter_getFlavor */
# extern int GEOS_DLL GEOSWKBWriter_getFlavor_r(
#     GEOSContextHandle_t handle,
#     const GEOSWKBWriter* writer);
sub GEOSWKBWriter_getFlavor_r(GEOSContextHandle, Pointer) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSWKBWriter_setFlavor */
# extern void GEOS_DLL GEOSWKBWriter_setFlavor_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBWriter* writer,
#     int flavor);
sub GEOSWKBWriter_setFlavor_r(GEOSContextHandle, Pointer, int32) is native(GEOS) is export { * } 

# /** \see GEOSWKBWriter_getIncludeSRID */
# extern char GEOS_DLL GEOSWKBWriter_getIncludeSRID_r(
#     GEOSContextHandle_t handle,
#     const GEOSWKBWriter* writer);
sub GEOSWKBWriter_getIncludeSRID_r(GEOSContextHandle, Pointer) returns int32 is native(GEOS) is export { * } 

# /** \see GEOSWKBWriter_setIncludeSRID */
# extern void GEOS_DLL GEOSWKBWriter_setIncludeSRID_r(
#     GEOSContextHandle_t handle,
#     GEOSWKBWriter* writer, const char writeSRID);
sub GEOSWKBWriter_setIncludeSRID_r(GEOSContextHandle, Pointer, int32) is native(GEOS) is export { * } 

# /* ========== GeoJSON Reader ========== */
# 
# /** \see GEOSGeoJSONReader_create */
# extern GEOSGeoJSONReader GEOS_DLL *GEOSGeoJSONReader_create_r(
#     GEOSContextHandle_t handle);
sub GEOSGeoJSONReader_create_r(GEOSContextHandle) returns Pointer is native(GEOS) is export { * }

# /** \see GEOSGeoJSONReader_destroy */
# extern void GEOS_DLL GEOSGeoJSONReader_destroy_r(GEOSContextHandle_t handle,
#     GEOSGeoJSONReader* reader);
sub GEOSGeoJSONReader_destroy_r(GEOSContextHandle, Pointer) is native(GEOS) is export { * } 

# /** \see GEOSGeoJSONReader_read */
# extern GEOSGeometry GEOS_DLL *GEOSGeoJSONReader_readGeometry_r(
#     GEOSContextHandle_t handle,
#     GEOSGeoJSONReader* reader,
#     const char *geojson);
sub GEOSGeoJSONReader_readGeometry_r(GEOSContextHandle, Pointer, Str) returns Pointer is native(GEOS) is export { * } 

# /* ========== GeoJSON Writer ========== */
# 
# /** \see GEOSGeoJSONWriter_create */
# extern GEOSGeoJSONWriter GEOS_DLL *GEOSGeoJSONWriter_create_r(
#     GEOSContextHandle_t handle);
sub GEOSGeoJSONWriter_create_r(GEOSContextHandle) returns Pointer is native(GEOS) is export { * } 
 
# /** \see GEOSGeoJSONWriter_destroy */
# extern void GEOS_DLL GEOSGeoJSONWriter_destroy_r(GEOSContextHandle_t handle,
#     GEOSGeoJSONWriter* writer);
sub GEOSGeoJSONWriter_destroy_r(GEOSContextHandle, Pointer) is native(GEOS) is export { * }
 
# /** \see GEOSGeoJSONWriter_writeGeometry */
# extern char GEOS_DLL *GEOSGeoJSONWriter_writeGeometry_r(
#     GEOSContextHandle_t handle,
#     GEOSGeoJSONWriter* writer,
#     const GEOSGeometry* g,
#     int indent);
sub GEOSGeoJSONWriter_writeGeometry_r(GEOSContextHandle, Pointer, GEOSGeometry, int32) returns Str is native(GEOS) is export { * }

