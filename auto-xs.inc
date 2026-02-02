void
glAreTexturesResident_s(n, textures, residences)
	GLsizei	n
	SV *	textures
	SV *	residences
CODE:
	void * textures_s = EL(textures, sizeof(GLuint)*n);
	void * residences_s = EL(residences, sizeof(GLboolean)*n);
	glAreTexturesResident(n, textures_s, residences_s);

void
glClipPlane_s(plane, eqn)
	GLenum	plane
	SV *	eqn
CODE:
		GLdouble * eqn_s = EL(eqn, sizeof(GLdouble) * 4);
		glClipPlane(plane, eqn_s);

void
glColor3bv_s(v)
	SV *	v
CODE:
		GLbyte * v_s = EL(v, sizeof(GLbyte)*3);
		glColor3bv(v_s);

void
glColor3dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glColor3dv(v_s);

void
glColor3fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glColor3fv(v_s);

void
glColor3iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glColor3iv(v_s);

void
glColor3sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glColor3sv(v_s);

void
glColor3ubv_s(v)
	SV *	v
CODE:
		GLubyte * v_s = EL(v, sizeof(GLubyte)*3);
		glColor3ubv(v_s);

void
glColor3uiv_s(v)
	SV *	v
CODE:
		GLuint * v_s = EL(v, sizeof(GLuint)*3);
		glColor3uiv(v_s);

void
glColor3usv_s(v)
	SV *	v
CODE:
		GLushort * v_s = EL(v, sizeof(GLushort)*3);
		glColor3usv(v_s);

void
glColor4bv_s(v)
	SV *	v
CODE:
		GLbyte * v_s = EL(v, sizeof(GLbyte)*4);
		glColor4bv(v_s);

void
glColor4dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glColor4dv(v_s);

void
glColor4fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glColor4fv(v_s);

void
glColor4iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glColor4iv(v_s);

void
glColor4sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glColor4sv(v_s);

void
glColor4ubv_s(v)
	SV *	v
CODE:
		GLubyte * v_s = EL(v, sizeof(GLubyte)*4);
		glColor4ubv(v_s);

void
glColor4uiv_s(v)
	SV *	v
CODE:
		GLuint * v_s = EL(v, sizeof(GLuint)*4);
		glColor4uiv(v_s);

void
glColor4usv_s(v)
	SV *	v
CODE:
		GLushort * v_s = EL(v, sizeof(GLushort)*4);
		glColor4usv(v_s);

#ifdef GL_VERSION_1_5

void
glDeleteBuffers_s(n,buffers)
	GLsizei n
	SV *	buffers
CODE:
		void * buffers_s = EL(buffers, sizeof(GLuint)*n);
		glDeleteBuffers(n,buffers_s);

#endif

#ifdef GL_ARB_vertex_buffer_object

void
glDeleteBuffersARB_s(n,buffers)
	GLsizei n
	SV *	buffers
	INIT:
		loadProc(glDeleteBuffersARB,"glDeleteBuffersARB");
CODE:
		void * buffers_s = EL(buffers, sizeof(GLuint)*n);
		glDeleteBuffersARB(n,buffers_s);

#endif

#ifdef GL_ARB_vertex_program

void
glDeleteProgramsARB_s(n,programs)
	GLsizei n
	SV *	programs
	INIT:
		loadProc(glDeleteProgramsARB,"glDeleteProgramsARB");
CODE:
		GLuint * programs_s = EL(programs, sizeof(GLuint)*n);
		glDeleteProgramsARB(n,programs_s);

#endif

void
glDeleteTextures_s(items, list)
	GLint	items
	SV *	list
CODE:
	void * list_s = EL(list, sizeof(GLuint) * items);
	glDeleteTextures(items,list_s);

#ifdef GL_VERSION_2_0

void
glDrawBuffers_s(n,buffers)
	GLsizei n
	SV *	buffers
CODE:
		void * buffers_s = EL(buffers, sizeof(GLuint)*n);
		glDrawBuffers(n,buffers_s);

#endif

#ifdef GL_ARB_draw_buffers

void
glDrawBuffersARB_s(n,buffers)
	GLsizei n
	SV *	buffers
	INIT:
		loadProc(glDrawBuffersARB,"glDrawBuffersARB");
CODE:
		void * buffers_s = EL(buffers, sizeof(GLuint)*n);
		glDrawBuffersARB(n,buffers_s);

#endif

void
glFogfv_s(pname, params)
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_FogParameter_count(pname);
	if (nparams < 0) croak("Unknown fog parameter");
	GLfloat * params_s = EL(params, sizeof(GLfloat)*nparams);
	glFogfv(pname, params_s);

