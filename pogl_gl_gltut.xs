
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





MODULE = OpenGL::GL::gltut	PACKAGE = OpenGL



#ifdef GL_VERSION_3_0

#//# @vertex_arrays = glGenVertexArrays_p($n);
void
glGenVertexArrays_p(n)
	GLsizei n
	INIT:
		loadProc(glGenVertexArrays,"glGenVertexArrays");
	PPCODE:
	if (n)
	{
		GLuint * vertex_arrays = malloc(sizeof(GLuint) * n);
		int i;

		glGenVertexArrays(n, vertex_arrays);

		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(vertex_arrays[i])));

		free(vertex_arrays);
	}

#//# glBindVertexArray(vertex_array);
void
glBindVertexArray(vertex_array)
	GLuint vertex_array
	INIT:
		loadProc(glBindVertexArray,"glBindVertexArray");
	CODE:
	{
		glBindVertexArray(vertex_array);
	}

#endif // GL_VERSION_3_0
