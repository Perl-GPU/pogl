/*  Copyright (c) 1998 Kenneth Albanowski. All rights reserved.
 *  Copyright (c) 2007 Bob Free. All rights reserved.
 *  Copyright (c) 2009 Chris Marshall. All rights reserved.
 *  This program is free software; you can redistribute it and/or
 *  modify it under the same terms as Perl itself.
 */

#include <stdio.h>

#include "pgopogl.h"

#ifdef HAVE_GL
#include "gl_util.h"
#endif /* defined HAVE_GL */

MODULE = OpenGL::V1	PACKAGE = OpenGL

#ifdef HAVE_GL

#// 1.0
#//# glAccum($op, $value);
void
glAccum(op, value)
	GLenum	op
	GLfloat	value

#// 1.0
#//# glAlphaFunc($func, $ref);
void
glAlphaFunc(func, ref)
	GLenum	func
	GLclampf	ref

#ifdef GL_VERSION_1_1

#//# glAreTexturesResident_c($n, (CPTR)textures, (CPTR)residences);
void
glAreTexturesResident_c(n, textures, residences)
	GLsizei	n
	void *	textures
	void *	residences
	CODE:
	glAreTexturesResident(n, textures, residences);

#//# glAreTexturesResident_s($n, (PACKED)textures, (PACKED)residences);
void
glAreTexturesResident_s(n, textures, residences)
	GLsizei	n
	SV *	textures
	SV *	residences
	CODE:
	{
	void * textures_s = EL(textures, sizeof(GLuint)*n);
	void * residences_s = EL(residences, sizeof(GLboolean)*n);
	glAreTexturesResident(n, textures_s, residences_s);
	}

#// 1.1
#//# (result,@residences) = glAreTexturesResident_p(@textureIDs);
void
glAreTexturesResident_p(...)
	PPCODE:
	{
		GLsizei n = items;
		GLuint * textures = malloc(sizeof(GLuint) * (n+1));
		GLboolean * residences = malloc(sizeof(GLboolean) * (n+1));
		GLboolean result;
		int i;

		for (i=0;i<n;i++)
			textures[i] = SvIV(ST(i));

		result = glAreTexturesResident(n, textures, residences);

		if ((result == GL_TRUE) || (GIMME != G_ARRAY))
			PUSHs(sv_2mortal(newSViv(result)));
		else {
			EXTEND(sp, n+1);
			PUSHs(sv_2mortal(newSViv(result)));
			for(i=0;i<n;i++)
				PUSHs(sv_2mortal(newSViv(residences[i])));
		}

		free(textures);
		free(residences);
	}

#// 1.1
#//# glArrayElement($i);
void
glArrayElement(i)
	GLint	i

#endif

#// 1.0
#//# glBegin($mode);
void
glBegin(mode)
	GLenum	mode

#// 1.0
#//# glEnd()
void
glEnd()

#ifdef GL_VERSION_1_1

#//# glBindTexture($target, $texture);
void
glBindTexture(target, texture)
	GLenum	target
	GLuint	texture

#endif


#// 1.0
#//# glBitmap_c($width, $height, $xorig, $yorig, $xmove, $ymove, (CPTR)bitmap);
void
glBitmap_c(width, height, xorig, yorig, xmove, ymove, bitmap)
	GLsizei	width
	GLsizei	height
	GLfloat	xorig
	GLfloat	yorig
	GLfloat	xmove
	GLfloat	ymove
	void *	bitmap
	CODE:
	glBitmap(width, height, xorig, yorig, xmove, ymove, bitmap);

#//# glBitmap_s($width, $height, $xorig, $yorig, $xmove, $ymove, (PACKED)bitmap);
void
glBitmap_s(width, height, xorig, yorig, xmove, ymove, bitmap)
	GLsizei	width
	GLsizei	height
	GLfloat	xorig
	GLfloat	yorig
	GLfloat	xmove
	GLfloat	ymove
	SV *	bitmap
	CODE:
	{
	GLubyte * bitmap_s = ELI(bitmap, width, height,
		GL_COLOR_INDEX, GL_BITMAP, gl_pixelbuffer_unpack);
	glBitmap(width, height, xorig, yorig, xmove, ymove, bitmap_s);
	}

#//# glBitmap_p($width, $height, $xorig, $yorig, $xmove, $ymove, @bitmap);
void
glBitmap_p(width, height, xorig, yorig, xmove, ymove, ...)
	GLsizei	width
	GLsizei	height
	GLfloat	xorig
	GLfloat	yorig
	GLfloat	xmove
	GLfloat	ymove
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(6)), items-6, width, height,
		1, GL_COLOR_INDEX, GL_BITMAP, 0);
	glBitmap(width, height, xorig, yorig, xmove, ymove, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#// 1.0
#//# glBlendFunc($sfactor, $dfactor);
void
glBlendFunc(sfactor, dfactor)
	GLenum	sfactor
	GLenum	dfactor

#// 1.0
#//# glCallList($list);
void
glCallList(list)
	GLuint	list

#// 1.0
#//# glCallLists_c($n, $type, (CPTR)lists);
void
glCallLists_c(n, type, lists)
	GLsizei	n
	GLenum	type
	void *	lists
	CODE:
	glCallLists(n, type, lists);

#// 1.0
#//# glCallLists_s($n, $type, (PACKED)lists);
void
glCallLists_s(n, type, lists)
	GLsizei	n
	GLenum	type
	SV *	lists
	CODE:
	{
	void * lists_s = EL(lists, gl_type_size(type) * n);
	glCallLists(n, type, lists_s);
	}

#// 1.0
#//# glCallLists_p(@lists);
#//- Assumes GLint type
void
glCallLists_p(...)
	CODE:
	if (items) {
		int * list = malloc(sizeof(int) * items);
		int i;
		for(i=0;i<items;i++)
			list[i] = SvIV(ST(i));
		glCallLists(items, GL_INT, list);
		free(list);
	}

#// 1.0
#//# glClear($mask);
void
glClear(mask)
	GLbitfield	mask

#// 1.0
#//# glClearAccum($red, $green, $blue, $alpha);
void
glClearAccum(red, green, blue, alpha)
	GLfloat	red
	GLfloat	green
	GLfloat	blue
	GLfloat	alpha

#// 1.0
#//# glClearColor($red, $green, $blue, $alpha);
void
glClearColor(red, green, blue, alpha)
	GLclampf	red
	GLclampf	green
	GLclampf	blue
	GLclampf	alpha

#// 1.0
#//# glClearDepth($depth);
void
glClearDepth(depth)
	GLclampd	depth

#// 1.0
#//# glClearIndex($c);
void
glClearIndex(c)
	GLfloat	c

#// 1.0
#//# glClearStencil($s);
void
glClearStencil(s)
	GLint	s

#// 1.0
#//# glClipPlane_c($plane, (CPTR)eqn);
void
glClipPlane_c(plane, eqn)
	GLenum	plane
	void *	eqn
	CODE:
	glClipPlane(plane, eqn);

#// 1.0
#//# glClipPlane_s($plane, (PACKED)eqn);
void
glClipPlane_s(plane, eqn)
	GLenum	plane
	SV *	eqn
	CODE:
	{
		GLdouble * eqn_s = EL(eqn, sizeof(GLdouble) * 4);
		glClipPlane(plane, eqn_s);
	}

#// 1.0
#//# glClipPlane_p($plane, $eqn0, $eqn1, $eqn2, $eqn3);
void
glClipPlane_p(plane, eqn0, eqn1, eqn2, eqn3)
	GLenum	plane
	double	eqn0
	double	eqn1
	double	eqn2
	double	eqn3
	CODE:
	{
		double eqn[4];
		eqn[0] = eqn0;
		eqn[1] = eqn1;
		eqn[2] = eqn2;
		eqn[3] = eqn3;
		glClipPlane(plane, &eqn[0]);
	}

#// 1.0
#//# glColorMask($red, $green, $blue, $alpha);
void
glColorMask(red, green, blue, alpha)
	GLboolean	red
	GLboolean	green
	GLboolean	blue
	GLboolean	alpha

#// 1.0
#//# glColorMaterial($face, $mode);
void
glColorMaterial(face, mode)
	GLenum	face
	GLenum	mode


#// 1.0
#//# glCopyPixels($x, $y, $width, $height, $type);
void
glCopyPixels(x, y, width, height, type)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLenum	type

#ifdef GL_VERSION_1_1

#// 1.1
#//# glCopyTexImage1D($target, $level, $internalFormat, $x, $y, $width, $border);
void
glCopyTexImage1D(target, level, internalFormat, x, y, width, border)
	GLenum	target
	GLint	level
	GLenum	internalFormat
	GLint	x
	GLint	y
	GLsizei	width
	GLint	border

#// 1.1
#//# glCopyTexImage2D($target, $level, $internalFormat, $x, $y, $width, $height, $border);
void
glCopyTexImage2D(target, level, internalFormat, x, y, width, height, border)
	GLenum	target
	GLint	level
	GLenum	internalFormat
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLint	border

#// 1.1
#//# glCopyTexSubImage1D($target, $level, $xoffset, $x, $y, $width);
void
glCopyTexSubImage1D(target, level, xoffset, x, y, width)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	x
	GLint	y
	GLsizei	width

#// 1.1
#//# glCopyTexSubImage2D($target, $level, $xoffset, $yoffset, $x, $y, $width, $height);
void
glCopyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height

#ifdef GL_VERSION_1_2

#// 1.2
#//# glCopyTexSubImage3D($target, $level, $xoffset, $yoffset, $zoffset, $x, $y, $width, $height);
void
glCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset, x, y, width, height)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	zoffset
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	INIT:
		loadProc(glCopyTexSubImage3D,"glCopyTexSubImage3D");
	CODE:
	{
		glCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset,
			x, y, width, height);
	}

#endif

#endif

#// 1.0
#//# glCullFace($mode);
void
glCullFace(mode)
	GLenum	mode

#// 1.0
#//# glDeleteLists($list, $range);
void
glDeleteLists(list, range)
	GLenum	list
	GLsizei	range

#ifdef GL_VERSION_1_1

#// 1.1
#//# glDeleteTextures_c($items, (CPTR)list);
void
glDeleteTextures_c(items, list)
	GLint	items
	void *	list
	CODE:
	glDeleteTextures(items,list);

#// 1.1
#//# glDeleteTextures_s($items, (PACKED)list);
void
glDeleteTextures_s(items, list)
	GLint	items
	SV *	list
	CODE:
	{
	void * list_s = EL(list, sizeof(GLuint) * items);
	glDeleteTextures(items,list_s);
	}

#// 1.1
#//# glDeleteTextures_p(@textureIDs);
void
glDeleteTextures_p(...)
	CODE:
	if (items) {
		GLuint * list = malloc(sizeof(GLuint) * items);
		int i;

		for(i=0;i<items;i++)
			list[i] = SvIV(ST(i));

		glDeleteTextures(items, list);
		free(list);
	}

#endif

#// 1.0
#//# glDepthFunc($func);
void
glDepthFunc(func)
	GLenum	func

#// 1.0
#//# glDepthMask($flag);
void
glDepthMask(flag)
	GLboolean	flag

#// 1.0
#//# glDepthRange($zNear, $zFar);
void
glDepthRange(zNear, zFar)
	GLclampd	zNear
	GLclampd	zFar

#ifdef GL_VERSION_1_1

#// 1.1
#//# glDrawArrays($mode, $first, $count);
void
glDrawArrays(mode, first, count)
	GLenum	mode
	GLint	first
	GLsizei	count

#endif

#// 1.0
#//# glDrawBuffer($mode);
void
glDrawBuffer(mode)
	GLenum	mode

#ifdef GL_VERSION_1_1

#// 1.1
#//# glDrawElements_c($mode, $count, $type, (CPTR)indices);
void
glDrawElements_c(mode, count, type, indices)
	GLenum	mode
	GLint	count
	GLenum	type
	void *	indices
	CODE:
		glDrawElements(mode, count, type, indices);

