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

MODULE = OpenGL::V2	PACKAGE = OpenGL

#ifdef HAVE_GL

#ifdef GL_VERSION_2_0

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

#endif // GL_VERSION_2_0

#ifdef GL_ARB_vertex_program

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

#//# glDeleteProgramsARB_s($n,(PACKED)programs);
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
		int nparams = gl_ProgramPropertyARB_count(pname);
		if (nparams < 0) croak("Unknown param");
		GLint * params_s = EL(params, sizeof(GLint)*nparams);
		glGetProgramivARB(target,pname,params_s);
	}

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

#endif // GL_ARB_vertex_program


#if defined(GL_ARB_vertex_program) || defined(GL_ARB_vertex_shader)

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

#//# glVertexAttrib4usvARB_s($index,(PACKED)v);
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
		int size = gl_type_size(type);
		if (size < 0) croak("unknown type");
		void * pointer = malloc(count * size);

		SvItems(type,4,count,pointer);

		glVertexAttribPointerARB(index,count,type,
			normalized,stride,pointer);

		free(pointer);
	}

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

#endif

#ifdef GL_ARB_shader_objects

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

#//# $param = glGetObjectParameterivARB_p($obj,$pname);
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
			PUSHs(sv_2mortal(newSViv((IV)obj[i])));

		free(obj);
	}

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

#endif // GL_ARB_shader_objects

#ifdef GL_ARB_draw_buffers

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

#endif // GL_ARB_draw_buffers

#endif /* HAVE_GL */
