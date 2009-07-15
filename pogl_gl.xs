/*  Last saved: Tue 14 Jul 2009 05:32:14 PM  */

/*  Copyright (c) 1998 Kenneth Albanowski. All rights reserved.
 *  Copyright (c) 2007 Bob Free. All rights reserved.
 *  This program is free software; you can redistribute it and/or
 *  modify it under the same terms as Perl itself.
 */

/* OpenGL GLX bindings */
#define IN_POGL_GLX_XS

#include <stdio.h>

#include "pgopogl.h"

#ifdef HAVE_GL
#include "gl_util.h"

/* Note: this is caching procs once for all contexts */
/* !!! This should instead cache per context */
#if defined(_WIN32) || (defined(__CYGWIN__) && defined(HAVE_W32API))
#define loadProc(proc,name) \
{ \
  if (!proc) \
  { \
    proc = (void *)wglGetProcAddress(name); \
    if (!proc) croak(name " is not supported by this renderer"); \
  } \
}
#define testProc(proc,name) ((proc) ? 1 : !!(proc = (void *)wglGetProcAddress(name)))
#else /* not using WGL */
#define loadProc(proc,name)
#define testProc(proc,name) 1
#endif /* not defined _WIN32, __CYGWIN__, and HAVE_W32API */
#endif /* defined HAVE_GL */

#ifdef HAVE_GLX
#include "glx_util.h"
#endif /* defined HAVE_GLX */

#ifdef HAVE_GLU
#include "glu_util.h"
#endif /* defined HAVE_GLU */





MODULE = PDL::Graphics::OpenGL::Perl::OpenGL::GL		PACKAGE = PDL::Graphics::OpenGL::Perl::OpenGL





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

#ifdef GL_VERSION_1_1

#// 1.1
#//# glColorPointer_c($size, $type, $stride, (CPTR)pointer);
void
glColorPointer_c(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	void *	pointer
	CODE:
	glColorPointer(size, type, stride, pointer);


#//# glColorPointer_s($size, $type, $stride, (PACKED)pointer);
void
glColorPointer_s(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*size);
		void * pointer_s = EL(pointer, width);
		glColorPointer(size, type, stride, pointer_s);
	}

#//# glColorPointer_p($size, $type, $stride, (OGA)pointer);
void
glColorPointer_p(size, oga)
	GLint	size
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glColorPointer(size, oga->types[0], 0, oga->bind ? 0 : oga->data);
#else
		glColorPointer(size, oga->types[0], 0, oga->data);
#endif
	}

#endif

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

#ifdef GL_VERSION_1_1

#// 1.1
#//# glEdgeFlagPointer_c($stride, (CPTR)pointer);
void
glEdgeFlagPointer_c(stride, pointer)
	GLint	stride
	void *	pointer
	CODE:
	glEdgeFlagPointer(stride, pointer);

#//# glEdgeFlagPointer_s($stride, (PACKED)pointer);
void
glEdgeFlagPointer_s(stride, pointer)
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : sizeof(GLboolean);
		void * pointer_s = EL(pointer, width);
		glEdgeFlagPointer(stride, pointer_s);
	}

#//# glEdgeFlagPointer_p($stride, (OGA)pointer);
void
glEdgeFlagPointer_p(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glEdgeFlagPointer(0, oga->bind ? 0 : oga->data);
#else
		glEdgeFlagPointer(0, oga->data);
#endif
	}

#endif

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

#ifdef GL_VERSION_1_1

#// 1.1
#//# glIndexPointer_c($type, $stride, (CPTR)pointer);
void
glIndexPointer_c(type, stride, pointer)
	GLenum	type
	GLsizei	stride
	void *	pointer
	CODE:
	glIndexPointer(type, stride, pointer);

#//# glIndexPointer_s($type, $stride, (PACKED)pointer);
void
glIndexPointer_s(type, stride, pointer)
	GLenum	type
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : sizeof(type);
		void * pointer_s = EL(pointer, width);
		glIndexPointer(type, stride, pointer_s);
	}

#//# glIndexPointer_p($type, $stride, (OGA)pointer);
void
glIndexPointer_p(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glIndexPointer(oga->types[0], 0, oga->bind ? 0 : oga->data);
#else
		glIndexPointer(oga->types[0], 0, oga->data);
#endif
	}

#endif

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

#ifdef GL_VERSION_1_1

#// 1.1
#//# glNormalPointer_c($type, $stride, (CPTR)pointer);
void
glNormalPointer_c(type, stride, pointer)
	GLenum	type
	GLsizei	stride
	void *	pointer
	CODE:
	glNormalPointer(type, stride, pointer);


#//# glNormalPointer_s($type, $stride, (PACKED)pointer);
void
glNormalPointer_s(type, stride, pointer)
	GLenum	type
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*3);
		void * pointer_s = EL(pointer, width);
		glNormalPointer(type, stride, pointer_s);
	}

#//# glNormalPointer_s($type, $stride, (OGA)pointer);
void
glNormalPointer_p(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glNormalPointer(oga->types[0], 0, oga->bind ? 0 : oga->data);
#else
		glNormalPointer(oga->types[0], 0, oga->data);
#endif
	}

#endif

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


#ifdef GL_VERSION_1_1

#// 1.1
#//# glTexCoordPointer_c($size, $type, $stride, (CPTR)pointer);
void
glTexCoordPointer_c(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	void *	pointer
	CODE:
	glTexCoordPointer(size, type, stride, pointer);

#//# glTexCoordPointer_s($size, $type, $stride, (PACKED)pointer);
void
glTexCoordPointer_s(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*size);
		void * pointer_s = EL(pointer, width);
		glTexCoordPointer(size, type, stride, pointer_s);
	}

#//# glTexCoordPointer_p($size, (OGA)pointer);
void
glTexCoordPointer_p(size, oga)
	GLint	size
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glTexCoordPointer(size, oga->types[0], 0, oga->bind ? 0 : oga->data);
#else
		glTexCoordPointer(size, oga->types[0], 0, oga->data);
#endif
	}

#endif

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


#ifdef GL_VERSION_1_1

#// 1.1
#//# glVertexPointer_c($size, $type, $stride, (CPTR)pointer);
void
glVertexPointer_c(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	void *	pointer
	CODE:
		glVertexPointer(size, type, stride, pointer);

#//# glVertexPointer_s($size, $type, $stride, (PACKED)pointer);
void
glVertexPointer_s(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*size);
		void * pointer_s = EL(pointer, width);
		glVertexPointer(size, type, stride, pointer_s);
	}

#//# glVertexPointer_p($size, $type, $stride, (OGA)pointer);
void
glVertexPointer_p(size, oga)
	GLint	size
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glVertexPointer(size, oga->types[0], 0, oga->bind ? 0 : oga->data);
#else
		glVertexPointer(size, oga->types[0], 0, oga->data);
#endif
	}

#endif

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