#// 1.1
#//# glDrawElements_s($mode, $count, $type, (PACKED)indices);
void
glDrawElements_s(mode, count, type, indices)
	GLenum	mode
	GLint	count
	GLenum	type
	SV *	indices
	CODE:
	{
		void * indices_s = EL(indices, gl_type_size(type)*count);
		glDrawElements(mode, count, type, indices_s);
	}

#//# glDrawElements_p($mode, @indices);
#//- Assumes GLuint for indices
void
glDrawElements_p(mode, ...)
	GLenum	mode
	CODE:
	{
		GLuint * indices = malloc(sizeof(GLuint) * items);
		int i;

		for (i=1; i<items; i++)
			indices[i-1] = SvIV(ST(i));

		glDrawElements(mode, items-1, GL_UNSIGNED_INT, indices);

		free(indices);
	}

#endif

#// 1.0
#//# glDrawPixels_c($width, $height, $format, $type, (CPTR)pixels);
void
glDrawPixels_c(width, height, format, type, pixels)
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glDrawPixels(width, height, format, type, pixels);

#// 1.0
#//# glDrawPixels_s($width, $height, $format, $type, (PACKED)pixels);
void
glDrawPixels_s(width, height, format, type, pixels)
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
	GLvoid * ptr = ELI(pixels, width, height,
		format, type, gl_pixelbuffer_unpack);
	glDrawPixels(width, height, format, type, ptr);
	}

#// 1.0
#//# glDrawPixels_p($width, $height, $format, $type, @pixels);
void
glDrawPixels_p(width, height, format, type, ...)
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(4)), items-4, width, height, 1, format, type, 0);
	glDrawPixels(width, height, format, type, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#ifdef GL_VERSION_1_2

#// 1.2
#//# glDrawRangeElements_c($mode, $start, $end, $count, $type, (CPTR)indices);
void
glDrawRangeElements_c(mode, start, end, count, type, indices)
	GLenum	mode
	GLuint	start
	GLuint	end
	GLsizei	count
	GLenum	type
	void *	indices
	INIT:
		loadProc(glDrawRangeElements,"glDrawRangeElements");
	CODE:
		glDrawRangeElements(mode, start, end, count, type, indices);

#//# glDrawRangeElements_s($mode, $start, $end, $count, $type, (PACKED)indices);
void
glDrawRangeElements_s(mode, start, end, count, type, indices)
	GLenum	mode
	GLuint	start
	GLuint	end
	GLsizei	count
	GLenum	type
	SV *	indices
	INIT:
		loadProc(glDrawRangeElements,"glDrawRangeElements");
	CODE:
	{
		void * indices_s = EL(indices, gl_type_size(type) * count);
		glDrawRangeElements(mode, start, end, count, type, indices_s);
	}

#//# glDrawRangeElements_p($mode, $start, $end, $count, $type, @indices);
#//- Assumes GLuint indices
void
glDrawRangeElements_p(mode, start, count, ...)
	GLenum	mode
	GLuint	start
	GLuint	count
	INIT:
		loadProc(glDrawRangeElements,"glDrawRangeElements");
	CODE:
	{
		if (items > 3)
		{
			if (start < (GLuint)items-3)
			{
				GLuint * indices;
				GLuint i;

				if (start+count > (GLuint)(items-3))
					count = (GLuint)items-(start+3);

				indices = malloc(sizeof(GLuint) * count);

				for (i=start; i<count; i++)
					indices[i] = SvIV(ST(i+3));

				glDrawRangeElements(mode, start, start+count-1,
					count, GL_UNSIGNED_INT, indices);

				free(indices);
			}
		}
		else
		{
			glDrawRangeElements(mode, start, start+count-1,
				count, GL_UNSIGNED_INT, 0);
		}
	}

#endif

#// 1.0
#//# glEdgeFlag($flag);
void
glEdgeFlag(flag)
	GLboolean	flag


#// 1.0
#//# glEnable($cap);
void
glEnable(cap)
	GLenum	cap

#// 1.0
#//# glDisable($cap);
void
glDisable(cap)
	GLenum	cap

#ifdef GL_VERSION_1_1

#// 1.1
#//# glEnableClientState($cap);
void
glEnableClientState(cap)
	GLenum	cap

#// 1.1
#//# glDisableClientState($cap);
void
glDisableClientState(cap)
	GLenum	cap

#endif

#// 1.0
#//# glEvalCoord1d($u);
void
glEvalCoord1d(u)
	GLdouble	u

#// 1.0
#//# glEvalCoord1f($u);
void
glEvalCoord1f(u)
	GLfloat	u

#// 1.0
#//# glEvalCoord2d($u, $v);
void
glEvalCoord2d(u, v)
	GLdouble	u
	GLdouble	v

#// 1.0
#//# glEvalCoord2f($u, $v);
void
glEvalCoord2f(u, v)
	GLfloat	u
	GLfloat	v

#// 1.0
#//# glEvalMesh1($mode, $i1, $i2);
void
glEvalMesh1(mode, i1, i2)
	GLenum	mode
	GLint	i1
	GLint	i2

#// 1.0
#//# glEvalMesh2($mode, $i1, $i2, $j1, $j2);
void
glEvalMesh2(mode, i1, i2, j1, j2)
	GLenum	mode
	GLint	i1
	GLint	i2
	GLint	j1
	GLint	j2

#// 1.0
#//# glEvalPoint1($i);
void
glEvalPoint1(i)
	GLint	i

#// 1.0
#//# glEvalPoint2($i, $j);
void
glEvalPoint2(i, j)
	GLint	i
	GLint	j

#// 1.0
#//# glFeedbackBuffer_c($size, $type, (CPTR)buffer);
void
glFeedbackBuffer_c(size, type, buffer)
	GLsizei	size
	GLenum	type
	void *	buffer
	CODE:
	glFeedbackBuffer(size, type, (GLfloat*)(buffer));

#// 1.0
#//# glFinish();
void
glFinish()

#// 1.0
#//# glFlush();
void
glFlush()

#// 1.0
#//# glFogf($pname, $param);
void
glFogf(pname, param)
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glFogi($pname, $param);
void
glFogi(pname, param)
	GLenum	pname
	GLint	param

#// 1.0
#//# glFogfv_c($pname, (CPTR)params);
void
glFogfv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glFogfv(pname, params);

#// 1.0
#//# glFogiv_c($pname, (CPTR)params);
void
glFogiv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glFogiv(pname, params);

#// 1.0
#//# glFogfv_s($pname, (PACKED)params);
void
glFogfv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat)*gl_fog_count(pname));
	glFogfv(pname, params_s);
	}

#// 1.0
#//# glFogiv_s($pname, (PACKED)params);
void
glFogiv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*gl_fog_count(pname));
	glFogiv(pname, params_s);
	}

#// 1.0
#//# glFogfv_p($pname, $param1, $param2=0, $param3=0, $param4=0);
void
glFogfv_p(pname, param1, param2=0, param3=0, param4=0)
	GLenum	pname
	GLfloat	param1
	GLfloat	param2
	GLfloat	param3
	GLfloat	param4
	CODE:
	{
		GLfloat p[4];
		p[0] = param1;
		p[1] = param2;
		p[2] = param3;
		p[3] = param4;
		glFogfv(pname, &p[0]);
	}

#// 1.0
#//# glFogiv_p($pname, $param1, $param2=0, $param3=0, $param4=0);
void
glFogiv_p(pname, param1, param2=0, param3=0, param4=0)
	GLenum	pname
	GLint	param1
	GLint	param2
	GLint	param3
	GLint	param4
	CODE:
	{
		GLint p[4];
		p[0] = param1;
		p[1] = param2;
		p[2] = param3;
		p[3] = param4;
		glFogiv(pname, &p[0]);
	}

#// 1.0
#//# glFrontFace($mode);
void
glFrontFace(mode)
	GLenum	mode

#// 1.0
#//# glFrustum($left, $right, $bottom, $top, $zNear, $zFar);
void
glFrustum(left, right, bottom, top, zNear, zFar)
	GLdouble	left
	GLdouble	right
	GLdouble	bottom
	GLdouble	top
	GLdouble	zNear
	GLdouble	zFar

#// 1.0
#//# glGenLists($range);
GLuint
glGenLists(range)
	GLsizei	range

#ifdef GL_VERSION_1_1

#// 1.1
#//# glGenTextures_c($n, (CPTR)textures);
void
glGenTextures_c(n, textures)
	GLint	n
	void *	textures
	CODE:
	glGenTextures(n, textures);

#// 1.1
#//# glGenTextures_s($n, (PACKED)textures);
void
glGenTextures_s(n, textures)
	GLint	n
	SV *	textures
	CODE:
	{
	void * textures_s = EL(textures, sizeof(GLuint)*n);
	glGenTextures(n, textures_s);
	}

#// 1.1
#//# @textureIDs = glGenTextures_p($n);
void
glGenTextures_p(n)
	GLint	n
	PPCODE:
	if (n) {
		GLuint * textures = malloc(sizeof(GLuint) * n);
		int i;

		glGenTextures(n, textures);

		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(textures[i])));

		free(textures);
	}

#endif

#// 1.0
#//# glGetDoublev_c($pname, (CPTR)params);
void
glGetDoublev_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glGetDoublev(pname, params);

#// 1.0
#//# glGetDoublev_c($pname, (PACKED)params);
void
glGetDoublev_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	void * params_s = EL(params, sizeof(GLdouble) * gl_get_count(pname));
	glGetDoublev(pname, params_s);
	}

#// 1.0
#//# glGetBooleanv_c($pname, (CPTR)params);
void
glGetBooleanv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glGetBooleanv(pname, params);

#// 1.0
#//# glGetBooleanv_s($pname, (PACKED)params);
void
glGetBooleanv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	void * params_s = EL(params, sizeof(GLboolean) * gl_get_count(pname));
	glGetBooleanv(pname, params_s);
	}

#// 1.0
#//# glGetIntegerv_c($pname, (CPTR)params);
void
glGetIntegerv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glGetIntegerv(pname, params);

#// 1.0
#//# glGetIntegerv_s($pname, (PACKED)params);
void
glGetIntegerv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	void * params_s = EL(params, sizeof(GLint) * gl_get_count(pname));
	glGetIntegerv(pname, params_s);
	}

#// 1.0
#//# glGetFloatv_c($pname, (CPTR)params);
void
glGetFloatv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glGetFloatv(pname, params);

#// 1.0
#//# glGetFloatv_s($pname, (PACKED)params);
void
glGetFloatv_s(pname, params)
	GLenum	pname
	void *	params
	CODE:
	{
	void * params_s = EL(params, sizeof(GLfloat) * gl_get_count(pname));
	glGetFloatv(pname, params_s);
	}

