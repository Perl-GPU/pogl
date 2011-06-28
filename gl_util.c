
#include "gl_util.h"

int gl_texparameter_count(GLenum pname)
{

#ifdef GL_EXT_texture_object
	switch (pname) {
	case GL_TEXTURE_PRIORITY_EXT:
	case GL_TEXTURE_RESIDENT_EXT:
		return 1;
	}
#endif

/* FIXME: Missing stuff? */

#ifdef GL_VERSION_1_2
	switch (pname) {
	case GL_TEXTURE_WRAP_R:
	case GL_TEXTURE_DEPTH:
		return 1;
	
	case GL_TEXTURE_MIN_LOD:
	case GL_TEXTURE_MAX_LOD:
	case GL_TEXTURE_BASE_LEVEL:
	case GL_TEXTURE_MAX_LEVEL:
		return 1;
	}
#endif

	switch (pname) {

	case GL_TEXTURE_MAG_FILTER:
	case GL_TEXTURE_MIN_FILTER:
	case GL_TEXTURE_WRAP_S:
	case GL_TEXTURE_WRAP_T:
	case GL_TEXTURE_PRIORITY:
	case GL_TEXTURE_RESIDENT:
		return 1;
	case GL_TEXTURE_BORDER_COLOR:
		return 4;
	default:
		croak("Unknown texparameter parameter");
	}
	return 0;	// Just to make the compiler happy
}


int gl_texenv_count(GLenum pname)
{
	switch (pname) {
	case GL_TEXTURE_ENV_MODE:
		return 1;
	case GL_TEXTURE_ENV_COLOR:
		return 4;
	default:
		croak("Unknown texenv parameter");
	}
	return 0;	// Just to make the compiler happy
}

int gl_texgen_count(GLenum pname)
{
	switch (pname) {
	case GL_TEXTURE_GEN_MODE:
		return 1;
	case GL_OBJECT_PLANE:
	case GL_EYE_PLANE:
		return 4;
	default:
		croak("Unknown texgen parameter");
	}
	return 0;	// Just to make the compiler happy
}

int gl_material_count(GLenum pname)
{
	switch (pname) {
	case GL_AMBIENT:
	case GL_DIFFUSE:
	case GL_AMBIENT_AND_DIFFUSE:
	case GL_SPECULAR:
	case GL_EMISSION:
		return 4;
	case GL_COLOR_INDEXES:
		return 3;
	case GL_SHININESS:
		return 1;
	default:
		croak("Unknown material parameter");
	}
	return 0;	// Just to make the compiler happy
}


int gl_map_count(GLenum target, GLenum query)
{
	switch (query) {
	case GL_COEFF:
		switch (target) {
		case GL_MAP1_VERTEX_3:
		case GL_MAP1_NORMAL:
		case GL_MAP1_TEXTURE_COORD_3:
			return 3;
		case GL_MAP1_VERTEX_4:
		case GL_MAP1_COLOR_4:
		case GL_MAP1_TEXTURE_COORD_4:
			return 4;
		case GL_MAP1_TEXTURE_COORD_2:
			return 2;
		case GL_MAP1_INDEX:
		case GL_MAP1_TEXTURE_COORD_1:
			return 1;
		case GL_MAP2_VERTEX_3:
		case GL_MAP2_NORMAL:
		case GL_MAP2_TEXTURE_COORD_3:
			return 3;
		case GL_MAP2_VERTEX_4:
		case GL_MAP2_COLOR_4:
		case GL_MAP2_TEXTURE_COORD_4:
			return 4;
		case GL_MAP2_TEXTURE_COORD_2:
			return 2;
		case GL_MAP2_INDEX:
		case GL_MAP2_TEXTURE_COORD_1:
			return 1;
		default:
			croak("Unknown map target");
		}
	case GL_ORDER:
		switch (target) {
		case GL_MAP1_VERTEX_3:
		case GL_MAP1_NORMAL:
		case GL_MAP1_TEXTURE_COORD_3:
		case GL_MAP1_VERTEX_4:
		case GL_MAP1_COLOR_4:
		case GL_MAP1_TEXTURE_COORD_4:
		case GL_MAP1_TEXTURE_COORD_2:
		case GL_MAP1_INDEX:
		case GL_MAP1_TEXTURE_COORD_1:
			return 1;
		case GL_MAP2_VERTEX_3:
		case GL_MAP2_NORMAL:
		case GL_MAP2_TEXTURE_COORD_3:
		case GL_MAP2_VERTEX_4:
		case GL_MAP2_COLOR_4:
		case GL_MAP2_TEXTURE_COORD_4:
		case GL_MAP2_TEXTURE_COORD_2:
		case GL_MAP2_INDEX:
		case GL_MAP2_TEXTURE_COORD_1:
			return 2;
		default:
			croak("Unknown map target");
		}
	case GL_DOMAIN:
		switch (target) {
		case GL_MAP1_VERTEX_3:
		case GL_MAP1_NORMAL:
		case GL_MAP1_TEXTURE_COORD_3:
		case GL_MAP1_VERTEX_4:
		case GL_MAP1_COLOR_4:
		case GL_MAP1_TEXTURE_COORD_4:
		case GL_MAP1_TEXTURE_COORD_2:
		case GL_MAP1_INDEX:
		case GL_MAP1_TEXTURE_COORD_1:
			return 2;
		case GL_MAP2_VERTEX_3:
		case GL_MAP2_NORMAL:
		case GL_MAP2_TEXTURE_COORD_3:
		case GL_MAP2_VERTEX_4:
		case GL_MAP2_COLOR_4:
		case GL_MAP2_TEXTURE_COORD_4:
		case GL_MAP2_TEXTURE_COORD_2:
		case GL_MAP2_INDEX:
		case GL_MAP2_TEXTURE_COORD_1:
			return 4;
		default:
			croak("Unknown map target");
		}
	default:
		croak("Unknown map query");
	}
	return 0;	// Just to make the compiler happy
}

int gl_light_count(GLenum pname)
{
	switch (pname) {
	case GL_AMBIENT:
	case GL_DIFFUSE:
	case GL_SPECULAR:
	case GL_POSITION:
		return 4;
	case GL_SPOT_DIRECTION:
		return 3;
	case GL_SPOT_EXPONENT:
	case GL_SPOT_CUTOFF:
	case GL_CONSTANT_ATTENUATION:
	case GL_LINEAR_ATTENUATION:
	case GL_QUADRATIC_ATTENUATION:
		return 1;
	default:
		croak("Unknown light parameter");
	}
	return 0;	// Just to make the compiler happy
}

