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

MODULE = OpenGL::GL::Tex2Draw	PACKAGE = OpenGL

#ifdef HAVE_GL

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

#endif /* HAVE_GL */

