/*  Last saved: Sun 06 Sep 2009 02:10:22 PM */

/*  Copyright (c) 1998 Kenneth Albanowski. All rights reserved.
 *  Copyright (c) 2007 Bob Free. All rights reserved.
 *  Copyright (c) 2009 Chris Marshall. All rights reserved.
 *  This program is free software; you can redistribute it and/or
 *  modify it under the same terms as Perl itself.
 */

/* OpenGL GLU bindings */
#define IN_POGL_GLU_XS

#include <stdio.h>

#include "pgopogl.h"

#ifdef HAVE_GL
#include "gl_util.h"
#endif

#ifdef HAVE_GLX
#include "glx_util.h"
#endif

#ifdef HAVE_GLU
#include "glu_util.h"
#endif


#ifdef IN_POGL_GLU_XS

#ifndef CALLBACK
#define CALLBACK
#endif

/* Begin a named callback handler */
#define begin_void_specific_marshaller(name, assign_handler_av, params, default_handler) \
void CALLBACK _s_marshal_ ## name params				\
{                                                                       \
    SV * handler;                                                       \
	AV * handler_av;                                                \
	dSP;                                                            \
	int i;                                                          \
	assign_handler_av;                                              \
	if (!handler_av) croak("Failure of callback handler");          \
	handler = *av_fetch(handler_av, 0, 0);                          \
        if (! SvROK(handler)) { /* DEFAULT */                           \
          default_handler;                                              \
          return;                                                       \
        }                                                               \
    PUSHMARK(sp);                                                       \
    for (i=1; i<=av_len(handler_av); i++)                               \
        XPUSHs(sv_2mortal(newSVsv(*av_fetch(handler_av, i, 0))));

/* End a named callback handler */
#define end_void_specific_marshaller()                                  \
	PUTBACK;                                                        \
	perl_call_sv(handler, G_DISCARD);                               \
}


struct PGLUtess {
	GLUtesselator * triangulator;

#ifdef GLU_VERSION_1_2
	AV * polygon_data_av;
	AV * begin_callback;
	AV * edgeFlag_callback;
	AV * vertex_callback;
	AV * end_callback;
	AV * error_callback;
	AV * combine_callback;
#endif
	
	AV * vertex_datas;
};

typedef struct PGLUtess PGLUtess;

#ifdef GLU_VERSION_1_2


/* Begin a gluTess callback handler */
#define begin_tess_marshaller(type, params, default_handler)		\
begin_void_specific_marshaller(glu_t_callback_ ## type,                 \
	PGLUtess * t = (PGLUtess*)polygon_data;                         \
	handler_av = t-> type ## _callback                              \
	, params, default_handler)

/* End a gluTess callback handler */
#define end_tess_marshaller()                                           \
    if (t->polygon_data_av)                                             \
      for (i=0; i<=av_len(t->polygon_data_av); i++)                     \
        XPUSHs(sv_2mortal(newSVsv(*av_fetch(t->polygon_data_av, i, 0)))); \
end_void_specific_marshaller()

/* Declare gluTess BEGIN */
begin_tess_marshaller(begin, (GLenum type, void * polygon_data), glBegin(type))
	XPUSHs(sv_2mortal(newSViv(type)));
end_tess_marshaller()

/* Declare gluTess END */
begin_tess_marshaller(end, (void * polygon_data), glEnd())
end_tess_marshaller()

/* Declare gluTess EDGEFLAG */
begin_tess_marshaller(edgeFlag, (GLboolean flag, void * polygon_data), glEdgeFlag(flag))
	XPUSHs(sv_2mortal(newSViv(flag)));
end_tess_marshaller()

/* Declare gluTess VERTEX */
begin_tess_marshaller(vertex,                                    \
                      (void * vertex_data, void * polygon_data), \
                      GLdouble * vd = (GLdouble*) vertex_data;   \
                      glColor3f(vd[3], vd[4], vd[5]);            \
                      glVertex3f(vd[0], vd[1], vd[2]);           \
                     )
    if (! vertex_data) croak("Missing vertex data in tess vertex callback");
    GLdouble * vd = (GLdouble*) vertex_data;
    for (i=0; i<7; i++)
      XPUSHs(sv_2mortal(newSVnv(vd[i])));
end_tess_marshaller()