int gl_lightmodel_count(GLenum pname)
{
	switch (pname) {
	case GL_LIGHT_MODEL_AMBIENT:
		return 4;
	case GL_LIGHT_MODEL_LOCAL_VIEWER:
	case GL_LIGHT_MODEL_TWO_SIDE:
		return 1;
	default:
		croak("Unknown light model");
	}
	return 0;	// Just to make the compiler happy
}

int gl_fog_count(GLenum pname)
{
	switch (pname) {
	case GL_FOG_COLOR:
		return 4;
	case GL_FOG_MODE:
	case GL_FOG_DENSITY:
	case GL_FOG_START:
	case GL_FOG_END:
	case GL_FOG_INDEX:
		return 1;
	default:
		croak("Unknown fog parameter");
	}
	return 0;	// Just to make the compiler happy
}

int gl_get_count(GLenum param)
{

/* 3 */
#ifdef GL_EXT_polygon_offset
	switch (param) {
	case GL_POLYGON_OFFSET_EXT:
	case GL_POLYGON_OFFSET_FACTOR_EXT:
	case GL_POLYGON_OFFSET_BIAS_EXT:
		return 1;
	}
#endif

#ifdef GL_VERSION_1_2

	switch (param) {

	case GL_TEXTURE_3D:
	case GL_UNPACK_SKIP_IMAGES:
	case GL_UNPACK_IMAGE_HEIGHT:
	case GL_PACK_SKIP_IMAGES:
	case GL_PACK_IMAGE_HEIGHT:
	case GL_MAX_3D_TEXTURE_SIZE:
		return 1;

	case GL_RESCALE_NORMAL:
		return 1;
	
	case GL_LIGHT_MODEL_COLOR_CONTROL:
		return 1;

	case GL_MAX_ELEMENTS_VERTICES:
	case GL_MAX_ELEMENTS_INDICES:
		return 1;
	}
#endif

#ifdef GL_VERSION_1_1
	switch (param) {
	case GL_TEXTURE_COORD_ARRAY:
	case GL_TEXTURE_COORD_ARRAY_SIZE:
	case GL_TEXTURE_COORD_ARRAY_STRIDE:
	case GL_TEXTURE_COORD_ARRAY_TYPE:
	case GL_VERTEX_ARRAY:
	case GL_VERTEX_ARRAY_SIZE:
	case GL_VERTEX_ARRAY_STRIDE:
	case GL_VERTEX_ARRAY_TYPE:
	case GL_POLYGON_OFFSET_FACTOR:
	case GL_POLYGON_OFFSET_UNITS:
	case GL_POLYGON_OFFSET_FILL:
	case GL_POLYGON_OFFSET_LINE:
	case GL_POLYGON_OFFSET_POINT:
	case GL_NORMAL_ARRAY:
	case GL_NORMAL_ARRAY_STRIDE:
	case GL_NORMAL_ARRAY_TYPE:
	case GL_INDEX_LOGIC_OP:
	case GL_INDEX_ARRAY:
	case GL_INDEX_ARRAY_STRIDE:
	case GL_INDEX_ARRAY_TYPE:
	case GL_EDGE_FLAG_ARRAY:
	case GL_EDGE_FLAG_ARRAY_STRIDE:
	case GL_COLOR_ARRAY:
	case GL_COLOR_ARRAY_SIZE:
	case GL_COLOR_ARRAY_STRIDE:
	case GL_COLOR_ARRAY_TYPE:
	case GL_COLOR_LOGIC_OP:
		return 1;
	}
#endif

/* 18 */
#ifdef GL_EXT_cmyka
	switch (param) {
	case GL_PACK_CMYK_HINT_EXT:
	case GL_UNPACK_CMYK_HINT_EXT:
		return 1;
	}
#endif

/* 30 */
#ifdef GL_EXT_vertex_array
	switch (param) {
	case GL_VERTEX_ARRAY_EXT:
	case GL_VERTEX_ARRAY_SIZE_EXT:
	case GL_VERTEX_ARRAY_STRIDE_EXT:
	case GL_VERTEX_ARRAY_TYPE_EXT:
	case GL_VERTEX_ARRAY_COUNT_EXT:
	case GL_NORMAL_ARRAY_EXT:
	case GL_NORMAL_ARRAY_STRIDE_EXT:
	case GL_NORMAL_ARRAY_TYPE_EXT:
	case GL_NORMAL_ARRAY_COUNT_EXT:
	case GL_COLOR_ARRAY_EXT:
	case GL_COLOR_ARRAY_SIZE_EXT:
	case GL_COLOR_ARRAY_STRIDE_EXT:
	case GL_COLOR_ARRAY_TYPE_EXT:
	case GL_COLOR_ARRAY_COUNT_EXT:
	case GL_INDEX_ARRAY_EXT:
	case GL_INDEX_ARRAY_STRIDE_EXT:
	case GL_INDEX_ARRAY_TYPE_EXT:
	case GL_INDEX_ARRAY_COUNT_EXT:
	case GL_TEXTURE_COORD_ARRAY_EXT:
	case GL_TEXTURE_COORD_ARRAY_SIZE_EXT:
	case GL_TEXTURE_COORD_ARRAY_STRIDE_EXT:
	case GL_TEXTURE_COORD_ARRAY_TYPE_EXT:
	case GL_TEXTURE_COORD_ARRAY_COUNT_EXT:
	case GL_EDGE_FLAG_ARRAY_EXT:
	case GL_EDGE_FLAG_ARRAY_STRIDE_EXT:
	case GL_EDGE_FLAG_ARRAY_COUNT_EXT:
		return 1;
	}
#endif

#ifdef GL_EXT_framebuffer_object
	switch (param) {
	case GL_FRAMEBUFFER_BINDING_EXT:
        case GL_RENDERBUFFER_BINDING_EXT:
        case GL_MAX_COLOR_ATTACHMENTS_EXT:
        case GL_MAX_RENDERBUFFER_SIZE_EXT:
		return 1;
	}
#endif

#ifdef GL_ARB_point_sprite
	switch (param) {
	case GL_POINT_SPRITE_ARB:
	case GL_COORD_REPLACE_ARB:
		return 1;
	}
#endif

#ifdef GL_ARB_point_parameters
	switch (param) {
	case GL_POINT_SIZE_MIN_ARB:
	case GL_POINT_SIZE_MAX_ARB:
	case GL_POINT_FADE_THRESHOLD_SIZE_ARB:
		return 1;
	case GL_POINT_DISTANCE_ATTENUATION_ARB:
		return 3;
	}
#endif

/* 79 */
#if defined(GL_EXT_clip_volume_hint) && defined(GL_VOLUME_CLIPPING_HINT_EXT)
	switch (param) {
	case GL_VOLUME_CLIPPING_HINT_EXT:
		return 1;
	}
#endif

	switch (param) {
	case GL_ACCUM_ALPHA_BITS:
	case GL_ACCUM_RED_BITS:
	case GL_ACCUM_BLUE_BITS:
	case GL_ACCUM_GREEN_BITS:
	case GL_ALPHA_BIAS:
	case GL_ALPHA_BITS:
	case GL_ALPHA_SCALE:
	case GL_ALPHA_TEST:
	case GL_ALPHA_TEST_FUNC:
	case GL_ALPHA_TEST_REF:
	case GL_ATTRIB_STACK_DEPTH:
	case GL_AUTO_NORMAL:
	case GL_AUX_BUFFERS:
	case GL_BLEND:
	case GL_BLEND_DST:
	case GL_BLEND_EQUATION_EXT:
	case GL_BLEND_SRC:
	case GL_BLUE_BIAS:
	case GL_BLUE_BITS:
	case GL_BLUE_SCALE:
	case GL_CLIENT_ATTRIB_STACK_DEPTH:
	case GL_COLOR_MATERIAL:
	case GL_COLOR_MATERIAL_FACE:
	case GL_COLOR_MATERIAL_PARAMETER:
	case GL_CULL_FACE:
	case GL_CULL_FACE_MODE:
	case GL_CURRENT_INDEX:
	case GL_CURRENT_RASTER_DISTANCE:
	case GL_CURRENT_RASTER_INDEX:
	case GL_CURRENT_RASTER_POSITION_VALID:
	case GL_DEPTH_BIAS:
	case GL_DEPTH_BITS:
	case GL_DEPTH_CLEAR_VALUE:
	case GL_DEPTH_FUNC:
	case GL_DEPTH_SCALE:
	case GL_DEPTH_TEST:
	case GL_DEPTH_WRITEMASK:
	case GL_DITHER:
	case GL_DOUBLEBUFFER:
	case GL_DRAW_BUFFER:
	case GL_EDGE_FLAG:
	case GL_FOG_DENSITY:
	case GL_FOG_END:
	case GL_FOG_HINT:
	case GL_FOG_INDEX:
	case GL_FOG_MODE:
	case GL_FOG_START:
	case GL_FRONT_FACE:
	case GL_GREEN_BIAS:
	case GL_GREEN_BITS:
	case GL_GREEN_SCALE:
	case GL_INDEX_BITS:
	case GL_INDEX_CLEAR_VALUE:
	case GL_INDEX_MODE:
	case GL_INDEX_OFFSET:
	case GL_INDEX_SHIFT:
	case GL_INDEX_WRITEMASK:
	case GL_LIGHTING:
	case GL_LIGHT_MODEL_LOCAL_VIEWER:
	case GL_LIGHT_MODEL_TWO_SIDE:
	case GL_LINE_SMOOTH:
	case GL_LINE_SMOOTH_HINT:
	case GL_LINE_STIPPLE:
	case GL_LINE_STIPPLE_PATTERN:
	case GL_LINE_STIPPLE_REPEAT:
	case GL_LINE_WIDTH:
	case GL_LINE_WIDTH_GRANULARITY:
	case GL_LIST_BASE:
	case GL_LIST_INDEX:
	case GL_LIST_MODE:
	case GL_LOGIC_OP_MODE:
	case GL_MAP1_COLOR_4:
	case GL_MAP1_GRID_SEGMENTS:
	case GL_MAP1_INDEX:
	case GL_MAP1_NORMAL:
	case GL_MAP1_TEXTURE_COORD_1:
	case GL_MAP1_TEXTURE_COORD_2:
	case GL_MAP1_TEXTURE_COORD_3:
	case GL_MAP1_TEXTURE_COORD_4:
	case GL_MAP1_VERTEX_3:
	case GL_MAP1_VERTEX_4:
	case GL_MAP2_INDEX:
	case GL_MAP2_NORMAL:
	case GL_MAP2_TEXTURE_COORD_1:
	case GL_MAP2_TEXTURE_COORD_2:
	case GL_MAP2_TEXTURE_COORD_3:
	case GL_MAP2_TEXTURE_COORD_4:
	case GL_MAP2_VERTEX_3:
	case GL_MAP2_VERTEX_4:
	case GL_MAP_COLOR:
	case GL_MAP_STENCIL:
	case GL_MATRIX_MODE:
	case GL_MAX_CLIENT_ATTRIB_STACK_DEPTH:
	case GL_MAX_ATTRIB_STACK_DEPTH:
	case GL_MAX_CLIP_PLANES:
	case GL_MAX_EVAL_ORDER:
	case GL_MAX_LIGHTS:
	case GL_MAX_LIST_NESTING:
	case GL_MAX_MODELVIEW_STACK_DEPTH:
	case GL_MAX_NAME_STACK_DEPTH:
	case GL_MAX_PIXEL_MAP_TABLE:
	case GL_MAX_PROJECTION_STACK_DEPTH:
	case GL_MAX_TEXTURE_SIZE:
	case GL_MAX_TEXTURE_STACK_DEPTH:
	case GL_MODELVIEW_STACK_DEPTH:
	case GL_NAME_STACK_DEPTH:
	case GL_NORMALIZE:
	case GL_PACK_ALIGNMENT:
	case GL_PACK_LSB_FIRST:
	case GL_PACK_ROW_LENGTH:
	case GL_PACK_SKIP_PIXELS:
	case GL_PACK_SKIP_ROWS:
	case GL_PACK_SWAP_BYTES:
	case GL_PERSPECTIVE_CORRECTION_HINT:
	case GL_PIXEL_MAP_A_TO_A_SIZE:
	case GL_PIXEL_MAP_B_TO_B_SIZE:
	case GL_PIXEL_MAP_G_TO_G_SIZE:
	case GL_PIXEL_MAP_I_TO_A_SIZE:
	case GL_PIXEL_MAP_I_TO_B_SIZE:
	case GL_PIXEL_MAP_I_TO_G_SIZE:
	case GL_PIXEL_MAP_I_TO_I_SIZE:
	case GL_PIXEL_MAP_I_TO_R_SIZE:
	case GL_PIXEL_MAP_R_TO_R_SIZE:
	case GL_PIXEL_MAP_S_TO_S_SIZE:
	case GL_POINT_SIZE:
	case GL_POINT_SIZE_GRANULARITY:
	case GL_POINT_SIZE_RANGE:
	case GL_POINT_SMOOTH:
	case GL_POINT_SMOOTH_HINT:
	case GL_POLYGON_SMOOTH:
	case GL_POLYGON_SMOOTH_HINT:
	case GL_POLYGON_STIPPLE:
	case GL_PROJECTION_STACK_DEPTH:
	case GL_READ_BUFFER:
	case GL_RED_BIAS:
	case GL_RED_BITS:
	case GL_RED_SCALE:
	case GL_RENDER_MODE:
	case GL_RGBA_MODE:
	case GL_SCISSOR_TEST:
	case GL_SHADE_MODEL:
	case GL_STENCIL_BITS:
	case GL_STENCIL_CLEAR_VALUE:
	case GL_STENCIL_FAIL:
	case GL_STENCIL_FUNC:
	case GL_STENCIL_PASS_DEPTH_FAIL:
	case GL_STENCIL_PASS_DEPTH_PASS:
	case GL_STENCIL_REF:
	case GL_STENCIL_TEST:
	case GL_STENCIL_VALUE_MASK:
	case GL_STENCIL_WRITEMASK:
	case GL_STEREO:
	case GL_SUBPIXEL_BITS:
	case GL_TEXTURE_1D:
	case GL_TEXTURE_BINDING_1D:
	case GL_TEXTURE_2D:
	case GL_TEXTURE_BINDING_2D:
	case GL_TEXTURE_GEN_Q:
	case GL_TEXTURE_GEN_R:
	case GL_TEXTURE_GEN_S:
	case GL_TEXTURE_GEN_T:
	case GL_TEXTURE_STACK_DEPTH:
	case GL_UNPACK_ALIGNMENT:
	case GL_UNPACK_LSB_FIRST:
	case GL_UNPACK_ROW_LENGTH:
	case GL_UNPACK_SKIP_PIXELS:
	case GL_UNPACK_SKIP_ROWS:
	case GL_UNPACK_SWAP_BYTES:
	case GL_ZOOM_X:
	case GL_ZOOM_Y:
		return 1;
	case GL_DEPTH_RANGE:
	case GL_LINE_WIDTH_RANGE:
	case GL_MAP1_GRID_DOMAIN:
	case GL_MAP2_GRID_SEGMENTS:
	case GL_MAX_VIEWPORT_DIMS:
	case GL_POLYGON_MODE:
		return 2;
	case GL_CURRENT_NORMAL:
		return 3;
	case GL_ACCUM_CLEAR_VALUE:
	case GL_BLEND_COLOR_EXT:
	case GL_COLOR_CLEAR_VALUE:
	case GL_COLOR_WRITEMASK:
	case GL_CURRENT_COLOR:
	case GL_CURRENT_RASTER_COLOR:
	case GL_CURRENT_RASTER_POSITION:
	case GL_CURRENT_RASTER_TEXTURE_COORDS:
	case GL_CURRENT_TEXTURE_COORDS:
	case GL_FOG_COLOR:
	case GL_LIGHT_MODEL_AMBIENT:
	case GL_MAP2_GRID_DOMAIN:
	case GL_SCISSOR_BOX:
	case GL_VIEWPORT:
		return 4;
	case GL_MODELVIEW_MATRIX:
	case GL_PROJECTION_MATRIX:
	case GL_TEXTURE_MATRIX:
		return 16;
	default:
		{
			/* GL_LIGHTi = 1 */
			static GLint max_lights = 0;
			if (!max_lights)
				glGetIntegerv(GL_MAX_LIGHTS, &max_lights);
			if ((param > GL_LIGHT0) && (param <= (GLenum)(GL_LIGHT0 + max_lights)))
				return 1;
		}
		{
			/* GL_CLIP_PLANEi = 1 */
			static GLint max_clip_planes = 0;
			if (!max_clip_planes)
				glGetIntegerv(GL_MAX_CLIP_PLANES, &max_clip_planes);
			if ((param > GL_CLIP_PLANE0) && (param <= (GLenum)(GL_CLIP_PLANE0 + max_clip_planes)))
				return 1;
		}
		croak("Unknown param");
	}
	return 0;	// Just to make the compiler happy
}


