/*  Last saved: Fri 24 Jul 2009 01:50:05 PM  */

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





MODULE = OpenGL::GL::VertMulti	PACKAGE = OpenGL





#ifdef HAVE_GL
 
#ifdef GL_EXT_vertex_array
 
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
	OpenGL::Array oga
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
	OpenGL::Array oga
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
	OpenGL::Array oga
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
	OpenGL::Array oga
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
	OpenGL::Array oga
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
	OpenGL::Array oga
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
	OpenGL::Array oga
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
	OpenGL::Array oga
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
OpenGL::Array
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
OpenGL::Array
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
OpenGL::Array
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
 
#endif 
 
#endif /* HAVE_GL */