#//# glVertex3d($x, $y, $z);
void
glVertex3d(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z

#//# glVertex3dv_c((CPTR)v);
void
glVertex3dv_c(v)
	void *	v
	CODE:
	glVertex3dv(v);

#//# glVertex3dv_s((PACKED)v);
void
glVertex3dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glVertex3dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex3d
#//# glVertex3dv_p($x, $y, $z);
void
glVertex3dv_p(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	CODE:
	{
		GLdouble param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertex3dv(param);
	}

#//# glVertex3f($x, $y, $z);
void
glVertex3f(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z

#//# glVertex3fv_c((CPTR)v);
void
glVertex3fv_c(v)
	void *	v
	CODE:
	glVertex3fv(v);

#//# glVertex3fv_s((PACKED)v);
void
glVertex3fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glVertex3fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex3f
#//# glVertex3fv_p($x, $y, $z);
void
glVertex3fv_p(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	CODE:
	{
		GLfloat param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertex3fv(param);
	}

#//# glVertex3i(x, y, z);
void
glVertex3i(x, y, z)
	GLint	x
	GLint	y
	GLint	z

#//# glVertex3iv_c((CPTR)v);
void
glVertex3iv_c(v)
	void *	v
	CODE:
	glVertex3iv(v);

#//# glVertex3iv_s((PACKED)v);
void
glVertex3iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glVertex3iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex3i
#//# glVertex3iv_p($x, $y, $z);
void
glVertex3iv_p(x, y, z)
	GLint	x
	GLint	y
	GLint	z
	CODE:
	{
		GLint param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertex3iv(param);
	}

#//# glVertex3s($x, $y, $z);
void
glVertex3s(x, y, z)
	GLshort	x
	GLshort	y
	GLshort	z

#//# glVertex3sv_c((CPTR)v);
void
glVertex3sv_c(v)
	void *	v
	CODE:
	glVertex3sv(v);

#//# glVertex3sv_s((PACKED)v);
void
glVertex3sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glVertex3sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex3s
#//# glVertex3sv_p($x, $y, $z);
void
glVertex3sv_p(x, y, z)
	GLshort	x
	GLshort	y
	GLshort	z
	CODE:
	{
		GLshort param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertex3sv(param);
	}

#//# glVertex4d($x, $y, $z, $w);
void
glVertex4d(x, y, z, w)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w

#//# glVertex4dv_c((CPTR)v);
void
glVertex4dv_c(v)
	void *	v
	CODE:
	glVertex4dv(v);

#//# glVertex4dv_s((PACKED)v);
void
glVertex4dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glVertex4dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex4d
#//# glVertex4dv_p($x, $y, $z, $w);
void
glVertex4dv_p(x, y, z, w)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w
	CODE:
	{
		GLdouble param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertex4dv(param);
	}

#//# glVertex4f($x, $y, $z, $w);
void
glVertex4f(x, y, z, w)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w

#//# glVertex4fv_c((CPTR)v);
void
glVertex4fv_c(v)
	void *	v
	CODE:
	glVertex4fv(v);

#//# glVertex4fv_s((PACKED)v);
void
glVertex4fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glVertex4fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex4f
#//# glVertex4fv_p($x, $y, $z, $w);
void
glVertex4fv_p(x, y, z, w)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w
	CODE:
	{
		GLfloat param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertex4fv(param);
	}

#//# glVertex4i($x, $y, $z, $w);
void
glVertex4i(x, y, z, w)
	GLint	x
	GLint	y
	GLint	z
	GLint	w

#//# glVertex4iv_c((CPTR)v);
void
glVertex4iv_c(v)
	void *	v
	CODE:
	glVertex4iv(v);

#//# glVertex4iv_s((PACKED)v);
void
glVertex4iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glVertex4iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex4i
#//# glVertex4iv_p($x, $y, $z, $w);
void
glVertex4iv_p(x, y, z, w)
	GLint	x
	GLint	y
	GLint	z
	GLint	w
	CODE:
	{
		GLint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertex4iv(param);
	}

#//# glVertex4s($x, $y, $z, $w);
void
glVertex4s(x, y, z, w)
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w

#//# glVertex4sv_s((PACKED)v);
void
glVertex4sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glVertex4sv(v_s);
	}

#//# glVertex4sv_c((CPTR)v);
void
glVertex4sv_c(v)
	void *	v
	CODE:
	glVertex4sv(v);

#//!!! Do we really need this?  It duplicates glVertex4s
#//# glVertex4sv_p($x, $y, $z, $w);
void
glVertex4sv_p(x, y, z, w)
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w
	CODE:
	{
		GLshort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertex4sv(param);
	}

#//# glNormal3b($nx, $ny, $nz);
void
glNormal3b(nx, ny, nz)
	GLbyte	nx
	GLbyte	ny
	GLbyte	nz

#//# glNormal3bv_c((CPTR)v);
void
glNormal3bv_c(v)
	void *	v
	CODE:
	glNormal3bv(v);

#//# glNormal3bv_s((PACKED)v);
void
glNormal3bv_s(v)
	SV *	v
	CODE:
	{
		GLbyte * v_s = EL(v, sizeof(GLbyte)*3);
		glNormal3bv(v_s);
	}

#//!!! Do we really need this?  It duplicates glNormal3b
#//# glNormal3bv_p($nx, $ny, $nz);
void
glNormal3bv_p(nx, ny, nz)
	GLbyte	nx
	GLbyte	ny
	GLbyte	nz
	CODE:
	{
		GLbyte param[3];
		param[0] = nx;
		param[1] = ny;
		param[2] = nz;
		glNormal3bv(param);
	}

#//# glNormal3d($nx, $ny, $nz);
void
glNormal3d(nx, ny, nz)
	GLdouble	nx
	GLdouble	ny
	GLdouble	nz

#//# glNormal3dv_c((CPTR)v);
void
glNormal3dv_c(v)
	void *	v
	CODE:
	glNormal3dv(v);

#//# glNormal3dv_s((PACKED)v);
void
glNormal3dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glNormal3dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glNormal3d
#//# glNormal3dv_p($nx, $ny, $nz);
void
glNormal3dv_p(nx, ny, nz)
	GLdouble	nx
	GLdouble	ny
	GLdouble	nz
	CODE:
	{
		GLdouble param[3];
		param[0] = nx;
		param[1] = ny;
		param[2] = nz;
		glNormal3dv(param);
	}

#//# glNormal3f($nx, $ny, $nz);
void
glNormal3f(nx, ny, nz)
	GLfloat	nx
	GLfloat	ny
	GLfloat	nz

#//# glNormal3fv_c((CPTR)v);
void
glNormal3fv_c(v)
	void *	v
	CODE:
	glNormal3fv(v);

#//# glNormal3fv_s((PACKED)v);
void
glNormal3fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glNormal3fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glNormal3f
#//# glNormal3fv_p($nx, $ny, $nz);
void
glNormal3fv_p(nx, ny, nz)
	GLfloat	nx
	GLfloat	ny
	GLfloat	nz
	CODE:
	{
		GLfloat param[3];
		param[0] = nx;
		param[1] = ny;
		param[2] = nz;
		glNormal3fv(param);
	}

#//# glNormal3i($nx, $ny, $nz);
void
glNormal3i(nx, ny, nz)
	GLint	nx
	GLint	ny
	GLint	nz

#//# glNormal3iv_c((CPTR)v);
void
glNormal3iv_c(v)
	void *	v
	CODE:
	glNormal3iv(v);

#//# glNormal3iv_s((PACKED)v);
void
glNormal3iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glNormal3iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glNormal3i
#//# glNormal3iv_p($nx, $ny, $nz);
void
glNormal3iv_p(nx, ny, nz)
	GLint	nx
	GLint	ny
	GLint	nz
	CODE:
	{
		GLint param[3];
		param[0] = nx;
		param[1] = ny;
		param[2] = nz;
		glNormal3iv(param);
	}

#//# glNormal3s($nx, $ny, $nz);
void
glNormal3s(nx, ny, nz)
	GLshort	nx
	GLshort	ny
	GLshort	nz

#//# glNormal3sv_c((CPTR)v);
void
glNormal3sv_c(v)
	void *	v
	CODE:
	glNormal3sv(v);

#//# glNormal3sv_s((PACKED)v);
void
glNormal3sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glNormal3sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glNormal3s
#//# glNormal3sv_p($nx, $ny, $nz);
void
glNormal3sv_p(nx, ny, nz)
	GLshort	nx
	GLshort	ny
	GLshort	nz
	CODE:
	{
		GLshort param[3];
		param[0] = nx;
		param[1] = ny;
		param[2] = nz;
		glNormal3sv(param);
	}

#//# glColor3b($red, $green, $blue);
void
glColor3b(red, green, blue)
	GLbyte	red
	GLbyte	green
	GLbyte	blue

#//# glColor3bv_c((CPTR)v);
void
glColor3bv_c(v)
	void *	v
	CODE:
	glColor3bv(v);

#//# glColor3bv_s((PACKED)v);
void
glColor3bv_s(v)
	SV *	v
	CODE:
	{
		GLbyte * v_s = EL(v, sizeof(GLbyte)*3);
		glColor3bv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3b
#//# glColor3bv_p($red, $green, $blue);
void
glColor3bv_p(red, green, blue)
	GLbyte	red
	GLbyte	green
	GLbyte	blue
	CODE:
	{
		GLbyte param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3bv(param);
	}

#//# glColor3d($red, $green, $blue);
void
glColor3d(red, green, blue)
	GLdouble	red
	GLdouble	green
	GLdouble	blue

#//# glColor3dv_c((CPTR)v);
void
glColor3dv_c(v)
	void *	v
	CODE:
	glColor3dv(v);

#//# glColor3dv_s((PACKED)v);
void
glColor3dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glColor3dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3d
#//# glColor3dv_p($red, $green, $blue);
void
glColor3dv_p(red, green, blue)
	GLdouble	red
	GLdouble	green
	GLdouble	blue
	CODE:
	{
		GLdouble param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3dv(param);
	}

#//# glColor3f($red, $green, $blue);
void
glColor3f(red, green, blue)
	GLfloat	red
	GLfloat	green
	GLfloat	blue

#//# glColor3fv_c((CPTR)v);
void
glColor3fv_c(v)
	void *	v
	CODE:
	glColor3fv(v);

#//# glColor3fv_s((PACKED)v);
void
glColor3fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glColor3fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3s
#//# glColor3sv_p($red, $green, $blue);
void
glColor3fv_p(red, green, blue)
	GLfloat	red
	GLfloat	green
	GLfloat	blue
	CODE:
	{
		GLfloat param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3fv(param);
	}

#//# glColor3i($red, $green, $blue);
void
glColor3i(red, green, blue)
	GLint	red
	GLint	green
	GLint	blue

#//# glColor3iv_c((CPTR)v);
void
glColor3iv_c(v)
	void *	v
	CODE:
	glColor3iv(v);

#//# glColor3iv_s((PACKED)v);
void
glColor3iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glColor3iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3i
#//# glColor3iv_p($red, $green, $blue);
void
glColor3iv_p(red, green, blue)
	GLint	red
	GLint	green
	GLint	blue
	CODE:
	{
		GLint param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3iv(param);
	}

#//# glColor3s($red, $green, $blue);
void
glColor3s(red, green, blue)
	GLshort	red
	GLshort	green
	GLshort	blue

#//# glColor3sv_c((CPTR)v);
void
glColor3sv_c(v)
	void *	v
	CODE:
	glColor3sv(v);

#//# glColor3sv_s((PACKED)v);
void
glColor3sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glColor3sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3s
#//# glColor3sv_p($red, $green, $blue);
void
glColor3sv_p(red, green, blue)
	GLshort	red
	GLshort	green
	GLshort	blue
	CODE:
	{
		GLshort param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3sv(param);
	}

#//# glColor3ub($red, $green, $blue);
void
glColor3ub(red, green, blue)
	GLubyte	red
	GLubyte	green
	GLubyte	blue

#//# glColor3ubv_c((CPTR)v);
void
glColor3ubv_c(v)
	void *	v
	CODE:
	glColor3ubv(v);

#//# glColor3ubv_s((PACKED)v);
void
glColor3ubv_s(v)
	SV *	v
	CODE:
	{
		GLubyte * v_s = EL(v, sizeof(GLubyte)*3);
		glColor3ubv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3ub
#//# glColor3ubv_p($red, $green, $blue);
void
glColor3ubv_p(red, green, blue)
	GLubyte	red
	GLubyte	green
	GLubyte	blue
	CODE:
	{
		GLubyte param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3ubv(param);
	}

#//# glColor3ui($red, $green, $blue);
void
glColor3ui(red, green, blue)
	GLuint	red
	GLuint	green
	GLuint	blue

#//# glColor3uiv_c((CPTR)v);
void
glColor3uiv_c(v)
	void *	v
	CODE:
	glColor3uiv(v);

#//# glColor3uiv_s((PACKED)v);
void
glColor3uiv_s(v)
	SV *	v
	CODE:
	{
		GLuint * v_s = EL(v, sizeof(GLuint)*3);
		glColor3uiv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3ui
#//# glColor3uiv_p($red, $green, $blue);
void
glColor3uiv_p(red, green, blue)
	GLuint	red
	GLuint	green
	GLuint	blue
	CODE:
	{
		GLuint param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3uiv(param);
	}

#//# glColor3us($red, $green, $blue);
void
glColor3us(red, green, blue)
	GLushort	red
	GLushort	green
	GLushort	blue

#//# glColor3usv_c((CPTR)v);
void
glColor3usv_c(v)
	void *	v
	CODE:
	glColor3usv(v);

#//# glColor3usv_s((PACKED)v);
void
glColor3usv_s(v)
	SV *	v
	CODE:
	{
		GLushort * v_s = EL(v, sizeof(GLushort)*3);
		glColor3usv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3us
#//# glColor3usv_p($red, $green, $blue);
void
glColor3usv_p(red, green, blue)
	GLushort	red
	GLushort	green
	GLushort	blue
	CODE:
	{
		GLushort param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3usv(param);
	}

#//# glColor4b($red, $green, $blue, $alpha);
void
glColor4b(red, green, blue, alpha)
	GLbyte	red
	GLbyte	green
	GLbyte	blue
	GLbyte	alpha

#//# glColor4bv_c((CPTR)v);
void
glColor4bv_c(v)
	void *	v
	CODE:
	glColor4bv(v);

#//# glColor4bv_s((PACKED)v);
void
glColor4bv_s(v)
	SV *	v
	CODE:
	{
		GLbyte * v_s = EL(v, sizeof(GLbyte)*4);
		glColor4bv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3b
#//# glColor3bv_p($red, $green, $blue, $alpha);
void
glColor4bv_p(red, green, blue, alpha)
	GLbyte	red
	GLbyte	green
	GLbyte	blue
	GLbyte	alpha
	CODE:
	{
		GLbyte param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4bv(param);
	}

#//# glColor4d($red, $green, $blue, $alpha);
void
glColor4d(red, green, blue, alpha)
	GLdouble	red
	GLdouble	green
	GLdouble	blue
	GLdouble	alpha

#//# glColor4dv_c((CPTR)v);
void
glColor4dv_c(v)
	void *	v
	CODE:
	glColor4dv(v);

#//# glColor4dv_s((PACKED)v);
void
glColor4dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glColor4dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3d
#//# glColor3dv_p($red, $green, $blue, $alpha);
void
glColor4dv_p(red, green, blue, alpha)
	GLdouble	red
	GLdouble	green
	GLdouble	blue
	GLdouble	alpha
	CODE:
	{
		GLdouble param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4dv(param);
	}

#//# glColor4f($red, $green, $blue, $alpha);
void
glColor4f(red, green, blue, alpha)
	GLfloat	red
	GLfloat	green
	GLfloat	blue
	GLfloat	alpha

#//# glColor4fv_c((CPTR)v);
void
glColor4fv_c(v)
	void *	v
	CODE:
	glColor4fv(v);

#//# glColor4fv_s((PACKED)v);
void
glColor4fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glColor4fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3f
#//# glColor3fv_p($red, $green, $blue, $alpha);
void
glColor4fv_p(red, green, blue, alpha)
	GLfloat	red
	GLfloat	green
	GLfloat	blue
	GLfloat	alpha
	CODE:
	{
		GLfloat param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4fv(param);
	}

#//# glColor4i($red, $green, $blue, $alpha);
void
glColor4i(red, green, blue, alpha)
	GLint	red
	GLint	green
	GLint	blue
	GLint	alpha

#//# glColor4iv_c((CPTR)v);
void
glColor4iv_c(v)
	void *	v
	CODE:
	glColor4iv(v);

#//# glColor4iv_s((PACKED)v);
void
glColor4iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glColor4iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3i
#//# glColor3iv_p($red, $green, $blue, $alpha);
void
glColor4iv_p(red, green, blue, alpha)
	GLint	red
	GLint	green
	GLint	blue
	GLint	alpha
	CODE:
	{
		GLint param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4iv(param);
	}

#//# glColor4s($red, $green, $blue, $alpha);
void
glColor4s(red, green, blue, alpha)
	GLshort	red
	GLshort	green
	GLshort	blue
	GLshort	alpha

#//# glColor4sv_c((CPTR)v);
void
glColor4sv_c(v)
	void *	v
	CODE:
	glColor4sv(v);

#//# glColor4sv_s((PACKED)v);
void
glColor4sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glColor4sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3s
#//# glColor3sv_p($red, $green, $blue, $alpha);
void
glColor4sv_p(red, green, blue, alpha)
	GLshort	red
	GLshort	green
	GLshort	blue
	GLshort	alpha
	CODE:
	{
		GLshort param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4sv(param);
	}

#//# glColor4ub(red, green, blue, alpha);
void
glColor4ub(red, green, blue, alpha)
	GLubyte	red
	GLubyte	green
	GLubyte	blue
	GLubyte	alpha

#//# glColor4ubv_c((CPTR)v);
void
glColor4ubv_c(v)
	void *	v
	CODE:
	glColor4ubv(v);

#//# glColor4ubv_s((PACKED)v);
void
glColor4ubv_s(v)
	SV *	v
	CODE:
	{
		GLubyte * v_s = EL(v, sizeof(GLubyte)*4);
		glColor4ubv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3ub
#//# glColor3ubv_p($red, $green, $blue, $alpha);
void
glColor4ubv_p(red, green, blue, alpha)
	GLubyte	red
	GLubyte	green
	GLubyte	blue
	GLubyte	alpha
	CODE:
	{
		GLubyte param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4ubv(param);
	}

#//# glColor4ui($red, $green, $blue, $alpha);
void
glColor4ui(red, green, blue, alpha)
	GLuint	red
	GLuint	green
	GLuint	blue
	GLuint	alpha

#//# glColor4uiv_s((PACKED)v);
void
glColor4uiv_s(v)
	SV *	v
	CODE:
	{
		GLuint * v_s = EL(v, sizeof(GLuint)*4);
		glColor4uiv(v_s);
	}

#//# glColor4uiv_c((CPTR)v);
void
glColor4uiv_c(v)
	void *	v
	CODE:
	glColor4uiv(v);

#//!!! Do we really need this?  It duplicates glColor3ui
#//# glColor3uiv_p($red, $green, $blue, $alpha);
void
glColor4uiv_p(red, green, blue, alpha)
	GLuint	red
	GLuint	green
	GLuint	blue
	GLuint	alpha
	CODE:
	{
		GLuint param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4uiv(param);
	}

#//# glColor4us($red, $green, $blue, $alpha);
void
glColor4us(red, green, blue, alpha)
	GLushort	red
	GLushort	green
	GLushort	blue
	GLushort	alpha

#//# glColor4usv_c((CPTR)v);
void
glColor4usv_c(v)
	void *	v
	CODE:
	glColor4usv(v);

#//# glColor4usv_s((PACKED)v);
void
glColor4usv_s(v)
	SV *	v
	CODE:
	{
		GLushort * v_s = EL(v, sizeof(GLushort)*4);
		glColor4usv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3us
#//# glColor3usv_p($red, $green, $blue, $alpha);
void
glColor4usv_p(red, green, blue, alpha)
	GLushort	red
	GLushort	green
	GLushort	blue
	GLushort	alpha
	CODE:
	{
		GLushort param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4usv(param);
	}

#//# glTexCoord1d($s);
void
glTexCoord1d(s)
	GLdouble	s

#//# glTexCoord1dv_c((CPTR)v);
void
glTexCoord1dv_c(v)
	void *	v
	CODE:
	glTexCoord1dv(v);

#//# glTexCoord1dv_c((PACKED)v);
void
glTexCoord1dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*1);
		glTexCoord1dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord1d
#//# glTexCoord1dv_p($s);
void
glTexCoord1dv_p(s)
	GLdouble	s
	CODE:
	{
		GLdouble param[1];
		param[0] = s;
		glTexCoord1dv(param);
	}

#//# glTexCoord1f($s);
void
glTexCoord1f(s)
	GLfloat	s

#//# glTexCoord1fv_c((CPTR)v);
void
glTexCoord1fv_c(v)
	void *	v
	CODE:
	glTexCoord1fv(v);

#//# glTexCoord1fv_s((PACKED)v);
void
glTexCoord1fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*1);
		glTexCoord1fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord1f
#//# glTexCoord1fv_p($s);
void
glTexCoord1fv_p(s)
	GLfloat	s
	CODE:
	{
		GLfloat param[1];
		param[0] = s;
		glTexCoord1fv(param);
	}

#//# glTexCoord1i($s);
void
glTexCoord1i(s)
	GLint	s

#//# glTexCoord1iv_c((CPTR)v);
void
glTexCoord1iv_c(v)
	void *	v
	CODE:
	glTexCoord1iv(v);

#//# glTexCoord1iv_s((PACKED)v);
void
glTexCoord1iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*1);
		glTexCoord1iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord1i
#//# glTexCoord1iv_p($s);
void
glTexCoord1iv_p(s)
	GLint	s
	CODE:
	{
		GLint param[1];
		param[0] = s;
		glTexCoord1iv(param);
	}

#//# glTexCoord1s($s);
void
glTexCoord1s(s)
	GLshort	s

#//# glTexCoord1sv_c((CPTR)v)
void
glTexCoord1sv_c(v)
	void *	v
	CODE:
	glTexCoord1sv(v);

#//# glTexCoord1sv_s((PACKED)v)
void
glTexCoord1sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*1);
		glTexCoord1sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord1s
#//# glTexCoord1sv_p($s);
void
glTexCoord1sv_p(s)
	GLshort	s
	CODE:
	{
		GLshort param[1];
		param[0] = s;
		glTexCoord1sv(param);
	}

#//# glTexCoord2d($s, $t);
void
glTexCoord2d(s, t)
	GLdouble	s
	GLdouble	t

#//# glTexCoord2dv_c((CPTR)v);
void
glTexCoord2dv_c(v)
	void *	v
	CODE:
	glTexCoord2dv(v);

#//# glTexCoord2dv_s((PACKED)v);
void
glTexCoord2dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glTexCoord2dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord2d
#//# glTexCoord2dv_p($s, $t);
void
glTexCoord2dv_p(s, t)
	GLdouble	s
	GLdouble	t
	CODE:
	{
		GLdouble param[2];
		param[0] = s;
		param[1] = t;
		glTexCoord2dv(param);
	}

#//# glTexCoord2f($s, $t);
void
glTexCoord2f(s, t)
	GLfloat	s
	GLfloat	t

#//# glTexCoord2fv_c((CPTR)v);
void
glTexCoord2fv_c(v)
	void *	v
	CODE:
	glTexCoord2fv(v);

#//# glTexCoord2fv_s((PACKED)v);
void
glTexCoord2fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*2);
		glTexCoord2fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord2f
#//# glTexCoord2fv_p($s, $t);
void
glTexCoord2fv_p(s, t)
	GLfloat	s
	GLfloat	t
	CODE:
	{
		GLfloat param[2];
		param[0] = s;
		param[1] = t;
		glTexCoord2fv(param);
	}

#//# glTexCoord2i($s, $t);
void
glTexCoord2i(s, t)
	GLint	s
	GLint	t

#//# glTexCoord2iv_c((CPTR)v);
void
glTexCoord2iv_c(v)
	void *	v
	CODE:
	glTexCoord2iv(v);

#//# glTexCoord2iv_s((PACKED)v);
void
glTexCoord2iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*2);
		glTexCoord2iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord2i
#//# glTexCoord2iv_p($s, $t);
void
glTexCoord2iv_p(s, t)
	GLint	s
	GLint	t
	CODE:
	{
		GLint param[2];
		param[0] = s;
		param[1] = t;
		glTexCoord2iv(param);
	}

#//# glTexCoord2s($s, $t);
void
glTexCoord2s(s, t)
	GLshort	s
	GLshort	t

#//# glTexCoord2sv_c((CPTR)v);
void
glTexCoord2sv_c(v)
	void *	v
	CODE:
	glTexCoord2sv(v);

#//# glTexCoord2sv_c((PACKED)v);
void
glTexCoord2sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glTexCoord2sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord2s
#//# glTexCoord2sv_p($s, $t);
void
glTexCoord2sv_p(s, t)
	GLshort	s
	GLshort	t
	CODE:
	{
		GLshort param[2];
		param[0] = s;
		param[1] = t;
		glTexCoord2sv(param);
	}

#//# glTexCoord3d($s, $t, $r);
void
glTexCoord3d(s, t, r)
	GLdouble	s
	GLdouble	t
	GLdouble	r

#//# glTexCoord3dv_c((CPTR)v);
void
glTexCoord3dv_c(v)
	void *	v
	CODE:
	glTexCoord3dv(v);

#//# glTexCoord3dv_s((PACKED)v);
void
glTexCoord3dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glTexCoord3dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord3d
#//# glTexCoord3dv_p($s, $t, $r);
void
glTexCoord3dv_p(s, t, r)
	GLdouble	s
	GLdouble	t
	GLdouble	r
	CODE:
	{
		GLdouble param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glTexCoord3dv(param);
	}

#//# glTexCoord3f($s, $t, $r);
void
glTexCoord3f(s, t, r)
	GLfloat	s
	GLfloat	t
	GLfloat	r

#//# glTexCoord3fv_c((CPTR)v);
void
glTexCoord3fv_c(v)
	void *	v
	CODE:
	glTexCoord3fv(v);

#//# glTexCoord3fv_s((PACKED)v);
void
glTexCoord3fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glTexCoord3fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord3f
#//# glTexCoord3fv_p($s, $t, $r);
void
glTexCoord3fv_p(s, t, r)
	GLfloat	s
	GLfloat	t
	GLfloat	r
	CODE:
	{
		GLfloat param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glTexCoord3fv(param);
	}

#//# glTexCoord3i($s, $t, $r);
void
glTexCoord3i(s, t, r)
	GLint	s
	GLint	t
	GLint	r

#//# glTexCoord3iv_c((CPTR)v);
void
glTexCoord3iv_c(v)
	void *	v
	CODE:
	glTexCoord3iv(v);

#//# glTexCoord3iv_s((PACKED)v);
void
glTexCoord3iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glTexCoord3iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord3i
#//# glTexCoord3iv_p($s, $t, $r);
void
glTexCoord3iv_p(s, t, r)
	GLint	s
	GLint	t
	GLint	r
	CODE:
	{
		GLint param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glTexCoord3iv(param);
	}

#//# glTexCoord3s($s, $t, $r);
void
glTexCoord3s(s, t, r)
	GLshort	s
	GLshort	t
	GLshort	r

#//# glTexCoord3sv_s((PACKED)v);
void
glTexCoord3sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glTexCoord3sv(v_s);
	}

#//# glTexCoord3sv_c((CPTR)v);
void
glTexCoord3sv_c(v)
	void *	v
	CODE:
	glTexCoord3sv(v);

#//!!! Do we really need this?  It duplicates glTexCoord3s
#//# glTexCoord3sv_p($s, $t, $r);
void
glTexCoord3sv_p(s, t, r)
	GLshort	s
	GLshort	t
	GLshort	r
	CODE:
	{
		GLshort param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glTexCoord3sv(param);
	}

#//# glTexCoord4d($s, $t, $r, $q);
void
glTexCoord4d(s, t, r, q)
	GLdouble	s
	GLdouble	t
	GLdouble	r
	GLdouble	q

#//# glTexCoord4dv_c((CPTR)v);
void
glTexCoord4dv_c(v)
	void *	v
	CODE:
	glTexCoord4dv(v);

#//# glTexCoord4dv_s((PACKED)v);
void
glTexCoord4dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glTexCoord4dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord4d
#//# glTexCoord4dv_p($s, $t, $r, $q);
void
glTexCoord4dv_p(s, t, r, q)
	GLdouble	s
	GLdouble	t
	GLdouble	r
	GLdouble	q
	CODE:
	{
		GLdouble param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glTexCoord4dv(param);
	}

#//# glTexCoord4f($s, $t, $r, $q);
void
glTexCoord4f(s, t, r, q)
	GLfloat	s
	GLfloat	t
	GLfloat	r
	GLfloat	q

#//# glTexCoord4fv_c((CPTR)v);
void
glTexCoord4fv_c(v)
	void *	v
	CODE:
	glTexCoord4fv(v);

#//# glTexCoord4fv_s((PACKED)v);
void
glTexCoord4fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glTexCoord4fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord4f
#//# glTexCoord4fv_p($s, $t, $r, $q);
void
glTexCoord4fv_p(s, t, r, q)
	GLfloat	s
	GLfloat	t
	GLfloat	r
	GLfloat	q
	CODE:
	{
		GLfloat param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glTexCoord4fv(param);
	}

#//# glTexCoord4i($s, $t, $r, $q);
void
glTexCoord4i(s, t, r, q)
	GLint	s
	GLint	t
	GLint	r
	GLint	q

#//# glTexCoord4iv_c((CPTR)v);
void
glTexCoord4iv_c(v)
	void *	v
	CODE:
	glTexCoord4iv(v);

#//# glTexCoord4iv_s((PACKED)v);
void
glTexCoord4iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glTexCoord4iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord4i
#//# glTexCoord4iv_p($s, $t, $r, $q);
void
glTexCoord4iv_p(s, t, r, q)
	GLint	s
	GLint	t
	GLint	r
	GLint	q
	CODE:
	{
		GLint param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glTexCoord4iv(param);
	}

#//# glTexCoord4s($s, $t, $r, $q);
void
glTexCoord4s(s, t, r, q)
	GLshort	s
	GLshort	t
	GLshort	r
	GLshort	q

#//# glTexCoord4sv_c((CPTR)v);
void
glTexCoord4sv_c(v)
	void *	v
	CODE:
	glTexCoord4sv(v);

#//# glTexCoord4sv_s((PACKED)v);
void
glTexCoord4sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glTexCoord4sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord4s
#//# glTexCoord4sv_p($s, $t, $r, $q);
void
glTexCoord4sv_p(s, t, r, q)
	GLshort	s
	GLshort	t
	GLshort	r
	GLshort	q
	CODE:
	{
		GLshort param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glTexCoord4sv(param);
	}

#//# glRasterPos2d(x, y);
void
glRasterPos2d(x, y)
	GLdouble	x
	GLdouble	y

#//# glRasterPos2dv_c((CPTR)v);
void
glRasterPos2dv_c(v)
	void *	v
	CODE:
	glRasterPos2dv(v);

#//# glRasterPos2dv_s((PACKED)v);
void
glRasterPos2dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glRasterPos2dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos2d
#//# glRasterPos2dv_p($x, $y);
void
glRasterPos2dv_p(x, y)
	GLdouble	x
	GLdouble	y
	CODE:
	{
		GLdouble param[2];
		param[0] = x;
		param[1] = y;
		glRasterPos2dv(param);
	}

#//# glRasterPos2f($x, $y);
void
glRasterPos2f(x, y)
	GLfloat	x
	GLfloat	y

#//# glRasterPos2fv_c((CPTR)v);
void
glRasterPos2fv_c(v)
	void *	v
	CODE:
	glRasterPos2fv(v);

#//# glRasterPos2fv_s((PACKED)v);
void
glRasterPos2fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*2);
		glRasterPos2fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos2f
#//# glRasterPos2fv_p($x, $y);
void
glRasterPos2fv_p(x, y)
	GLfloat	x
	GLfloat	y
	CODE:
	{
		GLfloat param[2];
		param[0] = x;
		param[1] = y;
		glRasterPos2fv(param);
	}

#//# glRasterPos2i($x, $y);
void
glRasterPos2i(x, y)
	GLint	x
	GLint	y

#//# glRasterPos2iv_c((CPTR)v);
void
glRasterPos2iv_c(v)
	void *	v
	CODE:
	glRasterPos2iv(v);

#//# glRasterPos2iv_s((PACKED)v);
void
glRasterPos2iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*2);
		glRasterPos2iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos2i
#//# glRasterPos2iv_p($x, $y);
void
glRasterPos2iv_p(x, y)
	GLint	x
	GLint	y
	CODE:
	{
		GLint param[2];
		param[0] = x;
		param[1] = y;
		glRasterPos2iv(param);
	}

#//# glRasterPos2s($x, $y);
void
glRasterPos2s(x, y)
	GLshort	x
	GLshort	y

#//# glRasterPos2sv_c((CPTR)v);
void
glRasterPos2sv_c(v)
	void *	v
	CODE:
	glRasterPos2sv(v);

#//# glRasterPos2sv_s((PACKED)v);
void
glRasterPos2sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glRasterPos2sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos2s
#//# glRasterPos2sv_p($x, $y);
void
glRasterPos2sv_p(x, y)
	GLshort	x
	GLshort	y
	CODE:
	{
		GLshort param[2];
		param[0] = x;
		param[1] = y;
		glRasterPos2sv(param);
	}

#//# glRasterPos3d($x, $y, $z);
void
glRasterPos3d(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z

#//# glRasterPos3dv_c((CPTR)v);
void
glRasterPos3dv_c(v)
	void *	v
	CODE:
	glRasterPos3dv(v);

#//# glRasterPos3dv_s((PACKED)v);
void
glRasterPos3dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glRasterPos3dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos3d
#//# glRasterPos3dv_p($x, $y, $z);
void
glRasterPos3dv_p(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	CODE:
	{
		GLdouble param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glRasterPos3dv(param);
	}

#//# glRasterPos3f($x, $y, $z);
void
glRasterPos3f(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z

#//# glRasterPos3fv_c((CPTR)v);
void
glRasterPos3fv_c(v)
	void *	v
	CODE:
	glRasterPos3fv(v);

#//# glRasterPos3fv_s((PACKED)v);
void
glRasterPos3fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glRasterPos3fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos3f
#//# glRasterPos3fv_p($x, $y, $z);
void
glRasterPos3fv_p(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	CODE:
	{
		GLfloat param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glRasterPos3fv(param);
	}

#//# glRasterPos3i($x, $y, $z);
void
glRasterPos3i(x, y, z)
	GLint	x
	GLint	y
	GLint	z

#//# glRasterPos3iv_c((CPTR)v);
void
glRasterPos3iv_c(v)
	void *	v
	CODE:
	glRasterPos3iv(v);

#//# glRasterPos3iv_s((PACKED)v);
void
glRasterPos3iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glRasterPos3iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos3i
#//# glRasterPos3iv_p($x, $y, $z);
void
glRasterPos3iv_p(x, y, z)
	GLint	x
	GLint	y
	GLint	z
	CODE:
	{
		GLint param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glRasterPos3iv(param);
	}

#//# glRasterPos3s($x, $y, $z);
void
glRasterPos3s(x, y, z)
	GLshort	x
	GLshort	y
	GLshort	z

#//# glRasterPos3sv_c((CPTR)v);
void
glRasterPos3sv_c(v)
	void *	v
	CODE:
	glRasterPos3sv(v);

#//# glRasterPos3sv_s((PACKED)v);
void
glRasterPos3sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glRasterPos3sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos3s
#//# glRasterPos3sv_p($x, $y, $z);
void
glRasterPos3sv_p(x, y, z)
	GLshort	x
	GLshort	y
	GLshort	z
	CODE:
	{
		GLshort param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glRasterPos3sv(param);
	}

#//# glRasterPos4d($x, $y, $z, $w);
void
glRasterPos4d(x, y, z, w)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w

#//# glRasterPos4dv_c((CPTR)v);
void
glRasterPos4dv_c(v)
	void *	v
	CODE:
	glRasterPos4dv(v);

#//# glRasterPos4dv_s((PACKED)v);
void
glRasterPos4dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glRasterPos4dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos4d
#//# glRasterPos4dv_p($x, $y, $z, $w);
void
glRasterPos4dv_p(x, y, z, w)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w
	CODE:
	{
		GLdouble param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glRasterPos4dv(param);
	}

#//# glRasterPos4f($x, $y, $z, $w);
void
glRasterPos4f(x, y, z, w)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w

#//# glRasterPos4fv_c((CPTR)v);
void
glRasterPos4fv_c(v)
	void *	v
	CODE:
	glRasterPos4fv(v);

#//# glRasterPos4fv_s((PACKED)v);
void
glRasterPos4fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glRasterPos4fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos4f
#//# glRasterPos4fv_p($x, $y, $z, $w);
void
glRasterPos4fv_p(x, y, z, w)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w
	CODE:
	{
		GLfloat param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glRasterPos4fv(param);
	}

#//# glRasterPos4i($x, $y, $z, $w);
void
glRasterPos4i(x, y, z, w)
	GLint	x
	GLint	y
	GLint	z
	GLint	w

#//# glRasterPos4iv_c((CPTR)v);
void
glRasterPos4iv_c(v)
	void *	v
	CODE:
	glRasterPos4iv(v);

#//# glRasterPos4iv_s((PACKED)v);
void
glRasterPos4iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glRasterPos4iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos4i
#//# glRasterPos4iv_p($x, $y, $z, $w);
void
glRasterPos4iv_p(x, y, z, w)
	GLint	x
	GLint	y
	GLint	z
	GLint	w
	CODE:
	{
		GLint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glRasterPos4iv(param);
	}

#//# glRasterPos4s($x, $y, $z, $w);
void
glRasterPos4s(x, y, z, w)
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w

#//# glRasterPos4sv_c((CPTR)v);
void
glRasterPos4sv_c(v)
	void *	v
	CODE:
	glRasterPos4sv(v);

#//# glRasterPos4sv_s((PACKED)v);
void
glRasterPos4sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glRasterPos4sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos4s
#//# glRasterPos4sv_p($x, $y, $z, $w);
void
glRasterPos4sv_p(x, y, z, w)
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w
	CODE:
	{
		GLshort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glRasterPos4sv(param);
	}

# End of generated declarations

################## DEPRECATED EXTENSIONS ########################

#ifdef DEPRECATED
#ifdef GL_EXT_polygon_offset

#// glPolygonOffsetEXT($factor, $bias);
void
glPolygonOffsetEXT(factor, bias)
	GLfloat	factor
	GLfloat	units

#endif

#ifdef GL_EXT_texture_object

#// glIsTextureEXT($list);
GLboolean
glIsTextureEXT(list)
	GLuint	list

#// glPrioritizeTexturesEXT_p(@textureIDs,@priorities);
void
glPrioritizeTexturesEXT_p(...)
	CODE:
	{
		GLsizei n = items/2;
		GLuint * textures = malloc(sizeof(GLuint) * (n+1));
		GLclampf * prior = malloc(sizeof(GLclampf) * (n+1));
		int i;
		
		for (i=0;i<n;i++) {
			textures[i] = SvIV(ST(i * 2 + 0));
			prior[i] = SvNV(ST(i * 2 + 1));
		}
		
		glPrioritizeTextures(n, textures, prior);
		
		free(textures);
		free(prior);
	}

#// glBindTextureEXT($target, $texture);
void
glBindTextureEXT(target, texture)
	GLenum	target
	GLuint	texture

#// glDeleteTexturesEXT_p(@textureIDs);
void
glDeleteTexturesEXT_p(...);
	CODE:
	if (items) {
		GLuint * list = malloc(sizeof(GLuint) * items);
		int i;

		for(i=0;i<items;i++)
			list[i] = SvIV(ST(i));
		
		glDeleteTextures(items, list);
		free(list);
	}

#// @textureIDs = glGenTexturesEXT_p($n);
void
glGenTexturesEXT_p(n)
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

#// ($result,@residences) = glAreTexturesResidentEXT_p(@textureIDs);
void
glAreTexturesResidentEXT_p(...)
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
		
		if (result == GL_TRUE)
			PUSHs(sv_2mortal(newSViv(1)));
		else {
			EXTEND(sp, n+1);
			PUSHs(sv_2mortal(newSViv(0)));
			for(i=0;i<n;i++)
				PUSHs(sv_2mortal(newSViv(residences[i])));
		}
		
		free(textures);
		free(residences);
	}

#endif

#ifdef GL_EXT_copy_texture

#// glCopyTexImage1DEXT($target, $level, $internalFormat, $x, $y, $width, $border);
void
glCopyTexImage1DEXT(target, level, internalFormat, x, y, width, border)
	GLenum	target
	GLint	level
	GLenum	internalFormat
	GLint	x
	GLint	y
	GLsizei	width
	GLint	border

#// glCopyTexImage2DEXT($target, $level, $internalFormat, $x, $y, $width, $height, $border);
void
glCopyTexImage2DEXT(target, level, internalFormat, x, y, width, height, border)
	GLenum	target
	GLint	level
	GLenum	internalFormat
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLint	border

#// glCopyTexSubImage1DEXT($target, $level, $xoffset, $x, $y, $width);
void
glCopyTexSubImage1DEXT(target, level, xoffset, x, y, width)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	x
	GLint	y
	GLsizei	width

#// glCopyTexSubImage2DEXT($target, $level, $xoffset, $yoffset, $x, $y, $width, $height);
void
glCopyTexSubImage2DEXT(target, level, xoffset, yoffset, x, y, width, height)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height

#// glCopyTexSubImage3DEXT($target, $level, $xoffset, $yoffset, $zoffset, $x, $y, $width, $height);
void
glCopyTexSubImage3DEXT(target, level, xoffset, yoffset, zoffset, x, y, width, height)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	zoffset
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height

#endif

#ifdef GL_EXT_subtexture

#// glTexSubImage1DEXT_c($target, $level, $xoffset, $width, $format, $type, (CPTR)pixels);
void
glTexSubImage1DEXT_c(target, level, xoffset, width, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	void *	pixels
	INIT:
		loadProc(glTexSubImage1DEXT,"glTexSubImage1DEXT");
	CODE:
	{
		glTexSubImage1DEXT(target, level, xoffset, width, format, type, pixels);
	}

#// glTexSubImage1DEXT_s($target, $level, $xoffset, $width, $format, $type, (PACKED)pixels);
void
glTexSubImage1DEXT_s(target, level, xoffset, width, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	SV *	pixels
	INIT:
		loadProc(glTexSubImage1DEXT,"glTexSubImage1DEXT");
	CODE:
	{
		GLvoid * ptr = ELI(pixels, width, height,
			format, type, gl_pixelbuffer_unpack);
		glTexSubImage1DEXT(target, level, xoffset, width, format, type, ptr);
	}

#// glTexSubImage1DEXT_p($target, $level, $xoffset, $width, $format, $type, @pixels);
void
glTexSubImage1DEXT_p(target, level, xoffset, width, format, type, ...)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	INIT:
		loadProc(glTexSubImage1DEXT,"glTexSubImage1DEXT");
	CODE:
	{
		GLvoid * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		ptr = pack_image_ST(&(ST(4)), items-4, width, height, 1, format, type, 0);
		glTexSubImage1DEXT(target, level, xoffset, width, format, type, ptr);
		glPopClientAttrib();
		free(ptr);
	}

#// glTexSubImage2DEXT_c($target, $level, $xoffset, $yoffset, $width, $height, $format, $type, (CPTR)pixels);
void
glTexSubImage2DEXT_c(target, level, xoffset, yoffset, width, height, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	void *	pixels
	INIT:
		loadProc(glTexSubImage2DEXT,"glTexSubImage2DEXT");
	CODE:
	{
		glTexSubImage2DEXT(target, level, xoffset, yoffset, width, height,
			format, type, pixels);
	}

#// glTexSubImage2DEXT_s($target, $level, $xoffset, $yoffset, $width, $height, $format, $type, (PACKED)pixels);
void
glTexSubImage2DEXT_s(target, level, xoffset, yoffset, width, height, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	SV *	pixels
	INIT:
		loadProc(glTexSubImage2DEXT,"glTexSubImage2DEXT");
	CODE:
	{
		GLvoid * ptr = ELI(pixels, width, height,
			format, type, gl_pixelbuffer_unpack);
		glTexSubImage2DEXT(target, level, xoffset, yoffset, width, height,
			format, type, ptr);
	}

#// glTexSubImage2DEXT_p($target, $level, $xoffset, $yoffset, $width, $height, $format, $type, @pixels);
void
glTexSubImage2DEXT_p(target, level, xoffset, yoffset, width, height, format, type, ...)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	INIT:
		loadProc(glTexSubImage2DEXT,"glTexSubImage2DEXT");
	CODE:
	{
		GLvoid * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		ptr = pack_image_ST(&(ST(4)), items-4, width, height, 1, format, type, 0);
		glTexSubImage2DEXT(target, level, xoffset, yoffset, width, height,
			format, type, ptr);
		glPopClientAttrib();
		free(ptr);
	}

#endif
#endif //DEPRECATED

################## POST 1.1 VERSIONS ########################

#ifdef GL_VERSION_1_2

#//# glBlendColor($red, $green, $blue, $alpha);
void
glBlendColor(red, green, blue, alpha)
	GLclampf	red
	GLclampf	green
	GLclampf	blue
	GLclampf	alpha
	INIT:
		loadProc(glBlendColor,"glBlendColor");
	CODE:
		glBlendColor(red, green, blue, alpha);

#//# glBlendEquation($mode);
void
glBlendEquation(mode)
	GLenum	mode
	INIT:
		loadProc(glBlendEquation,"glBlendEquation");
	CODE:
		glBlendEquation(mode);


#endif

################## EXTENSIONS ########################

#ifdef GL_EXT_texture3D

#//# glTexImage3DEXT_c($target, $level, $internalformat, $width, $height, $depth, $border, $format, $type, (CPTR)pixels);
void
glTexImage3DEXT_c(target, level, internalformat, width, height, depth, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLenum	internalformat
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLint	border
	GLenum	format
	GLenum	type
	void *	pixels
	INIT:
		loadProc(glTexImage3DEXT,"glTexImage3DEXT");
	CODE:
	{
		glTexImage3DEXT(target, level, internalformat, width, height,
			depth, border, format, type, pixels);
	}

#//# glTexImage3DEXT_s($target, $level, $internalformat, $width, $height, $depth, $border, $format, $type, (PACKED)pixels);
void
glTexImage3DEXT_s(target, level, internalformat, width, height, depth, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLenum	internalformat
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLint	border
	GLenum	format
	GLenum	type
	SV *	pixels
	INIT:
		loadProc(glTexImage3DEXT,"glTexImage3DEXT");
	CODE:
	{
		GLvoid * ptr = ELI(pixels, width, height,
			format, type, gl_pixelbuffer_unpack);
		glTexImage3DEXT(target, level, internalformat, width, height,
			depth, border, format, type, ptr);
	}

#//# glTexImage3DEXT_p($target, $level, $internalformat, $width, $height, $depth, $border, $format, $type, @pixels);
void
glTexImage3DEXT_p(target, level, internalformat, width, height, depth, border, format, type, ...)
	GLenum	target
	GLint	level
	GLenum	internalformat
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLint	border
	GLenum	format
	GLenum	type
	INIT:
		loadProc(glTexImage3DEXT,"glTexImage3DEXT");
	CODE:
	{
		GLvoid * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		ptr = pack_image_ST(&(ST(4)), items-4, width, height, 1, format, type, 0);
		glTexImage3DEXT(target, level, internalformat, width, height,
			depth, border, format, type, ptr);
		glPopClientAttrib();
		free(ptr);
	}

#//# glTexSubImage3DEXT_c($target, $level, $xoffset, $yoffset, $zoffset, $width, $height, $depth, $format, $type, (CPTR)pixels);
void
glTexSubImage3DEXT_c(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels)
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
		loadProc(glTexSubImage3DEXT,"glTexSubImage3DEXT");
	CODE:
	{
		glTexSubImage3DEXT(target, level, xoffset, yoffset, zoffset,
			width, height, depth, format, type, pixels);
	}

#//# glTexSubImage3DEXT_s($target, $level, $xoffset, $yoffset, $zoffset, $width, $height, $depth, $format, $type, (PACKED)pixels);
void
glTexSubImage3DEXT_s(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels)
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
		loadProc(glTexSubImage3DEXT,"glTexSubImage3DEXT");
	CODE:
	{
		GLvoid * ptr = ELI(pixels, width, height,
			format, type, gl_pixelbuffer_unpack);
		glTexSubImage3DEXT(target, level, xoffset, yoffset, zoffset,
			width, height, depth, format, type, ptr);
	}

#//# glTexSubImage3DEXT_p($target, $level, $xoffset, $yoffset, $zoffset, $width, $height, $depth, $format, $type, @pixels);
void
glTexSubImage3DEXT_p(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, ...)
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
		loadProc(glTexSubImage3DEXT,"glTexSubImage3DEXT");
	CODE:
	{
		GLvoid * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		ptr = pack_image_ST(&(ST(4)), items-4, width, height, 1, format, type, 0);
		glTexSubImage3DEXT(target, level, xoffset, yoffset, zoffset,
			width, height, depth, format, type, ptr);
		glPopClientAttrib();
		free(ptr);
	}

#endif


# OS/2 PM implementation misses this function
# It is very hard to test for this, so we check for some other omission...

#if defined(GL_EXT_blend_minmax) && (!defined(GL_SRC_ALPHA_SATURATE) || defined(GL_CONSTANT_COLOR))

#//# glBlendEquationEXT($mode);
void
glBlendEquationEXT(mode)
	GLenum	mode
	INIT:
		loadProc(glBlendEquationEXT,"glBlendEquationEXT");
	CODE:
		glBlendEquationEXT(mode);

#endif

#ifdef GL_EXT_blend_color

#//# glBlendColorEXT($red, $green, $blue, $alpha);
void
glBlendColorEXT(red, green, blue, alpha)
	GLclampf	red
	GLclampf	green
	GLclampf	blue
	GLclampf	alpha
	INIT:
		loadProc(glBlendColorEXT,"glBlendColorEXT");
	CODE:
		glBlendColorEXT(red, green, blue, alpha);

#endif

#ifdef GL_EXT_vertex_array

#//# glArrayElementEXT($i);
void
glArrayElementEXT(i)
	GLint	i
	INIT:
		loadProc(glArrayElementEXT,"glArrayElementEXT");

#//# glDrawArraysEXT($mode, $first, $count);
void
glDrawArraysEXT(mode, first, count)
	GLenum	mode
	GLint	first
	GLsizei	count
	INIT:
		loadProc(glDrawArraysEXT,"glDrawArraysEXT");

#//# glVertexPointerEXT_c($size, $type, $stride, $count, (CPTR)pointer);
void
glVertexPointerEXT_c(size, type, stride, count, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	GLsizei	count
	void *	pointer
	INIT:
		loadProc(glVertexPointerEXT,"glVertexPointerEXT");
	CODE:
		glVertexPointerEXT(size, type, stride, count, pointer);

#//# glVertexPointerEXT_s($size, $type, $stride, $count, (PACKED)pointer);
void
glVertexPointerEXT_s(size, type, stride, count, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	GLsizei	count
	SV *	pointer
	INIT:
		loadProc(glVertexPointerEXT,"glVertexPointerEXT");
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*size);
		void * pointer_s = EL(pointer, width*count);
		glVertexPointerEXT(size, type, stride, count, pointer_s);
	}

#//# glVertexPointerEXT_p($size, (OGA)pointer);
void
glVertexPointerEXT_p(size, oga)
	GLint	size
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	INIT:
		loadProc(glVertexPointerEXT,"glVertexPointerEXT");
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glVertexPointerEXT(size, oga->types[0], 0, oga->item_count/size,
			oga->bind ? 0 : oga->data);
#else
		glVertexPointerEXT(size, oga->types[0], 0, oga->item_count/size,
			oga->data);
#endif
	}

#//# glNormalPointerEXT_c($type, $stride, $count, (CPTR)pointer);
void
glNormalPointerEXT_c(type, stride, count, pointer)
	GLenum	type
	GLsizei	stride
	GLsizei	count
	void *	pointer
	INIT:
		loadProc(glNormalPointerEXT,"glNormalPointerEXT");
	CODE:
		glNormalPointerEXT(type, stride, count, pointer);

#//# glNormalPointerEXT_s($type, $stride, $count, (PACKED)pointer);
void
glNormalPointerEXT_s(type, stride, count, pointer)
	GLenum	type
	GLsizei	stride
	GLsizei	count
	SV *	pointer
	INIT:
		loadProc(glNormalPointerEXT,"glNormalPointerEXT");
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*3);
		void * pointer_s = EL(pointer, width*count);
		glNormalPointerEXT(type, stride, count, pointer_s);
	}

#//# glNormalPointerEXT_p((OGA)pointer);
void
glNormalPointerEXT_p(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	INIT:
		loadProc(glNormalPointerEXT,"glNormalPointerEXT");
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glNormalPointerEXT(oga->types[0], 0, oga->item_count/3,
			oga->bind ? 0 : oga->data);
#else
		glNormalPointerEXT(oga->types[0], 0, oga->item_count/3,
			oga->data);
#endif
	}

#//# glColorPointerEXT_c($size, $type, $stride, $count, (CPTR)pointer);
void
glColorPointerEXT_c(size, type, stride, count, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	GLsizei	count
	void *	pointer
	INIT:
		loadProc(glColorPointerEXT,"glColorPointerEXT");
	CODE:
		glColorPointerEXT(size, type, stride, count, pointer);

#//# glColorPointerEXT_s($size, $type, $stride, $count, (PACKED)pointer);
void
glColorPointerEXT_s(size, type, stride, count, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	GLsizei	count
	SV *	pointer
	INIT:
		loadProc(glColorPointerEXT,"glColorPointerEXT");
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*size);
		void * pointer_s = EL(pointer, width*count);
		glColorPointerEXT(size, type, stride, count, pointer_s);
	}

#//# glColorPointerEXT_p($size, (OGA)pointer);
void
glColorPointerEXT_p(size, oga)
	GLint	size
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	INIT:
		loadProc(glColorPointerEXT,"glColorPointerEXT");
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glColorPointerEXT(size, oga->types[0], 0, oga->item_count/size,
			oga->bind ? 0 : oga->data);
#else
		glColorPointerEXT(size, oga->types[0], 0, oga->item_count/size,
			oga->data);
#endif
	}

#//# glIndexPointerEXT_c($type, $stride, $count, (CPTR)pointer);
void
glIndexPointerEXT_c(type, stride, count, pointer)
	GLenum	type
	GLsizei	stride
	GLsizei	count
	void *	pointer
	INIT:
		loadProc(glIndexPointerEXT,"glIndexPointerEXT");
	CODE:
		glIndexPointerEXT(type, stride, count, pointer);

#//# glIndexPointerEXT_s($type, $stride, $count, (PACKED)pointer);
void
glIndexPointerEXT_s(type, stride, count, pointer)
	GLenum	type
	GLsizei	stride
	GLsizei	count
	SV *	pointer
	INIT:
		loadProc(glIndexPointerEXT,"glIndexPointerEXT");
	CODE:
	{
		int width = stride ? stride : (sizeof(type));
		void * pointer_s = EL(pointer, width*count);
		glIndexPointerEXT(type, stride, count, pointer_s);
	}

#//# glIndexPointerEXT_p((OGA)pointer);
void
glIndexPointerEXT_p(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	INIT:
		loadProc(glIndexPointerEXT,"glIndexPointerEXT");
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glIndexPointerEXT(oga->types[0], 0, oga->item_count,
			oga->bind ? 0 : oga->data);
#else
		glIndexPointerEXT(oga->types[0], 0, oga->item_count,
			oga->data);
#endif
	}

#//# glTexCoordPointerEXT_c($size, $type, $stride, $count, (CPTR)pointer);
void
glTexCoordPointerEXT_c(size, type, stride, count, pointer)
	GLint	size
	GLenum	type
	GLsizei	count
	GLsizei	stride
	void *	pointer
	INIT:
		loadProc(glTexCoordPointerEXT,"glTexCoordPointerEXT");
	CODE:
		glTexCoordPointerEXT(size, type, stride, count, pointer);

#//# glTexCoordPointerEXT_s($size, $type, $stride, $count, (PACKED)pointer);
void
glTexCoordPointerEXT_s(size, type, stride, count, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	GLsizei	count
	SV *	pointer
	INIT:
		loadProc(glTexCoordPointerEXT,"glTexCoordPointerEXT");
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*size);
		void * pointer_s = EL(pointer, width*count);
		glTexCoordPointerEXT(size, type, stride, count, pointer_s);
	}

#//# glTexCoordPointerEXT_p($size, (OGA)pointer);
void
glTexCoordPointerEXT_p(size, oga)
	GLint	size
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	INIT:
		loadProc(glTexCoordPointerEXT,"glTexCoordPointerEXT");
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glTexCoordPointerEXT(size, oga->types[0], 0, oga->item_count/size,
			oga->bind ? 0 : oga->data);
#else
		glTexCoordPointerEXT(size, oga->types[0], 0, oga->item_count/size,
			oga->data);
#endif
	}

#//# glEdgeFlagPointerEXT_c($stride, $count, (CPTR)pointer);
void
glEdgeFlagPointerEXT_c(stride, count, pointer)
	GLint	stride
	GLsizei	count
	void *	pointer
	INIT:
		loadProc(glEdgeFlagPointerEXT,"glEdgeFlagPointerEXT");
	CODE:
		glEdgeFlagPointerEXT(stride, count, pointer);

#//# glEdgeFlagPointerEXT_s($stride, $count, (PACKED)pointer);
void
glEdgeFlagPointerEXT_s(stride, count, pointer)
	GLsizei	stride
	GLsizei	count
	SV *	pointer
	INIT:
		loadProc(glEdgeFlagPointerEXT,"glEdgeFlagPointerEXT");
	CODE:
	{
		int width = stride ? stride : (sizeof(GLboolean));
		void * pointer_s = EL(pointer, width*count);
		glEdgeFlagPointerEXT(stride, count, pointer_s);
	}

#//# glEdgeFlagPointerEXT_p((OGA)pointer);
void
glEdgeFlagPointerEXT_p(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	INIT:
		loadProc(glEdgeFlagPointerEXT,"glEdgeFlagPointerEXT");
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glEdgeFlagPointerEXT(0, oga->item_count, oga->bind ? 0 : oga->data);
#else
		glEdgeFlagPointerEXT(0, oga->item_count, oga->data);
#endif
	}

#endif


#ifdef GL_MESA_window_pos

#// glWindowPos2iMESA($x, $y);
void
glWindowPos2iMESA(x, y)
	GLint	x
	GLint	y

#// glWindowPos2dMESA($x, $y);
void
glWindowPos2dMESA(x, y)
	GLdouble	x
	GLdouble	y

#// glWindowPos3iMESA($x, $y, $z);
void
glWindowPos3iMESA(x, y, z)
	GLint	x
	GLint	y
	GLint	z

#// glWindowPos3dMESA($x, $y, $z);
void
glWindowPos3dMESA(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z

#// glWindowPos4iMESA($x, $y, $z, $w);
void
glWindowPos4iMESA(x, y, z, w)
	GLint	x
	GLint	y
	GLint	z
	GLint	w

#// glWindowPos4dMESA($x, $y, $z, $w);
void
glWindowPos4dMESA(x, y, z, w)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w

#endif

#ifdef GL_MESA_resize_buffers

#// glResizeBuffersMESA();
void
glResizeBuffersMESA()

#endif

#ifdef GL_ARB_draw_buffers

#//# glDrawBuffersARB_c($n,(CPTR)buffers);
void
glDrawBuffersARB_c(n,buffers)
	GLsizei n
	void *	buffers
	INIT:
		loadProc(glDrawBuffersARB,"glDrawBuffersARB");
	CODE:
	{
		glDrawBuffersARB(n,buffers);
	}

#//# glDrawBuffersARB_s($n,(PACKED)buffers);
void
glDrawBuffersARB_s(n,buffers)
	GLsizei n
	SV *	buffers
	INIT:
		loadProc(glDrawBuffersARB,"glDrawBuffersARB");
	CODE:
	{
		void * buffers_s = EL(buffers, sizeof(GLuint)*n);
		glDrawBuffersARB(n,buffers_s);
	}

#//# glDrawBuffersARB_p(@buffers);
void
glDrawBuffersARB_p(...)
	INIT:
		loadProc(glDrawBuffersARB,"glDrawBuffersARB");
	CODE:
	{
		if (items)
		{
			GLuint * list = malloc(sizeof(GLuint) * items);
			int i;
			for (i=0;i<items;i++)
				list[i] = SvIV(ST(i));
			glDrawBuffersARB(items, list);
			free(list);
		}
	}

#endif
#ifdef GL_VERSION_2_0

#//# glDrawBuffers_c($n,(CPTR)buffers);
void
glDrawBuffers_c(n,buffers)
	GLsizei n
	void *	buffers
	CODE:
	{
		glDrawBuffers(n,buffers);
	}

#//# glDrawBuffers_s($n,(PACKED)buffers);
void
glDrawBuffers_s(n,buffers)
	GLsizei n
	SV *	buffers
	CODE:
	{
		void * buffers_s = EL(buffers, sizeof(GLuint)*n);
		glDrawBuffers(n,buffers_s);
	}

#//# glDrawBuffers_p(@buffers);
void
glDrawBuffers_p(...)
	CODE:
	{
		if (items) {
			GLuint * list = malloc(sizeof(GLuint) * items);
			int i;

			for (i=0;i<items;i++)
				list[i] = SvIV(ST(i));

			glDrawBuffers(items, list);
			free(list);
		}
	}

#endif

#ifdef GL_EXT_framebuffer_object

#//# glIsRenderbufferEXT(renderbuffer);
GLboolean
glIsRenderbufferEXT(renderbuffer)
	GLuint	renderbuffer
	INIT:
		loadProc(glIsRenderbufferEXT,"glIsRenderbufferEXT");
	CODE:
	{
		RETVAL = glIsRenderbufferEXT(renderbuffer);
	}
	OUTPUT:
		RETVAL

#//# glBindRenderbufferEXT(target,renderbuffer);
void
glBindRenderbufferEXT(target,renderbuffer)
	GLenum target
	GLuint renderbuffer
	INIT:
		loadProc(glBindRenderbufferEXT,"glBindRenderbufferEXT");
	CODE:
	{
		glBindRenderbufferEXT(target,renderbuffer);
	}

#//# glDeleteRenderbuffersEXT_c($n,(CPTR)renderbuffers);
void
glDeleteRenderbuffersEXT_c(n,renderbuffers)
	GLsizei n
	void *	renderbuffers
	INIT:
		loadProc(glDeleteRenderbuffersEXT,"glDeleteRenderbuffersEXT");
	CODE:
	{
		glDeleteRenderbuffersEXT(n,renderbuffers);
	}

#//# glDeleteRenderbuffersEXT_s($n,(PACKED)renderbuffers);
void
glDeleteRenderbuffersEXT_s(n,renderbuffers)
	GLsizei n
	SV *	renderbuffers
	INIT:
		loadProc(glDeleteRenderbuffersEXT,"glDeleteRenderbuffersEXT");
	CODE:
	{
		void * renderbuffers_s = EL(renderbuffers, sizeof(GLuint)*n);
		glDeleteRenderbuffersEXT(n,renderbuffers_s);
	}

#//# glDeleteRenderbuffersEXT_p(@renderbuffers);
void
glDeleteRenderbuffersEXT_p(...)
	INIT:
		loadProc(glDeleteRenderbuffersEXT,"glDeleteRenderbuffersEXT");
	CODE:
	{
		if (items) {
			GLuint * list = malloc(sizeof(GLuint) * items);
			int i;

			for (i=0;i<items;i++)
				list[i] = SvIV(ST(i));

			glDeleteRenderbuffersEXT(items, list);
			free(list);
		}
	}

#//# glGenRenderbuffersEXT_c($n,(CPTR)renderbuffers);
void
glGenRenderbuffersEXT_c(n,renderbuffers)
	GLsizei n
	void *	renderbuffers
	INIT:
		loadProc(glGenRenderbuffersEXT,"glGenRenderbuffersEXT");
	CODE:
	{
		glGenRenderbuffersEXT(n, renderbuffers);
	}

#//# glGenRenderbuffersEXT_s($n,(PACKED)renderbuffers);
void
glGenRenderbuffersEXT_s(n,renderbuffers)
	GLsizei n
	SV *	renderbuffers
	INIT:
		loadProc(glGenRenderbuffersEXT,"glGenRenderbuffersEXT");
	CODE:
	{
		void * renderbuffers_s = EL(renderbuffers, sizeof(GLuint)*n);
		glGenRenderbuffersEXT(n, renderbuffers_s);
	}

#//# @renderbuffers = glGenRenderbuffersEXT_c($n);
void
glGenRenderbuffersEXT_p(n)
	GLsizei n
	INIT:
		loadProc(glGenRenderbuffersEXT,"glGenRenderbuffersEXT");
	PPCODE:
	if (n)
	{
		GLuint * renderbuffers = malloc(sizeof(GLuint) * n);
		int i;

		glGenRenderbuffersEXT(n, renderbuffers);

		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(renderbuffers[i])));

		free(renderbuffers);
	} 

#//# glRenderbufferStorageEXT($target,$internalformat,$width,$height);
void
glRenderbufferStorageEXT(target,internalformat,width,height)
	GLenum	target
	GLenum	internalformat
	GLsizei	width
	GLsizei	height
	INIT:
		loadProc(glRenderbufferStorageEXT,"glRenderbufferStorageEXT");
	CODE:
	{
		glRenderbufferStorageEXT(target,internalformat,width,height);
	}

#//# glGetRenderbufferParameterivEXT_s($target,$pname,(PACKED)params);
void
glGetRenderbufferParameterivEXT_s(target,pname,params)
	GLenum	target
	GLenum	pname
        SV *	params
	INIT:
		loadProc(glGetRenderbufferParameterivEXT,"glGetRenderbufferParameterivEXT");
	CODE:
	{
		GLint * params_s = EL(params, sizeof(GLint));
		glGetRenderbufferParameterivEXT(target,pname,params_s);
        }

#//# glGetRenderbufferParameterivEXT_c($target,$pname,(CPTR)params);
void
glGetRenderbufferParameterivEXT_c(target,pname,params)
	GLenum	target
	GLenum	pname
        void *	params
	INIT:
		loadProc(glGetRenderbufferParameterivEXT,"glGetRenderbufferParameterivEXT");
	CODE:
	{
		glGetRenderbufferParameterivEXT(target,pname,params);
        }

#//# glIsFramebufferEXT($framebuffer);
GLboolean
glIsFramebufferEXT(framebuffer)
	GLuint framebuffer
	INIT:
		loadProc(glIsFramebufferEXT,"glIsFramebufferEXT");
	CODE:
	{
		RETVAL = glIsFramebufferEXT(framebuffer);
        }
	OUTPUT:
		RETVAL

#//# glBindFramebufferEXT($target,$framebuffer);
void
glBindFramebufferEXT(target,framebuffer)
	GLenum target
	GLuint framebuffer
	INIT:
		loadProc(glBindFramebufferEXT,"glBindFramebufferEXT");
	CODE:
	{
		glBindFramebufferEXT(target,framebuffer);
        }

#//# glDeleteFramebuffersEXT_c($n,(CPTR)framebuffers);
void
glDeleteFramebuffersEXT_c(n,framebuffers)
	GLsizei n
	void *	framebuffers
	INIT:
		loadProc(glDeleteFramebuffersEXT,"glDeleteFramebuffersEXT");
	CODE:
	{
		glDeleteFramebuffersEXT(n,framebuffers);
	}

#//# glDeleteFramebuffersEXT_s($n,(PACKED)framebuffers);
void
glDeleteFramebuffersEXT_s(n,framebuffers)
	GLsizei n
	SV *	framebuffers
	INIT:
		loadProc(glDeleteFramebuffersEXT,"glDeleteFramebuffersEXT");
	CODE:
	{
		void * framebuffers_s = EL(framebuffers, sizeof(GLuint)*n);
		glDeleteFramebuffersEXT(n,framebuffers_s);
	}

#//# glDeleteFramebuffersEXT_p(@framebuffers);
void
glDeleteFramebuffersEXT_p(...)
	INIT:
		loadProc(glDeleteFramebuffersEXT,"glDeleteFramebuffersEXT");
	CODE:
	{
		if (items) {
			GLuint * list = malloc(sizeof(GLuint) * items);
			int i;

			for(i=0;i<items;i++)
				list[i] = SvIV(ST(i));
		
			glDeleteFramebuffersEXT(items, list);
			free(list);
		}
	}

#//# glGenFramebuffersEXT_c($n,(CPTR)framebuffers);
void
glGenFramebuffersEXT_c(n,framebuffers)
	GLsizei n
	void *	framebuffers
	INIT:
		loadProc(glGenFramebuffersEXT,"glGenFramebuffersEXT");
	CODE:
	{
		glGenFramebuffersEXT(n,framebuffers);
	}

#//# glGenFramebuffersEXT_s($n,(PACKED)framebuffers);
void
glGenFramebuffersEXT_s(n,framebuffers)
	GLsizei n
	SV *	framebuffers
	INIT:
		loadProc(glGenFramebuffersEXT,"glGenFramebuffersEXT");
	CODE:
	{
		void * framebuffers_s = EL(framebuffers, sizeof(GLuint)*n);
		glGenFramebuffersEXT(n,framebuffers_s);
	}

#//# @framebuffers = glGenFramebuffersEXT_c($n);
void
glGenFramebuffersEXT_p(n)
	GLsizei n
	INIT:
		loadProc(glGenFramebuffersEXT,"glGenFramebuffersEXT");
	PPCODE:
	if (n)
	{
		GLuint * framebuffers = malloc(sizeof(GLuint) * n);
		int i;
		
		glGenFramebuffersEXT(n, framebuffers);

		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(framebuffers[i])));

		free(framebuffers);
	} 

#//# glCheckFramebufferStatusEXT($target);
GLenum
glCheckFramebufferStatusEXT(target)
	GLenum target
	INIT:
		loadProc(glCheckFramebufferStatusEXT,"glCheckFramebufferStatusEXT");
	CODE:
	{
		RETVAL = glCheckFramebufferStatusEXT(target);
	}
	OUTPUT:
		RETVAL

#//# glFramebufferTexture1DEXT($target,$attachment,$textarget,$texture,$level);
void
glFramebufferTexture1DEXT(target,attachment,textarget,texture,level)
	GLenum target
	GLenum attachment
	GLenum textarget
	GLuint texture
	GLint level
	INIT:
		loadProc(glFramebufferTexture1DEXT,"glFramebufferTexture1DEXT");
	CODE:
	{
		glFramebufferTexture1DEXT(target,attachment,textarget,texture,level);
	}

#//# glFramebufferTexture2DEXT($target,$attachment,$textarget,$texture,$level);
void
glFramebufferTexture2DEXT(target,attachment,textarget,texture,level)
	GLenum target
	GLenum attachment
	GLenum textarget
	GLuint texture
	GLint level
	INIT:
		loadProc(glFramebufferTexture2DEXT,"glFramebufferTexture2DEXT");
	CODE:
	{
		glFramebufferTexture2DEXT(target,attachment,textarget,texture,level);
	}

#//# glFramebufferTexture3DEXT($target,$attachment,$textarget,$texture,$level,$zoffset)'
void
glFramebufferTexture3DEXT(target,attachment,textarget,texture,level,zoffset)
	GLenum target
	GLenum attachment
	GLenum textarget
	GLuint texture
	GLint level
	GLint zoffset
	INIT:
		loadProc(glFramebufferTexture3DEXT,"glFramebufferTexture3DEXT");
	CODE:
	{
		glFramebufferTexture3DEXT(target,attachment,textarget,texture,level,zoffset);
	}

#//# glFramebufferRenderbufferEXT($target,$attachment,$renderbuffertarget,$renderbuffer);
void
glFramebufferRenderbufferEXT(target,attachment,renderbuffertarget,renderbuffer)
	GLenum target
	GLenum attachment
	GLenum renderbuffertarget
	GLuint renderbuffer
	INIT:
		loadProc(glFramebufferRenderbufferEXT,"glFramebufferRenderbufferEXT");
	CODE:
	{
		glFramebufferRenderbufferEXT(target,attachment,renderbuffertarget,renderbuffer);
	}

#//# glGetFramebufferAttachmentParameterivEXT_s($target,$attachment,$pname,(PACKED)params);
void
glGetFramebufferAttachmentParameterivEXT_s(target,attachment,pname,params)
	GLenum	target
	GLenum	attachment
	GLenum	pname
        SV *	params
	INIT:
		loadProc(glGetFramebufferAttachmentParameterivEXT,"glGetFramebufferAttachmentParameterivEXT");
	CODE:
	{
		GLint * params_s = EL(params, sizeof(GLint));
		glGetFramebufferAttachmentParameterivEXT(target,attachment,pname,params_s);
        }

#//# glGetFramebufferAttachmentParameterivEXT_c($target,$attachment,$pname,(CPTR)params);
void
glGetFramebufferAttachmentParameterivEXT_c(target,attachment,pname,params)
	GLenum	target
	GLenum	attachment
	GLenum	pname
        void *	params
	INIT:
		loadProc(glGetFramebufferAttachmentParameterivEXT,"glGetFramebufferAttachmentParameterivEXT");
	CODE:
	{
		glGetFramebufferAttachmentParameterivEXT(target,attachment,pname,params);
        }

#//# glGenerateMipmapEXT($target);
void
glGenerateMipmapEXT(target)
	GLenum target
	INIT:
		loadProc(glGenerateMipmapEXT,"glGenerateMipmapEXT");
	CODE:
	{
		glGenerateMipmapEXT(target);
        }

#endif


#ifdef GL_ARB_vertex_buffer_object

#//# glBindBufferARB($target,$buffer);
void
glBindBufferARB(target,buffer)
	GLenum target
	GLuint buffer
	INIT:
		loadProc(glBindBufferARB,"glBindBufferARB");
	CODE:
	{
		glBindBufferARB(target,buffer);
	}

#//# glDeleteBuffersARB_c($n,(CPTR)buffers);
void
glDeleteBuffersARB_c(n,buffers)
	GLsizei	n
	void *	buffers
	INIT:
		loadProc(glDeleteBuffersARB,"glDeleteBuffersARB");
	CODE:
	{
		glDeleteBuffersARB(n,buffers);
	}

#//# glDeleteBuffersARB_s($n,(PACKED)buffers);
void
glDeleteBuffersARB_s(n,buffers)
	GLsizei n
	SV *	buffers
	INIT:
		loadProc(glDeleteBuffersARB,"glDeleteBuffersARB");
	CODE:
	{
		void * buffers_s = EL(buffers, sizeof(GLuint)*n);
		glDeleteBuffersARB(n,buffers_s);
	}

#//# glDeleteBuffersARB_p(@buffers);
void
glDeleteBuffersARB_p(...)
	INIT:
		loadProc(glDeleteBuffersARB,"glDeleteBuffersARB");
	CODE:
	{
		if (items) {
			GLuint * list = malloc(sizeof(GLuint) * items);
			int i;

			for (i=0;i<items;i++)
				list[i] = SvIV(ST(i));

			glDeleteBuffersARB(items, list);
			free(list);
		}
	}

#//# glGenBuffersARB_c($n,(CPTR)buffers);
void
glGenBuffersARB_c(n,buffers)
	GLsizei n
	void *	buffers
	INIT:
		loadProc(glGenBuffersARB,"glGenBuffersARB");
	CODE:
	{
		glGenBuffersARB(n, buffers);
	}

#//# glGenBuffersARB_s($n,(PACKED)buffers);
void
glGenBuffersARB_s(n,buffers)
	GLsizei n
	SV *	buffers
	INIT:
		loadProc(glGenBuffersARB,"glGenBuffersARB");
	CODE:
	{
		void * buffers_s = EL(buffers, sizeof(GLuint)*n);
		glGenBuffersARB(n, buffers_s);
	}

#//# @buffers = glGenBuffersARB_p($n);
void
glGenBuffersARB_p(n)
	GLsizei n
	INIT:
		loadProc(glGenBuffersARB,"glGenBuffersARB");
	PPCODE:
	if (n)
	{
		GLuint * buffers = malloc(sizeof(GLuint) * n);
		int i;

		glGenBuffersARB(n, buffers);

		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(buffers[i])));

		free(buffers);
	} 