void
glFogiv_s(pname, params)
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_FogParameter_count(pname);
	if (nparams < 0) croak("Unknown fog parameter");
	GLint * params_s = EL(params, sizeof(GLint)*nparams);
	glFogiv(pname, params_s);

#ifdef GL_VERSION_1_5

void
glGenBuffers_s(n,buffers)
	GLsizei n
	SV *	buffers
CODE:
		void * buffers_s = EL(buffers, sizeof(GLuint)*n);
		glGenBuffers(n, buffers_s);

#endif

#ifdef GL_ARB_vertex_buffer_object

void
glGenBuffersARB_s(n,buffers)
	GLsizei n
	SV *	buffers
	INIT:
		loadProc(glGenBuffersARB,"glGenBuffersARB");
CODE:
		void * buffers_s = EL(buffers, sizeof(GLuint)*n);
		glGenBuffersARB(n, buffers_s);

#endif

#ifdef GL_ARB_vertex_program

void
glGenProgramsARB_s(n,programs)
	GLsizei n
	SV *	programs
	INIT:
		loadProc(glGenProgramsARB,"glGenProgramsARB");
CODE:
		GLuint * programs_s = EL(programs, sizeof(GLuint)*n);
		glGenProgramsARB(n, programs_s);

#endif

void
glGenTextures_s(n, textures)
	GLint	n
	SV *	textures
CODE:
	void * textures_s = EL(textures, sizeof(GLuint)*n);
	glGenTextures(n, textures_s);

#ifdef GL_ARB_vertex_shader

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
		GLsizei	  *length_s = EL(length, sizeof(GLsizei));
		GLint	  *size_s = EL(size, sizeof(GLint));
		GLenum	  *type_s = EL(type, sizeof(GLenum));
		GLcharARB *name_s = EL(name, sizeof(GLcharARB));
		glGetActiveAttribARB(programObj,index,maxLength,length_s,size_s,type_s,name_s);

#endif

#ifdef GL_ARB_shader_objects

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
		GLsizei	  *length_s = EL(length, sizeof(GLsizei));
		GLint	  *size_s = EL(size, sizeof(GLint));
		GLenum	  *type_s = EL(type, sizeof(GLenum));
		GLcharARB *name_s = EL(name, sizeof(GLcharARB));
		glGetActiveUniformARB(programObj,index,maxLength,length_s,size_s,type_s,name_s);

#endif

void
glGetBooleanv_s(pname, params)
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_GetPName_count(pname);
	if (nparams < 0) croak("Unknown param");
	void * params_s = EL(params, sizeof(GLboolean) * nparams);
	glGetBooleanv(pname, params_s);

#ifdef GL_VERSION_1_5

void
glGetBufferParameteriv_s(target,pname,params)
	GLenum	target
	GLenum	pname
	SV *	params
CODE:
		GLint * params_s = EL(params, sizeof(GLint)*1);
		glGetBufferParameteriv(target,pname,params_s);

#endif

#ifdef GL_ARB_vertex_buffer_object

void
glGetBufferParameterivARB_s(target,pname,params)
	GLenum	target
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetBufferParameterivARB,"glGetBufferParameterivARB");
CODE:
		GLint * params_s = EL(params, sizeof(GLint)*1);
		glGetBufferParameterivARB(target,pname,params_s);

#endif

void
glGetClipPlane_s(plane, eqn)
	GLenum	plane
	SV *	eqn
CODE:
	GLdouble * eqn_s = EL(eqn, sizeof(GLdouble)*4);
	glGetClipPlane(plane, eqn_s);

void
glGetDoublev_s(pname, params)
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_GetPName_count(pname);
	if (nparams < 0) croak("Unknown param");
	void * params_s = EL(params, sizeof(GLdouble) * nparams);
	glGetDoublev(pname, params_s);

void
glGetFloatv_s(pname, params)
	GLenum	pname
	void *	params
CODE:
	int nparams = gl_GetPName_count(pname);
	if (nparams < 0) croak("Unknown param");
	void * params_s = EL(params, sizeof(GLfloat) * nparams);
	glGetFloatv(pname, params_s);

void
glGetIntegerv_s(pname, params)
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_GetPName_count(pname);
	if (nparams < 0) croak("Unknown param");
	void * params_s = EL(params, sizeof(GLint) * nparams);
	glGetIntegerv(pname, params_s);

void
glGetLightfv_s(light, pname, p)
	GLenum	light
	GLenum	pname
	SV *	p
CODE:
	int nparams = gl_LightParameter_count(pname);
	if (nparams < 0) croak("Unknown light parameter");
	void * p_s = EL(p, sizeof(GLfloat)*nparams);
	glGetLightfv(light, pname, p_s);

void
glGetLightiv_s(light, pname, p)
	GLenum	light
	GLenum	pname
	SV *	p