#// 1.0
#//# @data = glGetDoublev_p($param);
void
glGetDoublev_p(param)
	GLenum	param
	PPCODE:
	{
		GLdouble	ret[MAX_GL_GET_COUNT];
		int n = gl_get_count(param);
		int i;
		glGetDoublev(param, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @data = glGetBooleanv_p($param);
void
glGetBooleanv_p(param)
	GLenum	param
	PPCODE:
	{
		GLboolean	ret[MAX_GL_GET_COUNT];
		int n = gl_get_count(param);
		int i;
		glGetBooleanv(param, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# @data = glGetIntegerv_p($param);
void
glGetIntegerv_p(param)
	GLenum	param
	PPCODE:
	{
		GLint	ret[MAX_GL_GET_COUNT];
		int n = gl_get_count(param);
		int i;
		glGetIntegerv(param, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# @data = glGetFloatv_p($param);
void
glGetFloatv_p(param)
	GLenum	param
	PPCODE:
	{
		GLfloat	ret[MAX_GL_GET_COUNT];
		int n = gl_get_count(param);
		int i;
		glGetFloatv(param, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# glGetClipPlane_c($plane, (CPTR)eqn);
void
glGetClipPlane_c(plane, eqn)
	GLenum	plane
	void *	eqn
	CODE:
	glGetClipPlane(plane, eqn);

#// 1.0
#//# glGetClipPlane_s($plane, (PACKED)eqn);
void
glGetClipPlane_s(plane, eqn)
	GLenum	plane
	SV *	eqn
	CODE:
	{
	GLdouble * eqn_s = EL(eqn, sizeof(GLdouble)*4);
	glGetClipPlane(plane, eqn_s);
	}

#// 1.0
#//# @data = glGetClipPlane_p($plane);
void
glGetClipPlane_p(plane)
	GLenum	plane
	PPCODE:
	{
		int i;
		GLdouble	eqn[4];
		eqn[0] = eqn[1] = eqn[2] = eqn[3] = 0;
		glGetClipPlane(plane, &eqn[0]);
		EXTEND(sp, 4);
		for(i=0;i<4;i++)
			PUSHs(sv_2mortal(newSVnv(eqn[i])));
	}

#// 1.0
#//# glGetError();
GLenum
glGetError()

#// 1.0
#//# glGetLightfv_c($light, $pname, (CPTR)p);
void
glGetLightfv_c(light, pname, p)
	GLenum	light
	GLenum	pname
	void *	p
	CODE:
	glGetLightfv(light, pname, p);

#// 1.0
#//# glGetLightiv_c($light, $pname, (CPTR)p);
void
glGetLightiv_c(light, pname, p)
	GLenum	light
	GLenum	pname
	void *	p
	CODE:
	glGetLightiv(light, pname, p);

#// 1.0
#//# glGetLightfv_s($light, $pname, (PACKED)p);
void
glGetLightfv_s(light, pname, p)
	GLenum	light
	GLenum	pname
	SV *	p
	CODE:
	{
	void * p_s = EL(p, sizeof(GLfloat)*gl_light_count(pname));
	glGetLightfv(light, pname, p_s);
	}

#// 1.0
#//# glGetLightiv_s($light, $pname, (PACKED)p);
void
glGetLightiv_s(light, pname, p)
	GLenum	light
	GLenum	pname
	SV *	p
	CODE:
	{
	void * p_s = EL(p, sizeof(GLint)*gl_light_count(pname));
	glGetLightiv(light, pname, p_s);
	}

#// 1.0
#//# @data = glGetLightfv_p($light, $pname);
void
glGetLightfv_p(light, pname)
	GLenum	light
	GLenum	pname
	PPCODE:
	{
		GLfloat	ret[MAX_GL_LIGHT_COUNT];
		int n = gl_light_count(pname);
		int i;
		glGetLightfv(light, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @data = glGetLightiv_p($light, $pname);
void
glGetLightiv_p(light, pname)
	GLenum	light
	GLenum	pname
	PPCODE:
	{
		GLint	ret[MAX_GL_LIGHT_COUNT];
		int n = gl_light_count(pname);
		int i;
		glGetLightiv(light, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glGetMapiv_c($target, $query, (CPTR)v);
void
glGetMapiv_c(target, query, v)
	GLenum	target
	GLenum	query
	void *	v
	CODE:
	glGetMapiv(target, query, (GLint*)v);

#// 1.0
#//# glGetMapfv_c($target, $query, (CPTR)v);
void
glGetMapfv_c(target, query, v)
	GLenum	target
	GLenum	query
	void *	v
	CODE:
	glGetMapfv(target, query, (GLfloat*)v);

#// 1.0
#//# glGetMapdv_c($target, $query, (CPTR)v);
void
glGetMapdv_c(target, query, v)
	GLenum	target
	GLenum	query
	void *	v
	CODE:
	glGetMapdv(target, query, (GLdouble*)v);

#// 1.0
#//# glGetMapdv_s($target, $query, (PACKED)v);
void
glGetMapdv_s(target, query, v)
	GLenum	target
	GLenum	query
	SV * v
	CODE:
	{
		GLdouble * v_s = EL(v,
			sizeof(GLdouble)*gl_map_count(target, query));
		glGetMapdv(target, query, v_s);
	}

#// 1.0
#//# glGetMapfv_s($target, $query, (PACKED)v);
void
glGetMapfv_s(target, query, v)
	GLenum	target
	GLenum	query
	SV * v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*gl_map_count(target, query));
		glGetMapfv(target, query, v_s);
	}

#// 1.0
#//# glGetMapiv_s($target, $query, (PACKED)v);
void
glGetMapiv_s(target, query, v)
	GLenum	target
	GLenum	query
	SV * v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*gl_map_count(target, query));
		glGetMapiv(target, query, v_s);
	}

#// 1.0
#//# @data = glGetMapfv_p($target, $query);
void
glGetMapfv_p(target, query)
	GLenum	target
	GLenum	query
	PPCODE:
	{
		GLfloat	ret[MAX_GL_MAP_COUNT];
		int n = gl_map_count(target, query);
		int i;
		glGetMapfv(target, query, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @data = glGetMapdv_p($target, $query);
void
glGetMapdv_p(target, query)
	GLenum	target
	GLenum	query
	PPCODE:
	{
		GLdouble	ret[MAX_GL_MAP_COUNT];
		int n = gl_map_count(target, query);
		int i;
		glGetMapdv(target, query, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @data = glGetMapiv_p($target, $query);
void
glGetMapiv_p(target, query)
	GLenum	target
	GLenum	query
	PPCODE:
	{
		GLint	ret[MAX_GL_MAP_COUNT];
		int n = gl_map_count(target, query);
		int i;
		glGetMapiv(target, query, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glGetMaterialfv_c($face, $query, (CPTR)params);
void
glGetMaterialfv_c(face, query, params)
	GLenum	face
	GLenum	query
	void *	params
	CODE:
	glGetMaterialfv(face, query, params);

#// 1.0
#//# glGetMaterialiv_c($face, $query, (CPTR)params);
void
glGetMaterialiv_c(face, query, params)
	GLenum	face
	GLenum	query
	void *	params
	CODE:
	glGetMaterialiv(face, query, params);

#// 1.0
#//# glGetMaterialfv_s($face, $query, (PACKED)params);
void
glGetMaterialfv_s(face, query, params)
	GLenum	face
	GLenum	query
	SV *	params
	CODE:
	{
		GLfloat * params_s = EL(params,
			sizeof(GLfloat)*gl_material_count(query));
		glGetMaterialfv(face, query, params_s);
	}

#// 1.0
#//# glGetMaterialiv_s($face, $query, (PACKED)params);
void
glGetMaterialiv_s(face, query, params)
	GLenum	face
	GLenum	query
	SV *	params
	CODE:
	{
		GLint * params_s = EL(params,
			sizeof(GLfloat)*gl_material_count(query));
		glGetMaterialiv(face, query, params_s);
	}

#// 1.0
#//# @params = glGetMaterialfv_p($face, $query);
void
glGetMaterialfv_p(face, query)
	GLenum	face
	GLenum	query
	PPCODE:
	{
		GLfloat	ret[MAX_GL_MATERIAL_COUNT];
		int n = gl_material_count(query);
		int i;
		glGetMaterialfv(face, query, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @params = glGetMaterialiv_p($face, $query);
void
glGetMaterialiv_p(face, query)
	GLenum	face
	GLenum	query
	PPCODE:
	{
		GLint	ret[MAX_GL_MATERIAL_COUNT];
		int n = gl_material_count(query);
		int i;
		glGetMaterialiv(face, query, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glGetPixelMapfv_c($map, (CPTR)values);
void
glGetPixelMapfv_c(map, values)
	GLenum	map
	void *	values
	CODE:
	glGetPixelMapfv(map, values);

#// 1.0
#//# glGetPixelMapuiv_c($map, (CPTR)values);
void
glGetPixelMapuiv_c(map, values)
	GLenum	map
	void *	values
	CODE:
	glGetPixelMapuiv(map, values);

#// 1.0
#//# glGetPixelMapusv_c($map, (CPTR)values);
void
glGetPixelMapusv_c(map, values)
	GLenum	map
	void *	values
	CODE:
	glGetPixelMapusv(map, values);

#// 1.0
#//# glGetPixelMapfv_s($map, (PACKED)values);
void
glGetPixelMapfv_s(map, values)
	GLenum	map
	SV *	values
	CODE:
	{
	GLfloat * values_s = EL(values, sizeof(GLfloat)* gl_pixelmap_size(map));
	glGetPixelMapfv(map, values_s);
	}

#// 1.0
#//# glGetPixelMapuiv_s($map, (PACKED)values);
void
glGetPixelMapuiv_s(map, values)
	GLenum	map
	SV *	values
	CODE:
	{
	GLuint * values_s = EL(values, sizeof(GLuint)* gl_pixelmap_size(map));
	glGetPixelMapuiv(map, values_s);
	}

#// 1.0
#//# glGetPixelMapusv_s($map, (PACKED)values);
void
glGetPixelMapusv_s(map, values)
	GLenum	map
	SV *	values
	CODE:
	{
	GLushort * values_s = EL(values, sizeof(GLushort)* gl_pixelmap_size(map));
	glGetPixelMapusv(map, values_s);
	}

#// 1.0
#//# @data = glGetPixelMapfv_p($map);
void
glGetPixelMapfv_p(map)
	GLenum	map
	CODE:
	{
		int count = gl_pixelmap_size(map);
		GLfloat * values;
		int i;

		values = malloc(sizeof(GLfloat) * count);

		glGetPixelMapfv(map, values);

		EXTEND(sp, count);

		for(i=0; i<count; i++)
			PUSHs(sv_2mortal(newSVnv(values[i])));

		free(values);
	}

#// 1.0
#//# @data = glGetPixelMapuiv_p($map);
void
glGetPixelMapuiv_p(map)
	GLenum	map
	CODE:
	{
		int count = gl_pixelmap_size(map);
		GLuint * values;
		int i;
		values = malloc(sizeof(GLuint) * count);
		glGetPixelMapuiv(map, values);
		EXTEND(sp, count);
		for(i=0; i<count; i++)
			PUSHs(sv_2mortal(newSViv(values[i])));
		free(values);
	}

#// 1.0
#//# @data = glGetPixelMapusv_p($map);
void
glGetPixelMapusv_p(map)
	GLenum	map
	CODE:
	{
		int count = gl_pixelmap_size(map);
		GLushort * values;
		int i;
		values = malloc(sizeof(GLushort) * count);
		glGetPixelMapusv(map, values);
		EXTEND(sp, count);
		for(i=0; i<count; i++)
			PUSHs(sv_2mortal(newSViv(values[i])));
		free(values);
	}

#// 1.0
#//# glGetPolygonStipple_c((CPTR)mask);
void
glGetPolygonStipple_c(mask)
	void *	mask
	CODE:
	glGetPolygonStipple(mask);

#// 1.0
#//# glGetPolygonStipple_s((PACKED)mask);
void
glGetPolygonStipple_s(mask)
	SV *	mask
	CODE:
	{
	GLubyte * ptr = ELI(mask, 32, 32, GL_COLOR_INDEX, GL_BITMAP, gl_pixelbuffer_unpack);
	glGetPolygonStipple(ptr);
	}

#// 1.0
#//# @mask = glGetPolygonStipple_p();
void
glGetPolygonStipple_p()
	PPCODE:
	{
		void * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_PACK_ROW_LENGTH, 0);
		glPixelStorei(GL_PACK_ALIGNMENT, 1);
		ptr = allocate_image_ST(32, 32, 1, GL_COLOR_INDEX, GL_BITMAP, 0);
		glGetPolygonStipple(ptr);
		sp = unpack_image_ST(sp, ptr, 32, 32, 1,
			GL_COLOR_INDEX, GL_BITMAP, 0);
		free(ptr);
		glPopClientAttrib();
	}

#ifdef GL_VERSION_1_1

#// 1.1
#//# glGetPointerv_c($pname, (CPTR)params);
void
glGetPointerv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glGetPointerv(pname,&params);

#// 1.1
#//# glGetPointerv_s($pname, (PACKED)params);
void
glGetPointerv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
		void ** params_s = EL(params, sizeof(void*));
		glGetPointerv(pname, params_s);
	}

#// 1.1
#//# @params = glGetPointerv_p($pname);
void *
glGetPointerv_p(pname)
	GLenum	pname
	CODE:
	glGetPointerv(pname, &RETVAL);
	OUTPUT:
	RETVAL

#endif

#// 1.0
#//# $string = glGetString($name);
SV *
glGetString(name)
	GLenum	name
	CODE:
	{
		char * c = (char*)glGetString(name);
		if (c)
			RETVAL = newSVpv(c, 0);
		else
			RETVAL = newSVsv(&PL_sv_undef);
	}
	OUTPUT:
	RETVAL

#// 1.0
#//# glGetTexEnvfv_c($target, $pname, (CPTR)params);
void
glGetTexEnvfv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void * params
	CODE:
	glGetTexEnvfv(target, pname, params);

#// 1.0
#//# glGetTexEnviv_c($target, $pname, (CPTR)params);
void
glGetTexEnviv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void * params
	CODE:
	glGetTexEnviv(target, pname, params);

#// 1.0
#//# glGetTexEnvfv_s($target, $pname, (PACKED)params);
void
glGetTexEnvfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV * params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat) * gl_texenv_count(pname));
	glGetTexEnvfv(target, pname, params_s);
	}

#// 1.0
#//# glGetTexEnviv_s($target, $pname, (PACKED)params);
void
glGetTexEnviv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV * params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint) * gl_texenv_count(pname));
	glGetTexEnviv(target, pname, params_s);
	}

#// 1.0
#//# @parames = glGetTexEnvfv_p($target, $pname);
void
glGetTexEnvfv_p(target, pname)
	GLenum	target
	GLenum	pname
	PPCODE:
	{
		GLfloat	ret[MAX_GL_TEXENV_COUNT];
		int n = gl_texenv_count(pname);
		int i;
		glGetTexEnvfv(target, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @parames = glGetTexEnviv_p($target, $pname);
void
glGetTexEnviv_p(target, pname)
	GLenum	target
	GLenum	pname
	PPCODE:
	{
		GLint	ret[MAX_GL_TEXENV_COUNT];
		int n = gl_texenv_count(pname);
		int i;
		glGetTexEnviv(target, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glGetTexGenfv_c($coord, $pname, (CPTR)params);
void
glGetTexGenfv_c(coord, pname, params)
	GLenum	coord
	GLenum	pname
	void *	params
	CODE:
	glGetTexGenfv(coord, pname, params);

#// 1.0
#//# glGetTexGendv_c($coord, $pname, (CPTR)params);
void
glGetTexGendv_c(coord, pname, params)
	GLenum	coord
	GLenum	pname
	void *	params
	CODE:
	glGetTexGendv(coord, pname, params);

#// 1.0
#//# glGetTexGeniv_c($coord, $pname, (CPTR)params);
void
glGetTexGeniv_c(coord, pname, params)
	GLenum	coord
	GLenum	pname
	void *	params
	CODE:
	glGetTexGeniv(coord, pname, params);

#// 1.0
#//# glGetTexGendv_c($coord, $pname, (CPTR)params);
void
glGetTexGendv_s(coord, pname, params)
	GLenum	coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLdouble * params_s = EL(params, sizeof(GLdouble)*gl_texgen_count(pname));
	glGetTexGendv(coord, pname, params_s);
	}

#// 1.0
#//# glGetTexGenfv_s($coord, $pname, (PACKED)params);
void
glGetTexGenfv_s(coord, pname, params)
	GLenum	coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat)*gl_texgen_count(pname));
	glGetTexGenfv(coord, pname, params_s);
	}

#// 1.0
#//# glGetTexGeniv_s($coord, $pname, (PACKED)params);
void
glGetTexGeniv_s(coord, pname, params)
	GLenum	coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*gl_texgen_count(pname));
	glGetTexGeniv(coord, pname, params_s);
	}

#// 1.0
#//# @params = glGetTexGenfv_p($coord, $pname);
void
glGetTexGenfv_p(coord, pname)
	GLenum	coord
	GLenum	pname
	PPCODE:
	{
		GLfloat	ret[MAX_GL_TEXGEN_COUNT];
		int n = gl_texgen_count(pname);
		int i;
		glGetTexGenfv(coord, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @params = glGetTexGendv_p($coord, $pname);
void
glGetTexGendv_p(coord, pname)
	GLenum	coord
	GLenum	pname
	PPCODE:
	{
		GLdouble	ret[MAX_GL_TEXGEN_COUNT];
		int n = gl_texgen_count(pname);
		int i;
		glGetTexGendv(coord, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @params = glGetTexGeniv_p($coord, $pname);
void
glGetTexGeniv_p(coord, pname)
	GLenum	coord
	GLenum	pname
	PPCODE:
	{
		GLint	ret[MAX_GL_TEXGEN_COUNT];
		int n = gl_texgen_count(pname);
		int i;
		glGetTexGeniv(coord, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glGetTexImage_c($target, $level, $format, $type, (CPTR)pixels);
void
glGetTexImage_c(target, level, format, type, pixels)
	GLenum	target
	GLint	level
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glGetTexImage(target, level, format, type, pixels);

#// 1.0
#//# glGetTexImage_s($target, $level, $format, $type, (PACKED)pixels);
void
glGetTexImage_s(target, level, format, type, pixels)
	GLenum	target
	GLint	level
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
		GLint width, height;
		GLvoid * ptr;

		glGetTexLevelParameteriv(target, level,
			GL_TEXTURE_WIDTH, &width);
		glGetTexLevelParameteriv(target, level,
			GL_TEXTURE_HEIGHT, &height);

		ptr = ELI(pixels, width, height, format, type,
			gl_pixelbuffer_unpack);
		glGetTexImage(target, level, format, type, pixels);
	}

#// 1.0
#//# @pixels = glGetTexImage_c($target, $level, $format, $type);
void
glGetTexImage_p(target, level, format, type)
	GLenum	target
	GLint	level
	GLenum	format
	GLenum	type
	PPCODE:
	{
		GLint width, height;
		GLvoid * ptr;

		glGetTexLevelParameteriv(target, level,
			GL_TEXTURE_WIDTH, &width);
		glGetTexLevelParameteriv(target, level,
			GL_TEXTURE_HEIGHT, &height);

		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_PACK_ROW_LENGTH, 0);
		glPixelStorei(GL_PACK_ALIGNMENT, 1);

		ptr = allocate_image_ST(width, height, 1, format, type, 0);
		glGetTexImage(target, level, format, type, ptr);
		sp = unpack_image_ST(sp, ptr, width, height, 1, format, type, 0);

		free(ptr);
		glPopClientAttrib();
	}

#// 1.0
#//# glGetTexLevelParameterfv_c($target, $level, $pname, (CPTR)params);
void
glGetTexLevelParameterfv_c(target, level, pname, params)
	GLenum	target
	GLint	level
	GLenum	pname
	void *	params
	CODE:
	glGetTexLevelParameterfv(target, level, pname, params);

#// 1.0
#//# glGetTexLevelParameteriv_c($target, $level, $pname, (CPTR)params);
void
glGetTexLevelParameteriv_c(target, level, pname, params)
	GLenum	target
	GLint	level
	GLenum	pname
	void *	params
	CODE:
	glGetTexLevelParameteriv(target, level, pname, params);

#// 1.0
#//# glGetTexLevelParameterfv_s($target, $level, $pname, (PACKED)params);
void
glGetTexLevelParameterfv_s(target, level, pname, params)
	GLenum	target
	GLint	level
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat)*1);
	glGetTexLevelParameterfv(target, level, pname, params_s);
	}

#// 1.0
#//# glGetTexLevelParameteriv_s($target, $level, $pname, (PACKED)params);
void
glGetTexLevelParameteriv_s(target, level, pname, params)
	GLenum	target
	GLint	level
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*1);
	glGetTexLevelParameteriv(target, level, pname, params_s);
	}

#// 1.0
#//# @params = glGetTexLevelParameterfv_p($target, $level, $pname);
void
glGetTexLevelParameterfv_p(target, level, pname)
	GLenum	target
	GLint	level
	GLenum	pname
	PPCODE:
	{
		GLfloat	ret;
		glGetTexLevelParameterfv(target, level, pname, &ret);
		PUSHs(sv_2mortal(newSVnv(ret)));
	}

#// 1.0
#//# @params = glGetTexLevelParameteriv_p($target, $level, $pname);
void
glGetTexLevelParameteriv_p(target, level, pname)
	GLenum	target
	GLint	level
	GLenum	pname
	PPCODE:
	{
		GLint	ret;
		glGetTexLevelParameteriv(target, level, pname, &ret);
		PUSHs(sv_2mortal(newSViv(ret)));
	}

#// 1.0
#//# glGetTexParameterfv_c($target, $pname, (CPTR)params);
void
glGetTexParameterfv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void *	params
	CODE:
	glGetTexParameterfv(target, pname, params);

#// 1.0
#//# glGetTexParameteriv_c($target, $pname, (CPTR)params);
void
glGetTexParameteriv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void *	params
	CODE:
	glGetTexParameteriv(target, pname, params);

#// 1.0
#//# glGetTexParameterfv_s($target, $pname, (PACKED)params);
void
glGetTexParameterfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params,
		sizeof(GLfloat)*gl_texparameter_count(pname));
	glGetTexParameterfv(target, pname, params_s);
	}

#// 1.0
#//# glGetTexParameteriv_s($target, $pname, (PACKED)params);
void
glGetTexParameteriv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params,
		sizeof(GLint)*gl_texparameter_count(pname));
	glGetTexParameteriv(target, pname, params_s);
	}

#// 1.0
#//# @params = glGetTexParameterfv_p($target, $pname);
void
glGetTexParameterfv_p(target, pname)
	GLenum	target
	GLenum	pname
	PPCODE:
	{
		GLfloat	ret[MAX_GL_TEXPARAMETER_COUNT];
		int n = gl_texparameter_count(pname);
		int i;
		glGetTexParameterfv(target, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @params = glGetTexParameteriv_p($target, $pname);
void
glGetTexParameteriv_p(target, pname)
	GLenum	target
	GLenum	pname
	PPCODE:
	{
		GLint	ret[MAX_GL_TEXPARAMETER_COUNT];
		int n = gl_texparameter_count(pname);
		int i;
		glGetTexParameteriv(target, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glHint($target, $mode);
void
glHint(target, mode)
	GLenum	target
	GLenum	mode

#// 1.0
#//# glIndexd($c);
void
glIndexd(c)
	GLdouble	c

#// 1.0
#//# glIndexi($c);
void
glIndexi(c)
	GLint	c

#// 1.0
#//# glIndexMask($mask)
void
glIndexMask(mask)
	GLuint	mask


#// 1.0
#//# glInitNames();
void
glInitNames()

#ifdef GL_VERSION_1_1

#// 1.1
#//# glInterleavedArrays_c($format, $stride, (CPTR)pointer);
void
glInterleavedArrays_c(format, stride, pointer)
	GLenum	format
	GLsizei	stride
	void *	pointer
	CODE:
	glInterleavedArrays(format, stride, pointer);

#endif

#// 1.0
#//# glIsEnabled($cap);
GLboolean
glIsEnabled(cap)
	GLenum	cap

#// 1.0
#//# glIsList(list);
GLboolean
glIsList(list)
	GLuint	list

#ifdef GL_VERSION_1_1

#// 1.1
#//# glIsTexture($list);
GLboolean
glIsTexture(list)
	GLuint	list

#endif


#// 1.0
#//# glLightf($light, $pname, $param);
void
glLightf(light, pname, param)
	GLenum	light
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glLighti($light, $pname, $param);
void
glLighti(light, pname, param)
	GLenum	light
	GLenum	pname
	GLint	param

#// 1.0
#//# glLightfv_c($light, $pname, (CPTR)params);
void
glLightfv_c(light, pname, params)
	GLenum	light
	GLenum	pname
	void *	params
	CODE:
	glLightfv(light, pname, params);

#// 1.0
#//# glLightiv_c($light, $pname, (CPTR)params);
void
glLightiv_c(light, pname, params)
	GLenum	light
	GLenum	pname
	void *	params
	CODE:
	glLightiv(light, pname, params);

#// 1.0
#//# glLightfv_s($light, $pname, (PACKED)params);
void
glLightfv_s(light, pname, params)
	GLenum	light
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat)*gl_light_count(pname));
	glLightfv(light, pname, params_s);
	}

#// 1.0
#//# glLightiv_s($light, $pname, (PACKED)params);
void
glLightiv_s(light, pname, params)
	GLenum	light
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*gl_light_count(pname));
	glLightiv(light, pname, params_s);
	}

#// 1.0
#//# glLightfv_p($light, $pname, @params);
void
glLightfv_p(light, pname, ...)
	GLenum	light
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_LIGHT_COUNT];
		int i;
		if ((items-2) != gl_light_count(pname))
			croak("Incorrect number of arguments");
		for(i=2;i<items;i++)
			p[i-2] = (GLfloat)SvNV(ST(i));
		glLightfv(light, pname, &p[0]);
	}