#//# glIsBufferARB($buffer);
GLboolean
glIsBufferARB(buffer)
	GLuint buffer
	INIT:
		loadProc(glIsBufferARB,"glIsBufferARB");
	CODE:
	{
		RETVAL = glIsBufferARB(buffer);
        }
	OUTPUT:
		RETVAL

#//# glBufferDataARB_c($target,$size,(CPTR)data,$usage);
void
glBufferDataARB_c(target,size,data,usage)
	GLenum	target
	GLsizei	size
	void *	data
	GLenum	usage
	INIT:
		loadProc(glBufferDataARB,"glBufferDataARB");
	CODE:
	{
		glBufferDataARB(target,size,data,usage);
	}

#//# glBufferDataARB_s($target,$size,(PACKED)data,$usage);
void
glBufferDataARB_s(target,size,data,usage)
	GLenum	target
	GLsizei	size
	SV *	data
	GLenum	usage
	INIT:
		loadProc(glBufferDataARB,"glBufferDataARB");
	CODE:
	{
		void * data_s = EL(data, size);
		glBufferDataARB(target,size,data_s,usage);
	}

#//# glBufferDataARB_p($target,(OGA)data,$usage);
void
glBufferDataARB_p(target,oga,usage)
	GLenum target
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	GLenum usage
	INIT:
		loadProc(glBufferDataARB,"glBufferDataARB");
	CODE:
	{
		glBufferDataARB(target,oga->data_length,oga->data,usage);
	}