CODE:
	int nparams = gl_LightParameter_count(pname);
	if (nparams < 0) croak("Unknown light parameter");
	void * p_s = EL(p, sizeof(GLint)*nparams);
	glGetLightiv(light, pname, p_s);

void
glGetMaterialfv_s(face, query, params)
	GLenum	face
	GLenum	query
	SV *	params
CODE:
		int nparams = gl_MaterialParameter_count(query);
		if (nparams < 0) croak("Unknown material parameter");
		GLfloat * params_s = EL(params,
			sizeof(GLfloat)*nparams);
		glGetMaterialfv(face, query, params_s);

void
glGetMaterialiv_s(face, query, params)
	GLenum	face
	GLenum	query
	SV *	params
CODE:
		int nparams = gl_MaterialParameter_count(query);
		if (nparams < 0) croak("Unknown material parameter");
		GLint * params_s = EL(params,
			sizeof(GLfloat)*nparams);
		glGetMaterialiv(face, query, params_s);

#ifdef GL_ARB_vertex_program

void
glGetProgramEnvParameterdvARB_s(target,index,params)
	GLenum	target
	GLint	index
	SV *	params
	INIT:
		loadProc(glGetProgramEnvParameterdvARB,"glGetProgramEnvParameterdvARB");
CODE:
		GLdouble * params_s = EL(params, sizeof(GLdouble) * 4);
		glGetProgramEnvParameterdvARB(target,index,params_s);

#endif

#ifdef GL_ARB_vertex_program

void
glGetProgramEnvParameterfvARB_s(target,index,params)
	GLenum	target
	GLint	index
	SV *	params
	INIT:
		loadProc(glGetProgramEnvParameterfvARB,"glGetProgramEnvParameterfvARB");
CODE:
		GLfloat * params_s = EL(params, sizeof(GLfloat) * 4);
		glGetProgramEnvParameterfvARB(target,index,params_s);

#endif

#ifdef GL_ARB_vertex_program

void
glGetProgramLocalParameterdvARB_s(target,index,params)
	GLenum	target
	GLint	index
	SV *	params
	INIT:
		loadProc(glGetProgramLocalParameterdvARB,"glGetProgramLocalParameterdvARB");
CODE:
		GLdouble * params_s = EL(params, sizeof(GLdouble) * 4);
		glGetProgramLocalParameterdvARB(target,index,params_s);

#endif

#ifdef GL_ARB_vertex_program

void
glGetProgramLocalParameterfvARB_s(target,index,params)
	GLenum	target
	GLint	index
	SV *	params
	INIT:
		loadProc(glGetProgramLocalParameterfvARB,"glGetProgramLocalParameterfvARB");
CODE:
		GLfloat * params_s = EL(params, sizeof(GLfloat) * 4);
		glGetProgramLocalParameterfvARB(target,index,params_s);

#endif

#ifdef GL_ARB_vertex_program

void
glGetProgramivARB_s(target,pname,params)
	GLenum	target
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetProgramivARB,"glGetProgramivARB");
CODE:
		int nparams = gl_PointParameterNameARB_count(pname);
		if (nparams < 0) croak("Unknown param");
		GLint * params_s = EL(params, sizeof(GLint)*nparams);
		glGetProgramivARB(target,pname,params_s);

#endif

void
glGetTexEnvfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV * params
CODE:
	int nparams = gl_TextureEnvParameter_count(pname);
	if (nparams < 0) croak("Unknown texenv parameter");
	GLfloat * params_s = EL(params, sizeof(GLfloat) * nparams);
	glGetTexEnvfv(target, pname, params_s);

void
glGetTexEnviv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV * params
CODE:
	int nparams = gl_TextureEnvParameter_count(pname);
	if (nparams < 0) croak("Unknown texenv parameter");
	GLint * params_s = EL(params, sizeof(GLint) * nparams);
	glGetTexEnviv(target, pname, params_s);

void
glGetTexGendv_s(coord, pname, params)
	GLenum	coord
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_TextureGenParameter_count(pname);
	if (nparams < 0) croak("Unknown texgen parameter");
	GLdouble * params_s = EL(params, sizeof(GLdouble)*nparams);
	glGetTexGendv(coord, pname, params_s);

void
glGetTexGenfv_s(coord, pname, params)
	GLenum	coord
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_TextureGenParameter_count(pname);
	if (nparams < 0) croak("Unknown texgen parameter");
	GLfloat * params_s = EL(params, sizeof(GLfloat)*nparams);
	glGetTexGenfv(coord, pname, params_s);