#// 1.0
#//# glLightiv_p($light, $pname, @params);
void
glLightiv_p(light, pname, ...)
	GLenum	light
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_LIGHT_COUNT];
		int i;
		if ((items-2) != gl_light_count(pname))
			croak("Incorrect number of arguments");
		for(i=2;i<items;i++)
			p[i-2] = SvIV(ST(i));
		glLightiv(light, pname, &p[0]);
	}

#// 1.0
#//# glLightModelf($pname, $param);
void
glLightModelf(pname, param)
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glLightModeli($pname, $param);
void
glLightModeli(pname, param)
	GLenum	pname
	GLint	param

#// 1.0
#//# glLightModeliv_c($pname, (CPTR)params);
void
glLightModeliv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glLightModeliv(pname, params);

#// 1.0
#//# glLightModelfv_c($pname, (CPTR)params);
void
glLightModelfv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glLightModelfv(pname, params);

#// 1.0
#//# glLightModeliv_s($pname, (PACKED)params);
void
glLightModeliv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*gl_lightmodel_count(pname));
	glLightModeliv(pname, params_s);
	}

#// 1.0
#//# glLightModelfv_s($pname, (PACKED)params);
void
glLightModelfv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params,
		sizeof(GLfloat)*gl_lightmodel_count(pname));
	glLightModelfv(pname, params_s);
	}

