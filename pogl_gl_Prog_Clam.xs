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

MODULE = OpenGL::GL::ProgClam	PACKAGE = OpenGL

#ifdef HAVE_GL

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