void
glGetTexGeniv_s(coord, pname, params)
	GLenum	coord
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_TextureGenParameter_count(pname);
	if (nparams < 0) croak("Unknown texgen parameter");
	GLint * params_s = EL(params, sizeof(GLint)*nparams);
	glGetTexGeniv(coord, pname, params_s);

void
glGetTexLevelParameterfv_s(target, level, pname, params)
	GLenum	target
	GLint	level
	GLenum	pname
	SV *	params
CODE:
	GLfloat * params_s = EL(params, sizeof(GLfloat)*1);
	glGetTexLevelParameterfv(target, level, pname, params_s);

void
glGetTexLevelParameteriv_s(target, level, pname, params)
	GLenum	target
	GLint	level
	GLenum	pname
	SV *	params
CODE:
	GLint * params_s = EL(params, sizeof(GLint)*1);
	glGetTexLevelParameteriv(target, level, pname, params_s);

void
glGetTexParameterfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_GetTextureParameter_count(pname);
	if (nparams < 0) croak("Unknown texparameter parameter");
	GLfloat * params_s = EL(params, sizeof(GLfloat)*nparams);
	glGetTexParameterfv(target, pname, params_s);

void
glGetTexParameteriv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_GetTextureParameter_count(pname);
	if (nparams < 0) croak("Unknown texparameter parameter");
	GLint * params_s = EL(params, sizeof(GLint)*nparams);
	glGetTexParameteriv(target, pname, params_s);

#ifdef GL_ARB_vertex_program

void
glGetVertexAttribdvARB_s(index,pname,params)
	GLuint	index
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetVertexAttribdvARB,"glGetVertexAttribdvARB");
CODE:
		GLdouble * params_s = EL(params, sizeof(GLdouble) * 4);
		glGetVertexAttribdvARB(index,pname,params_s);

#endif

#ifdef GL_ARB_vertex_program

void
glGetVertexAttribfvARB_s(index,pname,params)
	GLuint	index
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetVertexAttribfvARB,"glGetVertexAttribfvARB");
CODE:
		GLfloat * params_s = EL(params, sizeof(GLfloat) * 4);
		glGetVertexAttribfvARB(index,pname,params_s);

#endif

#ifdef GL_ARB_vertex_program

void
glGetVertexAttribivARB_s(index,pname,params)
	GLuint	index
	GLenum	pname
	SV *	params
	INIT:
		loadProc(glGetVertexAttribivARB,"glGetVertexAttribivARB");
CODE:
		GLint * params_s = EL(params, sizeof(GLint) * 4);
		glGetVertexAttribivARB(index,pname,params_s);

#endif

void
glLightModelfv_s(pname, params)
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_LightModelParameter_count(pname);
	if (nparams < 0) croak("Unknown light model");
	GLfloat * params_s = EL(params, sizeof(GLfloat)*nparams);
	glLightModelfv(pname, params_s);

void
glLightModeliv_s(pname, params)
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_LightModelParameter_count(pname);
	if (nparams < 0) croak("Unknown light model");
	GLint * params_s = EL(params, sizeof(GLint)*nparams);
	glLightModeliv(pname, params_s);

void
glLightfv_s(light, pname, params)
	GLenum	light
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_LightParameter_count(pname);
	if (nparams < 0) croak("Unknown light parameter");
	GLfloat * params_s = EL(params, sizeof(GLfloat)*nparams);
	glLightfv(light, pname, params_s);

void
glLightiv_s(light, pname, params)
	GLenum	light
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_LightParameter_count(pname);
	if (nparams < 0) croak("Unknown light parameter");
	GLint * params_s = EL(params, sizeof(GLint)*nparams);
	glLightiv(light, pname, params_s);

void
glLoadMatrixd_s(m)
	SV *	m
CODE:
	GLdouble * m_s = EL(m, sizeof(GLdouble)*16);
	glLoadMatrixd(m_s);

void
glLoadMatrixf_s(m)
	SV *	m
CODE:
	GLfloat * m_s = EL(m, sizeof(GLfloat)*16);
	glLoadMatrixf(m_s);

void
glMaterialfv_s(face, pname, param)
	GLenum	face
	GLenum	pname
	SV *	param
CODE:
	int nparams = gl_MaterialParameter_count(pname);
	if (nparams < 0) croak("Unknown material parameter");
	GLfloat * param_s = EL(param, sizeof(GLfloat)*nparams);
	glMaterialfv(face, pname, param_s);

void
glMaterialiv_s(face, pname, param)
	GLenum	face
	GLenum	pname
	SV *	param
CODE:
	int nparams = gl_MaterialParameter_count(pname);
	if (nparams < 0) croak("Unknown material parameter");
	GLint * param_s = EL(param, sizeof(GLint)*nparams);
	glMaterialiv(face, pname, param_s);

#ifdef GL_VERSION_1_3