int gl_pixelmap_size(GLenum map)
{
	GLint s;
	switch (map) {
		case GL_PIXEL_MAP_I_TO_I:
			glGetIntegerv(GL_PIXEL_MAP_I_TO_I_SIZE, &s);
			return s;
		case GL_PIXEL_MAP_S_TO_S:
			glGetIntegerv(GL_PIXEL_MAP_S_TO_S_SIZE, &s);
			return s;
		case GL_PIXEL_MAP_I_TO_R:
			glGetIntegerv(GL_PIXEL_MAP_I_TO_R_SIZE, &s);
			return s;
		case GL_PIXEL_MAP_I_TO_G:
			glGetIntegerv(GL_PIXEL_MAP_I_TO_G_SIZE, &s);
			return s;
		case GL_PIXEL_MAP_I_TO_B:
			glGetIntegerv(GL_PIXEL_MAP_I_TO_B_SIZE, &s);
			return s;
		case GL_PIXEL_MAP_I_TO_A:
			glGetIntegerv(GL_PIXEL_MAP_I_TO_A_SIZE, &s);
			return s;
		case GL_PIXEL_MAP_R_TO_R:
			glGetIntegerv(GL_PIXEL_MAP_R_TO_R_SIZE, &s);
			return s;
		case GL_PIXEL_MAP_G_TO_G:
			glGetIntegerv(GL_PIXEL_MAP_G_TO_G_SIZE, &s);
			return s;
		case GL_PIXEL_MAP_B_TO_B:
			glGetIntegerv(GL_PIXEL_MAP_B_TO_B_SIZE, &s);
			return s;
		case GL_PIXEL_MAP_A_TO_A:
			glGetIntegerv(GL_PIXEL_MAP_A_TO_A_SIZE, &s);
			return s;
		default:
			croak("unknown pixelmap");
	}
	return 0;	// Just to make the compiler happy
}

