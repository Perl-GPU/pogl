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

MODULE = OpenGL::GL::VertMulti	PACKAGE = OpenGL

#ifdef HAVE_GL

#ifndef NO_GL_EXT_vertex_array
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

#endif // GL_EXT_vertex_array
#endif // !NO_GL_EXT_vertex_array


#ifdef GL_MESA_resize_buffers

#// glResizeBuffersMESA();
void
glResizeBuffersMESA()

#endif // GL_MESA_resize_buffers

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

#endif // GL_ARB_draw_buffers

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
		GLint size;
		
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

		glGetBufferParameterivARB(target,GL_BUFFER_SIZE_ARB,&size);
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

#endif // GL_ARB_vertex_buffer_object

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

#endif // GL_ARB_multitexture

#endif // HAVE_GL