void
glMultiTexCoord1dv_s(target,v)
	GLenum target
	void *v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord1dv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord1dvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1dvARB,"glMultiTexCoord1dvARB");
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord1dvARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord1fv_s(target,v)
	GLenum target
	void *v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord1fv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord1fvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1fvARB,"glMultiTexCoord1fvARB");
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord1fvARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord1iv_s(target,v)
	GLenum target
	void *v
CODE:
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord1iv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord1ivARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1ivARB,"glMultiTexCoord1ivARB");
CODE:
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord1ivARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord1sv_s(target,v)
	GLenum target
	void *v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord1sv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord1svARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord1svARB,"glMultiTexCoord1svARB");
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord1svARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord2dv_s(target,v)
	GLenum target
	void *v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord2dv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord2dvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2dvARB,"glMultiTexCoord2dvARB");
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord2dvARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord2fv_s(target,v)
	GLenum target
	void *v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord2fv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord2fvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2fvARB,"glMultiTexCoord2fvARB");
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord2fvARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord2iv_s(target,v)
	GLenum target
	void *v
CODE:
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord2iv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord2ivARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2ivARB,"glMultiTexCoord2ivARB");
CODE:
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord2ivARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord2sv_s(target,v)
	GLenum target
	void *v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord2sv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord2svARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord2svARB,"glMultiTexCoord2svARB");
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord2svARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord3dv_s(target,v)
	GLenum target
	void *v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord3dv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord3dvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3dvARB,"glMultiTexCoord3dvARB");
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord3dvARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord3fv_s(target,v)
	GLenum target
	void *v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord3fv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord3fvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3fvARB,"glMultiTexCoord3fvARB");
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord3fvARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord3iv_s(target,v)
	GLenum target
	void *v
CODE:
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord3iv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord3ivARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3ivARB,"glMultiTexCoord3ivARB");
CODE:
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord3ivARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord3sv_s(target,v)
	GLenum target
	void *v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord3sv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord3svARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord3svARB,"glMultiTexCoord3svARB");
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord3svARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord4dv_s(target,v)
	GLenum target
	void *v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord4dv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord4dvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4dvARB,"glMultiTexCoord4dvARB");
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble));
		glMultiTexCoord4dvARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord4fv_s(target,v)
	GLenum target
	void *v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord4fv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord4fvARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4fvARB,"glMultiTexCoord4fvARB");
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat));
		glMultiTexCoord4fvARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord4iv_s(target,v)
	GLenum target
	void *v
CODE:
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord4iv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord4ivARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4ivARB,"glMultiTexCoord4ivARB");
CODE:
		GLint * v_s = EL(v, sizeof(GLint));
		glMultiTexCoord4ivARB(target,v_s);

#endif

#ifdef GL_VERSION_1_3

void
glMultiTexCoord4sv_s(target,v)
	GLenum target
	void *v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord4sv(target,v_s);

#endif

#ifdef GL_ARB_multitexture

void
glMultiTexCoord4svARB_s(target,v)
	GLenum target
	void *v
	INIT:
		loadProc(glMultiTexCoord4svARB,"glMultiTexCoord4svARB");
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort));
		glMultiTexCoord4svARB(target,v_s);

#endif

void
glNormal3bv_s(v)
	SV *	v
CODE:
		GLbyte * v_s = EL(v, sizeof(GLbyte)*3);
		glNormal3bv(v_s);

void
glNormal3dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glNormal3dv(v_s);

void
glNormal3fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glNormal3fv(v_s);

void
glNormal3iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glNormal3iv(v_s);

void
glNormal3sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glNormal3sv(v_s);