int gl_state_count(GLenum state) {
	switch (state) {
		case GL_CURRENT_COLOR: return 4;
		case GL_CURRENT_INDEX: return 1;
	}
	return 0;
}

unsigned long gl_pixelbuffer_size(
	GLenum format,
	GLsizei	width,
	GLsizei	height,
	GLenum	type,
	int mode);

GLvoid * EL(SV * sv, int needlen)
{
	STRLEN skip = 0;
    SV * svref;
	
	if (SvREADONLY(sv))
		croak("Readonly value for buffer");

	if(SvROK(sv)) {
        svref = SvRV(sv);
        sv = svref;
    }
    else
    {
#ifdef USE_STRICT_UNGLOB
        if (SvFAKE(sv) && SvTYPE(sv) == SVt_PVGV)
            sv_unglob(sv);
#endif

        SvUPGRADE(sv, SVt_PV);
        SvGROW(sv, (unsigned int)(needlen + 1));
        SvPOK_on(sv);
        SvCUR_set(sv, needlen);
        *SvEND(sv) = '\0';  /* Why is this here? -chm */
    }

	return SvPV_force(sv, skip);
}

GLvoid * ELI(SV * sv, GLsizei width, GLsizei height, 
             GLenum format, GLenum type, int mode)
{
	int needlen = 0;
    if (!SvROK(sv)) /* don't calc length if arg is a perl ref */
        needlen = gl_pixelbuffer_size(format, width, height, type, mode);
	return EL(sv, needlen);
}

