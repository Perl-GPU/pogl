#ifdef GLUT_API_VERSION
	OGL_CONST_i(GLUT_API_VERSION)
#ifdef GLUT_XLIB_IMPLEMENTATION
	OGL_CONST_i(GLUT_XLIB_IMPLEMENTATION)
#endif
	OGL_CONST_i(GLUT_RGB)
	OGL_CONST_i(GLUT_RGBA)
	OGL_CONST_i(GLUT_INDEX)
	OGL_CONST_i(GLUT_SINGLE)
	OGL_CONST_i(GLUT_DOUBLE)
	OGL_CONST_i(GLUT_ACCUM)
	OGL_CONST_i(GLUT_ALPHA)
	OGL_CONST_i(GLUT_DEPTH)
	OGL_CONST_i(GLUT_STENCIL)
#if GLUT_API_VERSION >= 2
	OGL_CONST_i(GLUT_MULTISAMPLE)
	OGL_CONST_i(GLUT_STEREO)
#endif
#if GLUT_API_VERSION >= 3
	OGL_CONST_i(GLUT_LUMINANCE)
#endif
	OGL_CONST_i(GLUT_LEFT_BUTTON)
	OGL_CONST_i(GLUT_MIDDLE_BUTTON)
	OGL_CONST_i(GLUT_RIGHT_BUTTON)
	OGL_CONST_i(GLUT_DOWN)
	OGL_CONST_i(GLUT_UP)
#if GLUT_API_VERSION >= 2
	OGL_CONST_i(GLUT_KEY_F1)
	OGL_CONST_i(GLUT_KEY_F2)
	OGL_CONST_i(GLUT_KEY_F3)
	OGL_CONST_i(GLUT_KEY_F4)
	OGL_CONST_i(GLUT_KEY_F5)
	OGL_CONST_i(GLUT_KEY_F6)
	OGL_CONST_i(GLUT_KEY_F7)
	OGL_CONST_i(GLUT_KEY_F8)
	OGL_CONST_i(GLUT_KEY_F9)
	OGL_CONST_i(GLUT_KEY_F10)
	OGL_CONST_i(GLUT_KEY_F11)
	OGL_CONST_i(GLUT_KEY_F12)
	OGL_CONST_i(GLUT_KEY_LEFT)
	OGL_CONST_i(GLUT_KEY_UP)
	OGL_CONST_i(GLUT_KEY_RIGHT)
	OGL_CONST_i(GLUT_KEY_DOWN)
	OGL_CONST_i(GLUT_KEY_PAGE_UP)
	OGL_CONST_i(GLUT_KEY_PAGE_DOWN)
	OGL_CONST_i(GLUT_KEY_HOME)
	OGL_CONST_i(GLUT_KEY_END)
	OGL_CONST_i(GLUT_KEY_INSERT)
#endif
	OGL_CONST_i(GLUT_LEFT)
	OGL_CONST_i(GLUT_ENTERED)
	OGL_CONST_i(GLUT_MENU_NOT_IN_USE)
	OGL_CONST_i(GLUT_MENU_IN_USE)
	OGL_CONST_i(GLUT_NOT_VISIBLE)
	OGL_CONST_i(GLUT_VISIBLE)
#if GLUT_API_VERSION >= 4
	OGL_CONST_i(GLUT_HIDDEN)
	OGL_CONST_i(GLUT_FULLY_RETAINED)
	OGL_CONST_i(GLUT_PARTIALLY_RETAINED)
	OGL_CONST_i(GLUT_FULLY_COVERED)
#endif
	OGL_CONST_i(GLUT_RED)
	OGL_CONST_i(GLUT_GREEN)
	OGL_CONST_i(GLUT_BLUE)
	OGL_CONST_p(GLUT_STROKE_ROMAN)
	OGL_CONST_p(GLUT_STROKE_MONO_ROMAN)
	OGL_CONST_p(GLUT_BITMAP_9_BY_15)
	OGL_CONST_p(GLUT_BITMAP_8_BY_13)
	OGL_CONST_p(GLUT_BITMAP_TIMES_ROMAN_10)
	OGL_CONST_p(GLUT_BITMAP_TIMES_ROMAN_24)