void
glPixelMapfv_s(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	SV *	values
CODE:
	GLfloat * values_s = EL(values, sizeof(GLfloat)*mapsize);
	glPixelMapfv(map, mapsize, values_s);

void
glPixelMapuiv_s(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	SV *	values
CODE:
	GLuint * values_s = EL(values, sizeof(GLuint)*mapsize);
	glPixelMapuiv(map, mapsize, values_s);

void
glPixelMapusv_s(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	SV *	values
CODE:
	GLushort * values_s = EL(values, sizeof(GLushort)*mapsize);
	glPixelMapusv(map, mapsize, values_s);

#ifdef GL_ARB_point_parameters

void
glPointParameterfvARB_s(pname,params)
	GLenum pname
	SV *	params
	INIT:
		loadProc(glPointParameterfvARB,"glPointParameterfvARB");
CODE:
		int count = gl_ProgramPropertyARB_count(pname);
		if (count < 0) croak("Unknown param");
		GLfloat * params_s = EL(params, sizeof(GLfloat)*count);
		glPointParameterfvARB(pname,params_s);

#endif

void
glPrioritizeTextures_s(n, textures, priorities)
	GLsizei	n
	SV *	textures
	SV *	priorities
CODE:
	GLuint * textures_s = EL(textures, sizeof(GLuint) * n);
	GLclampf * priorities_s = EL(priorities, sizeof(GLclampf) * n);
	glPrioritizeTextures(n, textures_s, priorities_s);

#ifdef GL_ARB_vertex_program

void
glProgramEnvParameter4dvARB_s(target,index,v)
	GLenum target
	GLuint index
	SV *	v
	INIT:
		loadProc(glProgramEnvParameter4dvARB,"glProgramEnvParameter4dvARB");
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glProgramEnvParameter4dvARB(target,index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glProgramEnvParameter4fvARB_s(target,index,v)
	GLenum target
	GLuint index
	SV *	v
	INIT:
		loadProc(glProgramEnvParameter4fvARB,"glProgramEnvParameter4fvARB");
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glProgramEnvParameter4fvARB(target,index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glProgramLocalParameter4dvARB_s(target,index,v)
	GLenum target
	GLuint index
	SV *	v
	INIT:
		loadProc(glProgramLocalParameter4dvARB,"glProgramLocalParameter4dvARB");
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glProgramLocalParameter4dvARB(target,index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glProgramLocalParameter4fvARB_s(target,index,v)
	GLenum target
	GLuint index
	SV *	v
	INIT:
		loadProc(glProgramLocalParameter4fvARB,"glProgramLocalParameter4fvARB");
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glProgramLocalParameter4fvARB(target,index,v_s);

#endif

void
glRasterPos2dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glRasterPos2dv(v_s);

void
glRasterPos2fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*2);
		glRasterPos2fv(v_s);

void
glRasterPos2iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*2);
		glRasterPos2iv(v_s);

void
glRasterPos2sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glRasterPos2sv(v_s);

void
glRasterPos3dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glRasterPos3dv(v_s);

void
glRasterPos3fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glRasterPos3fv(v_s);

void
glRasterPos3iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glRasterPos3iv(v_s);

void
glRasterPos3sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glRasterPos3sv(v_s);

void
glRasterPos4dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glRasterPos4dv(v_s);

void
glRasterPos4fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glRasterPos4fv(v_s);

void
glRasterPos4iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glRasterPos4iv(v_s);

void
glRasterPos4sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glRasterPos4sv(v_s);

void
glRectdv_s(v1, v2)
	SV *	v1
	SV *	v2
CODE:
	GLdouble * v1_s = EL(v1, sizeof(GLdouble)*2);
	GLdouble * v2_s = EL(v2, sizeof(GLdouble)*2);
	glRectdv(v1_s, v2_s);

void
glRectfv_s(v1, v2)
	SV *	v1
	SV *	v2
CODE:
	GLfloat * v1_s = EL(v1, sizeof(GLfloat)*2);
	GLfloat * v2_s = EL(v2, sizeof(GLfloat)*2);
	glRectfv(v1_s, v2_s);

void
glRectiv_s(v1, v2)
	SV *	v1
	SV *	v2
CODE:
	GLint * v1_s = EL(v1, sizeof(GLint)*2);
	GLint * v2_s = EL(v2, sizeof(GLint)*2);
	glRectiv(v1_s, v2_s);

void
glRectsv_s(v1, v2)
	SV *	v1
	SV *	v2
CODE:
	GLshort * v1_s = EL(v1, sizeof(GLshort)*2);
	GLshort * v2_s = EL(v2, sizeof(GLshort)*2);
	glRectsv(v1_s, v2_s);

void
glTexCoord1dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*1);
		glTexCoord1dv(v_s);

void
glTexCoord1fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*1);
		glTexCoord1fv(v_s);

void
glTexCoord1iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*1);
		glTexCoord1iv(v_s);

void
glTexCoord1sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*1);
		glTexCoord1sv(v_s);

void
glTexCoord2dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glTexCoord2dv(v_s);

void
glTexCoord2fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*2);
		glTexCoord2fv(v_s);

void
glTexCoord2iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*2);
		glTexCoord2iv(v_s);

void
glTexCoord2sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glTexCoord2sv(v_s);

void
glTexCoord3dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glTexCoord3dv(v_s);

void
glTexCoord3fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glTexCoord3fv(v_s);

void
glTexCoord3iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glTexCoord3iv(v_s);

void
glTexCoord3sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glTexCoord3sv(v_s);

void
glTexCoord4dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glTexCoord4dv(v_s);

void
glTexCoord4fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glTexCoord4fv(v_s);