#//# glBufferSubDataARB_c($target,$offset,$size,(CPTR)data);
void
glBufferSubDataARB_c(target,offset,size,data)
	GLenum	target
	GLint	offset
	GLsizei	size
	void *	data
	INIT:
		loadProc(glBufferSubDataARB,"glBufferSubDataARB");
	CODE:
	{
		glBufferSubDataARB(target,offset,size,data);
	}

#//# glBufferSubDataARB_s($target,$offset,$size,(PACKED)data);
void
glBufferSubDataARB_s(target,offset,size,data)
	GLenum	target
	GLint	offset
	GLsizei	size
	SV *	data
	INIT:
		loadProc(glBufferSubDataARB,"glBufferSubDataARB");
	CODE:
	{
		void * data_s = EL(data, size);
		glBufferSubDataARB(target,offset,size,data);
	}

#//# glBufferSubDataARB_p($target,$offset,(OGA)data);
void
glBufferSubDataARB_p(target,offset,oga)
	GLenum	target
	GLint	offset
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	INIT:
		loadProc(glBufferSubDataARB,"glBufferSubDataARB");
	CODE:
	{
		glBufferSubDataARB(target,offset*oga->total_types_width,oga->data_length,oga->data);
	}

#//# glGetBufferSubDataARB_c($target,$offset,$size,(CPTR)data)
void
glGetBufferSubDataARB_c(target,offset,size,data)
	GLenum	target
	GLint	offset
	GLsizei	size
	void *	data
	INIT:
		loadProc(glGetBufferSubDataARB,"glBufferSubDataARB");
	CODE:
		glGetBufferSubDataARB(target,offset,size,data);

#//# glGetBufferSubDataARB_s($target,$offset,$size,(PACKED)data)
void
glGetBufferSubDataARB_s(target,offset,size,data)
	GLenum	target
	GLint	offset
	GLsizei	size
	SV *	data
	INIT:
		loadProc(glGetBufferSubDataARB,"glBufferSubDataARB");
	CODE:
	{
		GLubyte * data_s = EL(data,size);
		glGetBufferSubDataARB(target,offset,size,data_s);
	}

#//# $oga = glGetBufferSubDataARB_p($target,$offset,$count,@types);
#//- If no types are provided, GLubyte is assumed
PDL::Graphics::OpenGL::Perl::OpenGL::Array
glGetBufferSubDataARB_p(target,offset,count,...)
	GLenum	target
	GLint	offset
	GLsizei	count
	INIT:
		loadProc(glGetBufferSubDataARB,"glGetBufferSubDataARB");
		loadProc(glGetBufferParameterivARB,"glGetBufferParameterivARB");
	CODE:
	{
		oga_struct * oga = malloc(sizeof(oga_struct));
		GLsizeiptrARB size;
		
		oga->item_count = count;
		oga->type_count = (items - 3);

                if (oga->type_count)
		{
			int i,j;

			oga->types = malloc(sizeof(GLenum) * oga->type_count);
			oga->type_offset = malloc(sizeof(GLint) * oga->type_count);
			for(i=0,j=0;i<oga->type_count;i++) {
				oga->types[i] = SvIV(ST(i+3));
				oga->type_offset[i] = j;
				j += gl_type_size(oga->types[i]);
			}
			oga->total_types_width = j;
		}
		else
		{
			oga->type_count = 1;
			oga->types = malloc(sizeof(GLenum) * oga->type_count);
			oga->type_offset = malloc(sizeof(GLint) * oga->type_count);

			oga->types[0] = GL_UNSIGNED_BYTE;
			oga->type_offset[0] = 0;
			oga->total_types_width = gl_type_size(oga->types[0]);
		}
		if (!oga->total_types_width) croak("Unable to determine type sizes\n");

		glGetBufferParameterivARB(target,GL_BUFFER_SIZE_ARB,(GLint*)&size);
		size /= oga->total_types_width;
		if (offset > size) croak("Offset is greater than elements in buffer: %d\n",size);

		if ((offset+count) > size) count = size - offset;
		
		oga->data_length = oga->total_types_width * count;
		oga->data = malloc(oga->data_length);

		glGetBufferSubDataARB(target,offset*oga->total_types_width,
			oga->data_length,oga->data);

		oga->free_data = 1;
		
		RETVAL = oga;
	}
	OUTPUT:
		RETVAL

#//# (CPTR)buffer = glMapBufferARB_c($target,$access);
void *
glMapBufferARB_c(target,access)
	GLenum	target
	GLenum	access
	INIT:
		loadProc(glMapBufferARB,"glMapBufferARB");
	CODE:
		RETVAL = glMapBufferARB(target,access);
	OUTPUT:
		RETVAL

#define FIXME /* !!! Need to refactor with glGetBufferPointervARB_p */

#//# $oga = glMapBufferARB_p($target,$access,@types);
#//- If no types are provided, GLubyte is assumed
PDL::Graphics::OpenGL::Perl::OpenGL::Array
glMapBufferARB_p(target,access,...)
	GLenum	target
	GLenum	access
	INIT:
		loadProc(glMapBufferARB,"glMapBufferARB");
		loadProc(glGetBufferParameterivARB,"glGetBufferParameterivARB");
	CODE:
	{
		GLsizeiptrARB size;
		oga_struct * oga;
		int i,j;

		void * buffer =	glMapBufferARB(target,access);
		if (!buffer) croak("Unable to map buffer\n");

		glGetBufferParameterivARB(target,GL_BUFFER_SIZE_ARB,(GLint*)&size);
		if (!size) croak("Buffer has no size\n");

		oga = malloc(sizeof(oga_struct));

		oga->type_count = (items - 2);

                if (oga->type_count)
		{
			oga->types = malloc(sizeof(GLenum) * oga->type_count);
			oga->type_offset = malloc(sizeof(GLint) * oga->type_count);
			for(i=0,j=0;i<oga->type_count;i++) {
				oga->types[i] = SvIV(ST(i+2));
				oga->type_offset[i] = j;
				j += gl_type_size(oga->types[i]);
			}
			oga->total_types_width = j;
		}
		else
		{
			oga->type_count = 1;
			oga->types = malloc(sizeof(GLenum) * oga->type_count);
			oga->type_offset = malloc(sizeof(GLint) * oga->type_count);

			oga->types[0] = GL_UNSIGNED_BYTE;
			oga->type_offset[0] = 0;
			oga->total_types_width = gl_type_size(oga->types[0]);
		}

		if (!oga->total_types_width) croak("Unable to determine type sizes\n");
		oga->item_count = size / oga->total_types_width;

		oga->data_length = oga->total_types_width * oga->item_count;
		
		oga->data = buffer;

		oga->free_data = 0;
		
		RETVAL = oga;
	}
	OUTPUT:
		RETVAL

#//# glUnmapBufferARB($target);
GLboolean
glUnmapBufferARB(target)
	GLenum	target
	INIT:
		loadProc(glUnmapBufferARB,"glUnmapBufferARB");
	CODE:
		RETVAL = glUnmapBufferARB(target);
	OUTPUT:
		RETVAL

#//# glGetBufferParameterivARB_c($target,$pname,(CPTR)params);
void
glGetBufferParameterivARB_c(target,pname,params)
	GLenum	target
	GLenum	pname
	void *	params
	INIT:
		loadProc(glGetBufferParameterivARB,"glGetBufferParameterivARB");
	CODE:
		glGetBufferParameterivARB(target,pname,params);

#//# glGetBufferParameterivARB_s($target,$pname,(PACKED)params);
void
glGetBufferParameterivARB_s(target,pname,params)
	GLenum	target
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetBufferParameterivARB,"glGetBufferParameterivARB");
	CODE:
	{
		GLint * params_s = EL(params, sizeof(GLint)*1);
		glGetBufferParameterivARB(target,pname,params_s);
	}

#//# @params = glGetBufferParameterivARB_p($target,$pname);
void
glGetBufferParameterivARB_p(target,pname)
	GLenum	target
	GLenum	pname
	INIT:
		loadProc(glGetBufferParameterivARB,"glGetBufferParameterivARB");
	PPCODE:
	{
		GLint	ret;
		glGetBufferParameterivARB(target,pname,&ret);
		PUSHs(sv_2mortal(newSViv(ret)));
	}

#//# glGetBufferPointervARB_c($target,$pname,(CPTR)params);
void
glGetBufferPointervARB_c(target,pname,params)
	GLenum	target
	GLenum	pname
	void *	params
	INIT:
		loadProc(glGetBufferPointervARB,"glGetBufferPointervARB");
	CODE:
		glGetBufferPointervARB(target,pname,&params);

#//# glGetBufferPointervARB_s($target,$pname,(PACKED)params);
void
glGetBufferPointervARB_s(target,pname,params)
	GLenum	target
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetBufferPointervARB,"glGetBufferPointervARB");
	CODE:
	{
		void ** params_s = EL(params, sizeof(void*));
		glGetBufferPointervARB(target,pname,params_s);
	}

#//# $oga = glGetBufferPointervARB_p($target,$pname,@types);
#//- If no types are provided, GLubyte is assumed
PDL::Graphics::OpenGL::Perl::OpenGL::Array
glGetBufferPointervARB_p(target,pname,...)
	GLenum	target
	GLenum	pname
	INIT:
		loadProc(glGetBufferPointervARB,"glGetBufferPointervARB");
		loadProc(glGetBufferParameterivARB,"glGetBufferParameterivARB");
	CODE:
	{
		GLsizeiptrARB size;
		oga_struct * oga;
		void * buffer;
		int i,j;

		glGetBufferPointervARB(target,pname,&buffer);
		if (!buffer) croak("Buffer is not mapped\n");

		glGetBufferParameterivARB(target,GL_BUFFER_SIZE_ARB,(GLint*)&size);
		if (!size) croak("Buffer has no size\n");

		oga = malloc(sizeof(oga_struct));

		oga->type_count = (items - 2);

                if (oga->type_count)
		{
			oga->types = malloc(sizeof(GLenum) * oga->type_count);
			oga->type_offset = malloc(sizeof(GLint) * oga->type_count);
			for(i=0,j=0;i<oga->type_count;i++) {
				oga->types[i] = SvIV(ST(i+2));
				oga->type_offset[i] = j;
				j += gl_type_size(oga->types[i]);
			}
			oga->total_types_width = j;
		}
		else
		{
			oga->type_count = 1;
			oga->types = malloc(sizeof(GLenum) * oga->type_count);
			oga->type_offset = malloc(sizeof(GLint) * oga->type_count);

			oga->types[0] = GL_UNSIGNED_BYTE;
			oga->type_offset[0] = 0;
			oga->total_types_width = gl_type_size(oga->types[0]);
		}

		if (!oga->total_types_width) croak("Unable to determine type sizes\n");
		oga->item_count = size / oga->total_types_width;
		
		oga->data_length = oga->total_types_width * oga->item_count;
		
		oga->data = buffer;

		oga->free_data = 0;
		
		RETVAL = oga;
	}
	OUTPUT:
		RETVAL


#endif


#ifdef GL_ARB_multitexture

#//# glActiveTextureARB($texture);
void
glActiveTextureARB(texture)
	GLenum texture
	INIT:
		loadProc(glActiveTextureARB,"glActiveTextureARB");
	CODE:
		glActiveTextureARB(texture);

#//# glClientActiveTextureARB($texture);
void
glClientActiveTextureARB(texture)
	GLenum texture
	INIT:
		loadProc(glClientActiveTextureARB,"glClientActiveTextureARB");
	CODE:
		glClientActiveTextureARB(texture);

#//# glMultiTexCoord1dARB($target,$s)
void
glMultiTexCoord1dARB(target,s)
	GLenum target
	GLdouble s
	INIT:
		loadProc(glMultiTexCoord1dARB,"glMultiTexCoord1dARB");
	CODE:
		glMultiTexCoord1dARB(target,s);

#//# glMultiTexCoord1dvARB_c($target,(CPTR)v);
void
glMultiTexCoord1dvARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1dvARB,"glMultiTexCoord1dvARB");
	CODE:
		glMultiTexCoord1dvARB(target,v);

#//# glMultiTexCoord1dvARB_s($target,(PACKED)v);
void
glMultiTexCoord1dvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1dvARB,"glMultiTexCoord1dvARB");
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord1dvARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord1dARB
#//# glMultiTexCoord1dvARB_p($target,$s);
void
glMultiTexCoord1dvARB_p(target,s)
	GLenum target
	GLdouble s
	INIT:
		loadProc(glMultiTexCoord1dvARB,"glMultiTexCoord1dvARB");
	CODE:
	{
		glMultiTexCoord1dvARB(target,&s);
	}

#//# glMultiTexCoord1fARB($target,$s);
void
glMultiTexCoord1fARB(target,s)
	GLenum target
	GLfloat s
	INIT:
		loadProc(glMultiTexCoord1fARB,"glMultiTexCoord1fARB");
	CODE:
		glMultiTexCoord1fARB(target,s);

#//# glMultiTexCoord1fvARB_c($target,(CPTR)v);
void
glMultiTexCoord1fvARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1fvARB,"glMultiTexCoord1fvARB");
	CODE:
		glMultiTexCoord1fvARB(target,v);

#//# glMultiTexCoord1fvARB_s($target,(PACKED)v);
void
glMultiTexCoord1fvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1fvARB,"glMultiTexCoord1fvARB");
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord1fvARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord1fARB
#//# glMultiTexCoord1fvARB_p($target,$s);
void
glMultiTexCoord1fvARB_p(target,s)
	GLenum target
	GLfloat s
	INIT:
		loadProc(glMultiTexCoord1fvARB,"glMultiTexCoord1fvARB");
	CODE:
	{
		glMultiTexCoord1fvARB(target,&s);
	}

#//# glMultiTexCoord1iARB($target,$s);
void
glMultiTexCoord1iARB(target,s)
	GLenum target
	GLint s
	INIT:
		loadProc(glMultiTexCoord1iARB,"glMultiTexCoord1iARB");
	CODE:
		glMultiTexCoord1iARB(target,s);

#//# glMultiTexCoord1ivARB_c($target,(CPTR)v);
void
glMultiTexCoord1ivARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1ivARB,"glMultiTexCoord1ivARB");
	CODE:
		glMultiTexCoord1ivARB(target,v);

#//# glMultiTexCoord1ivARB_s($target,(PACKED)v);
void
glMultiTexCoord1ivARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1ivARB,"glMultiTexCoord1ivARB");
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord1ivARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord1iARB
#//# glMultiTexCoord1ivARB_p($target,$s);
void
glMultiTexCoord1ivARB_p(target,s)
	GLenum target
	GLint s
	INIT:
		loadProc(glMultiTexCoord1ivARB,"glMultiTexCoord1ivARB");
	CODE:
	{
		glMultiTexCoord1ivARB(target,&s);
	}

#//# glMultiTexCoord1sARB($target,$s);
void
glMultiTexCoord1sARB(target,s)
	GLenum target
	GLshort s
	INIT:
		loadProc(glMultiTexCoord1sARB,"glMultiTexCoord1sARB");
	CODE:
		glMultiTexCoord1sARB(target,s);

#//# glMultiTexCoord1svARB_c($target,(CPTR)v);
void
glMultiTexCoord1svARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1svARB,"glMultiTexCoord1svARB");
	CODE:
		glMultiTexCoord1svARB(target,v);

#//# glMultiTexCoord1svARB_s($target,(PACKED)v);
void
glMultiTexCoord1svARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1svARB,"glMultiTexCoord1svARB");
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord1svARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord1sARB
#//# glMultiTexCoord1svARB_p($target,$s);
void
glMultiTexCoord1svARB_p(target,s)
	GLenum target
	GLshort s
	INIT:
		loadProc(glMultiTexCoord1svARB,"glMultiTexCoord1svARB");
	CODE:
	{
		glMultiTexCoord1svARB(target,&s);
	}

#//# glMultiTexCoord2dARB($target,$s,$t);
void
glMultiTexCoord2dARB(target,s,t)
	GLenum target
	GLdouble s
	GLdouble t
	INIT:
		loadProc(glMultiTexCoord2dARB,"glMultiTexCoord2dARB");
	CODE:
		glMultiTexCoord2dARB(target,s,t);

