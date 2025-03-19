package OpenGL::GLU;

=head1 NAME

OpenGL::GLU - module encapsulating GLU functions

=cut

use strict;
use warnings;

use Exporter 'import';
require DynaLoader;

our $VERSION = '0.7003';
our @ISA = qw(DynaLoader);

our @const_common = qw(
   GLU_AUTO_LOAD_MATRIX
   GLU_BEGIN
   GLU_CCW
   GLU_CULLING
   GLU_CW
   GLU_DISPLAY_MODE
   GLU_DOMAIN_DISTANCE
   GLU_EDGE_FLAG
   GLU_END
   GLU_ERROR
   GLU_EXTENSIONS
   GLU_EXTERIOR
   GLU_FILL
   GLU_FLAT
   GLU_INCOMPATIBLE_GL_VERSION
   GLU_INSIDE
   GLU_INTERIOR
   GLU_INVALID_ENUM
   GLU_INVALID_VALUE
   GLU_LINE
   GLU_MAP1_TRIM_2
   GLU_MAP1_TRIM_3
   GLU_NONE
   GLU_NURBS_ERROR1
   GLU_NURBS_ERROR10
   GLU_NURBS_ERROR11
   GLU_NURBS_ERROR12
   GLU_NURBS_ERROR13
   GLU_NURBS_ERROR14
   GLU_NURBS_ERROR15
   GLU_NURBS_ERROR16
   GLU_NURBS_ERROR17
   GLU_NURBS_ERROR18
   GLU_NURBS_ERROR19
   GLU_NURBS_ERROR2
   GLU_NURBS_ERROR20
   GLU_NURBS_ERROR21
   GLU_NURBS_ERROR22
   GLU_NURBS_ERROR23
   GLU_NURBS_ERROR24
   GLU_NURBS_ERROR25
   GLU_NURBS_ERROR26
   GLU_NURBS_ERROR27
   GLU_NURBS_ERROR28
   GLU_NURBS_ERROR29
   GLU_NURBS_ERROR3
   GLU_NURBS_ERROR30
   GLU_NURBS_ERROR31
   GLU_NURBS_ERROR32
   GLU_NURBS_ERROR33
   GLU_NURBS_ERROR34
   GLU_NURBS_ERROR35
   GLU_NURBS_ERROR36
   GLU_NURBS_ERROR37
   GLU_NURBS_ERROR4
   GLU_NURBS_ERROR5
   GLU_NURBS_ERROR6
   GLU_NURBS_ERROR7
   GLU_NURBS_ERROR8
   GLU_NURBS_ERROR9
   GLU_OUTLINE_PATCH
   GLU_OUTLINE_POLYGON
   GLU_OUTSIDE
   GLU_OUT_OF_MEMORY
   GLU_PARAMETRIC_ERROR
   GLU_PARAMETRIC_TOLERANCE
   GLU_PATH_LENGTH
   GLU_POINT
   GLU_SAMPLING_METHOD
   GLU_SAMPLING_TOLERANCE
   GLU_SILHOUETTE
   GLU_SMOOTH
   GLU_TESS_ERROR1
   GLU_TESS_ERROR2
   GLU_TESS_ERROR3
   GLU_TESS_ERROR4
   GLU_TESS_ERROR5
   GLU_TESS_ERROR6
   GLU_TESS_ERROR7
   GLU_TESS_ERROR8
   GLU_UNKNOWN
   GLU_U_STEP
   GLU_VERSION
   GLU_VERTEX
   GLU_V_STEP
);
our @const = (@const_common, qw(
   GLU_OBJECT_PARAMETRIC_ERROR_EXT
   GLU_OBJECT_PATH_LENGTH_EXT
   GLU_TESS_BEGIN
   GLU_TESS_BEGIN_DATA
   GLU_TESS_COMBINE
   GLU_TESS_COMBINE_DATA
   GLU_TESS_EDGE_FLAG
   GLU_TESS_EDGE_FLAG_DATA
   GLU_TESS_END
   GLU_TESS_END_DATA
   GLU_TESS_ERROR
   GLU_TESS_ERROR_DATA
   GLU_TESS_VERTEX
   GLU_TESS_VERTEX_DATA
   GLU_TESS_WINDING_ABS_GEQ_TWO
   GLU_TESS_WINDING_NEGATIVE
   GLU_TESS_WINDING_NONZERO
   GLU_TESS_WINDING_ODD
   GLU_TESS_WINDING_POSITIVE
   GLU_TESS_WINDING_RULE
));

our @func = qw(
   gluBeginCurve
   gluBeginPolygon
   gluBeginSurface
   gluBeginTrim
   gluBuild1DMipmaps_c
   gluBuild1DMipmaps_s
   gluBuild2DMipmaps_c
   gluBuild2DMipmaps_s
   gluCylinder
   gluDeleteNurbsRenderer
   gluDeleteQuadric
   gluDeleteTess
   gluDisk
   gluEndCurve
   gluEndPolygon
   gluEndSurface
   gluEndTrim
   gluErrorString
   gluGetNurbsProperty_p
   gluGetString
   gluGetTessProperty_p
   gluLoadSamplingMatrices_p
   gluLookAt
   gluNewNurbsRenderer
   gluNewQuadric
   gluNewTess
   gluNextContour
   gluNurbsCurve_c
   gluNurbsSurface_c
   gluOrtho2D
   gluPartialDisk
   gluPerspective
   gluPickMatrix_p
   gluProject_p
   gluPwlCurve_c
   gluQuadricDrawStyle
   gluQuadricNormals
   gluQuadricOrientation
   gluQuadricTexture
   gluScaleImage_s
   gluSphere
   gluTessBeginContour
   gluTessBeginPolygon
   gluTessCallback
   gluTessEndContour
   gluTessEndPolygon
   gluTessNormal
   gluTessProperty
   gluTessVertex_p
   gluUnProject_p
);

our @EXPORT_OK = (@const, @func, '_have_glu');
our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
  constants => \@const,
  gluconstants => \@const,
  functions => \@func,
  glufunctions => \@func,
);

__PACKAGE__->bootstrap;

1;