/* Declare gluTess ERROR */
begin_tess_marshaller(error,                                                \
                      (GLenum errno_, void * polygon_data),                 \
                      warn("Tesselation error: %s", gluErrorString(errno_)) \
                     )
	XPUSHs(sv_2mortal(newSViv(errno_)));
end_tess_marshaller()

/* Declare gluTess COMBINE */
void CALLBACK _s_marshal_glu_t_callback_combine (GLdouble coords[3], GLdouble * vertex_data[4],
                                                 GLfloat weight[4], GLdouble ** out_data,
                                                 void * polygon_data)
{
        SV * handler;
	AV * handler_av;
	AV * vds;
        I32 n;
	int i, j;
	dSP;
	PGLUtess * t = (PGLUtess*)polygon_data;

        GLdouble *vertex = malloc(sizeof(GLdouble) * 7);
        if (vertex == NULL) croak("Couldn't allocate combination vertex during tesselation");
        vds = t->vertex_datas;
        if (!vds) croak("Missing vertex data storage");
	av_push(vds, newSViv((int)vertex));
        *out_data = vertex;

	handler_av = t->combine_callback;
	if (!handler_av) croak("Failure of callback handler");
	handler = *av_fetch(handler_av, 0, 0);

        if (! SvROK(handler)) { /* DEFAULT */
          vertex[0] = coords[0];
          vertex[1] = coords[1];
          vertex[2] = coords[2];
          for (i=3; i<7; i++) {
            vertex[i] = 0;
            for (j=0; j<4; j++)
              if (weight[j]) vertex[i] += weight[j]*vertex_data[j][i];
          }
        } else {
          for (i=1; i<=av_len(handler_av); i++)
            XPUSHs(sv_2mortal(newSVsv(*av_fetch(handler_av, i, 0))));

          PUSHMARK(sp);
          for (i = 0; i < 3; i++)
            XPUSHs(sv_2mortal(newSVnv(coords[i])));
          for (i = 0; i < 4; i++)
            for (j = 0; j < 7; j++)
              XPUSHs(sv_2mortal(newSVnv(weight[i] ? vertex_data[i][j] : 0.0)));
          for (i = 0; i < 4; i++)
            XPUSHs(sv_2mortal(newSVnv(weight[i])));
          if (t->polygon_data_av)
            for (i=0; i<=av_len(t->polygon_data_av); i++)
              XPUSHs(sv_2mortal(newSVsv(*av_fetch(t->polygon_data_av, i, 0))));
	  PUTBACK;
          n = perl_call_sv(handler, G_ARRAY);
          SPAGAIN;
          if (n != 7) croak("Need 7 values returned from callback - x,y,z,r,g,b,a");
          SV * item;
          GLdouble val;
          for (i = 6; i >= 0; i--) {
              item = POPs;
              if (! item || (! SvIOK(item) && ! SvNOK(item)))
                croak("Value returned in index %d was not a valid number", i);
              val = (GLdouble)SvNV(item);
              vertex[i] = val;
          }
	  PUTBACK;
        }
}

#endif

#endif /* End IN_POGL_GLU_XS */


MODULE = OpenGL::GLU		PACKAGE = OpenGL


#ifdef IN_POGL_GLU_XS

##################### GLU #########################

#ifdef HAVE_GLU

#// $nurb->gluBeginCurve($nurb);
void
gluBeginCurve(nurb)
	GLUnurbsObj *	nurb

#// gluEndCurve($nurb);
void
gluEndCurve(nurb)
	GLUnurbsObj *	nurb

#// gluBeginPolygon($tess);
void
gluBeginPolygon(tess)
	PGLUtess *	tess
	CODE:
	gluBeginPolygon(tess->triangulator);

#// gluEndPolygon($tess);
void
gluEndPolygon(tess)
	PGLUtess *	tess
	CODE:
	gluEndPolygon(tess->triangulator);

#// gluBeginSurface($nurb);
void
gluBeginSurface(nurb)
	GLUnurbsObj *	nurb

#// gluEndSurface($nurb);
void
gluEndSurface(nurb)
	GLUnurbsObj *	nurb

#// gluBeginTrim($nurb);
void
gluBeginTrim(nurb)
	GLUnurbsObj *	nurb

#// gluEndTrim($nurb);
void
gluEndTrim(nurb)
	GLUnurbsObj *	nurb