#//# glMultiTexCoord2dvARB_c(target,(CPTR)v);
void
glMultiTexCoord2dvARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2dvARB,"glMultiTexCoord2dvARB");
	CODE:
		glMultiTexCoord2dvARB(target,v);

#//# glMultiTexCoord2dvARB_s(target,(PACKED)v);
void
glMultiTexCoord2dvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2dvARB,"glMultiTexCoord2dvARB");
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord2dvARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord2dARB
#//# glMultiTexCoord2dvARB_p($target,$s,$t);
void
glMultiTexCoord2dvARB_p(target,s,t)
	GLenum target
	GLdouble s
	GLdouble t
	INIT:
		loadProc(glMultiTexCoord2dvARB,"glMultiTexCoord2dvARB");
	CODE:
	{
		GLdouble param[2];
		param[0] = s;
		param[1] = t;
		glMultiTexCoord2dvARB(target,param);
	}

#//# glMultiTexCoord2fARB($target,$s,$t);
void
glMultiTexCoord2fARB(target,s,t)
	GLenum target
	GLfloat s
	GLfloat t
	INIT:
		loadProc(glMultiTexCoord2fARB,"glMultiTexCoord2fARB");
	CODE:
		glMultiTexCoord2fARB(target,s,t);

#//# glMultiTexCoord2fvARB_c($target,(CPTR)v);
void
glMultiTexCoord2fvARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2fvARB,"glMultiTexCoord2fvARB");
	CODE:
		glMultiTexCoord2fvARB(target,v);

#//# glMultiTexCoord2fvARB_s($target,(PACKED)v);
void
glMultiTexCoord2fvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2fvARB,"glMultiTexCoord2fvARB");
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord2fvARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord2fARB
#//# glMultiTexCoord2fvARB_p($target,$s,$t);
void
glMultiTexCoord2fvARB_p(target,s,t)
	GLenum target
	GLfloat s
	GLfloat t
	INIT:
		loadProc(glMultiTexCoord2fvARB,"glMultiTexCoord2fvARB");
	CODE:
	{
		GLfloat param[2];
		param[0] = s;
		param[1] = t;
		glMultiTexCoord2fvARB(target,param);
	}

#//# glMultiTexCoord2iARB($target,$s,$t);
void
glMultiTexCoord2iARB(target,s,t)
	GLenum target
	GLint s
	GLint t
	INIT:
		loadProc(glMultiTexCoord2iARB,"glMultiTexCoord2iARB");
	CODE:
		glMultiTexCoord2iARB(target,s,t);

#//# glMultiTexCoord2ivARB_c($target,(CPTR)v);
void
glMultiTexCoord2ivARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2ivARB,"glMultiTexCoord2ivARB");
	CODE:
		glMultiTexCoord2ivARB(target,v);

#//# glMultiTexCoord2ivARB_s($target,(PACKED)v);
void
glMultiTexCoord2ivARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2ivARB,"glMultiTexCoord2ivARB");
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord2ivARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord2iARB
#//# glMultiTexCoord2ivARB_p($target,$s,$t);
void
glMultiTexCoord2ivARB_p(target,s,t)
	GLenum target
	GLint s
	GLint t
	INIT:
		loadProc(glMultiTexCoord2ivARB,"glMultiTexCoord2ivARB");
	CODE:
	{
		GLint param[2];
		param[0] = s;
		param[1] = t;
		glMultiTexCoord2ivARB(target,param);
	}

#//# glMultiTexCoord2sARB($target,$s,$t);
void
glMultiTexCoord2sARB(target,s,t)
	GLenum target
	GLshort s
	GLshort t
	INIT:
		loadProc(glMultiTexCoord2sARB,"glMultiTexCoord2sARB");
	CODE:
		glMultiTexCoord2sARB(target,s,t);

#//# glMultiTexCoord2svARB_c($target,(CPTR)v);
void
glMultiTexCoord2svARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2svARB,"glMultiTexCoord2svARB");
	CODE:
		glMultiTexCoord2svARB(target,v);

#//# glMultiTexCoord2svARB_s($target,(PACKED)v);
void
glMultiTexCoord2svARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2svARB,"glMultiTexCoord2svARB");
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord2svARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord2sARB
#//# glMultiTexCoord2svARB_p($target,$s,$t);
void
glMultiTexCoord2svARB_p(target,s,t)
	GLenum target
	GLshort s
	GLshort t
	INIT:
		loadProc(glMultiTexCoord2svARB,"glMultiTexCoord2svARB");
	CODE:
	{
		GLshort param[2];
		param[0] = s;
		param[1] = t;
		glMultiTexCoord2svARB(target,param);
	}

#//# glMultiTexCoord3dARB($target,$s,$t,$r);
void
glMultiTexCoord3dARB(target,s,t,r)
	GLenum target
	GLdouble s
	GLdouble t
	GLdouble r
	INIT:
		loadProc(glMultiTexCoord3dARB,"glMultiTexCoord3dARB");
	CODE:
		glMultiTexCoord3dARB(target,s,t,r);

#//# glMultiTexCoord3dvARB_c(target,(CPTR)v);
void
glMultiTexCoord3dvARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3dvARB,"glMultiTexCoord3dvARB");
	CODE:
		glMultiTexCoord3dvARB(target,v);

#//# glMultiTexCoord3dvARB_s(target,(PACKED)v);
void
glMultiTexCoord3dvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3dvARB,"glMultiTexCoord3dvARB");
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord3dvARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord3dARB
#//# glMultiTexCoord3dvARB_p($target,$s,$t,$r);
void
glMultiTexCoord3dvARB_p(target,s,t,r)
	GLenum target
	GLdouble s
	GLdouble t
	GLdouble r
	INIT:
		loadProc(glMultiTexCoord3dvARB,"glMultiTexCoord3dvARB");
	CODE:
	{
		GLdouble param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glMultiTexCoord3dvARB(target,param);
	}

#//# glMultiTexCoord3fARB($target,$s,$t,$r);
void
glMultiTexCoord3fARB(target,s,t,r)
	GLenum target
	GLfloat s
	GLfloat t
	GLfloat r
	INIT:
		loadProc(glMultiTexCoord3fARB,"glMultiTexCoord3fARB");
	CODE:
		glMultiTexCoord3fARB(target,s,t,r);

#//# glMultiTexCoord3fvARB_c($target,(CPTR)v);
void
glMultiTexCoord3fvARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3fvARB,"glMultiTexCoord3fvARB");
	CODE:
		glMultiTexCoord3fvARB(target,v);

#//# glMultiTexCoord3fvARB_s($target,(PACKED)v);
void
glMultiTexCoord3fvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3fvARB,"glMultiTexCoord3fvARB");
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord3fvARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord3fARB
#//# glMultiTexCoord3fvARB_p($target,$s,$t,$r);
void
glMultiTexCoord3fvARB_p(target,s,t,r)
	GLenum target
	GLfloat s
	GLfloat t
	GLfloat r
	INIT:
		loadProc(glMultiTexCoord3fvARB,"glMultiTexCoord3fvARB");
	CODE:
	{
		GLfloat param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glMultiTexCoord3fvARB(target,param);
	}

#//# glMultiTexCoord3iARB($target,$s,$t,$r);
void
glMultiTexCoord3iARB(target,s,t,r)
	GLenum target
	GLint s
	GLint t
	GLint r
	INIT:
		loadProc(glMultiTexCoord3iARB,"glMultiTexCoord3iARB");
	CODE:
		glMultiTexCoord3iARB(target,s,t,r);

#//# glMultiTexCoord3ivARB_c($target,(CPTR)v);
void
glMultiTexCoord3ivARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3ivARB,"glMultiTexCoord3ivARB");
	CODE:
		glMultiTexCoord3ivARB(target,v);

#//# glMultiTexCoord3ivARB_s($target,(PACKED)v);
void
glMultiTexCoord3ivARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3ivARB,"glMultiTexCoord3ivARB");
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord3ivARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord3iARB
#//# glMultiTexCoord3ivARB_p($target,$s,$t,$r);
void
glMultiTexCoord3ivARB_p(target,s,t,r)
	GLenum target
	GLint s
	GLint t
	GLint r
	INIT:
		loadProc(glMultiTexCoord3ivARB,"glMultiTexCoord3ivARB");
	CODE:
	{
		GLint param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glMultiTexCoord3ivARB(target,param);
	}

#//# glMultiTexCoord3sARB($target,$s,$t,$r);
void
glMultiTexCoord3sARB(target,s,t,r)
	GLenum target
	GLshort s
	GLshort t
	GLshort r
	INIT:
		loadProc(glMultiTexCoord3sARB,"glMultiTexCoord3sARB");
	CODE:
		glMultiTexCoord3sARB(target,s,t,r);

#//# glMultiTexCoord3svARB_c($target,(CPTR)v);
void
glMultiTexCoord3svARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3svARB,"glMultiTexCoord3svARB");
	CODE:
		glMultiTexCoord3svARB(target,v);

#//# glMultiTexCoord3svARB_s($target,(PACKED)v);
void
glMultiTexCoord3svARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3svARB,"glMultiTexCoord3svARB");
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord3svARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord3sARB
#//# glMultiTexCoord3svARB_p($target,$s,$t,$r);
void
glMultiTexCoord3svARB_p(target,s,t,r)
	GLenum target
	GLshort s
	GLshort t
	GLshort r
	INIT:
		loadProc(glMultiTexCoord3svARB,"glMultiTexCoord3svARB");
	CODE:
	{
		GLshort param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glMultiTexCoord3svARB(target,param);
	}

#//# glMultiTexCoord4dARB($target,$s,$t,$r,$q);
void
glMultiTexCoord4dARB(target,s,t,r,q)
	GLenum target
	GLdouble s
	GLdouble t
	GLdouble r
	GLdouble q
	INIT:
		loadProc(glMultiTexCoord4dARB,"glMultiTexCoord4dARB");
	CODE:
		glMultiTexCoord4dARB(target,s,t,r,q);

#//# glMultiTexCoord4dvARB_c($target,(CPTR)v);
void
glMultiTexCoord4dvARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4dvARB,"glMultiTexCoord4dvARB");
	CODE:
		glMultiTexCoord4dvARB(target,v);

#//# glMultiTexCoord4dvARB_s($target,(PACKED)v);
void
glMultiTexCoord4dvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4dvARB,"glMultiTexCoord4dvARB");
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord4dvARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord4dARB
#//# glMultiTexCoord4dvARB_p($target,$s,$t,$r,$q);
void
glMultiTexCoord4dvARB_p(target,s,t,r,q)
	GLenum target
	GLdouble s
	GLdouble t
	GLdouble r
	GLdouble q
	INIT:
		loadProc(glMultiTexCoord4dvARB,"glMultiTexCoord4dvARB");
	CODE:
	{
		GLdouble param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glMultiTexCoord4dvARB(target,param);
	}

#//# glMultiTexCoord4fARB($target,$s,$t,$r,$q);
void
glMultiTexCoord4fARB(target,s,t,r,q)
	GLenum target
	GLfloat s
	GLfloat t
	GLfloat r
	GLfloat q
	INIT:
		loadProc(glMultiTexCoord4fARB,"glMultiTexCoord4fARB");
	CODE:
		glMultiTexCoord4fARB(target,s,t,r,q);

#//# glMultiTexCoord4fvARB_c($target,(CPTR)v);
void
glMultiTexCoord4fvARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4fvARB,"glMultiTexCoord4fvARB");
	CODE:
		glMultiTexCoord4fvARB(target,v);

#//# glMultiTexCoord4fvARB_s($target,(PACKED)v);
void
glMultiTexCoord4fvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4fvARB,"glMultiTexCoord4fvARB");
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord4fvARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord4fARB
#//# glMultiTexCoord4fvARB_p($target,$s,$t,$r,$q);
void
glMultiTexCoord4fvARB_p(target,s,t,r,q)
	GLenum target
	GLfloat s
	GLfloat t
	GLfloat r
	GLfloat q
	INIT:
		loadProc(glMultiTexCoord4fvARB,"glMultiTexCoord4fvARB");
	CODE:
	{
		GLfloat param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glMultiTexCoord4fvARB(target,param);
	}

#//# glMultiTexCoord4iARB($target,$s,$t,$r,$q)
void
glMultiTexCoord4iARB(target,s,t,r,q)
	GLenum target
	GLint s
	GLint t
	GLint r
	GLint q
	INIT:
		loadProc(glMultiTexCoord4iARB,"glMultiTexCoord4iARB");
	CODE:
		glMultiTexCoord4iARB(target,s,t,r,q);

#//# glMultiTexCoord4ivARB_c($target,(CPTR)v);
void
glMultiTexCoord4ivARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4ivARB,"glMultiTexCoord4ivARB");
	CODE:
		glMultiTexCoord4ivARB(target,v);

#//# glMultiTexCoord4ivARB_s($target,(PACKED)v);
void
glMultiTexCoord4ivARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4ivARB,"glMultiTexCoord4ivARB");
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord4ivARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord4iARB
#//# glMultiTexCoord4ivARB_p($target,$s,$t,$r,$q);
void
glMultiTexCoord4ivARB_p(target,s,t,r,q)
	GLenum target
	GLint s
	GLint t
	GLint r
	GLint q
	INIT:
		loadProc(glMultiTexCoord4ivARB,"glMultiTexCoord4ivARB");
	CODE:
	{
		GLint param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glMultiTexCoord4ivARB(target,param);
	}

#//# glMultiTexCoord4sARB($target,$s,$t,$r,$q);
void
glMultiTexCoord4sARB(target,s,t,r,q)
	GLenum target
	GLshort s
	GLshort t
	GLshort r
	GLshort q
	INIT:
		loadProc(glMultiTexCoord4sARB,"glMultiTexCoord4sARB");
	CODE:
		glMultiTexCoord4sARB(target,s,t,r,q);

#//# glMultiTexCoord4svARB_c($target,(CPTR)v);
void
glMultiTexCoord4svARB_c(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4svARB,"glMultiTexCoord4svARB");
	CODE:
		glMultiTexCoord4svARB(target,v);

#//# glMultiTexCoord4svARB_s($target,(PACKED)v);
void
glMultiTexCoord4svARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4svARB,"glMultiTexCoord4svARB");
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord4svARB(target,v_s);
	}

#//!!! Do we really need this?  It duplicates glMultiTexCoord4sARB
#//# glMultiTexCoord4svARB_p($target,$s,$t,$r,$q);
void
glMultiTexCoord4svARB_p(target,s,t,r,q)
	GLenum target
	GLshort s
	GLshort t
	GLshort r
	GLshort q
	INIT:
		loadProc(glMultiTexCoord4svARB,"glMultiTexCoord4svARB");
	CODE:
	{
		GLshort param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glMultiTexCoord4svARB(target,param);
	}

#endif



#ifdef GL_ARB_shader_objects

#//# glDeleteObjectARB($obj);
void
glDeleteObjectARB(obj)
	GLhandleARB	obj
	INIT:
		loadProc(glDeleteObjectARB,"glDeleteObjectARB");
	CODE:
	{
		glDeleteObjectARB(obj);
	}

#//# glGetHandleARB($pname);
GLhandleARB
glGetHandleARB(pname)
	GLenum	pname
	INIT:
		loadProc(glGetHandleARB,"glGetHandleARB");
	CODE:
	{
		RETVAL = glGetHandleARB(pname);
	}
	OUTPUT:
		RETVAL

#//# glDetachObjectARB($containerObj, $attachedObj);
void
glDetachObjectARB(containerObj, attachedObj)
	GLhandleARB containerObj
	GLhandleARB attachedObj
	INIT:
		loadProc(glDetachObjectARB,"glDetachObjectARB");
	CODE:
	{
		glDetachObjectARB(containerObj, attachedObj);
	}

#//# glCreateShaderObjectARB($shaderType);
GLhandleARB
glCreateShaderObjectARB(shaderType)
	GLenum shaderType
	INIT:
		loadProc(glCreateShaderObjectARB,"glCreateShaderObjectARB");
	CODE:
	{
		RETVAL = glCreateShaderObjectARB(shaderType);
	}
	OUTPUT:
		RETVAL

#//# glShaderSourceARB_c($shaderObj, $count, (CPTR)string, (CPTR)length);
void
glShaderSourceARB_c(shaderObj, count, string, length)
	GLhandleARB shaderObj
	GLsizei count
	void	*string
	void	*length
	INIT:
		loadProc(glShaderSourceARB,"glShaderSourceARB");
	CODE:
	{
		glShaderSourceARB(shaderObj, count, string, length);
	}

#//# glShaderSourceARB_p($shaderObj, @string);
void
glShaderSourceARB_p(shaderObj, ...)
	GLhandleARB shaderObj
	INIT:
		loadProc(glShaderSourceARB,"glShaderSourceARB");
	CODE:
	{
		int i;
		int count = items - 1;
		GLcharARB **string = malloc(sizeof(GLcharARB *) * count);
		GLint *length = malloc(sizeof(GLint) * count);

		for(i=0;i<count;i++) {
			string[i] = (GLcharARB *)SvPV(ST(i+1),PL_na);
			length[i] = strlen(string[i]);
		}

		glShaderSourceARB(shaderObj, count, (const GLcharARB**)string,
			(const GLint *)length);

		free(length);
                free(string);
	}

#//# glCompileShaderARB($shaderObj);
void
glCompileShaderARB(shaderObj)
	GLhandleARB shaderObj
	INIT:
		loadProc(glCompileShaderARB,"glCompileShaderARB");
	CODE:
	{
		glCompileShaderARB(shaderObj);
	}

#//# $obj = glCreateProgramObjectARB();
GLhandleARB
glCreateProgramObjectARB()
	INIT:
		loadProc(glCreateProgramObjectARB,"glCreateProgramObjectARB");
	CODE:
	{
		RETVAL = glCreateProgramObjectARB();
	}
	OUTPUT:
		RETVAL

#//# glAttachObjectARB($containerObj, $obj);
void
glAttachObjectARB(containerObj, obj)
	GLhandleARB containerObj
	GLhandleARB obj
	INIT:
		loadProc(glAttachObjectARB,"glAttachObjectARB");
	CODE:
	{
		glAttachObjectARB(containerObj, obj);
	}

#//# glLinkProgramARB($programObj);
void
glLinkProgramARB(programObj)
	GLhandleARB programObj
	INIT:
		loadProc(glLinkProgramARB,"glLinkProgramARB");
	CODE:
	{
		glLinkProgramARB(programObj);
	}

#//# glUseProgramObjectARB($programObj);
void
glUseProgramObjectARB(programObj)
	GLhandleARB programObj
	INIT:
		loadProc(glUseProgramObjectARB,"glUseProgramObjectARB");
	CODE:
	{
		glUseProgramObjectARB(programObj);
	}

#//# glValidateProgramARB($programObj);
void
glValidateProgramARB(programObj)
	GLhandleARB programObj
	INIT:
		loadProc(glValidateProgramARB,"glValidateProgramARB");
	CODE:
	{
		glValidateProgramARB(programObj);
	}

#//# glUniform1fARB($location, $v0);
void
glUniform1fARB(location, v0)
	GLint location
	GLfloat v0
	INIT:
		loadProc(glUniform1fARB,"glUniform1fARB");
	CODE:
	{
		glUniform1fARB(location, v0);
	}

#//# glUniform2fARB($location, $v0, $v1);
void
glUniform2fARB(location, v0, v1)
	GLint location
	GLfloat v0
	GLfloat v1
	INIT:
		loadProc(glUniform2fARB,"glUniform2fARB");
	CODE:
	{
		glUniform2fARB(location, v0, v1);
	}

#//# glUniform3fARB($location, $v0, $v1, $v2);
void
glUniform3fARB(location, v0, v1, v2)
	GLint location
	GLfloat v0
	GLfloat v1
	GLfloat v2
	INIT:
		loadProc(glUniform3fARB,"glUniform3fARB");
	CODE:
	{
		glUniform3fARB(location, v0, v1, v2);
	}

#//# glUniform4fARB($location, $v0, $v1, $v2, $v3);
void
glUniform4fARB(location, v0, v1, v2, v3)
	GLint location
	GLfloat v0
	GLfloat v1
	GLfloat v2
	GLfloat v3
	INIT:
		loadProc(glUniform4fARB,"glUniform4fARB");
	CODE:
	{
		glUniform4fARB(location, v0, v1, v2, v3);
	}

#//# glUniform1iARB($location, $v0);
void
glUniform1iARB(location, v0)
	GLint location
	GLint v0
	INIT:
		loadProc(glUniform1iARB,"glUniform1iARB");
	CODE:
	{
		glUniform1iARB(location, v0);
	}

#//# glUniform2iARB($location, $v0, $v1);
void
glUniform2iARB(location, v0, v1)
	GLint location
	GLint v0
	GLint v1
	INIT:
		loadProc(glUniform2iARB,"glUniform2iARB");
	CODE:
	{
		glUniform2iARB(location, v0, v1);
	}

#//# glUniform3iARB($location, $v0, $v1, $v2);
void
glUniform3iARB(location, v0, v1, v2)
	GLint location
	GLint v0
	GLint v1
	GLint v2
	INIT:
		loadProc(glUniform3iARB,"glUniform3iARB");
	CODE:
	{
		glUniform3iARB(location, v0, v1, v2);
	}

#//# glUniform4iARB($location, $v0, $v1, $v2, $v3);
void
glUniform4iARB(location, v0, v1, v2, v3)
	GLint location
	GLint v0
	GLint v1
	GLint v2
	GLint v3
	INIT:
		loadProc(glUniform4iARB,"glUniform4iARB");
	CODE:
	{
		glUniform4iARB(location, v0, v1, v2, v3);
	}

#//# glUniform1fvARB_c($location, $count, (CPTR)value);
void
glUniform1fvARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform1fvARB,"glUniform1fvARB");
	CODE:
		glUniform1fvARB(location, count, value);

#//# glUniform1fvARB_s($location, $count, (PACKED)value);
void
glUniform1fvARB_s(location, count, value)
	GLint	location
	GLsizei count
	SV	*value
	INIT:
		loadProc(glUniform1fvARB,"glUniform1fvARB");
	CODE:
	{
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniform1fvARB(location, count, value_s);
	}

#//# glUniform1fvARB_p(location, @value);
void
glUniform1fvARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform1fvARB,"glUniform1fvARB");
	CODE:
	{
		int i;
		GLsizei count = items - 1;
		GLfloat *value = malloc(sizeof(GLfloat) * count);

		for(i=0;i<count;i++) {
			value[i] = (GLfloat)SvNV(ST(i+1));
		}

		glUniform1fvARB(location, count, value);

		free(value);
	}

#//# glUniform2fvARB_c($location, $count, (CPTR)value);
void
glUniform2fvARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform2fvARB,"glUniform2fvARB");
	CODE:
		glUniform2fvARB(location, count, value);

#//# glUniform2fvARB_s($location, $count, (PACKED)value);
void
glUniform2fvARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform2fvARB,"glUniform2fvARB");
	CODE:
	{
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniform2fvARB(location, count, value_s);
	}

#//# glUniform2fvARB_p($location, @value);
void
glUniform2fvARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform2fvARB,"glUniform2fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements >> 1;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+1));
		}

		glUniform2fvARB(location, count, value);

		free(value);
	}

#//# glUniform3fvARB_c($location, $count, (CPTR)value);
void
glUniform3fvARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform3fvARB,"glUniform3fvARB");
	CODE:
		glUniform3fvARB(location, count, value);

#//# glUniform3fvARB_s($location, $count, (PACKED)value);
void
glUniform3fvARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform3fvARB,"glUniform3fvARB");
	CODE:
	{
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniform3fvARB(location, count, value_s);
	}

#//# glUniform3fvARB_p($location, @value);
void
glUniform3fvARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform3fvARB,"glUniform3fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements / 3;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+1));
		}

		glUniform3fvARB(location, count, value);

		free(value);
	}

#//# glUniform4fvARB_c($location, $count, (CPTR)value);
void
glUniform4fvARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform4fvARB,"glUniform4fvARB");
	CODE:
		glUniform4fvARB(location, count, value);

#//# glUniform4fvARB_s($location, $count, (PACKED)value);
void
glUniform4fvARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform4fvARB,"glUniform4fvARB");
	CODE:
	{
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniform4fvARB(location, count, value_s);
	}

#//# glUniform4fvARB_p($location, @value);
void
glUniform4fvARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform4fvARB,"glUniform4fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements >> 2;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+1));
		}

		glUniform4fvARB(location, count, value);

		free(value);
	}

#//# glUniform1ivARB_c($location, $count, (CPTR)value);
void
glUniform1ivARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform1ivARB,"glUniform1ivARB");
	CODE:
		glUniform1ivARB(location, count, value);

#//# glUniform1ivARB_s($location, $count, (PACKED)value);
void
glUniform1ivARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform1ivARB,"glUniform1ivARB");
	CODE:
	{
		GLint * value_s = EL(value, sizeof(GLint));
		glUniform1ivARB(location, count, value_s);
	}