int gl_type_size(GLenum type)
{
	switch (type) {

#ifdef GL_VERSION_1_2
		case GL_UNSIGNED_BYTE_3_3_2:
		case GL_UNSIGNED_BYTE_2_3_3_REV:
			return sizeof(GLubyte);
		case GL_UNSIGNED_SHORT_5_6_5:
		case GL_UNSIGNED_SHORT_5_6_5_REV:
		case GL_UNSIGNED_SHORT_4_4_4_4:
		case GL_UNSIGNED_SHORT_4_4_4_4_REV:
		case GL_UNSIGNED_SHORT_5_5_5_1:
		case GL_UNSIGNED_SHORT_1_5_5_5_REV:
			return sizeof(GLushort);
		case GL_UNSIGNED_INT_8_8_8_8:
		case GL_UNSIGNED_INT_8_8_8_8_REV:
		case GL_UNSIGNED_INT_10_10_10_2:
		case GL_UNSIGNED_INT_2_10_10_10_REV:
			return sizeof(GLuint);
#endif


		case GL_UNSIGNED_BYTE: return sizeof(GLubyte); break;
		case GL_BITMAP: return sizeof(GLubyte); break;
		case GL_BYTE: return  sizeof(GLbyte); break;
		case GL_UNSIGNED_SHORT: return sizeof(GLushort); break;
		case GL_SHORT: return sizeof(GLshort); break;
		case GL_UNSIGNED_INT: return sizeof(GLuint); break;
		case GL_INT: return sizeof(GLint); break;
		case GL_FLOAT: return  sizeof(GLfloat); break;
		case GL_DOUBLE: return  sizeof(GLdouble); break;
		case GL_2_BYTES: return 2;
		case GL_3_BYTES: return 3;
		case GL_4_BYTES: return 4;
	default:
		croak("unknown type");
	}
	return 0;	// Just to make the compiler happy
}

int gl_component_count(GLenum format, GLenum type)
{
	int n;
	switch (format) {
#ifdef GL_VERSION_1_2
		case GL_BGR:
			n = 3; break;
		case GL_BGRA:
			n = 4; break;
#endif


/* 18 */
#ifdef GL_EXT_cmyka
		case GL_CMYK:
			n = 4; break;
		case GL_CMYKA:
			n = 5; break;
#endif

#ifdef GL_EXT_agbr
		case GL_AGBR:
			n = 4; break;
#endif

		case GL_COLOR_INDEX:
		case GL_STENCIL_INDEX:
		case GL_DEPTH_COMPONENT:
		case GL_RED:
		case GL_GREEN:
		case GL_BLUE:
		case GL_ALPHA:
		case GL_LUMINANCE:
			n = 1; break;
		case GL_LUMINANCE_ALPHA:
			n = 2; break;
		case GL_RGB:
			n = 3; break;
		case GL_RGBA:
			n = 4; break;
		default:
			croak("unknown format");
	}

#ifdef GL_VERSION_1_2
	switch (type) {
		case GL_UNSIGNED_BYTE_3_3_2:
		case GL_UNSIGNED_BYTE_2_3_3_REV:
		case GL_UNSIGNED_SHORT_5_6_5:
		case GL_UNSIGNED_SHORT_5_6_5_REV:
		case GL_UNSIGNED_SHORT_4_4_4_4:
		case GL_UNSIGNED_SHORT_4_4_4_4_REV:
		case GL_UNSIGNED_SHORT_5_5_5_1:
		case GL_UNSIGNED_SHORT_1_5_5_5_REV:
		case GL_UNSIGNED_INT_8_8_8_8:
		case GL_UNSIGNED_INT_8_8_8_8_REV:
		case GL_UNSIGNED_INT_10_10_10_2:
		case GL_UNSIGNED_INT_2_10_10_10_REV:
			n = 1;
	}
#endif
	return n;
}


/* From Mesa */

/* Compute ceiling of integer quotient of A divided by B: */
#define CEILING( A, B )  ( (A) % (B) == 0 ? (A)/(B) : (A)/(B)+1 )

unsigned long gl_pixelbuffer_size(
	GLenum format,
	GLsizei	width,
	GLsizei	height,
	GLenum	type,
	int mode)
{
	GLint n; /* elements in a group */
	GLint l; /* number of groups in a row */
	GLint r; /* pack/unpack row length (overrides l if nonzero) */
	GLint s; /* size (in bytes) of an element */
	GLint a; /* alignment */
	unsigned long k; /* size in bytes of row */
	
	r = 0;
	a = 4;
	
	if (mode == gl_pixelbuffer_pack) {
		glGetIntegerv(GL_PACK_ROW_LENGTH, &r);
		glGetIntegerv(GL_PACK_ALIGNMENT, &a);
	} else if (mode == gl_pixelbuffer_unpack) {
		glGetIntegerv(GL_UNPACK_ROW_LENGTH, &r);
		glGetIntegerv(GL_UNPACK_ALIGNMENT, &a);
	}

	l = r > 0 ? r : width;

	s = gl_type_size(type);
	
	n = gl_component_count(format, type);

/* From Mesa, more or less */

	if (type == GL_BITMAP) {
		k = a * CEILING( n * l, 8 * a);
	} else {
		k = l * s * n;

		if ( s < a ) {
			k = (a / s * CEILING(k, a)) * s;
		}
	}

	return k * height;
}

/* Compute ceiling of integer quotient of A divided by B: */
#define CEILING( A, B )  ( (A) % (B) == 0 ? (A)/(B) : (A)/(B)+1 )

void gl_pixelbuffer_size2(
	GLsizei	width,
	GLsizei	height,
	GLsizei depth,
	GLenum format,
	GLenum	type,
	int mode,
	GLsizei * length,
	GLsizei * items)
{
	GLint n; /* elements in a group */
	GLint l; /* number of groups in a row */
	GLint s; /* size (in bytes) of an element */
	GLint a; /* alignment */
	unsigned long k; /* size in bytes of row */
	
	a = 4;
	l = width;
	
	if (mode == gl_pixelbuffer_pack) {
		glGetIntegerv(GL_PACK_ROW_LENGTH, &l);
		glGetIntegerv(GL_PACK_ALIGNMENT, &a);
	} else if (mode == gl_pixelbuffer_unpack) {
		glGetIntegerv(GL_UNPACK_ROW_LENGTH, &l);
		glGetIntegerv(GL_UNPACK_ALIGNMENT, &a);
	}

	s = gl_type_size(type);
	
	n = gl_component_count(format, type);

/* From Mesa, more or less */

	if (type == GL_BITMAP) {
		k = a * CEILING( n * l, 8 * a);
	} else {
		k = l * s * n;

		if ( s < a ) {
			k = (a / s * CEILING(k, a)) * s;
		}
	}
	
	*items = l * n * height * depth;
	*length = (k * height * depth);
	
}