#// 1.0
#//# glLightModelfv_p($pname, @params);
void
glLightModelfv_p(pname, ...)
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_LIGHTMODEL_COUNT];
		int i;
		if ((items-1) != gl_lightmodel_count(pname))
			croak("Incorrect number of arguments");
		for(i=1;i<items;i++)
			p[i-1] = (GLfloat)SvNV(ST(i));
		glLightModelfv(pname, &p[0]);
	}

#// 1.0
#//# glLightModeliv_p($pname, @params);
void
glLightModeliv_p(pname, ...)
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_LIGHTMODEL_COUNT];
		int i;
		if ((items-1) != gl_lightmodel_count(pname))
			croak("Incorrect number of arguments");
		for(i=1;i<items;i++)
			p[i-1] = SvIV(ST(i));
		glLightModeliv(pname, &p[0]);
	}

#// 1.0
#//# glLineStipple($factor, $pattern);
void
glLineStipple(factor, pattern)
	GLint	factor
	GLushort	pattern

#// 1.0
#//# glLineWidth($width);
void
glLineWidth(width)
	GLfloat	width

#// 1.0
#//# glListBase($base);
void
glListBase(base)
	GLuint	base

#// 1.0
#//# glLoadIdentity();
void
glLoadIdentity()

#// 1.0
#//# glLoadMatrixf_c((CPTR)m);
void
glLoadMatrixf_c(m)
	void *	m
	CODE:
	glLoadMatrixf(m);

#// 1.0
#//# glLoadMatrixd_c((CPTR)m);
void
glLoadMatrixd_c(m)
	void *	m
	CODE:
	glLoadMatrixd(m);

#// 1.0
#//# glLoadMatrixf_s((PACKED)m);
void
glLoadMatrixf_s(m)
	SV *	m
	CODE:
	{
	GLfloat * m_s = EL(m, sizeof(GLfloat)*16);
	glLoadMatrixf(m_s);
	}

#// 1.0
#//# glLoadMatrixd_s((PACKED)m);
void
glLoadMatrixd_s(m)
	SV *	m
	CODE:
	{
	GLdouble * m_s = EL(m, sizeof(GLdouble)*16);
	glLoadMatrixd(m_s);
	}

#// 1.0
#//# glLoadMatrixd_p(@m);
void
glLoadMatrixd_p(...)
	CODE:
	{
		GLdouble m[16];
		int i;
		if (items != 16)
			croak("Incorrect number of arguments");
		for (i=0;i<16;i++)
			m[i] = SvNV(ST(i));
		glLoadMatrixd(&m[0]);
	}

#// 1.0
#//# glLoadMatrixf_p(@m);
void
glLoadMatrixf_p(...)
	CODE:
	{
		GLfloat m[16];
		int i;
		if (items != 16)
			croak("Incorrect number of arguments");
		for (i=0;i<16;i++)
			m[i] = (GLfloat)SvNV(ST(i));
		glLoadMatrixf(&m[0]);
	}

#// 1.0
#//# glLoadName($name);
void
glLoadName(name)
	GLuint	name

#// 1.0
#//# glLogicOp($opcode);
void
glLogicOp(opcode)
	GLenum	opcode

#// 1.0
#//# glMap1d_c($target, $u1, $u2, $stride, $order, (CPTR)points);
void
glMap1d_c(target, u1, u2, stride, order, points)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	GLint	stride
	GLint	order
	void *	points
	CODE:
	glMap1d(target, u1, u2, stride, order, points);

#// 1.0
#//# glMap1f_c($target, $u1, $u2, $stride, $order, (CPTR)points);
void
glMap1f_c(target, u1, u2, stride, order, points)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	GLint	stride
	GLint	order
	void *	points
	CODE:
	glMap1f(target, u1, u2, stride, order, points);

#// 1.0
#//# glMap1d_s($target, $u1, $u2, $stride, $order, (PACKED)points);
void
glMap1d_s(target, u1, u2, stride, order, points)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	GLint	stride
	GLint	order
	SV *	points
	CODE:
	{
	GLdouble * points_s = EL(points, 0 /*FIXME*/);
	glMap1d(target, u1, u2, stride, order, points_s);
	}

#// 1.0
#//# glMap1f_s($target, $u1, $u2, $stride, $order, (PACKED)points);
void
glMap1f_s(target, u1, u2, stride, order, points)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	GLint	stride
	GLint	order
	SV *	points
	CODE:
	{
	GLfloat * points_s = EL(points, 0 /*FIXME*/);
	glMap1f(target, u1, u2, stride, order, points_s);
	}

#// 1.0
#//# glMap1d_p($target, $u1, $u2, @points);
#//- Assumes 0 stride
void
glMap1d_p(target, u1, u2, ...)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	CODE:
	{
		int count = items-3;
		GLint order = (items - 3) / gl_map_count(target, GL_COEFF);
		GLdouble * points = malloc(sizeof(GLdouble) * (count+1));
		int i;
		for (i=0;i<count;i++)
			points[i] = SvNV(ST(i+3));
		glMap1d(target, u1, u2, 0, order, points);
		free(points);
	}

#// 1.0
#//# glMap1f_p($target, $u1, $u2, @points);
#//- Assumes 0 stride
void
glMap1f_p(target, u1, u2, ...)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	CODE:
	{
		int count = items-3;
		GLint order = (items - 3) / gl_map_count(target, GL_COEFF);
		GLfloat * points = malloc(sizeof(GLfloat) * (count+1));
		int i;
		for (i=0;i<count;i++)
			points[i] = (GLfloat)SvNV(ST(i+3));
		glMap1f(target, u1, u2, 0, order, points);
		free(points);
	}

#// 1.0
#//# glMap2d_c($target, $u1, $u2, $ustride, $uorder, $v1, $v2, $vstride, $vorder, (CPTR)points);
void
glMap2d_c(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	GLint	ustride
	GLint	uorder
	GLdouble	v1
	GLdouble	v2
	GLint	vstride
	GLint	vorder
	void *	points
	CODE:
	glMap2d(target, u1, u2, ustride, uorder, v1, v2,
		vstride, vorder, points);

#// 1.0
#//# glMap2f_c($target, $u1, $u2, $ustride, $uorder, $v1, $v2, $vstride, $vorder, (CPTR)points);
void
glMap2f_c(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	GLint	ustride
	GLint	uorder
	GLfloat	v1
	GLfloat	v2
	GLint	vstride
	GLint	vorder
	void *	points
	CODE:
	glMap2f(target, u1, u2, ustride, uorder, v1, v2,
		vstride, vorder, points);

#// 1.0
#//# glMap2d_s($target, $u1, $u2, $ustride, $uorder, $v1, $v2, $vstride, $vorder, (PACKED)points);
void
glMap2d_s(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	GLint	ustride
	GLint	uorder
	GLdouble	v1
	GLdouble	v2
	GLint	vstride
	GLint	vorder
	SV *	points
	CODE:
	{
	GLdouble * points_s = EL(points, 0 /*FIXME*/);
	glMap2d(target, u1, u2, ustride, uorder, v1, v2,
		vstride, vorder, points_s);
	}

#// 1.0
#//# glMap2f_s($target, $u1, $u2, $ustride, $uorder, $v1, $v2, $vstride, $vorder, (PACKED)points);
void
glMap2f_s(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	GLint	ustride
	GLint	uorder
	GLfloat	v1
	GLfloat	v2
	GLint	vstride
	GLint	vorder
	SV *	points
	CODE:
	{
	GLfloat * points_s = EL(points, 0 /*FIXME*/);
	glMap2f(target, u1, u2, ustride, uorder, v1, v2,
		vstride, vorder, points_s);
	}

#// 1.0
#//# glMap2d_p($target, $u1, $u2, $uorder, $v1, $v2, @points);
#//- Assumes 0 ustride and vstride
void
glMap2d_p(target, u1, u2, uorder, v1, v2, ...)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	GLint	uorder
	GLdouble	v1
	GLdouble	v2
	CODE:
	{
		int count = items-6;
		GLint vorder = (count / uorder) / gl_map_count(target, GL_COEFF);
		GLdouble * points = malloc(sizeof(GLdouble) * (count+1));
		int i;
		for (i=0;i<count;i++)
			points[i] = SvNV(ST(i+6));
		glMap2d(target, u1, u2, 0, uorder, v1, v2, 0, vorder, points);
		free(points);
	}

#// 1.0
#//# glMap2f_p($target, $u1, $u2, $uorder, $v1, $v2, @points);
#//- Assumes 0 ustride and vstride
void
glMap2f_p(target, u1, u2, uorder, v1, v2, ...)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	GLint	uorder
	GLfloat	v1
	GLfloat	v2
	CODE:
	{
		int count = items-6;
		GLint vorder = (count / uorder) / gl_map_count(target, GL_COEFF);
		GLfloat * points = malloc(sizeof(GLfloat) * (count+1));
		int i;
		for (i=0;i<count;i++)
			points[i] = (GLfloat)SvNV(ST(i+6));
		glMap2f(target, u1, u2, 0, uorder, v1, v2, 0, vorder, points);
		free(points);
	}

#// 1.0
#//# glMapGrid1d($un, $u1, $u2);
void
glMapGrid1d(un, u1, u2)
	GLint	un
	GLdouble	u1
	GLdouble	u2

#// 1.0
#//# glMapGrid1f($un, $u1, $u2);
void
glMapGrid1f(un, u1, u2)
	GLint	un
	GLfloat	u1
	GLfloat	u2

#// 1.0
#//# glMapGrid2d($un, $u1, $u2, $vn, $v1, $v2);
void
glMapGrid2d(un, u1, u2, vn, v1, v2)
	GLint	un
	GLdouble	u1
	GLdouble	u2
	GLint	vn
	GLdouble	v1
	GLdouble	v2

#// 1.0
#//# glMapGrid2f($un, $u1, $u2, $vn, $v1, $v2);
void
glMapGrid2f(un, u1, u2, vn, v1, v2)
	GLint	un
	GLfloat	u1
	GLfloat	u2
	GLint	vn
	GLfloat	v1
	GLfloat	v2

#// 1.0
#//# glMaterialf($face, $pname, $param);
void
glMaterialf(face, pname, param)
	GLenum	face
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glMateriali($face, $pname, $param);
void
glMateriali(face, pname, param)
	GLenum	face
	GLenum	pname
	GLint	param

#// 1.0
#//# glMaterialfv_c($face, $pname, (CPTR)param);
void
glMaterialfv_c(face, pname, param)
	GLenum	face
	GLenum	pname
	void *	param
	CODE:
	glMaterialfv(face, pname, param);

#// 1.0
#//# glMaterialiv_c($face, $pname, (CPTR)param);
void
glMaterialiv_c(face, pname, param)
	GLenum	face
	GLenum	pname
	void *	param
	CODE:
	glMaterialiv(face, pname, param);

#// 1.0
#//# glMaterialfv_s($face, $pname, (PACKED)param);
void
glMaterialfv_s(face, pname, param)
	GLenum	face
	GLenum	pname
	SV *	param
	CODE:
	{
	GLfloat * param_s = EL(param, sizeof(GLfloat)*gl_material_count(pname));
	glMaterialfv(face, pname, param_s);
	}

#// 1.0
#//# glMaterialiv_s($face, $pname, (PACKED)param);
void
glMaterialiv_s(face, pname, param)
	GLenum	face
	GLenum	pname
	SV *	param
	CODE:
	{
	GLint * param_s = EL(param, sizeof(GLint)*gl_material_count(pname));
	glMaterialiv(face, pname, param_s);
	}

#// 1.0
#//# glMaterialfv_s($face, $pname, @param);
void
glMaterialfv_p(face, pname, ...)
	GLenum	face
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_MATERIAL_COUNT];
		int i;
		if ((items-2) != gl_material_count(pname))
			croak("Incorrect number of arguments");
		for(i=2;i<items;i++)
			p[i-2] = (GLfloat)SvNV(ST(i));
		glMaterialfv(face, pname, &p[0]);
	}

#// 1.0
#//# glMaterialiv_s($face, $pname, @param);
void
glMaterialiv_p(face, pname, ...)
	GLenum	face
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_MATERIAL_COUNT];
		int i;
		if ((items-2) != gl_material_count(pname))
			croak("Incorrect number of arguments");
		for(i=2;i<items;i++)
			p[i-2] = SvIV(ST(i));
		glMaterialiv(face, pname, &p[0]);
	}