#//# glUniform1ivARB_p($location, @value);
void
glUniform1ivARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform1ivARB,"glUniform1ivARB");
	CODE:
	{
		int i;
		GLsizei count = items - 1;
		GLint *value = malloc(sizeof(GLint) * count);

		for(i=0;i<count;i++) {
			value[i] = SvIV(ST(i+1));
		}

		glUniform1ivARB(location, count, value);

		free(value);
	}

#//# glUniform2ivARB_c($location, $count, (CPTR)value);
void
glUniform2ivARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform2ivARB,"glUniform2ivARB");
	CODE:
		glUniform2ivARB(location, count, value);

#//# glUniform2ivARB_s($location, $count, (PACKED)value);
void
glUniform2ivARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform2ivARB,"glUniform2ivARB");
	CODE:
	{
		GLint * value_s = EL(value, sizeof(GLint));
		glUniform2ivARB(location, count, value_s);
	}

#//# glUniform2ivARB_p($location, @value);
void
glUniform2ivARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform2ivARB,"glUniform2ivARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements >> 1;
		GLint *value = malloc(sizeof(GLint) * elements);

		for(i=0;i<elements;i++) {
			value[i] = SvIV(ST(i+1));
		}

		glUniform2ivARB(location, count, value);

		free(value);
	}

#//# glUniform3ivARB_c($location, $count, (CPTR)value);
void
glUniform3ivARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform3ivARB,"glUniform3ivARB");
	CODE:
		glUniform3ivARB(location, count, value);

#//# glUniform3ivARB_s($location, $count, (PACKED)value);
void
glUniform3ivARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform3ivARB,"glUniform3ivARB");
	CODE:
	{
		GLint * value_s = EL(value, sizeof(GLint));
		glUniform3ivARB(location, count, value_s);
	}

#//# glUniform3ivARB_p($location, @value);
void
glUniform3ivARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform3ivARB,"glUniform3ivARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements / 3;
		GLint *value = malloc(sizeof(GLint) * elements);

		for(i=0;i<elements;i++) {
			value[i] = SvIV(ST(i+1));
		}

		glUniform3ivARB(location, count, value);

		free(value);
	}

#//# glUniform4ivARB_c($location, $count, (CPTR)value);
void
glUniform4ivARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform4ivARB,"glUniform4ivARB");
	CODE:
		glUniform4ivARB(location, count, value);

#//# glUniform4ivARB_s($location, $count, (PACKED)value);
void
glUniform4ivARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform4ivARB,"glUniformifvARB");
	CODE:
	{
		GLint * value_s = EL(value, sizeof(GLint));
		glUniform4ivARB(location, count, value_s);
	}

#//# glUniform4ivARB_p($location, @value);
void
glUniform4ivARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform4ivARB,"glUniform4ivARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements >> 2;
		GLint *value = malloc(sizeof(GLint) * elements);

		for(i=0;i<elements;i++) {
			value[i] = SvIV(ST(i+1));
		}

		glUniform4ivARB(location, count, value);

		free(value);
	}

#//# glUniformMatrix2fvARB_c($location, $count, $transpose, (CPTR)value);
void
glUniformMatrix2fvARB_c(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	void	*value
	INIT:
		loadProc(glUniformMatrix2fvARB,"glUniformMatrix2fvARB");
	CODE:
		glUniformMatrix2fvARB(location, count, transpose, value);

#//# glUniformMatrix2fvARB_s($location, $count, $transpose, (PACKED)value);
void
glUniformMatrix2fvARB_s(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	SV	*value
	INIT:
		loadProc(glUniformMatrix2fvARB,"glUniformMatrix2fvARB");
	CODE:
	{
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniformMatrix2fvARB(location, count, transpose, value_s);
	}

#//# glUniformMatrix2fvARB_p($location, $transpose, @matrix);
void
glUniformMatrix2fvARB_p(location, transpose, ...)
	GLint location
	GLboolean transpose
	INIT:
		loadProc(glUniformMatrix2fvARB,"glUniformMatrix2fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 2;
		GLsizei count = elements / 4;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+2));
		}

		glUniformMatrix2fvARB(location, count, transpose, value);

		free(value);
	}

#//# glUniformMatrix3fvARB_c($location, $count, $transpose, (CPTR)value);
void
glUniformMatrix3fvARB_c(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	void	*value
	INIT:
		loadProc(glUniformMatrix3fvARB,"glUniformMatrix2fvARB");
	CODE:
		glUniformMatrix3fvARB(location, count, transpose, value);

#//# glUniformMatrix3fvARB_s($location, $count, $transpose, (PACKED)value);
void
glUniformMatrix3fvARB_s(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	SV	*value
	INIT:
		loadProc(glUniformMatrix3fvARB,"glUniformMatrix3fvARB");
	CODE:
	{
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniformMatrix3fvARB(location, count, transpose, value_s);
	}

#//# glUniformMatrix3fvARB_p($location, $transpose, @matrix);
void
glUniformMatrix3fvARB_p(location, transpose, ...)
	GLint location
	GLboolean transpose
	INIT:
		loadProc(glUniformMatrix3fvARB,"glUniformMatrix3fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 2;
		GLsizei count = elements / 9;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+2));
		}

		glUniformMatrix3fvARB(location, count, transpose, value);

		free(value);
	}

#//# glUniformMatrix4fvARB_c($location, $count, $transpose, (CPTR)value);
void
glUniformMatrix4fvARB_c(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	void	*value
	INIT:
		loadProc(glUniformMatrix4fvARB,"glUniformMatrix4fvARB");
	CODE:
		glUniformMatrix4fvARB(location, count, transpose, value);

#//# glUniformMatrix4fvARB_s($location, $count, $transpose, (PACKED)value);
void
glUniformMatrix4fvARB_s(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	SV	*value
	INIT:
		loadProc(glUniformMatrix4fvARB,"glUniformMatrix4fvARB");
	CODE:
	{
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniformMatrix4fvARB(location, count, transpose, value_s);
	}

#//# glUniformMatrix4fvARB_p($location, $transpose, @matrix);
void
glUniformMatrix4fvARB_p(location, transpose, ...)
	GLint location
	GLboolean transpose
	INIT:
		loadProc(glUniformMatrix4fvARB,"glUniformMatrix4fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 2;
		GLsizei count = elements / 16;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+2));
		}

		glUniformMatrix4fvARB(location, count, transpose, value);

		free(value);
	}

#//# glGetObjectParameterfvARB_c($obj,$pname,(CPTR)params);
void
glGetObjectParameterfvARB_c(obj,pname,params)
	GLhandleARB obj
	GLenum	pname
	void	*params
	INIT:
		loadProc(glGetObjectParameterfvARB,"glGetObjectParameterfvARB");
	CODE:
		glGetObjectParameterfvARB(obj,pname,params);

#//# glGetObjectParameterfvARB_s($obj,$pname,(PACKED)params);
void
glGetObjectParameterfvARB_s(obj,pname,params)
	GLhandleARB obj
	GLenum	pname
	SV	*params
	INIT:
		loadProc(glGetObjectParameterfvARB,"glGetObjectParameterfvARB");
	CODE:
	{
		GLfloat * params_s = EL(params, sizeof(GLfloat));
		glGetObjectParameterfvARB(obj,pname,params_s);
	}

#//# $param = glGetObjectParameterfvARB_p($obj,$pname);
GLfloat
glGetObjectParameterfvARB_p(obj,pname)
	GLhandleARB obj
	GLenum pname
	INIT:
		loadProc(glGetObjectParameterfvARB,"glGetObjectParameterfvARB");
	CODE:
	{
		GLfloat	ret;
		glGetObjectParameterfvARB(obj,pname,&ret);
		RETVAL = ret;
	}
	OUTPUT:
		RETVAL

#//# glGetObjectParameterivARB_c($obj,$pname,(CPTR)params);
void
glGetObjectParameterivARB_c(obj,pname,params)
	GLhandleARB obj
	GLenum	pname
	void	*params
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
	CODE:
		glGetObjectParameterivARB(obj,pname,params);

#//# glGetObjectParameterivARB_s($obj,$pname,(PACKED)params);
void
glGetObjectParameterivARB_s(obj,pname,params)
	GLhandleARB obj
	GLenum	pname
	SV	*params
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
	CODE:
	{
		GLint * params_s = EL(params, sizeof(GLint));
		glGetObjectParameterivARB(obj,pname,params_s);
	}

#//# $param = glGetObjectParameterivARB_c($obj,$pname);
GLint
glGetObjectParameterivARB_p(obj,pname)
	GLhandleARB obj
	GLenum pname
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
	CODE:
	{
		GLint	ret;
		glGetObjectParameterivARB(obj,pname,&ret);
		RETVAL = ret;
	}
	OUTPUT:
		RETVAL

#//# glGetInfoLogARB_c($obj, $maxLength, (CPTR)length, (CPTR)infoLog);
void
glGetInfoLogARB_c(obj, maxLength, length, infoLog)
	GLhandleARB obj
	GLsizei	maxLength
	void	*length
	void	*infoLog
	INIT:
		loadProc(glGetInfoLogARB,"glGetInfoLogARB");
	CODE:
		glGetInfoLogARB(obj, maxLength, length, infoLog);

#//# $infoLog = glGetInfoLogARB_c($obj);
SV *
glGetInfoLogARB_p(obj)
	GLhandleARB obj
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
		loadProc(glGetInfoLogARB,"glGetInfoLogARB");
	CODE:
	{
		GLint maxLength;
		glGetObjectParameterivARB(obj,GL_OBJECT_INFO_LOG_LENGTH_ARB,(GLvoid *)&maxLength);
		if (maxLength)
		{
			GLint length;
			GLcharARB * infoLog = malloc(maxLength+1);
			glGetInfoLogARB(obj,maxLength,&length,infoLog);
			infoLog[length] = 0;
			if (*infoLog)
				RETVAL = newSVpv(infoLog, 0);
			else
				RETVAL = newSVsv(&PL_sv_undef);

			free(infoLog);
		}
		else
		{
			RETVAL = newSVsv(&PL_sv_undef);
		}
	}
	OUTPUT:
		RETVAL

#//# glGetAttachedObjectsARB_c($containerObj, $maxCount, (CPTR)count, (CPTR)obj);
void
glGetAttachedObjectsARB_c(containerObj, maxCount, count, obj)
	GLhandleARB containerObj
	GLsizei	maxCount
	void	*count
	void	*obj
	INIT:
		loadProc(glGetAttachedObjectsARB,"glGetAttachedObjectsARB");
	CODE:
		glGetAttachedObjectsARB(containerObj, maxCount, count, obj);

#//# glGetAttachedObjectsARB_s($containerObj, $maxCount, (PACKED)count, (PACKED)obj);
void
glGetAttachedObjectsARB_s(containerObj, maxCount, count, obj)
	GLhandleARB containerObj
	GLsizei	maxCount
	void	*count
	SV	*obj
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
		loadProc(glGetAttachedObjectsARB,"glGetAttachedObjectsARB");
	CODE:
	{
		GLint len;
		glGetObjectParameterivARB(containerObj,GL_OBJECT_ATTACHED_OBJECTS_ARB,
			(GLvoid *)&len);
		if (len)
		{
			GLsizei * count_s = EL(count, sizeof(GLsizei));
			GLhandleARB * obj_s = EL(obj, sizeof(GLhandleARB)*len);
			glGetAttachedObjectsARB(containerObj, maxCount, count_s, obj_s);
		}
	}

#//# @objs = glGetAttachedObjectsARB_p($containerObj);
void
glGetAttachedObjectsARB_p(containerObj)
	GLhandleARB containerObj
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
		loadProc(glGetAttachedObjectsARB,"glGetAttachedObjectsARB");
	PPCODE:
	{
		GLsizei maxCount;
		GLsizei count;
		GLhandleARB *obj;
		int i;

		glGetObjectParameterivARB(containerObj,GL_OBJECT_ATTACHED_OBJECTS_ARB,
			(GLvoid *)&maxCount);
		obj = malloc(sizeof(GLhandleARB)*maxCount);

		glGetAttachedObjectsARB(containerObj, maxCount, &count, obj);

		EXTEND(sp, count);
		for(i=0;i<count;i++)
			PUSHs(sv_2mortal(newSViv(obj[i])));

		free(obj);
	}

#//# glGetUniformLocationARB_c($programObj, (CPTR)name);
GLint
glGetUniformLocationARB_c(programObj, name)
	GLhandleARB programObj
	void	*name
	INIT:
		loadProc(glGetUniformLocationARB,"glGetUniformLocationARB");
	CODE:
		RETVAL = glGetUniformLocationARB(programObj, name);
	OUTPUT:
		RETVAL

#//# $value = glGetUniformLocationARB_p($programObj, $name);
GLint
glGetUniformLocationARB_p(programObj, ...)
	GLhandleARB programObj
	INIT:
		loadProc(glGetUniformLocationARB,"glGetUniformLocationARB");
	CODE:
	{
		GLcharARB *name = (GLcharARB *)SvPV(ST(1),PL_na);
		RETVAL = glGetUniformLocationARB(programObj, name);
	}
	OUTPUT:
		RETVAL

#//# glGetActiveUniformARB_c($programObj, $index, $maxLength, (CPTR)length, (CPTR)size, (CPTR)type, (CPTR)name);
void
glGetActiveUniformARB_c(programObj, index, maxLength, length, size, type, name)
	GLhandleARB programObj
	GLuint	index
	GLsizei	maxLength
	void	*length
	void	*size
	void	*type
	void	*name
	INIT:
		loadProc(glGetActiveUniformARB,"glGetActiveUniformARB");
	CODE:
		glGetActiveUniformARB(programObj,index,maxLength,length,size,type,name);

#//# glGetActiveUniformARB_s($programObj, $index, $maxLength, (PACKED)length, (PACKED)size, (PACKED)type, (PACKED)name);
void
glGetActiveUniformARB_s(programObj, index, maxLength, length, size, type, name)
	GLhandleARB programObj
	GLuint	index
	GLsizei	maxLength
	SV	*length
	SV	*size
	SV	*type
	SV	*name
	INIT:
		loadProc(glGetActiveUniformARB,"glGetActiveUniformARB");
	CODE:
	{
		GLsizei	  *length_s = EL(length, sizeof(GLsizei));
		GLint	  *size_s = EL(size, sizeof(GLint));
		GLenum	  *type_s = EL(type, sizeof(GLenum));
		GLcharARB *name_s = EL(name, sizeof(GLcharARB));
		glGetActiveUniformARB(programObj,index,maxLength,length_s,size_s,type_s,name_s);
	}

#//# ($name,$type,$size) = glGetActiveUniformARB_p($programObj, $index);
void
glGetActiveUniformARB_p(programObj, index)
	GLhandleARB programObj
	GLuint index
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
		loadProc(glGetActiveUniformARB,"glGetActiveUniformARB");
	PPCODE:
	{
		GLsizei maxLength;
		glGetObjectParameterivARB(programObj,GL_OBJECT_ACTIVE_UNIFORM_MAX_LENGTH_ARB,
			(GLvoid *)&maxLength);
		if (maxLength)
		{
			GLsizei length;
			GLint size;
			GLenum type;
			GLcharARB *name;

			name = malloc(maxLength+1);
			glGetActiveUniformARB(programObj,index,maxLength,
				&length,&size,&type,name);
			name[length] = 0;

			if (*name)
			{
				EXTEND(sp,3);
				PUSHs(sv_2mortal(newSVpv(name,0)));
				PUSHs(sv_2mortal(newSViv(type)));
				PUSHs(sv_2mortal(newSViv(size)));
			}
			else
			{
				EXTEND(sp,1);
				PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
			}

			free(name);
		}
		else
		{
			EXTEND(sp,1);
			PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
		}
	}

#//# glGetUniformfvARB_c($programObj, $location, (CPTR)params);
void
glGetUniformfvARB_c(programObj, location, params)
	GLhandleARB programObj
	GLint	location
	void	*params
	INIT:
		loadProc(glGetUniformfvARB,"glGetUniformfvARB");
	CODE:
		glGetUniformfvARB(programObj, location, params);