void pgl_set_type(SV * sv, GLenum type, void ** ptr)
{
#define RIV(t)	\
		(*(t*)*ptr) = (t)SvIV(sv);	\
		*(unsigned char**)ptr += sizeof(t);\
		break;
#define RNV(t)	\
		(*(t*)*ptr) = (t)SvNV(sv);	\
		*(unsigned char**)ptr += sizeof(t);\
		break;
	switch (type) {
#ifdef GL_VERSION_1_2
	case GL_UNSIGNED_BYTE_3_3_2:
	case GL_UNSIGNED_BYTE_2_3_3_REV:
		RIV(GLubyte)
	case GL_UNSIGNED_SHORT_5_6_5:
	case GL_UNSIGNED_SHORT_5_6_5_REV:
	case GL_UNSIGNED_SHORT_4_4_4_4:
	case GL_UNSIGNED_SHORT_4_4_4_4_REV:
	case GL_UNSIGNED_SHORT_5_5_5_1:
	case GL_UNSIGNED_SHORT_1_5_5_5_REV:
		RIV(GLushort)
	case GL_UNSIGNED_INT_8_8_8_8:
	case GL_UNSIGNED_INT_8_8_8_8_REV:
	case GL_UNSIGNED_INT_10_10_10_2:
	case GL_UNSIGNED_INT_2_10_10_10_REV:
		RIV(GLuint)
#endif
	case GL_UNSIGNED_BYTE:
	case GL_BITMAP:
	case GL_BYTE:
		RIV(GLubyte)
	case GL_UNSIGNED_SHORT:
	case GL_SHORT:
		RIV(GLushort)
	case GL_UNSIGNED_INT:
	case GL_INT:
		RIV(GLuint)
	case GL_FLOAT:
		RNV(GLfloat)
	case GL_DOUBLE:
		RNV(GLdouble)
	case GL_2_BYTES:
	{
		unsigned long v = SvIV(sv);
		(*(GLubyte*)*ptr) = (GLubyte)(v >> 8);
		*(unsigned char**)ptr++;
		(*(GLubyte*)*ptr) = (GLubyte)(v & 0xff);
		*(unsigned char**)ptr++;
		break;
	}
	case GL_3_BYTES:
	{
		unsigned long v = SvIV(sv);
		(*(GLubyte*)*ptr) = (GLubyte)((v >> 16) & 0xff);
		*(unsigned char**)ptr++;
		(*(GLubyte*)*ptr) = (GLubyte)((v >> 8) & 0xff);
		*(unsigned char**)ptr++;
		(*(GLubyte*)*ptr) = (GLubyte)((v >> 0) & 0xff);
		*(unsigned char**)ptr++;
		break;
	}
	case GL_4_BYTES:
	{
		unsigned long v = SvIV(sv);
		(*(GLubyte*)*ptr) = (GLubyte)((v >> 24) & 0xff);
		*(unsigned char**)ptr++;
		(*(GLubyte*)*ptr) = (GLubyte)((v >> 16) & 0xff);
		*(unsigned char**)ptr++;
		(*(GLubyte*)*ptr) = (GLubyte)((v >> 8) & 0xff);
		*(unsigned char**)ptr++;
		(*(GLubyte*)*ptr) = (GLubyte)((v >> 0) & 0xff);
		*ptr++;
		break;
	}
	default:
		croak("Unable to set data with unknown type");
	}
#undef RIV
#undef RNV
}

SV * pgl_get_type(GLenum type, void ** ptr)
{
	SV * result = 0;
#define RIV(t)	\
		result = newSViv((*(t*)*ptr));	\
		*(unsigned char**)ptr += sizeof(t);	\
		break;
#define RNV(t)	\
		result = newSVnv((*(t*)*ptr));	\
		*(unsigned char**)ptr += sizeof(t);	\
		break;

	switch (type) {
#ifdef GL_VERSION_1_2
	case GL_UNSIGNED_BYTE_3_3_2:
	case GL_UNSIGNED_BYTE_2_3_3_REV:
		RIV(GLubyte)
	case GL_UNSIGNED_SHORT_5_6_5:
	case GL_UNSIGNED_SHORT_5_6_5_REV:
	case GL_UNSIGNED_SHORT_4_4_4_4:
	case GL_UNSIGNED_SHORT_4_4_4_4_REV:
	case GL_UNSIGNED_SHORT_5_5_5_1:
	case GL_UNSIGNED_SHORT_1_5_5_5_REV:
		RIV(GLushort)
	case GL_UNSIGNED_INT_8_8_8_8:
	case GL_UNSIGNED_INT_8_8_8_8_REV:
	case GL_UNSIGNED_INT_10_10_10_2:
	case GL_UNSIGNED_INT_2_10_10_10_REV:
		RIV(GLuint)
#endif
	case GL_UNSIGNED_BYTE:
	case GL_BITMAP:
	case GL_BYTE:
		RIV(GLubyte)
	case GL_UNSIGNED_SHORT:
	case GL_SHORT:
		RIV(GLushort)
	case GL_UNSIGNED_INT:
	case GL_INT:
		RIV(GLuint)
	case GL_FLOAT:
		RNV(GLfloat)
	case GL_DOUBLE:
		RNV(GLdouble)
	case GL_2_BYTES:
	{
		unsigned long v;
		v = (*(GLubyte*)*ptr) << 8;
		*(unsigned char**)ptr++;
		v |= (*(GLubyte*)*ptr) << 0;
		*(unsigned char**)ptr++;
		result = newSViv(v);
		break;
	}
	case GL_3_BYTES:
	{
		unsigned long v;
		v = (*(GLubyte*)*ptr) << 16;
		*(unsigned char**)ptr++;
		v |= (*(GLubyte*)*ptr) << 8;
		*(unsigned char**)ptr++;
		v |= (*(GLubyte*)*ptr) << 0;
		*(unsigned char**)ptr++;
		result = newSViv(v);
		break;
	}
	case GL_4_BYTES:
	{
		unsigned long v;
		v = (*(GLubyte*)*ptr) << 24;
		*(unsigned char**)ptr++;
		v |= (*(GLubyte*)*ptr) << 16;
		*(unsigned char**)ptr++;
		v |= (*(GLubyte*)*ptr) << 8;
		*(unsigned char**)ptr++;
		v |= (*(GLubyte*)*ptr) << 0;
		*(unsigned char**)ptr++;
		result = newSViv(v);
		break;
	}
	default:
		croak("Unable to get data with unknown type");
	}
	return result;
#undef RIV
#undef RNV
}