#//# gluBuild1DMipmaps_c($target, $internalformat, $width, $format, $type, (CPTR)data);
GLint
gluBuild1DMipmaps_c(target, internalformat, width, format, type, data)
	GLenum	target
	GLuint	internalformat
	GLsizei	width
	GLenum	format
	GLenum	type
	void *	data
	CODE:
	{
		RETVAL=gluBuild1DMipmaps(target, internalformat,
			width, format, type, data);
	}
	OUTPUT:
	  RETVAL

#//# gluBuild1DMipmaps_s($target, $internalformat, $width, $format, $type, (PACKED)data);
GLint
gluBuild1DMipmaps_s(target, internalformat, width, format, type, data)
	GLenum	target
	GLuint	internalformat
	GLsizei	width
	GLenum	format
	GLenum	type
	SV *	data
	CODE:
	{
	GLvoid * ptr = ELI(data, width, 1, format, type, gl_pixelbuffer_unpack);
	RETVAL=gluBuild1DMipmaps(target, internalformat, width, format, type, ptr);
	}
	OUTPUT:
	  RETVAL

#//# gluBuild2DMipmaps_c($target, $internalformat, $width, $height, $format, $type, (CPTR)data);
GLint
gluBuild2DMipmaps_c(target, internalformat, width, height, format, type, data)
	GLenum	target
	GLuint	internalformat
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	void *	data
	CODE:
	{
		RETVAL=gluBuild2DMipmaps(target, internalformat,
			width, height, format, type, data);
	}
	OUTPUT:
	  RETVAL

#//# gluBuild2DMipmaps_s($target, $internalformat, $width, $height, $format, $type, (PACKED)data);
GLint
gluBuild2DMipmaps_s(target, internalformat, width, height, format, type, data)
	GLenum	target
	GLuint	internalformat
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	SV *	data
	CODE:
	{
	GLvoid * ptr = ELI(data, width, height, format, type, gl_pixelbuffer_unpack);
	RETVAL=gluBuild2DMipmaps(target, internalformat, width, height, format, type, ptr);
	}
	OUTPUT:
	  RETVAL

#// gluCylinder($quad, $base, $top, $height, $slices, $stacks);
void
gluCylinder(quad, base, top, height, slices, stacks)
	GLUquadricObj *	quad
	GLdouble	base
	GLdouble	top
	GLdouble	height
	GLint	slices
	GLint	stacks

#// gluDeleteNurbsRenderer($nurb);
void
gluDeleteNurbsRenderer(nurb)
	GLUnurbsObj *	nurb

#// gluDeleteQuadric($quad);
void
gluDeleteQuadric(quad)
	GLUquadricObj *	quad

#// gluDeleteTess($tess);
void
gluDeleteTess(tess)
	PGLUtess *	tess
	CODE:
	{
		if (tess->triangulator)
			gluDeleteTess(tess->triangulator);
#ifdef GLU_VERSION_1_2
		if (tess->polygon_data_av)
			SvREFCNT_dec(tess->polygon_data_av);
		if (tess->begin_callback)
			SvREFCNT_dec(tess->begin_callback);
		if (tess->edgeFlag_callback)
			SvREFCNT_dec(tess->edgeFlag_callback);
		if (tess->vertex_callback)
			SvREFCNT_dec(tess->vertex_callback);
		if (tess->end_callback)
			SvREFCNT_dec(tess->end_callback);
		if (tess->error_callback)
			SvREFCNT_dec(tess->error_callback);
		if (tess->combine_callback)
			SvREFCNT_dec(tess->combine_callback);
		if (tess->vertex_datas)
			SvREFCNT_dec(tess->vertex_datas);
#endif
		free(tess);
	}

#// gluDisk($quad, $inner, $outer, $slices, $loops);
void
gluDisk(quad, inner, outer, slices, loops)
	GLUquadricObj *	quad
	GLdouble	inner
	GLdouble	outer
	GLint	slices
	GLint	loops

#//# gluErrorString($error);
char *
gluErrorString(error)
	GLenum	error
	CODE:
	RETVAL = (char*)gluErrorString(error);
	OUTPUT:
	RETVAL

#// gluGetNurbsProperty_p($nurb, $property);
GLfloat
gluGetNurbsProperty_p(nurb, property)
	GLUnurbsObj *	nurb
	GLenum	property
	CODE:
	{
		GLfloat param;
		gluGetNurbsProperty(nurb, property, &param);
		RETVAL = param;
	}
	OUTPUT:
	RETVAL