#//# @params = glGetUniformfvARB_p($programObj, $location[, $count]);
void
glGetUniformfvARB_p(programObj, location, count=1)
	GLhandleARB programObj
	GLint location
	int count
	INIT:
		loadProc(glGetUniformfvARB,"glGetUniformfvARB");
	CODE:
	{
		int i;
		GLfloat	*ret = malloc(sizeof(GLfloat)*count);
		glGetUniformfvARB(programObj, location, ret);

		for(i=0;i<count;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#//# glGetUniformivARB_c($programObj, $location, (CPTR)params);
void
glGetUniformivARB_c(programObj, location, params)
	GLhandleARB programObj
	GLint	location
	void	*params
	INIT:
		loadProc(glGetUniformivARB,"glGetUniformivARB");
	CODE:
		glGetUniformivARB(programObj, location, params);

#//# @params = glGetUniformivARB_p($programObj, $location[, $count]);
void
glGetUniformivARB_p(programObj, location, count=1)
	GLhandleARB programObj
	GLint	location
	int count
	INIT:
		loadProc(glGetUniformivARB,"glGetUniformivARB");
	CODE:
	{
		int i;
		GLint	*ret = malloc(sizeof(GLint)*count);
		glGetUniformivARB(programObj, location, ret);

		for(i=0;i<count;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#//# glGetShaderSourceARB_c($obj, $maxLength, (CPTR)length, (CPTR)source);
void
glGetShaderSourceARB_c(obj, maxLength, length, source)
	GLhandleARB obj
	GLsizei	maxLength
	void	*length
	void	*source
	INIT:
		loadProc(glGetShaderSourceARB,"glGetShaderSourceARB");
	CODE:
		glGetShaderSourceARB(obj, maxLength, length, source);

#//# $source = glGetShaderSourceARB_p($obj);
void
glGetShaderSourceARB_p(obj)
	GLhandleARB obj
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
		loadProc(glGetShaderSourceARB,"glGetShaderSourceARB");
	PPCODE:
	{
		GLsizei maxLength;
		glGetObjectParameterivARB(obj,GL_OBJECT_SHADER_SOURCE_LENGTH_ARB,
			(GLvoid *)&maxLength);

		EXTEND(sp,1);

		if (maxLength)
		{
			GLsizei length;
			GLcharARB *source;

			source = malloc(maxLength+1);
			glGetShaderSourceARB(obj,maxLength,&length,source);
			source[length] = 0;

			if (*source)
			{
				PUSHs(sv_2mortal(newSVpv(source,0)));
			}
			else
			{
				PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
			}

			free(source);
		}
		else
		{
			PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
		}
	}

#endif


#ifdef GL_ARB_vertex_program

#//# glProgramStringARB_c($target,$format,$len,(CPTR)string);
void
glProgramStringARB_c(target,format,len,string)
	GLenum target
	GLenum format
	GLsizei len
	void * string
	INIT:
		loadProc(glProgramStringARB,"glProgramStringARB");
	CODE:
		glProgramStringARB(target,format,len,string);

#//# glProgramStringARB_s($target,$format,$len,(PACKED)string);
void
glProgramStringARB_s(target,format,len,string)
	GLenum target
	GLenum format
	GLsizei len
	SV *	string
	INIT:
		loadProc(glProgramStringARB,"glProgramStringARB");
	CODE:
	{
		GLvoid * string_s = EL(string, len);
		glProgramStringARB(target,format,len,string_s);
	}

#//# glProgramStringARB_p($target,$string);
#//- Assumes GL_PROGRAM_FORMAT_ASCII_ARB
void
glProgramStringARB_p(target,string)
	GLenum target
	char * string
	INIT:
		loadProc(glProgramStringARB,"glProgramStringARB");
	CODE:
	{
		int len = strlen(string);
		glProgramStringARB(target,GL_PROGRAM_FORMAT_ASCII_ARB,len,string);
	}

#//# glBindProgramARB($target,$program);
void
glBindProgramARB(target,program)
	GLenum target
	GLuint program
	INIT:
		loadProc(glBindProgramARB,"glBindProgramARB");

#//# glDeleteProgramsARB_c($n,(CPTR)programs);
void
glDeleteProgramsARB_c(n,programs)
	GLsizei n
	void *	programs
	INIT:
		loadProc(glDeleteProgramsARB,"glDeleteProgramsARB");
	CODE:
	{
		glDeleteProgramsARB(n,(GLuint*)programs);
	}

#//# glDeleteProgramsARB_c($n,(PACKED)programs);
void
glDeleteProgramsARB_s(n,programs)
	GLsizei n
	SV *	programs
	INIT:
		loadProc(glDeleteProgramsARB,"glDeleteProgramsARB");
	CODE:
	{
		GLuint * programs_s = EL(programs, sizeof(GLuint)*n);
		glDeleteProgramsARB(n,programs_s);
	}

#//# glDeleteProgramsARB_p(@programIDs);
void
glDeleteProgramsARB_p(...)
	INIT:
		loadProc(glDeleteProgramsARB,"glDeleteProgramsARB");
	CODE:
	{
		if (items) {
			GLuint * list = malloc(sizeof(GLuint) * items);
			int i;

			for (i=0;i<items;i++)
				list[i] = SvIV(ST(i));

			glDeleteProgramsARB(items, list);
			free(list);
		}
	}

#//# glGenProgramsARB_c($n,(CPTR)programs);
void
glGenProgramsARB_c(n,programs)
	GLsizei n
	void *	programs
	INIT:
		loadProc(glGenProgramsARB,"glGenProgramsARB");
	CODE:
	{
		glGenProgramsARB(n,(GLuint*)programs);
	}

#//# glGenProgramsARB_s($n,(PACKED)programs);
void
glGenProgramsARB_s(n,programs)
	GLsizei n
	SV *	programs
	INIT:
		loadProc(glGenProgramsARB,"glGenProgramsARB");
	CODE:
	{
		GLuint * programs_s = EL(programs, sizeof(GLuint)*n);
		glGenProgramsARB(n, programs_s);
	}

#//# @programIDs = glGenProgramsARB_c($n);
void
glGenProgramsARB_p(n)
	GLsizei n
	INIT:
		loadProc(glGenProgramsARB,"glGenProgramsARB");
	PPCODE:
	if (n)
	{
		GLuint * programs = malloc(sizeof(GLuint) * n);
		int i;

		glGenProgramsARB(n, programs);

		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(programs[i])));

		free(programs);
	} 

#//# glProgramEnvParameter4dARB($target,$index,$x,$y,$z,$w);
void
glProgramEnvParameter4dARB(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLdouble x
	GLdouble y
	GLdouble z
	GLdouble w
	INIT:
		loadProc(glProgramEnvParameter4dARB,"glProgramEnvParameter4dARB");

#//# glProgramEnvParameter4dvARB_c($target,$index,(CPTR)v);
void
glProgramEnvParameter4dvARB_c(target,index,v)
	GLenum target
	GLuint index
	void *	v
	INIT:
		loadProc(glProgramEnvParameter4dvARB,"glProgramEnvParameter4dvARB");
	CODE:
		glProgramEnvParameter4dvARB(target,index,(GLdouble*)v);

#//# glProgramEnvParameter4dvARB_s($target,$index,(PACKED)v);
void
glProgramEnvParameter4dvARB_s(target,index,v)
	GLenum target
	GLuint index
	SV *	v
	INIT:
		loadProc(glProgramEnvParameter4dvARB,"glProgramEnvParameter4dvARB");
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glProgramEnvParameter4dvARB(target,index,v_s);
	}

#//!!! Do we really need this?  It duplicates glProgramEnvParameter4dARB
#//# glProgramEnvParameter4dvARB_p($target,$index,$x,$y,$z,$w);
void
glProgramEnvParameter4dvARB_p(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w
	INIT:
		loadProc(glProgramEnvParameter4dvARB,"glProgramEnvParameter4dvARB");
	CODE:
	{
		GLdouble param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glProgramEnvParameter4dvARB(target,index,param);
	}

#//# glProgramEnvParameter4fARB($target,$index,$x,$y,$z,$w);
void
glProgramEnvParameter4fARB(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLfloat x
	GLfloat y
	GLfloat z
	GLfloat w
	INIT:
		loadProc(glProgramEnvParameter4fARB,"glProgramEnvParameter4fARB");

#//# glProgramEnvParameter4fvARB_c($target,$index,(CPTR)v);
void
glProgramEnvParameter4fvARB_c(target,index,v)
	GLenum target
	GLuint index
	void *	v
	INIT:
		loadProc(glProgramEnvParameter4fvARB,"glProgramEnvParameter4fvARB");
	CODE:
		glProgramEnvParameter4fvARB(target,index,(GLfloat*)v);

#//# glProgramEnvParameter4fvARB_s($target,$index,(PACKED)v);
void
glProgramEnvParameter4fvARB_s(target,index,v)
	GLenum target
	GLuint index
	SV *	v
	INIT:
		loadProc(glProgramEnvParameter4fvARB,"glProgramEnvParameter4fvARB");
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glProgramEnvParameter4fvARB(target,index,v_s);
	}

#//!!! Do we really need this?  It duplicates glProgramEnvParameter4fARB
#//# glProgramEnvParameter4fvARB_p($target,$index,$x,$y,$z,$w);
void
glProgramEnvParameter4fvARB_p(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w
	INIT:
		loadProc(glProgramEnvParameter4fvARB,"glProgramEnvParameter4fvARB");
	CODE:
	{
		GLfloat param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glProgramEnvParameter4fvARB(target,index,param);
	}

#//# glProgramLocalParameter4dARB($target,$index,$x,$y,$z,$w);
void
glProgramLocalParameter4dARB(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLdouble x
	GLdouble y
	GLdouble z
	GLdouble w
	INIT:
		loadProc(glProgramLocalParameter4dARB,"glProgramLocalParameter4dARB");

#//# glProgramLocalParameter4dvARB_c($target,$index,(CPTR)v);
void
glProgramLocalParameter4dvARB_c(target,index,v)
	GLenum target
	GLuint index
	void *	v
	INIT:
		loadProc(glProgramLocalParameter4dvARB,"glProgramLocalParameter4dvARB");
	CODE:
		glProgramLocalParameter4dvARB(target,index,(GLdouble*)v);

#//# glProgramLocalParameter4dvARB_s($target,$index,(PACKED)v);
void
glProgramLocalParameter4dvARB_s(target,index,v)
	GLenum target
	GLuint index
	SV *	v
	INIT:
		loadProc(glProgramLocalParameter4dvARB,"glProgramLocalParameter4dvARB");
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glProgramLocalParameter4dvARB(target,index,v_s);
	}

#//!!! Do we really need this?  It duplicates glProgramLocalParameter4dARB
#//# glProgramLocalParameter4dvARB_p($target,$index,$x,$y,$z,$w);
void
glProgramLocalParameter4dvARB_p(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w
	INIT:
		loadProc(glProgramLocalParameter4dvARB,"glProgramLocalParameter4dvARB");
	CODE:
	{
		GLdouble param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glProgramLocalParameter4dvARB(target,index,param);
	}

#//# glProgramLocalParameter4fARB($target,$index,$x,$y,$z,$w);
void
glProgramLocalParameter4fARB(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLfloat x
	GLfloat y
	GLfloat z
	GLfloat w
	INIT:
		loadProc(glProgramLocalParameter4fARB,"glProgramLocalParameter4fARB");

#//# glProgramLocalParameter4fvARB_c($target,$index,(CPTR)v);
void
glProgramLocalParameter4fvARB_c(target,index,v)
	GLenum target
	GLuint index
	void *	v
	INIT:
		loadProc(glProgramLocalParameter4fvARB,"glProgramLocalParameter4fvARB");
	CODE:
		glProgramLocalParameter4fvARB(target,index,(GLfloat*)v);

#//# glProgramLocalParameter4fvARB_s($target,$index,(PACKED)v);
void
glProgramLocalParameter4fvARB_s(target,index,v)
	GLenum target
	GLuint index
	SV *	v
	INIT:
		loadProc(glProgramLocalParameter4fvARB,"glProgramLocalParameter4fvARB");
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glProgramLocalParameter4fvARB(target,index,v_s);
	}

#//!!! Do we really need this?  It duplicates glProgramLocalParameter4fARB
#//# glProgramLocalParameter4fvARB_p($target,$index,$x,$y,$z,$w);
void
glProgramLocalParameter4fvARB_p(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w
	INIT:
		loadProc(glProgramLocalParameter4fvARB,"glProgramLocalParameter4fvARB");
	CODE:
	{
		GLfloat param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glProgramLocalParameter4fvARB(target,index,param);
	}

#//# glGetProgramEnvParameterdvARB_c($target,$index,(CPTR)params);
void
glGetProgramEnvParameterdvARB_c(target,index,params)
	GLenum	target
	GLint	index
	void *	params
	INIT:
		loadProc(glGetProgramEnvParameterdvARB,"glGetProgramEnvParameterdvARB");
	CODE:
		glGetProgramEnvParameterdvARB(target,index,(GLdouble*)params);

#//# glGetProgramEnvParameterdvARB_s($target,$index,(PACKED)params);
void
glGetProgramEnvParameterdvARB_s(target,index,params)
	GLenum	target
	GLint	index
	SV *	params
	INIT:
		loadProc(glGetProgramEnvParameterdvARB,"glGetProgramEnvParameterdvARB");
	CODE:
	{
		GLdouble * params_s = EL(params, sizeof(GLdouble) * 4);
		glGetProgramEnvParameterdvARB(target,index,params_s);
	}

#//# @params = glGetProgramEnvParameterdvARB_p($target,$index);
void
glGetProgramEnvParameterdvARB_p(target,index)
	GLenum	target
	GLint	index
	INIT:
		loadProc(glGetProgramEnvParameterdvARB,"glGetProgramEnvParameterdvARB");
	PPCODE:
	{
		GLdouble params[4];
		glGetProgramEnvParameterdvARB(target,index,params);

		EXTEND(sp, 4);
		PUSHs(sv_2mortal(newSVnv(params[0])));
		PUSHs(sv_2mortal(newSVnv(params[1])));
		PUSHs(sv_2mortal(newSVnv(params[2])));
		PUSHs(sv_2mortal(newSVnv(params[3])));
	}

#//# glGetProgramEnvParameterfvARB_c($target,$index,(CPTR)params);
void
glGetProgramEnvParameterfvARB_c(target,index,params)
	GLenum	target
	GLint	index
	void *	params
	INIT:
		loadProc(glGetProgramEnvParameterfvARB,"glGetProgramEnvParameterfvARB");
	CODE:
		glGetProgramEnvParameterfvARB(target,index,(GLfloat*)params);

#//# glGetProgramEnvParameterfvARB_s($target,$index,(PACKED)params);
void
glGetProgramEnvParameterfvARB_s(target,index,params)
	GLenum	target
	GLint	index
	SV *	params
	INIT:
		loadProc(glGetProgramEnvParameterfvARB,"glGetProgramEnvParameterfvARB");
	CODE:
	{
		GLfloat * params_s = EL(params, sizeof(GLfloat) * 4);
		glGetProgramEnvParameterfvARB(target,index,params_s);
	}

#//# @params = glGetProgramEnvParameterfvARB_p($target,$index);
void
glGetProgramEnvParameterfvARB_p(target,index)
	GLenum	target
	GLint	index
	INIT:
		loadProc(glGetProgramEnvParameterfvARB,"glGetProgramEnvParameterfvARB");
	PPCODE:
	{
		GLfloat params[4];
		glGetProgramEnvParameterfvARB(target,index,params);

		EXTEND(sp, 4);
		PUSHs(sv_2mortal(newSVnv(params[0])));
		PUSHs(sv_2mortal(newSVnv(params[1])));
		PUSHs(sv_2mortal(newSVnv(params[2])));
		PUSHs(sv_2mortal(newSVnv(params[3])));
	}

#//# glGetProgramLocalParameterdvARB_c($target,$index,(CPTR)params);
void
glGetProgramLocalParameterdvARB_c(target,index,params)
	GLenum	target
	GLint	index
	void *	params
	INIT:
		loadProc(glGetProgramLocalParameterdvARB,"glGetProgramLocalParameterdvARB");
	CODE:
		glGetProgramLocalParameterdvARB(target,index,(GLdouble*)params);

#//# glGetProgramLocalParameterdvARB_s($target,$index,(PACKED)params);
void
glGetProgramLocalParameterdvARB_s(target,index,params)
	GLenum	target
	GLint	index
	SV *	params
	INIT:
		loadProc(glGetProgramLocalParameterdvARB,"glGetProgramLocalParameterdvARB");
	CODE:
	{
		GLdouble * params_s = EL(params, sizeof(GLdouble) * 4);
		glGetProgramLocalParameterdvARB(target,index,params_s);
	}

#//# @params = glGetProgramLocalParameterdvARB_p($target,$index);
void
glGetProgramLocalParameterdvARB_p(target,index)
	GLenum	target
	GLint	index
	INIT:
		loadProc(glGetProgramLocalParameterdvARB,"glGetProgramLocalParameterdvARB");
	PPCODE:
	{
		GLdouble params[4];
		glGetProgramLocalParameterdvARB(target,index,params);

		EXTEND(sp, 4);
		PUSHs(sv_2mortal(newSVnv(params[0])));
		PUSHs(sv_2mortal(newSVnv(params[1])));
		PUSHs(sv_2mortal(newSVnv(params[2])));
		PUSHs(sv_2mortal(newSVnv(params[3])));
	}

#//# glGetProgramLocalParameterfvARB_c($target,$index,(CPTR)params);
void
glGetProgramLocalParameterfvARB_c(target,index,params)
	GLenum	target
	GLint	index
	void *	params
	INIT:
		loadProc(glGetProgramLocalParameterfvARB,"glGetProgramLocalParameterfvARB");
	CODE:
		glGetProgramLocalParameterfvARB(target,index,(GLfloat*)params);

#//# glGetProgramLocalParameterfvARB_s($target,$index,(PACKED)params);
void
glGetProgramLocalParameterfvARB_s(target,index,params)
	GLenum	target
	GLint	index
	SV *	params
	INIT:
		loadProc(glGetProgramLocalParameterfvARB,"glGetProgramLocalParameterfvARB");
	CODE:
	{
		GLfloat * params_s = EL(params, sizeof(GLfloat) * 4);
		glGetProgramLocalParameterfvARB(target,index,params_s);
	}

#//# @params = glGetProgramLocalParameterfvARB_p($target,$index);
void
glGetProgramLocalParameterfvARB_p(target,index)
	GLenum	target
	GLint	index
	INIT:
		loadProc(glGetProgramLocalParameterfvARB,"glGetProgramLocalParameterfvARB");
	PPCODE:
	{
		GLfloat params[4];
		glGetProgramLocalParameterfvARB(target,index,params);

		EXTEND(sp, 4);
		PUSHs(sv_2mortal(newSVnv(params[0])));
		PUSHs(sv_2mortal(newSVnv(params[1])));
		PUSHs(sv_2mortal(newSVnv(params[2])));
		PUSHs(sv_2mortal(newSVnv(params[3])));
	}

#//# glGetProgramivARB_c($target,$pname,(CPTR)params);
void
glGetProgramivARB_c(target,pname,params)
	GLenum	target
	GLenum	pname
	void *	params
	INIT:
		loadProc(glGetProgramivARB,"glGetProgramivARB");
	CODE:
		glGetProgramivARB(target,pname,params);

#//# glGetProgramivARB_s($target,$pname,(PACKED)params);
void
glGetProgramivARB_s(target,pname,params)
	GLenum	target
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetProgramivARB,"glGetProgramivARB");
	CODE:
	{
		GLint * params_s = EL(params, sizeof(GLint)*gl_get_count(pname));
		glGetProgramivARB(target,pname,params_s);
	}

#//# $value = glGetProgramivARB_p($target,$pname);
GLuint
glGetProgramivARB_p(target,pname)
	GLenum	target
	GLenum	pname
	INIT:
		loadProc(glGetProgramivARB,"glGetProgramivARB");
	CODE:
	{
		GLuint param;
		glGetProgramivARB(target,pname,(void *)&param);
		RETVAL = param;
	}
	OUTPUT:
		RETVAL

#//# glGetProgramStringARB_c(target,pname,(CPTR)string);
void
glGetProgramStringARB_c(target,pname,string)
	GLenum	target
	GLenum	pname
	void *	string
	INIT:
		loadProc(glGetProgramStringARB,"glGetProgramStringARB");
	CODE:
		glGetProgramStringARB(target,pname,string);

#//# glGetProgramStringARB_s(target,pname,(PACKED)string);
void
glGetProgramStringARB_s(target,pname,string)
	GLenum	target
	GLenum	pname
	SV *	string
	INIT:
		loadProc(glGetProgramivARB,"glGetProgramivARB");
		loadProc(glGetProgramStringARB,"glGetProgramStringARB");
	CODE:
	{
		GLint len;
		glGetProgramivARB(target,GL_PROGRAM_LENGTH_ARB,(GLvoid *)&len);
		if (len)
		{
			GLubyte * string_s = EL(string, sizeof(GLubyte)*len);
			glGetProgramStringARB(target,pname,string_s);
		}
	}

#//# $string = glGetProgramStringARB_p(target[,pname]);
#//- Defaults to GL_PROGRAM_STRING_ARB
SV *
glGetProgramStringARB_p(target,pname=GL_PROGRAM_STRING_ARB)
	GLenum	target
	GLenum	pname
	INIT:
		loadProc(glGetProgramivARB,"glGetProgramivARB");
		loadProc(glGetProgramStringARB,"glGetProgramStringARB");
	CODE:
	{
		GLint len;
		glGetProgramivARB(target,GL_PROGRAM_LENGTH_ARB,(GLvoid *)&len);
		if (len)
		{
			char * string = malloc(len+1);
			glGetProgramStringARB(target,pname,(GLubyte*)string);
			string[len] = 0;
			if (*string)
				RETVAL = newSVpv(string, 0);
			else
				RETVAL = newSVsv(&PL_sv_undef);

			free(string);
		}
		else
		{
			RETVAL = newSVsv(&PL_sv_undef);
		}
	}
	OUTPUT:
		RETVAL

#//# glIsProgramARB(program);
GLboolean
glIsProgramARB(program)
	GLuint	program
	INIT:
		loadProc(glIsProgramARB,"glIsProgramARB");
	CODE:
	{
		RETVAL = glIsProgramARB(program);
	}
	OUTPUT:
		RETVAL

#endif


#if defined(GL_ARB_vertex_program) || defined(GL_ARB_vertex_shader)

#//# glVertexAttrib1dARB($index,$x);
void
glVertexAttrib1dARB(index,x)
	GLuint index
	GLdouble x
	INIT:
		loadProc(glVertexAttrib1dARB,"glVertexAttrib1dARB");

#//# glVertexAttrib1dvARB_c($index,(CPTR)v);
void
glVertexAttrib1dvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib1dvARB,"glVertexAttrib1dvARB");
	CODE:
		glVertexAttrib1dvARB(index,(GLdouble*)v);

#//# glVertexAttrib1dvARB_s($index,(PACKED)v);
void
glVertexAttrib1dvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib1dvARB,"glVertexAttrib1dvARB");
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*1);
		glVertexAttrib1dvARB(index,v_s);
	}

#//!!! Do we really need this?  It duplicates glVertexAttrib1dARB
#//# glVertexAttrib1dvARB_p($index,$x);
void
glVertexAttrib1dvARB_p(index,x)
	GLuint index
	GLdouble	x
	INIT:
		loadProc(glVertexAttrib1dvARB,"glVertexAttrib1dvARB");
	CODE:
	{
		GLdouble param[1];
		param[0] = x;
		glVertexAttrib1dvARB(index,param);
	}

#//# glVertexAttrib1fARB($index,$x);
void
glVertexAttrib1fARB(index,x)
	GLuint index
	GLfloat x
	INIT:
		loadProc(glVertexAttrib1fARB,"glVertexAttrib1fARB");

#//# glVertexAttrib1sARB($index,$x);
void
glVertexAttrib1sARB(index,x)
	GLuint index
	GLshort x
	INIT:
		loadProc(glVertexAttrib1s,"glVertexAttrib1s");

#//# glVertexAttrib1svARB_c($index,(CPTR)v);
void
glVertexAttrib1svARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib1svARB,"glVertexAttrib1svARB");
	CODE:
		glVertexAttrib1svARB(index,(GLshort*)v);

#//# glVertexAttrib1svARB_s($index,(PACKED)v);
void
glVertexAttrib1svARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib1svARB,"glVertexAttrib1svARB");
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*1);
		glVertexAttrib1svARB(index,v_s);
	}

#//!!! Do we really need this?  It duplicates glVertexAttrib1sARB
#//# glVertexAttrib1svARB_p($index,$x);
void
glVertexAttrib1svARB_p(index,x)
	GLuint index
	GLshort	x
	INIT:
		loadProc(glVertexAttrib1svARB,"glVertexAttrib1svARB");
	CODE:
	{
		GLshort param[1];
		param[0] = x;
		glVertexAttrib1svARB(index,param);
	}

#//# glVertexAttrib2dARB($index,$x,$y);
void
glVertexAttrib2dARB(index,x,y)
	GLuint index
	GLdouble x
	GLdouble y
	INIT:
		loadProc(glVertexAttrib2dARB,"glVertexAttrib2dARB");

#//# glVertexAttrib2dvARB_c($index,(CPTR)v);
void
glVertexAttrib2dvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib2dvARB,"glVertexAttrib2dvARB");
	CODE:
		glVertexAttrib2dvARB(index,(GLdouble*)v);

#//# glVertexAttrib2dvARB_s($index,(PACKED)v);
void
glVertexAttrib2dvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib2dvARB,"glVertexAttrib2dvARB");
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glVertexAttrib2dvARB(index,v_s);
	}

#//!!! Do we really need this?  It duplicates glVertexAttrib2dARB
#//# glVertexAttrib2dvARB_p($index,$x,$y);
void
glVertexAttrib2dvARB_p(index,x,y)
	GLuint index
	GLdouble	x
	GLdouble	y
	INIT:
		loadProc(glVertexAttrib2dvARB,"glVertexAttrib2dvARB");
	CODE:
	{
		GLdouble param[2];
		param[0] = x;
		param[1] = y;
		glVertexAttrib2dvARB(index,param);
	}

#//# glVertexAttrib2fARB($index,$x,$y);
void
glVertexAttrib2fARB(index,x,y)
	GLuint index
	GLfloat x
	GLfloat y
	INIT:
		loadProc(glVertexAttrib2fARB,"glVertexAttrib2fARB");

#//# glVertexAttrib2sARB($index,$x,$y);
void
glVertexAttrib2sARB(index,x,y)
	GLuint index
	GLshort x
	GLshort y
	INIT:
		loadProc(glVertexAttrib2sARB,"glVertexAttrib2sARB");

#//# glVertexAttrib2svARB_c($index,(CPTR)v);
void
glVertexAttrib2svARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib2svARB,"glVertexAttrib2svARB");
	CODE:
		glVertexAttrib2svARB(index,(GLshort*)v);

#//# glVertexAttrib2svARB_s($index,(PACKED)v);
void
glVertexAttrib2svARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib2svARB,"glVertexAttrib2svARB");
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glVertexAttrib2svARB(index,v_s);
	}

#//!!! Do we really need this?  It duplicates glVertexAttrib2sARB
#//# glVertexAttrib2svARB_p($index,$x,$y);
void
glVertexAttrib2svARB_p(index,x,y)
	GLuint index
	GLshort	x
	GLshort	y
	INIT:
		loadProc(glVertexAttrib2svARB,"glVertexAttrib2svARB");
	CODE:
	{
		GLshort param[2];
		param[0] = x;
		param[1] = y;
		glVertexAttrib2svARB(index,param);
	}

#//# glVertexAttrib3dARB($index,$x,$y,$z);
void
glVertexAttrib3dARB(index,x,y,z)
	GLuint index
	GLdouble x
	GLdouble y
	GLdouble z
	INIT:
		loadProc(glVertexAttrib3dARB,"glVertexAttrib3dARB");

#//# glVertexAttrib3dvARB_c($index,(CPTR)v);
void
glVertexAttrib3dvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib3dvARB,"glVertexAttrib3dvARB");
	CODE:
		glVertexAttrib3dvARB(index,(GLdouble*)v);

#//# glVertexAttrib3dvARB_s($index,(PACKED)v);
void
glVertexAttrib3dvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib3dvARB,"glVertexAttrib3dvARB");
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glVertexAttrib3dvARB(index,v_s);
	}

#//!!! Do we really need this?  It duplicates glVertexAttrib3dARB
#//# glVertexAttrib3dvARB_p($index,$x,$y,$z);
void
glVertexAttrib3dvARB_p(index,x,y,z)
	GLuint index
	GLdouble	x
	GLdouble	y
	GLdouble	z
	INIT:
		loadProc(glVertexAttrib3dvARB,"glVertexAttrib3dvARB");
	CODE:
	{
		GLdouble param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertexAttrib3dvARB(index,param);
	}

#//# glVertexAttrib3fARB($index,$x,$y,$z);
void
glVertexAttrib3fARB(index,x,y,z)
	GLuint index
	GLfloat x
	GLfloat y
	GLfloat z
	INIT:
		loadProc(glVertexAttrib3fARB,"glVertexAttrib3fARB");

#//# glVertexAttrib3fvARB_c($index,(CPTR)v);
void
glVertexAttrib3fvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib3fvARB,"glVertexAttrib3fvARB");
	CODE:
		glVertexAttrib3fvARB(index,(GLfloat*)v);

#//# glVertexAttrib3fvARB_s($index,(PACKED)v);
void
glVertexAttrib3fvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib3fvARB,"glVertexAttrib3fvARB");
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glVertexAttrib3fvARB(index,v_s);
	}

#//!!! Do we really need this?  It duplicates glVertexAttrib3fARB
#//# glVertexAttrib3fvARB_p($index,$x,$y,$z);
void
glVertexAttrib3fvARB_p(index,x,y,z)
	GLuint index
	GLfloat	x
	GLfloat	y
	GLfloat	z
	INIT:
		loadProc(glVertexAttrib3fvARB,"glVertexAttrib3fvARB");
	CODE:
	{
		GLfloat param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertexAttrib3fvARB(index,param);
	}

#//# glVertexAttrib3sARB($index,$x,$y,$z);
void
glVertexAttrib3sARB(index,x,y,z)
	GLuint index
	GLshort x
	GLshort y
	GLshort z
	INIT:
		loadProc(glVertexAttrib3sARB,"glVertexAttrib3sARB");

#//# glVertexAttrib3svARB_c($index,(CPTR)v);
void
glVertexAttrib3svARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib3svARB,"glVertexAttrib3svARB");
	CODE:
		glVertexAttrib3svARB(index,(GLshort*)v);

#//# glVertexAttrib3svARB_s($index,(PACKED)v);
void
glVertexAttrib3svARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib3svARB,"glVertexAttrib3svARB");
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glVertexAttrib3svARB(index,v_s);
	}

#//!!! Do we really need this?  It duplicates glVertexAttrib3sARB
#//# glVertexAttrib3svARB_p($index,$x,$y,$z);
void
glVertexAttrib3svARB_p(index,x,y,z)
	GLuint index
	GLshort	x
	GLshort	y
	GLshort	z
	INIT:
		loadProc(glVertexAttrib3svARB,"glVertexAttrib3svARB");
	CODE:
	{
		GLshort param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertexAttrib3svARB(index,param);
	}

#//# glVertexAttrib4NbvARB_c($index,(CPTR)v);
void
glVertexAttrib4NbvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NbvARB,"glVertexAttrib4NbvARB");
	CODE:
		glVertexAttrib4NbvARB(index,(GLbyte*)v);

#//# glVertexAttrib4NbvARB_s($index,(PACKED)v);
void
glVertexAttrib4NbvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NbvARB,"glVertexAttrib4NbvARB");
	CODE:
	{
		GLbyte * v_s = EL(v, sizeof(GLbyte)*4);
		glVertexAttrib4NbvARB(index,v_s);
	}

#//# glVertexAttrib4NbvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NbvARB_p(index,x,y,z,w)
	GLuint index
	GLbyte	x
	GLbyte	y
	GLbyte	z
	GLbyte	w
	INIT:
		loadProc(glVertexAttrib4NbvARB,"glVertexAttrib4NbvARB");
	CODE:
	{
		GLbyte param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NbvARB(index,param);
	}

#//# glVertexAttrib4NivARB_c($index,(CPTR)v);
void
glVertexAttrib4NivARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NivARB,"glVertexAttrib4NivARB");
	CODE:
		glVertexAttrib4NivARB(index,(GLint*)v);

#//# glVertexAttrib4NivARB_s($index,(PACKED)v);
void
glVertexAttrib4NivARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NivARB,"glVertexAttrib4NivARB");
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glVertexAttrib4NivARB(index,v_s);
	}

#//# glVertexAttrib4NivARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NivARB_p(index,x,y,z,w)
	GLuint index
	GLint	x
	GLint	y
	GLint	z
	GLint	w
	INIT:
		loadProc(glVertexAttrib4NivARB,"glVertexAttrib4NivARB");
	CODE:
	{
		GLint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NivARB(index,param);
	}

#//# glVertexAttrib4NsvARB_c($index,(CPTR)v);
void
glVertexAttrib4NsvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NsvARB,"glVertexAttrib4NsvARB");
	CODE:
		glVertexAttrib4NsvARB(index,(GLshort*)v);

#//# glVertexAttrib4NsvARB_s($index,(PACKED)v);
void
glVertexAttrib4NsvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NsvARB,"glVertexAttrib4NsvARB");
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glVertexAttrib4NsvARB(index,v_s);
	}

#//# glVertexAttrib4NsvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NsvARB_p(index,x,y,z,w)
	GLuint index
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w
	INIT:
		loadProc(glVertexAttrib4NsvARB,"glVertexAttrib4NsvARB");
	CODE:
	{
		GLshort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NsvARB(index,param);
	}

#//# glVertexAttrib4NubARB($index,$x,$y,$z,$w);
void
glVertexAttrib4NubARB(index,x,y,z,w)
	GLuint index
	GLubyte x
	GLubyte y
	GLubyte z
	GLubyte w
	INIT:
		loadProc(glVertexAttrib4NubARB,"glVertexAttrib4NubARB");

#//# glVertexAttrib4NubvARB_c($index,(CPTR)v);
void
glVertexAttrib4NubvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NubvARB,"glVertexAttrib4NubvARB");
	CODE:
		glVertexAttrib4NubvARB(index,(GLubyte*)v);

