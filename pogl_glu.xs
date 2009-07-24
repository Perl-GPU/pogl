/*  Last saved: Fri 24 Jul 2009 01:50:20 PM  */

/*  Copyright (c) 1998 Kenneth Albanowski. All rights reserved.
 *  Copyright (c) 2007 Bob Free. All rights reserved.
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

/* Begin a named callback handler */
#define begin_void_specific_marshaller(name, assign_handler_av, params) \
static void _s_marshal_ ## name params					\
{                                                                       \
    SV * handler;                                                       \
	AV * handler_av;                                                \
	dSP;                                                            \
	int i;                                                          \
	assign_handler_av;                                              \
	if (!handler_av) croak("Failure of callback handler");          \
	handler = *av_fetch(handler_av, 0, 0);                          \
    PUSHMARK(sp);                                                       \
    for (i=1; i<=av_len(handler_av); i++)                               \
        XPUSHs(sv_2mortal(newSVsv(*av_fetch(handler_av, i, 0))));

/* End a named callback handler */
#define end_void_specific_marshaller()                                  \
	PUTBACK;                                                        \
	perl_call_sv(handler, G_DISCARD);                               \
}


struct PGLUtess {
	GLUtriangulatorObj * triangulator;

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
#define begin_tess_marshaller(type, params)				\
begin_void_specific_marshaller(glu_t_callback_ ## type,                 \
	PGLUtess * t = (PGLUtess*)polygon_data;                         \
	handler_av = t-> type ## _callback                              \
	, params)                                                       \
    if (t->polygon_data_av)                                             \
      for (i=0; i<=av_len(t->polygon_data_av); i++)                     \
        XPUSHs(sv_2mortal(newSVsv(*av_fetch(t->polygon_data_av, i, 0))));

/* End a gluTess callback handler */
#define end_tess_marshaller()                                           \
end_void_specific_marshaller()

/* Declare gluTess BEGIN */
begin_tess_marshaller(begin, (GLenum type, void * polygon_data))
	XPUSHs(sv_2mortal(newSViv(type)));
end_tess_marshaller()

/* Declare gluTess END */
begin_tess_marshaller(end, (void * polygon_data))
end_tess_marshaller()

/* Declare gluTess EDGEFLAG */
begin_tess_marshaller(edgeFlag, (GLboolean flag, void * polygon_data))
	XPUSHs(sv_2mortal(newSViv(flag)));
end_tess_marshaller()

/* Declare gluTess VERTEX */
begin_tess_marshaller(vertex, (void * vertex_data, void * polygon_data))
	if (vertex_data) {
      AV * vd = (AV*)vertex_data;
      for (i=0; i<=av_len(vd); i++)
        XPUSHs(sv_2mortal(newSVsv(*av_fetch(vd, i, 0))));
    }
end_tess_marshaller()

/* Declare gluTess ERROR */
begin_tess_marshaller(error, (GLenum errno_, void * polygon_data))
	XPUSHs(sv_2mortal(newSViv(errno_)));
end_tess_marshaller()

/* Declare gluTess COMBINE */
begin_tess_marshaller(combine, (GLdouble coords[3], void * vertex_data[4], GLfloat weight[4], void ** outd, void * polygon_data))
	croak("combine tess marshaller needs FIXME (see OpenGL.xs)");
end_tess_marshaller()

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

#// gluTessBeginCountour(tess);
void
gluTessBeginCountour(tess)
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
		gluTessBeginPolygon(tess->triangulator, tess);
	}

#// gluTessEndPolygon(tess);
void
gluTessEndPolygon(tess)
	PGLUtess *	tess
	CODE:
	{
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
		}
		
		if ((items > 3) && !SvOK(ST(2))) {
			AV * callback = newAV();
			PackCallbackST(callback, 2);

			switch (which) {
			case GLU_TESS_BEGIN:
			case GLU_TESS_BEGIN_DATA:
				tess->begin_callback = callback;
				gluTessCallback(tess->triangulator, which, (void (CALLBACK*)()) _s_marshal_glu_t_callback_begin);
				break;
			case GLU_TESS_END:
			case GLU_TESS_END_DATA:
				tess->end_callback = callback;
				gluTessCallback(tess->triangulator, which, (void (CALLBACK*)()) _s_marshal_glu_t_callback_end);
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
		AV * data = 0;
		GLdouble v[3];
		v[0] = x;
		v[1] = y;
		v[2] = z;

		if (items > 4) {
			data = newAV();
			PackCallbackST(data, 4);
			
			if (!tess->vertex_datas)
				tess->vertex_datas = newAV();
			
			av_push(tess->vertex_datas, newRV_inc((SV*)data));
			SvREFCNT_dec(data);
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