#// gluNurbsProperty(nurb, property, value);
void
gluNurbsProperty(nurb, property, value)
	GLUnurbsObj *	nurb
	GLenum	property
	GLfloat value

#ifdef GLU_VERSION_1_1

#//# gluGetString($name);
char *
gluGetString(name)
	GLenum	name
	CODE:
	RETVAL = (char*)gluGetString(name);
	OUTPUT:
	RETVAL

#endif

#// gluLoadSamplingMatrices_p(nurb, m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16, o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16, v1,v2,v3,v4);
void
gluLoadSamplingMatrices_p(nurb, m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16, o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16, v1,v2,v3,v4)
	GLUnurbsObj *	nurb
	CODE:
	{
		GLfloat m[16], p[16];
		GLint v[4];
		int i;
		for (i=0;i<16;i++)
			m[i] = (GLfloat)SvNV(ST(i+1));
		for (i=0;i<16;i++)
			p[i] = (GLfloat)SvNV(ST(i+1+16));
		for (i=0;i<4;i++)
			v[i] = SvIV(ST(i+1+16+16));
		gluLoadSamplingMatrices(nurb, m, p, v);
	}

#//# gluLookAt($eyeX, $eyeY, $eyeZ, $centerX, $centerY, $centerZ, $upX, $upY, $upZ);
void
gluLookAt(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
	GLdouble	eyeX
	GLdouble	eyeY
	GLdouble	eyeZ
	GLdouble	centerX
	GLdouble	centerY
	GLdouble	centerZ
	GLdouble	upX
	GLdouble	upY
	GLdouble	upZ

#// gluNewNurbsRenderer();
GLUnurbsObj *
gluNewNurbsRenderer()

#// gluNewQuadric();
GLUquadricObj *
gluNewQuadric()

#// gluNewTess();
PGLUtess *
gluNewTess()
	CODE:
	{
		RETVAL = calloc(sizeof(PGLUtess), 1);
		RETVAL->triangulator = gluNewTess();
	}
	OUTPUT:
	RETVAL

#// gluNextContour(tess, type);
void
gluNextContour(tess, type)
	PGLUtess *	tess
	GLenum	type
	CODE:
	gluNextContour(tess->triangulator, type);

#// gluNurbsCurve_c(nurb, nknots, knot, stride, ctlarray, order, type);
void
gluNurbsCurve_c(nurb, nknots, knot, stride, ctlarray, order, type)
	GLUnurbsObj *	nurb
	GLint	nknots
	void *	knot
	GLint	stride
	void *	ctlarray
	GLint	order
	GLenum	type
	CODE:
	gluNurbsCurve(nurb, nknots, knot, stride, ctlarray, order, type);

#// gluNurbsSurface_c(nurb, sknot_count, sknot, tknot_count, tknot, s_stride, t_stride, ctrlarray, sorder, torder, type);
void
gluNurbsSurface_c(nurb, sknot_count, sknot, tknot_count, tknot, s_stride, t_stride, ctrlarray, sorder, torder, type)
	GLUnurbsObj *	nurb
	GLint	sknot_count
	void *	sknot
	GLint	tknot_count
	void *	tknot
	GLint	s_stride
	GLint	t_stride
	void *	ctrlarray
	GLint	sorder
	GLint	torder
	GLenum	type
	CODE:
	gluNurbsSurface(nurb, sknot_count, sknot, tknot_count, tknot, s_stride, t_stride, ctrlarray, sorder, torder, type);

#//# gluOrtho2D($left, $right, $bottom, $top);
void
gluOrtho2D(left, right, bottom, top)
	GLdouble	left
	GLdouble	right
	GLdouble	bottom
	GLdouble	top

#// gluPartialDisk(quad, inner, outer, slices, loops, start, sweep);
void
gluPartialDisk(quad, inner, outer, slices, loops, start, sweep)
	GLUquadricObj*	quad
	GLdouble	inner
	GLdouble	outer
	GLint	slices
	GLint	loops
	GLdouble	start
	GLdouble	sweep

#//# gluPerspective($fovy, $aspect, $zNear, $zFar);
void
gluPerspective(fovy, aspect, zNear, zFar)
	GLdouble	fovy
	GLdouble	aspect
	GLdouble	zNear
	GLdouble	zFar

#//# gluPickMatrix_p($x, $y, $delX, $delY, $m1,$m2,$m3,$m4);
void
gluPickMatrix_p(x, y, delX, delY, m1,m2,m3,m4)
	GLdouble	x
	GLdouble	y
	GLdouble	delX
	GLdouble	delY
	CODE:
	{
		GLint m[4];
		int i;
		for (i=0;i<4;i++)
			m[i] = SvIV(ST(i+4));
		gluPickMatrix(x, y, delX, delY, &m[0]);
	}

#//# gluProject_p($objx, $objy, $objz, @m4x4, @o4x4, $v1,$v2,$v3,$v4);
void
gluProject_p(objx, objy, objz, m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16, o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16, v1,v2,v3,v4)
	GLdouble	objx
	GLdouble	objy
	GLdouble	objz
	PPCODE:
	{
		GLdouble m[16], p[16], winx, winy, winz;
		GLint v[4];
		int i;
		for (i=0;i<16;i++)
			m[i] = SvNV(ST(i+3));
		for (i=0;i<16;i++)
			p[i] = SvNV(ST(i+3+16));
		for (i=0;i<4;i++)
			v[i] = SvIV(ST(i+3+16+16));
		i = gluProject(objx, objy, objz, m, p, v, &winx, &winy, &winz);
		if (i) {
			EXTEND(sp, 3);
			PUSHs(sv_2mortal(newSVnv(winx)));
			PUSHs(sv_2mortal(newSVnv(winy)));
			PUSHs(sv_2mortal(newSVnv(winz)));
		}
	}

#// gluPwlCurve_c(nurb, count, data, stride, type);
void
gluPwlCurve_c(nurb, count, data, stride, type)
	GLUnurbsObj *	nurb
	GLint	count
	void *	data
	GLint	stride
	GLenum	type
	CODE:
	gluPwlCurve(nurb, count, data, stride, type);


#// gluQuadricDrawStyle(quad, draw);
void
gluQuadricDrawStyle(quad, draw)
	GLUquadricObj *	quad
	GLenum	draw

#// gluQuadricNormals(quad, normal);
void
gluQuadricNormals(quad, normal)
	GLUquadricObj *	quad
	GLenum	normal

#// gluQuadricOrientation(quad, orientation);
void
gluQuadricOrientation(quad, orientation)
	GLUquadricObj *	quad
	GLenum	orientation

#// gluQuadricTexture(quad, texture);
void
gluQuadricTexture(quad, texture)
	GLUquadricObj *	quad
	GLboolean	texture

#//# gluScaleImage_s($format, $wIn, $hIn, $typeIn, (PACKED)dataIn, $wOut, $hOut, $typeOut, (PACKED)dataOut);
GLint
gluScaleImage_s(format, wIn, hIn, typeIn, dataIn, wOut, hOut, typeOut, dataOut)
	GLenum	format
	GLsizei	wIn
	GLsizei	hIn
	GLenum	typeIn
	SV *	dataIn
	GLsizei	wOut
	GLsizei	hOut
	GLenum	typeOut
	SV *	dataOut
	CODE:
	{
		GLvoid * inptr, * outptr;
		STRLEN discard;
		ELI(dataIn, wIn, hIn, format, typeIn, gl_pixelbuffer_unpack);
		ELI(dataOut, wOut, hOut, format, typeOut, gl_pixelbuffer_pack);
		inptr = SvPV(dataIn, discard);
		outptr = SvPV(dataOut, discard);
		RETVAL = gluScaleImage(format, wIn, hIn, typeIn, inptr, wOut, hOut, typeOut, outptr);
	}
	OUTPUT:
	RETVAL

#// gluSphere(quad, radius, slices, stacks);
void
gluSphere(quad, radius, slices, stacks)
	GLUquadricObj *	quad
	GLdouble	radius
	GLint	slices
	GLint	stacks

#ifdef GLU_VERSION_1_2

#// gluGetTessProperty_p(tess, property);
GLdouble
gluGetTessProperty_p(tess, property)
	PGLUtess *	tess
	GLenum	property
	CODE:
	{
		GLdouble param;
		gluGetTessProperty(tess->triangulator, property, &param);
		RETVAL = param;
	}
	OUTPUT:
	RETVAL

#// #gluNurbsCallback_p(nurb, which, handler, ...);
#void
#gluNurbsCallback_p(nurb, which, handler, ...)

#// gluNurbsCallbackDataEXT
#void
#gluNurbsCallbackDataEXT

#// gluQuadricCallback
#void
#gluQuadricCallback

#// gluTessBeginContour(tess);
void
gluTessBeginContour(tess)
	PGLUtess *	tess
	CODE:
	gluTessBeginContour(tess->triangulator);

#// gluTessEndContour(tess);
void
gluTessEndContour(tess)
	PGLUtess *	tess
	CODE:
	gluTessEndContour(tess->triangulator);

#// gluTessBeginPolygon(tess, ...);
void
gluTessBeginPolygon(tess, ...)
	PGLUtess *	tess
	CODE:
	{
		if (tess->polygon_data_av) {
			SvREFCNT_dec(tess->polygon_data_av);
			tess->polygon_data_av = 0;
		}
		if (items > 1) {
			tess->polygon_data_av = newAV();
			PackCallbackST(tess->polygon_data_av, 1);
		}
               	if (!tess->vertex_datas)
 			tess->vertex_datas = newAV();
		gluTessBeginPolygon(tess->triangulator, tess);
	}

#// gluTessEndPolygon(tess);
void
gluTessEndPolygon(tess)
	PGLUtess *	tess
	CODE:
	{
		gluTessEndPolygon(tess->triangulator);
		if (tess->vertex_datas) {
			AV * vds = tess->vertex_datas;
			SV** svp;
			I32 i;
			for (i=0; i<=av_len(vds); i++) {
				svp = av_fetch(vds, i, FALSE);
				free((GLdouble*)SvIV(*svp));
			}
			SvREFCNT_dec(tess->vertex_datas);
			tess->vertex_datas = 0;
		}
		if (tess->polygon_data_av) {
			SvREFCNT_dec(tess->polygon_data_av);
			tess->polygon_data_av = 0;
		}
	}

#// gluTessNormal(tess, valueX, valueY, valueZ)
void
gluTessNormal(tess, valueX, valueY, valueZ)
	PGLUtess *	tess
	GLdouble	valueX
	GLdouble	valueY
	GLdouble	valueZ
	CODE:
	gluTessNormal(tess->triangulator, valueX, valueY, valueZ);

#// gluTessProperty(tess, which, data);
void
gluTessProperty(tess, which, data)
	PGLUtess *	tess
	GLenum	which
	GLdouble	data
	CODE:
	gluTessProperty(tess->triangulator, which, data);

#// gluTessCallback(tess, which, ...);
void
gluTessCallback(tess, which, ...)
	PGLUtess *	tess
	GLenum	which
	CODE:
	{
		switch (which) {
		case GLU_TESS_BEGIN:
		case GLU_TESS_BEGIN_DATA:
			if (tess->begin_callback) {
				SvREFCNT_dec(tess->begin_callback);
				tess->begin_callback = 0;
			}
			break;
		case GLU_TESS_END:
		case GLU_TESS_END_DATA:
			if (tess->end_callback) {
				SvREFCNT_dec(tess->end_callback);
				tess->end_callback = 0;
			}
			break;
		case GLU_TESS_VERTEX:
		case GLU_TESS_VERTEX_DATA:
			if (tess->vertex_callback) {
				SvREFCNT_dec(tess->vertex_callback);
				tess->vertex_callback = 0;
			}
			break;
		case GLU_TESS_ERROR:
		case GLU_TESS_ERROR_DATA:
			if (tess->error_callback) {
				SvREFCNT_dec(tess->error_callback);
				tess->error_callback = 0;
			}
			break;
		case GLU_TESS_COMBINE:
		case GLU_TESS_COMBINE_DATA:
			if (tess->combine_callback) {
				SvREFCNT_dec(tess->combine_callback);
				tess->combine_callback = 0;
			}
			break;
		case GLU_TESS_EDGE_FLAG:
		case GLU_TESS_EDGE_FLAG_DATA:
			if (tess->edgeFlag_callback) {
				SvREFCNT_dec(tess->edgeFlag_callback);
				tess->edgeFlag_callback = 0;
			}
			break;
		}

                // if ((items > 2) && !SvOK(ST(2))) {
                if (items > 2) {
			AV * callback = newAV();
                        if (SvPOK(ST(2))
                           && sv_eq(ST(2), sv_2mortal(newSVpv("DEFAULT", 0)))) {
    			   av_push(callback, newSViv(1));
                        } else if (!SvROK(ST(2)) || SvTYPE(SvRV(ST(2))) != SVt_PVCV) {
                                croak("3rd argument to gluTessCallback must be a perl code ref");
                        } else {
   			   PackCallbackST(callback, 2);
                        }
			switch (which) {
			case GLU_TESS_BEGIN:
			case GLU_TESS_BEGIN_DATA:
				tess->begin_callback = callback;
				gluTessCallback(tess->triangulator, GLU_TESS_BEGIN_DATA, (void (CALLBACK*)()) _s_marshal_glu_t_callback_begin);
				break;
			case GLU_TESS_END:
			case GLU_TESS_END_DATA:
				tess->end_callback = callback;
				gluTessCallback(tess->triangulator, GLU_TESS_END_DATA, (void (CALLBACK*)()) _s_marshal_glu_t_callback_end);
				break;
			case GLU_TESS_VERTEX:
			case GLU_TESS_VERTEX_DATA:
				tess->vertex_callback = callback;
				gluTessCallback(tess->triangulator, GLU_TESS_VERTEX_DATA, (void (CALLBACK*)()) _s_marshal_glu_t_callback_vertex);
				break;
			case GLU_TESS_ERROR:
			case GLU_TESS_ERROR_DATA:
				tess->error_callback = callback;
				gluTessCallback(tess->triangulator, GLU_TESS_ERROR_DATA, (void (CALLBACK*)()) _s_marshal_glu_t_callback_error);
				break;
			case GLU_TESS_COMBINE:
			case GLU_TESS_COMBINE_DATA:
				tess->combine_callback = callback;
				gluTessCallback(tess->triangulator, GLU_TESS_COMBINE_DATA, (void (CALLBACK*)()) _s_marshal_glu_t_callback_combine);
				break;
			case GLU_TESS_EDGE_FLAG:
			case GLU_TESS_EDGE_FLAG_DATA:
				tess->edgeFlag_callback = callback;
				gluTessCallback(tess->triangulator, GLU_TESS_EDGE_FLAG_DATA, (void (CALLBACK*)()) _s_marshal_glu_t_callback_edgeFlag);
				break;
			}
		}
	}
	

#endif

#// gluTessVertex(tess, x, y, z, ...);
void
gluTessVertex(tess, x, y, z, ...)
	PGLUtess *	tess
	GLdouble	x
	GLdouble	y
	GLdouble	z
	CODE:
	{
		GLdouble *v    = malloc(sizeof(GLdouble) * 3);
		GLdouble *data = malloc(sizeof(GLdouble) * 7);
                AV *vds = tess->vertex_datas;
                if (!vds) croak("Missing vertex data storage");
	        av_push(vds, newSViv((int)v));
	        av_push(vds, newSViv((int)data));
		v[0] = x;
		v[1] = y;
		v[2] = z;
		data[0] = x;
		data[1] = y;
		data[2] = z;
                if (items > 4) {
                  if (items != 6 && items != 7) croak("Invalid r, g, b, a arguments to gluTessVertex");
                  I32 i;
                  for (i = 4; i<items; i++)
                    data[i-1] = (GLdouble)SvNV(ST(i));
                }
		gluTessVertex(tess->triangulator, &v[0], (void*)data);
	}

#//# gluUnProject_p($winx,$winy,$winz, @m4x4, @o4x4, $v1,$v2,$v3,$v4);
void
gluUnProject_p(winx,winy,winz, m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16, o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16, v1,v2,v3,v4)
	GLdouble	winx
	GLdouble	winy
	GLdouble	winz
	PPCODE:
	{
		GLdouble m[16], p[16], objx, objy, objz;
		GLint v[4];
		int i;

		for (i=0;i<16;i++)
			m[i] = SvNV(ST(i+3));
		for (i=0;i<16;i++)
			p[i] = SvNV(ST(i+3+16));
		for (i=0;i<4;i++)
			v[i] = SvIV(ST(i+3+16+16));

		i = gluUnProject(winx,winy,winz, m, p, v, &objx,&objy,&objz);

		if (i) {
			EXTEND(sp, 3);
			PUSHs(sv_2mortal(newSVnv(objx)));
			PUSHs(sv_2mortal(newSVnv(objy)));
			PUSHs(sv_2mortal(newSVnv(objz)));
		}
	}

#endif

#endif /* End IN_POGL_GLU_XS */