#// 1.0
#//# glMatrixMode($mode);
void
glMatrixMode(mode)
	GLenum	mode

#// 1.0
#//# glMultMatrixd_p(@m);
void
glMultMatrixd_p(...)
	CODE:
	{
		GLdouble m[16];
		int i;
		if (items != 16)
			croak("Incorrect number of arguments");
		for (i=0;i<16;i++)
			m[i] = SvNV(ST(i));
		glMultMatrixd(&m[0]);
	}

#// 1.0
#//# glMultMatrixf_p(@m);
void
glMultMatrixf_p(...)
	CODE:
	{
		GLfloat m[16];
		int i;
		if (items != 16)
			croak("Incorrect number of arguments");
		for (i=0;i<16;i++)
			m[i] = (GLfloat)SvNV(ST(i));
		glMultMatrixf(&m[0]);
	}

#// 1.0
#//# glNewList($list, $mode);
void
glNewList(list, mode)
	GLuint	list
	GLenum	mode

#// 1.0
#//# glEndList();
void
glEndList()


#// 1.0
#//# glOrtho($left, $right, $bottom, $top, $zNear, $zFar);
void
glOrtho(left, right, bottom, top, zNear, zFar)
	GLdouble	left
	GLdouble	right
	GLdouble	bottom
	GLdouble	top
	GLdouble	zNear
	GLdouble	zFar

#// 1.0
#//# glPassThrough($token);
void
glPassThrough(token)
	GLfloat	token

#// 1.0
#//# glPixelMapfv_c($map, $mapsize, (CPTR)values);
void
glPixelMapfv_c(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	void *	values
	CODE:
	glPixelMapfv(map, mapsize, values);

#// 1.0
#//# glPixelMapuiv_c($map, $mapsize, (CPTR)values);
void
glPixelMapuiv_c(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	void *	values
	CODE:
	glPixelMapuiv(map, mapsize, values);

#// 1.0
#//# glPixelMapusv_c($map, $mapsize, (CPTR)values);
void
glPixelMapusv_c(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	void *	values
	CODE:
	glPixelMapusv(map, mapsize, values);

#// 1.0
#//# glPixelMapfv_s($map, $mapsize, (PACKED)values);
void
glPixelMapfv_s(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	SV *	values
	CODE:
	{
	GLfloat * values_s = EL(values, sizeof(GLfloat)*mapsize);
	glPixelMapfv(map, mapsize, values_s);
	}

#// 1.0
#//# glPixelMapuiv_s($map, $mapsize, (PACKED)values);
void
glPixelMapuiv_s(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	SV *	values
	CODE:
	{
	GLuint * values_s = EL(values, sizeof(GLuint)*mapsize);
	glPixelMapuiv(map, mapsize, values_s);
	}

#// 1.0
#//# glPixelMapusv_s($map, $mapsize, (PACKED)values);
void
glPixelMapusv_s(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	SV *	values
	CODE:
	{
	GLushort * values_s = EL(values, sizeof(GLushort)*mapsize);
	glPixelMapusv(map, mapsize, values_s);
	}

#// 1.0
#//# glPixelMapfv_p($map, @values);
void
glPixelMapfv_p(map, ...)
	GLenum	map
	CODE:
	{
		GLint mapsize = items-1;
		GLfloat * values;
		int i;
		values = malloc(sizeof(GLfloat) * (mapsize+1));
		for (i=0;i<mapsize;i++)
			values[i] = (GLfloat)SvNV(ST(i+1));
		glPixelMapfv(map, mapsize, values);
		free(values);
	}

#// 1.0
#//# glPixelMapuiv_p($map, @values);
void
glPixelMapuiv_p(map, ...)
	GLenum	map
	CODE:
	{
		GLint mapsize = items-1;
		GLuint * values;
		int i;
		values = malloc(sizeof(GLuint) * (mapsize+1));
		for (i=0;i<mapsize;i++)
			values[i] = SvIV(ST(i+1));
		glPixelMapuiv(map, mapsize, values);
		free(values);
	}

#// 1.0
#//# glPixelMapusv_p($map, @values);
void
glPixelMapusv_p(map, ...)
	GLenum	map
	CODE:
	{
		GLint mapsize = items-1;
		GLushort * values;
		int i;
		values = malloc(sizeof(GLushort) * (mapsize+1));
		for (i=0;i<mapsize;i++)
			values[i] = (GLushort)SvIV(ST(i+1));
		glPixelMapusv(map, mapsize, values);
		free(values);
	}

#// 1.0
#//# glPixelStoref($pname, $param);
void
glPixelStoref(pname, param)
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glPixelStorei($pname, $param);
void
glPixelStorei(pname, param)
	GLenum	pname
	GLint	param

#// 1.0
#//# glPixelTransferf($pname, $param);
void
glPixelTransferf(pname, param)
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glPixelTransferi($pname, $param);
void
glPixelTransferi(pname, param)
	GLenum	pname
	GLint	param

#// 1.0
#//# glPixelZoom($xfactor, $yfactor);
void
glPixelZoom(xfactor, yfactor)
	GLfloat	xfactor
	GLfloat	yfactor

#// 1.0
#//# glPointSize($size);
void
glPointSize(size)
	GLfloat	size

#// 1.0
#//# glPolygonMode($face, $mode);
void
glPolygonMode(face, mode)
	GLenum	face
	GLenum	mode

#ifdef GL_VERSION_1_1

#// 1.1
#//# glPolygonOffset($factor, $units);
void
glPolygonOffset(factor, units)
	GLfloat	factor
	GLfloat	units

#endif

#// 1.0
#//# glPolygonStipple_c((CPTR)mask);
void
glPolygonStipple_c(mask)
	void *	mask
	CODE:
	glPolygonStipple(mask);

#// 1.0
#//# glPolygonStipple_s((PACKED)mask);
void
glPolygonStipple_s(mask)
	SV *	mask
	CODE:
	{
	GLubyte * ptr = ELI(mask, 32, 32, GL_COLOR_INDEX, GL_BITMAP, 0);
	glPolygonStipple(ptr);
	}

#//# glPolygonStipple_p(@mask);
void
glPolygonStipple_p(...)
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(0)), items, 32, 32, 1,
		GL_COLOR_INDEX, GL_BITMAP, 0);
	glPolygonStipple(ptr);
	glPopClientAttrib();
	free(ptr);
	}

#ifdef GL_VERSION_1_1

#// 1.1
#//# glPrioritizeTextures_c($n, (CPTR)textures, (CPTR)priorities);
void
glPrioritizeTextures_c(n, textures, priorities)
	GLsizei	n
	void *	textures
	void *	priorities
	CODE:
	glPrioritizeTextures(n, textures, priorities);

#// 1.1
#//# glPrioritizeTextures_s($n, (PACKED)textures, (PACKED)priorities);
void
glPrioritizeTextures_s(n, textures, priorities)
	GLsizei	n
	SV *	textures
	SV *	priorities
	CODE:
	{
	GLuint * textures_s = EL(textures, sizeof(GLuint) * n);
	GLclampf * priorities_s = EL(priorities, sizeof(GLclampf) * n);
	glPrioritizeTextures(n, textures_s, priorities_s);
	}

#// 1.1
#//# glPrioritizeTextures_p(@textureIDs, @priorities);
void
glPrioritizeTextures_p(...)
	CODE:
	{
		GLsizei n = items/2;
		GLuint * textures = malloc(sizeof(GLuint) * (n+1));
		GLclampf * prior = malloc(sizeof(GLclampf) * (n+1));
		int i;

		for (i=0;i<n;i++) {
			textures[i] = SvIV(ST(i * 2 + 0));
			prior[i] = (GLclampf)SvNV(ST(i * 2 + 1));
		}

		glPrioritizeTextures(n, textures, prior);

		free(textures);
		free(prior);
	}

#endif

#// 1.0
#//# glPushAttrib($mask);
void
glPushAttrib(mask)
	GLbitfield	mask

#// 1.0
#//# glPopAttrib();
void
glPopAttrib()

#// 1.0
#//# glPushClientAttrib($mask);
void
glPushClientAttrib(mask)
	GLbitfield	mask

#// 1.0
#//# glPopClientAttrib();
void
glPopClientAttrib()

#// 1.0
#//# glPushMatrix();
void
glPushMatrix()

#// 1.0
#//# glPopMatrix();
void
glPopMatrix()

#// 1.0
#//# glPushName($name);
void
glPushName(name)
	GLuint	name

#// 1.0
#//# glPopName();
void
glPopName()


#// 1.0
#//# glReadBuffer($mode);
void
glReadBuffer(mode)
	GLenum	mode

#// 1.0
#//# glReadPixels_c($x, $y, $width, $height, $format, $type, (CPTR)pixels);
void
glReadPixels_c(x, y, width, height, format, type, pixels)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glReadPixels(x, y, width, height, format, type, pixels);

#// 1.0
#//# glReadPixels_s($x, $y, $width, $height, $format, $type, (PACKED)pixels);
void
glReadPixels_s(x, y, width, height, format, type, pixels)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
		void * ptr = ELI(pixels, width, height,
			format, type, gl_pixelbuffer_pack);
		glReadPixels(x, y, width, height, format, type, ptr);
	}

#// 1.0
#//# @pixels = glReadPixels_p($x, $y, $width, $height, $format, $type);
void
glReadPixels_p(x, y, width, height, format, type)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	PPCODE:
	{
		void * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_PACK_ROW_LENGTH, 0);
		glPixelStorei(GL_PACK_ALIGNMENT, 1);
		ptr = allocate_image_ST(width, height, 1, format, type, 0);
		glReadPixels(x, y, width, height, format, type, ptr);
		sp = unpack_image_ST(sp, ptr, width, height, 1, format, type, 0);
		free(ptr);
		glPopClientAttrib();
	}

#// 1.0
#//# glRecti($x1, $y1, $x2, $y2);
void
glRecti(x1, y1, x2, y2)
	GLint	x1
	GLint	y1
	GLint	x2
	GLint	y2
	ALIAS:
		glRectiv_p = 1


#// 1.0
#//# glRects($x1, $y1, $x2, $y2);
void
glRects(x1, y1, x2, y2)
	GLshort	x1
	GLshort	y1
	GLshort	x2
	GLshort	y2
	ALIAS:
		glRectsv_p = 1

#// 1.0
#//# glRectd($x1, $y1, $x2, $y2);
void
glRectd(x1, y1, x2, y2)
	GLdouble	x1
	GLdouble	y1
	GLdouble	x2
	GLdouble	y2
	ALIAS:
		glRectdv_p = 1

#// 1.0
#//# glRectf($x1, $y1, $x2, $y2);
void
glRectf(x1, y1, x2, y2)
	GLfloat	x1
	GLfloat	y1
	GLfloat	x2
	GLfloat	y2
	ALIAS:
		glRectfv_p = 1


#// 1.0
#//# glRectsv_c((CPTR)v1, (CPTR)v2);
void
glRectsv_c(v1, v2)
	void *	v1
	void *	v2
	CODE:
	glRectsv(v1, v2);

#// 1.0
#//# glRectiv_c((CPTR)v1, (CPTR)v2);
void
glRectiv_c(v1, v2)
	void *	v1
	void *	v2
	CODE:
	glRectiv(v1, v2);

#// 1.0
#//# glRectfv_c((CPTR)v1, (CPTR)v2);
void
glRectfv_c(v1, v2)
	void *	v1
	void *	v2
	CODE:
	glRectfv(v1, v2);

#// 1.0
#//# glRectdv_c((CPTR)v1, (CPTR)v2);
void
glRectdv_c(v1, v2)
	void *	v1
	void *	v2
	CODE:
	glRectdv(v1, v2);

#// 1.0
#//# glRectdv_s((PACKED)v1, (PACKED)v2);
void
glRectdv_s(v1, v2)
	SV *	v1
	SV *	v2
	CODE:
	{
	GLdouble * v1_s = EL(v1, sizeof(GLdouble)*2);
	GLdouble * v2_s = EL(v2, sizeof(GLdouble)*2);
	glRectdv(v1_s, v2_s);
	}

#// 1.0
#//# glRectfv_s((PACKED)v1, (PACKED)v2);
void
glRectfv_s(v1, v2)
	SV *	v1
	SV *	v2
	CODE:
	{
	GLfloat * v1_s = EL(v1, sizeof(GLfloat)*2);
	GLfloat * v2_s = EL(v2, sizeof(GLfloat)*2);
	glRectfv(v1_s, v2_s);
	}

#// 1.0
#//# glRectiv_s((PACKED)v1, (PACKED)v2);
void
glRectiv_s(v1, v2)
	SV *	v1
	SV *	v2
	CODE:
	{
	GLint * v1_s = EL(v1, sizeof(GLint)*2);
	GLint * v2_s = EL(v2, sizeof(GLint)*2);
	glRectiv(v1_s, v2_s);
	}

#// 1.0
#//# glRectsv_s((PACKED)v1, (PACKED)v2);
void
glRectsv_s(v1, v2)
	SV *	v1
	SV *	v2
	CODE:
	{
	GLshort * v1_s = EL(v1, sizeof(GLshort)*2);
	GLshort * v2_s = EL(v2, sizeof(GLshort)*2);
	glRectsv(v1_s, v2_s);
	}

#// 1.0
#//# glRenderMode($mode);
GLint
glRenderMode(mode)
	GLenum	mode

#// 1.0
#//# glRotated($angle, $x, $y, $z);
void
glRotated(angle, x, y, z)
	GLdouble	angle
	GLdouble	x
	GLdouble	y
	GLdouble	z

#// 1.0
#//# glRotatef($angle, $x, $y, $z);
void
glRotatef(angle, x, y, z)
	GLfloat	angle
	GLfloat	x
	GLfloat	y
	GLfloat	z

#// 1.0
#//# glScaled($x, $y, $z);
void
glScaled(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z

#// 1.0
#//# glScalef($x, $y, $z);
void
glScalef(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z

#// 1.0
#//# glScissor($x, $y, $width, $height);
void
glScissor(x, y, width, height)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height

#// 1.0
#//# glSelectBuffer_c($size, (CPTR)list);
void
glSelectBuffer_c(size, list)
	GLsizei	size
	void *	list
	CODE:
	glSelectBuffer(size, list);

#// 1.0
#//# glShadeModel($mode);
void
glShadeModel(mode)
	GLenum	mode

#// 1.0
#//# glStencilFunc($func, $ref, $mask);
void
glStencilFunc(func, ref, mask)
	GLenum	func
	GLint	ref
	GLuint	mask

#// 1.0
#//# glStencilMask($mask);
void
glStencilMask(mask)
	GLuint	mask

#// 1.0
#//# glStencilOp($fail, $zfail, $zpass);
void
glStencilOp(fail, zfail, zpass)
	GLenum	fail
	GLenum	zfail
	GLenum	zpass



#// 1.0
#//# glTexEnvf($target, $pname, $param);
void
glTexEnvf(target, pname, param)
	GLenum	target
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glTexEnvi($target, $pname, $param);
void
glTexEnvi(target, pname, param)
	GLenum	target
	GLenum	pname
	GLint	param

#// 1.0
#//# glTexEnvfv_s(target, pname, (PACKED)params);
void
glTexEnvfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat)*gl_texenv_count(pname));
	glTexEnvfv(target, pname, params_s);
	}