void
glTexCoord4iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glTexCoord4iv(v_s);

void
glTexCoord4sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glTexCoord4sv(v_s);

void
glTexEnvfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_TextureEnvParameter_count(pname);
	if (nparams < 0) croak("Unknown texenv parameter");
	GLfloat * params_s = EL(params, sizeof(GLfloat)*nparams);
	glTexEnvfv(target, pname, params_s);

void
glTexEnviv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_TextureEnvParameter_count(pname);
	if (nparams < 0) croak("Unknown texenv parameter");
	GLint * params_s = EL(params, sizeof(GLint)*nparams);
	glTexEnviv(target, pname, params_s);

void
glTexGendv_s(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_TextureGenParameter_count(pname);
	if (nparams < 0) croak("Unknown texgen parameter");
	GLdouble * params_s = EL(params, sizeof(GLdouble)* nparams);
	glTexGendv(Coord, pname, params_s);

void
glTexGenfv_s(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_TextureGenParameter_count(pname);
	if (nparams < 0) croak("Unknown texgen parameter");
	GLfloat * params_s = EL(params, sizeof(GLfloat)* nparams);
	glTexGenfv(Coord, pname, params_s);

void
glTexGeniv_s(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_TextureGenParameter_count(pname);
	if (nparams < 0) croak("Unknown texgen parameter");
	GLint * params_s = EL(params, sizeof(GLint)* nparams);
	glTexGeniv(Coord, pname, params_s);

void
glTexParameterfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_GetTextureParameter_count(pname);
	if (nparams < 0) croak("Unknown texparameter parameter");
	GLfloat * params_s = EL(params, sizeof(GLfloat)*nparams);
	glTexParameterfv(target, pname, params_s);

void
glTexParameteriv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
CODE:
	int nparams = gl_GetTextureParameter_count(pname);
	if (nparams < 0) croak("Unknown texparameter parameter");
	GLint * params_s = EL(params, sizeof(GLint)*nparams);
	glTexParameteriv(target, pname, params_s);

#ifdef GL_ARB_shader_objects

void
glUniform1fvARB_s(location, count, value)
	GLint	location
	GLsizei count
	SV	*value
	INIT:
		loadProc(glUniform1fvARB,"glUniform1fvARB");
CODE:
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniform1fvARB(location, count, value_s);

#endif

#ifdef GL_ARB_shader_objects

void
glUniform1ivARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform1ivARB,"glUniform1ivARB");
CODE:
		GLint * value_s = EL(value, sizeof(GLint));
		glUniform1ivARB(location, count, value_s);

#endif

#ifdef GL_ARB_shader_objects

void
glUniform2fvARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform2fvARB,"glUniform2fvARB");
CODE:
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniform2fvARB(location, count, value_s);

#endif

#ifdef GL_ARB_shader_objects

void
glUniform2ivARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform2ivARB,"glUniform2ivARB");
CODE:
		GLint * value_s = EL(value, sizeof(GLint));
		glUniform2ivARB(location, count, value_s);

#endif

#ifdef GL_ARB_shader_objects

void
glUniform3fvARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform3fvARB,"glUniform3fvARB");
CODE:
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniform3fvARB(location, count, value_s);

#endif

#ifdef GL_ARB_shader_objects

void
glUniform3ivARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform3ivARB,"glUniform3ivARB");
CODE:
		GLint * value_s = EL(value, sizeof(GLint));
		glUniform3ivARB(location, count, value_s);

#endif

#ifdef GL_ARB_shader_objects

void
glUniform4fvARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform4fvARB,"glUniform4fvARB");
CODE:
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniform4fvARB(location, count, value_s);

#endif

#ifdef GL_ARB_shader_objects

void
glUniform4ivARB_s(location, count, value)
	GLint	location
	GLsizei	count
	SV	*value
	INIT:
		loadProc(glUniform4ivARB,"glUniformifvARB");
CODE:
		GLint * value_s = EL(value, sizeof(GLint));
		glUniform4ivARB(location, count, value_s);

#endif

#ifdef GL_ARB_shader_objects