#if GLUT_API_VERSION >= 3
	OGL_CONST_p(GLUT_BITMAP_HELVETICA_10)
	OGL_CONST_p(GLUT_BITMAP_HELVETICA_12)
	OGL_CONST_p(GLUT_BITMAP_HELVETICA_18)
#endif
	OGL_CONST_i(GLUT_WINDOW_X)
	OGL_CONST_i(GLUT_WINDOW_Y)
	OGL_CONST_i(GLUT_WINDOW_WIDTH)
	OGL_CONST_i(GLUT_WINDOW_HEIGHT)
	OGL_CONST_i(GLUT_WINDOW_BUFFER_SIZE)
	OGL_CONST_i(GLUT_WINDOW_STENCIL_SIZE)
	OGL_CONST_i(GLUT_WINDOW_DEPTH_SIZE)
	OGL_CONST_i(GLUT_WINDOW_RED_SIZE)
	OGL_CONST_i(GLUT_WINDOW_GREEN_SIZE)
	OGL_CONST_i(GLUT_WINDOW_BLUE_SIZE)
	OGL_CONST_i(GLUT_WINDOW_ALPHA_SIZE)
	OGL_CONST_i(GLUT_WINDOW_ACCUM_RED_SIZE)
	OGL_CONST_i(GLUT_WINDOW_ACCUM_GREEN_SIZE)
	OGL_CONST_i(GLUT_WINDOW_ACCUM_BLUE_SIZE)
	OGL_CONST_i(GLUT_WINDOW_ACCUM_ALPHA_SIZE)
	OGL_CONST_i(GLUT_WINDOW_DOUBLEBUFFER)
	OGL_CONST_i(GLUT_WINDOW_RGBA)
	OGL_CONST_i(GLUT_WINDOW_PARENT)
	OGL_CONST_i(GLUT_WINDOW_NUM_CHILDREN)
	OGL_CONST_i(GLUT_WINDOW_COLORMAP_SIZE)
#if GLUT_API_VERSION >= 2
	OGL_CONST_i(GLUT_WINDOW_NUM_SAMPLES)
	OGL_CONST_i(GLUT_WINDOW_STEREO)
#endif
#if GLUT_API_VERSION >= 3
	OGL_CONST_i(GLUT_WINDOW_CURSOR)
#endif
	OGL_CONST_i(GLUT_SCREEN_WIDTH)
	OGL_CONST_i(GLUT_SCREEN_HEIGHT)
	OGL_CONST_i(GLUT_SCREEN_WIDTH_MM)
	OGL_CONST_i(GLUT_SCREEN_HEIGHT_MM)
	OGL_CONST_i(GLUT_MENU_NUM_ITEMS)
	OGL_CONST_i(GLUT_DISPLAY_MODE_POSSIBLE)
	OGL_CONST_i(GLUT_INIT_WINDOW_X)
	OGL_CONST_i(GLUT_INIT_WINDOW_Y)
	OGL_CONST_i(GLUT_INIT_WINDOW_WIDTH)
	OGL_CONST_i(GLUT_INIT_WINDOW_HEIGHT)
	OGL_CONST_i(GLUT_INIT_DISPLAY_MODE)
#if GLUT_API_VERSION >= 2
	OGL_CONST_i(GLUT_ELAPSED_TIME)
#endif
#if GLUT_API_VERSION >= 2
	OGL_CONST_i(GLUT_HAS_KEYBOARD)
	OGL_CONST_i(GLUT_HAS_MOUSE)
	OGL_CONST_i(GLUT_HAS_SPACEBALL)
	OGL_CONST_i(GLUT_HAS_DIAL_AND_BUTTON_BOX)
	OGL_CONST_i(GLUT_HAS_TABLET)
	OGL_CONST_i(GLUT_NUM_MOUSE_BUTTONS)
	OGL_CONST_i(GLUT_NUM_SPACEBALL_BUTTONS)
	OGL_CONST_i(GLUT_NUM_BUTTON_BOX_BUTTONS)
	OGL_CONST_i(GLUT_NUM_DIALS)
	OGL_CONST_i(GLUT_NUM_TABLET_BUTTONS)