#// 1.0
#//# glTexEnviv_s(target, pname, (PACKED)params);
void
glTexEnviv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*gl_texenv_count(pname));
	glTexEnviv(target, pname, params_s);
	}

#// 1.0
#//# glTexEnvfv_p(target, pname, @params);
void
glTexEnvfv_p(target, pname, ...)
	GLenum	target
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_TEXENV_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texenv_count(pname))
			croak("Incorrect number of arguments");
		for (i=2;i<items;i++)
			p[i-2] = (GLfloat)SvNV(ST(i));
		glTexEnvfv(target, pname, &p[0]);
	}

#// 1.0
#//# glTexEnviv_p(target, pname, @params);
void
glTexEnviv_p(target, pname, ...)
	GLenum	target
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_TEXENV_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texenv_count(pname))
			croak("Incorrect number of arguments");
		for (i=2;i<items;i++)
			p[i-2] = SvIV(ST(i));
		glTexEnviv(target, pname, &p[0]);
	}

#// 1.0
#//# glTexGend($Coord, $pname, $param);
void
glTexGend(Coord, pname, param)
	GLenum	Coord
	GLenum	pname
	GLdouble	param

#// 1.0
#//# glTexGenf($Coord, $pname, $param);
void
glTexGenf(Coord, pname, param)
	GLenum	Coord
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glTexGeni($Coord, $pname, $param);
void
glTexGeni(Coord, pname, param)
	GLenum	Coord
	GLenum	pname
	GLint	param

#// 1.0
#//# glTexGendv_c($Coord, $pname, (CPTR)params);
void
glTexGendv_c(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	void *	params
	CODE:
	glTexGendv(Coord, pname, params);

#// 1.0
#//# glTexGenfv_c($Coord, $pname, (CPTR)params);
void
glTexGenfv_c(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	void *	params
	CODE:
	glTexGenfv(Coord, pname, params);

#// 1.0
#//# glTexGeniv_c($Coord, $pname, (CPTR)params);
void
glTexGeniv_c(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	void *	params
	CODE:
	glTexGeniv(Coord, pname, params);

#// 1.0
#//# glTexGendv_s($Coord, $pname, (PACKED)params);
void
glTexGendv_s(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLdouble * params_s = EL(params,
		sizeof(GLdouble)* gl_texgen_count(pname));
	glTexGendv(Coord, pname, params_s);
	}

#// 1.0
#//# glTexGenfv_s($Coord, $pname, (PACKED)params);
void
glTexGenfv_s(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params,
		sizeof(GLfloat)* gl_texgen_count(pname));
	glTexGenfv(Coord, pname, params_s);
	}

#// 1.0
#//# glTexGeniv_s($Coord, $pname, (PACKED)params);
void
glTexGeniv_s(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params,
		sizeof(GLint)* gl_texgen_count(pname));
	glTexGeniv(Coord, pname, params_s);
	}

#// 1.0
#//# glTexGendv_p($Coord, $pname, @params);
void
glTexGendv_p(Coord, pname, ...)
	GLenum	Coord
	GLenum	pname
	CODE:
	{
		GLdouble p[MAX_GL_TEXGEN_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texgen_count(pname))
			croak("Incorrect number of arguments");
		for (i=2;i<items;i++)
			p[i-2] = SvNV(ST(i));
		glTexGendv(Coord, pname, &p[0]);
	}

#// 1.0
#//# glTexGenfv_p($Coord, $pname, @params);
void
glTexGenfv_p(Coord, pname, ...)
	GLenum	Coord
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_TEXGEN_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texgen_count(pname))
			croak("Incorrect number of arguments");
		for (i=2;i<items;i++)
			p[i-2] = (GLfloat)SvNV(ST(i));
		glTexGenfv(Coord, pname, &p[0]);
	}

#// 1.0
#//# glTexGeniv_p($Coord, $pname, @params);
void
glTexGeniv_p(Coord, pname, ...)
	GLenum	Coord
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_TEXGEN_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texgen_count(pname))
			croak("Incorrect number of arguments");
		for (i=2;i<items;i++)
			p[i-2] = SvIV(ST(i));
		glTexGeniv(Coord, pname, &p[0]);
	}