#//# glVertexAttrib4NubvARB_s($index,(PACKED)v);
void
glVertexAttrib4NubvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NubvARB,"glVertexAttrib4NubvARB");
	CODE:
	{
		GLubyte * v_s = EL(v, sizeof(GLubyte)*4);
		glVertexAttrib4NubvARB(index,v_s);
	}

#//# glVertexAttrib4NubvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NubvARB_p(index,x,y,z,w)
	GLuint index
	GLubyte	x
	GLubyte	y
	GLubyte	z
	GLubyte	w
	INIT:
		loadProc(glVertexAttrib4NubvARB,"glVertexAttrib4NubvARB");
	CODE:
	{
		GLubyte param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NubvARB(index,param);
	}

#//# glVertexAttrib4NuivARB_c($index,(CPTR)v);
void
glVertexAttrib4NuivARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NuivARB,"glVertexAttrib4NuivARB");
	CODE:
		glVertexAttrib4NuivARB(index,(GLuint*)v);

#//# glVertexAttrib4NuivARB_s($index,(PACKED)v);
void
glVertexAttrib4NuivARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NuivARB,"glVertexAttrib4NuivARB");
	CODE:
	{
		GLuint * v_s = EL(v, sizeof(GLuint)*4);
		glVertexAttrib4NuivARB(index,v_s);
	}

#//# glVertexAttrib4NuivARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NuivARB_p(index,x,y,z,w)
	GLuint index
	GLuint	x
	GLuint	y
	GLuint	z
	GLuint	w
	INIT:
		loadProc(glVertexAttrib4NuivARB,"glVertexAttrib4NuivARB");
	CODE:
	{
		GLuint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NuivARB(index,param);
	}

#//# glVertexAttrib4NusvARB_c($index,(CPTR)v);
void
glVertexAttrib4NusvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NusvARB,"glVertexAttrib4NusvARB");
	CODE:
		glVertexAttrib4NusvARB(index,(GLushort*)v);

#//# glVertexAttrib4NusvARB_s($index,(PACKED)v);
void
glVertexAttrib4NusvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NusvARB,"glVertexAttrib4NusvARB");
	CODE:
	{
		GLushort * v_s = EL(v, sizeof(GLushort)*4);
		glVertexAttrib4NusvARB(index,v_s);
	}

#//# glVertexAttrib4NusvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NusvARB_p(index,x,y,z,w)
	GLuint index
	GLushort	x
	GLushort	y
	GLushort	z
	GLushort	w
	INIT:
		loadProc(glVertexAttrib4NusvARB,"glVertexAttrib4NusvARB");
	CODE:
	{
		GLushort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NusvARB(index,param);
	}

#//# glVertexAttrib4bvARB_c($index,(CPTR)v);
void
glVertexAttrib4bvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4bvARB,"glVertexAttrib4bvARB");
	CODE:
		glVertexAttrib4bvARB(index,(GLbyte*)v);

#//# glVertexAttrib4bvARB_s($index,(PACKED)v);
void
glVertexAttrib4bvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4bvARB,"glVertexAttrib4bvARB");
	CODE:
	{
		GLbyte * v_s = EL(v, sizeof(GLbyte)*4);
		glVertexAttrib4bvARB(index,v_s);
	}

#//# glVertexAttrib4bvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4bvARB_p(index,x,y,z,w)
	GLuint index
	GLbyte	x
	GLbyte	y
	GLbyte	z
	GLbyte	w
	INIT:
		loadProc(glVertexAttrib4bvARB,"glVertexAttrib4bvARB");
	CODE:
	{
		GLbyte param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4bvARB(index,param);
	}

#//# glVertexAttrib4dARB($index,$x,$y,$z,$w);
void
glVertexAttrib4dARB(index,x,y,z,w)
	GLuint index
	GLdouble x
	GLdouble y
	GLdouble z
	GLdouble w
	INIT:
		loadProc(glVertexAttrib4dARB,"glVertexAttrib4dARB");

#//# glVertexAttrib4dvARB_c($index,(CPTR)v);
void
glVertexAttrib4dvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4dvARB,"glVertexAttrib4dvARB");
	CODE:
		glVertexAttrib4dvARB(index,(GLdouble*)v);

#//# glVertexAttrib4dvARB_s($index,(PACKED)v);
void
glVertexAttrib4dvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4dvARB,"glVertexAttrib4dvARB");
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glVertexAttrib4dvARB(index,v_s);
	}

#//!!! Do we really need this?  It duplicates glVertexAttrib4dARB
#//# glVertexAttrib4dvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4dvARB_p(index,x,y,z,w)
	GLuint index
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w
	INIT:
		loadProc(glVertexAttrib4dvARB,"glVertexAttrib4dvARB");
	CODE:
	{
		GLdouble param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4dvARB(index,param);
	}

#//# glVertexAttrib4fARB($index,$x,$y,$z,$w);
void
glVertexAttrib4fARB(index,x,y,z,w)
	GLuint index
	GLfloat x
	GLfloat y
	GLfloat z
	GLfloat w
	INIT:
		loadProc(glVertexAttrib4fARB,"glVertexAttrib4fARB");

#//# glVertexAttrib4fvARB_c($index,(CPTR)v);
void
glVertexAttrib4fvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4fvARB,"glVertexAttrib4fvARB");
	CODE:
		glVertexAttrib4fvARB(index,(GLfloat*)v);

#//# glVertexAttrib4fvARB_s($index,(PACKED)v);
void
glVertexAttrib4fvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4fvARB,"glVertexAttrib4fvARB");
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glVertexAttrib4fvARB(index,v_s);
	}

#//!!! Do we really need this?  It duplicates glVertexAttrib4fARB
#//# glVertexAttrib4fvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4fvARB_p(index,x,y,z,w)
	GLuint index
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w
	INIT:
		loadProc(glVertexAttrib4fvARB,"glVertexAttrib4fvARB");
	CODE:
	{
		GLfloat param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4fvARB(index,param);
	}

#//# glVertexAttrib4ivARB_c($index,(CPTR)v);
void
glVertexAttrib4ivARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4ivARB,"glVertexAttrib4ivARB");
	CODE:
		glVertexAttrib4ivARB(index,(GLint*)v);

#//# glVertexAttrib4ivARB_s($index,(PACKED)v);
void
glVertexAttrib4ivARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4ivARB,"glVertexAttrib4ivARB");
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glVertexAttrib4ivARB(index,v_s);
	}

#//# glVertexAttrib4ivARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4ivARB_p(index,x,y,z,w)
	GLuint index
	GLint	x
	GLint	y
	GLint	z
	GLint	w
	INIT:
		loadProc(glVertexAttrib4ivARB,"glVertexAttrib4ivARB");
	CODE:
	{
		GLint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4ivARB(index,param);
	}

#//# glVertexAttrib4sARB($index,$x,$y,$z,$w);
void
glVertexAttrib4sARB(index,x,y,z,w)
	GLuint index
	GLshort x
	GLshort y
	GLshort z
	GLshort w
	INIT:
		loadProc(glVertexAttrib4sARB,"glVertexAttrib4sARB");

#//# glVertexAttrib4svARB_c($index,(CPTR)v);
void
glVertexAttrib4svARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4svARB,"glVertexAttrib4svARB");
	CODE:
		glVertexAttrib4svARB(index,(GLshort*)v);

#//# glVertexAttrib4svARB_s($index,(PACKED)v);
void
glVertexAttrib4svARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4svARB,"glVertexAttrib4svARB");
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glVertexAttrib4svARB(index,v_s);
	}

#//!!! Do we really need this?  It duplicates glVertexAttrib4sARB
#//# glVertexAttrib4svARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4svARB_p(index,x,y,z,w)
	GLuint index
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w
	INIT:
		loadProc(glVertexAttrib4svARB,"glVertexAttrib4svARB");
	CODE:
	{
		GLshort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4svARB(index,param);
	}

#//# glVertexAttrib4ubvARB_c($index,(CPTR)v);
void
glVertexAttrib4ubvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4ubvARB,"glVertexAttrib4ubvARB");
	CODE:
		glVertexAttrib4ubvARB(index,(GLubyte*)v);

#//# glVertexAttrib4ubvARB_s($index,(PACKED)v);
void
glVertexAttrib4ubvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4ubvARB,"glVertexAttrib4ubvARB");
	CODE:
	{
		GLubyte * v_s = EL(v, sizeof(GLubyte)*4);
		glVertexAttrib4ubvARB(index,v_s);
	}

#//# glVertexAttrib4ubvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4ubvARB_p(index,x,y,z,w)
	GLuint index
	GLubyte	x
	GLubyte	y
	GLubyte	z
	GLubyte	w
	INIT:
		loadProc(glVertexAttrib4ubvARB,"glVertexAttrib4ubvARB");
	CODE:
	{
		GLubyte param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4ubvARB(index,param);
	}

#//# glVertexAttrib4uivARB_c($index,(CPTR)v);
void
glVertexAttrib4uivARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4uivARB,"glVertexAttrib4uivARB");
	CODE:
		glVertexAttrib4uivARB(index,(GLuint*)v);

#//# glVertexAttrib4uivARB_s($index,(PACKED)v);
void
glVertexAttrib4uivARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4uivARB,"glVertexAttrib4uivARB");
	CODE:
	{
		GLuint * v_s = EL(v, sizeof(GLuint)*4);
		glVertexAttrib4uivARB(index,v_s);
	}

#//# glVertexAttrib4uivARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4uivARB_p(index,x,y,z,w)
	GLuint index
	GLuint	x
	GLuint	y
	GLuint	z
	GLuint	w
	INIT:
		loadProc(glVertexAttrib4uivARB,"glVertexAttrib4uivARB");
	CODE:
	{
		GLuint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4uivARB(index,param);
	}

#//# glVertexAttrib4usvARB_c($index,(CPTR)v);
void
glVertexAttrib4usvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4usvARB,"glVertexAttrib4usvARB");
	CODE:
		glVertexAttrib4usvARB(index,(GLushort*)v);

#//# glVertexAttrib4usvARB_c($index,(PACKED)v);
void
glVertexAttrib4usvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4usvARB,"glVertexAttrib4usvARB");
	CODE:
	{
		GLushort * v_s = EL(v, sizeof(GLushort)*4);
		glVertexAttrib4usvARB(index,v_s);
	}

#//# glVertexAttrib4usvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4usvARB_p(index,x,y,z,w)
	GLuint index
	GLushort	x
	GLushort	y
	GLushort	z
	GLushort	w
	INIT:
		loadProc(glVertexAttrib4usvARB,"glVertexAttrib4usvARB");
	CODE:
	{
		GLushort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4usvARB(index,param);
	}

#//# glVertexAttribPointerARB_c($index,$size,$type,$normalized,$stride,(CPTR)pointer);
void
glVertexAttribPointerARB_c(index,size,type,normalized,stride,pointer)
	GLuint index
	GLint size
	GLenum type
	GLboolean normalized
	GLsizei stride
	void * pointer
	INIT:
		loadProc(glVertexAttribPointerARB,"glVertexAttribPointerARB");
	CODE:
		glVertexAttribPointerARB(index,size,type,
			normalized,stride,pointer);

#//# glVertexAttribPointerARB_p($index,$type,$normalized,$stride,@attribs);
void
glVertexAttribPointerARB_p(index,type,normalized,stride,...)
	GLuint index
	GLenum type
	GLboolean normalized
	GLsizei stride
	INIT:
		loadProc(glVertexAttribPointerARB,"glVertexAttribPointerARB");
	CODE:
	{
		GLuint count = items - 4;
		GLuint size = gl_type_size(type);
		void * pointer = malloc(count * size);

		SvItems(type,4,count,pointer);

		glVertexAttribPointerARB(index,count,type,
			normalized,stride,pointer);

		free(pointer);
	}

#//# glEnableVertexAttribArrayARB($index);
void
glEnableVertexAttribArrayARB(index)
	GLuint index
	INIT:
		loadProc(glEnableVertexAttribArrayARB,"glEnableVertexAttribArrayARB");

#//# glDisableVertexAttribArrayARB($index);
void
glDisableVertexAttribArrayARB(index)
	GLuint index
	INIT:
		loadProc(glDisableVertexAttribArrayARB,"glDisableVertexAttribArrayARB");

#//# glGetVertexAttribdvARB_c($index,$pname,(CPTR)params);
void
glGetVertexAttribdvARB_c(index,pname,params)
	GLuint	index
	GLenum	pname
	void *	params
	INIT:
		loadProc(glGetVertexAttribdvARB,"glGetVertexAttribdvARB");
	CODE:
		glGetVertexAttribdvARB(index,pname,(GLdouble*)params);

#//# glGetVertexAttribdvARB_s($index,$pname,(PACKED)params);
void
glGetVertexAttribdvARB_s(index,pname,params)
	GLuint	index
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetVertexAttribdvARB,"glGetVertexAttribdvARB");
	CODE:
	{
		GLdouble * params_s = EL(params, sizeof(GLdouble) * 4);
		glGetVertexAttribdvARB(index,pname,params_s);
	}

#//# $param = glGetVertexAttribdvARB_p($index,$pname);
GLdouble
glGetVertexAttribdvARB_p(index,pname)
	GLuint	index
	GLenum	pname
	INIT:
		loadProc(glGetVertexAttribdvARB,"glGetVertexAttribdvARB");
	CODE:
	{
		GLdouble param;
		glGetVertexAttribdvARB(index,pname,(void *)&param);
		RETVAL = param;
	}
	OUTPUT:
		RETVAL

#//# glGetVertexAttribfvARB_c($index,$pname,(CPTR)params);
void
glGetVertexAttribfvARB_c(index,pname,params)
	GLuint	index
	GLenum	pname
	void *	params
	INIT:
		loadProc(glGetVertexAttribfvARB,"glGetVertexAttribfvARB");
	CODE:
		glGetVertexAttribfvARB(index,pname,(GLfloat*)params);

#//# glGetVertexAttribfvARB_s($index,$pname,(PACKED)params);
void
glGetVertexAttribfvARB_s(index,pname,params)
	GLuint	index
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetVertexAttribfvARB,"glGetVertexAttribfvARB");
	CODE:
	{
		GLfloat * params_s = EL(params, sizeof(GLfloat) * 4);
		glGetVertexAttribfvARB(index,pname,params_s);
	}

#//# $param = glGetVertexAttribfvARB_p($index,$pname);
GLfloat
glGetVertexAttribfvARB_p(index,pname)
	GLuint	index
	GLenum	pname
	INIT:
		loadProc(glGetVertexAttribfvARB,"glGetVertexAttribfvARB");
	CODE:
	{
		GLfloat param;
		glGetVertexAttribfvARB(index,pname,(void *)&param);
		RETVAL = param;
	}
	OUTPUT:
		RETVAL

#//# glGetVertexAttribivARB_c($index,$pname,(CPTR)params);
void
glGetVertexAttribivARB_c(index,pname,params)
	GLuint	index
	GLenum	pname
	void *	params
	INIT:
		loadProc(glGetVertexAttribivARB,"glGetVertexAttribivARB");
	CODE:
		glGetVertexAttribivARB(index,pname,(GLint*)params);

#//# glGetVertexAttribivARB_s($index,$pname,(PACKED)params);
void
glGetVertexAttribivARB_s(index,pname,params)
	GLuint	index
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetVertexAttribivARB,"glGetVertexAttribivARB");
	CODE:
	{
		GLint * params_s = EL(params, sizeof(GLint) * 4);
		glGetVertexAttribivARB(index,pname,params_s);
	}

#//# $param = glGetVertexAttribivARB_p($index,$pname);
GLuint
glGetVertexAttribivARB_p(index,pname)
	GLuint	index
	GLenum	pname
	INIT:
		loadProc(glGetVertexAttribivARB,"glGetVertexAttribivARB");
	CODE:
	{
		GLuint param;
		glGetVertexAttribivARB(index,pname,(void *)&param);
		RETVAL = param;
	}
	OUTPUT:
		RETVAL

#//# glGetVertexAttribPointervARB_c($index,$pname,(CPTR)pointer);
void
glGetVertexAttribPointervARB_c(index,pname,pointer)
	GLuint	index
	GLenum	pname
	void *	pointer
	INIT:
		loadProc(glGetVertexAttribPointervARB,"glGetVertexAttribPointervARB");
	CODE:
		glGetVertexAttribPointervARB(index,pname,pointer);

#//# $param = glGetVertexAttribPointervARB_p($index,$pname);
void
glGetVertexAttribPointervARB_p(index,pname)
	GLuint	index
	GLenum	pname
	INIT:
		loadProc(glGetVertexAttribPointervARB,"glGetVertexAttribPointervARB");
		loadProc(glGetVertexAttribivARB,"glGetVertexAttribivARB");
	PPCODE:
	{
		void * pointer;
		GLuint i,count,type;

		glGetVertexAttribPointervARB(index,pname,&pointer);

		glGetVertexAttribivARB(index,GL_VERTEX_ATTRIB_ARRAY_SIZE_ARB,(void *)&count);
		glGetVertexAttribivARB(index,GL_VERTEX_ATTRIB_ARRAY_TYPE_ARB,(void *)&type);

		EXTEND(sp, count);

		switch (type)
		{
#ifdef GL_VERSION_1_2
			case GL_UNSIGNED_BYTE_3_3_2:
			case GL_UNSIGNED_BYTE_2_3_3_REV:
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSViv(((GLubyte*)pointer)[i])));
				}
				break;
			case GL_UNSIGNED_SHORT_5_6_5:
			case GL_UNSIGNED_SHORT_5_6_5_REV:
			case GL_UNSIGNED_SHORT_4_4_4_4:
			case GL_UNSIGNED_SHORT_4_4_4_4_REV:
			case GL_UNSIGNED_SHORT_5_5_5_1:
			case GL_UNSIGNED_SHORT_1_5_5_5_REV:
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSViv(((GLushort*)pointer)[i])));
				}
				break;
			case GL_UNSIGNED_INT_8_8_8_8:
			case GL_UNSIGNED_INT_8_8_8_8_REV:
			case GL_UNSIGNED_INT_10_10_10_2:
			case GL_UNSIGNED_INT_2_10_10_10_REV:
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSViv(((GLuint*)pointer)[i])));
				}
				break;
#endif
			case GL_UNSIGNED_BYTE:
			case GL_BITMAP:
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSViv(((GLubyte*)pointer)[i])));
				}
				break;
			case GL_BYTE:
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSViv(((GLbyte*)pointer)[i])));
				}
				break;
			case GL_UNSIGNED_SHORT:
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSViv(((GLushort*)pointer)[i])));
				}
				break;
			case GL_SHORT:
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSViv(((GLushort*)pointer)[i])));
				}
				break;
			case GL_UNSIGNED_INT:
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSViv(((GLuint*)pointer)[i])));
				}
				break;
			case GL_INT:
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSViv(((GLint*)pointer)[i])));
				}
				break;
			case GL_FLOAT: 
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSVnv(((GLfloat*)pointer)[i])));
				}
				break;
			case GL_DOUBLE: 
				for (i=0;i<count;i++)
				{
				  PUSHs(sv_2mortal(newSVnv(((GLdouble*)pointer)[i])));
				}
				break;
			default:
				croak("unknown type");
		}
	}

#endif


#ifdef GL_ARB_vertex_shader

#//# glBindAttribLocationARB($programObj, $index, $name);
void
glBindAttribLocationARB(programObj, index, name)
	GLhandleARB programObj
	GLuint index
	void *name
	INIT:
		loadProc(glBindAttribLocationARB,"glBindAttribLocationARB");
	CODE:
		glBindAttribLocationARB(programObj,index,name);

#//# glGetActiveAttribARB_c($programObj, $index, $maxLength, (CPTR)length, (CPTR)size, (CPTR)type, (CPTR)name);
void
glGetActiveAttribARB_c(programObj, index, maxLength, length, size, type, name)
	GLhandleARB programObj
	GLuint	index
	GLsizei	maxLength
	void	*length
	void	*size
	void	*type
	void	*name
	INIT:
		loadProc(glGetActiveAttribARB,"glGetActiveAttribARB");
	CODE:
		glGetActiveAttribARB(programObj,index,maxLength,length,size,type,name);

#//# glGetActiveAttribARB_s($programObj, $index, $maxLength, (PACKED)length, (PACKED)size, (PACKED)type, (PACKED)name);
void
glGetActiveAttribARB_s(programObj, index, maxLength, length, size, type, name)
	GLhandleARB programObj
	GLuint	index
	GLsizei	maxLength
	SV	*length
	SV	*size
	SV	*type
	SV	*name
	INIT:
		loadProc(glGetActiveAttribARB,"glGetActiveAttribARB");
	CODE:
	{
		GLsizei	  *length_s = EL(length, sizeof(GLsizei));
		GLint	  *size_s = EL(size, sizeof(GLint));
		GLenum	  *type_s = EL(type, sizeof(GLenum));
		GLcharARB *name_s = EL(name, sizeof(GLcharARB));
		glGetActiveAttribARB(programObj,index,maxLength,length_s,size_s,type_s,name_s);
	}

#//# ($name,$type,$size) = glGetActiveAttribARB_p($programObj, $index);
void
glGetActiveAttribARB_p(programObj, index)
	GLhandleARB programObj
	GLuint index
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
		loadProc(glGetActiveAttribARB,"glGetActiveAttribARB");
	PPCODE:
	{
		GLsizei maxLength;
		glGetObjectParameterivARB(programObj,GL_OBJECT_ACTIVE_ATTRIBUTES_ARB,
			(GLvoid *)&maxLength);
		if (maxLength)
		{
			GLsizei length;
			GLint size;
			GLenum type;
			GLcharARB *name;

			name = malloc(maxLength+1);
			glGetActiveAttribARB(programObj,index,maxLength,
				&length,&size,&type,name);
			name[length] = 0;

			if (*name)
			{
				EXTEND(sp,3);
				PUSHs(sv_2mortal(newSVpv(name,0)));
				PUSHs(sv_2mortal(newSViv(type)));
				PUSHs(sv_2mortal(newSViv(size)));
			}
			else
			{
				EXTEND(sp,1);
				PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
			}

			free(name);
		}
		else
		{
			EXTEND(sp,1);
			PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
		}
	}

#//# glGetAttribLocationARB_c($programObj, (CPTR)name);
GLint
glGetAttribLocationARB_c(programObj, name)
	GLhandleARB programObj
	void	*name
	INIT:
		loadProc(glGetAttribLocationARB,"glGetAttribLocationARB");
	CODE:
		RETVAL = glGetAttribLocationARB(programObj, name);
	OUTPUT:
		RETVAL

#//!!! Since pointer is string, should combine _C and _p
#//# $value = glGetAttribLocationARB_p(programObj, $name);
GLint
glGetAttribLocationARB_p(programObj, ...)
	GLhandleARB programObj
	INIT:
		loadProc(glGetAttribLocationARB,"glGetAttribLocationARB");
	CODE:
	{
		GLcharARB *name = (GLcharARB *)SvPV(ST(1),PL_na);
		RETVAL = glGetAttribLocationARB(programObj, name);
	}
	OUTPUT:
		RETVAL

#endif


#ifdef GL_ARB_point_parameters

#//# glPointParameterfARB($pname,$param);
void
glPointParameterfARB(pname,param)
	GLenum pname
	GLfloat param
	INIT:
		loadProc(glPointParameterfARB,"glPointParameterfARB");
	CODE:
	{
		glPointParameterfARB(pname,param);
	}

#//# glPointParameterfvARB_c($pname,(CPTR)params);
void
glPointParameterfvARB_c(pname,params)
	GLenum pname
	void *	params
	INIT:
		loadProc(glPointParameterfvARB,"glPointParameterfvARB");
	CODE:
		glPointParameterfvARB(pname,(GLfloat*)params);

#//# glPointParameterfvARB_s($pname,(PACKED)params);
void
glPointParameterfvARB_s(pname,params)
	GLenum pname
	SV *	params
	INIT:
		loadProc(glPointParameterfvARB,"glPointParameterfvARB");
	CODE:
	{
		int count = gl_get_count(pname);
		GLfloat * params_s = EL(params, sizeof(GLfloat)*count);
		glPointParameterfvARB(pname,params_s);
	}

#//!!! This implementation doesn't look right
#//# glPointParameterfvARB_p($pname,@params);
void
glPointParameterfvARB_p(pname, ...)
	GLenum pname
	INIT:
		loadProc(glPointParameterfvARB,"glPointParameterfvARB");
	CODE:
	{
		GLfloat params[4];
		int i;
		if ((items-1) != gl_get_count(pname))
			croak("Incorrect number of arguments");
		for(i=1;i<items;i++)
			params[i-1] = (GLfloat)SvNV(ST(i));
		glPointParameterfvARB(pname,params);
	}

#endif


#ifdef GL_ARB_multisample

#//# glSampleCoverageARB($value,$invert);
void
glSampleCoverageARB(value,invert)
	GLclampf value
	GLboolean invert
	INIT:
		loadProc(glSampleCoverageARB,"glSampleCoverageARB");
	CODE:
	{
		glSampleCoverageARB(value,invert);
	}

#endif


#ifdef GL_ARB_color_buffer_float

#//# glClampColorARB($target,$clamp);
void
glClampColorARB(target,clamp)
	GLenum target
	GLenum clamp
	INIT:
		loadProc(glClampColorARB,"glClampColorARB");
	CODE:
	{
		glClampColorARB(target,clamp);
	}

#endif

##################### !!! End of Extensions !!! #####################

#endif /* HAVE_GL */