GLvoid * pack_image_ST(SV ** stack, int count, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, int mode)
{
	int i;
	void * ptr, * optr;
	GLsizei size, max;
	gl_pixelbuffer_size2(width, height, depth, format, type, mode, &size, &max);
	optr = ptr = malloc(size);

	for (i=0;i<count;i++) {
		if (SvROK(stack[i])) {
			AV * ast[8];
			int apos[8];
			int level = 0;
			ast[0] = (AV*)SvRV(stack[i]);
			apos[0] = 0;
			
			if (SvTYPE(ast[0]) != SVt_PVAV) {
				croak("Weird nest 1");
			}
			
			while (level >= 0) {
				SV ** sv;

	 			sv = av_fetch(ast[level], apos[level]++, 0);
	 			if (!sv) {
	 				level--;
	 				continue;
	 			}
	 			
				if (SvROK(*sv)) {
					if (SvTYPE(SvRV(*sv)) != SVt_PVAV) {
						croak("Weird nest 2");
					}
					level++;
					if (level >= 8)
						goto too_many_levels;
					ast[level] = (AV*)SvRV(*sv);
					apos[level] = 0;
				} else {
					if (!max--)
						goto too_much_data;
					pgl_set_type(*sv, type, &ptr);
				}
			}
			
		} else {
			if (!max--)
				goto too_much_data;
			pgl_set_type(stack[i], type, &ptr);
		}
	}

	if (max>0)
		goto too_little_data;

	return optr;

too_little_data:
	croak("too little data");
too_much_data:
	croak("too much data");
too_many_levels:
	croak("too many levels");
	return 0;	// Just to make the compiler happy
}

GLvoid * allocate_image_ST(GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, int mode)
{
	//int i;
	void * ptr;
	GLsizei size, max;
	
	gl_pixelbuffer_size2(width, height, depth, format, type, mode, &size, &max);
	ptr = malloc(size);

	return ptr;
}

SV ** unpack_image_ST(SV ** SP, void * data, 
GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, int mode)
{
#define	sp SP
	int i;
	GLsizei size, max;

	gl_pixelbuffer_size2(width, height, depth, format, type, mode, &size, &max);

	EXTEND(sp, max);
	for (i=0;i<max;i++) {
		PUSHs(sv_2mortal(pgl_get_type(type, &data)));
	}
	
	return sp;
#undef sp
}


#ifdef __PM__

/* A very primitive emulation level for X under PM... */

#  include "os2pm_X.h"

int yScreen;		/* Will update ASAP */

void
InitSys(void) {
    yScreen = WinQuerySysValue(HWND_DESKTOP, SV_CYSCREEN);
    EventAv = newAV();
}

Bool
XQueryPointer(display, w, root_return, child_return, root_x_return,
	root_y_return, win_x_return, win_y_return, mask_return)
    Display* display;
    Window w;
    Window* root_return;
    Window* child_return;
    int* root_x_return;
    int* root_y_return;
    int* win_x_return;
    int* win_y_return;
    unsigned int* mask_return;
{
    POINTL pos;
    unsigned int  state = 0;
    static SWP clientsize;

#ifdef XDEBUG
    printf("XQueryPointer\n");
#endif
    WinQueryPointerPos(HWND_DESKTOP, &pos);
    *root_x_return = pos.x;
    /* Translate from PM to X coordinates */
    *root_y_return = yScreen - pos.y;

    WinMapWindowPoints (HWND_DESKTOP, w, &pos, 1);
    *win_x_return = pos.x;
    /* Translate from PM to X coordinates */
    WinQueryWindowPos(w,&clientsize);
    *win_y_return = clientsize.cy - pos.y;

    *root_return = HWND_DESKTOP;
    *child_return = w;

    if (WinGetKeyState(HWND_DESKTOP, VK_BUTTON1) & 0x8000)
	state |= Button1MaskOS2;
    /* Report mouse as with X */
    if (WinGetKeyState(HWND_DESKTOP, VK_BUTTON2) & 0x8000)
	state |= Button2MaskOS2;
    if (WinGetKeyState(HWND_DESKTOP, VK_BUTTON3) & 0x8000)
	state |= Button3MaskOS2;
    if (WinGetKeyState(HWND_DESKTOP, VK_CTRL) & 0x8000)
	state |= ControlMask;
    if (WinGetKeyState(HWND_DESKTOP, VK_SHIFT) & 0x8000)
	state |= ShiftMask;
    if (WinGetKeyState(HWND_DESKTOP, VK_ALT) & 0x8000)
	state |= Mod4Mask;
    if (WinGetKeyState(HWND_DESKTOP, VK_CAPSLOCK) & 0x0001)
	state |= LockMask;
    if (WinGetKeyState(HWND_DESKTOP, VK_NUMLOCK) & 0x0001)
	state |= Mod1Mask;
    if (WinGetKeyState(HWND_DESKTOP, VK_SCRLLOCK) & 0x0001)
	state |= Mod3Mask;
    *mask_return = state;
#ifdef XDEBUG
    printf("sx = %d, sy = %d, wx = %d, wx = %d, mask = %#x. \n",
	*root_x_return, *root_y_return, *win_x_return, *win_y_return, *mask_return);
#endif
    return True;
}

void
XNextEvent(Display *d, XEvent *event)
{
  SV* sv = av_shift(EventAv);
  IV n_a;

  StructCopy((XEvent*)SvPV(sv, n_a),event, XEvent);
  SvREFCNT_dec(sv);
}

void
XLookupString(XKeyEvent *xkey, char *buf, int sizeof_buf, KeySym *ks, int f)
{
  if (xkey->keycode < 256)
    *ks = (KeySym)xkey->keycode;
  else if (xkey->keycode == 256 + VK_ESC)
    *ks = (KeySym)27;
  else if (xkey->keycode == 256 + VK_ENTER)
    *ks = (KeySym)'\n';
  else if (xkey->keycode == 256 + VK_SPACE)
    *ks = (KeySym)' ';
  else if (xkey->keycode == 256 + VK_TAB)
    *ks = (KeySym)'\t';
  else
    *ks = (KeySym)'\0';
}


