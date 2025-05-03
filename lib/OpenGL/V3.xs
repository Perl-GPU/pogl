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

MODULE = OpenGL::V3	PACKAGE = OpenGL

#ifdef HAVE_GL

#ifdef GL_VERSION_3_0

#//# glDeleteRenderbuffers_s($n,(PACKED)renderbuffers);
void
glDeleteRenderbuffers_s(n,renderbuffers)
	GLsizei n
	SV *	renderbuffers
	CODE:
	{
		void * renderbuffers_s = EL(renderbuffers, sizeof(GLuint)*n);
		glDeleteRenderbuffers(n,renderbuffers_s);
	}

#//# glGenRenderbuffers_s($n,(PACKED)renderbuffers);
void
glGenRenderbuffers_s(n,renderbuffers)
	GLsizei n
	SV *	renderbuffers
	CODE:
	{
		void * renderbuffers_s = EL(renderbuffers, sizeof(GLuint)*n);
		glGenRenderbuffers(n, renderbuffers_s);
	}

#//# glGetRenderbufferParameteriv_s($target,$pname,(PACKED)params);
void
glGetRenderbufferParameteriv_s(target,pname,params)
	GLenum	target
	GLenum	pname
		SV *	params
	CODE:
	{
		GLint * params_s = EL(params, sizeof(GLint));
		glGetRenderbufferParameteriv(target,pname,params_s);
	}

#//# glDeleteFramebuffers_s($n,(PACKED)framebuffers);
void
glDeleteFramebuffers_s(n,framebuffers)
	GLsizei n
	SV *	framebuffers
	CODE:
	{
		void * framebuffers_s = EL(framebuffers, sizeof(GLuint)*n);
		glDeleteFramebuffers(n,framebuffers_s);
	}

#//# glGenFramebuffers_s($n,(PACKED)framebuffers);
void
glGenFramebuffers_s(n,framebuffers)
	GLsizei n
	SV *	framebuffers
	CODE:
	{
		void * framebuffers_s = EL(framebuffers, sizeof(GLuint)*n);
		glGenFramebuffers(n,framebuffers_s);
	}

#//# glGetFramebufferAttachmentParameteriv_s($target,$attachment,$pname,(PACKED)params);
void
glGetFramebufferAttachmentParameteriv_s(target,attachment,pname,params)
	GLenum	target
	GLenum	attachment
	GLenum	pname
		SV *	params
	CODE:
	{
		GLint * params_s = EL(params, sizeof(GLint));
		glGetFramebufferAttachmentParameteriv(target,attachment,pname,params_s);
	}

#endif // GL_VERSION_3_0

#ifdef GL_EXT_framebuffer_object

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

#endif // GL_EXT_framebuffer_object

#endif /* HAVE_GL */