void
glUniformMatrix2fvARB_s(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	SV	*value
	INIT:
		loadProc(glUniformMatrix2fvARB,"glUniformMatrix2fvARB");
CODE:
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniformMatrix2fvARB(location, count, transpose, value_s);

#endif

#ifdef GL_ARB_shader_objects

void
glUniformMatrix3fvARB_s(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	SV	*value
	INIT:
		loadProc(glUniformMatrix3fvARB,"glUniformMatrix3fvARB");
CODE:
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniformMatrix3fvARB(location, count, transpose, value_s);

#endif

#ifdef GL_ARB_shader_objects

void
glUniformMatrix4fvARB_s(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	SV	*value
	INIT:
		loadProc(glUniformMatrix4fvARB,"glUniformMatrix4fvARB");
CODE:
		GLfloat * value_s = EL(value, sizeof(GLfloat));
		glUniformMatrix4fvARB(location, count, transpose, value_s);

#endif

void
glVertex2dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glVertex2dv(v_s);

void
glVertex2fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*2);
		glVertex2fv(v_s);

void
glVertex2iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*2);
		glVertex2iv(v_s);

void
glVertex2sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glVertex2sv(v_s);

void
glVertex3dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glVertex3dv(v_s);

void
glVertex3fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glVertex3fv(v_s);

void
glVertex3iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glVertex3iv(v_s);

void
glVertex3sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glVertex3sv(v_s);

void
glVertex4dv_s(v)
	SV *	v
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glVertex4dv(v_s);

void
glVertex4fv_s(v)
	SV *	v
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glVertex4fv(v_s);

void
glVertex4iv_s(v)
	SV *	v
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glVertex4iv(v_s);

void
glVertex4sv_s(v)
	SV *	v
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glVertex4sv(v_s);

#ifdef GL_ARB_vertex_program

void
glVertexAttrib1dvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib1dvARB,"glVertexAttrib1dvARB");
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*1);
		glVertexAttrib1dvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib1fvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib1fvARB,"glVertexAttrib1fvARB");
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*1);
		glVertexAttrib1fvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib1svARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib1svARB,"glVertexAttrib1svARB");
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*1);
		glVertexAttrib1svARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib2dvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib2dvARB,"glVertexAttrib2dvARB");
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glVertexAttrib2dvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib2fvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib2fvARB,"glVertexAttrib2fvARB");
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*2);
		glVertexAttrib2fvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib2svARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib2svARB,"glVertexAttrib2svARB");
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glVertexAttrib2svARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib3dvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib3dvARB,"glVertexAttrib3dvARB");
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glVertexAttrib3dvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib3fvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib3fvARB,"glVertexAttrib3fvARB");
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glVertexAttrib3fvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib3svARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib3svARB,"glVertexAttrib3svARB");
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glVertexAttrib3svARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4NbvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NbvARB,"glVertexAttrib4NbvARB");
CODE:
		GLbyte * v_s = EL(v, sizeof(GLbyte)*4);
		glVertexAttrib4NbvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4NivARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NivARB,"glVertexAttrib4NivARB");
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glVertexAttrib4NivARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4NsvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NsvARB,"glVertexAttrib4NsvARB");
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glVertexAttrib4NsvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4NubvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NubvARB,"glVertexAttrib4NubvARB");
CODE:
		GLubyte * v_s = EL(v, sizeof(GLubyte)*4);
		glVertexAttrib4NubvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4NuivARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NuivARB,"glVertexAttrib4NuivARB");
CODE:
		GLuint * v_s = EL(v, sizeof(GLuint)*4);
		glVertexAttrib4NuivARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4NusvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4NusvARB,"glVertexAttrib4NusvARB");
CODE:
		GLushort * v_s = EL(v, sizeof(GLushort)*4);
		glVertexAttrib4NusvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4bvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4bvARB,"glVertexAttrib4bvARB");
CODE:
		GLbyte * v_s = EL(v, sizeof(GLbyte)*4);
		glVertexAttrib4bvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4dvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4dvARB,"glVertexAttrib4dvARB");
CODE:
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glVertexAttrib4dvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4fvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4fvARB,"glVertexAttrib4fvARB");
CODE:
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glVertexAttrib4fvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4ivARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4ivARB,"glVertexAttrib4ivARB");
CODE:
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glVertexAttrib4ivARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4svARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4svARB,"glVertexAttrib4svARB");
CODE:
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glVertexAttrib4svARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4ubvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4ubvARB,"glVertexAttrib4ubvARB");
CODE:
		GLubyte * v_s = EL(v, sizeof(GLubyte)*4);
		glVertexAttrib4ubvARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4uivARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4uivARB,"glVertexAttrib4uivARB");
CODE:
		GLuint * v_s = EL(v, sizeof(GLuint)*4);
		glVertexAttrib4uivARB(index,v_s);

#endif

#ifdef GL_ARB_vertex_program

void
glVertexAttrib4usvARB_s(index,v)
	GLuint index
	SV *	v
	INIT:
		loadProc(glVertexAttrib4usvARB,"glVertexAttrib4usvARB");
CODE:
		GLushort * v_s = EL(v, sizeof(GLushort)*4);
		glVertexAttrib4usvARB(index,v_s);

#endif