static MRESULT EXPENTRY WindowProc(HWND hwnd, ULONG msg, MPARAM mp1, MPARAM
mp2)
{
  static float t = 0.0;
  static SWP clientsize;
  static USHORT mycode;
  static ULONG key;

  switch(msg) {
  case WM_SIZE:
    WinQueryWindowPos(hwnd,&clientsize);
    if (LastEventMask & StructureNotifyMask) {
      XEvent x;
      SV *ev;

      x.type = ConfigureNotify;
      x.xconfigure.width = clientsize.cx;
      x.xconfigure.height = clientsize.cy;
      av_push(EventAv, newSVpv((char*)&x,sizeof(XEvent)));
    } else {
      /* Upon a resize, query new window size and set OpenGL viewport */
      glViewport(0, 0, clientsize.cx, clientsize.cy);
    }
    return WinDefWindowProc(hwnd, msg, mp1, mp2);
  case WM_TIMER:
    /* Upon getting a timer message, the invalidate rectangle call  */
    /* will cause a WM_PAINT message to be sent, enabling animation */
    WinInvalidateRect(hwnd, NULLHANDLE, 0);
    return WinDefWindowProc(hwnd, msg, mp1, mp2);
  case WM_PAINT:
    if (LastEventMask & ExposureMask) {
      XEvent x;
      SV *ev;

      x.type = Expose;
      av_push(EventAv, newSVpv((char*)&x,sizeof(XEvent)));
    }
    return WinDefWindowProc(hwnd, msg, mp1, mp2);
  case WM_CHAR:
    mycode = (USHORT)SHORT1FROMMP(mp1);
    if ((mycode & KC_CHAR) && !(mycode & KC_KEYUP))
      key = CHAR1FROMMP(mp2);
    else if ((mycode & KC_VIRTUALKEY) && !(mycode & KC_KEYUP))
      key = CHAR3FROMMP(mp2) + 256;
    else
      key = 0;
    if (key && (LastEventMask & KeyPressMask)) {
      XEvent x;
      SV *ev;

      x.type = KeyPress;
      x.xkey.keycode = key;
      av_push(EventAv, newSVpv((char*)&x,sizeof(XEvent)));
    }
    return WinDefWindowProc(hwnd, msg, mp1, mp2);
  default:
    return WinDefWindowProc(hwnd, msg, mp1, mp2);
  }
}

struct Tk_Window_t {long type; HWND w;};

Window
nativeWindowId(Display *d, Window id)
{
    if (!WinIsWindow(*d,id))			 /* Tk handle? */
	return ((struct Tk_Window_t*)id)->w;
    return id;
}


Window
MyCreateWindow(Display *d, Window par, int x, int y, int w, int h)
{
    HWND hwnd = 0, hwndTop;
    int err;

/*    fprintf(stderr, "Creating with parent=%#lx.\n", (long)par);	*/
    if (par != HWND_DESKTOP) {
      ULONG createflags = 0;

      par = nativeWindowId(d, par);
/*    fprintf(stderr, "Creating with parent=%#lx.\n", (long)par);	*/
      if (!WinRegisterClass( Perl_hab,
                             (PSZ)"PerlGLkid",
                             WindowProc,
                             CS_MOVENOTIFY, /* Need at least this! */
			     /* As documented CS_SIZEREDRAW is needed too... */
			     /* But this would not improve the visual appearence... */
                             0))
          croak("Cannot register class");
      err = CheckWinError(
		hwnd = WinCreateWindow(
                        par,   		/* Parent    */
                        (PSZ)"PerlGLkid", /* class name              */
                        NULL,		/* window title            */
                        WS_VISIBLE,     /* Window style             */
			x,y,w,h,
                        par,   		/* Owner    */
                        HWND_TOP,	/* Position    */
                        FID_CLIENT,     /* Standard id         */
                        0,              /* No class data         */
                        0));            /* No presentation parameters */
    } else {
      ULONG createflags = FCF_TITLEBAR |
                        FCF_SYSMENU    |
                        FCF_MINMAX     |
                        FCF_TASKLIST   |
                        FCF_SIZEBORDER;
    
      if (!WinRegisterClass( Perl_hab,
                             (PSZ)"PerlGLtop",
                             WindowProc,
                             CS_SIZEREDRAW | CS_MOVENOTIFY, /* Need at least this! */
                             0))
          croak("Cannot register class");
      err = CheckWinError(
	      hwndTop = WinCreateStdWindow(
                        par,   /* Parent    */
                        WS_VISIBLE,     /* Frame style             */
                        &createflags,   /* min FCF_MENU|FCF_MINMAX */
                        (PSZ)"PerlGLtop", /* class name              */
                        "OpenGL Sample",/* window title            */
                        WS_VISIBLE,     /* client style            */
                        0,              /* resource handle         */
                        1,              /* Resource ID             */
                        &hwnd));
    }
    if (err)
	croak("Cannot create window, $^E=%#x", WinGetLastError(*d));
    if (!hwnd)
	croak("Error creating window");
        /* you must set window size before you call pglMakeCurrent */
    if ((par == HWND_DESKTOP) &&
	!WinSetWindowPos( hwndTop,
			  HWND_TOP,
			  x,
			  y,
			  w,		/* XXXX Add border! */
			  h,
			  SWP_ACTIVATE | SWP_SIZE | SWP_MOVE | SWP_SHOW))
          croak("Couldn't position window!\n");
    return hwnd;
}

void
glpMoveResizeWindow(int x, int y, unsigned int width, unsigned int height, Window w, Display* display)
{
    SWP parPos;

    w = nativeWindowId(display, w);
    WinQueryWindowPos(WinQueryWindow(w, QW_PARENT), &parPos);
    /* Translate Y coordinates to PM: relative to parent */
    WinSetWindowPos(w, HWND_TOP, x, parPos.cy - height - y,
                    width, height, SWP_MOVE | SWP_SIZE);
}

void
glpMoveWindow(int x, int y, Window w, Display* display)
{
    SWP parPos;
    SWP myPos;

    w = nativeWindowId(display, w);
    WinQueryWindowPos(WinQueryWindow(w, QW_PARENT), &parPos);
    WinQueryWindowPos(w, &myPos);
    /* Translate Y coordinates to PM: relative to parent */
    WinSetWindowPos(w, HWND_TOP, x, parPos.cy - myPos.cy - y,
                    0, 0, SWP_MOVE);
}

void
glpResizeWindow(unsigned int width, unsigned int height, Window w, Display* display)
{
    SWP parPos;
    SWP myPos;

    w = nativeWindowId(display, w);
    WinQueryWindowPos(WinQueryWindow(w, QW_PARENT), &parPos);
    WinQueryWindowPos(w, &myPos);
    /* Translate Y coordinates to PM: relative to parent... */
    /* Need to move too to leave the upper left corner at the same place... */
    WinSetWindowPos(w, HWND_TOP, myPos.x, parPos.cy - myPos.cy - myPos.y,
		    width, height, SWP_MOVE | SWP_SIZE);
}

void
morphPM()
{
    PPIB pib;
    PTIB tib;

    DosGetInfoBlocks(&tib, &pib);
    if (pib->pib_ultype != 3)		/* 2 is VIO */
	pib->pib_ultype = 3;		/* 3 is PM */
}

#undef glutCreateWindow
int
my_glutCreateWindow(name)
{
    morphPM();
    return glutCreateWindow(name);
}

#endif