#endif
#if GLUT_API_VERSION >= 3
	OGL_CONST_i(GLUT_OVERLAY_POSSIBLE)
	OGL_CONST_i(GLUT_LAYER_IN_USE)
	OGL_CONST_i(GLUT_HAS_OVERLAY)
	OGL_CONST_i(GLUT_TRANSPARENT_INDEX)
	OGL_CONST_i(GLUT_NORMAL_DAMAGED)
	OGL_CONST_i(GLUT_OVERLAY_DAMAGED)
#endif
	OGL_CONST_i(GLUT_NORMAL)
	OGL_CONST_i(GLUT_OVERLAY)
	OGL_CONST_i(GLUT_ACTIVE_SHIFT)
	OGL_CONST_i(GLUT_ACTIVE_CTRL)
	OGL_CONST_i(GLUT_ACTIVE_ALT)
	OGL_CONST_i(GLUT_CURSOR_RIGHT_ARROW)
	OGL_CONST_i(GLUT_CURSOR_LEFT_ARROW)
	OGL_CONST_i(GLUT_CURSOR_INFO)
	OGL_CONST_i(GLUT_CURSOR_DESTROY)
	OGL_CONST_i(GLUT_CURSOR_HELP)
	OGL_CONST_i(GLUT_CURSOR_CYCLE)
	OGL_CONST_i(GLUT_CURSOR_SPRAY)
	OGL_CONST_i(GLUT_CURSOR_WAIT)
	OGL_CONST_i(GLUT_CURSOR_TEXT)
	OGL_CONST_i(GLUT_CURSOR_CROSSHAIR)
	OGL_CONST_i(GLUT_CURSOR_UP_DOWN)
	OGL_CONST_i(GLUT_CURSOR_LEFT_RIGHT)
	OGL_CONST_i(GLUT_CURSOR_TOP_SIDE)
	OGL_CONST_i(GLUT_CURSOR_BOTTOM_SIDE)
	OGL_CONST_i(GLUT_CURSOR_LEFT_SIDE)
	OGL_CONST_i(GLUT_CURSOR_RIGHT_SIDE)
	OGL_CONST_i(GLUT_CURSOR_TOP_LEFT_CORNER)
	OGL_CONST_i(GLUT_CURSOR_TOP_RIGHT_CORNER)
	OGL_CONST_i(GLUT_CURSOR_BOTTOM_RIGHT_CORNER)
	OGL_CONST_i(GLUT_CURSOR_BOTTOM_LEFT_CORNER)
	OGL_CONST_i(GLUT_CURSOR_INHERIT)
	OGL_CONST_i(GLUT_CURSOR_NONE)
	OGL_CONST_i(GLUT_CURSOR_FULL_CROSSHAIR)
#if GLUT_API_VERSION >= 4
	OGL_CONST_i(GLUT_GAME_MODE_ACTIVE)
	OGL_CONST_i(GLUT_GAME_MODE_POSSIBLE)
	OGL_CONST_i(GLUT_GAME_MODE_WIDTH)
	OGL_CONST_i(GLUT_GAME_MODE_HEIGHT)
	OGL_CONST_i(GLUT_GAME_MODE_PIXEL_DEPTH)
	OGL_CONST_i(GLUT_GAME_MODE_REFRESH_RATE)
	OGL_CONST_i(GLUT_GAME_MODE_DISPLAY_CHANGED)
#endif
#ifdef HAVE_FREEGLUT
	/* FreeGLUT Constants */
	OGL_CONST_i(GLUT_INIT_STATE)
	OGL_CONST_i(GLUT_WINDOW_FORMAT_ID)
	OGL_CONST_i(GLUT_ACTION_EXIT)
	OGL_CONST_i(GLUT_ACTION_GLUTMAINLOOP_RETURNS)
	OGL_CONST_i(GLUT_ACTION_CONTINUE_EXECUTION)
	OGL_CONST_i(GLUT_ACTION_ON_WINDOW_CLOSE)
	OGL_CONST_i(GLUT_VERSION)
	OGL_CONST_i(GLUT_DEBUG)
	OGL_CONST_i(GLUT_FORWARD_COMPATIBLE)
	OGL_CONST_i(GLUT_CORE_PROFILE)
	OGL_CONST_i(GLUT_COMPATIBILITY_PROFILE)
	OGL_CONST_i(GLUT_KEY_DELETE)
#endif
#endif