#// 1.0
#//# glTexImage1D_c($target, $level, $internalformat, $width, $border, $format, $type, (CPTR)pixels);
void
glTexImage1D_c(target, level, internalformat, width, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLint	border
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glTexImage1D(target, level, internalformat,
		width, border, format, type, pixels);

#// 1.0
#//# glTexImage1D_s($target, $level, $internalformat, $width, $border, $format, $type, (PACKED)pixels);
void
glTexImage1D_s(target, level, internalformat, width, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLint	border
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
	GLvoid * ptr = ELI(pixels, width, 1, format, type,
		gl_pixelbuffer_unpack);
	glTexImage1D(target, level, internalformat,
		width, border, format, type, ptr);
	}

#// 1.2
#//# glTexImage1D_p($target, $level, $internalformat, $width, $border, $format, $type, @pixels);
void
glTexImage1D_p(target, level, internalformat, width, border, format, type, ...)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLint	border
	GLenum	format
	GLenum	type
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(7)), items-7, width, 1, 1, format, type, 0);
	glTexImage1D(target, level, internalformat,
		width, border, format, type, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#// 1.0
#//# glTexImage2D_c($target, $level, $internalformat, $width, $height, $border, $format, $type, (CPTR)pixels);
void
glTexImage2D_c(target, level, internalformat, width, height, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLint	border
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glTexImage2D(target, level, internalformat,
		width, height, border, format, type, pixels);

#// 1.0
#//# glTexImage2D_s($target, $level, $internalformat, $width, $height, $border, $format, $type, (PACKED)pixels);
void
glTexImage2D_s(target, level, internalformat, width, height, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLint	border
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
		GLvoid * ptr = NULL;
		if (pixels)
		{
			ptr = ELI(pixels, width, height,
				format, type, gl_pixelbuffer_unpack);
		}
		glTexImage2D(target, level, internalformat,
			width, height, border, format, type, ptr);
	}

#// 1.2
#//# glTexImage2D_p($target, $level, $internalformat, $width, $height, $border, $format, $type, @pixels);
void
glTexImage2D_p(target, level, internalformat, width, height, border, format, type, ...)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLint	border
	GLenum	format
	GLenum	type
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(8)), items-8, width, height,
		1, format, type, 0);
	glTexImage2D(target, level, internalformat,
		width, height, border, format, type, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#ifdef GL_VERSION_1_2

#// 1.2
#//# glTexImage3D_c($target, $level, $internalformat, $width, $height, $depth, $border, $format, $type, (CPTR)pixels);
void
glTexImage3D_c(target, level, internalformat, width, height, depth, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLint	border
	GLenum	format
	GLenum	type
	void *	pixels
	INIT:
		loadProc(glTexImage3D,"glTexImage3D");
	CODE:
		glTexImage3D(target, level, internalformat,
			width, height, depth, border, format, type, pixels);

#// 1.2
#//# glTexImage3D_s($target, $level, $internalformat, $width, $height, $depth, $border, $format, $type, (PACKED)pixels);
void
glTexImage3D_s(target, level, internalformat, width, height, depth, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLint	border
	GLenum	format
	GLenum	type
	SV *	pixels
	INIT:
		loadProc(glTexImage3D,"glTexImage3D");
	CODE:
	{
		GLvoid * ptr = ELI(pixels, width, height, format,
			type, gl_pixelbuffer_unpack);
		glTexImage3D(target, level, internalformat,
			width, height, depth, border, format, type, ptr);
	}

#// 1.2
#//# glTexImage3D_p($target, $level, $internalformat, $width, $height, $depth, $border, $format, $type, @pixels);
void
glTexImage3D_p(target, level, internalformat, width, height, depth, border, format, type, ...)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLint	border
	GLenum	format
	GLenum	type
	INIT:
		loadProc(glTexImage3D,"glTexImage3D");
	CODE:
	{
		GLvoid * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		ptr = pack_image_ST(&(ST(9)), items-9, width, height,
			depth, format, type, 0);
		glTexImage3D(target, level, internalformat,
			width, height, depth, border, format, type, ptr);
		glPopClientAttrib();
		free(ptr);
	}

#endif

#// 1.0
#//# glTexParameterf($target, $pname, $param);
void
glTexParameterf(target, pname, param)
	GLenum	target
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glTexParameteri($target, $pname, $param);
void
glTexParameteri(target, pname, param)
	GLenum	target
	GLenum	pname
	GLint	param

#// 1.0
#//# glTexParameterfv_c($target, $pname, (CPTR)params);
void
glTexParameterfv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void *	params
	CODE:
	glTexParameterfv(target, pname, params);

#// 1.0
#//# glTexParameteriv_c($target, $pname, (CPTR)params);
void
glTexParameteriv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void *	params
	CODE:
	glTexParameteriv(target, pname, params);

#// 1.0
#//# glTexParameterfv_s($target, $pname, (PACKED)params);
void
glTexParameterfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params,
		sizeof(GLfloat)*gl_texparameter_count(pname));
	glTexParameterfv(target, pname, params_s);
	}

#// 1.0
#//# glTexParameteriv_s($target, $pname, (PACKED)params);
void
glTexParameteriv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params,
		sizeof(GLint)*gl_texparameter_count(pname));
	glTexParameteriv(target, pname, params_s);
	}

#// 1.0
#//# glTexParameterfv_p($target, $pname, @params);
void
glTexParameterfv_p(target, pname, ...)
	GLenum	target
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_TEXPARAMETER_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texparameter_count(pname))
			croak("Incorrect number of arguments");
		for(i=0;i<n;i++)
			p[i] = (GLfloat)SvNV(ST(i+2));
		glTexParameterfv(target, pname, &p[0]);
	}

#// 1.0
#//# glTexParameteriv_p($target, $pname, @params);
void
glTexParameteriv_p(target, pname, ...)
	GLenum	target
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_TEXPARAMETER_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texparameter_count(pname))
			croak("Incorrect number of arguments");
		for(i=0;i<n;i++)
			p[i] = SvIV(ST(i+2));
		glTexParameteriv(target, pname, &p[0]);
	}

#ifdef GL_VERSION_1_1

#// 1.1
#//# glTexSubImage1D_c($target, $level, $xoffset, $width, $border, $format, $type, (CPTR)pixels);
void
glTexSubImage1D_c(target, level, xoffset, width, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glTexSubImage1D(target, level, xoffset, width, format, type, pixels);

#// 1.1
#//# glTexSubImage1D_s($target, $level, $xoffset, $width, $border, $format, $type, (PACKED)pixels);
void
glTexSubImage1D_s(target, level, xoffset, width, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
	GLvoid * ptr = ELI(pixels, width, 1, format, type, gl_pixelbuffer_unpack);
	glTexSubImage1D(target, level, xoffset, width, format, type, ptr);
	}

#// 1.1
#//# glTexSubImage1D_p($target, $level, $xoffset, $width, $border, $format, $type, @pixels);
void
glTexSubImage1D_p(target, level, xoffset, width, format, type, ...)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(7)), items-7, width, 1, 1, format, type, 0);
	glTexSubImage1D(target, level, xoffset, width, format, type, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#// 1.1
#//# glTexSubImage2D_c($target, $level, $xoffset, $yoffset, $width, $height, $border, $format, $type, (CPTR)pixels);
void
glTexSubImage2D_c(target, level, xoffset, yoffset, width, height, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glTexSubImage2D(target, level, xoffset, yoffset,
		width, height, format, type, pixels);

#// 1.1
#//# glTexSubImage2D_s($target, $level, $xoffset, $yoffset, $width, $height, $border, $format, $type, (PACKED)pixels);
void
glTexSubImage2D_s(target, level, xoffset, yoffset, width, height, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
	GLvoid * ptr = ELI(pixels, width, height,
		format, type, gl_pixelbuffer_unpack);
	glTexSubImage2D(target, level, xoffset, yoffset,
		width, height, format, type, ptr);
	}

#// 1.1
#//# glTexSubImage2D_c($target, $level, $xoffset, $yoffset, $width, $height, $border, $format, $type, @pixels);
void
glTexSubImage2D_p(target, level, xoffset, yoffset, width, height, format, type, ...)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(8)), items-8, width, height, 1,
		format, type, 0);
	glTexSubImage2D(target, level, xoffset, yoffset,
		width, height, format, type, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#ifdef GL_VERSION_1_2

#// 1.2
#//# glTexSubImage3D_c($target, $level, $xoffset, $yoffset, $zoffset, $width, $height, $depth, $border, $format, $type, (CPTR)pixels);
void
glTexSubImage3D_c(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	zoffset
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLenum	format
	GLenum	type
	void *	pixels
	INIT:
		loadProc(glTexSubImage3D,"glTexSubImage3D");
	CODE:
		glTexSubImage3D(target, level, xoffset, yoffset, zoffset,
			width, height, depth, format, type, pixels);

#// 1.2
#//# glTexSubImage3D_s($target, $level, $xoffset, $yoffset, $zoffset, $width, $height, $depth, $border, $format, $type, (PACKED)pixels);
void
glTexSubImage3D_s(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	zoffset
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLenum	format
	GLenum	type
	SV *	pixels
	INIT:
		loadProc(glTexSubImage3D,"glTexSubImage3D");
	CODE:
	{
		GLvoid * ptr = ELI(pixels, width, height,
			format, type, gl_pixelbuffer_unpack);
		glTexSubImage3D(target, level, xoffset, yoffset, zoffset,
			width, height, depth, format, type, ptr);
	}

#// 1.1
#//# glTexSubImage3D_p($target, $level, $xoffset, $yoffset, $zoffset, $width, $height, $depth, $border, $format, $type, @pixels);
void
glTexSubImage3D_p(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, ...)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	zoffset
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLenum	format
	GLenum	type
	INIT:
		loadProc(glTexSubImage3D,"glTexSubImage3D");
	CODE:
	{
		GLvoid * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		ptr = pack_image_ST(&(ST(10)), items-10, width, height,
			depth, format, type, 0);
		glTexSubImage3D(target, level, xoffset, yoffset, zoffset,
			width, height, depth, format, type, ptr);
		glPopClientAttrib();
		free(ptr);
	}

#endif

#endif

#// 1.0
#//# glTranslated($x, $y, $z);
void
glTranslated(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z

#// 1.0
#//# glTranslatef($x, $y, $z);
void
glTranslatef(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z


#// 1.0
#//# glViewport($x, $y, $width, $height);
void
glViewport(x, y, width, height)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height

# Generated declarations

#//# glVertex2d($x, $y);
void
glVertex2d(x, y)
	GLdouble	x
	GLdouble	y

#//# glVertex2dv_c((CPTR)v);
void
glVertex2dv_c(v)
	void *	v
	CODE:
	glVertex2dv(v);

#//# glVertex2dv_s((PACKED)v);
void
glVertex2dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glVertex2dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex2d
#//# glVertex2dv_p($x, $y);
void
glVertex2dv_p(x, y)
	GLdouble	x
	GLdouble	y
	CODE:
	{
		GLdouble param[2];
		param[0] = x;
		param[1] = y;
		glVertex2dv(param);
	}

#//# glVertex2f($x, $y);
void
glVertex2f(x, y)
	GLfloat	x
	GLfloat	y

#//# glVertex2f_s((PACKED)v);
void
glVertex2fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*2);
		glVertex2fv(v_s);
	}

#//# glVertex2f_s((CPTR)v);
void
glVertex2fv_c(v)
	void *	v
	CODE:
	glVertex2fv(v);

#//!!! Do we really need this?  It duplicates glVertex2f
#//# glVertex2fv_p($x, $y);
void
glVertex2fv_p(x, y)
	GLfloat	x
	GLfloat	y
	CODE:
	{
		GLfloat param[2];
		param[0] = x;
		param[1] = y;
		glVertex2fv(param);
	}

#//# glVertex2i($x, $y);
void
glVertex2i(x, y)
	GLint	x
	GLint	y

#//# glVertex2iv_c((CPTR)v);
void
glVertex2iv_c(v)
	void *	v
	CODE:
	glVertex2iv(v);

#//# glVertex2iv_s((PACKED)v);
void
glVertex2iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*2);
		glVertex2iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex2i
#//# glVertex2iv_p($x, $y);
void
glVertex2iv_p(x, y)
	GLint	x
	GLint	y
	CODE:
	{
		GLint param[2];
		param[0] = x;
		param[1] = y;
		glVertex2iv(param);
	}

#//# glVertex2s($x, $y);
void
glVertex2s(x, y)
	GLshort	x
	GLshort	y

#//# glVertex2sv_c((CPTR)v);
void
glVertex2sv_c(v)
	void *	v
	CODE:
	glVertex2sv(v);

#//# glVertex2sv_c((PACKED)v);
void
glVertex2sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glVertex2sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex2s
#//# glVertex2sv_p($x, $y);
void
glVertex2sv_p(x, y)
	GLshort	x
	GLshort	y
	CODE:
	{
		GLshort param[2];
		param[0] = x;
		param[1] = y;
		glVertex2sv(param);
	}

#endif /* HAVE_GL */
