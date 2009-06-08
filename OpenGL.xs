/*  Last saved: Mon 08 Jun 2009 05:12:45 PM  */

/*  Copyright (c) 1998 Kenneth Albanowski. All rights reserved.
 *  Copyright (c) 2007 Bob Free. All rights reserved.
 *  This program is free software; you can redistribute it and/or
 *  modify it under the same terms as Perl itself.
 */

/* OpenGL::Array */
/* #define IN_POGL_ARRAY_XS */

/* All OpenGL constants---should split */
/* #define IN_POGL_CONST_XS */

/* OpenGL OpenGL bindings */
/* #define IN_POGL_GL_XS */

/* OpenGL *GLUT bindings */
/* #define IN_POGL_GLUT_XS */

/* OpenGL GLU bindings */
/* #define IN_POGL_GLU_XS */

/* OpenGL GLX bindings */
/* #define IN_POGL_GLX_XS */

/* This ends up being OpenGL.pm */
#define IN_POGL_MAIN_XS

/* OpenGL RPN code */
/* #define IN_POGL_RPN_XS */

#include <stdio.h>

#include "pgopogl.h"

#ifdef IN_POGL_MAIN_XS
=head2 Miscellaneous

Various BOOT utilities defined in pogl_main.xs.

=over

=item PGOPOGL_CALL_BOOT(name)

call the boot code of a module by symbol rather than by name.

in a perl extension which uses several xs files but only one pm, you
need to bootstrap the other xs files in order to get their functions
exported to perl.  if the file has MODULE = Foo::Bar, the boot symbol
would be boot_Foo__Bar.

=item void _pgopogl_call_XS (pTHX_ void (*subaddr) (pTHX_ CV *), CV * cv, SV ** mark);

never use this function directly.  see C<PGOPOGLL_CALL_BOOT>.

for the curious, this calls a perl sub by function pointer rather than
by name; call_sv requires that the xsub already be registered, but we
need this to call a function which will register xsubs.  this is an
evil hack and should not be used outside of the PGOPOGL_CALL_BOOT macro.
it's implemented as a function to avoid code size bloat, and exported
so that extension modules can pull the same trick.

=cut
void
_pgopogl_call_XS (pTHX_ void (*subaddr) (pTHX_ CV *), CV * cv, SV ** mark)
{
	dSP;
	PUSHMARK (mark);
	(*subaddr) (aTHX_ cv);
	PUTBACK;	/* forget return values */
}
#endif /* End IN_POGL_MAIN_XS */

#ifdef IN_POGL_GL_XS
#ifdef HAVE_GL
#include "gl_util.h"
#endif
#endif /* End IN_POGL_GL_XS */

#ifdef IN_POGL_GLX_XS
#ifdef HAVE_GLX
#include "glx_util.h"
#endif
#endif /* End IN_POGL_GLX_XS */

#ifdef IN_POGL_GLU_XS
#ifdef HAVE_GLU
#include "glu_util.h"
#endif
#endif /* End IN_POGL_GLU_XS */

#ifdef IN_POGL_GLUT_XS
#if defined(HAVE_GLUT) || defined(HAVE_FREEGLUT)
#ifndef GLUT_API_VERSION
#define GLUT_API_VERSION 4
#endif
#include "glut_util.h"
#endif

static int _done_glutInit = 0;
#endif /* End IN_POGL_GLUT_XS */

#ifdef IN_POGL_RPN_XS
#ifndef M_PI
#ifdef PI
#define M_PI PI
#else
#define M_PI 3.1415926535897932384626433832795
#endif
#endif
#endif /* End IN_POGL_RPN_XS */

#ifdef IN_POGL_GL_XS
GLint FBO_MAX = -1;
#endif /* End IN_POGL_GL_XS */

/* This does not seem to be used */
#if 0
static char *SWIZZLE[4] = {"x","y","z","w"}; */
#endif 

/* This does not seem to be used */
#if 0
static int
not_here(s)
char *s;
{
    croak("%s not implemented on this architecture", s);
    return -1;
}
#endif


#ifdef IN_POGL_GLUT_XS
#ifndef __PM__
#  define DO_perl_call_sv(handler, flag) perl_call_sv(handler, flag)
#  define ENSURE_callback_thread
#  define GLUT_PUSH_NEW_SV(sv)		XPUSHs(sv_2mortal(newSVsv(sv)))
#  define GLUT_PUSH_NEW_IV(i)		XPUSHs(sv_2mortal(newSViv(i)))
#  define GLUT_PUSH_NEW_U8(c)		XPUSHs(sv_2mortal(newSViv((int)c)))
#  define GLUT_EXTEND_STACK(sp,n)
#  define GLUT_PUSHMARK(sp)		PUSHMARK(sp)
#else
/* GLUT on OS/2 PM runs callbacks from a secondary thread.  This thread
   is not instrumented to run EMX CRTL functions.  Basically, no Perl
   function may be run from this thread.
   We create a ternary thread via CRTL _beginthread() call, and communicate
   the requests to this thread via inter-thread communication (ITC).  */

#  define GLUT_PUSHMARK(sp)

#  include "sys/builtin.h"
#  include "sys/fmutex.h"

#  include "os2pm_X.h"

#  define DO_perl_call_sv(handler, flag) 				\
    STMT_START {   	PUSHs(handler);					\
			PUTBACK;					\
			extend_by = 0;					\
			RUN_perl_call_sv();				\
    } STMT_END

#  define GLUT_START_PUSHING		7
#  define GLUT_PUSHING_IVP		17
#  define GLUT_PUSHING_U8		27
#  define GLUT_PUSHING_SV		37

#  define GLUT_EXTEND_STACK(p,n)					\
    STMT_START {   if (PL_stack_max - p < 2*(n)+4) {			\
		     extend_by = 2*(n)+4;				\
		     RUN_perl_call_sv();				\
		   }							\
		   SPAGAIN;						\
		   PUSHs((SV*)GLUT_START_PUSHING);			\
    } STMT_END

#  define GLUT_PUSH_NEW_SV(sv)	(PUSHs(sv), PUSHs((SV*)GLUT_PUSHING_SV))
#  define GLUT_PUSH_NEW_IV(i)	(PUSHs((SV*)&i), PUSHs((SV*)GLUT_PUSHING_IVP))
#  define GLUT_PUSH_NEW_U8(c)	(PUSHs((SV*)(int)c), PUSHs((SV*)GLUT_PUSHING_U8))

_fmutex run_mutex, result_mutex;
static int worker_started;
static int extend_by;

void
RUN_perl_call_sv(void)
{
    char *s = NULL;
    
    if (_fmutex_release(&run_mutex))
	s = "Error unlocking the callback thread";
    /* result_mutex is requested on entry!  Block until looper finishes. */
    else if (_fmutex_request(&result_mutex, _FMR_IGNINT))
	s = "Error requesting the callback thread";
    if (s)
	write(2, s, strlen(s));
    return;
}

/* Main event handler for callbacks */
void
callback_thread_looper(void *dummy)
{
    while (1) {
	/* It is requested already!  Wait until somebody requests a run */
	if (_fmutex_request(&run_mutex, _FMR_IGNINT)) {
	    warn("Error unlocking in the callback thread");
	    worker_started = 0;
	    return;
	}
	if (extend_by) {  /* Need to extend the stack */
	    dSP;

	    EXTEND(sp, extend_by);
	} else {
	    dSP;
	    SV* handler = POPs;
	    STRLEN n_a;
	    SV **last = sp, **f;

	    /* The rest is put on stack in a "raw" pointer form */
	    while (1) {
		switch ((IV)*sp) {
		case GLUT_START_PUSHING:
		    goto start_found;
		    break;
		case GLUT_PUSHING_IVP:
		case GLUT_PUSHING_SV:
		case GLUT_PUSHING_U8:
		    break;
		default:
		    croak("Panic: broken descriptor/down when ITC for Glut: %#lx", (unsigned long)*sp);
		    break;
		}
		sp -= 2;
	    }
	  start_found:
	    f = sp + 1;
	    sp--;
	    PUSHMARK(sp);
	    while (f < last) {
		switch ((IV)f[1]) {
		case GLUT_PUSHING_IVP:
		    PUSHs(sv_2mortal(newSViv(*(IV*)*f)));
		    break;
		case GLUT_PUSHING_U8:
		    PUSHs(sv_2mortal(newSViv((IV)*f)));
		    break;
		case GLUT_PUSHING_SV:
		    PUSHs(sv_2mortal(newSVsv(*f)));
		    break;
		default:
		    croak("Panic: broken descriptor/up when ITC for Glut: %#lx", (unsigned long)f[1]);
		    break;
		}
		f += 2;
	    }
	    PUTBACK;
	    perl_call_sv(handler, G_DISCARD|G_EVAL);
	    if (SvTRUE(ERRSV))
		fprintf(stderr, "Error in a GLUT Callback: %s", SvPV(ERRSV, n_a));
	}
	if (_fmutex_release(&result_mutex)) {
	    warn("Error in a callback thread");
	    worker_started = 0;
	    return;
	}	
    }
}

#  define ENSURE_callback_thread					\
	if (!worker_started)						\
	    start_callback_thread()

/* Spin a thread for a callback */
void
start_callback_thread()
{
    unsigned long rc;

    if (worker_started)
	return;
    if (  CheckOSError(_fmutex_create(&run_mutex, 0))
	  || CheckOSError(_fmutex_create(&result_mutex, 0))
	  || CheckOSError(_fmutex_request(&run_mutex, _FMR_IGNINT))
	  || CheckOSError(_fmutex_request(&result_mutex, _FMR_IGNINT)))
	croak("Error creating semaphores");
    worker_started = _beginthread(&callback_thread_looper, NULL,
				   8*1024*1024, NULL);
    if (worker_started == -1) {
	worker_started = 0;
	croak("Error creating callback thread");
    }
}
#endif	/* __PM__ */
#endif /* End IN_POGL_GLUT_XS */

#ifdef IN_POGL_CONST_XS
/* These macros used in neoconstant */
#define i(test) if (strEQ(name, #test)) return newSViv((int)test);
#define f(test) if (strEQ(name, #test)) return newSVnv((double)test);

static SV *
neoconstant(char * name, int arg)
{
#include "gl_const.h"
#include "glu_const.h"
#include "glut_const.h"
#include "glx_const.h"
#include "glpm_const.h"
	;
	return 0;
}

#undef i
#undef f
#endif /* End IN_POGL_CONST_XS */

#ifdef IN_POGL_GL_XS
/* Note: this is caching procs once for all contexts */
/* !!! This should instead cache per context */
#ifdef HAVE_GL
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
#else
#define loadProc(proc,name)
#define testProc(proc,name) 1
#endif
#endif
#endif /* End IN_POGL_GL_XS */


#ifdef IN_POGL_GLX_XS
#ifdef HAVE_GLX
#  define HAVE_GLpc			/* Perl interface */
#  define nativeWindowId(d, w)	(w)
static Bool WaitForNotify(Display *d, XEvent *e, char *arg) {
    return (e->type == MapNotify) && (e->xmap.window == (Window)arg);
}
#  define glpResizeWindow(s1,s2,w,d)	XResizeWindow(d,w,s1,s2)
#  define glpMoveWindow(s1,s2,w,d)		XMoveWindow(d,w,s1,s2)
#  define glpMoveResizeWindow(s1,s2,s3,s4,w,d)	XMoveResizeWindow(d,w,s1,s2,s3,s4)
#endif	/* defined HAVE_GLX */ 


#ifdef __PM__

#  define HAVE_GLpc			/* Perl interface */
#  define auxXWindow()	(croak("Not implemented: auxXWindow"),0)

HMQ hmq;
AV *EventAv;
unsigned long LastEventMask;	/* !! Common for all the windows */
Display myDisplay;

#endif	/* defined __PM__ */ 

#ifdef HAVE_GLpc

#  define NUM_ARG 7

Display *dpy;
int dpy_open;
XVisualInfo *vi;
Colormap cmap;
XSetWindowAttributes swa;
Window win;
GLXContext cx;

static int default_attributes[] = { GLX_DOUBLEBUFFER, GLX_RGBA };

#endif	/* defined HAVE_GLpc */ 

static int DBUFFER_HACK = 0;
#define __had_dbuffer_hack() (DBUFFER_HACK)

#endif /* End IN_POGL_GLX_XS */

/*
#define PackCallbackST(av,first)					\
	if (SvROK(ST(first)) && (SvTYPE(SvRV(ST(first))) == SVt_PVAV)){	\
		int i;							\
		AV * x = (AV*)SvRV(ST(first));				\
		for(i=0;i<=av_len(x);i++) {				\
			av_push(av, newSVsv(*av_fetch(x, i, 0)));	\
		}							\
	} else {							\
		int i;							\
		for(i=first;i<items;i++)				\
			av_push(av, newSVsv(ST(i)));			\
	}

*/

#ifdef IN_POGL_GLUT_XS

#ifdef GLUT_API_VERSION

static AV * glut_handlers = 0;

/* Attach a handler to a window */
static void set_glut_win_handler(int win, int type, SV * data)
{
	SV ** h;
	AV * a;
	
	if (!glut_handlers)
		glut_handlers = newAV();
	
	h = av_fetch(glut_handlers, win, FALSE);
	
	if (!h) {
		a = newAV();
		av_store(glut_handlers, win, newRV_inc((SV*)a));
		SvREFCNT_dec(a);
	} else if (!SvOK(*h) || !SvROK(*h))
		croak("Unable to establish glut handler");
	else 
		a = (AV*)SvRV(*h);
	
	av_store(a, type, newRV_inc(data));
	SvREFCNT_dec(data);
}

/* Get a window's handler */
static SV * get_glut_win_handler(int win, int type)
{
	SV ** h;
	
	if (!glut_handlers)
		croak("Unable to locate glut handler");
	
	h = av_fetch(glut_handlers, win, FALSE);

	if (!h || !SvOK(*h) || !SvROK(*h))
		croak("Unable to locate glut handler");
	
	h = av_fetch((AV*)SvRV(*h), type, FALSE);
	
	if (!h || !SvOK(*h) || !SvROK(*h))
		croak("Unable to locate glut handler");

	return SvRV(*h);
}

/* Release a window's handlers */
static void destroy_glut_win_handlers(int win)
{
	SV ** h;
	
	if (!glut_handlers)
		return;
	
	h = av_fetch(glut_handlers, win, FALSE);
	
	if (!h || !SvOK(*h) || !SvROK(*h))
		return;

	av_store(glut_handlers, win, newSVsv(&PL_sv_undef));
}

/* Release a handler */
static void destroy_glut_win_handler(int win, int type)
{
	SV ** h;
	AV * a;
	
	if (!glut_handlers)
		glut_handlers = newAV();
	
	h = av_fetch(glut_handlers, win, FALSE);
	
	if (!h || !SvOK(*h) || !SvROK(*h))
		return;

	a = (AV*)SvRV(*h);
	
	av_store(a, type, newSVsv(&PL_sv_undef));
}

/* Begin window callback definition */
#define begin_decl_gwh(type, params, nparam)				\
									\
static void generic_glut_ ## type ## _handler params			\
{									\
	int win = glutGetWindow();					\
	AV * handler_data = (AV*)get_glut_win_handler(win, HANDLE_GLUT_ ## type);\
	SV * handler;							\
	int i;								\
	dSP;								\
									\
	handler = *av_fetch(handler_data, 0, 0);			\
									\
	GLUT_PUSHMARK(sp);						\
	GLUT_EXTEND_STACK(sp,av_len(handler_data)+nparam);		\
	for (i=1;i<=av_len(handler_data);i++)				\
		GLUT_PUSH_NEW_SV(*av_fetch(handler_data, i, 0));

/* End window callback definition */
#define end_decl_gwh()							\
	PUTBACK;							\
	DO_perl_call_sv(handler, G_DISCARD);				\
}

/* Activate a window callback handler */
#define decl_gwh_xs(type)						\
	{								\
		int win = glutGetWindow();				\
									\
		if (!handler || !SvOK(handler)) {			\
			destroy_glut_win_handler(win, HANDLE_GLUT_ ## type);\
			glut ## type ## Func(NULL);			\
		} else {						\
			AV * handler_data = newAV();			\
									\
			PackCallbackST(handler_data, 0);		\
									\
			set_glut_win_handler(win, HANDLE_GLUT_ ## type, (SV*)handler_data);\
									\
			glut ## type ## Func(generic_glut_ ## type ## _handler);\
		}							\
	ENSURE_callback_thread;}

/* Activate a window callback handler; die on failure */
#define decl_gwh_xs_nullfail(type, fail)				\
	{								\
		int win = glutGetWindow();				\
									\
		if (!handler || !SvOK(handler)) {			\
			croak fail;					\
		} else {						\
			AV * handler_data = newAV();			\
									\
			PackCallbackST(handler_data, 0);		\
									\
			set_glut_win_handler(win, HANDLE_GLUT_ ## type, (SV*)handler_data);\
									\
			glut ## type ## Func(generic_glut_ ## type ## _handler);\
		}							\
	ENSURE_callback_thread;}


/* Activate a global state callback handler */
#define decl_ggh_xs(type)						\
	{								\
		if (glut_ ## type ## _handler_data)			\
			SvREFCNT_dec(glut_ ## type ## _handler_data);	\
									\
		if (!handler || !SvOK(handler)) {			\
			glut_ ## type ## _handler_data = 0;		\
			glut ## type ## Func(NULL);			\
		} else {						\
			AV * handler_data = newAV();			\
									\
			PackCallbackST(handler_data, 0);		\
									\
			glut_ ## type ## _handler_data = handler_data;	\
									\
			glut ## type ## Func(generic_glut_ ## type ## _handler);\
		}							\
	ENSURE_callback_thread;}


/* Begin a global state callback definition */
#define begin_decl_ggh(type, params, nparam)				\
									\
static AV * glut_ ## type ## _handler_data = 0;				\
									\
static void generic_glut_ ## type ## _handler params			\
{									\
	AV * handler_data = glut_ ## type ## _handler_data;		\
	SV * handler;							\
	int i;								\
	dSP;								\
									\
	handler = *av_fetch(handler_data, 0, 0);			\
									\
	GLUT_PUSHMARK(sp);						\
	GLUT_EXTEND_STACK(sp,av_len(handler_data)+nparam);		\
	for (i=1;i<=av_len(handler_data);i++)				\
		GLUT_PUSH_NEW_SV(*av_fetch(handler_data, i, 0));

/* End a global state callback definition */
#define end_decl_ggh()							\
	PUTBACK;							\
	DO_perl_call_sv(handler, G_DISCARD);				\
}

/* Define callbacks */
enum {
	HANDLE_GLUT_Display,
	HANDLE_GLUT_OverlayDisplay,
	HANDLE_GLUT_Reshape,
	HANDLE_GLUT_Keyboard,
	HANDLE_GLUT_KeyboardUp,
	HANDLE_GLUT_Mouse,
        HANDLE_GLUT_MouseWheel,             /* Open/FreeGLUT -chm */
	HANDLE_GLUT_Motion,
	HANDLE_GLUT_PassiveMotion,
	HANDLE_GLUT_Entry,
	HANDLE_GLUT_Visibility,
	HANDLE_GLUT_WindowStatus,
	HANDLE_GLUT_Special,
	HANDLE_GLUT_SpecialUp,
        HANDLE_GLUT_Joystick,               /* Open/FreeGLUT -chm */
	HANDLE_GLUT_SpaceballMotion,
	HANDLE_GLUT_SpaceballRotate,
	HANDLE_GLUT_SpaceballButton,
	HANDLE_GLUT_ButtonBox,
	HANDLE_GLUT_Dials,
	HANDLE_GLUT_TabletMotion,
	HANDLE_GLUT_TabletButton,
        HANDLE_GLUT_MenuDestroy,            /* Open/FreeGLUT -chm */
	HANDLE_GLUT_Close
};

/* Callback for glutDisplayFunc */
begin_decl_gwh(Display, (void), 0)
end_decl_gwh()

/* Callback for glutOverlayDisplayFunc */
begin_decl_gwh(OverlayDisplay, (void), 0)
end_decl_gwh()

/* Callback for glutReshapeFunc */
begin_decl_gwh(Reshape, (int width, int height), 2)
	GLUT_PUSH_NEW_IV(width);
	GLUT_PUSH_NEW_IV(height);
end_decl_gwh()

/* Callback for glutKeyboardFunc */
begin_decl_gwh(Keyboard, (unsigned char key, int width, int height), 3)
	GLUT_PUSH_NEW_U8(key);
	GLUT_PUSH_NEW_IV(width);
	GLUT_PUSH_NEW_IV(height);
end_decl_gwh()

/* Callback for glutKeyboardUpFunc */
begin_decl_gwh(KeyboardUp, (unsigned char key, int width, int height), 3)
	GLUT_PUSH_NEW_U8(key);
	GLUT_PUSH_NEW_IV(width);
	GLUT_PUSH_NEW_IV(height);
end_decl_gwh()

/* Callback for glutMouseFunc */
begin_decl_gwh(Mouse, (int button, int state, int x, int y), 4)
	GLUT_PUSH_NEW_IV(button);
	GLUT_PUSH_NEW_IV(state);
	GLUT_PUSH_NEW_IV(x);
	GLUT_PUSH_NEW_IV(y);
end_decl_gwh()

/* Callback for glutMouseWheelFunc */	/* Open/FreeGLUT -chm */
begin_decl_gwh(MouseWheel, (int wheel, int direction, int x, int y), 4)
	GLUT_PUSH_NEW_IV(wheel);
	GLUT_PUSH_NEW_IV(direction);
	GLUT_PUSH_NEW_IV(x);
	GLUT_PUSH_NEW_IV(y);
end_decl_gwh()

/* Callback for glutPassiveMotionFunc */
begin_decl_gwh(PassiveMotion, (int x, int y), 2)
	GLUT_PUSH_NEW_IV(x);
	GLUT_PUSH_NEW_IV(y);
end_decl_gwh()

/* Callback for glutMotionFunc */
begin_decl_gwh(Motion, (int x, int y), 2)
	GLUT_PUSH_NEW_IV(x);
	GLUT_PUSH_NEW_IV(y);
end_decl_gwh()

/* Callback for glutVisibilityFunc */
begin_decl_gwh(Visibility, (int state), 1)
	GLUT_PUSH_NEW_IV(state);
end_decl_gwh()

/* Callback for glutWindowStatusFunc */
begin_decl_gwh(WindowStatus, (int state), 1)
	GLUT_PUSH_NEW_IV(state);
end_decl_gwh()

/* Callback for glutEntryFunc */
begin_decl_gwh(Entry, (int state), 1)
	GLUT_PUSH_NEW_IV(state);
end_decl_gwh()

/* Callback for glutSpecialFunc */
begin_decl_gwh(Special, (int key, int width, int height), 3)
	GLUT_PUSH_NEW_IV(key);
	GLUT_PUSH_NEW_IV(width);
	GLUT_PUSH_NEW_IV(height);
end_decl_gwh()

/* Callback for glutSpecialUpFunc */
begin_decl_gwh(SpecialUp, (int key, int width, int height), 3)
	GLUT_PUSH_NEW_IV(key);
	GLUT_PUSH_NEW_IV(width);
	GLUT_PUSH_NEW_IV(height);
end_decl_gwh()

/* Callback for glutJoystickFunc */	/* Open/FreeGLUT -chm */
begin_decl_gwh(Joystick, (unsigned int buttons, int xaxis, int yaxis, int zaxis), 4)
	GLUT_PUSH_NEW_IV(buttons);
	GLUT_PUSH_NEW_IV(xaxis);
	GLUT_PUSH_NEW_IV(yaxis);
	GLUT_PUSH_NEW_IV(zaxis);
end_decl_gwh()


/* Callback for glutSpaceballMotionFunc */
begin_decl_gwh(SpaceballMotion, (int x, int y, int z), 3)
	GLUT_PUSH_NEW_IV(x);
	GLUT_PUSH_NEW_IV(y);
	GLUT_PUSH_NEW_IV(z);
end_decl_gwh()

/* Callback for glutSpaceballRotateFunc */
begin_decl_gwh(SpaceballRotate, (int x, int y, int z), 3)
	GLUT_PUSH_NEW_IV(x);
	GLUT_PUSH_NEW_IV(y);
	GLUT_PUSH_NEW_IV(z);
end_decl_gwh()

/* Callback for glutSpaceballButtonFunc */
begin_decl_gwh(SpaceballButton, (int button, int state), 2)
	GLUT_PUSH_NEW_IV(button);
	GLUT_PUSH_NEW_IV(state);
end_decl_gwh()

/* Callback for glutButtonBoxFunc */
begin_decl_gwh(ButtonBox, (int button, int state), 2)
	GLUT_PUSH_NEW_IV(button);
	GLUT_PUSH_NEW_IV(state);
end_decl_gwh()

/* Callback for glutDialsFunc */
begin_decl_gwh(Dials, (int dial, int value), 2)
	GLUT_PUSH_NEW_IV(dial);
	GLUT_PUSH_NEW_IV(value);
end_decl_gwh()

/* Callback for glutTabletMotionFunc */
begin_decl_gwh(TabletMotion, (int x, int y), 2)
	GLUT_PUSH_NEW_IV(x);
	GLUT_PUSH_NEW_IV(y);
end_decl_gwh()

/* Callback for glutTabletButtonFunc */
begin_decl_gwh(TabletButton, (int button, int state, int x, int y), 4)
	GLUT_PUSH_NEW_IV(button);
	GLUT_PUSH_NEW_IV(state);
	GLUT_PUSH_NEW_IV(x);
	GLUT_PUSH_NEW_IV(y);
end_decl_gwh()

/* Callback for glutIdleFunc */
begin_decl_ggh(Idle, (void), 0)
end_decl_ggh()

/* Callback for glutMenuStatusFunc */
begin_decl_ggh(MenuStatus, (int status, int x, int y), 3)
	GLUT_PUSH_NEW_IV(status);
	GLUT_PUSH_NEW_IV(x);
	GLUT_PUSH_NEW_IV(y);
end_decl_ggh()

/* Callback for glutMenuStateFunc */
begin_decl_ggh(MenuState, (int status), 1)
	GLUT_PUSH_NEW_IV(status);
end_decl_ggh()

/* Callback for glutMenuDestroyFunc */		/* Open/FreeGLUT -chm */
begin_decl_gwh(MenuDestroy, (void), 0)
end_decl_gwh()

/* Callback for glutCloseFunc */
static void generic_glut_Close_handler(void)
{
	int win = glutGetWindow();
	AV * handler_data = (AV*)get_glut_win_handler(win, HANDLE_GLUT_Close);
	SV * handler = *av_fetch(handler_data, 0, 0);
	dSP;

	GLUT_PUSHMARK(sp);
	GLUT_EXTEND_STACK(sp,1);
	GLUT_PUSH_NEW_IV(win);

	PUTBACK;
	DO_perl_call_sv(handler, G_DISCARD);
}

/* Callback for glutTimerFunc */
static void generic_glut_timer_handler(int value)
{
	AV * handler_data = (AV*)value;
	SV * handler;
	int i;
	dSP;

	handler = *av_fetch(handler_data, 0, 0);

	GLUT_PUSHMARK(sp);
	GLUT_EXTEND_STACK(sp,av_len(handler_data));
	for (i=1;i<=av_len(handler_data);i++)
		GLUT_PUSH_NEW_SV(*av_fetch(handler_data, i, 0));

	PUTBACK;
	DO_perl_call_sv(handler, G_DISCARD);
	
	SvREFCNT_dec(handler_data);
}

static AV * glut_menu_handlers = 0;

/* Callback for glutMenuFunc */
static void generic_glut_menu_handler(int value)
{
	AV * handler_data;
	SV * handler;
	SV ** h;
	int i;
	dSP;
	
	h = av_fetch(glut_menu_handlers, glutGetMenu(), FALSE);
	if (!h || !SvOK(*h) || !SvROK(*h))
		croak("Unable to locate menu handler");
	
	handler_data = (AV*)SvRV(*h);

	handler = *av_fetch(handler_data, 0, 0);

	GLUT_PUSHMARK(sp);
	GLUT_EXTEND_STACK(sp,av_len(handler_data) + 1);
	for (i=1;i<=av_len(handler_data);i++)
		GLUT_PUSH_NEW_SV(*av_fetch(handler_data, i, 0));

	GLUT_PUSH_NEW_IV(value);

	PUTBACK;
	DO_perl_call_sv(handler, G_DISCARD);
}


#endif /* def GLUT_API_VERSION */

#endif /* End IN_POGL_GLUT_XS */

#ifdef IN_POGL_GLU_XS

/* Begin a named callback handler */
#define begin_void_specific_marshaller(name, assign_handler_av, params) \
static void _s_marshal_ ## name params					\
{                                                                       \
    SV * handler;                                                       \
	AV * handler_av;                                                \
	dSP;                                                            \
	int i;                                                          \
	assign_handler_av;                                              \
	if (!handler_av) croak("Failure of callback handler");          \
	handler = *av_fetch(handler_av, 0, 0);                          \
    PUSHMARK(sp);                                                       \
    for (i=1; i<=av_len(handler_av); i++)                               \
        XPUSHs(sv_2mortal(newSVsv(*av_fetch(handler_av, i, 0))));

/* End a named callback handler */
#define end_void_specific_marshaller()                                  \
	PUTBACK;                                                        \
	perl_call_sv(handler, G_DISCARD);                               \
}


struct PGLUtess {
	GLUtriangulatorObj * triangulator;

#ifdef GLU_VERSION_1_2
	AV * polygon_data_av;
	AV * begin_callback;
	AV * edgeFlag_callback;
	AV * vertex_callback;
	AV * end_callback;
	AV * error_callback;
	AV * combine_callback;
#endif
	
	AV * vertex_datas;
};

typedef struct PGLUtess PGLUtess;

#ifdef GLU_VERSION_1_2


/* Begin a gluTess callback handler */
#define begin_tess_marshaller(type, params)				\
begin_void_specific_marshaller(glu_t_callback_ ## type,                 \
	PGLUtess * t = (PGLUtess*)polygon_data;                         \
	handler_av = t-> type ## _callback                              \
	, params)                                                       \
    if (t->polygon_data_av)                                             \
      for (i=0; i<=av_len(t->polygon_data_av); i++)                     \
        XPUSHs(sv_2mortal(newSVsv(*av_fetch(t->polygon_data_av, i, 0))));

/* End a gluTess callback handler */
#define end_tess_marshaller()                                           \
end_void_specific_marshaller()

/* Declare gluTess BEGIN */
begin_tess_marshaller(begin, (GLenum type, void * polygon_data))
	XPUSHs(sv_2mortal(newSViv(type)));
end_tess_marshaller()

/* Declare gluTess END */
begin_tess_marshaller(end, (void * polygon_data))
end_tess_marshaller()

/* Declare gluTess EDGEFLAG */
begin_tess_marshaller(edgeFlag, (GLboolean flag, void * polygon_data))
	XPUSHs(sv_2mortal(newSViv(flag)));
end_tess_marshaller()

/* Declare gluTess VERTEX */
begin_tess_marshaller(vertex, (void * vertex_data, void * polygon_data))
	if (vertex_data) {
      AV * vd = (AV*)vertex_data;
      for (i=0; i<=av_len(vd); i++)
        XPUSHs(sv_2mortal(newSVsv(*av_fetch(vd, i, 0))));
    }
end_tess_marshaller()

/* Declare gluTess ERROR */
begin_tess_marshaller(error, (GLenum errno_, void * polygon_data))
	XPUSHs(sv_2mortal(newSViv(errno_)));
end_tess_marshaller()

/* Declare gluTess COMBINE */
begin_tess_marshaller(combine, (GLdouble coords[3], void * vertex_data[4], GLfloat weight[4], void ** outd, void * polygon_data))
	croak("combine tess marshaller needs FIXME (see OpenGL.xs)");
end_tess_marshaller()

#endif

#endif /* End IN_POGL_GLU_XS */

#if 0
typedef void * ptr;
#endif  /* Does not seem to be used.  Uncomment if breaks. chm 29-May-2009 */


#if 0
/* Get a Perl parameter, cast to C type */
#define SvItems(type,offset,count,dst)					\
{									\
	GLuint i;							\
	switch (type)							\
	{								\
		case GL_UNSIGNED_BYTE:					\
		case GL_BITMAP:						\
			for (i=0;i<(count);i++)				\
			{						\
			  ((GLubyte*)(dst))[i] = (GLubyte)SvIV(ST(i+(offset)));	\
			}						\
			break;						\
		case GL_BYTE:						\
			for (i=0;i<(count);i++)				\
			{						\
			  ((GLbyte*)(dst))[i] = (GLbyte)SvIV(ST(i+(offset)));	\
			}						\
			break;						\
		case GL_UNSIGNED_SHORT:					\
			for (i=0;i<(count);i++)				\
			{						\
			  ((GLushort*)(dst))[i] = (GLushort)SvIV(ST(i+(offset)));	\
			}						\
			break;						\
		case GL_SHORT:						\
			for (i=0;i<(count);i++)				\
			{						\
			  ((GLshort*)(dst))[i] = (GLshort)SvIV(ST(i+(offset)));	\
			}						\
			break;						\
		case GL_UNSIGNED_INT:					\
			for (i=0;i<(count);i++)				\
			{						\
			  ((GLuint*)(dst))[i] = (GLuint)SvIV(ST(i+(offset)));	\
			}						\
			break;						\
		case GL_INT:						\
			for (i=0;i<(count);i++)				\
			{						\
			  ((GLint*)(dst))[i] = (GLint)SvIV(ST(i+(offset)));	\
			}						\
			break;						\
		case GL_FLOAT:						\
			for (i=0;i<(count);i++)				\
			{						\
			  ((GLfloat*)(dst))[i] = (GLfloat)SvNV(ST(i+(offset)));	\
			}						\
			break;						\
		case GL_DOUBLE:						\
			for (i=0;i<(count);i++)				\
			{						\
			  ((GLdouble*)(dst))[i] = (GLdouble)SvNV(ST(i+(offset)));	\
			}						\
			break;						\
		default:						\
			croak("unknown type");				\
	}								\
}
#endif /* Moved SvItems to gl_util.h */


#ifdef IN_POGL_RPN_XS

/********************/
/* RPN Processor    */
/********************/

/* RPN Ops */
enum
{
  RPN_NOP = 0,
  RPN_PSH,
  RPN_POP,

  RPN_CNT,
  RPN_IDX,
  RPN_CLS,
  RPN_COL,
  RPN_RWS,
  RPN_ROW,

  RPN_SET,
  RPN_GET,
  RPN_STO,
  RPN_LOD,

  RPN_TST,
  RPN_NOT,
  RPN_EQU,
  RPN_GRE,
  RPN_LES,

  RPN_END,
  RPN_EIF,
  RPN_ERW,
  RPN_ERI,

  RPN_RET,
  RPN_RIF,
  RPN_RRW,
  RPN_RRI,

  RPN_SUM,
  RPN_AVG,

  RPN_RND,
  RPN_DUP,
  RPN_SWP,
  RPN_ABS,
  RPN_NEG,

  RPN_INC,
  RPN_DEC,

  RPN_ADD,	// Also OR
  RPN_MUL,	// ALSO AND
  RPN_DIV,
  RPN_POW,
  RPN_MOD,
  RPN_MIN,
  RPN_MAX,
  RPN_SIN,
  RPN_COS,
  RPN_TAN,
  RPN_AT2
};

/* RPN OP link-list */
struct tag_rpn_op
{
  int			op;
  GLfloat		value;
  struct tag_rpn_op *	next;
};
typedef struct tag_rpn_op rpn_op;

/* RPN OP stack for a given column */
struct tag_rpn_stack
{
  int		count;
  GLfloat *	data;
  rpn_op *	ops;
};
typedef struct tag_rpn_stack rpn_stack;

/* RPN Object */
struct tag_rpn_context
{
  int		rows;
  int		cols;
  int		oga_count;
  oga_struct **	oga_list;
  GLfloat *	store;
  rpn_stack **	stacks;
};
typedef struct tag_rpn_context rpn_context;

/* RPN Parser */
rpn_stack * rpn_parse(int size,char * string)
{
  rpn_stack *	stack = malloc(sizeof(rpn_stack));
  rpn_op *	op = NULL;
  rpn_op *	last = NULL;
  char *	data = NULL;

  /* Will destroy string, so make a copy */
  memset(stack,0,sizeof(rpn_stack));
  if (string && *string)
  {
    /* Assumes ASCII */
    data = malloc(strlen(string)+1);
    strcpy(data,string);
    string = data;
  }

  /* OPs are comma-separated */
  while (string && *string)
  {
    rpn_op *	cur = NULL;
    char *	pos = string;
    char *	end = strchr(pos,',');
    int		len;

    /* Grab op */
    if (end)
    {
      *end = 0;
      string = end+1;
      len = end - pos;
    }
    else
    {
      len = strlen(string);
      string += len;
    }

    /* Empty op is a NOP */
    if (!len) continue;

    /* Update linklist */
    cur = malloc(sizeof(rpn_op));
    memset(cur,0,sizeof(rpn_op));
    if (last)
    {
      last->next = cur;
    }
    else
    {
      op = cur;
    }
    last = cur;

    /* Check for primitive OPs */
    if (len == 1)
    {
      switch (*pos)
      {
        case '!':
        {
          cur->op = RPN_NOT;
          continue;
        }
        case '-':
        {
          cur->op = RPN_NEG;
          continue;
        }
        case '+':
        {
          cur->op = RPN_ADD;
          continue;
        }
        case '*':
        {
          cur->op = RPN_MUL;
          continue;
        }
        case '/':
        {
          cur->op = RPN_DIV;
          continue;
        }
        case '%':
        {
          cur->op = RPN_MOD;
          continue;
        }
        case '=':
        {
          cur->op = RPN_EQU;
          continue;
        }
        case '>':
        {
          cur->op = RPN_GRE;
          continue;
        }
        case '<':
        {
          cur->op = RPN_LES;
          continue;
        }
        case '?':
        {
          cur->op = RPN_TST;
          continue;
        }
      }
    }

    /* Check for textual OPs */
    if (!strcmp(pos,"pop"))
    {
      cur->op = RPN_POP;
    }
    else if (!strcmp(pos,"rand"))
    {
      cur->op = RPN_RND;
      size++;
    }
    else if (!strcmp(pos,"dup"))
    {
      cur->op = RPN_DUP;
      size++;
    }
    else if (!strcmp(pos,"swap"))
    {
      cur->op = RPN_SWP;
    }
    else if (!strcmp(pos,"set"))
    {
      cur->op = RPN_SET;
    }
    else if (!strcmp(pos,"get"))
    {
      cur->op = RPN_GET;
      size++;
    }
    else if (!strcmp(pos,"store"))
    {
      cur->op = RPN_STO;
    }
    else if (!strcmp(pos,"load"))
    {
      cur->op = RPN_LOD;
    }
    else if (!strcmp(pos,"end"))
    {
      cur->op = RPN_END;
    }
    else if (!strcmp(pos,"endif"))
    {
      cur->op = RPN_EIF;
    }
    else if (!strcmp(pos,"endrow"))
    {
      cur->op = RPN_ERW;
    }
    else if (!strcmp(pos,"endrowif"))
    {
      cur->op = RPN_ERI;
    }
    else if (!strcmp(pos,"return"))
    {
      cur->op = RPN_RET;
    }
    else if (!strcmp(pos,"returnif"))
    {
      cur->op = RPN_RIF;
    }
    else if (!strcmp(pos,"returnrow"))
    {
      cur->op = RPN_RRW;
    }
    else if (!strcmp(pos,"returnrowif"))
    {
      cur->op = RPN_RRI;
    }
    else if (!strcmp(pos,"if"))
    {
      cur->op = RPN_TST;
    }
    else if (!strcmp(pos,"or"))
    {
      cur->op = RPN_ADD;
    }
    else if (!strcmp(pos,"and"))
    {
      cur->op = RPN_MUL;
    }
    else if (!strcmp(pos,"inc"))
    {
      cur->op = RPN_INC;
    }
    else if (!strcmp(pos,"dec"))
    {
      cur->op = RPN_DEC;
    }
    else if (!strcmp(pos,"sum"))
    {
      cur->op = RPN_SUM;
    }
    else if (!strcmp(pos,"avg"))
    {
      cur->op = RPN_AVG;
    }
    else if (!strcmp(pos,"abs"))
    {
      cur->op = RPN_ABS;
    }
    else if (!strcmp(pos,"power"))
    {
      cur->op = RPN_POW;
    }
    else if (!strcmp(pos,"min"))
    {
      cur->op = RPN_MIN;
    }
    else if (!strcmp(pos,"max"))
    {
      cur->op = RPN_MAX;
    }
    else if (!strcmp(pos,"sin"))
    {
      cur->op = RPN_SIN;
    }
    else if (!strcmp(pos,"cos"))
    {
      cur->op = RPN_COS;
    }
    else if (!strcmp(pos,"tan"))
    {
      cur->op = RPN_TAN;
    }
    else if (!strcmp(pos,"atan2"))
    {
      cur->op = RPN_AT2;
    }
    else if (!strcmp(pos,"count"))
    {
      cur->op = RPN_CNT;
      size++;
    }
    else if (!strcmp(pos,"index"))
    {
      cur->op = RPN_IDX;
      size++;
    }
    else if (!strcmp(pos,"columns"))
    {
      cur->op = RPN_CLS;
      size++;
    }
    else if (!strcmp(pos,"column"))
    {
      cur->op = RPN_COL;
      size++;
    }
    else if (!strcmp(pos,"rows"))
    {
      cur->op = RPN_RWS;
      size++;
    }
    else if (!strcmp(pos,"row"))
    {
      cur->op = RPN_ROW;
      size++;
    }
    else if (!strcmp(pos,"pi"))
    {
      cur->op = RPN_PSH;
      cur->value = (float)M_PI;
      size++;
    }
    /* Default to a numeric push */
    else
    {
      cur->op = RPN_PSH;
      cur->value = (float)atof(pos);
      size++;
    }
  }

  /* release string copy */
  if (data) free(data);
  stack->data = malloc(sizeof(GLfloat)*size);
  stack->ops = op;
  return(stack);
}

/* Instantiate an RPN Object */
rpn_context * rpn_init(int oga_count,oga_struct ** oga_list,int col_count,char ** col_ops)
{
  rpn_context * ctx = NULL;
  int elements = 0;
  int i,j;

  if (!oga_count) croak("Missing OGA count");
  if (!oga_list) croak("Missing OGA list");
  if (!col_count) croak("Missing column count");

  /* Validate OGAs */
  for (i=0; i<oga_count; i++)
  {
    if (!oga_list[i]) croak("Missing OGA %d",i);
    if (!oga_list[i]->item_count) croak("Empty OGA %d",i);

    /* Check that all OGAs have the same dimension */
    if (!i)
    {
      elements = oga_list[i]->item_count;
      if (elements % col_count) croak("Invalid OGA size for %d columns",col_count);
    }
    else if (elements != oga_list[i]->item_count)
    {
      croak("Invalid length in OGA %d",i);
    }

    /* Only supporting GLfloat for now */
    for (j=0; j<oga_list[i]->type_count; j++)
    {
      if (oga_list[i]->types[j] != GL_FLOAT)
        croak("Unsupported type in OGA %d",i);
    }
  }

  /* Alloc Object data */
  ctx = malloc(sizeof(rpn_context));
  if (!ctx) croak("Unable to alloc rpn context");

  /* Alloc current row store */
  ctx->store = malloc(sizeof(GLfloat) * col_count);
  if (!ctx->store) croak("Unable to alloc rpn store");

  /* Alloc column stack array */
  ctx->stacks = malloc(sizeof(rpn_stack *) * col_count);
  if (!ctx->stacks) croak("Unable to alloc rpn stacks");

  ctx->cols =col_count;
  ctx->rows = elements / col_count;
  ctx->oga_count = oga_count;
  ctx->oga_list = oga_list;

  /* Parse and populate column stacks */
  for (i=0; i<col_count; i++)
    ctx->stacks[i] = rpn_parse(oga_count,col_ops[i]);

  return(ctx);
}

/* Release OP link-list */
void rpn_delete_ops(rpn_op * ops)
{
  if (!ops) return;
  rpn_delete_ops(ops->next);
  free(ops);
}

/* Release OPS stack */
void rpn_delete_stack(rpn_stack * stack)
{
  if (!stack) return;
  rpn_delete_ops(stack->ops);
  free(stack->data);
  free(stack);
}

/* Release RPN Object */
void rpn_term(rpn_context * ctx)
{
  if (ctx)
  {
    int i;
    for (i=0; i<ctx->cols; i++)
      rpn_delete_stack(ctx->stacks[i]);

    free(ctx->stacks);
    free(ctx->store);
    free(ctx);
  }
}

/* Push an RPN value on the stack */
void rpn_push(rpn_stack * stack, GLfloat value)
{
  if (stack) stack->data[stack->count++] = value;
}

/* Pop an RPN value from the stack */
GLfloat rpn_pop(rpn_stack * stack)
{
  GLfloat value = 0.0;

  if (stack && stack->count)
  {
    value = stack->data[--stack->count];
    if (!stack->count) rpn_push(stack,0.0);
  }

  return(value);
}

/* Execute RPN OPs stack */
void rpn_exec(rpn_context * ctx)
{
  int		elements = ctx->rows * ctx->cols;
  int		i,j,k,r = 0;
  GLfloat	v1,v2;

  for (i=0;i<ctx->rows;i++)
  {
    for (j=0;j<ctx->cols;j++)
    {
      rpn_stack *	stack = ctx->stacks[j];
      int		end = 0;
      rpn_op *		ops;

      /* Skip for NOP columns */
      if (!stack || !stack->ops) continue;
      stack->count = 0;

      /* Push oga data on stack - reverse order */
      for (k=ctx->oga_count-1;k>=0;k--)
        rpn_push(stack,((GLfloat *)ctx->oga_list[k]->data)[r+j]);

      /* Process RPN ops */
      ops = stack->ops;
      while (ops)
      {
        int pos = stack->count - 1;

        switch(ops->op)
        {
          case RPN_PSH:
          {
            //printf("RPN_PSH: %f\n",ops->value);
            rpn_push(stack,ops->value);
            break;
          }
          case RPN_POP:
          {
            //printf("RPN_POP\n");
            rpn_pop(stack);
            break;
          }
          case RPN_CNT:
          {
            //printf("RPN_CNT: %f\n",elements);
            rpn_push(stack,(float)elements);
            break;
          }
          case RPN_IDX:
          {
            //printf("RPN_IDX: %f\n",r+j);
            rpn_push(stack,(float)r+j);
            break;
          }
          case RPN_CLS:
          {
            //printf("RPN_CLS: %f\n",ctx->cols);
            rpn_push(stack,(float)ctx->cols);
            break;
          }
          case RPN_COL:
          {
            //printf("RPN_COL: %f\n",j);
            rpn_push(stack,(float)j);
            break;
          }
          case RPN_RWS:
          {
            //printf("RPN_RWS: %f\n",ctx->rows);
            rpn_push(stack,(float)ctx->rows);
            break;
          }
          case RPN_ROW:
          {
            //printf("RPN_ROW: %f\n",i);
            rpn_push(stack,(float)i);
            break;
          }
          case RPN_SET:
          {
            //printf("RPN_SET %d: %f\n",j,stack->data[pos]);
            ctx->store[j] = stack->data[pos];
            break;
          }
          case RPN_GET:
          {
            //printf("RPN_Get %d: %f\n",j,ctx->store[j]);
            rpn_push(stack,ctx->store[j]);
            break;
          }
          case RPN_STO:
          {
            //printf("RPN_STO row %d\n",r);
            v1 = rpn_pop(stack);
            k = ((int)v1) % ctx->oga_count;
            if (k < 0) k += ctx->oga_count;
            memcpy(ctx->store,&((GLfloat *)ctx->oga_list[k]->data)[r],
              ctx->cols*sizeof(GLfloat));
            break;
          }
          case RPN_LOD:
          {
            //printf("RPN_LOD rwo %d\n",r);
            v1 = rpn_pop(stack);
            k = ((int)v1) % ctx->oga_count;
            if (k < 0) k += ctx->oga_count;
            memcpy(&((GLfloat *)ctx->oga_list[k]->data)[r],ctx->store,
              ctx->cols*sizeof(GLfloat));
            break;
          }
          case RPN_TST:
          {
            //printf("RPN_TST\n");
            v1 = rpn_pop(stack);
            if (v1 != 0.0)
            {
              rpn_pop(stack);
            }
            else
            {
              v1 = rpn_pop(stack);
              rpn_pop(stack);
              rpn_push(stack,v1);
            }
            break;
          }
          case RPN_NOT:
          {
            //printf("RPN_NOT\n");
            if (!stack->count)
            {
              rpn_push(stack,1.0);
            }
            else if (stack->data[pos] == 0.0)
            {
              stack->data[pos] = 1.0;
            }
            else
            {
              stack->data[pos] = 0.0;
            }
            break;
          }
          case RPN_EQU:
          {
            //printf("RPN_EQU\n");
            v1 = (stack->count) ? rpn_pop(stack) : (float)0.0;
            v2 = (stack->count) ? rpn_pop(stack) : (float)0.0;
            rpn_push(stack,(float)((v1 == v2) ? 1.0 : 0.0));
            break;
          }
          case RPN_GRE:
          {
            //printf("RPN_GRE\n");
            v1 = (stack->count) ? rpn_pop(stack) : (float)0.0;
            v2 = (stack->count) ? rpn_pop(stack) : (float)0.0;
            rpn_push(stack,(float)((v1 > v2) ? 1.0 : 0.0));
            break;
          }
          case RPN_LES:
          {
            //printf("RPN_LES\n");
            v1 = (stack->count) ? rpn_pop(stack) : (float)0.0;
            v2 = (stack->count) ? rpn_pop(stack) : (float)0.0;
            rpn_push(stack,(float)((v1 < v2) ? 1.0 : 0.0));
            break;
          }
          case RPN_END:
          {
            //printf("RPN_END\n");
            end = 1;
            ops = 0;
            continue;
          }
          case RPN_EIF:
          {
            //printf("RPN_EIF\n");
            v1 = rpn_pop(stack);
            if (v1 != 0.0)
            {
              end = 1;
              ops = 0;
              continue;
            }
            break;
          }
          case RPN_ERW:
          {
            //printf("RPN_ERW\n");
            j = ctx->rows;
            end = 1;
            ops = 0;
            continue;
          }
          case RPN_ERI:
          {
            //printf("RPN_ERI\n");
            v1 = rpn_pop(stack);
            if (v1 != 0.0)
            {
              j = ctx->rows;
              end = 1;
              ops = 0;
              continue;
            }
            break;
          }
          case RPN_RET:
          {
            //printf("RPN_RET\n");
            ops = 0;
            continue;
          }
          case RPN_RIF:
          {
            //printf("RPN_RIF\n");
            v1 = rpn_pop(stack);
            if (v1 != 0.0)
            {
              ops = 0;
              continue;
            }
            break;
          }
          case RPN_RRW:
          {
            //printf("RPN_RRW\n");
            j = ctx->rows;
            ops = 0;
            continue;
          }
          case RPN_RRI:
          {
            //printf("RPN_RRI\n");
            v1 = rpn_pop(stack);
            if (v1 != 0.0)
            {
              j = ctx->rows;
              ops = 0;
              continue;
            }
            break;
          }
          case RPN_RND:
          {
            //printf("RPN_RND\n");
            rpn_push(stack,(float)(1.0*rand()/RAND_MAX));
            break;
          }
          case RPN_DUP:
          {
            //printf("RPN_DUP\n");
            rpn_push(stack,stack->data[pos]);
            break;
          }
          case RPN_SWP:
          {
            //printf("RPN_SWP\n");
            if (stack->count > 1)
            {
              v1 = stack->data[pos];
              stack->data[pos] = stack->data[--pos];
              stack->data[pos] = v1;
            }
            break;
          }
          case RPN_ABS:
          {
            //printf("RPN_ABS\n");
            stack->data[pos] = (float)fabs(stack->data[pos]);
            break;
          }
          case RPN_NEG:
          {
            //printf("RPN_NEG\n");
            stack->data[pos] *= (float)-1.0;
            break;
          }
          case RPN_INC:
          {
            //printf("RPN_INC\n");
            stack->data[pos] += (float)1.0;
            break;
          }
          case RPN_DEC:
          {
            //printf("RPN_DEC\n");
            stack->data[pos] -= (float)1.0;
            break;
          }
          case RPN_AVG:
          case RPN_SUM:
          {
            //printf("RPN_SUM/AVG\n");
            v1 = 0;

            for(pos=0; pos<stack->count; pos++)
              v1 += stack->data[pos];

            if (ops->op == RPN_AVG) v1 /= stack->count;

            stack->data[0] = v1;
            stack->count = 1;
            break;
          }
          case RPN_ADD:
          {
            //printf("RPN_ADD\n");
            if (stack->count > 1)
            {
              v1 = rpn_pop(stack);
              stack->data[--pos] += v1;
            }
            break;
          }
          case RPN_MUL:
          {
            //printf("RPN_MUL\n");
            if (stack->count > 1)
            {
              v1 = rpn_pop(stack);
              stack->data[--pos] *= v1;
            }
            break;
          }
          case RPN_DIV:
          {
            //printf("RPN_DIV\n");
            if (stack->count > 1)
            {
              v1 = rpn_pop(stack);
              if (v1 != 0.0) stack->data[--pos] /= v1;
            }
            break;
          }
          case RPN_POW:
          {
            //printf("RPN_POW\n");
            if (stack->count > 1)
            {
              v1 = rpn_pop(stack);
              stack->data[--pos] = (float)pow(stack->data[pos],v1);
            }
            break;
          }
          case RPN_MOD:
          {
            //printf("RPN_MOD\n");
            if (stack->count > 1)
            {
              v1 = rpn_pop(stack);
              stack->data[--pos] = (float)fmod(stack->data[pos],v1);
            }
            break;
          }
          case RPN_MIN:
          {
            //printf("RPN_MIN\n");
            if (stack->count > 1)
            {
              v1 = rpn_pop(stack);
              if (stack->data[--pos] > v1)
                stack->data[pos] = v1;
            }
            break;
          }
          case RPN_MAX:
          {
            //printf("RPN_MAX\n");
            if (stack->count > 1)
            {
              v1 = rpn_pop(stack);
              if (stack->data[--pos] < v1)
                stack->data[pos] = v1;
            }
            break;
          }
          case RPN_SIN:
          {
            //printf("RPN_SIN\n");
            stack->data[pos] = (float)sin(stack->data[pos]);
            break;
          }
          case RPN_COS:
          {
            //printf("RPN_COS\n");
            stack->data[pos] = (float)cos(stack->data[pos]);
            break;
          }
          case RPN_TAN:
          {
            //printf("RPN_TAN\n");
            stack->data[pos] = (float)tan(stack->data[pos]);
            break;
          }
          case RPN_AT2:
          {
            //printf("RPN_AT2\n");
            v2 = rpn_pop(stack);
            v1 = rpn_pop(stack);
            if (v1 != 0.0 || v2 != 0.0)
              rpn_push(stack,(float)atan2(v1,v2));
            break;
          }
          case RPN_NOP:
          {
            //printf("RPN_NOP\n");
            break;
          }
          default:
          {
            croak("Unknown RPN op: %d\n",ops->op);
          }
        }

        ops = ops->next;
      }
      if (!end) ((GLfloat *)ctx->oga_list[0]->data)[r+j] = rpn_pop(stack);
    }
    r += ctx->cols;
  }
}

#endif /* End IN_POGL_RPN_XS */


#ifdef IN_POGL_GL_XS

/********************/
/* GPGPU Utils      */
/********************/

/* Get max GPGPU data size */
int gpgpu_size(void)
{
#if defined(GL_ARB_texture_rectangle) && defined(GL_ARB_texture_float) && \
  defined(GL_ARB_fragment_program) && defined(GL_EXT_framebuffer_object)
  if (FBO_MAX == -1)
  {
    if (testProc(glProgramStringARB,"glProgramStringARB") &&
      testProc(glGenProgramsARB,"glGenProgramsARB") &&
      testProc(glBindProgramARB,"glBindProgramARB") &&
      testProc(glIsProgramARB,"glIsProgramARB") &&
      testProc(glProgramLocalParameter4fvARB,"glProgramLocalParameter4fvARB") &&
      testProc(glDeleteProgramsARB,"glDeleteProgramsARB") &&
      testProc(glGenFramebuffersEXT,"glGenFramebuffersEXT") &&
      testProc(glGenRenderbuffersEXT,"glGenRenderbuffersEXT") &&
      testProc(glBindFramebufferEXT,"glBindFramebufferEXT") &&
      testProc(glFramebufferTexture2DEXT,"glFramebufferTexture2DEXT") &&
      testProc(glBindRenderbufferEXT,"glBindRenderbufferEXT") &&
      testProc(glRenderbufferStorageEXT,"glRenderbufferStorageEXT") &&
      testProc(glFramebufferRenderbufferEXT,"glFramebufferRenderbufferEXT") &&
      testProc(glCheckFramebufferStatusEXT,"glCheckFramebufferStatusEXT") &&
      testProc(glDeleteRenderbuffersEXT,"glDeleteRenderbuffersEXT") &&
      testProc(glDeleteFramebuffersEXT,"glDeleteFramebuffersEXT"))
    {
      glGetIntegerv(GL_MAX_RENDERBUFFER_SIZE_EXT,&FBO_MAX);
    }
    else
    {
      FBO_MAX = 0;
    }
  }
  return(FBO_MAX);
#else
  return(0);
#endif
}

/* Get max square array width for a given GPGPU data size */
int gpgpu_width(int len)
{
  int max = gpgpu_size();
  if (max && len && !(len%3))
  {
    int count = len / 3;
    int w = (int)sqrt(count);

    while ((w <= count) && (w <= max))
    {
      if (!(count%w)) return(w);
      w++;
    }
  }
  return(0);
}

#ifdef GL_ARB_fragment_program
static char affine_prog[] =
  "!!ARBfp1.0\n"
  "PARAM affine[4] = {program.local[0..3]};\n"
  "TEMP decal;\n"
  "TEX decal, fragment.texcoord[0], texture[0], RECT;\n"
  "MOV decal.w, 1.0;\n"
  "DP4 result.color.x, decal, affine[0];\n"
  "DP4 result.color.y, decal, affine[1];\n"
  "DP4 result.color.z, decal, affine[2];\n"
  "END\n";

/* Enable affine shader program */
void enable_affine(oga_struct * oga)
{
  if (!oga) return;
  if (!oga->affine_handle)
  {
    /* Load shader program */
    glGenProgramsARB(1,&oga->affine_handle);
    glBindProgramARB(GL_FRAGMENT_PROGRAM_ARB,oga->affine_handle);
    glProgramStringARB(GL_FRAGMENT_PROGRAM_ARB,
      GL_PROGRAM_FORMAT_ASCII_ARB, strlen(affine_prog),affine_prog);

    /* Validate shader program */
    if (!glIsProgramARB(oga->affine_handle))
    {
      GLint errorPos;
      glGetIntegerv(GL_PROGRAM_ERROR_POSITION_ARB,&errorPos);
      if (errorPos < 0) errorPos = strlen(affine_prog);
      croak("Affine fragment program error\n%s",&affine_prog[errorPos]);
    }
  }
  glEnable(GL_FRAGMENT_PROGRAM_ARB);
}

/* Disable affine shader program */
void disable_affine(oga_struct * oga)
{
  if (!oga) return;
  if (oga->affine_handle) glDisable(GL_FRAGMENT_PROGRAM_ARB);
}
#endif

#ifdef GL_EXT_framebuffer_object
/* Unbind an FBO to an OGA */
void release_fbo(oga_struct * oga)
{
  if (oga->fbo_handle)
  {
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    glDeleteFramebuffersEXT(1,&oga->fbo_handle);
  }

  if (oga->tex_handle)
  {
    glBindTexture(oga->target,0);	
    if (oga->tex_handle[0]) glDeleteTextures(1,&oga->tex_handle[0]);
    if (oga->tex_handle[1]) glDeleteTextures(1,&oga->tex_handle[1]);
  }
}

/* Enable an FBO bound to an OGA */
void enable_fbo(oga_struct * oga, int w, int h, GLuint target,
  GLuint pixel_type, GLuint pixel_format, GLuint element_size)
{
  if (!oga) return;

  if ((oga->fbo_w != w) || (oga->fbo_h != h) ||
    (oga->target != target) ||
    (oga->pixel_type != pixel_type) ||
    (oga->pixel_format != pixel_format) ||
    (oga->element_size != element_size)) release_fbo(oga);

  if (!oga->fbo_handle)
  {
    GLenum status;

    /* Save params */
    oga->fbo_w = w;
    oga->fbo_h = h;
    oga->target = target;
    oga->pixel_type = pixel_type;
    oga->pixel_format = pixel_format;
    oga->element_size = element_size;

    /* Set up FBO */
    glGenTextures(2,oga->tex_handle);
    glGenFramebuffersEXT(1,&oga->fbo_handle);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,oga->fbo_handle);

    glViewport(0,0,w,h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0,w,0,h);
    glMatrixMode(GL_MODELVIEW); 
    glLoadIdentity();

    glBindTexture(target,oga->tex_handle[1]);
    glTexParameteri(target,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
    glTexParameteri(target,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
    glTexParameteri(target,GL_TEXTURE_WRAP_S,GL_CLAMP);
    glTexParameteri(target,GL_TEXTURE_WRAP_T,GL_CLAMP);

    glTexImage2D(target,0,pixel_type,w,h,0,
      pixel_format,element_size,0);

    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,
      GL_COLOR_ATTACHMENT0_EXT,target,oga->tex_handle[1],0);

    status = glCheckFramebufferStatusEXT(GL_RENDERBUFFER_EXT);
    if (status) croak("enable_fbo status: %04X\n",status);
  }
  else
  {
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,oga->fbo_handle);
  }

  /* Load data */
  glBindTexture(target,oga->tex_handle[0]);
  glTexImage2D(target,0,pixel_type,w,h,0,
    pixel_format,element_size,oga->data);

  glEnable(target);
  //glDrawBuffer(GL_COLOR_ATTACHMENT0_EXT);
  glBindTexture(target,oga->tex_handle[0]);
  glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_DECAL);
}

/* Disable an FBO bound to an OGA */
void disable_fbo(oga_struct * oga)
{
  if (!oga) return;
  if (oga->fbo_handle)
  {
    glDisable(oga->target);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);
  }
}
#endif

#endif /* End IN_POGL_GL_XS */




MODULE = PDL::Graphics::OpenGL::Perl::OpenGL		PACKAGE = PDL::Graphics::OpenGL::Perl::OpenGL::Array

#ifdef IN_POGL_ARRAY_XS

#//# $oga = OpenGL::Array->new($count, @types);
#//- Contructor for multi-type OGA - unpopulated
PDL::Graphics::OpenGL::Perl::OpenGL::Array
new(Class, count, type, ...)
	GLsizei	count
	GLenum	type
	CODE:
	{
		int oga_len = sizeof(oga_struct);
		oga_struct * oga = malloc(oga_len);
		int i,j;

		memset(oga,0,oga_len);
		
		oga->type_count = items - 2;
		oga->item_count = count;
		
		oga->types = malloc(sizeof(GLenum) * oga->type_count);
		oga->type_offset = malloc(sizeof(GLint) * oga->type_count);
		for(i=0,j=0;i<oga->type_count;i++) {
			oga->types[i] = SvIV(ST(i+2));
			oga->type_offset[i] = j;
			j += gl_type_size(oga->types[i]);
		}
		oga->total_types_width = j;
		
		oga->data_length = oga->total_types_width *
			// ((count + oga->type_count-1) / oga->type_count); # vas is das?
			count;
		
		oga->data = malloc(oga->data_length);
		memset(oga->data,0,oga->data_length);

		oga->free_data = 1;
		
		RETVAL = oga;
	}
	OUTPUT:
		RETVAL



#//# $oga = OpenGL::Array->new_list($type, @data);
#//- Contructor for mono-type OGA - populated
PDL::Graphics::OpenGL::Perl::OpenGL::Array
new_list(Class, type, ...)
	GLenum	type
	CODE:
	{
		int oga_len = sizeof(oga_struct);
		oga_struct * oga = malloc(oga_len);

		memset(oga,0,oga_len);

		oga->type_count = 1;
		oga->item_count = items - 2;
		oga->total_types_width = gl_type_size(type);
		oga->data_length = oga->total_types_width * oga->item_count;
		
		oga->types = malloc(sizeof(GLenum) * oga->type_count);
		oga->type_offset = malloc(sizeof(GLint) * oga->type_count);
		oga->data = malloc(oga->data_length);
		oga->free_data = 1;

		oga->type_offset[0] = 0;
		oga->types[0] = type;

		SvItems(type,2,(GLuint)oga->item_count,oga->data);
		
		RETVAL = oga;
	}
	OUTPUT:
		RETVAL

#//# $oga = OpenGL::Array->new_scalar($type, (PACKED)data, $length);
#//- Contructor for mono-type OGA - populated by string
PDL::Graphics::OpenGL::Perl::OpenGL::Array
new_scalar(Class, type, data, length)
	GLenum	type
	SV *	data
        GLsizei	length
	CODE:
	{
		int width = gl_type_size(type);
		void * data_s = EL(data, width*length);
		int oga_len = sizeof(oga_struct);
		oga_struct * oga = malloc(oga_len);

		memset(oga,0,oga_len);

		oga->type_count = 1;
		oga->item_count = length / width;
		oga->total_types_width = width;
		oga->data_length = length;
		
		oga->types = malloc(sizeof(GLenum) * oga->type_count);
		oga->type_offset = malloc(sizeof(GLint) * oga->type_count);
		oga->data = malloc(oga->data_length);
		oga->free_data = 1;

		oga->type_offset[0] = 0;
		oga->types[0] = type;

		memcpy(oga->data,data_s,oga->data_length);
		
		RETVAL = oga;
	}
	OUTPUT:
		RETVAL

#//# $oga = OpenGL::Array->new_pointer($type, (CPTR)ptr, $elements);
#//- Contructor for mono-type OGA wrapper over a C pointer
PDL::Graphics::OpenGL::Perl::OpenGL::Array
new_pointer(Class, type, ptr, elements)
	GLenum	type
	void *	ptr
	GLsizei	elements
	CODE:
	{
		int width = gl_type_size(type);
		int oga_len = sizeof(oga_struct);
		oga_struct * oga = malloc(sizeof(oga_struct));

		memset(oga,0,oga_len);
		
		oga->type_count = 1;
		oga->item_count = elements;
		
		oga->types = malloc(sizeof(GLenum) * oga->type_count);
		oga->type_offset = malloc(sizeof(GLint) * oga->type_count);
		oga->types[0] = type;
		oga->type_offset[0] = 0;
		oga->total_types_width = 1;
		
		oga->data_length = elements * width;
		
		oga->data = ptr;
		oga->free_data = 0;
		
		RETVAL = oga;
	}
	OUTPUT:
		RETVAL

#//# $oga = OpenGL::Array->new_from_pointer((CPTR)ptr, $length);
#//- Contructor for GLubyte OGA wrapper over a C pointer
PDL::Graphics::OpenGL::Perl::OpenGL::Array
new_from_pointer(Class, ptr, length)
	void *	ptr
	GLsizei	length
	CODE:
	{
		int oga_len = sizeof(oga_struct);
		oga_struct * oga = malloc(sizeof(oga_struct));

		memset(oga,0,oga_len);
		
		oga->type_count = 1;
		oga->item_count = length;
		
		oga->types = malloc(sizeof(GLenum) * oga->type_count);
		oga->type_offset = malloc(sizeof(GLint) * oga->type_count);
		oga->types[0] = GL_UNSIGNED_BYTE;
		oga->type_offset[0] = 0;
		oga->total_types_width = 1;
		
		oga->data_length = oga->item_count;
		
		oga->data = ptr;
		oga->free_data = 0;
		
		RETVAL = oga;
	}
	OUTPUT:
		RETVAL

#//# $oga->update_pointer((CPTR)ptr);
#//- Replace OGA's C pointer - old one is not released
GLboolean
update_pointer(oga, ptr)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	void *	ptr
	CODE:
	{
                RETVAL = (oga->data != ptr);
		oga->data = ptr;
	}
	OUTPUT:
		RETVAL

#//# $oga->bind($vboID);
#//- Bind a VBO to an OGA
void
bind(oga, bind)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	GLint	bind
	INIT:
#ifdef GL_ARB_vertex_buffer_object
		loadProc(glBindBufferARB,"glBindBufferARB");
#endif
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		oga->bind = bind;
		glBindBufferARB(GL_ARRAY_BUFFER_ARB,bind);
#else
		croak("PDL::Graphics::OpenGL::Perl::OpenGL::Array::bind requires GL_ARB_vertex_buffer_object");
#endif
	}

#//# $vboID = $oga->bound();
#//- Return OGA's bound VBO ID
GLint
bound(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
		RETVAL = oga->bind;
	OUTPUT:
		RETVAL

#//# $oga->calc([@(OGA)moreOGAs,]@rpnOPs);
#//- Execute RPN instructions on one or more OGAs
void
calc(...)
	CODE:
	{
		rpn_context *	ctx;
		oga_struct **	oga_list;
		int		oga_count = 0;
		int		ops_count,i;
		char **		ops;

		/* Determine number of OGAs passed in */
		for (i=0; i<items; i++)
		{
			SV *	sv = ST(i);
			if (sv == &PL_sv_undef ||
				!sv_derived_from(sv,"PDL::Graphics::OpenGL::Perl::OpenGL::Array")) break;
			oga_count++;
		}

		/* Grab OGA data buffers */
		if (!oga_count) croak("Missing OGA parameters");
		ops_count = items - oga_count;

		oga_list = malloc(sizeof(oga_struct *) * oga_count);
		if (!oga_list) croak("Unable to alloc oga_list");

		for (i=0; i<oga_count; i++)
		{
			IV ref = SvIV((SV*)SvRV(ST(i)));
			oga_list[i] = INT2PTR(PDL__Graphics__OpenGL__Perl__OpenGL__Array,ref);
		}

		ops = malloc(sizeof(char *) * ops_count);
		if (!ops) croak("Unable to alloc ops");

		/* Parse parameters */
		for (i=0;i<ops_count;i++)
		{
			SV *	sv = ST(i+oga_count);
			char *	op = (sv != &PL_sv_undef) ?
				(char *)SvPV(sv,PL_na) : "";
			ops[i] = op;
		}

		/* Instantiate RPN context */
		ctx = rpn_init(oga_count,oga_list,ops_count,ops);
		rpn_exec(ctx);
		rpn_term(ctx);

		/* Delete lists */
		free(ops);
		free(oga_list);
	}

#//# $oga->assign($pos,@data);
#//- Set OGA values starting from offset
void
assign(oga, pos, ...)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	GLint	pos
	CODE:
	{
		int i,j;
		int end;
		GLenum t;
		char* offset;
		
		i = pos;
		end = i + items - 2;
		
		if (end > oga->item_count)
			end = oga->item_count;
		/* FIXME: is this char* conversion what is intended? */
		offset = ((char*)oga->data) +
			(pos / oga->type_count * oga->total_types_width) + 
			oga->type_offset[pos % oga->type_count];
		
		j = 2;

		/* Handle multi-type OGAs */		
		for (;i<end;i++,j++) {
			t = oga->types[i % oga->type_count];
			switch (t) {
#ifdef GL_VERSION_1_2
			case GL_UNSIGNED_BYTE_3_3_2:
			case GL_UNSIGNED_BYTE_2_3_3_REV:
				(*(GLubyte*)offset) = (GLubyte)SvIV(ST(j));
				offset += sizeof(GLubyte);
				break;
			case GL_UNSIGNED_SHORT_5_6_5:
			case GL_UNSIGNED_SHORT_5_6_5_REV:
			case GL_UNSIGNED_SHORT_4_4_4_4:
			case GL_UNSIGNED_SHORT_4_4_4_4_REV:
			case GL_UNSIGNED_SHORT_5_5_5_1:
			case GL_UNSIGNED_SHORT_1_5_5_5_REV:
				(*(GLushort*)offset) = (GLushort)SvIV(ST(j));
				offset += sizeof(GLushort);
				break;
			case GL_UNSIGNED_INT_8_8_8_8:
			case GL_UNSIGNED_INT_8_8_8_8_REV:
			case GL_UNSIGNED_INT_10_10_10_2:
			case GL_UNSIGNED_INT_2_10_10_10_REV:
				(*(GLuint*)offset) = (GLuint)SvIV(ST(j));
				offset += sizeof(GLuint);
				break;
#endif
			case GL_UNSIGNED_BYTE:
			case GL_BITMAP:
				(*(GLubyte*)offset) = (GLubyte)SvIV(ST(j));
				offset += sizeof(GLubyte);
				break;
			case GL_BYTE:
				(*(GLbyte*)offset) = (GLbyte)SvIV(ST(j));
				offset += sizeof(GLbyte);
				break;
			case GL_UNSIGNED_SHORT:
				(*(GLushort*)offset) = (GLushort)SvIV(ST(j));
				offset += sizeof(GLushort);
				break;
			case GL_SHORT:
				(*(GLshort*)offset) = (GLshort)SvIV(ST(j));
				offset += sizeof(GLshort);
				break;
			case GL_UNSIGNED_INT:
				(*(GLuint*)offset) = (GLuint)SvIV(ST(j));
				offset += sizeof(GLuint);
				break;
			case GL_INT:
				(*(GLint*)offset) = (GLint)SvIV(ST(j));
				offset += sizeof(GLint);
				break;
			case GL_FLOAT: 
				(*(GLfloat*)offset) = (GLfloat)SvNV(ST(j));
				offset += sizeof(GLfloat);
				break;
			case GL_DOUBLE: 
				(*(GLdouble*)offset) = (GLdouble)SvNV(ST(j));
				offset += sizeof(GLdouble);
				break;
			case GL_2_BYTES:
			{
				unsigned long v = (unsigned long)SvIV(ST(j));
				(*(GLubyte*)offset) = (GLubyte)(v >> 8);
				offset++;
				(*(GLubyte*)offset) = (GLubyte)v & 0xff;
				offset++;
				break;
			}
			case GL_3_BYTES:
			{
				unsigned long v = (unsigned long)SvIV(ST(j));
				(*(GLubyte*)offset) = (GLubyte)(v >> 16)& 0xff;
				offset++;
				(*(GLubyte*)offset) = (GLubyte)(v >> 8) & 0xff;
				offset++;
				(*(GLubyte*)offset) = (GLubyte)(v >> 0) & 0xff;
				offset++;
				break;
			}
			case GL_4_BYTES:
			{
				unsigned long v = (unsigned long)SvIV(ST(j));
				(*(GLubyte*)offset) = (GLubyte)(v >> 24)& 0xff;
				offset++;
				(*(GLubyte*)offset) = (GLubyte)(v >> 16)& 0xff;
				offset++;
				(*(GLubyte*)offset) = (GLubyte)(v >> 8) & 0xff;
				offset++;
				(*(GLubyte*)offset) = (GLubyte)(v >> 0) & 0xff;
				offset++;
				break;
			}
			default:
				croak("unknown type");
			}
		}
	}

#//# $oga->assign_data($pos,(PACKED)data);
#//- Set OGA values by string, starting from offset
void
assign_data(oga, pos, data)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array	oga
	GLint	pos
	SV *	data
	CODE:
	{
		void * offset;
		void * src;
		STRLEN len;
		
		offset = ((char*)oga->data) +
			(pos / oga->type_count * oga->total_types_width) + 
			oga->type_offset[pos % oga->type_count];
		
		src = SvPV(data, len);
		
		memcpy(offset, src, len);
	}

#//# @data = $oga->retrieve($pos,$len);
#//- Get OGA data array, by offset and length
void
retrieve(oga, ...)	
	PDL::Graphics::OpenGL::Perl::OpenGL::Array	oga
	PPCODE:
	{
		GLint	pos = (items > 1) ? SvIV(ST(1)) : 0;
		GLint	len = (items > 2) ? SvIV(ST(2)) : (oga->item_count - pos);
		char * offset;
		int end = pos + len;
		int i;

		offset = ((char*)oga->data) +
			(pos / oga->type_count * oga->total_types_width) + 
			oga->type_offset[pos % oga->type_count];
		
		if (end > oga->item_count)
			end = oga->item_count;
		
		EXTEND(sp, end-pos);
		
		i = pos;
		
		for (;i<end;i++) {
			GLenum t = oga->types[i % oga->type_count];
			switch (t) {
#ifdef GL_VERSION_1_2
			case GL_UNSIGNED_BYTE_3_3_2:
			case GL_UNSIGNED_BYTE_2_3_3_REV:
				PUSHs(sv_2mortal(newSViv( (*(GLubyte*)offset) )));
				offset += sizeof(GLubyte);
				break;
			case GL_UNSIGNED_SHORT_5_6_5:
			case GL_UNSIGNED_SHORT_5_6_5_REV:
			case GL_UNSIGNED_SHORT_4_4_4_4:
			case GL_UNSIGNED_SHORT_4_4_4_4_REV:
			case GL_UNSIGNED_SHORT_5_5_5_1:
			case GL_UNSIGNED_SHORT_1_5_5_5_REV:
				PUSHs(sv_2mortal(newSViv( (*(GLushort*)offset) )));
				offset += sizeof(GLushort);
				break;
			case GL_UNSIGNED_INT_8_8_8_8:
			case GL_UNSIGNED_INT_8_8_8_8_REV:
			case GL_UNSIGNED_INT_10_10_10_2:
			case GL_UNSIGNED_INT_2_10_10_10_REV:
				PUSHs(sv_2mortal(newSViv( (*(GLuint*)offset) )));
				offset += sizeof(GLuint);
				break;
#endif
			case GL_UNSIGNED_BYTE:
			case GL_BITMAP:
				PUSHs(sv_2mortal(newSViv( (*(GLubyte*)offset) )));
				offset += sizeof(GLubyte);
				break;
			case GL_BYTE:
				PUSHs(sv_2mortal(newSViv( (*(GLbyte*)offset) )));
				offset += sizeof(GLbyte);
				break;
			case GL_UNSIGNED_SHORT:
				PUSHs(sv_2mortal(newSViv( (*(GLushort*)offset) )));
				offset += sizeof(GLushort);
				break;
			case GL_SHORT:
				PUSHs(sv_2mortal(newSViv( (*(GLshort*)offset) )));
				offset += sizeof(GLshort);
				break;
			case GL_UNSIGNED_INT:
				PUSHs(sv_2mortal(newSViv( (*(GLuint*)offset) )));
				offset += sizeof(GLuint);
				break;
			case GL_INT:
				PUSHs(sv_2mortal(newSViv( (*(GLint*)offset) )));
				offset += sizeof(GLint);
				break;
			case GL_FLOAT: 
				PUSHs(sv_2mortal(newSVnv( (*(GLfloat*)offset) )));
				offset += sizeof(GLfloat);
				break;
			case GL_DOUBLE: 
				PUSHs(sv_2mortal(newSVnv( (*(GLdouble*)offset) )));
				offset += sizeof(GLdouble);
				break;
			case GL_2_BYTES:
			case GL_3_BYTES:
			case GL_4_BYTES:
			default:
				croak("unknown type");
			}
		}
	}

#//# $data = $oga->retrieve_data($pos,$len);
#//- Get OGA data as packed string, by offset and length
SV *
retrieve_data(oga, ...)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array	oga
	CODE:
	{
		GLint	pos = (items > 1) ? SvIV(ST(1)) : 0;
		GLint	len = (items > 2) ? SvIV(ST(2)) : (oga->item_count - pos);
		void * offset;
		
		offset = ((char*)oga->data) +
			(pos / oga->type_count * oga->total_types_width) + 
			oga->type_offset[pos % oga->type_count];

		RETVAL = newSVpv((char*)offset, len);
	}
	OUTPUT:
	RETVAL

#//# $count = $oga->elements();
#//- Get number of OGA elements
GLsizei
elements(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array	oga
	CODE:
		RETVAL = oga->item_count;
	OUTPUT:
		RETVAL

#//# $len = $oga->length();
#//- Get size of OGA in bytes
GLsizei
length(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array	oga
	CODE:
		RETVAL = oga->data_length;
	OUTPUT:
		RETVAL

#//# (CPTR)ptr = $oga->ptr();
#//- Get C pointer to OGA data
void *
ptr(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array	oga
	CODE:
	RETVAL = oga->data;
	OUTPUT:
	RETVAL

#//# (CPTR)ptr = $oga->offset($pos);
#//- Get C pointer to OGA data, by element offset
void *
offset(oga, pos)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array	oga
	GLint	pos
	CODE:
	RETVAL = ((char*)oga->data) +
		(pos / oga->type_count * oga->total_types_width) + 
		oga->type_offset[pos % oga->type_count];
	OUTPUT:
	RETVAL

#//# $oga->affine((OGA)matrix|@matrix|$scalar);
#//- Perform affine transform on an OGA
void
affine(oga, ...)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
		GLfloat *	data = (GLfloat *)oga->data;
		GLfloat *	mat = NULL;
		int		len = oga->item_count;
		int		fbo_width = 0;
		int		i,j,count,dim,cols;
		SV *		sv = ST(1);
		int		free_mat = 0;

		/* Get transform matrix OGA */
		if (sv != &PL_sv_undef && sv_derived_from(sv,"PDL::Graphics::OpenGL::Perl::OpenGL::Array"))
		{
			IV ref = SvIV((SV*)SvRV(sv));
			oga_struct *oga_mat = INT2PTR(PDL__Graphics__OpenGL__Perl__OpenGL__Array,ref);
			count = oga_mat->item_count;

			for (i=0;i<oga_mat->type_count;i++)
			{
				if (oga_mat->types[i] != GL_FLOAT)
					croak("Unsupported datatype in affine matrix");
			}

			mat = (GLfloat *)oga_mat->data;
		}
		else
		{
			count = items - 1;
			free_mat = 1;
		}
		if (!count) croak("No matrix values");

		/* Currently only support GLfloat */
		for (i=0;i<oga->type_count;i++)
		{
			if (oga->types[i] != GL_FLOAT)
				croak("Unsupported datatype");
		}

		/* Scalar Multiply */
		if (count == 1)
		{
			GLfloat scalar = mat ? mat[0] : (GLfloat)SvNV(ST(1));
			for (i=0;i<len;i++) data[i] *= scalar;
			XSRETURN_EMPTY;
		}

		/* Calc matrix dimension from sqrt of array size */
		dim = (int)sqrt(count);
		if (count != dim*dim) croak("Not a square matrix");

		/* Affine matrix dimension is one element larger than vector data */
		cols = dim - 1;
		if (len % cols)
			croak("Matrix does not match array vector size");

		/* Grab affine matrix */
		if (!mat)
		{
			mat = malloc(sizeof(GLfloat) * count);
			for (i=0; i<count; i++)
				mat[i] = (GLfloat)SvNV(ST(i+1));
		}
#if 0 /* Need to figure out why this is slower than CPU calcs */ 
		/* Use GPU if FBOs and Fragment Programs are supported */
		fbo_width = gpgpu_width(len);
		if (dim == 4 && fbo_width)
		{
			GLuint target = GL_TEXTURE_RECTANGLE_ARB;
			int w = fbo_width;
			int h = len / (w*3);

			/* Setup and enable FBO */
			enable_fbo(oga,w,h,target,GL_RGB32F_ARB,GL_RGB,GL_FLOAT);

			/* Pass affine matrix to shader */
			enable_affine(oga);
			for (i=0;i<4;i++)
			{
				glProgramLocalParameter4fvARB(GL_FRAGMENT_PROGRAM_ARB,
					i,&mat[i<<2]);
			}

			/* Render to FBO via fragment shader */
			glBegin(GL_QUADS);
			{
				glTexCoord2i(0,0); glVertex2i(0,0);
				glTexCoord2i(w,0); glVertex2i(w,0);
				glTexCoord2i(w,h); glVertex2i(w,h);
				glTexCoord2i(0,h); glVertex2i(0,h);
			}
			glEnd();

			/* Done rendering */
			disable_affine(oga);

			/* Save back to OGA */
			//glReadBuffer(GL_COLOR_ATTACHMENT0_EXT);
			glReadPixels(0,0,w,h,GL_RGB,GL_FLOAT,oga->data);

			disable_fbo(oga);
		}
		/* Use CPU to do transform */
		else
#endif
		{
			int s = sizeof(GLfloat) * cols;
			GLfloat *vec = malloc(s);
			int k,r;

			/* Iterate each data row */
			for (i=0; i < len; i+=cols)
			{
				/* Iterate each result column */
				for (j=0,r=0; j<cols; j++,r+=dim)
				{
					vec[j] = 0.0;

					/* Iterate each matrix column */
					for (k=0; k<cols; k++)
					{
						vec[j] += data[i+k] * mat[r+k];
					}
					/* Matrix translate column */
					vec[j] += mat[r+cols];
				}

				memcpy(data+i,vec,s);
			}

			free(vec);
		}

		if (free_mat) free(mat);
	}

#// OGA Destructor
void
DESTROY(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array	oga
	CODE:
	{
#if 0  /* Cleanup for GPU-based affine calcs */
#ifdef GL_ARB_fragment_program
		if (oga->affine_handle)
		{
			glBindProgramARB(GL_FRAGMENT_PROGRAM_ARB, 0);
			glDeleteProgramsARB(1,&oga->affine_handle);
		}
#endif
#ifdef GL_EXT_framebuffer_object
		release_fbo(oga);
#endif
#endif
#if 0
#ifdef GL_ARB_vertex_buffer_object
		if (oga->bind)
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB,0);
			glDeleteBuffersARB(1,&oga->bind);
		}
#endif
#endif
		if (oga->free_data)
		{
			/* To make sure dangling pointers will be obvious */
			memset(oga->data, '\0', oga->data_length);
			free(oga->data);
		}
	
		free(oga->types);
		free(oga->type_offset);
		free(oga);
	}

#endif /* End IN_POGL_ARRAY_XS */


MODULE = PDL::Graphics::OpenGL::Perl::OpenGL		PACKAGE = PDL::Graphics::OpenGL::Perl::OpenGL

#ifdef IN_POGL_CONST_XS

#// Define a POGL Constant
SV *
constant(name,arg)
	char *	name
	int	arg
	CODE:
	{
		RETVAL = neoconstant(name, arg);
		if (!RETVAL)
			RETVAL = newSVsv(&PL_sv_undef);
	}
	OUTPUT:
	RETVAL

#endif /* End IN_POGL_CONST_XS */

#ifdef IN_POGL_GL_XS

#// Test for GL
int
_have_gl()
	CODE:
#ifdef HAVE_GL
	RETVAL = 1;
#else
	RETVAL = 0;
#endif
	OUTPUT:
	RETVAL

#// Test for GLU
int
_have_glu()
	CODE:
#ifdef HAVE_GLU
	RETVAL = 1;
#else
	RETVAL = 0;
#endif
	OUTPUT:
	RETVAL

#// Test for GLUT
int
_have_glut()
	CODE:
#if defined(HAVE_GLUT) || defined(HAVE_FREEGLUT)
	RETVAL = 1;
#else
	RETVAL = 0;
#endif
	OUTPUT:
	RETVAL

#// Test for FreeGLUT
int
_have_freeglut()
	CODE:
#if defined(HAVE_FREEGLUT)
	RETVAL = 1;
#else
	RETVAL = 0;
#endif
	OUTPUT:
	RETVAL

#// Test for GLX
int
_have_glx()
	CODE:
#ifdef HAVE_GLX
	RETVAL = 1;
#else
	RETVAL = 0;
#endif
	OUTPUT:
	RETVAL

#// Test for GLpc
int
_have_glp()
	CODE:
#ifdef HAVE_GLpc
	RETVAL = 1;
#else
	RETVAL = 0;
#endif
	OUTPUT:
	RETVAL

#endif /* End IN_POGL_GL_XS */


#ifdef IN_POGL_GLUT_XS

#// Test for done with glutInit
int
done_glutInit()
	CODE:
	RETVAL = _done_glutInit;
	OUTPUT:
	RETVAL

#endif /* End IN_POGL_GLUT_XS */

#ifdef IN_POGL_GL_XS

#ifdef HAVE_GL

#// 1.0
#//# glAccum($op, $value);
void
glAccum(op, value)
	GLenum	op
	GLfloat	value

#// 1.0
#//# glAlphaFunc($func, $ref);
void
glAlphaFunc(func, ref)
	GLenum	func
	GLclampf	ref

#ifdef GL_VERSION_1_1

#//# glAreTexturesResident_c($n, (CPTR)textures, (CPTR)residences);
void
glAreTexturesResident_c(n, textures, residences)
	GLsizei	n
	void *	textures
	void *	residences
	CODE:
	glAreTexturesResident(n, textures, residences);

#//# glAreTexturesResident_s($n, (PACKED)textures, (PACKED)residences);
void
glAreTexturesResident_s(n, textures, residences)
	GLsizei	n
	SV *	textures
	SV *	residences
	CODE:
	{
	void * textures_s = EL(textures, sizeof(GLuint)*n);
	void * residences_s = EL(residences, sizeof(GLboolean)*n);
	glAreTexturesResident(n, textures_s, residences_s);
	}

#// 1.1
#//# (result,@residences) = glAreTexturesResident_p(@textureIDs);
void
glAreTexturesResident_p(...)
	PPCODE:
	{
		GLsizei n = items;
		GLuint * textures = malloc(sizeof(GLuint) * (n+1));
		GLboolean * residences = malloc(sizeof(GLboolean) * (n+1));
		GLboolean result;
		int i;
		
		for (i=0;i<n;i++)
			textures[i] = SvIV(ST(i));
		
		result = glAreTexturesResident(n, textures, residences);
		
		if ((result == GL_TRUE) || (GIMME != G_ARRAY))
			PUSHs(sv_2mortal(newSViv(result)));
		else {
			EXTEND(sp, n+1);
			PUSHs(sv_2mortal(newSViv(result)));
			for(i=0;i<n;i++)
				PUSHs(sv_2mortal(newSViv(residences[i])));
		}
		
		free(textures);
		free(residences);
	}

#// 1.1
#//# glArrayElement($i);
void
glArrayElement(i)
	GLint	i

#endif

#// 1.0
#//# glBegin($mode);
void
glBegin(mode)
	GLenum	mode

#// 1.0
#//# glEnd()
void
glEnd()

#ifdef GL_VERSION_1_1

#//# glBindTexture($target, $texture);
void
glBindTexture(target, texture)
	GLenum	target
	GLuint	texture

#endif


#// 1.0
#//# glBitmap_c($width, $height, $xorig, $yorig, $xmove, $ymove, (CPTR)bitmap);
void
glBitmap_c(width, height, xorig, yorig, xmove, ymove, bitmap)
	GLsizei	width
	GLsizei	height
	GLfloat	xorig
	GLfloat	yorig
	GLfloat	xmove
	GLfloat	ymove
	void *	bitmap
	CODE:
	glBitmap(width, height, xorig, yorig, xmove, ymove, bitmap);

#//# glBitmap_s($width, $height, $xorig, $yorig, $xmove, $ymove, (PACKED)bitmap);
void
glBitmap_s(width, height, xorig, yorig, xmove, ymove, bitmap)
	GLsizei	width
	GLsizei	height
	GLfloat	xorig
	GLfloat	yorig
	GLfloat	xmove
	GLfloat	ymove
	SV *	bitmap
	CODE:
	{
	GLubyte * bitmap_s = ELI(bitmap, width, height,
		GL_COLOR_INDEX, GL_BITMAP, gl_pixelbuffer_unpack);
	glBitmap(width, height, xorig, yorig, xmove, ymove, bitmap_s);
	}

#//# glBitmap_p($width, $height, $xorig, $yorig, $xmove, $ymove, @bitmap);
void
glBitmap_p(width, height, xorig, yorig, xmove, ymove, ...)
	GLsizei	width
	GLsizei	height
	GLfloat	xorig
	GLfloat	yorig
	GLfloat	xmove
	GLfloat	ymove
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(6)), items-6, width, height,
		1, GL_COLOR_INDEX, GL_BITMAP, 0);
	glBitmap(width, height, xorig, yorig, xmove, ymove, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#// 1.0
#//# glBlendFunc($sfactor, $dfactor);
void
glBlendFunc(sfactor, dfactor)
	GLenum	sfactor
	GLenum	dfactor

#// 1.0
#//# glCallList($list);
void
glCallList(list)
	GLuint	list

#// 1.0
#//# glCallLists_c($n, $type, (CPTR)lists);
void
glCallLists_c(n, type, lists)
	GLsizei	n
	GLenum	type
	void *	lists
	CODE:
	glCallLists(n, type, lists);

#// 1.0
#//# glCallLists_s($n, $type, (PACKED)lists);
void
glCallLists_s(n, type, lists)
	GLsizei	n
	GLenum	type
	SV *	lists
	CODE:
	{
	void * lists_s = EL(lists, gl_type_size(type) * n);
	glCallLists(n, type, lists_s);
	}

#// 1.0
#//# glCallLists_p(@lists);
#//- Assumes GLint type
void
glCallLists_p(...)
	CODE:
	if (items) {
		int * list = malloc(sizeof(int) * items);
		int i;
		for(i=0;i<items;i++)
			list[i] = SvIV(ST(i));
		glCallLists(items, GL_INT, list);
		free(list);
	}

#// 1.0
#//# glClear($mask);
void
glClear(mask)
	GLbitfield	mask

#// 1.0
#//# glClearAccum($red, $green, $blue, $alpha);
void
glClearAccum(red, green, blue, alpha)
	GLfloat	red
	GLfloat	green
	GLfloat	blue
	GLfloat	alpha

#// 1.0
#//# glClearColor($red, $green, $blue, $alpha);
void
glClearColor(red, green, blue, alpha)
	GLclampf	red
	GLclampf	green
	GLclampf	blue
	GLclampf	alpha

#// 1.0
#//# glClearDepth($depth);
void
glClearDepth(depth)
	GLclampd	depth

#// 1.0
#//# glClearIndex($c);
void
glClearIndex(c)
	GLfloat	c

#// 1.0
#//# glClearStencil($s);
void
glClearStencil(s)
	GLint	s

#// 1.0
#//# glClipPlane_c($plane, (CPTR)eqn);
void
glClipPlane_c(plane, eqn)
	GLenum	plane
	void *	eqn
	CODE:
	glClipPlane(plane, eqn);

#// 1.0
#//# glClipPlane_s($plane, (PACKED)eqn);
void
glClipPlane_s(plane, eqn)
	GLenum	plane
	SV *	eqn
	CODE:
	{
		GLdouble * eqn_s = EL(eqn, sizeof(GLdouble) * 4);
		glClipPlane(plane, eqn_s);
	}

#// 1.0
#//# glClipPlane_p($plane, $eqn0, $eqn1, $eqn2, $eqn3);
void
glClipPlane_p(plane, eqn0, eqn1, eqn2, eqn3)
	GLenum	plane
	double	eqn0
	double	eqn1
	double	eqn2
	double	eqn3
	CODE:
	{
		double eqn[4];
		eqn[0] = eqn0;
		eqn[1] = eqn1;
		eqn[2] = eqn2;
		eqn[3] = eqn3;
		glClipPlane(plane, &eqn[0]);
	}

#// 1.0
#//# glColorMask($red, $green, $blue, $alpha);
void
glColorMask(red, green, blue, alpha)
	GLboolean	red
	GLboolean	green
	GLboolean	blue
	GLboolean	alpha

#// 1.0
#//# glColorMaterial($face, $mode);
void
glColorMaterial(face, mode)
	GLenum	face
	GLenum	mode

#ifdef GL_VERSION_1_1

#// 1.1
#//# glColorPointer_c($size, $type, $stride, (CPTR)pointer);
void
glColorPointer_c(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	void *	pointer
	CODE:
	glColorPointer(size, type, stride, pointer);


#//# glColorPointer_s($size, $type, $stride, (PACKED)pointer);
void
glColorPointer_s(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*size);
		void * pointer_s = EL(pointer, width);
		glColorPointer(size, type, stride, pointer_s);
	}

#//# glColorPointer_p($size, $type, $stride, (OGA)pointer);
void
glColorPointer_p(size, oga)
	GLint	size
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glColorPointer(size, oga->types[0], 0, oga->bind ? 0 : oga->data);
#else
		glColorPointer(size, oga->types[0], 0, oga->data);
#endif
	}

#endif

#// 1.0
#//# glCopyPixels($x, $y, $width, $height, $type);
void
glCopyPixels(x, y, width, height, type)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLenum	type

#ifdef GL_VERSION_1_1

#// 1.1
#//# glCopyTexImage1D($target, $level, $internalFormat, $x, $y, $width, $border);
void
glCopyTexImage1D(target, level, internalFormat, x, y, width, border)
	GLenum	target
	GLint	level
	GLenum	internalFormat
	GLint	x
	GLint	y
	GLsizei	width
	GLint	border

#// 1.1
#//# glCopyTexImage2D($target, $level, $internalFormat, $x, $y, $width, $height, $border);
void
glCopyTexImage2D(target, level, internalFormat, x, y, width, height, border)
	GLenum	target
	GLint	level
	GLenum	internalFormat
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLint	border

#// 1.1
#//# glCopyTexSubImage1D($target, $level, $xoffset, $x, $y, $width);
void
glCopyTexSubImage1D(target, level, xoffset, x, y, width)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	x
	GLint	y
	GLsizei	width

#// 1.1
#//# glCopyTexSubImage2D($target, $level, $xoffset, $yoffset, $x, $y, $width, $height);
void
glCopyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height

#ifdef GL_VERSION_1_2

#// 1.2
#//# glCopyTexSubImage3D($target, $level, $xoffset, $yoffset, $zoffset, $x, $y, $width, $height);
void
glCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset, x, y, width, height)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	zoffset
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	INIT:
		loadProc(glCopyTexSubImage3D,"glCopyTexSubImage3D");
	CODE:
	{
		glCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset,
			x, y, width, height);
	}

#endif

#endif

#// 1.0
#//# glCullFace($mode);
void
glCullFace(mode)
	GLenum	mode

#// 1.0
#//# glDeleteLists($list, $range);
void
glDeleteLists(list, range)
	GLenum	list
	GLsizei	range

#ifdef GL_VERSION_1_1

#// 1.1
#//# glDeleteTextures_c($items, (CPTR)list);
void
glDeleteTextures_c(items, list)
	GLint	items
	void *	list
	CODE:
	glDeleteTextures(items,list);

#// 1.1
#//# glDeleteTextures_s($items, (PACKED)list);
void
glDeleteTextures_s(items, list)
	GLint	items
	SV *	list
	CODE:
	{
	void * list_s = EL(list, sizeof(GLuint) * items);
	glDeleteTextures(items,list_s);
	}

#// 1.1
#//# glDeleteTextures_p(@textureIDs);
void
glDeleteTextures_p(...)
	CODE:
	if (items) {
		GLuint * list = malloc(sizeof(GLuint) * items);
		int i;

		for(i=0;i<items;i++)
			list[i] = SvIV(ST(i));
		
		glDeleteTextures(items, list);
		free(list);
	}

#endif

#// 1.0
#//# glDepthFunc($func);
void
glDepthFunc(func)
	GLenum	func

#// 1.0
#//# glDepthMask($flag);
void
glDepthMask(flag)
	GLboolean	flag

#// 1.0
#//# glDepthRange($zNear, $zFar);
void
glDepthRange(zNear, zFar)
	GLclampd	zNear
	GLclampd	zFar

#ifdef GL_VERSION_1_1

#// 1.1
#//# glDrawArrays($mode, $first, $count);
void
glDrawArrays(mode, first, count)
	GLenum	mode
	GLint	first
	GLsizei	count

#endif

#// 1.0
#//# glDrawBuffer($mode);
void
glDrawBuffer(mode)
	GLenum	mode

#ifdef GL_VERSION_1_1

#// 1.1
#//# glDrawElements_c($mode, $count, $type, (CPTR)indices);
void
glDrawElements_c(mode, count, type, indices)
	GLenum	mode
	GLint	count
	GLenum	type
	void *	indices
	CODE:
		glDrawElements(mode, count, type, indices);

#// 1.1
#//# glDrawElements_s($mode, $count, $type, (PACKED)indices);
void
glDrawElements_s(mode, count, type, indices)
	GLenum	mode
	GLint	count
	GLenum	type
	SV *	indices
	CODE:
	{
		void * indices_s = EL(indices, gl_type_size(type)*count);
		glDrawElements(mode, count, type, indices_s);
	}

#//# glDrawElements_p($mode, @indices);
#//- Assumes GLuint for indices
void
glDrawElements_p(mode, ...)
	GLenum	mode
	CODE:
	{
		GLuint * indices = malloc(sizeof(GLuint) * items);
		int i;
		
		for (i=1; i<items; i++)
			indices[i-1] = SvIV(ST(i));
		
		glDrawElements(mode, items-1, GL_UNSIGNED_INT, indices);
		
		free(indices);
	}

#endif

#// 1.0
#//# glDrawPixels_c($width, $height, $format, $type, (CPTR)pixels);
void
glDrawPixels_c(width, height, format, type, pixels)
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glDrawPixels(width, height, format, type, pixels);

#// 1.0
#//# glDrawPixels_s($width, $height, $format, $type, (PACKED)pixels);
void
glDrawPixels_s(width, height, format, type, pixels)
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
	GLvoid * ptr = ELI(pixels, width, height,
		format, type, gl_pixelbuffer_unpack);
	glDrawPixels(width, height, format, type, ptr);
	}

#// 1.0
#//# glDrawPixels_p($width, $height, $format, $type, @pixels);
void
glDrawPixels_p(width, height, format, type, ...)
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(4)), items-4, width, height, 1, format, type, 0);
	glDrawPixels(width, height, format, type, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#ifdef GL_VERSION_1_2

#// 1.2
#//# glDrawRangeElements_c($mode, $start, $end, $count, $type, (CPTR)indices);
void
glDrawRangeElements_c(mode, start, end, count, type, indices)
	GLenum	mode
	GLuint	start
	GLuint	end
	GLsizei	count
	GLenum	type
	void *	indices
	INIT:
		loadProc(glDrawRangeElements,"glDrawRangeElements");
	CODE:
		glDrawRangeElements(mode, start, end, count, type, indices);

#//# glDrawRangeElements_s($mode, $start, $end, $count, $type, (PACKED)indices);
void
glDrawRangeElements_s(mode, start, end, count, type, indices)
	GLenum	mode
	GLuint	start
	GLuint	end
	GLsizei	count
	GLenum	type
	SV *	indices
	INIT:
		loadProc(glDrawRangeElements,"glDrawRangeElements");
	CODE:
	{
		void * indices_s = EL(indices, gl_type_size(type) * count);
		glDrawRangeElements(mode, start, end, count, type, indices_s);
	}

#//# glDrawRangeElements_p($mode, $start, $end, $count, $type, @indices);
#//- Assumes GLuint indices
void
glDrawRangeElements_p(mode, start, count, ...)
	GLenum	mode
	GLuint	start
	GLuint	count
	INIT:
		loadProc(glDrawRangeElements,"glDrawRangeElements");
	CODE:
	{
		if (items > 3)
		{
			if (start < (GLuint)items-3)
			{
				GLuint * indices;
				GLuint i;

				if (start+count > (GLuint)(items-3))
					count = (GLuint)items-(start+3);

				indices = malloc(sizeof(GLuint) * count);
		
				for (i=start; i<count; i++)
					indices[i] = SvIV(ST(i+3));
		
				glDrawRangeElements(mode, start, start+count-1,
					count, GL_UNSIGNED_INT, indices);
		
				free(indices);
			}
		}
		else
		{
			glDrawRangeElements(mode, start, start+count-1,
				count, GL_UNSIGNED_INT, 0);
		}
	}

#endif

#// 1.0
#//# glEdgeFlag($flag);
void
glEdgeFlag(flag)
	GLboolean	flag

#ifdef GL_VERSION_1_1

#// 1.1
#//# glEdgeFlagPointer_c($stride, (CPTR)pointer);
void
glEdgeFlagPointer_c(stride, pointer)
	GLint	stride
	void *	pointer
	CODE:
	glEdgeFlagPointer(stride, pointer);

#//# glEdgeFlagPointer_s($stride, (PACKED)pointer);
void
glEdgeFlagPointer_s(stride, pointer)
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : sizeof(GLboolean);
		void * pointer_s = EL(pointer, width);
		glEdgeFlagPointer(stride, pointer_s);
	}

#//# glEdgeFlagPointer_p($stride, (OGA)pointer);
void
glEdgeFlagPointer_p(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glEdgeFlagPointer(0, oga->bind ? 0 : oga->data);
#else
		glEdgeFlagPointer(0, oga->data);
#endif
	}

#endif

#// 1.0
#//# glEnable($cap);
void
glEnable(cap)
	GLenum	cap

#// 1.0
#//# glDisable($cap);
void
glDisable(cap)
	GLenum	cap

#ifdef GL_VERSION_1_1

#// 1.1
#//# glEnableClientState($cap);
void
glEnableClientState(cap)
	GLenum	cap

#// 1.1
#//# glDisableClientState($cap);
void
glDisableClientState(cap)
	GLenum	cap

#endif

#// 1.0
#//# glEvalCoord1d($u); 
void
glEvalCoord1d(u)
	GLdouble	u

#// 1.0
#//# glEvalCoord1f($u);
void
glEvalCoord1f(u)
	GLfloat	u

#// 1.0
#//# glEvalCoord2d($u, $v);
void
glEvalCoord2d(u, v)
	GLdouble	u
	GLdouble	v

#// 1.0
#//# glEvalCoord2f($u, $v);
void
glEvalCoord2f(u, v)
	GLfloat	u
	GLfloat	v

#// 1.0
#//# glEvalMesh1($mode, $i1, $i2);
void
glEvalMesh1(mode, i1, i2)
	GLenum	mode
	GLint	i1
	GLint	i2
	
#// 1.0
#//# glEvalMesh2($mode, $i1, $i2, $j1, $j2);
void
glEvalMesh2(mode, i1, i2, j1, j2)
	GLenum	mode
	GLint	i1
	GLint	i2
	GLint	j1
	GLint	j2

#// 1.0
#//# glEvalPoint1($i);
void
glEvalPoint1(i)
	GLint	i
	
#// 1.0
#//# glEvalPoint2($i, $j);
void
glEvalPoint2(i, j)
	GLint	i
	GLint	j

#// 1.0
#//# glFeedbackBuffer_c($size, $type, (CPTR)buffer);
void
glFeedbackBuffer_c(size, type, buffer)
	GLsizei	size
	GLenum	type
	void *	buffer
	CODE:
	glFeedbackBuffer(size, type, (GLfloat*)(buffer));

#// 1.0
#//# glFinish();
void
glFinish()

#// 1.0
#//# glFlush();
void
glFlush()

#// 1.0
#//# glFogf($pname, $param);
void
glFogf(pname, param)
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glFogi($pname, $param);
void
glFogi(pname, param)
	GLenum	pname
	GLint	param

#// 1.0
#//# glFogfv_c($pname, (CPTR)params);
void
glFogfv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glFogfv(pname, params);

#// 1.0
#//# glFogiv_c($pname, (CPTR)params);
void
glFogiv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glFogiv(pname, params);

#// 1.0
#//# glFogfv_s($pname, (PACKED)params);
void
glFogfv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat)*gl_fog_count(pname));
	glFogfv(pname, params_s);
	}

#// 1.0
#//# glFogiv_s($pname, (PACKED)params);
void
glFogiv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*gl_fog_count(pname));
	glFogiv(pname, params_s);
	}

#// 1.0
#//# glFogfv_p($pname, $param1, $param2=0, $param3=0, $param4=0);
void
glFogfv_p(pname, param1, param2=0, param3=0, param4=0)
	GLenum	pname
	GLfloat	param1
	GLfloat	param2
	GLfloat	param3
	GLfloat	param4
	CODE:
	{
		GLfloat p[4];
		p[0] = param1;
		p[1] = param2;
		p[2] = param3;
		p[3] = param4;
		glFogfv(pname, &p[0]);
	}

#// 1.0
#//# glFogiv_p($pname, $param1, $param2=0, $param3=0, $param4=0);
void
glFogiv_p(pname, param1, param2=0, param3=0, param4=0)
	GLenum	pname
	GLint	param1
	GLint	param2
	GLint	param3
	GLint	param4
	CODE:
	{
		GLint p[4];
		p[0] = param1;
		p[1] = param2;
		p[2] = param3;
		p[3] = param4;
		glFogiv(pname, &p[0]);
	}

#// 1.0
#//# glFrontFace($mode);
void
glFrontFace(mode)
	GLenum	mode

#// 1.0
#//# glFrustum($left, $right, $bottom, $top, $zNear, $zFar);
void
glFrustum(left, right, bottom, top, zNear, zFar)
	GLdouble	left
	GLdouble	right
	GLdouble	bottom
	GLdouble	top
	GLdouble	zNear
	GLdouble	zFar

#// 1.0
#//# glGenLists($range);
GLuint
glGenLists(range)
	GLsizei	range

#ifdef GL_VERSION_1_1

#// 1.1
#//# glGenTextures_c($n, (CPTR)textures);
void
glGenTextures_c(n, textures)
	GLint	n
	void *	textures
	CODE:
	glGenTextures(n, textures);

#// 1.1
#//# glGenTextures_s($n, (PACKED)textures);
void
glGenTextures_s(n, textures)
	GLint	n
	SV *	textures
	CODE:
	{
	void * textures_s = EL(textures, sizeof(GLuint)*n);
	glGenTextures(n, textures_s);
	}

#// 1.1
#//# @textureIDs = glGenTextures_p($n);
void
glGenTextures_p(n)
	GLint	n
	PPCODE:
	if (n) {
		GLuint * textures = malloc(sizeof(GLuint) * n);
		int i;
		
		glGenTextures(n, textures);
		
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(textures[i])));

		free(textures);
	} 

#endif

#// 1.0
#//# glGetDoublev_c($pname, (CPTR)params);
void
glGetDoublev_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glGetDoublev(pname, params);

#// 1.0
#//# glGetDoublev_c($pname, (PACKED)params);
void
glGetDoublev_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	void * params_s = EL(params, sizeof(GLdouble) * gl_get_count(pname));
	glGetDoublev(pname, params_s);
	}

#// 1.0
#//# glGetBooleanv_c($pname, (CPTR)params);
void
glGetBooleanv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glGetBooleanv(pname, params);

#// 1.0
#//# glGetBooleanv_s($pname, (PACKED)params);
void
glGetBooleanv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	void * params_s = EL(params, sizeof(GLboolean) * gl_get_count(pname));
	glGetBooleanv(pname, params_s);
	}

#// 1.0
#//# glGetIntegerv_c($pname, (CPTR)params);
void
glGetIntegerv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glGetIntegerv(pname, params);

#// 1.0
#//# glGetIntegerv_s($pname, (PACKED)params);
void
glGetIntegerv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	void * params_s = EL(params, sizeof(GLint) * gl_get_count(pname));
	glGetIntegerv(pname, params_s);
	}

#// 1.0
#//# glGetFloatv_c($pname, (CPTR)params);
void
glGetFloatv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glGetFloatv(pname, params);

#// 1.0
#//# glGetFloatv_s($pname, (PACKED)params);
void
glGetFloatv_s(pname, params)
	GLenum	pname
	void *	params
	CODE:
	{
	void * params_s = EL(params, sizeof(GLfloat) * gl_get_count(pname));
	glGetFloatv(pname, params_s);
	}

#// 1.0
#//# @data = glGetDoublev_p($param);
void
glGetDoublev_p(param)
	GLenum	param
	PPCODE:
	{
		GLdouble	ret[MAX_GL_GET_COUNT];
		int n = gl_get_count(param);
		int i;
		glGetDoublev(param, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @data = glGetBooleanv_p($param);
void
glGetBooleanv_p(param)
	GLenum	param
	PPCODE:
	{
		GLboolean	ret[MAX_GL_GET_COUNT];
		int n = gl_get_count(param);
		int i;
		glGetBooleanv(param, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# @data = glGetIntegerv_p($param);
void
glGetIntegerv_p(param)
	GLenum	param
	PPCODE:
	{
		GLint	ret[MAX_GL_GET_COUNT];
		int n = gl_get_count(param);
		int i;
		glGetIntegerv(param, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# @data = glGetFloatv_p($param);
void
glGetFloatv_p(param)
	GLenum	param
	PPCODE:
	{
		GLfloat	ret[MAX_GL_GET_COUNT];
		int n = gl_get_count(param);
		int i;
		glGetFloatv(param, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# glGetClipPlane_c($plane, (CPTR)eqn);
void
glGetClipPlane_c(plane, eqn)
	GLenum	plane
	void *	eqn
	CODE:
	glGetClipPlane(plane, eqn);

#// 1.0
#//# glGetClipPlane_s($plane, (PACKED)eqn);
void
glGetClipPlane_s(plane, eqn)
	GLenum	plane
	SV *	eqn
	CODE:
	{
	GLdouble * eqn_s = EL(eqn, sizeof(GLdouble)*4);
	glGetClipPlane(plane, eqn_s);
	}

#// 1.0
#//# @data = glGetClipPlane_p($plane);
void
glGetClipPlane_p(plane)
	GLenum	plane
	PPCODE:
	{
		int i;
		GLdouble	eqn[4];
		eqn[0] = eqn[1] = eqn[2] = eqn[3] = 0;
		glGetClipPlane(plane, &eqn[0]);
		EXTEND(sp, 4);
		for(i=0;i<4;i++)
			PUSHs(sv_2mortal(newSVnv(eqn[i])));
	}

#// 1.0
#//# glGetError();
GLenum
glGetError()

#// 1.0
#//# glGetLightfv_c($light, $pname, (CPTR)p);
void
glGetLightfv_c(light, pname, p)
	GLenum	light
	GLenum	pname
	void *	p
	CODE:
	glGetLightfv(light, pname, p);

#// 1.0
#//# glGetLightiv_c($light, $pname, (CPTR)p);
void
glGetLightiv_c(light, pname, p)
	GLenum	light
	GLenum	pname
	void *	p
	CODE:
	glGetLightiv(light, pname, p);

#// 1.0
#//# glGetLightfv_s($light, $pname, (PACKED)p);
void
glGetLightfv_s(light, pname, p)
	GLenum	light
	GLenum	pname
	SV *	p
	CODE:
	{
	void * p_s = EL(p, sizeof(GLfloat)*gl_light_count(pname));
	glGetLightfv(light, pname, p_s);
	}

#// 1.0
#//# glGetLightiv_s($light, $pname, (PACKED)p);
void
glGetLightiv_s(light, pname, p)
	GLenum	light
	GLenum	pname
	SV *	p
	CODE:
	{
	void * p_s = EL(p, sizeof(GLint)*gl_light_count(pname));
	glGetLightiv(light, pname, p_s);
	}

#// 1.0
#//# @data = glGetLightfv_p($light, $pname);
void
glGetLightfv_p(light, pname)
	GLenum	light
	GLenum	pname
	PPCODE:
	{
		GLfloat	ret[MAX_GL_LIGHT_COUNT];
		int n = gl_light_count(pname);
		int i;
		glGetLightfv(light, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @data = glGetLightiv_p($light, $pname);
void
glGetLightiv_p(light, pname)
	GLenum	light
	GLenum	pname
	PPCODE:
	{
		GLint	ret[MAX_GL_LIGHT_COUNT];
		int n = gl_light_count(pname);
		int i;
		glGetLightiv(light, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glGetMapiv_c($target, $query, (CPTR)v);
void
glGetMapiv_c(target, query, v)
	GLenum	target
	GLenum	query
	void *	v
	CODE:
	glGetMapiv(target, query, (GLint*)v);

#// 1.0
#//# glGetMapfv_c($target, $query, (CPTR)v);
void
glGetMapfv_c(target, query, v)
	GLenum	target
	GLenum	query
	void *	v
	CODE:
	glGetMapfv(target, query, (GLfloat*)v);

#// 1.0
#//# glGetMapdv_c($target, $query, (CPTR)v);
void
glGetMapdv_c(target, query, v)
	GLenum	target
	GLenum	query
	void *	v
	CODE:
	glGetMapdv(target, query, (GLdouble*)v);

#// 1.0
#//# glGetMapdv_s($target, $query, (PACKED)v);
void
glGetMapdv_s(target, query, v)
	GLenum	target
	GLenum	query
	SV * v
	CODE:
	{
		GLdouble * v_s = EL(v,
			sizeof(GLdouble)*gl_map_count(target, query));
		glGetMapdv(target, query, v_s);
	}

#// 1.0
#//# glGetMapfv_s($target, $query, (PACKED)v);
void
glGetMapfv_s(target, query, v)
	GLenum	target
	GLenum	query
	SV * v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*gl_map_count(target, query));
		glGetMapfv(target, query, v_s);
	}

#// 1.0
#//# glGetMapiv_s($target, $query, (PACKED)v);
void
glGetMapiv_s(target, query, v)
	GLenum	target
	GLenum	query
	SV * v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*gl_map_count(target, query));
		glGetMapiv(target, query, v_s);
	}

#// 1.0
#//# @data = glGetMapfv_p($target, $query);
void
glGetMapfv_p(target, query)
	GLenum	target
	GLenum	query
	PPCODE:
	{
		GLfloat	ret[MAX_GL_MAP_COUNT];
		int n = gl_map_count(target, query);
		int i;
		glGetMapfv(target, query, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @data = glGetMapdv_p($target, $query);
void
glGetMapdv_p(target, query)
	GLenum	target
	GLenum	query
	PPCODE:
	{
		GLdouble	ret[MAX_GL_MAP_COUNT];
		int n = gl_map_count(target, query);
		int i;
		glGetMapdv(target, query, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @data = glGetMapiv_p($target, $query);
void
glGetMapiv_p(target, query)
	GLenum	target
	GLenum	query
	PPCODE:
	{
		GLint	ret[MAX_GL_MAP_COUNT];
		int n = gl_map_count(target, query);
		int i;
		glGetMapiv(target, query, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glGetMaterialfv_c($face, $query, (CPTR)params);
void
glGetMaterialfv_c(face, query, params)
	GLenum	face
	GLenum	query
	void *	params
	CODE:
	glGetMaterialfv(face, query, params);

#// 1.0
#//# glGetMaterialiv_c($face, $query, (CPTR)params);
void
glGetMaterialiv_c(face, query, params)
	GLenum	face
	GLenum	query
	void *	params
	CODE:
	glGetMaterialiv(face, query, params);

#// 1.0
#//# glGetMaterialfv_s($face, $query, (PACKED)params);
void
glGetMaterialfv_s(face, query, params)
	GLenum	face
	GLenum	query
	SV *	params
	CODE:
	{
		GLfloat * params_s = EL(params,
			sizeof(GLfloat)*gl_material_count(query));
		glGetMaterialfv(face, query, params_s);
	}

#// 1.0
#//# glGetMaterialiv_s($face, $query, (PACKED)params);
void
glGetMaterialiv_s(face, query, params)
	GLenum	face
	GLenum	query
	SV *	params
	CODE:
	{
		GLint * params_s = EL(params,
			sizeof(GLfloat)*gl_material_count(query));
		glGetMaterialiv(face, query, params_s);
	}

#// 1.0
#//# @params = glGetMaterialfv_p($face, $query);
void
glGetMaterialfv_p(face, query)
	GLenum	face
	GLenum	query
	PPCODE:
	{
		GLfloat	ret[MAX_GL_MATERIAL_COUNT];
		int n = gl_material_count(query);
		int i;
		glGetMaterialfv(face, query, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @params = glGetMaterialiv_p($face, $query);
void
glGetMaterialiv_p(face, query)
	GLenum	face
	GLenum	query
	PPCODE:
	{
		GLint	ret[MAX_GL_MATERIAL_COUNT];
		int n = gl_material_count(query);
		int i;
		glGetMaterialiv(face, query, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glGetPixelMapfv_c($map, (CPTR)values);
void
glGetPixelMapfv_c(map, values)
	GLenum	map
	void *	values
	CODE:
	glGetPixelMapfv(map, values);

#// 1.0
#//# glGetPixelMapuiv_c($map, (CPTR)values);
void
glGetPixelMapuiv_c(map, values)
	GLenum	map
	void *	values
	CODE:
	glGetPixelMapuiv(map, values);

#// 1.0
#//# glGetPixelMapusv_c($map, (CPTR)values);
void
glGetPixelMapusv_c(map, values)
	GLenum	map
	void *	values
	CODE:
	glGetPixelMapusv(map, values);

#// 1.0
#//# glGetPixelMapfv_s($map, (PACKED)values);
void
glGetPixelMapfv_s(map, values)
	GLenum	map
	SV *	values
	CODE:
	{
	GLfloat * values_s = EL(values, sizeof(GLfloat)* gl_pixelmap_size(map));
	glGetPixelMapfv(map, values_s);
	}

#// 1.0
#//# glGetPixelMapuiv_s($map, (PACKED)values);
void
glGetPixelMapuiv_s(map, values)
	GLenum	map
	SV *	values
	CODE:
	{
	GLuint * values_s = EL(values, sizeof(GLuint)* gl_pixelmap_size(map));
	glGetPixelMapuiv(map, values_s);
	}

#// 1.0
#//# glGetPixelMapusv_s($map, (PACKED)values);
void
glGetPixelMapusv_s(map, values)
	GLenum	map
	SV *	values
	CODE:
	{
	GLushort * values_s = EL(values, sizeof(GLushort)* gl_pixelmap_size(map));
	glGetPixelMapusv(map, values_s);
	}

#// 1.0
#//# @data = glGetPixelMapfv_p($map);
void
glGetPixelMapfv_p(map)
	GLenum	map
	CODE:
	{
		int count = gl_pixelmap_size(map);
		GLfloat * values;
		int i;

		values = malloc(sizeof(GLfloat) * count);

		glGetPixelMapfv(map, values);
		
		EXTEND(sp, count);
		
		for(i=0; i<count; i++)
			PUSHs(sv_2mortal(newSVnv(values[i])));

		free(values);
	}

#// 1.0
#//# @data = glGetPixelMapuiv_p($map);
void
glGetPixelMapuiv_p(map)
	GLenum	map
	CODE:
	{
		int count = gl_pixelmap_size(map);
		GLuint * values;
		int i;
		values = malloc(sizeof(GLuint) * count);
		glGetPixelMapuiv(map, values);
		EXTEND(sp, count);
		for(i=0; i<count; i++)
			PUSHs(sv_2mortal(newSViv(values[i])));
		free(values);
	}
	
#// 1.0
#//# @data = glGetPixelMapusv_p($map);
void
glGetPixelMapusv_p(map)
	GLenum	map
	CODE:
	{
		int count = gl_pixelmap_size(map);
		GLushort * values;
		int i;
		values = malloc(sizeof(GLushort) * count);
		glGetPixelMapusv(map, values);
		EXTEND(sp, count);
		for(i=0; i<count; i++)
			PUSHs(sv_2mortal(newSViv(values[i])));
		free(values);
	}

#// 1.0
#//# glGetPolygonStipple_c((CPTR)mask);
void
glGetPolygonStipple_c(mask)
	void *	mask
	CODE:
	glGetPolygonStipple(mask);

#// 1.0
#//# glGetPolygonStipple_s((PACKED)mask);
void
glGetPolygonStipple_s(mask)
	SV *	mask
	CODE:
	{
	GLubyte * ptr = ELI(mask, 32, 32, GL_COLOR_INDEX, GL_BITMAP, gl_pixelbuffer_unpack);
	glGetPolygonStipple(ptr);
	}

#// 1.0
#//# @mask = glGetPolygonStipple_p();
void
glGetPolygonStipple_p()
	PPCODE:
	{
		void * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_PACK_ROW_LENGTH, 0);
		glPixelStorei(GL_PACK_ALIGNMENT, 1);
		ptr = allocate_image_ST(32, 32, 1, GL_COLOR_INDEX, GL_BITMAP, 0);
		glGetPolygonStipple(ptr);
		sp = unpack_image_ST(sp, ptr, 32, 32, 1,
			GL_COLOR_INDEX, GL_BITMAP, 0);
		free(ptr);
		glPopClientAttrib();
	}

#ifdef GL_VERSION_1_1

#// 1.1
#//# glGetPointerv_c($pname, (CPTR)params);
void
glGetPointerv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glGetPointerv(pname,&params);

#// 1.1
#//# glGetPointerv_s($pname, (PACKED)params);
void
glGetPointerv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
		void ** params_s = EL(params, sizeof(void*));
		glGetPointerv(pname, params_s);
	}

#// 1.1
#//# @params = glGetPointerv_p($pname);
void *
glGetPointerv_p(pname)
	GLenum	pname
	CODE:
	glGetPointerv(pname, &RETVAL);
	OUTPUT:
	RETVAL

#endif

#// 1.0
#//# $string = glGetString($name);
SV *
glGetString(name)
	GLenum	name
	CODE:
	{
		char * c = (char*)glGetString(name);
		if (c)
			RETVAL = newSVpv(c, 0);
		else
			RETVAL = newSVsv(&PL_sv_undef);
	}
	OUTPUT:
	RETVAL

#// 1.0
#//# glGetTexEnvfv_c($target, $pname, (CPTR)params);
void
glGetTexEnvfv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void * params
	CODE:
	glGetTexEnvfv(target, pname, params);

#// 1.0
#//# glGetTexEnviv_c($target, $pname, (CPTR)params);
void
glGetTexEnviv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void * params
	CODE:
	glGetTexEnviv(target, pname, params);

#// 1.0
#//# glGetTexEnvfv_s($target, $pname, (PACKED)params);
void
glGetTexEnvfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV * params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat) * gl_texenv_count(pname));
	glGetTexEnvfv(target, pname, params_s);
	}

#// 1.0
#//# glGetTexEnviv_s($target, $pname, (PACKED)params);
void
glGetTexEnviv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV * params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint) * gl_texenv_count(pname));
	glGetTexEnviv(target, pname, params_s);
	}

#// 1.0
#//# @parames = glGetTexEnvfv_p($target, $pname);
void
glGetTexEnvfv_p(target, pname)
	GLenum	target
	GLenum	pname
	PPCODE:
	{
		GLfloat	ret[MAX_GL_TEXENV_COUNT];
		int n = gl_texenv_count(pname);
		int i;
		glGetTexEnvfv(target, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @parames = glGetTexEnviv_p($target, $pname);
void
glGetTexEnviv_p(target, pname)
	GLenum	target
	GLenum	pname
	PPCODE:
	{
		GLint	ret[MAX_GL_TEXENV_COUNT];
		int n = gl_texenv_count(pname);
		int i;
		glGetTexEnviv(target, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glGetTexGenfv_c($coord, $pname, (CPTR)params);
void
glGetTexGenfv_c(coord, pname, params)
	GLenum	coord
	GLenum	pname
	void *	params
	CODE:
	glGetTexGenfv(coord, pname, params);

#// 1.0
#//# glGetTexGendv_c($coord, $pname, (CPTR)params);
void
glGetTexGendv_c(coord, pname, params)
	GLenum	coord
	GLenum	pname
	void *	params
	CODE:
	glGetTexGendv(coord, pname, params);

#// 1.0
#//# glGetTexGeniv_c($coord, $pname, (CPTR)params);
void
glGetTexGeniv_c(coord, pname, params)
	GLenum	coord
	GLenum	pname
	void *	params
	CODE:
	glGetTexGeniv(coord, pname, params);

#// 1.0
#//# glGetTexGendv_c($coord, $pname, (CPTR)params);
void
glGetTexGendv_s(coord, pname, params)
	GLenum	coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLdouble * params_s = EL(params, sizeof(GLdouble)*gl_texgen_count(pname));
	glGetTexGendv(coord, pname, params_s);
	}

#// 1.0
#//# glGetTexGenfv_s($coord, $pname, (PACKED)params);
void
glGetTexGenfv_s(coord, pname, params)
	GLenum	coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat)*gl_texgen_count(pname));
	glGetTexGenfv(coord, pname, params_s);
	}

#// 1.0
#//# glGetTexGeniv_s($coord, $pname, (PACKED)params);
void
glGetTexGeniv_s(coord, pname, params)
	GLenum	coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*gl_texgen_count(pname));
	glGetTexGeniv(coord, pname, params_s);
	}

#// 1.0
#//# @params = glGetTexGenfv_p($coord, $pname);
void
glGetTexGenfv_p(coord, pname)
	GLenum	coord
	GLenum	pname
	PPCODE:
	{
		GLfloat	ret[MAX_GL_TEXGEN_COUNT];
		int n = gl_texgen_count(pname);
		int i;
		glGetTexGenfv(coord, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @params = glGetTexGendv_p($coord, $pname);
void
glGetTexGendv_p(coord, pname)
	GLenum	coord
	GLenum	pname
	PPCODE:
	{
		GLdouble	ret[MAX_GL_TEXGEN_COUNT];
		int n = gl_texgen_count(pname);
		int i;
		glGetTexGendv(coord, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @params = glGetTexGeniv_p($coord, $pname);
void
glGetTexGeniv_p(coord, pname)
	GLenum	coord
	GLenum	pname
	PPCODE:
	{
		GLint	ret[MAX_GL_TEXGEN_COUNT];
		int n = gl_texgen_count(pname);
		int i;
		glGetTexGeniv(coord, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glGetTexImage_c($target, $level, $format, $type, (CPTR)pixels);
void
glGetTexImage_c(target, level, format, type, pixels)
	GLenum	target
	GLint	level
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glGetTexImage(target, level, format, type, pixels);

#// 1.0
#//# glGetTexImage_s($target, $level, $format, $type, (PACKED)pixels);
void
glGetTexImage_s(target, level, format, type, pixels)
	GLenum	target
	GLint	level
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
		GLint width, height;
		GLvoid * ptr;
		
		glGetTexLevelParameteriv(target, level,
			GL_TEXTURE_WIDTH, &width);
		glGetTexLevelParameteriv(target, level,
			GL_TEXTURE_HEIGHT, &height);
		
		ptr = ELI(pixels, width, height, format, type,
			gl_pixelbuffer_unpack);
		glGetTexImage(target, level, format, type, pixels);
	}

#// 1.0
#//# @pixels = glGetTexImage_c($target, $level, $format, $type);
void
glGetTexImage_p(target, level, format, type)
	GLenum	target
	GLint	level
	GLenum	format
	GLenum	type
	PPCODE:
	{
		GLint width, height;
		GLvoid * ptr;
		
		glGetTexLevelParameteriv(target, level,
			GL_TEXTURE_WIDTH, &width);
		glGetTexLevelParameteriv(target, level,
			GL_TEXTURE_HEIGHT, &height);
		
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_PACK_ROW_LENGTH, 0);
		glPixelStorei(GL_PACK_ALIGNMENT, 1);

		ptr = allocate_image_ST(width, height, 1, format, type, 0);
		glGetTexImage(target, level, format, type, ptr);
		sp = unpack_image_ST(sp, ptr, width, height, 1, format, type, 0);

		free(ptr);
		glPopClientAttrib();
	}

#// 1.0
#//# glGetTexLevelParameterfv_c($target, $level, $pname, (CPTR)params);
void
glGetTexLevelParameterfv_c(target, level, pname, params)
	GLenum	target
	GLint	level
	GLenum	pname
	void *	params
	CODE:
	glGetTexLevelParameterfv(target, level, pname, params);

#// 1.0
#//# glGetTexLevelParameteriv_c($target, $level, $pname, (CPTR)params);
void
glGetTexLevelParameteriv_c(target, level, pname, params)
	GLenum	target
	GLint	level
	GLenum	pname
	void *	params
	CODE:
	glGetTexLevelParameteriv(target, level, pname, params);

#// 1.0
#//# glGetTexLevelParameterfv_s($target, $level, $pname, (PACKED)params);
void
glGetTexLevelParameterfv_s(target, level, pname, params)
	GLenum	target
	GLint	level
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat)*1);
	glGetTexLevelParameterfv(target, level, pname, params_s);
	}

#// 1.0
#//# glGetTexLevelParameteriv_s($target, $level, $pname, (PACKED)params);
void
glGetTexLevelParameteriv_s(target, level, pname, params)
	GLenum	target
	GLint	level
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*1);
	glGetTexLevelParameteriv(target, level, pname, params_s);
	}

#// 1.0
#//# @params = glGetTexLevelParameterfv_p($target, $level, $pname);
void
glGetTexLevelParameterfv_p(target, level, pname)
	GLenum	target
	GLint	level
	GLenum	pname
	PPCODE:
	{
		GLfloat	ret;
		glGetTexLevelParameterfv(target, level, pname, &ret);
		PUSHs(sv_2mortal(newSVnv(ret)));
	}

#// 1.0
#//# @params = glGetTexLevelParameteriv_p($target, $level, $pname);
void
glGetTexLevelParameteriv_p(target, level, pname)
	GLenum	target
	GLint	level
	GLenum	pname
	PPCODE:
	{
		GLint	ret;
		glGetTexLevelParameteriv(target, level, pname, &ret);
		PUSHs(sv_2mortal(newSViv(ret)));
	}

#// 1.0
#//# glGetTexParameterfv_c($target, $pname, (CPTR)params);
void
glGetTexParameterfv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void *	params
	CODE:
	glGetTexParameterfv(target, pname, params);

#// 1.0
#//# glGetTexParameteriv_c($target, $pname, (CPTR)params);
void
glGetTexParameteriv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void *	params
	CODE:
	glGetTexParameteriv(target, pname, params);

#// 1.0
#//# glGetTexParameterfv_s($target, $pname, (PACKED)params);
void
glGetTexParameterfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params,
		sizeof(GLfloat)*gl_texparameter_count(pname));
	glGetTexParameterfv(target, pname, params_s);
	}

#// 1.0
#//# glGetTexParameteriv_s($target, $pname, (PACKED)params);
void
glGetTexParameteriv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params,
		sizeof(GLint)*gl_texparameter_count(pname));
	glGetTexParameteriv(target, pname, params_s);
	}

#// 1.0
#//# @params = glGetTexParameterfv_p($target, $pname);
void
glGetTexParameterfv_p(target, pname)
	GLenum	target
	GLenum	pname
	PPCODE:
	{
		GLfloat	ret[MAX_GL_TEXPARAMETER_COUNT];
		int n = gl_texparameter_count(pname);
		int i;
		glGetTexParameterfv(target, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSVnv(ret[i])));
	}

#// 1.0
#//# @params = glGetTexParameteriv_p($target, $pname);
void
glGetTexParameteriv_p(target, pname)
	GLenum	target
	GLenum	pname
	PPCODE:
	{
		GLint	ret[MAX_GL_TEXPARAMETER_COUNT];
		int n = gl_texparameter_count(pname);
		int i;
		glGetTexParameteriv(target, pname, &ret[0]);
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(ret[i])));
	}

#// 1.0
#//# glHint($target, $mode);
void
glHint(target, mode)
	GLenum	target
	GLenum	mode

#// 1.0
#//# glIndexd($c);
void
glIndexd(c)
	GLdouble	c

#// 1.0
#//# glIndexi($c);
void
glIndexi(c)
	GLint	c

#// 1.0
#//# glIndexMask($mask)
void
glIndexMask(mask)
	GLuint	mask

#ifdef GL_VERSION_1_1

#// 1.1
#//# glIndexPointer_c($type, $stride, (CPTR)pointer);
void
glIndexPointer_c(type, stride, pointer)
	GLenum	type
	GLsizei	stride
	void *	pointer
	CODE:
	glIndexPointer(type, stride, pointer);

#//# glIndexPointer_s($type, $stride, (PACKED)pointer);
void
glIndexPointer_s(type, stride, pointer)
	GLenum	type
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : sizeof(type);
		void * pointer_s = EL(pointer, width);
		glIndexPointer(type, stride, pointer_s);
	}

#//# glIndexPointer_p($type, $stride, (OGA)pointer);
void
glIndexPointer_p(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glIndexPointer(oga->types[0], 0, oga->bind ? 0 : oga->data);
#else
		glIndexPointer(oga->types[0], 0, oga->data);
#endif
	}

#endif

#// 1.0
#//# glInitNames();
void
glInitNames()

#ifdef GL_VERSION_1_1

#// 1.1
#//# glInterleavedArrays_c($format, $stride, (CPTR)pointer);
void
glInterleavedArrays_c(format, stride, pointer)
	GLenum	format
	GLsizei	stride
	void *	pointer
	CODE:
	glInterleavedArrays(format, stride, pointer);

#endif

#// 1.0
#//# glIsEnabled($cap);
GLboolean
glIsEnabled(cap)
	GLenum	cap

#// 1.0
#//# glIsList(list);
GLboolean
glIsList(list)
	GLuint	list

#ifdef GL_VERSION_1_1

#// 1.1
#//# glIsTexture($list);
GLboolean
glIsTexture(list)
	GLuint	list

#endif


#// 1.0
#//# glLightf($light, $pname, $param);
void
glLightf(light, pname, param)
	GLenum	light
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glLighti($light, $pname, $param);
void
glLighti(light, pname, param)
	GLenum	light
	GLenum	pname
	GLint	param

#// 1.0
#//# glLightfv_c($light, $pname, (CPTR)params);
void
glLightfv_c(light, pname, params)
	GLenum	light
	GLenum	pname
	void *	params
	CODE:
	glLightfv(light, pname, params);

#// 1.0
#//# glLightiv_c($light, $pname, (CPTR)params);
void
glLightiv_c(light, pname, params)
	GLenum	light
	GLenum	pname
	void *	params
	CODE:
	glLightiv(light, pname, params);

#// 1.0
#//# glLightfv_s($light, $pname, (PACKED)params);
void
glLightfv_s(light, pname, params)
	GLenum	light
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat)*gl_light_count(pname));
	glLightfv(light, pname, params_s);
	}

#// 1.0
#//# glLightiv_s($light, $pname, (PACKED)params);
void
glLightiv_s(light, pname, params)
	GLenum	light
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*gl_light_count(pname));
	glLightiv(light, pname, params_s);
	}

#// 1.0
#//# glLightfv_p($light, $pname, @params);
void
glLightfv_p(light, pname, ...)
	GLenum	light
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_LIGHT_COUNT];
		int i;
		if ((items-2) != gl_light_count(pname))
			croak("Incorrect number of arguments");
		for(i=2;i<items;i++)
			p[i-2] = (GLfloat)SvNV(ST(i));
		glLightfv(light, pname, &p[0]);
	}

#// 1.0
#//# glLightiv_p($light, $pname, @params);
void
glLightiv_p(light, pname, ...)
	GLenum	light
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_LIGHT_COUNT];
		int i;
		if ((items-2) != gl_light_count(pname))
			croak("Incorrect number of arguments");
		for(i=2;i<items;i++)
			p[i-2] = SvIV(ST(i));
		glLightiv(light, pname, &p[0]);
	}

#// 1.0
#//# glLightModelf($pname, $param);
void
glLightModelf(pname, param)
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glLightModeli($pname, $param);
void
glLightModeli(pname, param)
	GLenum	pname
	GLint	param

#// 1.0
#//# glLightModeliv_c($pname, (CPTR)params);
void
glLightModeliv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glLightModeliv(pname, params);

#// 1.0
#//# glLightModelfv_c($pname, (CPTR)params);
void
glLightModelfv_c(pname, params)
	GLenum	pname
	void *	params
	CODE:
	glLightModelfv(pname, params);

#// 1.0
#//# glLightModeliv_s($pname, (PACKED)params);
void
glLightModeliv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*gl_lightmodel_count(pname));
	glLightModeliv(pname, params_s);
	}

#// 1.0
#//# glLightModelfv_s($pname, (PACKED)params);
void
glLightModelfv_s(pname, params)
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params,
		sizeof(GLfloat)*gl_lightmodel_count(pname));
	glLightModelfv(pname, params_s);
	}

#// 1.0
#//# glLightModelfv_p($pname, @params);
void
glLightModelfv_p(pname, ...)
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_LIGHTMODEL_COUNT];
		int i;
		if ((items-1) != gl_lightmodel_count(pname))
			croak("Incorrect number of arguments");
		for(i=1;i<items;i++)
			p[i-1] = (GLfloat)SvNV(ST(i));
		glLightModelfv(pname, &p[0]);
	}

#// 1.0
#//# glLightModeliv_p($pname, @params);
void
glLightModeliv_p(pname, ...)
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_LIGHTMODEL_COUNT];
		int i;
		if ((items-1) != gl_lightmodel_count(pname))
			croak("Incorrect number of arguments");
		for(i=1;i<items;i++)
			p[i-1] = SvIV(ST(i));
		glLightModeliv(pname, &p[0]);
	}

#// 1.0
#//# glLineStipple($factor, $pattern);
void
glLineStipple(factor, pattern)
	GLint	factor
	GLushort	pattern

#// 1.0
#//# glLineWidth($width);
void
glLineWidth(width)
	GLfloat	width

#// 1.0
#//# glListBase($base);
void
glListBase(base)
	GLuint	base

#// 1.0
#//# glLoadIdentity();
void
glLoadIdentity()

#// 1.0
#//# glLoadMatrixf_c((CPTR)m);
void
glLoadMatrixf_c(m)
	void *	m
	CODE:
	glLoadMatrixf(m);

#// 1.0
#//# glLoadMatrixd_c((CPTR)m);
void
glLoadMatrixd_c(m)
	void *	m
	CODE:
	glLoadMatrixd(m);

#// 1.0
#//# glLoadMatrixf_s((PACKED)m);
void
glLoadMatrixf_s(m)
	SV *	m
	CODE:
	{
	GLfloat * m_s = EL(m, sizeof(GLfloat)*16);
	glLoadMatrixf(m_s);
	}

#// 1.0
#//# glLoadMatrixd_s((PACKED)m);
void
glLoadMatrixd_s(m)
	SV *	m
	CODE:
	{
	GLdouble * m_s = EL(m, sizeof(GLdouble)*16);
	glLoadMatrixd(m_s);
	}

#// 1.0
#//# glLoadMatrixd_p(@m);
void
glLoadMatrixd_p(...)
	CODE:
	{
		GLdouble m[16];
		int i;
		if (items != 16)
			croak("Incorrect number of arguments");
		for (i=0;i<16;i++)
			m[i] = SvNV(ST(i));
		glLoadMatrixd(&m[0]);
	}

#// 1.0
#//# glLoadMatrixf_p(@m);
void
glLoadMatrixf_p(...)
	CODE:
	{
		GLfloat m[16];
		int i;
		if (items != 16)
			croak("Incorrect number of arguments");
		for (i=0;i<16;i++)
			m[i] = (GLfloat)SvNV(ST(i));
		glLoadMatrixf(&m[0]);
	}

#// 1.0
#//# glLoadName($name);
void
glLoadName(name)
	GLuint	name

#// 1.0
#//# glLogicOp($opcode);
void
glLogicOp(opcode)
	GLenum	opcode

#// 1.0
#//# glMap1d_c($target, $u1, $u2, $stride, $order, (CPTR)points);
void
glMap1d_c(target, u1, u2, stride, order, points)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	GLint	stride
	GLint	order
	void *	points
	CODE:
	glMap1d(target, u1, u2, stride, order, points);

#// 1.0
#//# glMap1f_c($target, $u1, $u2, $stride, $order, (CPTR)points);
void
glMap1f_c(target, u1, u2, stride, order, points)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	GLint	stride
	GLint	order
	void *	points
	CODE:
	glMap1f(target, u1, u2, stride, order, points);

#// 1.0
#//# glMap1d_s($target, $u1, $u2, $stride, $order, (PACKED)points);
void
glMap1d_s(target, u1, u2, stride, order, points)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	GLint	stride
	GLint	order
	SV *	points
	CODE:
	{
	GLdouble * points_s = EL(points, 0 /*FIXME*/);
	glMap1d(target, u1, u2, stride, order, points_s);
	}

#// 1.0
#//# glMap1f_s($target, $u1, $u2, $stride, $order, (PACKED)points);
void
glMap1f_s(target, u1, u2, stride, order, points)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	GLint	stride
	GLint	order
	SV *	points
	CODE:
	{
	GLfloat * points_s = EL(points, 0 /*FIXME*/);
	glMap1f(target, u1, u2, stride, order, points_s);
	}

#// 1.0
#//# glMap1d_p($target, $u1, $u2, @points);
#//- Assumes 0 stride
void
glMap1d_p(target, u1, u2, ...)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	CODE:
	{
		int count = items-3;
		GLint order = (items - 3) / gl_map_count(target, GL_COEFF);
		GLdouble * points = malloc(sizeof(GLdouble) * (count+1));
		int i;
		for (i=0;i<count;i++)
			points[i] = SvNV(ST(i+3));
		glMap1d(target, u1, u2, 0, order, points);
		free(points);
	}

#// 1.0
#//# glMap1f_p($target, $u1, $u2, @points);
#//- Assumes 0 stride
void
glMap1f_p(target, u1, u2, ...)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	CODE:
	{
		int count = items-3;
		GLint order = (items - 3) / gl_map_count(target, GL_COEFF);
		GLfloat * points = malloc(sizeof(GLfloat) * (count+1));
		int i;
		for (i=0;i<count;i++)
			points[i] = (GLfloat)SvNV(ST(i+3));
		glMap1f(target, u1, u2, 0, order, points);
		free(points);
	}

#// 1.0
#//# glMap2d_c($target, $u1, $u2, $ustride, $uorder, $v1, $v2, $vstride, $vorder, (CPTR)points);
void
glMap2d_c(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	GLint	ustride
	GLint	uorder
	GLdouble	v1
	GLdouble	v2
	GLint	vstride
	GLint	vorder
	void *	points
	CODE:
	glMap2d(target, u1, u2, ustride, uorder, v1, v2,
		vstride, vorder, points);

#// 1.0
#//# glMap2f_c($target, $u1, $u2, $ustride, $uorder, $v1, $v2, $vstride, $vorder, (CPTR)points);
void
glMap2f_c(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	GLint	ustride
	GLint	uorder
	GLfloat	v1
	GLfloat	v2
	GLint	vstride
	GLint	vorder
	void *	points
	CODE:
	glMap2f(target, u1, u2, ustride, uorder, v1, v2,
		vstride, vorder, points);

#// 1.0
#//# glMap2d_s($target, $u1, $u2, $ustride, $uorder, $v1, $v2, $vstride, $vorder, (PACKED)points);
void
glMap2d_s(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	GLint	ustride
	GLint	uorder
	GLdouble	v1
	GLdouble	v2
	GLint	vstride
	GLint	vorder
	SV *	points
	CODE:
	{
	GLdouble * points_s = EL(points, 0 /*FIXME*/);
	glMap2d(target, u1, u2, ustride, uorder, v1, v2,
		vstride, vorder, points_s);
	}

#// 1.0
#//# glMap2f_s($target, $u1, $u2, $ustride, $uorder, $v1, $v2, $vstride, $vorder, (PACKED)points);
void
glMap2f_s(target, u1, u2, ustride, uorder, v1, v2, vstride, vorder, points)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	GLint	ustride
	GLint	uorder
	GLfloat	v1
	GLfloat	v2
	GLint	vstride
	GLint	vorder
	SV *	points
	CODE:
	{
	GLfloat * points_s = EL(points, 0 /*FIXME*/);
	glMap2f(target, u1, u2, ustride, uorder, v1, v2,
		vstride, vorder, points_s);
	}

#// 1.0
#//# glMap2d_p($target, $u1, $u2, $uorder, $v1, $v2, @points);
#//- Assumes 0 ustride and vstride
void
glMap2d_p(target, u1, u2, uorder, v1, v2, ...)
	GLenum	target
	GLdouble	u1
	GLdouble	u2
	GLint	uorder
	GLdouble	v1
	GLdouble	v2
	CODE:
	{
		int count = items-6;
		GLint vorder = (count / uorder) / gl_map_count(target, GL_COEFF);
		GLdouble * points = malloc(sizeof(GLdouble) * (count+1));
		int i;
		for (i=0;i<count;i++)
			points[i] = SvNV(ST(i+6));
		glMap2d(target, u1, u2, 0, uorder, v1, v2, 0, vorder, points);
		free(points);
	}

#// 1.0
#//# glMap2f_p($target, $u1, $u2, $uorder, $v1, $v2, @points);
#//- Assumes 0 ustride and vstride
void
glMap2f_p(target, u1, u2, uorder, v1, v2, ...)
	GLenum	target
	GLfloat	u1
	GLfloat	u2
	GLint	uorder
	GLfloat	v1
	GLfloat	v2
	CODE:
	{
		int count = items-6;
		GLint vorder = (count / uorder) / gl_map_count(target, GL_COEFF);
		GLfloat * points = malloc(sizeof(GLfloat) * (count+1));
		int i;
		for (i=0;i<count;i++)
			points[i] = (GLfloat)SvNV(ST(i+6));
		glMap2f(target, u1, u2, 0, uorder, v1, v2, 0, vorder, points);
		free(points);
	}

#// 1.0
#//# glMapGrid1d($un, $u1, $u2);
void
glMapGrid1d(un, u1, u2)
	GLint	un
	GLdouble	u1
	GLdouble	u2

#// 1.0
#//# glMapGrid1f($un, $u1, $u2);
void
glMapGrid1f(un, u1, u2)
	GLint	un
	GLfloat	u1
	GLfloat	u2

#// 1.0
#//# glMapGrid2d($un, $u1, $u2, $vn, $v1, $v2);
void
glMapGrid2d(un, u1, u2, vn, v1, v2)
	GLint	un
	GLdouble	u1
	GLdouble	u2
	GLint	vn
	GLdouble	v1
	GLdouble	v2

#// 1.0
#//# glMapGrid2f($un, $u1, $u2, $vn, $v1, $v2);
void
glMapGrid2f(un, u1, u2, vn, v1, v2)
	GLint	un
	GLfloat	u1
	GLfloat	u2
	GLint	vn
	GLfloat	v1
	GLfloat	v2

#// 1.0
#//# glMaterialf($face, $pname, $param);
void
glMaterialf(face, pname, param)
	GLenum	face
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glMateriali($face, $pname, $param);
void
glMateriali(face, pname, param)
	GLenum	face
	GLenum	pname
	GLint	param

#// 1.0
#//# glMaterialfv_c($face, $pname, (CPTR)param);
void
glMaterialfv_c(face, pname, param)
	GLenum	face
	GLenum	pname
	void *	param
	CODE:
	glMaterialfv(face, pname, param);

#// 1.0
#//# glMaterialiv_c($face, $pname, (CPTR)param);
void
glMaterialiv_c(face, pname, param)
	GLenum	face
	GLenum	pname
	void *	param
	CODE:
	glMaterialiv(face, pname, param);

#// 1.0
#//# glMaterialfv_s($face, $pname, (PACKED)param);
void
glMaterialfv_s(face, pname, param)
	GLenum	face
	GLenum	pname
	SV *	param
	CODE:
	{
	GLfloat * param_s = EL(param, sizeof(GLfloat)*gl_material_count(pname));
	glMaterialfv(face, pname, param_s);
	}

#// 1.0
#//# glMaterialiv_s($face, $pname, (PACKED)param);
void
glMaterialiv_s(face, pname, param)
	GLenum	face
	GLenum	pname
	SV *	param
	CODE:
	{
	GLint * param_s = EL(param, sizeof(GLint)*gl_material_count(pname));
	glMaterialiv(face, pname, param_s);
	}

#// 1.0
#//# glMaterialfv_s($face, $pname, @param);
void
glMaterialfv_p(face, pname, ...)
	GLenum	face
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_MATERIAL_COUNT];
		int i;
		if ((items-2) != gl_material_count(pname))
			croak("Incorrect number of arguments");
		for(i=2;i<items;i++)
			p[i-2] = (GLfloat)SvNV(ST(i));
		glMaterialfv(face, pname, &p[0]);
	}

#// 1.0
#//# glMaterialiv_s($face, $pname, @param);
void
glMaterialiv_p(face, pname, ...)
	GLenum	face
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_MATERIAL_COUNT];
		int i;
		if ((items-2) != gl_material_count(pname))
			croak("Incorrect number of arguments");
		for(i=2;i<items;i++)
			p[i-2] = SvIV(ST(i));
		glMaterialiv(face, pname, &p[0]);
	}

#// 1.0
#//# glMatrixMode($mode);
void
glMatrixMode(mode)
	GLenum	mode

#// 1.0
#//# glMultMatrixd_p(@m);
void
glMultMatrixd_p(...)
	CODE:
	{
		GLdouble m[16];
		int i;
		if (items != 16)
			croak("Incorrect number of arguments");
		for (i=0;i<16;i++)
			m[i] = SvNV(ST(i));
		glMultMatrixd(&m[0]);
	}

#// 1.0
#//# glMultMatrixf_p(@m);
void
glMultMatrixf_p(...)
	CODE:
	{
		GLfloat m[16];
		int i;
		if (items != 16)
			croak("Incorrect number of arguments");
		for (i=0;i<16;i++)
			m[i] = (GLfloat)SvNV(ST(i));
		glMultMatrixf(&m[0]);
	}

#// 1.0
#//# glNewList($list, $mode);
void
glNewList(list, mode)
	GLuint	list
	GLenum	mode

#// 1.0
#//# glEndList();
void
glEndList()

#ifdef GL_VERSION_1_1

#// 1.1
#//# glNormalPointer_c($type, $stride, (CPTR)pointer);
void
glNormalPointer_c(type, stride, pointer)
	GLenum	type
	GLsizei	stride
	void *	pointer
	CODE:
	glNormalPointer(type, stride, pointer);


#//# glNormalPointer_s($type, $stride, (PACKED)pointer);
void
glNormalPointer_s(type, stride, pointer)
	GLenum	type
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*3);
		void * pointer_s = EL(pointer, width);
		glNormalPointer(type, stride, pointer_s);
	}

#//# glNormalPointer_s($type, $stride, (OGA)pointer);
void
glNormalPointer_p(oga)
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glNormalPointer(oga->types[0], 0, oga->bind ? 0 : oga->data);
#else
		glNormalPointer(oga->types[0], 0, oga->data);
#endif
	}

#endif

#// 1.0
#//# glOrtho($left, $right, $bottom, $top, $zNear, $zFar);
void
glOrtho(left, right, bottom, top, zNear, zFar)
	GLdouble	left
	GLdouble	right
	GLdouble	bottom
	GLdouble	top
	GLdouble	zNear
	GLdouble	zFar

#// 1.0
#//# glPassThrough($token);
void
glPassThrough(token)
	GLfloat	token

#// 1.0
#//# glPixelMapfv_c($map, $mapsize, (CPTR)values);
void
glPixelMapfv_c(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	void *	values
	CODE:
	glPixelMapfv(map, mapsize, values);

#// 1.0
#//# glPixelMapuiv_c($map, $mapsize, (CPTR)values);
void
glPixelMapuiv_c(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	void *	values
	CODE:
	glPixelMapuiv(map, mapsize, values);

#// 1.0
#//# glPixelMapusv_c($map, $mapsize, (CPTR)values);
void
glPixelMapusv_c(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	void *	values
	CODE:
	glPixelMapusv(map, mapsize, values);

#// 1.0
#//# glPixelMapfv_s($map, $mapsize, (PACKED)values);
void
glPixelMapfv_s(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	SV *	values
	CODE:
	{
	GLfloat * values_s = EL(values, sizeof(GLfloat)*mapsize);
	glPixelMapfv(map, mapsize, values_s);
	}

#// 1.0
#//# glPixelMapuiv_s($map, $mapsize, (PACKED)values);
void
glPixelMapuiv_s(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	SV *	values
	CODE:
	{
	GLuint * values_s = EL(values, sizeof(GLuint)*mapsize);
	glPixelMapuiv(map, mapsize, values_s);
	}

#// 1.0
#//# glPixelMapusv_s($map, $mapsize, (PACKED)values);
void
glPixelMapusv_s(map, mapsize, values)
	GLenum	map
	GLsizei	mapsize
	SV *	values
	CODE:
	{
	GLushort * values_s = EL(values, sizeof(GLushort)*mapsize);
	glPixelMapusv(map, mapsize, values_s);
	}

#// 1.0
#//# glPixelMapfv_p($map, @values);
void
glPixelMapfv_p(map, ...)
	GLenum	map
	CODE:
	{
		GLint mapsize = items-1;
		GLfloat * values;
		int i;
		values = malloc(sizeof(GLfloat) * (mapsize+1));
		for (i=0;i<mapsize;i++)
			values[i] = (GLfloat)SvNV(ST(i+1));
		glPixelMapfv(map, mapsize, values);
		free(values);
	}

#// 1.0
#//# glPixelMapuiv_p($map, @values);
void
glPixelMapuiv_p(map, ...)
	GLenum	map
	CODE:
	{
		GLint mapsize = items-1;
		GLuint * values;
		int i;
		values = malloc(sizeof(GLuint) * (mapsize+1));
		for (i=0;i<mapsize;i++)
			values[i] = SvIV(ST(i+1));
		glPixelMapuiv(map, mapsize, values);
		free(values);
	}

#// 1.0
#//# glPixelMapusv_p($map, @values);
void
glPixelMapusv_p(map, ...)
	GLenum	map
	CODE:
	{
		GLint mapsize = items-1;
		GLushort * values;
		int i;
		values = malloc(sizeof(GLushort) * (mapsize+1));
		for (i=0;i<mapsize;i++)
			values[i] = (GLushort)SvIV(ST(i+1));
		glPixelMapusv(map, mapsize, values);
		free(values);
	}

#// 1.0
#//# glPixelStoref($pname, $param);
void
glPixelStoref(pname, param)
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glPixelStorei($pname, $param);
void
glPixelStorei(pname, param)
	GLenum	pname
	GLint	param

#// 1.0
#//# glPixelTransferf($pname, $param);
void
glPixelTransferf(pname, param)
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glPixelTransferi($pname, $param);
void
glPixelTransferi(pname, param)
	GLenum	pname
	GLint	param

#// 1.0
#//# glPixelZoom($xfactor, $yfactor);
void
glPixelZoom(xfactor, yfactor)
	GLfloat	xfactor
	GLfloat	yfactor

#// 1.0
#//# glPointSize($size);
void
glPointSize(size)
	GLfloat	size

#// 1.0
#//# glPolygonMode($face, $mode);
void
glPolygonMode(face, mode)
	GLenum	face
	GLenum	mode

#ifdef GL_VERSION_1_1

#// 1.1
#//# glPolygonOffset($factor, $units);
void
glPolygonOffset(factor, units)
	GLfloat	factor
	GLfloat	units

#endif

#// 1.0
#//# glPolygonStipple_c((CPTR)mask);
void
glPolygonStipple_c(mask)
	void *	mask
	CODE:
	glPolygonStipple(mask);

#// 1.0
#//# glPolygonStipple_s((PACKED)mask);
void
glPolygonStipple_s(mask)
	SV *	mask
	CODE:
	{
	GLubyte * ptr = ELI(mask, 32, 32, GL_COLOR_INDEX, GL_BITMAP, 0);
	glPolygonStipple(ptr);
	}

#//# glPolygonStipple_p(@mask);
void
glPolygonStipple_p(...)
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(0)), items, 32, 32, 1,
		GL_COLOR_INDEX, GL_BITMAP, 0);
	glPolygonStipple(ptr);
	glPopClientAttrib();
	free(ptr);
	}

#ifdef GL_VERSION_1_1

#// 1.1
#//# glPrioritizeTextures_c($n, (CPTR)textures, (CPTR)priorities);
void
glPrioritizeTextures_c(n, textures, priorities)
	GLsizei	n
	void *	textures
	void *	priorities
	CODE:
	glPrioritizeTextures(n, textures, priorities);

#// 1.1
#//# glPrioritizeTextures_s($n, (PACKED)textures, (PACKED)priorities);
void
glPrioritizeTextures_s(n, textures, priorities)
	GLsizei	n
	SV *	textures
	SV *	priorities
	CODE:
	{
	GLuint * textures_s = EL(textures, sizeof(GLuint) * n);
	GLclampf * priorities_s = EL(priorities, sizeof(GLclampf) * n);
	glPrioritizeTextures(n, textures_s, priorities_s);
	}

#// 1.1
#//# glPrioritizeTextures_p(@textureIDs, @priorities);
void
glPrioritizeTextures_p(...)
	CODE:
	{
		GLsizei n = items/2;
		GLuint * textures = malloc(sizeof(GLuint) * (n+1));
		GLclampf * prior = malloc(sizeof(GLclampf) * (n+1));
		int i;
		
		for (i=0;i<n;i++) {
			textures[i] = SvIV(ST(i * 2 + 0));
			prior[i] = (GLclampf)SvNV(ST(i * 2 + 1));
		}
		
		glPrioritizeTextures(n, textures, prior);
		
		free(textures);
		free(prior);
	}

#endif



#// 1.0
#//# glPushAttrib($mask);
void
glPushAttrib(mask)
	GLbitfield	mask

#// 1.0
#//# glPopAttrib();
void
glPopAttrib()

#// 1.0
#//# glPushClientAttrib($mask);
void
glPushClientAttrib(mask)
	GLbitfield	mask

#// 1.0
#//# glPopClientAttrib();
void
glPopClientAttrib()

#// 1.0
#//# glPushMatrix();
void
glPushMatrix()

#// 1.0
#//# glPopMatrix();
void
glPopMatrix()

#// 1.0
#//# glPushName($name);
void
glPushName(name)
	GLuint	name

#// 1.0
#//# glPopName();
void
glPopName()


#// 1.0
#//# glReadBuffer($mode);
void
glReadBuffer(mode)
	GLenum	mode

#// 1.0
#//# glReadPixels_c($x, $y, $width, $height, $format, $type, (CPTR)pixels);
void
glReadPixels_c(x, y, width, height, format, type, pixels)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glReadPixels(x, y, width, height, format, type, pixels);

#// 1.0
#//# glReadPixels_s($x, $y, $width, $height, $format, $type, (PACKED)pixels);
void
glReadPixels_s(x, y, width, height, format, type, pixels)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
		void * ptr = ELI(pixels, width, height,
			format, type, gl_pixelbuffer_pack);
		glReadPixels(x, y, width, height, format, type, ptr);
	}

#// 1.0
#//# @pixels = glReadPixels_p($x, $y, $width, $height, $format, $type);
void
glReadPixels_p(x, y, width, height, format, type)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	PPCODE:
	{
		void * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_PACK_ROW_LENGTH, 0);
		glPixelStorei(GL_PACK_ALIGNMENT, 1);
		ptr = allocate_image_ST(width, height, 1, format, type, 0);
		glReadPixels(x, y, width, height, format, type, ptr);
		sp = unpack_image_ST(sp, ptr, width, height, 1, format, type, 0);
		free(ptr);
		glPopClientAttrib();
	}

#// 1.0
#//# glRecti($x1, $y1, $x2, $y2);
void
glRecti(x1, y1, x2, y2)
	GLint	x1
	GLint	y1
	GLint	x2
	GLint	y2
	ALIAS:
		glRectiv_p = 1


#// 1.0
#//# glRects($x1, $y1, $x2, $y2);
void
glRects(x1, y1, x2, y2)
	GLshort	x1
	GLshort	y1
	GLshort	x2
	GLshort	y2
	ALIAS:
		glRectsv_p = 1

#// 1.0
#//# glRectd($x1, $y1, $x2, $y2);
void
glRectd(x1, y1, x2, y2)
	GLdouble	x1
	GLdouble	y1
	GLdouble	x2
	GLdouble	y2
	ALIAS:
		glRectdv_p = 1

#// 1.0
#//# glRectf($x1, $y1, $x2, $y2);
void
glRectf(x1, y1, x2, y2)
	GLfloat	x1
	GLfloat	y1
	GLfloat	x2
	GLfloat	y2
	ALIAS:
		glRectfv_p = 1


#// 1.0
#//# glRectsv_c((CPTR)v1, (CPTR)v2);
void
glRectsv_c(v1, v2)
	void *	v1
	void *	v2
	CODE:
	glRectsv(v1, v2);

#// 1.0
#//# glRectiv_c((CPTR)v1, (CPTR)v2);
void
glRectiv_c(v1, v2)
	void *	v1
	void *	v2
	CODE:
	glRectiv(v1, v2);

#// 1.0
#//# glRectfv_c((CPTR)v1, (CPTR)v2);
void
glRectfv_c(v1, v2)
	void *	v1
	void *	v2
	CODE:
	glRectfv(v1, v2);

#// 1.0
#//# glRectdv_c((CPTR)v1, (CPTR)v2);
void
glRectdv_c(v1, v2)
	void *	v1
	void *	v2
	CODE:
	glRectdv(v1, v2);

#// 1.0
#//# glRectdv_s((PACKED)v1, (PACKED)v2);
void
glRectdv_s(v1, v2)
	SV *	v1
	SV *	v2
	CODE:
	{
	GLdouble * v1_s = EL(v1, sizeof(GLdouble)*2);
	GLdouble * v2_s = EL(v2, sizeof(GLdouble)*2);
	glRectdv(v1_s, v2_s);
	}

#// 1.0
#//# glRectfv_s((PACKED)v1, (PACKED)v2);
void
glRectfv_s(v1, v2)
	SV *	v1
	SV *	v2
	CODE:
	{
	GLfloat * v1_s = EL(v1, sizeof(GLfloat)*2);
	GLfloat * v2_s = EL(v2, sizeof(GLfloat)*2);
	glRectfv(v1_s, v2_s);
	}

#// 1.0
#//# glRectiv_s((PACKED)v1, (PACKED)v2);
void
glRectiv_s(v1, v2)
	SV *	v1
	SV *	v2
	CODE:
	{
	GLint * v1_s = EL(v1, sizeof(GLint)*2);
	GLint * v2_s = EL(v2, sizeof(GLint)*2);
	glRectiv(v1_s, v2_s);
	}

#// 1.0
#//# glRectsv_s((PACKED)v1, (PACKED)v2);
void
glRectsv_s(v1, v2)
	SV *	v1
	SV *	v2
	CODE:
	{
	GLshort * v1_s = EL(v1, sizeof(GLshort)*2);
	GLshort * v2_s = EL(v2, sizeof(GLshort)*2);
	glRectsv(v1_s, v2_s);
	}

#// 1.0
#//# glRenderMode($mode);
GLint
glRenderMode(mode)
	GLenum	mode

#// 1.0
#//# glRotated($angle, $x, $y, $z);
void
glRotated(angle, x, y, z)
	GLdouble	angle
	GLdouble	x
	GLdouble	y
	GLdouble	z

#// 1.0
#//# glRotatef($angle, $x, $y, $z);
void
glRotatef(angle, x, y, z)
	GLfloat	angle
	GLfloat	x
	GLfloat	y
	GLfloat	z

#// 1.0
#//# glScaled($x, $y, $z);
void
glScaled(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z

#// 1.0
#//# glScalef($x, $y, $z);
void
glScalef(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z

#// 1.0
#//# glScissor($x, $y, $width, $height);
void
glScissor(x, y, width, height)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height

#// 1.0
#//# glSelectBuffer_c($size, (CPTR)list);
void
glSelectBuffer_c(size, list)
	GLsizei	size
	void *	list
	CODE:
	glSelectBuffer(size, list);

#// 1.0
#//# glShadeModel($mode);
void
glShadeModel(mode)
	GLenum	mode

#// 1.0
#//# glStencilFunc($func, $ref, $mask);
void
glStencilFunc(func, ref, mask)
	GLenum	func
	GLint	ref
	GLuint	mask

#// 1.0
#//# glStencilMask($mask);
void
glStencilMask(mask)
	GLuint	mask

#// 1.0
#//# glStencilOp($fail, $zfail, $zpass);
void
glStencilOp(fail, zfail, zpass)
	GLenum	fail
	GLenum	zfail
	GLenum	zpass


#ifdef GL_VERSION_1_1

#// 1.1
#//# glTexCoordPointer_c($size, $type, $stride, (CPTR)pointer);
void
glTexCoordPointer_c(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	void *	pointer
	CODE:
	glTexCoordPointer(size, type, stride, pointer);

#//# glTexCoordPointer_s($size, $type, $stride, (PACKED)pointer);
void
glTexCoordPointer_s(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*size);
		void * pointer_s = EL(pointer, width);
		glTexCoordPointer(size, type, stride, pointer_s);
	}

#//# glTexCoordPointer_p($size, (OGA)pointer);
void
glTexCoordPointer_p(size, oga)
	GLint	size
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glTexCoordPointer(size, oga->types[0], 0, oga->bind ? 0 : oga->data);
#else
		glTexCoordPointer(size, oga->types[0], 0, oga->data);
#endif
	}

#endif

#// 1.0
#//# glTexEnvf($target, $pname, $param);
void
glTexEnvf(target, pname, param)
	GLenum	target
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glTexEnvi($target, $pname, $param);
void
glTexEnvi(target, pname, param)
	GLenum	target
	GLenum	pname
	GLint	param

#// 1.0
#//# glTexEnvfv_s(target, pname, (PACKED)params);
void
glTexEnvfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params, sizeof(GLfloat)*gl_texenv_count(pname));
	glTexEnvfv(target, pname, params_s);
	}

#// 1.0
#//# glTexEnviv_s(target, pname, (PACKED)params);
void
glTexEnviv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params, sizeof(GLint)*gl_texenv_count(pname));
	glTexEnviv(target, pname, params_s);
	}

#// 1.0
#//# glTexEnvfv_p(target, pname, @params);
void
glTexEnvfv_p(target, pname, ...)
	GLenum	target
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_TEXENV_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texenv_count(pname))
			croak("Incorrect number of arguments");
		for (i=2;i<items;i++)
			p[i-2] = (GLfloat)SvNV(ST(i));
		glTexEnvfv(target, pname, &p[0]);
	}

#// 1.0
#//# glTexEnviv_p(target, pname, @params);
void
glTexEnviv_p(target, pname, ...)
	GLenum	target
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_TEXENV_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texenv_count(pname))
			croak("Incorrect number of arguments");
		for (i=2;i<items;i++)
			p[i-2] = SvIV(ST(i));
		glTexEnviv(target, pname, &p[0]);
	}

#// 1.0
#//# glTexGend($Coord, $pname, $param);
void
glTexGend(Coord, pname, param)
	GLenum	Coord
	GLenum	pname
	GLdouble	param

#// 1.0
#//# glTexGenf($Coord, $pname, $param);
void
glTexGenf(Coord, pname, param)
	GLenum	Coord
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glTexGeni($Coord, $pname, $param);
void
glTexGeni(Coord, pname, param)
	GLenum	Coord
	GLenum	pname
	GLint	param

#// 1.0
#//# glTexGendv_c($Coord, $pname, (CPTR)params);
void
glTexGendv_c(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	void *	params
	CODE:
	glTexGendv(Coord, pname, params);

#// 1.0
#//# glTexGenfv_c($Coord, $pname, (CPTR)params);
void
glTexGenfv_c(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	void *	params
	CODE:
	glTexGenfv(Coord, pname, params);

#// 1.0
#//# glTexGeniv_c($Coord, $pname, (CPTR)params);
void
glTexGeniv_c(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	void *	params
	CODE:
	glTexGeniv(Coord, pname, params);

#// 1.0
#//# glTexGendv_s($Coord, $pname, (PACKED)params);
void
glTexGendv_s(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLdouble * params_s = EL(params,
		sizeof(GLdouble)* gl_texgen_count(pname));
	glTexGendv(Coord, pname, params_s);
	}

#// 1.0
#//# glTexGenfv_s($Coord, $pname, (PACKED)params);
void
glTexGenfv_s(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params,
		sizeof(GLfloat)* gl_texgen_count(pname));
	glTexGenfv(Coord, pname, params_s);
	}

#// 1.0
#//# glTexGeniv_s($Coord, $pname, (PACKED)params);
void
glTexGeniv_s(Coord, pname, params)
	GLenum	Coord
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params,
		sizeof(GLint)* gl_texgen_count(pname));
	glTexGeniv(Coord, pname, params_s);
	}

#// 1.0
#//# glTexGendv_p($Coord, $pname, @params);
void
glTexGendv_p(Coord, pname, ...)
	GLenum	Coord
	GLenum	pname
	CODE:
	{
		GLdouble p[MAX_GL_TEXGEN_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texgen_count(pname))
			croak("Incorrect number of arguments");
		for (i=2;i<items;i++)
			p[i-2] = SvNV(ST(i));
		glTexGendv(Coord, pname, &p[0]);
	}

#// 1.0
#//# glTexGenfv_p($Coord, $pname, @params);
void
glTexGenfv_p(Coord, pname, ...)
	GLenum	Coord
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_TEXGEN_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texgen_count(pname))
			croak("Incorrect number of arguments");
		for (i=2;i<items;i++)
			p[i-2] = (GLfloat)SvNV(ST(i));
		glTexGenfv(Coord, pname, &p[0]);
	}

#// 1.0
#//# glTexGeniv_p($Coord, $pname, @params);
void
glTexGeniv_p(Coord, pname, ...)
	GLenum	Coord
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_TEXGEN_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texgen_count(pname))
			croak("Incorrect number of arguments");
		for (i=2;i<items;i++)
			p[i-2] = SvIV(ST(i));
		glTexGeniv(Coord, pname, &p[0]);
	}

#// 1.0
#//# glTexImage1D_c($target, $level, $internalformat, $width, $border, $format, $type, (CPTR)pixels);
void
glTexImage1D_c(target, level, internalformat, width, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLint	border
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glTexImage1D(target, level, internalformat,
		width, border, format, type, pixels);

#// 1.0
#//# glTexImage1D_s($target, $level, $internalformat, $width, $border, $format, $type, (PACKED)pixels);
void
glTexImage1D_s(target, level, internalformat, width, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLint	border
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
	GLvoid * ptr = ELI(pixels, width, 1, format, type,
		gl_pixelbuffer_unpack);
	glTexImage1D(target, level, internalformat,
		width, border, format, type, ptr);
	}

#// 1.2
#//# glTexImage1D_p($target, $level, $internalformat, $width, $border, $format, $type, @pixels);
void
glTexImage1D_p(target, level, internalformat, width, border, format, type, ...)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLint	border
	GLenum	format
	GLenum	type
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(7)), items-7, width, 1, 1, format, type, 0);
	glTexImage1D(target, level, internalformat,
		width, border, format, type, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#// 1.0
#//# glTexImage2D_c($target, $level, $internalformat, $width, $height, $border, $format, $type, (CPTR)pixels);
void
glTexImage2D_c(target, level, internalformat, width, height, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLint	border
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glTexImage2D(target, level, internalformat,
		width, height, border, format, type, pixels);

#// 1.0
#//# glTexImage2D_s($target, $level, $internalformat, $width, $height, $border, $format, $type, (PACKED)pixels);
void
glTexImage2D_s(target, level, internalformat, width, height, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLint	border
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
		GLvoid * ptr = NULL;
		if (pixels)
		{
			ptr = ELI(pixels, width, height,
				format, type, gl_pixelbuffer_unpack);
		}
		glTexImage2D(target, level, internalformat,
			width, height, border, format, type, ptr);
	}

#// 1.2
#//# glTexImage2D_p($target, $level, $internalformat, $width, $height, $border, $format, $type, @pixels);
void
glTexImage2D_p(target, level, internalformat, width, height, border, format, type, ...)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLint	border
	GLenum	format
	GLenum	type
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(8)), items-8, width, height,
		1, format, type, 0);
	glTexImage2D(target, level, internalformat,
		width, height, border, format, type, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#ifdef GL_VERSION_1_2

#// 1.2
#//# glTexImage3D_c($target, $level, $internalformat, $width, $height, $depth, $border, $format, $type, (CPTR)pixels);
void
glTexImage3D_c(target, level, internalformat, width, height, depth, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLint	border
	GLenum	format
	GLenum	type
	void *	pixels
	INIT:
		loadProc(glTexImage3D,"glTexImage3D");
	CODE:
		glTexImage3D(target, level, internalformat,
			width, height, depth, border, format, type, pixels);

#// 1.2
#//# glTexImage3D_s($target, $level, $internalformat, $width, $height, $depth, $border, $format, $type, (PACKED)pixels);
void
glTexImage3D_s(target, level, internalformat, width, height, depth, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLint	border
	GLenum	format
	GLenum	type
	SV *	pixels
	INIT:
		loadProc(glTexImage3D,"glTexImage3D");
	CODE:
	{
		GLvoid * ptr = ELI(pixels, width, height, format,
			type, gl_pixelbuffer_unpack);
		glTexImage3D(target, level, internalformat,
			width, height, depth, border, format, type, ptr);
	}

#// 1.2
#//# glTexImage3D_p($target, $level, $internalformat, $width, $height, $depth, $border, $format, $type, @pixels);
void
glTexImage3D_p(target, level, internalformat, width, height, depth, border, format, type, ...)
	GLenum	target
	GLint	level
	GLint	internalformat
	GLsizei	width
	GLsizei	height
	GLsizei	depth
	GLint	border
	GLenum	format
	GLenum	type
	INIT:
		loadProc(glTexImage3D,"glTexImage3D");
	CODE:
	{
		GLvoid * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		ptr = pack_image_ST(&(ST(9)), items-9, width, height,
			depth, format, type, 0);
		glTexImage3D(target, level, internalformat,
			width, height, depth, border, format, type, ptr);
		glPopClientAttrib();
		free(ptr);
	}

#endif

#// 1.0
#//# glTexParameterf($target, $pname, $param);
void
glTexParameterf(target, pname, param)
	GLenum	target
	GLenum	pname
	GLfloat	param

#// 1.0
#//# glTexParameteri($target, $pname, $param);
void
glTexParameteri(target, pname, param)
	GLenum	target
	GLenum	pname
	GLint	param

#// 1.0
#//# glTexParameterfv_c($target, $pname, (CPTR)params);
void
glTexParameterfv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void *	params
	CODE:
	glTexParameterfv(target, pname, params);

#// 1.0
#//# glTexParameteriv_c($target, $pname, (CPTR)params);
void
glTexParameteriv_c(target, pname, params)
	GLenum	target
	GLenum	pname
	void *	params
	CODE:
	glTexParameteriv(target, pname, params);

#// 1.0
#//# glTexParameterfv_s($target, $pname, (PACKED)params);
void
glTexParameterfv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLfloat * params_s = EL(params,
		sizeof(GLfloat)*gl_texparameter_count(pname));
	glTexParameterfv(target, pname, params_s);
	}

#// 1.0
#//# glTexParameteriv_s($target, $pname, (PACKED)params);
void
glTexParameteriv_s(target, pname, params)
	GLenum	target
	GLenum	pname
	SV *	params
	CODE:
	{
	GLint * params_s = EL(params,
		sizeof(GLint)*gl_texparameter_count(pname));
	glTexParameteriv(target, pname, params_s);
	}

#// 1.0
#//# glTexParameterfv_p($target, $pname, @params);
void
glTexParameterfv_p(target, pname, ...)
	GLenum	target
	GLenum	pname
	CODE:
	{
		GLfloat p[MAX_GL_TEXPARAMETER_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texparameter_count(pname))
			croak("Incorrect number of arguments");
		for(i=0;i<n;i++)
			p[i] = (GLfloat)SvNV(ST(i+2));
		glTexParameterfv(target, pname, &p[0]);
	}

#// 1.0
#//# glTexParameteriv_p($target, $pname, @params);
void
glTexParameteriv_p(target, pname, ...)
	GLenum	target
	GLenum	pname
	CODE:
	{
		GLint p[MAX_GL_TEXPARAMETER_COUNT];
		int n = items-2;
		int i;
		if (n != gl_texparameter_count(pname))
			croak("Incorrect number of arguments");
		for(i=0;i<n;i++)
			p[i] = SvIV(ST(i+2));
		glTexParameteriv(target, pname, &p[0]);
	}

#ifdef GL_VERSION_1_1

#// 1.1
#//# glTexSubImage1D_c($target, $level, $xoffset, $width, $border, $format, $type, (CPTR)pixels);
void
glTexSubImage1D_c(target, level, xoffset, width, border, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glTexSubImage1D(target, level, xoffset, width, format, type, pixels);

#// 1.1
#//# glTexSubImage1D_s($target, $level, $xoffset, $width, $border, $format, $type, (PACKED)pixels);
void
glTexSubImage1D_s(target, level, xoffset, width, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
	GLvoid * ptr = ELI(pixels, width, 1, format, type, gl_pixelbuffer_unpack);
	glTexSubImage1D(target, level, xoffset, width, format, type, ptr);
	}

#// 1.1
#//# glTexSubImage1D_p($target, $level, $xoffset, $width, $border, $format, $type, @pixels);
void
glTexSubImage1D_p(target, level, xoffset, width, format, type, ...)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(7)), items-7, width, 1, 1, format, type, 0);
	glTexSubImage1D(target, level, xoffset, width, format, type, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#// 1.1
#//# glTexSubImage2D_c($target, $level, $xoffset, $yoffset, $width, $height, $border, $format, $type, (CPTR)pixels);
void
glTexSubImage2D_c(target, level, xoffset, yoffset, width, height, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	void *	pixels
	CODE:
	glTexSubImage2D(target, level, xoffset, yoffset,
		width, height, format, type, pixels);

#// 1.1
#//# glTexSubImage2D_s($target, $level, $xoffset, $yoffset, $width, $height, $border, $format, $type, (PACKED)pixels);
void
glTexSubImage2D_s(target, level, xoffset, yoffset, width, height, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	SV *	pixels
	CODE:
	{
	GLvoid * ptr = ELI(pixels, width, height,
		format, type, gl_pixelbuffer_unpack);
	glTexSubImage2D(target, level, xoffset, yoffset,
		width, height, format, type, ptr);
	}

#// 1.1
#//# glTexSubImage2D_c($target, $level, $xoffset, $yoffset, $width, $height, $border, $format, $type, @pixels);
void
glTexSubImage2D_p(target, level, xoffset, yoffset, width, height, format, type, ...)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	CODE:
	{
	GLvoid * ptr;
	glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	ptr = pack_image_ST(&(ST(8)), items-8, width, height, 1,
		format, type, 0);
	glTexSubImage2D(target, level, xoffset, yoffset,
		width, height, format, type, ptr);
	glPopClientAttrib();
	free(ptr);
	}

#ifdef GL_VERSION_1_2

#// 1.2
#//# glTexSubImage3D_c($target, $level, $xoffset, $yoffset, $zoffset, $width, $height, $depth, $border, $format, $type, (CPTR)pixels);
void
glTexSubImage3D_c(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels)
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
		loadProc(glTexSubImage3D,"glTexSubImage3D");
	CODE:
		glTexSubImage3D(target, level, xoffset, yoffset, zoffset,
			width, height, depth, format, type, pixels);

#// 1.2
#//# glTexSubImage3D_s($target, $level, $xoffset, $yoffset, $zoffset, $width, $height, $depth, $border, $format, $type, (PACKED)pixels);
void
glTexSubImage3D_s(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels)
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
		loadProc(glTexSubImage3D,"glTexSubImage3D");
	CODE:
	{
		GLvoid * ptr = ELI(pixels, width, height,
			format, type, gl_pixelbuffer_unpack);
		glTexSubImage3D(target, level, xoffset, yoffset, zoffset,
			width, height, depth, format, type, ptr);
	}

#// 1.1
#//# glTexSubImage3D_p($target, $level, $xoffset, $yoffset, $zoffset, $width, $height, $depth, $border, $format, $type, @pixels);
void
glTexSubImage3D_p(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, ...)
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
		loadProc(glTexSubImage3D,"glTexSubImage3D");
	CODE:
	{
		GLvoid * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		ptr = pack_image_ST(&(ST(10)), items-10, width, height,
			depth, format, type, 0);
		glTexSubImage3D(target, level, xoffset, yoffset, zoffset,
			width, height, depth, format, type, ptr);
		glPopClientAttrib();
		free(ptr);
	}

#endif

#endif

#// 1.0
#//# glTranslated($x, $y, $z);
void
glTranslated(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z

#// 1.0
#//# glTranslatef($x, $y, $z);
void
glTranslatef(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z


#ifdef GL_VERSION_1_1

#// 1.1
#//# glVertexPointer_c($size, $type, $stride, (CPTR)pointer);
void
glVertexPointer_c(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	void *	pointer
	CODE:
		glVertexPointer(size, type, stride, pointer);

#//# glVertexPointer_s($size, $type, $stride, (PACKED)pointer);
void
glVertexPointer_s(size, type, stride, pointer)
	GLint	size
	GLenum	type
	GLsizei	stride
	SV *	pointer
	CODE:
	{
		int width = stride ? stride : (sizeof(type)*size);
		void * pointer_s = EL(pointer, width);
		glVertexPointer(size, type, stride, pointer_s);
	}

#//# glVertexPointer_p($size, $type, $stride, (OGA)pointer);
void
glVertexPointer_p(size, oga)
	GLint	size
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
	CODE:
	{
#ifdef GL_ARB_vertex_buffer_object
		if (testProc(glBindBufferARB,"glBindBufferARB"))
		{
			glBindBufferARB(GL_ARRAY_BUFFER_ARB, oga->bind);
		}
		glVertexPointer(size, oga->types[0], 0, oga->bind ? 0 : oga->data);
#else
		glVertexPointer(size, oga->types[0], 0, oga->data);
#endif
	}

#endif

#// 1.0
#//# glViewport($x, $y, $width, $height);
void
glViewport(x, y, width, height)
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height

# Generated declarations

#//# glVertex2d($x, $y);
void
glVertex2d(x, y)
	GLdouble	x
	GLdouble	y

#//# glVertex2dv_c((CPTR)v);
void
glVertex2dv_c(v)
	void *	v
	CODE:
	glVertex2dv(v);

#//# glVertex2dv_s((PACKED)v);
void
glVertex2dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glVertex2dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex2d
#//# glVertex2dv_p($x, $y);
void
glVertex2dv_p(x, y)
	GLdouble	x
	GLdouble	y
	CODE:
	{
		GLdouble param[2];
		param[0] = x;
		param[1] = y;
		glVertex2dv(param);
	}

#//# glVertex2f($x, $y);
void
glVertex2f(x, y)
	GLfloat	x
	GLfloat	y

#//# glVertex2f_s((PACKED)v);
void
glVertex2fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*2);
		glVertex2fv(v_s);
	}

#//# glVertex2f_s((CPTR)v);
void
glVertex2fv_c(v)
	void *	v
	CODE:
	glVertex2fv(v);

#//!!! Do we really need this?  It duplicates glVertex2f
#//# glVertex2fv_p($x, $y);
void
glVertex2fv_p(x, y)
	GLfloat	x
	GLfloat	y
	CODE:
	{
		GLfloat param[2];
		param[0] = x;
		param[1] = y;
		glVertex2fv(param);
	}

#//# glVertex2i($x, $y);
void
glVertex2i(x, y)
	GLint	x
	GLint	y

#//# glVertex2iv_c((CPTR)v);
void
glVertex2iv_c(v)
	void *	v
	CODE:
	glVertex2iv(v);

#//# glVertex2iv_s((PACKED)v);
void
glVertex2iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*2);
		glVertex2iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex2i
#//# glVertex2iv_p($x, $y);
void
glVertex2iv_p(x, y)
	GLint	x
	GLint	y
	CODE:
	{
		GLint param[2];
		param[0] = x;
		param[1] = y;
		glVertex2iv(param);
	}

#//# glVertex2s($x, $y);
void
glVertex2s(x, y)
	GLshort	x
	GLshort	y

#//# glVertex2sv_c((CPTR)v);
void
glVertex2sv_c(v)
	void *	v
	CODE:
	glVertex2sv(v);

#//# glVertex2sv_c((PACKED)v);
void
glVertex2sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glVertex2sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex2s
#//# glVertex2sv_p($x, $y);
void
glVertex2sv_p(x, y)
	GLshort	x
	GLshort	y
	CODE:
	{
		GLshort param[2];
		param[0] = x;
		param[1] = y;
		glVertex2sv(param);
	}

#//# glVertex3d($x, $y, $z);
void
glVertex3d(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z

#//# glVertex3dv_c((CPTR)v);
void
glVertex3dv_c(v)
	void *	v
	CODE:
	glVertex3dv(v);

#//# glVertex3dv_s((PACKED)v);
void
glVertex3dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glVertex3dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex3d
#//# glVertex3dv_p($x, $y, $z);
void
glVertex3dv_p(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	CODE:
	{
		GLdouble param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertex3dv(param);
	}

#//# glVertex3f($x, $y, $z);
void
glVertex3f(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z

#//# glVertex3fv_c((CPTR)v);
void
glVertex3fv_c(v)
	void *	v
	CODE:
	glVertex3fv(v);

#//# glVertex3fv_s((PACKED)v);
void
glVertex3fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glVertex3fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex3f
#//# glVertex3fv_p($x, $y, $z);
void
glVertex3fv_p(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	CODE:
	{
		GLfloat param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertex3fv(param);
	}

#//# glVertex3i(x, y, z);
void
glVertex3i(x, y, z)
	GLint	x
	GLint	y
	GLint	z

#//# glVertex3iv_c((CPTR)v);
void
glVertex3iv_c(v)
	void *	v
	CODE:
	glVertex3iv(v);

#//# glVertex3iv_s((PACKED)v);
void
glVertex3iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glVertex3iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex3i
#//# glVertex3iv_p($x, $y, $z);
void
glVertex3iv_p(x, y, z)
	GLint	x
	GLint	y
	GLint	z
	CODE:
	{
		GLint param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertex3iv(param);
	}

#//# glVertex3s($x, $y, $z);
void
glVertex3s(x, y, z)
	GLshort	x
	GLshort	y
	GLshort	z

#//# glVertex3sv_c((CPTR)v);
void
glVertex3sv_c(v)
	void *	v
	CODE:
	glVertex3sv(v);

#//# glVertex3sv_s((PACKED)v);
void
glVertex3sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glVertex3sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex3s
#//# glVertex3sv_p($x, $y, $z);
void
glVertex3sv_p(x, y, z)
	GLshort	x
	GLshort	y
	GLshort	z
	CODE:
	{
		GLshort param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertex3sv(param);
	}

#//# glVertex4d($x, $y, $z, $w);
void
glVertex4d(x, y, z, w)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w

#//# glVertex4dv_c((CPTR)v);
void
glVertex4dv_c(v)
	void *	v
	CODE:
	glVertex4dv(v);

#//# glVertex4dv_s((PACKED)v);
void
glVertex4dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glVertex4dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex4d
#//# glVertex4dv_p($x, $y, $z, $w);
void
glVertex4dv_p(x, y, z, w)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w
	CODE:
	{
		GLdouble param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertex4dv(param);
	}

#//# glVertex4f($x, $y, $z, $w);
void
glVertex4f(x, y, z, w)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w

#//# glVertex4fv_c((CPTR)v);
void
glVertex4fv_c(v)
	void *	v
	CODE:
	glVertex4fv(v);

#//# glVertex4fv_s((PACKED)v);
void
glVertex4fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glVertex4fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex4f
#//# glVertex4fv_p($x, $y, $z, $w);
void
glVertex4fv_p(x, y, z, w)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w
	CODE:
	{
		GLfloat param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertex4fv(param);
	}

#//# glVertex4i($x, $y, $z, $w);
void
glVertex4i(x, y, z, w)
	GLint	x
	GLint	y
	GLint	z
	GLint	w

#//# glVertex4iv_c((CPTR)v);
void
glVertex4iv_c(v)
	void *	v
	CODE:
	glVertex4iv(v);

#//# glVertex4iv_s((PACKED)v);
void
glVertex4iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glVertex4iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glVertex4i
#//# glVertex4iv_p($x, $y, $z, $w);
void
glVertex4iv_p(x, y, z, w)
	GLint	x
	GLint	y
	GLint	z
	GLint	w
	CODE:
	{
		GLint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertex4iv(param);
	}

#//# glVertex4s($x, $y, $z, $w);
void
glVertex4s(x, y, z, w)
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w

#//# glVertex4sv_s((PACKED)v);
void
glVertex4sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glVertex4sv(v_s);
	}

#//# glVertex4sv_c((CPTR)v);
void
glVertex4sv_c(v)
	void *	v
	CODE:
	glVertex4sv(v);

#//!!! Do we really need this?  It duplicates glVertex4s
#//# glVertex4sv_p($x, $y, $z, $w);
void
glVertex4sv_p(x, y, z, w)
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w
	CODE:
	{
		GLshort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertex4sv(param);
	}

#//# glNormal3b($nx, $ny, $nz);
void
glNormal3b(nx, ny, nz)
	GLbyte	nx
	GLbyte	ny
	GLbyte	nz

#//# glNormal3bv_c((CPTR)v);
void
glNormal3bv_c(v)
	void *	v
	CODE:
	glNormal3bv(v);

#//# glNormal3bv_s((PACKED)v);
void
glNormal3bv_s(v)
	SV *	v
	CODE:
	{
		GLbyte * v_s = EL(v, sizeof(GLbyte)*3);
		glNormal3bv(v_s);
	}

#//!!! Do we really need this?  It duplicates glNormal3b
#//# glNormal3bv_p($nx, $ny, $nz);
void
glNormal3bv_p(nx, ny, nz)
	GLbyte	nx
	GLbyte	ny
	GLbyte	nz
	CODE:
	{
		GLbyte param[3];
		param[0] = nx;
		param[1] = ny;
		param[2] = nz;
		glNormal3bv(param);
	}

#//# glNormal3d($nx, $ny, $nz);
void
glNormal3d(nx, ny, nz)
	GLdouble	nx
	GLdouble	ny
	GLdouble	nz

#//# glNormal3dv_c((CPTR)v);
void
glNormal3dv_c(v)
	void *	v
	CODE:
	glNormal3dv(v);

#//# glNormal3dv_s((PACKED)v);
void
glNormal3dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glNormal3dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glNormal3d
#//# glNormal3dv_p($nx, $ny, $nz);
void
glNormal3dv_p(nx, ny, nz)
	GLdouble	nx
	GLdouble	ny
	GLdouble	nz
	CODE:
	{
		GLdouble param[3];
		param[0] = nx;
		param[1] = ny;
		param[2] = nz;
		glNormal3dv(param);
	}

#//# glNormal3f($nx, $ny, $nz);
void
glNormal3f(nx, ny, nz)
	GLfloat	nx
	GLfloat	ny
	GLfloat	nz

#//# glNormal3fv_c((CPTR)v);
void
glNormal3fv_c(v)
	void *	v
	CODE:
	glNormal3fv(v);

#//# glNormal3fv_s((PACKED)v);
void
glNormal3fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glNormal3fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glNormal3f
#//# glNormal3fv_p($nx, $ny, $nz);
void
glNormal3fv_p(nx, ny, nz)
	GLfloat	nx
	GLfloat	ny
	GLfloat	nz
	CODE:
	{
		GLfloat param[3];
		param[0] = nx;
		param[1] = ny;
		param[2] = nz;
		glNormal3fv(param);
	}

#//# glNormal3i($nx, $ny, $nz);
void
glNormal3i(nx, ny, nz)
	GLint	nx
	GLint	ny
	GLint	nz

#//# glNormal3iv_c((CPTR)v);
void
glNormal3iv_c(v)
	void *	v
	CODE:
	glNormal3iv(v);

#//# glNormal3iv_s((PACKED)v);
void
glNormal3iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glNormal3iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glNormal3i
#//# glNormal3iv_p($nx, $ny, $nz);
void
glNormal3iv_p(nx, ny, nz)
	GLint	nx
	GLint	ny
	GLint	nz
	CODE:
	{
		GLint param[3];
		param[0] = nx;
		param[1] = ny;
		param[2] = nz;
		glNormal3iv(param);
	}

#//# glNormal3s($nx, $ny, $nz);
void
glNormal3s(nx, ny, nz)
	GLshort	nx
	GLshort	ny
	GLshort	nz

#//# glNormal3sv_c((CPTR)v);
void
glNormal3sv_c(v)
	void *	v
	CODE:
	glNormal3sv(v);

#//# glNormal3sv_s((PACKED)v);
void
glNormal3sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glNormal3sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glNormal3s
#//# glNormal3sv_p($nx, $ny, $nz);
void
glNormal3sv_p(nx, ny, nz)
	GLshort	nx
	GLshort	ny
	GLshort	nz
	CODE:
	{
		GLshort param[3];
		param[0] = nx;
		param[1] = ny;
		param[2] = nz;
		glNormal3sv(param);
	}

#//# glColor3b($red, $green, $blue);
void
glColor3b(red, green, blue)
	GLbyte	red
	GLbyte	green
	GLbyte	blue

#//# glColor3bv_c((CPTR)v);
void
glColor3bv_c(v)
	void *	v
	CODE:
	glColor3bv(v);

#//# glColor3bv_s((PACKED)v);
void
glColor3bv_s(v)
	SV *	v
	CODE:
	{
		GLbyte * v_s = EL(v, sizeof(GLbyte)*3);
		glColor3bv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3b
#//# glColor3bv_p($red, $green, $blue);
void
glColor3bv_p(red, green, blue)
	GLbyte	red
	GLbyte	green
	GLbyte	blue
	CODE:
	{
		GLbyte param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3bv(param);
	}

#//# glColor3d($red, $green, $blue);
void
glColor3d(red, green, blue)
	GLdouble	red
	GLdouble	green
	GLdouble	blue

#//# glColor3dv_c((CPTR)v);
void
glColor3dv_c(v)
	void *	v
	CODE:
	glColor3dv(v);

#//# glColor3dv_s((PACKED)v);
void
glColor3dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glColor3dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3d
#//# glColor3dv_p($red, $green, $blue);
void
glColor3dv_p(red, green, blue)
	GLdouble	red
	GLdouble	green
	GLdouble	blue
	CODE:
	{
		GLdouble param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3dv(param);
	}

#//# glColor3f($red, $green, $blue);
void
glColor3f(red, green, blue)
	GLfloat	red
	GLfloat	green
	GLfloat	blue

#//# glColor3fv_c((CPTR)v);
void
glColor3fv_c(v)
	void *	v
	CODE:
	glColor3fv(v);

#//# glColor3fv_s((PACKED)v);
void
glColor3fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glColor3fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3s
#//# glColor3sv_p($red, $green, $blue);
void
glColor3fv_p(red, green, blue)
	GLfloat	red
	GLfloat	green
	GLfloat	blue
	CODE:
	{
		GLfloat param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3fv(param);
	}

#//# glColor3i($red, $green, $blue);
void
glColor3i(red, green, blue)
	GLint	red
	GLint	green
	GLint	blue

#//# glColor3iv_c((CPTR)v);
void
glColor3iv_c(v)
	void *	v
	CODE:
	glColor3iv(v);

#//# glColor3iv_s((PACKED)v);
void
glColor3iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glColor3iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3i
#//# glColor3iv_p($red, $green, $blue);
void
glColor3iv_p(red, green, blue)
	GLint	red
	GLint	green
	GLint	blue
	CODE:
	{
		GLint param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3iv(param);
	}

#//# glColor3s($red, $green, $blue);
void
glColor3s(red, green, blue)
	GLshort	red
	GLshort	green
	GLshort	blue

#//# glColor3sv_c((CPTR)v);
void
glColor3sv_c(v)
	void *	v
	CODE:
	glColor3sv(v);

#//# glColor3sv_s((PACKED)v);
void
glColor3sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glColor3sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3s
#//# glColor3sv_p($red, $green, $blue);
void
glColor3sv_p(red, green, blue)
	GLshort	red
	GLshort	green
	GLshort	blue
	CODE:
	{
		GLshort param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3sv(param);
	}

#//# glColor3ub($red, $green, $blue);
void
glColor3ub(red, green, blue)
	GLubyte	red
	GLubyte	green
	GLubyte	blue

#//# glColor3ubv_c((CPTR)v);
void
glColor3ubv_c(v)
	void *	v
	CODE:
	glColor3ubv(v);

#//# glColor3ubv_s((PACKED)v);
void
glColor3ubv_s(v)
	SV *	v
	CODE:
	{
		GLubyte * v_s = EL(v, sizeof(GLubyte)*3);
		glColor3ubv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3ub
#//# glColor3ubv_p($red, $green, $blue);
void
glColor3ubv_p(red, green, blue)
	GLubyte	red
	GLubyte	green
	GLubyte	blue
	CODE:
	{
		GLubyte param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3ubv(param);
	}

#//# glColor3ui($red, $green, $blue);
void
glColor3ui(red, green, blue)
	GLuint	red
	GLuint	green
	GLuint	blue

#//# glColor3uiv_c((CPTR)v);
void
glColor3uiv_c(v)
	void *	v
	CODE:
	glColor3uiv(v);

#//# glColor3uiv_s((PACKED)v);
void
glColor3uiv_s(v)
	SV *	v
	CODE:
	{
		GLuint * v_s = EL(v, sizeof(GLuint)*3);
		glColor3uiv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3ui
#//# glColor3uiv_p($red, $green, $blue);
void
glColor3uiv_p(red, green, blue)
	GLuint	red
	GLuint	green
	GLuint	blue
	CODE:
	{
		GLuint param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3uiv(param);
	}

#//# glColor3us($red, $green, $blue);
void
glColor3us(red, green, blue)
	GLushort	red
	GLushort	green
	GLushort	blue

#//# glColor3usv_c((CPTR)v);
void
glColor3usv_c(v)
	void *	v
	CODE:
	glColor3usv(v);

#//# glColor3usv_s((PACKED)v);
void
glColor3usv_s(v)
	SV *	v
	CODE:
	{
		GLushort * v_s = EL(v, sizeof(GLushort)*3);
		glColor3usv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3us
#//# glColor3usv_p($red, $green, $blue);
void
glColor3usv_p(red, green, blue)
	GLushort	red
	GLushort	green
	GLushort	blue
	CODE:
	{
		GLushort param[3];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		glColor3usv(param);
	}

#//# glColor4b($red, $green, $blue, $alpha);
void
glColor4b(red, green, blue, alpha)
	GLbyte	red
	GLbyte	green
	GLbyte	blue
	GLbyte	alpha

#//# glColor4bv_c((CPTR)v);
void
glColor4bv_c(v)
	void *	v
	CODE:
	glColor4bv(v);

#//# glColor4bv_s((PACKED)v);
void
glColor4bv_s(v)
	SV *	v
	CODE:
	{
		GLbyte * v_s = EL(v, sizeof(GLbyte)*4);
		glColor4bv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3b
#//# glColor3bv_p($red, $green, $blue, $alpha);
void
glColor4bv_p(red, green, blue, alpha)
	GLbyte	red
	GLbyte	green
	GLbyte	blue
	GLbyte	alpha
	CODE:
	{
		GLbyte param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4bv(param);
	}

#//# glColor4d($red, $green, $blue, $alpha);
void
glColor4d(red, green, blue, alpha)
	GLdouble	red
	GLdouble	green
	GLdouble	blue
	GLdouble	alpha

#//# glColor4dv_c((CPTR)v);
void
glColor4dv_c(v)
	void *	v
	CODE:
	glColor4dv(v);

#//# glColor4dv_s((PACKED)v);
void
glColor4dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glColor4dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3d
#//# glColor3dv_p($red, $green, $blue, $alpha);
void
glColor4dv_p(red, green, blue, alpha)
	GLdouble	red
	GLdouble	green
	GLdouble	blue
	GLdouble	alpha
	CODE:
	{
		GLdouble param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4dv(param);
	}

#//# glColor4f($red, $green, $blue, $alpha);
void
glColor4f(red, green, blue, alpha)
	GLfloat	red
	GLfloat	green
	GLfloat	blue
	GLfloat	alpha

#//# glColor4fv_c((CPTR)v);
void
glColor4fv_c(v)
	void *	v
	CODE:
	glColor4fv(v);

#//# glColor4fv_s((PACKED)v);
void
glColor4fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glColor4fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3f
#//# glColor3fv_p($red, $green, $blue, $alpha);
void
glColor4fv_p(red, green, blue, alpha)
	GLfloat	red
	GLfloat	green
	GLfloat	blue
	GLfloat	alpha
	CODE:
	{
		GLfloat param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4fv(param);
	}

#//# glColor4i($red, $green, $blue, $alpha);
void
glColor4i(red, green, blue, alpha)
	GLint	red
	GLint	green
	GLint	blue
	GLint	alpha

#//# glColor4iv_c((CPTR)v);
void
glColor4iv_c(v)
	void *	v
	CODE:
	glColor4iv(v);

#//# glColor4iv_s((PACKED)v);
void
glColor4iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glColor4iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3i
#//# glColor3iv_p($red, $green, $blue, $alpha);
void
glColor4iv_p(red, green, blue, alpha)
	GLint	red
	GLint	green
	GLint	blue
	GLint	alpha
	CODE:
	{
		GLint param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4iv(param);
	}

#//# glColor4s($red, $green, $blue, $alpha);
void
glColor4s(red, green, blue, alpha)
	GLshort	red
	GLshort	green
	GLshort	blue
	GLshort	alpha

#//# glColor4sv_c((CPTR)v);
void
glColor4sv_c(v)
	void *	v
	CODE:
	glColor4sv(v);

#//# glColor4sv_s((PACKED)v);
void
glColor4sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glColor4sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3s
#//# glColor3sv_p($red, $green, $blue, $alpha);
void
glColor4sv_p(red, green, blue, alpha)
	GLshort	red
	GLshort	green
	GLshort	blue
	GLshort	alpha
	CODE:
	{
		GLshort param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4sv(param);
	}

#//# glColor4ub(red, green, blue, alpha);
void
glColor4ub(red, green, blue, alpha)
	GLubyte	red
	GLubyte	green
	GLubyte	blue
	GLubyte	alpha

#//# glColor4ubv_c((CPTR)v);
void
glColor4ubv_c(v)
	void *	v
	CODE:
	glColor4ubv(v);

#//# glColor4ubv_s((PACKED)v);
void
glColor4ubv_s(v)
	SV *	v
	CODE:
	{
		GLubyte * v_s = EL(v, sizeof(GLubyte)*4);
		glColor4ubv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3ub
#//# glColor3ubv_p($red, $green, $blue, $alpha);
void
glColor4ubv_p(red, green, blue, alpha)
	GLubyte	red
	GLubyte	green
	GLubyte	blue
	GLubyte	alpha
	CODE:
	{
		GLubyte param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4ubv(param);
	}

#//# glColor4ui($red, $green, $blue, $alpha);
void
glColor4ui(red, green, blue, alpha)
	GLuint	red
	GLuint	green
	GLuint	blue
	GLuint	alpha

#//# glColor4uiv_s((PACKED)v);
void
glColor4uiv_s(v)
	SV *	v
	CODE:
	{
		GLuint * v_s = EL(v, sizeof(GLuint)*4);
		glColor4uiv(v_s);
	}

#//# glColor4uiv_c((CPTR)v);
void
glColor4uiv_c(v)
	void *	v
	CODE:
	glColor4uiv(v);

#//!!! Do we really need this?  It duplicates glColor3ui
#//# glColor3uiv_p($red, $green, $blue, $alpha);
void
glColor4uiv_p(red, green, blue, alpha)
	GLuint	red
	GLuint	green
	GLuint	blue
	GLuint	alpha
	CODE:
	{
		GLuint param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4uiv(param);
	}

#//# glColor4us($red, $green, $blue, $alpha);
void
glColor4us(red, green, blue, alpha)
	GLushort	red
	GLushort	green
	GLushort	blue
	GLushort	alpha

#//# glColor4usv_c((CPTR)v);
void
glColor4usv_c(v)
	void *	v
	CODE:
	glColor4usv(v);

#//# glColor4usv_s((PACKED)v);
void
glColor4usv_s(v)
	SV *	v
	CODE:
	{
		GLushort * v_s = EL(v, sizeof(GLushort)*4);
		glColor4usv(v_s);
	}

#//!!! Do we really need this?  It duplicates glColor3us
#//# glColor3usv_p($red, $green, $blue, $alpha);
void
glColor4usv_p(red, green, blue, alpha)
	GLushort	red
	GLushort	green
	GLushort	blue
	GLushort	alpha
	CODE:
	{
		GLushort param[4];
		param[0] = red;
		param[1] = green;
		param[2] = blue;
		param[3] = alpha;
		glColor4usv(param);
	}

#//# glTexCoord1d($s);
void
glTexCoord1d(s)
	GLdouble	s

#//# glTexCoord1dv_c((CPTR)v);
void
glTexCoord1dv_c(v)
	void *	v
	CODE:
	glTexCoord1dv(v);

#//# glTexCoord1dv_c((PACKED)v);
void
glTexCoord1dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*1);
		glTexCoord1dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord1d
#//# glTexCoord1dv_p($s);
void
glTexCoord1dv_p(s)
	GLdouble	s
	CODE:
	{
		GLdouble param[1];
		param[0] = s;
		glTexCoord1dv(param);
	}

#//# glTexCoord1f($s);
void
glTexCoord1f(s)
	GLfloat	s

#//# glTexCoord1fv_c((CPTR)v);
void
glTexCoord1fv_c(v)
	void *	v
	CODE:
	glTexCoord1fv(v);

#//# glTexCoord1fv_s((PACKED)v);
void
glTexCoord1fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*1);
		glTexCoord1fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord1f
#//# glTexCoord1fv_p($s);
void
glTexCoord1fv_p(s)
	GLfloat	s
	CODE:
	{
		GLfloat param[1];
		param[0] = s;
		glTexCoord1fv(param);
	}

#//# glTexCoord1i($s);
void
glTexCoord1i(s)
	GLint	s

#//# glTexCoord1iv_c((CPTR)v);
void
glTexCoord1iv_c(v)
	void *	v
	CODE:
	glTexCoord1iv(v);

#//# glTexCoord1iv_s((PACKED)v);
void
glTexCoord1iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*1);
		glTexCoord1iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord1i
#//# glTexCoord1iv_p($s);
void
glTexCoord1iv_p(s)
	GLint	s
	CODE:
	{
		GLint param[1];
		param[0] = s;
		glTexCoord1iv(param);
	}

#//# glTexCoord1s($s);
void
glTexCoord1s(s)
	GLshort	s

#//# glTexCoord1sv_c((CPTR)v)
void
glTexCoord1sv_c(v)
	void *	v
	CODE:
	glTexCoord1sv(v);

#//# glTexCoord1sv_s((PACKED)v)
void
glTexCoord1sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*1);
		glTexCoord1sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord1s
#//# glTexCoord1sv_p($s);
void
glTexCoord1sv_p(s)
	GLshort	s
	CODE:
	{
		GLshort param[1];
		param[0] = s;
		glTexCoord1sv(param);
	}

#//# glTexCoord2d($s, $t);
void
glTexCoord2d(s, t)
	GLdouble	s
	GLdouble	t

#//# glTexCoord2dv_c((CPTR)v);
void
glTexCoord2dv_c(v)
	void *	v
	CODE:
	glTexCoord2dv(v);

#//# glTexCoord2dv_s((PACKED)v);
void
glTexCoord2dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glTexCoord2dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord2d
#//# glTexCoord2dv_p($s, $t);
void
glTexCoord2dv_p(s, t)
	GLdouble	s
	GLdouble	t
	CODE:
	{
		GLdouble param[2];
		param[0] = s;
		param[1] = t;
		glTexCoord2dv(param);
	}

#//# glTexCoord2f($s, $t);
void
glTexCoord2f(s, t)
	GLfloat	s
	GLfloat	t

#//# glTexCoord2fv_c((CPTR)v);
void
glTexCoord2fv_c(v)
	void *	v
	CODE:
	glTexCoord2fv(v);

#//# glTexCoord2fv_s((PACKED)v);
void
glTexCoord2fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*2);
		glTexCoord2fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord2f
#//# glTexCoord2fv_p($s, $t);
void
glTexCoord2fv_p(s, t)
	GLfloat	s
	GLfloat	t
	CODE:
	{
		GLfloat param[2];
		param[0] = s;
		param[1] = t;
		glTexCoord2fv(param);
	}

#//# glTexCoord2i($s, $t);
void
glTexCoord2i(s, t)
	GLint	s
	GLint	t

#//# glTexCoord2iv_c((CPTR)v);
void
glTexCoord2iv_c(v)
	void *	v
	CODE:
	glTexCoord2iv(v);

#//# glTexCoord2iv_s((PACKED)v);
void
glTexCoord2iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*2);
		glTexCoord2iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord2i
#//# glTexCoord2iv_p($s, $t);
void
glTexCoord2iv_p(s, t)
	GLint	s
	GLint	t
	CODE:
	{
		GLint param[2];
		param[0] = s;
		param[1] = t;
		glTexCoord2iv(param);
	}

#//# glTexCoord2s($s, $t);
void
glTexCoord2s(s, t)
	GLshort	s
	GLshort	t

#//# glTexCoord2sv_c((CPTR)v);
void
glTexCoord2sv_c(v)
	void *	v
	CODE:
	glTexCoord2sv(v);

#//# glTexCoord2sv_c((PACKED)v);
void
glTexCoord2sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glTexCoord2sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord2s
#//# glTexCoord2sv_p($s, $t);
void
glTexCoord2sv_p(s, t)
	GLshort	s
	GLshort	t
	CODE:
	{
		GLshort param[2];
		param[0] = s;
		param[1] = t;
		glTexCoord2sv(param);
	}

#//# glTexCoord3d($s, $t, $r);
void
glTexCoord3d(s, t, r)
	GLdouble	s
	GLdouble	t
	GLdouble	r

#//# glTexCoord3dv_c((CPTR)v);
void
glTexCoord3dv_c(v)
	void *	v
	CODE:
	glTexCoord3dv(v);

#//# glTexCoord3dv_s((PACKED)v);
void
glTexCoord3dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glTexCoord3dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord3d
#//# glTexCoord3dv_p($s, $t, $r);
void
glTexCoord3dv_p(s, t, r)
	GLdouble	s
	GLdouble	t
	GLdouble	r
	CODE:
	{
		GLdouble param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glTexCoord3dv(param);
	}

#//# glTexCoord3f($s, $t, $r);
void
glTexCoord3f(s, t, r)
	GLfloat	s
	GLfloat	t
	GLfloat	r

#//# glTexCoord3fv_c((CPTR)v);
void
glTexCoord3fv_c(v)
	void *	v
	CODE:
	glTexCoord3fv(v);

#//# glTexCoord3fv_s((PACKED)v);
void
glTexCoord3fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glTexCoord3fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord3f
#//# glTexCoord3fv_p($s, $t, $r);
void
glTexCoord3fv_p(s, t, r)
	GLfloat	s
	GLfloat	t
	GLfloat	r
	CODE:
	{
		GLfloat param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glTexCoord3fv(param);
	}

#//# glTexCoord3i($s, $t, $r);
void
glTexCoord3i(s, t, r)
	GLint	s
	GLint	t
	GLint	r

#//# glTexCoord3iv_c((CPTR)v);
void
glTexCoord3iv_c(v)
	void *	v
	CODE:
	glTexCoord3iv(v);

#//# glTexCoord3iv_s((PACKED)v);
void
glTexCoord3iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glTexCoord3iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord3i
#//# glTexCoord3iv_p($s, $t, $r);
void
glTexCoord3iv_p(s, t, r)
	GLint	s
	GLint	t
	GLint	r
	CODE:
	{
		GLint param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glTexCoord3iv(param);
	}

#//# glTexCoord3s($s, $t, $r);
void
glTexCoord3s(s, t, r)
	GLshort	s
	GLshort	t
	GLshort	r

#//# glTexCoord3sv_s((PACKED)v);
void
glTexCoord3sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glTexCoord3sv(v_s);
	}

#//# glTexCoord3sv_c((CPTR)v);
void
glTexCoord3sv_c(v)
	void *	v
	CODE:
	glTexCoord3sv(v);

#//!!! Do we really need this?  It duplicates glTexCoord3s
#//# glTexCoord3sv_p($s, $t, $r);
void
glTexCoord3sv_p(s, t, r)
	GLshort	s
	GLshort	t
	GLshort	r
	CODE:
	{
		GLshort param[3];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		glTexCoord3sv(param);
	}

#//# glTexCoord4d($s, $t, $r, $q);
void
glTexCoord4d(s, t, r, q)
	GLdouble	s
	GLdouble	t
	GLdouble	r
	GLdouble	q

#//# glTexCoord4dv_c((CPTR)v);
void
glTexCoord4dv_c(v)
	void *	v
	CODE:
	glTexCoord4dv(v);

#//# glTexCoord4dv_s((PACKED)v);
void
glTexCoord4dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glTexCoord4dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord4d
#//# glTexCoord4dv_p($s, $t, $r, $q);
void
glTexCoord4dv_p(s, t, r, q)
	GLdouble	s
	GLdouble	t
	GLdouble	r
	GLdouble	q
	CODE:
	{
		GLdouble param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glTexCoord4dv(param);
	}

#//# glTexCoord4f($s, $t, $r, $q);
void
glTexCoord4f(s, t, r, q)
	GLfloat	s
	GLfloat	t
	GLfloat	r
	GLfloat	q

#//# glTexCoord4fv_c((CPTR)v);
void
glTexCoord4fv_c(v)
	void *	v
	CODE:
	glTexCoord4fv(v);

#//# glTexCoord4fv_s((PACKED)v);
void
glTexCoord4fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glTexCoord4fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord4f
#//# glTexCoord4fv_p($s, $t, $r, $q);
void
glTexCoord4fv_p(s, t, r, q)
	GLfloat	s
	GLfloat	t
	GLfloat	r
	GLfloat	q
	CODE:
	{
		GLfloat param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glTexCoord4fv(param);
	}

#//# glTexCoord4i($s, $t, $r, $q);
void
glTexCoord4i(s, t, r, q)
	GLint	s
	GLint	t
	GLint	r
	GLint	q

#//# glTexCoord4iv_c((CPTR)v);
void
glTexCoord4iv_c(v)
	void *	v
	CODE:
	glTexCoord4iv(v);

#//# glTexCoord4iv_s((PACKED)v);
void
glTexCoord4iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glTexCoord4iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord4i
#//# glTexCoord4iv_p($s, $t, $r, $q);
void
glTexCoord4iv_p(s, t, r, q)
	GLint	s
	GLint	t
	GLint	r
	GLint	q
	CODE:
	{
		GLint param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glTexCoord4iv(param);
	}

#//# glTexCoord4s($s, $t, $r, $q);
void
glTexCoord4s(s, t, r, q)
	GLshort	s
	GLshort	t
	GLshort	r
	GLshort	q

#//# glTexCoord4sv_c((CPTR)v);
void
glTexCoord4sv_c(v)
	void *	v
	CODE:
	glTexCoord4sv(v);

#//# glTexCoord4sv_s((PACKED)v);
void
glTexCoord4sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glTexCoord4sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glTexCoord4s
#//# glTexCoord4sv_p($s, $t, $r, $q);
void
glTexCoord4sv_p(s, t, r, q)
	GLshort	s
	GLshort	t
	GLshort	r
	GLshort	q
	CODE:
	{
		GLshort param[4];
		param[0] = s;
		param[1] = t;
		param[2] = r;
		param[3] = q;
		glTexCoord4sv(param);
	}

#//# glRasterPos2d(x, y);
void
glRasterPos2d(x, y)
	GLdouble	x
	GLdouble	y

#//# glRasterPos2dv_c((CPTR)v);
void
glRasterPos2dv_c(v)
	void *	v
	CODE:
	glRasterPos2dv(v);

#//# glRasterPos2dv_s((PACKED)v);
void
glRasterPos2dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*2);
		glRasterPos2dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos2d
#//# glRasterPos2dv_p($x, $y);
void
glRasterPos2dv_p(x, y)
	GLdouble	x
	GLdouble	y
	CODE:
	{
		GLdouble param[2];
		param[0] = x;
		param[1] = y;
		glRasterPos2dv(param);
	}

#//# glRasterPos2f($x, $y);
void
glRasterPos2f(x, y)
	GLfloat	x
	GLfloat	y

#//# glRasterPos2fv_c((CPTR)v);
void
glRasterPos2fv_c(v)
	void *	v
	CODE:
	glRasterPos2fv(v);

#//# glRasterPos2fv_s((PACKED)v);
void
glRasterPos2fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*2);
		glRasterPos2fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos2f
#//# glRasterPos2fv_p($x, $y);
void
glRasterPos2fv_p(x, y)
	GLfloat	x
	GLfloat	y
	CODE:
	{
		GLfloat param[2];
		param[0] = x;
		param[1] = y;
		glRasterPos2fv(param);
	}

#//# glRasterPos2i($x, $y);
void
glRasterPos2i(x, y)
	GLint	x
	GLint	y

#//# glRasterPos2iv_c((CPTR)v);
void
glRasterPos2iv_c(v)
	void *	v
	CODE:
	glRasterPos2iv(v);

#//# glRasterPos2iv_s((PACKED)v);
void
glRasterPos2iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*2);
		glRasterPos2iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos2i
#//# glRasterPos2iv_p($x, $y);
void
glRasterPos2iv_p(x, y)
	GLint	x
	GLint	y
	CODE:
	{
		GLint param[2];
		param[0] = x;
		param[1] = y;
		glRasterPos2iv(param);
	}

#//# glRasterPos2s($x, $y);
void
glRasterPos2s(x, y)
	GLshort	x
	GLshort	y

#//# glRasterPos2sv_c((CPTR)v);
void
glRasterPos2sv_c(v)
	void *	v
	CODE:
	glRasterPos2sv(v);

#//# glRasterPos2sv_s((PACKED)v);
void
glRasterPos2sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*2);
		glRasterPos2sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos2s
#//# glRasterPos2sv_p($x, $y);
void
glRasterPos2sv_p(x, y)
	GLshort	x
	GLshort	y
	CODE:
	{
		GLshort param[2];
		param[0] = x;
		param[1] = y;
		glRasterPos2sv(param);
	}

#//# glRasterPos3d($x, $y, $z);
void
glRasterPos3d(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z

#//# glRasterPos3dv_c((CPTR)v);
void
glRasterPos3dv_c(v)
	void *	v
	CODE:
	glRasterPos3dv(v);

#//# glRasterPos3dv_s((PACKED)v);
void
glRasterPos3dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*3);
		glRasterPos3dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos3d
#//# glRasterPos3dv_p($x, $y, $z);
void
glRasterPos3dv_p(x, y, z)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	CODE:
	{
		GLdouble param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glRasterPos3dv(param);
	}

#//# glRasterPos3f($x, $y, $z);
void
glRasterPos3f(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z

#//# glRasterPos3fv_c((CPTR)v);
void
glRasterPos3fv_c(v)
	void *	v
	CODE:
	glRasterPos3fv(v);

#//# glRasterPos3fv_s((PACKED)v);
void
glRasterPos3fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*3);
		glRasterPos3fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos3f
#//# glRasterPos3fv_p($x, $y, $z);
void
glRasterPos3fv_p(x, y, z)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	CODE:
	{
		GLfloat param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glRasterPos3fv(param);
	}

#//# glRasterPos3i($x, $y, $z);
void
glRasterPos3i(x, y, z)
	GLint	x
	GLint	y
	GLint	z

#//# glRasterPos3iv_c((CPTR)v);
void
glRasterPos3iv_c(v)
	void *	v
	CODE:
	glRasterPos3iv(v);

#//# glRasterPos3iv_s((PACKED)v);
void
glRasterPos3iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*3);
		glRasterPos3iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos3i
#//# glRasterPos3iv_p($x, $y, $z);
void
glRasterPos3iv_p(x, y, z)
	GLint	x
	GLint	y
	GLint	z
	CODE:
	{
		GLint param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glRasterPos3iv(param);
	}

#//# glRasterPos3s($x, $y, $z);
void
glRasterPos3s(x, y, z)
	GLshort	x
	GLshort	y
	GLshort	z

#//# glRasterPos3sv_c((CPTR)v);
void
glRasterPos3sv_c(v)
	void *	v
	CODE:
	glRasterPos3sv(v);

#//# glRasterPos3sv_s((PACKED)v);
void
glRasterPos3sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*3);
		glRasterPos3sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos3s
#//# glRasterPos3sv_p($x, $y, $z);
void
glRasterPos3sv_p(x, y, z)
	GLshort	x
	GLshort	y
	GLshort	z
	CODE:
	{
		GLshort param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glRasterPos3sv(param);
	}

#//# glRasterPos4d($x, $y, $z, $w);
void
glRasterPos4d(x, y, z, w)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w

#//# glRasterPos4dv_c((CPTR)v);
void
glRasterPos4dv_c(v)
	void *	v
	CODE:
	glRasterPos4dv(v);

#//# glRasterPos4dv_s((PACKED)v);
void
glRasterPos4dv_s(v)
	SV *	v
	CODE:
	{
		GLdouble * v_s = EL(v, sizeof(GLdouble)*4);
		glRasterPos4dv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos4d
#//# glRasterPos4dv_p($x, $y, $z, $w);
void
glRasterPos4dv_p(x, y, z, w)
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w
	CODE:
	{
		GLdouble param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glRasterPos4dv(param);
	}

#//# glRasterPos4f($x, $y, $z, $w);
void
glRasterPos4f(x, y, z, w)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w

#//# glRasterPos4fv_c((CPTR)v);
void
glRasterPos4fv_c(v)
	void *	v
	CODE:
	glRasterPos4fv(v);

#//# glRasterPos4fv_s((PACKED)v);
void
glRasterPos4fv_s(v)
	SV *	v
	CODE:
	{
		GLfloat * v_s = EL(v, sizeof(GLfloat)*4);
		glRasterPos4fv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos4f
#//# glRasterPos4fv_p($x, $y, $z, $w);
void
glRasterPos4fv_p(x, y, z, w)
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w
	CODE:
	{
		GLfloat param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glRasterPos4fv(param);
	}

#//# glRasterPos4i($x, $y, $z, $w);
void
glRasterPos4i(x, y, z, w)
	GLint	x
	GLint	y
	GLint	z
	GLint	w

#//# glRasterPos4iv_c((CPTR)v);
void
glRasterPos4iv_c(v)
	void *	v
	CODE:
	glRasterPos4iv(v);

#//# glRasterPos4iv_s((PACKED)v);
void
glRasterPos4iv_s(v)
	SV *	v
	CODE:
	{
		GLint * v_s = EL(v, sizeof(GLint)*4);
		glRasterPos4iv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos4i
#//# glRasterPos4iv_p($x, $y, $z, $w);
void
glRasterPos4iv_p(x, y, z, w)
	GLint	x
	GLint	y
	GLint	z
	GLint	w
	CODE:
	{
		GLint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glRasterPos4iv(param);
	}

#//# glRasterPos4s($x, $y, $z, $w);
void
glRasterPos4s(x, y, z, w)
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w

#//# glRasterPos4sv_c((CPTR)v);
void
glRasterPos4sv_c(v)
	void *	v
	CODE:
	glRasterPos4sv(v);

#//# glRasterPos4sv_s((PACKED)v);
void
glRasterPos4sv_s(v)
	SV *	v
	CODE:
	{
		GLshort * v_s = EL(v, sizeof(GLshort)*4);
		glRasterPos4sv(v_s);
	}

#//!!! Do we really need this?  It duplicates glRasterPos4s
#//# glRasterPos4sv_p($x, $y, $z, $w);
void
glRasterPos4sv_p(x, y, z, w)
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w
	CODE:
	{
		GLshort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glRasterPos4sv(param);
	}

# End of generated declarations

################## DEPRECATED EXTENSIONS ########################

#ifdef DEPRECATED
#ifdef GL_EXT_polygon_offset

#// glPolygonOffsetEXT($factor, $bias);
void
glPolygonOffsetEXT(factor, bias)
	GLfloat	factor
	GLfloat	units

#endif

#ifdef GL_EXT_texture_object

#// glIsTextureEXT($list);
GLboolean
glIsTextureEXT(list)
	GLuint	list

#// glPrioritizeTexturesEXT_p(@textureIDs,@priorities);
void
glPrioritizeTexturesEXT_p(...)
	CODE:
	{
		GLsizei n = items/2;
		GLuint * textures = malloc(sizeof(GLuint) * (n+1));
		GLclampf * prior = malloc(sizeof(GLclampf) * (n+1));
		int i;
		
		for (i=0;i<n;i++) {
			textures[i] = SvIV(ST(i * 2 + 0));
			prior[i] = SvNV(ST(i * 2 + 1));
		}
		
		glPrioritizeTextures(n, textures, prior);
		
		free(textures);
		free(prior);
	}

#// glBindTextureEXT($target, $texture);
void
glBindTextureEXT(target, texture)
	GLenum	target
	GLuint	texture

#// glDeleteTexturesEXT_p(@textureIDs);
void
glDeleteTexturesEXT_p(...);
	CODE:
	if (items) {
		GLuint * list = malloc(sizeof(GLuint) * items);
		int i;

		for(i=0;i<items;i++)
			list[i] = SvIV(ST(i));
		
		glDeleteTextures(items, list);
		free(list);
	}

#// @textureIDs = glGenTexturesEXT_p($n);
void
glGenTexturesEXT_p(n)
	GLint	n
	PPCODE:
	if (n) {
		GLuint * textures = malloc(sizeof(GLuint) * n);
		int i;
		
		glGenTextures(n, textures);
		
		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(textures[i])));

		free(textures);
	} 

#// ($result,@residences) = glAreTexturesResidentEXT_p(@textureIDs);
void
glAreTexturesResidentEXT_p(...)
	PPCODE:
	{
		GLsizei n = items;
		GLuint * textures = malloc(sizeof(GLuint) * (n+1));
		GLboolean * residences = malloc(sizeof(GLboolean) * (n+1));
		GLboolean result;
		int i;
		
		for (i=0;i<n;i++)
			textures[i] = SvIV(ST(i));
		
		result = glAreTexturesResident(n, textures, residences);
		
		if (result == GL_TRUE)
			PUSHs(sv_2mortal(newSViv(1)));
		else {
			EXTEND(sp, n+1);
			PUSHs(sv_2mortal(newSViv(0)));
			for(i=0;i<n;i++)
				PUSHs(sv_2mortal(newSViv(residences[i])));
		}
		
		free(textures);
		free(residences);
	}

#endif

#ifdef GL_EXT_copy_texture

#// glCopyTexImage1DEXT($target, $level, $internalFormat, $x, $y, $width, $border);
void
glCopyTexImage1DEXT(target, level, internalFormat, x, y, width, border)
	GLenum	target
	GLint	level
	GLenum	internalFormat
	GLint	x
	GLint	y
	GLsizei	width
	GLint	border

#// glCopyTexImage2DEXT($target, $level, $internalFormat, $x, $y, $width, $height, $border);
void
glCopyTexImage2DEXT(target, level, internalFormat, x, y, width, height, border)
	GLenum	target
	GLint	level
	GLenum	internalFormat
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height
	GLint	border

#// glCopyTexSubImage1DEXT($target, $level, $xoffset, $x, $y, $width);
void
glCopyTexSubImage1DEXT(target, level, xoffset, x, y, width)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	x
	GLint	y
	GLsizei	width

#// glCopyTexSubImage2DEXT($target, $level, $xoffset, $yoffset, $x, $y, $width, $height);
void
glCopyTexSubImage2DEXT(target, level, xoffset, yoffset, x, y, width, height)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height

#// glCopyTexSubImage3DEXT($target, $level, $xoffset, $yoffset, $zoffset, $x, $y, $width, $height);
void
glCopyTexSubImage3DEXT(target, level, xoffset, yoffset, zoffset, x, y, width, height)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLint	zoffset
	GLint	x
	GLint	y
	GLsizei	width
	GLsizei	height

#endif

#ifdef GL_EXT_subtexture

#// glTexSubImage1DEXT_c($target, $level, $xoffset, $width, $format, $type, (CPTR)pixels);
void
glTexSubImage1DEXT_c(target, level, xoffset, width, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	void *	pixels
	INIT:
		loadProc(glTexSubImage1DEXT,"glTexSubImage1DEXT");
	CODE:
	{
		glTexSubImage1DEXT(target, level, xoffset, width, format, type, pixels);
	}

#// glTexSubImage1DEXT_s($target, $level, $xoffset, $width, $format, $type, (PACKED)pixels);
void
glTexSubImage1DEXT_s(target, level, xoffset, width, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	SV *	pixels
	INIT:
		loadProc(glTexSubImage1DEXT,"glTexSubImage1DEXT");
	CODE:
	{
		GLvoid * ptr = ELI(pixels, width, height,
			format, type, gl_pixelbuffer_unpack);
		glTexSubImage1DEXT(target, level, xoffset, width, format, type, ptr);
	}

#// glTexSubImage1DEXT_p($target, $level, $xoffset, $width, $format, $type, @pixels);
void
glTexSubImage1DEXT_p(target, level, xoffset, width, format, type, ...)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLsizei	width
	GLenum	format
	GLenum	type
	INIT:
		loadProc(glTexSubImage1DEXT,"glTexSubImage1DEXT");
	CODE:
	{
		GLvoid * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		ptr = pack_image_ST(&(ST(4)), items-4, width, height, 1, format, type, 0);
		glTexSubImage1DEXT(target, level, xoffset, width, format, type, ptr);
		glPopClientAttrib();
		free(ptr);
	}

#// glTexSubImage2DEXT_c($target, $level, $xoffset, $yoffset, $width, $height, $format, $type, (CPTR)pixels);
void
glTexSubImage2DEXT_c(target, level, xoffset, yoffset, width, height, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	void *	pixels
	INIT:
		loadProc(glTexSubImage2DEXT,"glTexSubImage2DEXT");
	CODE:
	{
		glTexSubImage2DEXT(target, level, xoffset, yoffset, width, height,
			format, type, pixels);
	}

#// glTexSubImage2DEXT_s($target, $level, $xoffset, $yoffset, $width, $height, $format, $type, (PACKED)pixels);
void
glTexSubImage2DEXT_s(target, level, xoffset, yoffset, width, height, format, type, pixels)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	SV *	pixels
	INIT:
		loadProc(glTexSubImage2DEXT,"glTexSubImage2DEXT");
	CODE:
	{
		GLvoid * ptr = ELI(pixels, width, height,
			format, type, gl_pixelbuffer_unpack);
		glTexSubImage2DEXT(target, level, xoffset, yoffset, width, height,
			format, type, ptr);
	}

#// glTexSubImage2DEXT_p($target, $level, $xoffset, $yoffset, $width, $height, $format, $type, @pixels);
void
glTexSubImage2DEXT_p(target, level, xoffset, yoffset, width, height, format, type, ...)
	GLenum	target
	GLint	level
	GLint	xoffset
	GLint	yoffset
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	INIT:
		loadProc(glTexSubImage2DEXT,"glTexSubImage2DEXT");
	CODE:
	{
		GLvoid * ptr;
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		ptr = pack_image_ST(&(ST(4)), items-4, width, height, 1, format, type, 0);
		glTexSubImage2DEXT(target, level, xoffset, yoffset, width, height,
			format, type, ptr);
		glPopClientAttrib();
		free(ptr);
	}

#endif
#endif //DEPRECATED

################## POST 1.1 VERSIONS ########################

#ifdef GL_VERSION_1_2

#//# glBlendColor($red, $green, $blue, $alpha);
void
glBlendColor(red, green, blue, alpha)
	GLclampf	red
	GLclampf	green
	GLclampf	blue
	GLclampf	alpha
	INIT:
		loadProc(glBlendColor,"glBlendColor");
	CODE:
		glBlendColor(red, green, blue, alpha);

#//# glBlendEquation($mode);
void
glBlendEquation(mode)
	GLenum	mode
	INIT:
		loadProc(glBlendEquation,"glBlendEquation");
	CODE:
		glBlendEquation(mode);


#endif

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


# OS/2 PM implementation misses this function
# It is very hard to test for this, so we check for some other omission...

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
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
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
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
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
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
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
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
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
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
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
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
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
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
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
	PDL::Graphics::OpenGL::Perl::OpenGL::Array oga
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
PDL::Graphics::OpenGL::Perl::OpenGL::Array
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
PDL::Graphics::OpenGL::Perl::OpenGL::Array
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
PDL::Graphics::OpenGL::Perl::OpenGL::Array
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

#endif



#ifdef GL_ARB_shader_objects

#//# glDeleteObjectARB($obj);
void
glDeleteObjectARB(obj)
	GLhandleARB	obj
	INIT:
		loadProc(glDeleteObjectARB,"glDeleteObjectARB");
	CODE:
	{
		glDeleteObjectARB(obj);
	}

#//# glGetHandleARB($pname);
GLhandleARB
glGetHandleARB(pname)
	GLenum	pname
	INIT:
		loadProc(glGetHandleARB,"glGetHandleARB");
	CODE:
	{
		RETVAL = glGetHandleARB(pname);
	}
	OUTPUT:
		RETVAL

#//# glDetachObjectARB($containerObj, $attachedObj);
void
glDetachObjectARB(containerObj, attachedObj)
	GLhandleARB containerObj
	GLhandleARB attachedObj
	INIT:
		loadProc(glDetachObjectARB,"glDetachObjectARB");
	CODE:
	{
		glDetachObjectARB(containerObj, attachedObj);
	}

#//# glCreateShaderObjectARB($shaderType);
GLhandleARB
glCreateShaderObjectARB(shaderType)
	GLenum shaderType
	INIT:
		loadProc(glCreateShaderObjectARB,"glCreateShaderObjectARB");
	CODE:
	{
		RETVAL = glCreateShaderObjectARB(shaderType);
	}
	OUTPUT:
		RETVAL

#//# glShaderSourceARB_c($shaderObj, $count, (CPTR)string, (CPTR)length);
void
glShaderSourceARB_c(shaderObj, count, string, length)
	GLhandleARB shaderObj
	GLsizei count
	void	*string
	void	*length
	INIT:
		loadProc(glShaderSourceARB,"glShaderSourceARB");
	CODE:
	{
		glShaderSourceARB(shaderObj, count, string, length);
	}

#//# glShaderSourceARB_p($shaderObj, @string);
void
glShaderSourceARB_p(shaderObj, ...)
	GLhandleARB shaderObj
	INIT:
		loadProc(glShaderSourceARB,"glShaderSourceARB");
	CODE:
	{
		int i;
		int count = items - 1;
		GLcharARB **string = malloc(sizeof(GLcharARB *) * count);
		GLint *length = malloc(sizeof(GLint) * count);

		for(i=0;i<count;i++) {
			string[i] = (GLcharARB *)SvPV(ST(i+1),PL_na);
			length[i] = strlen(string[i]);
		}

		glShaderSourceARB(shaderObj, count, (const GLcharARB**)string,
			(const GLint *)length);

		free(length);
                free(string);
	}

#//# glCompileShaderARB($shaderObj);
void
glCompileShaderARB(shaderObj)
	GLhandleARB shaderObj
	INIT:
		loadProc(glCompileShaderARB,"glCompileShaderARB");
	CODE:
	{
		glCompileShaderARB(shaderObj);
	}

#//# $obj = glCreateProgramObjectARB();
GLhandleARB
glCreateProgramObjectARB()
	INIT:
		loadProc(glCreateProgramObjectARB,"glCreateProgramObjectARB");
	CODE:
	{
		RETVAL = glCreateProgramObjectARB();
	}
	OUTPUT:
		RETVAL

#//# glAttachObjectARB($containerObj, $obj);
void
glAttachObjectARB(containerObj, obj)
	GLhandleARB containerObj
	GLhandleARB obj
	INIT:
		loadProc(glAttachObjectARB,"glAttachObjectARB");
	CODE:
	{
		glAttachObjectARB(containerObj, obj);
	}

#//# glLinkProgramARB($programObj);
void
glLinkProgramARB(programObj)
	GLhandleARB programObj
	INIT:
		loadProc(glLinkProgramARB,"glLinkProgramARB");
	CODE:
	{
		glLinkProgramARB(programObj);
	}

#//# glUseProgramObjectARB($programObj);
void
glUseProgramObjectARB(programObj)
	GLhandleARB programObj
	INIT:
		loadProc(glUseProgramObjectARB,"glUseProgramObjectARB");
	CODE:
	{
		glUseProgramObjectARB(programObj);
	}

#//# glValidateProgramARB($programObj);
void
glValidateProgramARB(programObj)
	GLhandleARB programObj
	INIT:
		loadProc(glValidateProgramARB,"glValidateProgramARB");
	CODE:
	{
		glValidateProgramARB(programObj);
	}

#//# glUniform1fARB($location, $v0);
void
glUniform1fARB(location, v0)
	GLint location
	GLfloat v0
	INIT:
		loadProc(glUniform1fARB,"glUniform1fARB");
	CODE:
	{
		glUniform1fARB(location, v0);
	}

#//# glUniform2fARB($location, $v0, $v1);
void
glUniform2fARB(location, v0, v1)
	GLint location
	GLfloat v0
	GLfloat v1
	INIT:
		loadProc(glUniform2fARB,"glUniform2fARB");
	CODE:
	{
		glUniform2fARB(location, v0, v1);
	}

#//# glUniform3fARB($location, $v0, $v1, $v2);
void
glUniform3fARB(location, v0, v1, v2)
	GLint location
	GLfloat v0
	GLfloat v1
	GLfloat v2
	INIT:
		loadProc(glUniform3fARB,"glUniform3fARB");
	CODE:
	{
		glUniform3fARB(location, v0, v1, v2);
	}

#//# glUniform4fARB($location, $v0, $v1, $v2, $v3);
void
glUniform4fARB(location, v0, v1, v2, v3)
	GLint location
	GLfloat v0
	GLfloat v1
	GLfloat v2
	GLfloat v3
	INIT:
		loadProc(glUniform4fARB,"glUniform4fARB");
	CODE:
	{
		glUniform4fARB(location, v0, v1, v2, v3);
	}

#//# glUniform1iARB($location, $v0);
void
glUniform1iARB(location, v0)
	GLint location
	GLint v0
	INIT:
		loadProc(glUniform1iARB,"glUniform1iARB");
	CODE:
	{
		glUniform1iARB(location, v0);
	}

#//# glUniform2iARB($location, $v0, $v1);
void
glUniform2iARB(location, v0, v1)
	GLint location
	GLint v0
	GLint v1
	INIT:
		loadProc(glUniform2iARB,"glUniform2iARB");
	CODE:
	{
		glUniform2iARB(location, v0, v1);
	}

#//# glUniform3iARB($location, $v0, $v1, $v2);
void
glUniform3iARB(location, v0, v1, v2)
	GLint location
	GLint v0
	GLint v1
	GLint v2
	INIT:
		loadProc(glUniform3iARB,"glUniform3iARB");
	CODE:
	{
		glUniform3iARB(location, v0, v1, v2);
	}

#//# glUniform4iARB($location, $v0, $v1, $v2, $v3);
void
glUniform4iARB(location, v0, v1, v2, v3)
	GLint location
	GLint v0
	GLint v1
	GLint v2
	GLint v3
	INIT:
		loadProc(glUniform4iARB,"glUniform4iARB");
	CODE:
	{
		glUniform4iARB(location, v0, v1, v2, v3);
	}

#//# glUniform1fvARB_c($location, $count, (CPTR)value);
void
glUniform1fvARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform1fvARB,"glUniform1fvARB");
	CODE:
		glUniform1fvARB(location, count, value);

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

#//# glUniform1fvARB_p(location, @value);
void
glUniform1fvARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform1fvARB,"glUniform1fvARB");
	CODE:
	{
		int i;
		GLsizei count = items - 1;
		GLfloat *value = malloc(sizeof(GLfloat) * count);

		for(i=0;i<count;i++) {
			value[i] = (GLfloat)SvNV(ST(i+1));
		}

		glUniform1fvARB(location, count, value);

		free(value);
	}

#//# glUniform2fvARB_c($location, $count, (CPTR)value);
void
glUniform2fvARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform2fvARB,"glUniform2fvARB");
	CODE:
		glUniform2fvARB(location, count, value);

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

#//# glUniform2fvARB_p($location, @value);
void
glUniform2fvARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform2fvARB,"glUniform2fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements >> 1;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+1));
		}

		glUniform2fvARB(location, count, value);

		free(value);
	}

#//# glUniform3fvARB_c($location, $count, (CPTR)value);
void
glUniform3fvARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform3fvARB,"glUniform3fvARB");
	CODE:
		glUniform3fvARB(location, count, value);

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

#//# glUniform3fvARB_p($location, @value);
void
glUniform3fvARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform3fvARB,"glUniform3fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements / 3;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+1));
		}

		glUniform3fvARB(location, count, value);

		free(value);
	}

#//# glUniform4fvARB_c($location, $count, (CPTR)value);
void
glUniform4fvARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform4fvARB,"glUniform4fvARB");
	CODE:
		glUniform4fvARB(location, count, value);

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

#//# glUniform4fvARB_p($location, @value);
void
glUniform4fvARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform4fvARB,"glUniform4fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements >> 2;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+1));
		}

		glUniform4fvARB(location, count, value);

		free(value);
	}

#//# glUniform1ivARB_c($location, $count, (CPTR)value);
void
glUniform1ivARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform1ivARB,"glUniform1ivARB");
	CODE:
		glUniform1ivARB(location, count, value);

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

#//# glUniform1ivARB_p($location, @value);
void
glUniform1ivARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform1ivARB,"glUniform1ivARB");
	CODE:
	{
		int i;
		GLsizei count = items - 1;
		GLint *value = malloc(sizeof(GLint) * count);

		for(i=0;i<count;i++) {
			value[i] = SvIV(ST(i+1));
		}

		glUniform1ivARB(location, count, value);

		free(value);
	}

#//# glUniform2ivARB_c($location, $count, (CPTR)value);
void
glUniform2ivARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform2ivARB,"glUniform2ivARB");
	CODE:
		glUniform2ivARB(location, count, value);

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

#//# glUniform2ivARB_p($location, @value);
void
glUniform2ivARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform2ivARB,"glUniform2ivARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements >> 1;
		GLint *value = malloc(sizeof(GLint) * elements);

		for(i=0;i<elements;i++) {
			value[i] = SvIV(ST(i+1));
		}

		glUniform2ivARB(location, count, value);

		free(value);
	}

#//# glUniform3ivARB_c($location, $count, (CPTR)value);
void
glUniform3ivARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform3ivARB,"glUniform3ivARB");
	CODE:
		glUniform3ivARB(location, count, value);

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

#//# glUniform3ivARB_p($location, @value);
void
glUniform3ivARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform3ivARB,"glUniform3ivARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements / 3;
		GLint *value = malloc(sizeof(GLint) * elements);

		for(i=0;i<elements;i++) {
			value[i] = SvIV(ST(i+1));
		}

		glUniform3ivARB(location, count, value);

		free(value);
	}

#//# glUniform4ivARB_c($location, $count, (CPTR)value);
void
glUniform4ivARB_c(location, count, value)
	GLint	location
	GLsizei	count
	void	*value
	INIT:
		loadProc(glUniform4ivARB,"glUniform4ivARB");
	CODE:
		glUniform4ivARB(location, count, value);

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

#//# glUniform4ivARB_p($location, @value);
void
glUniform4ivARB_p(location, ...)
	GLint location
	INIT:
		loadProc(glUniform4ivARB,"glUniform4ivARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 1;
		GLsizei count = elements >> 2;
		GLint *value = malloc(sizeof(GLint) * elements);

		for(i=0;i<elements;i++) {
			value[i] = SvIV(ST(i+1));
		}

		glUniform4ivARB(location, count, value);

		free(value);
	}

#//# glUniformMatrix2fvARB_c($location, $count, $transpose, (CPTR)value);
void
glUniformMatrix2fvARB_c(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	void	*value
	INIT:
		loadProc(glUniformMatrix2fvARB,"glUniformMatrix2fvARB");
	CODE:
		glUniformMatrix2fvARB(location, count, transpose, value);

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

#//# glUniformMatrix2fvARB_p($location, $transpose, @matrix);
void
glUniformMatrix2fvARB_p(location, transpose, ...)
	GLint location
	GLboolean transpose
	INIT:
		loadProc(glUniformMatrix2fvARB,"glUniformMatrix2fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 2;
		GLsizei count = elements / 4;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+2));
		}

		glUniformMatrix2fvARB(location, count, transpose, value);

		free(value);
	}

#//# glUniformMatrix3fvARB_c($location, $count, $transpose, (CPTR)value);
void
glUniformMatrix3fvARB_c(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	void	*value
	INIT:
		loadProc(glUniformMatrix3fvARB,"glUniformMatrix2fvARB");
	CODE:
		glUniformMatrix3fvARB(location, count, transpose, value);

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

#//# glUniformMatrix3fvARB_p($location, $transpose, @matrix);
void
glUniformMatrix3fvARB_p(location, transpose, ...)
	GLint location
	GLboolean transpose
	INIT:
		loadProc(glUniformMatrix3fvARB,"glUniformMatrix3fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 2;
		GLsizei count = elements / 9;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+2));
		}

		glUniformMatrix3fvARB(location, count, transpose, value);

		free(value);
	}

#//# glUniformMatrix4fvARB_c($location, $count, $transpose, (CPTR)value);
void
glUniformMatrix4fvARB_c(location, count, transpose, value)
	GLint	location
	GLsizei	count
	GLboolean transpose
	void	*value
	INIT:
		loadProc(glUniformMatrix4fvARB,"glUniformMatrix4fvARB");
	CODE:
		glUniformMatrix4fvARB(location, count, transpose, value);

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

#//# glUniformMatrix4fvARB_p($location, $transpose, @matrix);
void
glUniformMatrix4fvARB_p(location, transpose, ...)
	GLint location
	GLboolean transpose
	INIT:
		loadProc(glUniformMatrix4fvARB,"glUniformMatrix4fvARB");
	CODE:
	{
		int i;
		GLsizei elements = items - 2;
		GLsizei count = elements / 16;
		GLfloat *value = malloc(sizeof(GLfloat) * elements);

		for(i=0;i<elements;i++) {
			value[i] = (GLfloat)SvNV(ST(i+2));
		}

		glUniformMatrix4fvARB(location, count, transpose, value);

		free(value);
	}

#//# glGetObjectParameterfvARB_c($obj,$pname,(CPTR)params);
void
glGetObjectParameterfvARB_c(obj,pname,params)
	GLhandleARB obj
	GLenum	pname
	void	*params
	INIT:
		loadProc(glGetObjectParameterfvARB,"glGetObjectParameterfvARB");
	CODE:
		glGetObjectParameterfvARB(obj,pname,params);

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

#//# glGetObjectParameterivARB_c($obj,$pname,(CPTR)params);
void
glGetObjectParameterivARB_c(obj,pname,params)
	GLhandleARB obj
	GLenum	pname
	void	*params
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
	CODE:
		glGetObjectParameterivARB(obj,pname,params);

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

#//# $param = glGetObjectParameterivARB_c($obj,$pname);
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

#//# glGetInfoLogARB_c($obj, $maxLength, (CPTR)length, (CPTR)infoLog);
void
glGetInfoLogARB_c(obj, maxLength, length, infoLog)
	GLhandleARB obj
	GLsizei	maxLength
	void	*length
	void	*infoLog
	INIT:
		loadProc(glGetInfoLogARB,"glGetInfoLogARB");
	CODE:
		glGetInfoLogARB(obj, maxLength, length, infoLog);

#//# $infoLog = glGetInfoLogARB_c($obj);
SV *
glGetInfoLogARB_p(obj)
	GLhandleARB obj
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
		loadProc(glGetInfoLogARB,"glGetInfoLogARB");
	CODE:
	{
		GLint maxLength;
		glGetObjectParameterivARB(obj,GL_OBJECT_INFO_LOG_LENGTH_ARB,(GLvoid *)&maxLength);
		if (maxLength)
		{
			GLint length;
			GLcharARB * infoLog = malloc(maxLength+1);
			glGetInfoLogARB(obj,maxLength,&length,infoLog);
			infoLog[length] = 0;
			if (*infoLog)
				RETVAL = newSVpv(infoLog, 0);
			else
				RETVAL = newSVsv(&PL_sv_undef);

			free(infoLog);
		}
		else
		{
			RETVAL = newSVsv(&PL_sv_undef);
		}
	}
	OUTPUT:
		RETVAL

#//# glGetAttachedObjectsARB_c($containerObj, $maxCount, (CPTR)count, (CPTR)obj);
void
glGetAttachedObjectsARB_c(containerObj, maxCount, count, obj)
	GLhandleARB containerObj
	GLsizei	maxCount
	void	*count
	void	*obj
	INIT:
		loadProc(glGetAttachedObjectsARB,"glGetAttachedObjectsARB");
	CODE:
		glGetAttachedObjectsARB(containerObj, maxCount, count, obj);

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
			PUSHs(sv_2mortal(newSViv(obj[i])));

		free(obj);
	}

#//# glGetUniformLocationARB_c($programObj, (CPTR)name);
GLint
glGetUniformLocationARB_c(programObj, name)
	GLhandleARB programObj
	void	*name
	INIT:
		loadProc(glGetUniformLocationARB,"glGetUniformLocationARB");
	CODE:
		RETVAL = glGetUniformLocationARB(programObj, name);
	OUTPUT:
		RETVAL

#//# $value = glGetUniformLocationARB_p($programObj, $name);
GLint
glGetUniformLocationARB_p(programObj, ...)
	GLhandleARB programObj
	INIT:
		loadProc(glGetUniformLocationARB,"glGetUniformLocationARB");
	CODE:
	{
		GLcharARB *name = (GLcharARB *)SvPV(ST(1),PL_na);
		RETVAL = glGetUniformLocationARB(programObj, name);
	}
	OUTPUT:
		RETVAL

#//# glGetActiveUniformARB_c($programObj, $index, $maxLength, (CPTR)length, (CPTR)size, (CPTR)type, (CPTR)name);
void
glGetActiveUniformARB_c(programObj, index, maxLength, length, size, type, name)
	GLhandleARB programObj
	GLuint	index
	GLsizei	maxLength
	void	*length
	void	*size
	void	*type
	void	*name
	INIT:
		loadProc(glGetActiveUniformARB,"glGetActiveUniformARB");
	CODE:
		glGetActiveUniformARB(programObj,index,maxLength,length,size,type,name);

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

#//# ($name,$type,$size) = glGetActiveUniformARB_p($programObj, $index);
void
glGetActiveUniformARB_p(programObj, index)
	GLhandleARB programObj
	GLuint index
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
		loadProc(glGetActiveUniformARB,"glGetActiveUniformARB");
	PPCODE:
	{
		GLsizei maxLength;
		glGetObjectParameterivARB(programObj,GL_OBJECT_ACTIVE_UNIFORM_MAX_LENGTH_ARB,
			(GLvoid *)&maxLength);
		if (maxLength)
		{
			GLsizei length;
			GLint size;
			GLenum type;
			GLcharARB *name;

			name = malloc(maxLength+1);
			glGetActiveUniformARB(programObj,index,maxLength,
				&length,&size,&type,name);
			name[length] = 0;

			if (*name)
			{
				EXTEND(sp,3);
				PUSHs(sv_2mortal(newSVpv(name,0)));
				PUSHs(sv_2mortal(newSViv(type)));
				PUSHs(sv_2mortal(newSViv(size)));
			}
			else
			{
				EXTEND(sp,1);
				PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
			}

			free(name);
		}
		else
		{
			EXTEND(sp,1);
			PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
		}
	}

#//# glGetUniformfvARB_c($programObj, $location, (CPTR)params);
void
glGetUniformfvARB_c(programObj, location, params)
	GLhandleARB programObj
	GLint	location
	void	*params
	INIT:
		loadProc(glGetUniformfvARB,"glGetUniformfvARB");
	CODE:
		glGetUniformfvARB(programObj, location, params);

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

#//# glGetUniformivARB_c($programObj, $location, (CPTR)params);
void
glGetUniformivARB_c(programObj, location, params)
	GLhandleARB programObj
	GLint	location
	void	*params
	INIT:
		loadProc(glGetUniformivARB,"glGetUniformivARB");
	CODE:
		glGetUniformivARB(programObj, location, params);

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

#//# glGetShaderSourceARB_c($obj, $maxLength, (CPTR)length, (CPTR)source);
void
glGetShaderSourceARB_c(obj, maxLength, length, source)
	GLhandleARB obj
	GLsizei	maxLength
	void	*length
	void	*source
	INIT:
		loadProc(glGetShaderSourceARB,"glGetShaderSourceARB");
	CODE:
		glGetShaderSourceARB(obj, maxLength, length, source);

#//# $source = glGetShaderSourceARB_p($obj);
void
glGetShaderSourceARB_p(obj)
	GLhandleARB obj
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
		loadProc(glGetShaderSourceARB,"glGetShaderSourceARB");
	PPCODE:
	{
		GLsizei maxLength;
		glGetObjectParameterivARB(obj,GL_OBJECT_SHADER_SOURCE_LENGTH_ARB,
			(GLvoid *)&maxLength);

		EXTEND(sp,1);

		if (maxLength)
		{
			GLsizei length;
			GLcharARB *source;

			source = malloc(maxLength+1);
			glGetShaderSourceARB(obj,maxLength,&length,source);
			source[length] = 0;

			if (*source)
			{
				PUSHs(sv_2mortal(newSVpv(source,0)));
			}
			else
			{
				PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
			}

			free(source);
		}
		else
		{
			PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
		}
	}

#endif


#ifdef GL_ARB_vertex_program

#//# glProgramStringARB_c($target,$format,$len,(CPTR)string);
void
glProgramStringARB_c(target,format,len,string)
	GLenum target
	GLenum format
	GLsizei len
	void * string
	INIT:
		loadProc(glProgramStringARB,"glProgramStringARB");
	CODE:
		glProgramStringARB(target,format,len,string);

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

#//# glBindProgramARB($target,$program);
void
glBindProgramARB(target,program)
	GLenum target
	GLuint program
	INIT:
		loadProc(glBindProgramARB,"glBindProgramARB");

#//# glDeleteProgramsARB_c($n,(CPTR)programs);
void
glDeleteProgramsARB_c(n,programs)
	GLsizei n
	void *	programs
	INIT:
		loadProc(glDeleteProgramsARB,"glDeleteProgramsARB");
	CODE:
	{
		glDeleteProgramsARB(n,(GLuint*)programs);
	}

#//# glDeleteProgramsARB_c($n,(PACKED)programs);
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

#//# glDeleteProgramsARB_p(@programIDs);
void
glDeleteProgramsARB_p(...)
	INIT:
		loadProc(glDeleteProgramsARB,"glDeleteProgramsARB");
	CODE:
	{
		if (items) {
			GLuint * list = malloc(sizeof(GLuint) * items);
			int i;

			for (i=0;i<items;i++)
				list[i] = SvIV(ST(i));

			glDeleteProgramsARB(items, list);
			free(list);
		}
	}

#//# glGenProgramsARB_c($n,(CPTR)programs);
void
glGenProgramsARB_c(n,programs)
	GLsizei n
	void *	programs
	INIT:
		loadProc(glGenProgramsARB,"glGenProgramsARB");
	CODE:
	{
		glGenProgramsARB(n,(GLuint*)programs);
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

#//# @programIDs = glGenProgramsARB_c($n);
void
glGenProgramsARB_p(n)
	GLsizei n
	INIT:
		loadProc(glGenProgramsARB,"glGenProgramsARB");
	PPCODE:
	if (n)
	{
		GLuint * programs = malloc(sizeof(GLuint) * n);
		int i;

		glGenProgramsARB(n, programs);

		EXTEND(sp, n);
		for(i=0;i<n;i++)
			PUSHs(sv_2mortal(newSViv(programs[i])));

		free(programs);
	} 

#//# glProgramEnvParameter4dARB($target,$index,$x,$y,$z,$w);
void
glProgramEnvParameter4dARB(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLdouble x
	GLdouble y
	GLdouble z
	GLdouble w
	INIT:
		loadProc(glProgramEnvParameter4dARB,"glProgramEnvParameter4dARB");

#//# glProgramEnvParameter4dvARB_c($target,$index,(CPTR)v);
void
glProgramEnvParameter4dvARB_c(target,index,v)
	GLenum target
	GLuint index
	void *	v
	INIT:
		loadProc(glProgramEnvParameter4dvARB,"glProgramEnvParameter4dvARB");
	CODE:
		glProgramEnvParameter4dvARB(target,index,(GLdouble*)v);

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

#//!!! Do we really need this?  It duplicates glProgramEnvParameter4dARB
#//# glProgramEnvParameter4dvARB_p($target,$index,$x,$y,$z,$w);
void
glProgramEnvParameter4dvARB_p(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w
	INIT:
		loadProc(glProgramEnvParameter4dvARB,"glProgramEnvParameter4dvARB");
	CODE:
	{
		GLdouble param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glProgramEnvParameter4dvARB(target,index,param);
	}

#//# glProgramEnvParameter4fARB($target,$index,$x,$y,$z,$w);
void
glProgramEnvParameter4fARB(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLfloat x
	GLfloat y
	GLfloat z
	GLfloat w
	INIT:
		loadProc(glProgramEnvParameter4fARB,"glProgramEnvParameter4fARB");

#//# glProgramEnvParameter4fvARB_c($target,$index,(CPTR)v);
void
glProgramEnvParameter4fvARB_c(target,index,v)
	GLenum target
	GLuint index
	void *	v
	INIT:
		loadProc(glProgramEnvParameter4fvARB,"glProgramEnvParameter4fvARB");
	CODE:
		glProgramEnvParameter4fvARB(target,index,(GLfloat*)v);

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

#//!!! Do we really need this?  It duplicates glProgramEnvParameter4fARB
#//# glProgramEnvParameter4fvARB_p($target,$index,$x,$y,$z,$w);
void
glProgramEnvParameter4fvARB_p(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w
	INIT:
		loadProc(glProgramEnvParameter4fvARB,"glProgramEnvParameter4fvARB");
	CODE:
	{
		GLfloat param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glProgramEnvParameter4fvARB(target,index,param);
	}

#//# glProgramLocalParameter4dARB($target,$index,$x,$y,$z,$w);
void
glProgramLocalParameter4dARB(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLdouble x
	GLdouble y
	GLdouble z
	GLdouble w
	INIT:
		loadProc(glProgramLocalParameter4dARB,"glProgramLocalParameter4dARB");

#//# glProgramLocalParameter4dvARB_c($target,$index,(CPTR)v);
void
glProgramLocalParameter4dvARB_c(target,index,v)
	GLenum target
	GLuint index
	void *	v
	INIT:
		loadProc(glProgramLocalParameter4dvARB,"glProgramLocalParameter4dvARB");
	CODE:
		glProgramLocalParameter4dvARB(target,index,(GLdouble*)v);

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

#//!!! Do we really need this?  It duplicates glProgramLocalParameter4dARB
#//# glProgramLocalParameter4dvARB_p($target,$index,$x,$y,$z,$w);
void
glProgramLocalParameter4dvARB_p(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w
	INIT:
		loadProc(glProgramLocalParameter4dvARB,"glProgramLocalParameter4dvARB");
	CODE:
	{
		GLdouble param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glProgramLocalParameter4dvARB(target,index,param);
	}

#//# glProgramLocalParameter4fARB($target,$index,$x,$y,$z,$w);
void
glProgramLocalParameter4fARB(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLfloat x
	GLfloat y
	GLfloat z
	GLfloat w
	INIT:
		loadProc(glProgramLocalParameter4fARB,"glProgramLocalParameter4fARB");

#//# glProgramLocalParameter4fvARB_c($target,$index,(CPTR)v);
void
glProgramLocalParameter4fvARB_c(target,index,v)
	GLenum target
	GLuint index
	void *	v
	INIT:
		loadProc(glProgramLocalParameter4fvARB,"glProgramLocalParameter4fvARB");
	CODE:
		glProgramLocalParameter4fvARB(target,index,(GLfloat*)v);

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

#//!!! Do we really need this?  It duplicates glProgramLocalParameter4fARB
#//# glProgramLocalParameter4fvARB_p($target,$index,$x,$y,$z,$w);
void
glProgramLocalParameter4fvARB_p(target,index,x,y,z,w)
	GLenum target
	GLuint index
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w
	INIT:
		loadProc(glProgramLocalParameter4fvARB,"glProgramLocalParameter4fvARB");
	CODE:
	{
		GLfloat param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glProgramLocalParameter4fvARB(target,index,param);
	}

#//# glGetProgramEnvParameterdvARB_c($target,$index,(CPTR)params);
void
glGetProgramEnvParameterdvARB_c(target,index,params)
	GLenum	target
	GLint	index
	void *	params
	INIT:
		loadProc(glGetProgramEnvParameterdvARB,"glGetProgramEnvParameterdvARB");
	CODE:
		glGetProgramEnvParameterdvARB(target,index,(GLdouble*)params);

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

#//# @params = glGetProgramEnvParameterdvARB_p($target,$index);
void
glGetProgramEnvParameterdvARB_p(target,index)
	GLenum	target
	GLint	index
	INIT:
		loadProc(glGetProgramEnvParameterdvARB,"glGetProgramEnvParameterdvARB");
	PPCODE:
	{
		GLdouble params[4];
		glGetProgramEnvParameterdvARB(target,index,params);

		EXTEND(sp, 4);
		PUSHs(sv_2mortal(newSVnv(params[0])));
		PUSHs(sv_2mortal(newSVnv(params[1])));
		PUSHs(sv_2mortal(newSVnv(params[2])));
		PUSHs(sv_2mortal(newSVnv(params[3])));
	}

#//# glGetProgramEnvParameterfvARB_c($target,$index,(CPTR)params);
void
glGetProgramEnvParameterfvARB_c(target,index,params)
	GLenum	target
	GLint	index
	void *	params
	INIT:
		loadProc(glGetProgramEnvParameterfvARB,"glGetProgramEnvParameterfvARB");
	CODE:
		glGetProgramEnvParameterfvARB(target,index,(GLfloat*)params);

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

#//# @params = glGetProgramEnvParameterfvARB_p($target,$index);
void
glGetProgramEnvParameterfvARB_p(target,index)
	GLenum	target
	GLint	index
	INIT:
		loadProc(glGetProgramEnvParameterfvARB,"glGetProgramEnvParameterfvARB");
	PPCODE:
	{
		GLfloat params[4];
		glGetProgramEnvParameterfvARB(target,index,params);

		EXTEND(sp, 4);
		PUSHs(sv_2mortal(newSVnv(params[0])));
		PUSHs(sv_2mortal(newSVnv(params[1])));
		PUSHs(sv_2mortal(newSVnv(params[2])));
		PUSHs(sv_2mortal(newSVnv(params[3])));
	}

#//# glGetProgramLocalParameterdvARB_c($target,$index,(CPTR)params);
void
glGetProgramLocalParameterdvARB_c(target,index,params)
	GLenum	target
	GLint	index
	void *	params
	INIT:
		loadProc(glGetProgramLocalParameterdvARB,"glGetProgramLocalParameterdvARB");
	CODE:
		glGetProgramLocalParameterdvARB(target,index,(GLdouble*)params);

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

#//# @params = glGetProgramLocalParameterdvARB_p($target,$index);
void
glGetProgramLocalParameterdvARB_p(target,index)
	GLenum	target
	GLint	index
	INIT:
		loadProc(glGetProgramLocalParameterdvARB,"glGetProgramLocalParameterdvARB");
	PPCODE:
	{
		GLdouble params[4];
		glGetProgramLocalParameterdvARB(target,index,params);

		EXTEND(sp, 4);
		PUSHs(sv_2mortal(newSVnv(params[0])));
		PUSHs(sv_2mortal(newSVnv(params[1])));
		PUSHs(sv_2mortal(newSVnv(params[2])));
		PUSHs(sv_2mortal(newSVnv(params[3])));
	}

#//# glGetProgramLocalParameterfvARB_c($target,$index,(CPTR)params);
void
glGetProgramLocalParameterfvARB_c(target,index,params)
	GLenum	target
	GLint	index
	void *	params
	INIT:
		loadProc(glGetProgramLocalParameterfvARB,"glGetProgramLocalParameterfvARB");
	CODE:
		glGetProgramLocalParameterfvARB(target,index,(GLfloat*)params);

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

#//# @params = glGetProgramLocalParameterfvARB_p($target,$index);
void
glGetProgramLocalParameterfvARB_p(target,index)
	GLenum	target
	GLint	index
	INIT:
		loadProc(glGetProgramLocalParameterfvARB,"glGetProgramLocalParameterfvARB");
	PPCODE:
	{
		GLfloat params[4];
		glGetProgramLocalParameterfvARB(target,index,params);

		EXTEND(sp, 4);
		PUSHs(sv_2mortal(newSVnv(params[0])));
		PUSHs(sv_2mortal(newSVnv(params[1])));
		PUSHs(sv_2mortal(newSVnv(params[2])));
		PUSHs(sv_2mortal(newSVnv(params[3])));
	}

#//# glGetProgramivARB_c($target,$pname,(CPTR)params);
void
glGetProgramivARB_c(target,pname,params)
	GLenum	target
	GLenum	pname
	void *	params
	INIT:
		loadProc(glGetProgramivARB,"glGetProgramivARB");
	CODE:
		glGetProgramivARB(target,pname,params);

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
		GLint * params_s = EL(params, sizeof(GLint)*gl_get_count(pname));
		glGetProgramivARB(target,pname,params_s);
	}

#//# $value = glGetProgramivARB_p($target,$pname);
GLuint
glGetProgramivARB_p(target,pname)
	GLenum	target
	GLenum	pname
	INIT:
		loadProc(glGetProgramivARB,"glGetProgramivARB");
	CODE:
	{
		GLuint param;
		glGetProgramivARB(target,pname,(void *)&param);
		RETVAL = param;
	}
	OUTPUT:
		RETVAL

#//# glGetProgramStringARB_c(target,pname,(CPTR)string);
void
glGetProgramStringARB_c(target,pname,string)
	GLenum	target
	GLenum	pname
	void *	string
	INIT:
		loadProc(glGetProgramStringARB,"glGetProgramStringARB");
	CODE:
		glGetProgramStringARB(target,pname,string);

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

#//# glIsProgramARB(program);
GLboolean
glIsProgramARB(program)
	GLuint	program
	INIT:
		loadProc(glIsProgramARB,"glIsProgramARB");
	CODE:
	{
		RETVAL = glIsProgramARB(program);
	}
	OUTPUT:
		RETVAL

#endif


#if defined(GL_ARB_vertex_program) || defined(GL_ARB_vertex_shader)

#//# glVertexAttrib1dARB($index,$x);
void
glVertexAttrib1dARB(index,x)
	GLuint index
	GLdouble x
	INIT:
		loadProc(glVertexAttrib1dARB,"glVertexAttrib1dARB");

#//# glVertexAttrib1dvARB_c($index,(CPTR)v);
void
glVertexAttrib1dvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib1dvARB,"glVertexAttrib1dvARB");
	CODE:
		glVertexAttrib1dvARB(index,(GLdouble*)v);

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

#//!!! Do we really need this?  It duplicates glVertexAttrib1dARB
#//# glVertexAttrib1dvARB_p($index,$x);
void
glVertexAttrib1dvARB_p(index,x)
	GLuint index
	GLdouble	x
	INIT:
		loadProc(glVertexAttrib1dvARB,"glVertexAttrib1dvARB");
	CODE:
	{
		GLdouble param[1];
		param[0] = x;
		glVertexAttrib1dvARB(index,param);
	}

#//# glVertexAttrib1fARB($index,$x);
void
glVertexAttrib1fARB(index,x)
	GLuint index
	GLfloat x
	INIT:
		loadProc(glVertexAttrib1fARB,"glVertexAttrib1fARB");

#//# glVertexAttrib1sARB($index,$x);
void
glVertexAttrib1sARB(index,x)
	GLuint index
	GLshort x
	INIT:
		loadProc(glVertexAttrib1s,"glVertexAttrib1s");

#//# glVertexAttrib1svARB_c($index,(CPTR)v);
void
glVertexAttrib1svARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib1svARB,"glVertexAttrib1svARB");
	CODE:
		glVertexAttrib1svARB(index,(GLshort*)v);

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

#//!!! Do we really need this?  It duplicates glVertexAttrib1sARB
#//# glVertexAttrib1svARB_p($index,$x);
void
glVertexAttrib1svARB_p(index,x)
	GLuint index
	GLshort	x
	INIT:
		loadProc(glVertexAttrib1svARB,"glVertexAttrib1svARB");
	CODE:
	{
		GLshort param[1];
		param[0] = x;
		glVertexAttrib1svARB(index,param);
	}

#//# glVertexAttrib2dARB($index,$x,$y);
void
glVertexAttrib2dARB(index,x,y)
	GLuint index
	GLdouble x
	GLdouble y
	INIT:
		loadProc(glVertexAttrib2dARB,"glVertexAttrib2dARB");

#//# glVertexAttrib2dvARB_c($index,(CPTR)v);
void
glVertexAttrib2dvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib2dvARB,"glVertexAttrib2dvARB");
	CODE:
		glVertexAttrib2dvARB(index,(GLdouble*)v);

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

#//!!! Do we really need this?  It duplicates glVertexAttrib2dARB
#//# glVertexAttrib2dvARB_p($index,$x,$y);
void
glVertexAttrib2dvARB_p(index,x,y)
	GLuint index
	GLdouble	x
	GLdouble	y
	INIT:
		loadProc(glVertexAttrib2dvARB,"glVertexAttrib2dvARB");
	CODE:
	{
		GLdouble param[2];
		param[0] = x;
		param[1] = y;
		glVertexAttrib2dvARB(index,param);
	}

#//# glVertexAttrib2fARB($index,$x,$y);
void
glVertexAttrib2fARB(index,x,y)
	GLuint index
	GLfloat x
	GLfloat y
	INIT:
		loadProc(glVertexAttrib2fARB,"glVertexAttrib2fARB");

#//# glVertexAttrib2sARB($index,$x,$y);
void
glVertexAttrib2sARB(index,x,y)
	GLuint index
	GLshort x
	GLshort y
	INIT:
		loadProc(glVertexAttrib2sARB,"glVertexAttrib2sARB");

#//# glVertexAttrib2svARB_c($index,(CPTR)v);
void
glVertexAttrib2svARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib2svARB,"glVertexAttrib2svARB");
	CODE:
		glVertexAttrib2svARB(index,(GLshort*)v);

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

#//!!! Do we really need this?  It duplicates glVertexAttrib2sARB
#//# glVertexAttrib2svARB_p($index,$x,$y);
void
glVertexAttrib2svARB_p(index,x,y)
	GLuint index
	GLshort	x
	GLshort	y
	INIT:
		loadProc(glVertexAttrib2svARB,"glVertexAttrib2svARB");
	CODE:
	{
		GLshort param[2];
		param[0] = x;
		param[1] = y;
		glVertexAttrib2svARB(index,param);
	}

#//# glVertexAttrib3dARB($index,$x,$y,$z);
void
glVertexAttrib3dARB(index,x,y,z)
	GLuint index
	GLdouble x
	GLdouble y
	GLdouble z
	INIT:
		loadProc(glVertexAttrib3dARB,"glVertexAttrib3dARB");

#//# glVertexAttrib3dvARB_c($index,(CPTR)v);
void
glVertexAttrib3dvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib3dvARB,"glVertexAttrib3dvARB");
	CODE:
		glVertexAttrib3dvARB(index,(GLdouble*)v);

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

#//!!! Do we really need this?  It duplicates glVertexAttrib3dARB
#//# glVertexAttrib3dvARB_p($index,$x,$y,$z);
void
glVertexAttrib3dvARB_p(index,x,y,z)
	GLuint index
	GLdouble	x
	GLdouble	y
	GLdouble	z
	INIT:
		loadProc(glVertexAttrib3dvARB,"glVertexAttrib3dvARB");
	CODE:
	{
		GLdouble param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertexAttrib3dvARB(index,param);
	}

#//# glVertexAttrib3fARB($index,$x,$y,$z);
void
glVertexAttrib3fARB(index,x,y,z)
	GLuint index
	GLfloat x
	GLfloat y
	GLfloat z
	INIT:
		loadProc(glVertexAttrib3fARB,"glVertexAttrib3fARB");

#//# glVertexAttrib3fvARB_c($index,(CPTR)v);
void
glVertexAttrib3fvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib3fvARB,"glVertexAttrib3fvARB");
	CODE:
		glVertexAttrib3fvARB(index,(GLfloat*)v);

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

#//!!! Do we really need this?  It duplicates glVertexAttrib3fARB
#//# glVertexAttrib3fvARB_p($index,$x,$y,$z);
void
glVertexAttrib3fvARB_p(index,x,y,z)
	GLuint index
	GLfloat	x
	GLfloat	y
	GLfloat	z
	INIT:
		loadProc(glVertexAttrib3fvARB,"glVertexAttrib3fvARB");
	CODE:
	{
		GLfloat param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertexAttrib3fvARB(index,param);
	}

#//# glVertexAttrib3sARB($index,$x,$y,$z);
void
glVertexAttrib3sARB(index,x,y,z)
	GLuint index
	GLshort x
	GLshort y
	GLshort z
	INIT:
		loadProc(glVertexAttrib3sARB,"glVertexAttrib3sARB");

#//# glVertexAttrib3svARB_c($index,(CPTR)v);
void
glVertexAttrib3svARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib3svARB,"glVertexAttrib3svARB");
	CODE:
		glVertexAttrib3svARB(index,(GLshort*)v);

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

#//!!! Do we really need this?  It duplicates glVertexAttrib3sARB
#//# glVertexAttrib3svARB_p($index,$x,$y,$z);
void
glVertexAttrib3svARB_p(index,x,y,z)
	GLuint index
	GLshort	x
	GLshort	y
	GLshort	z
	INIT:
		loadProc(glVertexAttrib3svARB,"glVertexAttrib3svARB");
	CODE:
	{
		GLshort param[3];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		glVertexAttrib3svARB(index,param);
	}

#//# glVertexAttrib4NbvARB_c($index,(CPTR)v);
void
glVertexAttrib4NbvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NbvARB,"glVertexAttrib4NbvARB");
	CODE:
		glVertexAttrib4NbvARB(index,(GLbyte*)v);

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

#//# glVertexAttrib4NbvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NbvARB_p(index,x,y,z,w)
	GLuint index
	GLbyte	x
	GLbyte	y
	GLbyte	z
	GLbyte	w
	INIT:
		loadProc(glVertexAttrib4NbvARB,"glVertexAttrib4NbvARB");
	CODE:
	{
		GLbyte param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NbvARB(index,param);
	}

#//# glVertexAttrib4NivARB_c($index,(CPTR)v);
void
glVertexAttrib4NivARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NivARB,"glVertexAttrib4NivARB");
	CODE:
		glVertexAttrib4NivARB(index,(GLint*)v);

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

#//# glVertexAttrib4NivARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NivARB_p(index,x,y,z,w)
	GLuint index
	GLint	x
	GLint	y
	GLint	z
	GLint	w
	INIT:
		loadProc(glVertexAttrib4NivARB,"glVertexAttrib4NivARB");
	CODE:
	{
		GLint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NivARB(index,param);
	}

#//# glVertexAttrib4NsvARB_c($index,(CPTR)v);
void
glVertexAttrib4NsvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NsvARB,"glVertexAttrib4NsvARB");
	CODE:
		glVertexAttrib4NsvARB(index,(GLshort*)v);

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

#//# glVertexAttrib4NsvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NsvARB_p(index,x,y,z,w)
	GLuint index
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w
	INIT:
		loadProc(glVertexAttrib4NsvARB,"glVertexAttrib4NsvARB");
	CODE:
	{
		GLshort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NsvARB(index,param);
	}

#//# glVertexAttrib4NubARB($index,$x,$y,$z,$w);
void
glVertexAttrib4NubARB(index,x,y,z,w)
	GLuint index
	GLubyte x
	GLubyte y
	GLubyte z
	GLubyte w
	INIT:
		loadProc(glVertexAttrib4NubARB,"glVertexAttrib4NubARB");

#//# glVertexAttrib4NubvARB_c($index,(CPTR)v);
void
glVertexAttrib4NubvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NubvARB,"glVertexAttrib4NubvARB");
	CODE:
		glVertexAttrib4NubvARB(index,(GLubyte*)v);

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

#//# glVertexAttrib4NubvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NubvARB_p(index,x,y,z,w)
	GLuint index
	GLubyte	x
	GLubyte	y
	GLubyte	z
	GLubyte	w
	INIT:
		loadProc(glVertexAttrib4NubvARB,"glVertexAttrib4NubvARB");
	CODE:
	{
		GLubyte param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NubvARB(index,param);
	}

#//# glVertexAttrib4NuivARB_c($index,(CPTR)v);
void
glVertexAttrib4NuivARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NuivARB,"glVertexAttrib4NuivARB");
	CODE:
		glVertexAttrib4NuivARB(index,(GLuint*)v);

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

#//# glVertexAttrib4NuivARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NuivARB_p(index,x,y,z,w)
	GLuint index
	GLuint	x
	GLuint	y
	GLuint	z
	GLuint	w
	INIT:
		loadProc(glVertexAttrib4NuivARB,"glVertexAttrib4NuivARB");
	CODE:
	{
		GLuint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NuivARB(index,param);
	}

#//# glVertexAttrib4NusvARB_c($index,(CPTR)v);
void
glVertexAttrib4NusvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4NusvARB,"glVertexAttrib4NusvARB");
	CODE:
		glVertexAttrib4NusvARB(index,(GLushort*)v);

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

#//# glVertexAttrib4NusvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4NusvARB_p(index,x,y,z,w)
	GLuint index
	GLushort	x
	GLushort	y
	GLushort	z
	GLushort	w
	INIT:
		loadProc(glVertexAttrib4NusvARB,"glVertexAttrib4NusvARB");
	CODE:
	{
		GLushort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4NusvARB(index,param);
	}

#//# glVertexAttrib4bvARB_c($index,(CPTR)v);
void
glVertexAttrib4bvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4bvARB,"glVertexAttrib4bvARB");
	CODE:
		glVertexAttrib4bvARB(index,(GLbyte*)v);

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

#//# glVertexAttrib4bvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4bvARB_p(index,x,y,z,w)
	GLuint index
	GLbyte	x
	GLbyte	y
	GLbyte	z
	GLbyte	w
	INIT:
		loadProc(glVertexAttrib4bvARB,"glVertexAttrib4bvARB");
	CODE:
	{
		GLbyte param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4bvARB(index,param);
	}

#//# glVertexAttrib4dARB($index,$x,$y,$z,$w);
void
glVertexAttrib4dARB(index,x,y,z,w)
	GLuint index
	GLdouble x
	GLdouble y
	GLdouble z
	GLdouble w
	INIT:
		loadProc(glVertexAttrib4dARB,"glVertexAttrib4dARB");

#//# glVertexAttrib4dvARB_c($index,(CPTR)v);
void
glVertexAttrib4dvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4dvARB,"glVertexAttrib4dvARB");
	CODE:
		glVertexAttrib4dvARB(index,(GLdouble*)v);

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

#//!!! Do we really need this?  It duplicates glVertexAttrib4dARB
#//# glVertexAttrib4dvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4dvARB_p(index,x,y,z,w)
	GLuint index
	GLdouble	x
	GLdouble	y
	GLdouble	z
	GLdouble	w
	INIT:
		loadProc(glVertexAttrib4dvARB,"glVertexAttrib4dvARB");
	CODE:
	{
		GLdouble param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4dvARB(index,param);
	}

#//# glVertexAttrib4fARB($index,$x,$y,$z,$w);
void
glVertexAttrib4fARB(index,x,y,z,w)
	GLuint index
	GLfloat x
	GLfloat y
	GLfloat z
	GLfloat w
	INIT:
		loadProc(glVertexAttrib4fARB,"glVertexAttrib4fARB");

#//# glVertexAttrib4fvARB_c($index,(CPTR)v);
void
glVertexAttrib4fvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4fvARB,"glVertexAttrib4fvARB");
	CODE:
		glVertexAttrib4fvARB(index,(GLfloat*)v);

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

#//!!! Do we really need this?  It duplicates glVertexAttrib4fARB
#//# glVertexAttrib4fvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4fvARB_p(index,x,y,z,w)
	GLuint index
	GLfloat	x
	GLfloat	y
	GLfloat	z
	GLfloat	w
	INIT:
		loadProc(glVertexAttrib4fvARB,"glVertexAttrib4fvARB");
	CODE:
	{
		GLfloat param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4fvARB(index,param);
	}

#//# glVertexAttrib4ivARB_c($index,(CPTR)v);
void
glVertexAttrib4ivARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4ivARB,"glVertexAttrib4ivARB");
	CODE:
		glVertexAttrib4ivARB(index,(GLint*)v);

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

#//# glVertexAttrib4ivARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4ivARB_p(index,x,y,z,w)
	GLuint index
	GLint	x
	GLint	y
	GLint	z
	GLint	w
	INIT:
		loadProc(glVertexAttrib4ivARB,"glVertexAttrib4ivARB");
	CODE:
	{
		GLint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4ivARB(index,param);
	}

#//# glVertexAttrib4sARB($index,$x,$y,$z,$w);
void
glVertexAttrib4sARB(index,x,y,z,w)
	GLuint index
	GLshort x
	GLshort y
	GLshort z
	GLshort w
	INIT:
		loadProc(glVertexAttrib4sARB,"glVertexAttrib4sARB");

#//# glVertexAttrib4svARB_c($index,(CPTR)v);
void
glVertexAttrib4svARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4svARB,"glVertexAttrib4svARB");
	CODE:
		glVertexAttrib4svARB(index,(GLshort*)v);

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

#//!!! Do we really need this?  It duplicates glVertexAttrib4sARB
#//# glVertexAttrib4svARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4svARB_p(index,x,y,z,w)
	GLuint index
	GLshort	x
	GLshort	y
	GLshort	z
	GLshort	w
	INIT:
		loadProc(glVertexAttrib4svARB,"glVertexAttrib4svARB");
	CODE:
	{
		GLshort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4svARB(index,param);
	}

#//# glVertexAttrib4ubvARB_c($index,(CPTR)v);
void
glVertexAttrib4ubvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4ubvARB,"glVertexAttrib4ubvARB");
	CODE:
		glVertexAttrib4ubvARB(index,(GLubyte*)v);

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

#//# glVertexAttrib4ubvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4ubvARB_p(index,x,y,z,w)
	GLuint index
	GLubyte	x
	GLubyte	y
	GLubyte	z
	GLubyte	w
	INIT:
		loadProc(glVertexAttrib4ubvARB,"glVertexAttrib4ubvARB");
	CODE:
	{
		GLubyte param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4ubvARB(index,param);
	}

#//# glVertexAttrib4uivARB_c($index,(CPTR)v);
void
glVertexAttrib4uivARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4uivARB,"glVertexAttrib4uivARB");
	CODE:
		glVertexAttrib4uivARB(index,(GLuint*)v);

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

#//# glVertexAttrib4uivARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4uivARB_p(index,x,y,z,w)
	GLuint index
	GLuint	x
	GLuint	y
	GLuint	z
	GLuint	w
	INIT:
		loadProc(glVertexAttrib4uivARB,"glVertexAttrib4uivARB");
	CODE:
	{
		GLuint param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4uivARB(index,param);
	}

#//# glVertexAttrib4usvARB_c($index,(CPTR)v);
void
glVertexAttrib4usvARB_c(index,v)
	GLuint index
	void *	v
	INIT:
		loadProc(glVertexAttrib4usvARB,"glVertexAttrib4usvARB");
	CODE:
		glVertexAttrib4usvARB(index,(GLushort*)v);

#//# glVertexAttrib4usvARB_c($index,(PACKED)v);
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

#//# glVertexAttrib4usvARB_p($index,$x,$y,$z,$w);
void
glVertexAttrib4usvARB_p(index,x,y,z,w)
	GLuint index
	GLushort	x
	GLushort	y
	GLushort	z
	GLushort	w
	INIT:
		loadProc(glVertexAttrib4usvARB,"glVertexAttrib4usvARB");
	CODE:
	{
		GLushort param[4];
		param[0] = x;
		param[1] = y;
		param[2] = z;
		param[3] = w;
		glVertexAttrib4usvARB(index,param);
	}

#//# glVertexAttribPointerARB_c($index,$size,$type,$normalized,$stride,(CPTR)pointer);
void
glVertexAttribPointerARB_c(index,size,type,normalized,stride,pointer)
	GLuint index
	GLint size
	GLenum type
	GLboolean normalized
	GLsizei stride
	void * pointer
	INIT:
		loadProc(glVertexAttribPointerARB,"glVertexAttribPointerARB");
	CODE:
		glVertexAttribPointerARB(index,size,type,
			normalized,stride,pointer);

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
		GLuint size = gl_type_size(type);
		void * pointer = malloc(count * size);

		SvItems(type,4,count,pointer);

		glVertexAttribPointerARB(index,count,type,
			normalized,stride,pointer);

		free(pointer);
	}

#//# glEnableVertexAttribArrayARB($index);
void
glEnableVertexAttribArrayARB(index)
	GLuint index
	INIT:
		loadProc(glEnableVertexAttribArrayARB,"glEnableVertexAttribArrayARB");

#//# glDisableVertexAttribArrayARB($index);
void
glDisableVertexAttribArrayARB(index)
	GLuint index
	INIT:
		loadProc(glDisableVertexAttribArrayARB,"glDisableVertexAttribArrayARB");

#//# glGetVertexAttribdvARB_c($index,$pname,(CPTR)params);
void
glGetVertexAttribdvARB_c(index,pname,params)
	GLuint	index
	GLenum	pname
	void *	params
	INIT:
		loadProc(glGetVertexAttribdvARB,"glGetVertexAttribdvARB");
	CODE:
		glGetVertexAttribdvARB(index,pname,(GLdouble*)params);

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

#//# $param = glGetVertexAttribdvARB_p($index,$pname);
GLdouble
glGetVertexAttribdvARB_p(index,pname)
	GLuint	index
	GLenum	pname
	INIT:
		loadProc(glGetVertexAttribdvARB,"glGetVertexAttribdvARB");
	CODE:
	{
		GLdouble param;
		glGetVertexAttribdvARB(index,pname,(void *)&param);
		RETVAL = param;
	}
	OUTPUT:
		RETVAL

#//# glGetVertexAttribfvARB_c($index,$pname,(CPTR)params);
void
glGetVertexAttribfvARB_c(index,pname,params)
	GLuint	index
	GLenum	pname
	void *	params
	INIT:
		loadProc(glGetVertexAttribfvARB,"glGetVertexAttribfvARB");
	CODE:
		glGetVertexAttribfvARB(index,pname,(GLfloat*)params);

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

#//# $param = glGetVertexAttribfvARB_p($index,$pname);
GLfloat
glGetVertexAttribfvARB_p(index,pname)
	GLuint	index
	GLenum	pname
	INIT:
		loadProc(glGetVertexAttribfvARB,"glGetVertexAttribfvARB");
	CODE:
	{
		GLfloat param;
		glGetVertexAttribfvARB(index,pname,(void *)&param);
		RETVAL = param;
	}
	OUTPUT:
		RETVAL

#//# glGetVertexAttribivARB_c($index,$pname,(CPTR)params);
void
glGetVertexAttribivARB_c(index,pname,params)
	GLuint	index
	GLenum	pname
	void *	params
	INIT:
		loadProc(glGetVertexAttribivARB,"glGetVertexAttribivARB");
	CODE:
		glGetVertexAttribivARB(index,pname,(GLint*)params);

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

#//# $param = glGetVertexAttribivARB_p($index,$pname);
GLuint
glGetVertexAttribivARB_p(index,pname)
	GLuint	index
	GLenum	pname
	INIT:
		loadProc(glGetVertexAttribivARB,"glGetVertexAttribivARB");
	CODE:
	{
		GLuint param;
		glGetVertexAttribivARB(index,pname,(void *)&param);
		RETVAL = param;
	}
	OUTPUT:
		RETVAL

#//# glGetVertexAttribPointervARB_c($index,$pname,(CPTR)pointer);
void
glGetVertexAttribPointervARB_c(index,pname,pointer)
	GLuint	index
	GLenum	pname
	void *	pointer
	INIT:
		loadProc(glGetVertexAttribPointervARB,"glGetVertexAttribPointervARB");
	CODE:
		glGetVertexAttribPointervARB(index,pname,pointer);

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

#//# glBindAttribLocationARB($programObj, $index, $name);
void
glBindAttribLocationARB(programObj, index, name)
	GLhandleARB programObj
	GLuint index
	void *name
	INIT:
		loadProc(glBindAttribLocationARB,"glBindAttribLocationARB");
	CODE:
		glBindAttribLocationARB(programObj,index,name);

#//# glGetActiveAttribARB_c($programObj, $index, $maxLength, (CPTR)length, (CPTR)size, (CPTR)type, (CPTR)name);
void
glGetActiveAttribARB_c(programObj, index, maxLength, length, size, type, name)
	GLhandleARB programObj
	GLuint	index
	GLsizei	maxLength
	void	*length
	void	*size
	void	*type
	void	*name
	INIT:
		loadProc(glGetActiveAttribARB,"glGetActiveAttribARB");
	CODE:
		glGetActiveAttribARB(programObj,index,maxLength,length,size,type,name);

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

#//# ($name,$type,$size) = glGetActiveAttribARB_p($programObj, $index);
void
glGetActiveAttribARB_p(programObj, index)
	GLhandleARB programObj
	GLuint index
	INIT:
		loadProc(glGetObjectParameterivARB,"glGetObjectParameterivARB");
		loadProc(glGetActiveAttribARB,"glGetActiveAttribARB");
	PPCODE:
	{
		GLsizei maxLength;
		glGetObjectParameterivARB(programObj,GL_OBJECT_ACTIVE_ATTRIBUTES_ARB,
			(GLvoid *)&maxLength);
		if (maxLength)
		{
			GLsizei length;
			GLint size;
			GLenum type;
			GLcharARB *name;

			name = malloc(maxLength+1);
			glGetActiveAttribARB(programObj,index,maxLength,
				&length,&size,&type,name);
			name[length] = 0;

			if (*name)
			{
				EXTEND(sp,3);
				PUSHs(sv_2mortal(newSVpv(name,0)));
				PUSHs(sv_2mortal(newSViv(type)));
				PUSHs(sv_2mortal(newSViv(size)));
			}
			else
			{
				EXTEND(sp,1);
				PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
			}

			free(name);
		}
		else
		{
			EXTEND(sp,1);
			PUSHs(sv_2mortal(newSVsv(&PL_sv_undef)));
		}
	}

#//# glGetAttribLocationARB_c($programObj, (CPTR)name);
GLint
glGetAttribLocationARB_c(programObj, name)
	GLhandleARB programObj
	void	*name
	INIT:
		loadProc(glGetAttribLocationARB,"glGetAttribLocationARB");
	CODE:
		RETVAL = glGetAttribLocationARB(programObj, name);
	OUTPUT:
		RETVAL

#//!!! Since pointer is string, should combine _C and _p
#//# $value = glGetAttribLocationARB_p(programObj, $name);
GLint
glGetAttribLocationARB_p(programObj, ...)
	GLhandleARB programObj
	INIT:
		loadProc(glGetAttribLocationARB,"glGetAttribLocationARB");
	CODE:
	{
		GLcharARB *name = (GLcharARB *)SvPV(ST(1),PL_na);
		RETVAL = glGetAttribLocationARB(programObj, name);
	}
	OUTPUT:
		RETVAL

#endif


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

#endif /* End IN_POGL_GL_XS */

##################### GLU #########################

#ifdef IN_POGL_GLU_XS

#ifdef HAVE_GLU

#// $nurb->gluBeginCurve($nurb);
void
gluBeginCurve(nurb)
	GLUnurbsObj *	nurb

#// gluEndCurve($nurb);
void
gluEndCurve(nurb)
	GLUnurbsObj *	nurb

#// gluBeginPolygon($tess);
void
gluBeginPolygon(tess)
	PGLUtess *	tess
	CODE:
	gluBeginPolygon(tess->triangulator);

#// gluEndPolygon($tess);
void
gluEndPolygon(tess)
	PGLUtess *	tess
	CODE:
	gluEndPolygon(tess->triangulator);

#// gluBeginSurface($nurb);
void
gluBeginSurface(nurb)
	GLUnurbsObj *	nurb

#// gluEndSurface($nurb);
void
gluEndSurface(nurb)
	GLUnurbsObj *	nurb

#// gluBeginTrim($nurb);
void
gluBeginTrim(nurb)
	GLUnurbsObj *	nurb

#// gluEndTrim($nurb);
void
gluEndTrim(nurb)
	GLUnurbsObj *	nurb

#//# gluBuild1DMipmaps_c($target, $internalformat, $width, $format, $type, (CPTR)data);
GLint
gluBuild1DMipmaps_c(target, internalformat, width, format, type, data)
	GLenum	target
	GLuint	internalformat
	GLsizei	width
	GLenum	format
	GLenum	type
	void *	data
	CODE:
	{
		RETVAL=gluBuild1DMipmaps(target, internalformat,
			width, format, type, data);
	}
	OUTPUT:
	  RETVAL

#//# gluBuild1DMipmaps_s($target, $internalformat, $width, $format, $type, (PACKED)data);
GLint
gluBuild1DMipmaps_s(target, internalformat, width, format, type, data)
	GLenum	target
	GLuint	internalformat
	GLsizei	width
	GLenum	format
	GLenum	type
	SV *	data
	CODE:
	{
	GLvoid * ptr = ELI(data, width, 1, format, type, gl_pixelbuffer_unpack);
	RETVAL=gluBuild1DMipmaps(target, internalformat, width, format, type, ptr);
	}
	OUTPUT:
	  RETVAL

#//# gluBuild2DMipmaps_c($target, $internalformat, $width, $height, $format, $type, (CPTR)data);
GLint
gluBuild2DMipmaps_c(target, internalformat, width, height, format, type, data)
	GLenum	target
	GLuint	internalformat
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	void *	data
	CODE:
	{
		RETVAL=gluBuild2DMipmaps(target, internalformat,
			width, height, format, type, data);
	}
	OUTPUT:
	  RETVAL

#//# gluBuild2DMipmaps_s($target, $internalformat, $width, $height, $format, $type, (PACKED)data);
GLint
gluBuild2DMipmaps_s(target, internalformat, width, height, format, type, data)
	GLenum	target
	GLuint	internalformat
	GLsizei	width
	GLsizei	height
	GLenum	format
	GLenum	type
	SV *	data
	CODE:
	{
	GLvoid * ptr = ELI(data, width, height, format, type, gl_pixelbuffer_unpack);
	RETVAL=gluBuild2DMipmaps(target, internalformat, width, height, format, type, ptr);
	}
	OUTPUT:
	  RETVAL

#// gluCylinder($quad, $base, $top, $height, $slices, $stacks);
void
gluCylinder(quad, base, top, height, slices, stacks)
	GLUquadricObj *	quad
	GLdouble	base
	GLdouble	top
	GLdouble	height
	GLint	slices
	GLint	stacks

#// gluDeleteNurbsRenderer($nurb);
void
gluDeleteNurbsRenderer(nurb)
	GLUnurbsObj *	nurb

#// gluDeleteQuadric($quad);
void
gluDeleteQuadric(quad)
	GLUquadricObj *	quad

#// gluDeleteTess($tess);
void
gluDeleteTess(tess)
	PGLUtess *	tess
	CODE:
	{
		if (tess->triangulator)
			gluDeleteTess(tess->triangulator);
#ifdef GLU_VERSION_1_2
		if (tess->polygon_data_av)
			SvREFCNT_dec(tess->polygon_data_av);
		if (tess->begin_callback)
			SvREFCNT_dec(tess->begin_callback);
		if (tess->edgeFlag_callback)
			SvREFCNT_dec(tess->edgeFlag_callback);
		if (tess->vertex_callback)
			SvREFCNT_dec(tess->vertex_callback);
		if (tess->end_callback)
			SvREFCNT_dec(tess->end_callback);
		if (tess->error_callback)
			SvREFCNT_dec(tess->error_callback);
		if (tess->combine_callback)
			SvREFCNT_dec(tess->combine_callback);
		if (tess->vertex_datas)
			SvREFCNT_dec(tess->vertex_datas);
#endif
		free(tess);
	}

#// gluDisk($quad, $inner, $outer, $slices, $loops);
void
gluDisk(quad, inner, outer, slices, loops)
	GLUquadricObj *	quad
	GLdouble	inner
	GLdouble	outer
	GLint	slices
	GLint	loops

#//# gluErrorString($error);
char *
gluErrorString(error)
	GLenum	error
	CODE:
	RETVAL = (char*)gluErrorString(error);
	OUTPUT:
	RETVAL

#// gluGetNurbsProperty_p($nurb, $property);
GLfloat
gluGetNurbsProperty_p(nurb, property)
	GLUnurbsObj *	nurb
	GLenum	property
	CODE:
	{
		GLfloat param;
		gluGetNurbsProperty(nurb, property, &param);
		RETVAL = param;
	}
	OUTPUT:
	RETVAL

#// gluNurbsProperty(nurb, property, value);
void
gluNurbsProperty(nurb, property, value)
	GLUnurbsObj *	nurb
	GLenum	property
	GLfloat value

#ifdef GLU_VERSION_1_1

#//# gluGetString($name);
char *
gluGetString(name)
	GLenum	name
	CODE:
	RETVAL = (char*)gluGetString(name);
	OUTPUT:
	RETVAL

#endif

#// gluLoadSamplingMatrices_p(nurb, m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16, o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16, v1,v2,v3,v4);
void
gluLoadSamplingMatrices_p(nurb, m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16, o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16, v1,v2,v3,v4)
	GLUnurbsObj *	nurb
	CODE:
	{
		GLfloat m[16], p[16];
		GLint v[4];
		int i;
		for (i=0;i<16;i++)
			m[i] = (GLfloat)SvNV(ST(i+1));
		for (i=0;i<16;i++)
			p[i] = (GLfloat)SvNV(ST(i+1+16));
		for (i=0;i<4;i++)
			v[i] = SvIV(ST(i+1+16+16));
		gluLoadSamplingMatrices(nurb, m, p, v);
	}

#//# gluLookAt($eyeX, $eyeY, $eyeZ, $centerX, $centerY, $centerZ, $upX, $upY, $upZ);
void
gluLookAt(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ)
	GLdouble	eyeX
	GLdouble	eyeY
	GLdouble	eyeZ
	GLdouble	centerX
	GLdouble	centerY
	GLdouble	centerZ
	GLdouble	upX
	GLdouble	upY
	GLdouble	upZ

#// gluNewNurbsRenderer();
GLUnurbsObj *
gluNewNurbsRenderer()

#// gluNewQuadric();
GLUquadricObj *
gluNewQuadric()

#// gluNewTess();
PGLUtess *
gluNewTess()
	CODE:
	{
		RETVAL = calloc(sizeof(PGLUtess), 1);
		RETVAL->triangulator = gluNewTess();
	}
	OUTPUT:
	RETVAL

#// gluNextContour(tess, type);
void
gluNextContour(tess, type)
	PGLUtess *	tess
	GLenum	type
	CODE:
	gluNextContour(tess->triangulator, type);

#// gluNurbsCurve_c(nurb, nknots, knot, stride, ctlarray, order, type);
void
gluNurbsCurve_c(nurb, nknots, knot, stride, ctlarray, order, type)
	GLUnurbsObj *	nurb
	GLint	nknots
	void *	knot
	GLint	stride
	void *	ctlarray
	GLint	order
	GLenum	type
	CODE:
	gluNurbsCurve(nurb, nknots, knot, stride, ctlarray, order, type);

#// gluNurbsSurface_c(nurb, sknot_count, sknot, tknot_count, tknot, s_stride, t_stride, ctrlarray, sorder, torder, type);
void
gluNurbsSurface_c(nurb, sknot_count, sknot, tknot_count, tknot, s_stride, t_stride, ctrlarray, sorder, torder, type)
	GLUnurbsObj *	nurb
	GLint	sknot_count
	void *	sknot
	GLint	tknot_count
	void *	tknot
	GLint	s_stride
	GLint	t_stride
	void *	ctrlarray
	GLint	sorder
	GLint	torder
	GLenum	type
	CODE:
	gluNurbsSurface(nurb, sknot_count, sknot, tknot_count, tknot, s_stride, t_stride, ctrlarray, sorder, torder, type);

#//# gluOrtho2D($left, $right, $bottom, $top);
void
gluOrtho2D(left, right, bottom, top)
	GLdouble	left
	GLdouble	right
	GLdouble	bottom
	GLdouble	top

#// gluPartialDisk(quad, inner, outer, slices, loops, start, sweep);
void
gluPartialDisk(quad, inner, outer, slices, loops, start, sweep)
	GLUquadricObj*	quad
	GLdouble	inner
	GLdouble	outer
	GLint	slices
	GLint	loops
	GLdouble	start
	GLdouble	sweep

#//# gluPerspective($fovy, $aspect, $zNear, $zFar);
void
gluPerspective(fovy, aspect, zNear, zFar)
	GLdouble	fovy
	GLdouble	aspect
	GLdouble	zNear
	GLdouble	zFar

#//# gluPickMatrix_p($x, $y, $delX, $delY, $m1,$m2,$m3,$m4);
void
gluPickMatrix_p(x, y, delX, delY, m1,m2,m3,m4)
	GLdouble	x
	GLdouble	y
	GLdouble	delX
	GLdouble	delY
	CODE:
	{
		GLint m[4];
		int i;
		for (i=0;i<4;i++)
			m[i] = SvIV(ST(i+4));
		gluPickMatrix(x, y, delX, delY, &m[0]);
	}

#//# gluProject_p($objx, $objy, $objz, @m4x4, @o4x4, $v1,$v2,$v3,$v4);
void
gluProject_p(objx, objy, objz, m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16, o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16, v1,v2,v3,v4)
	GLdouble	objx
	GLdouble	objy
	GLdouble	objz
	PPCODE:
	{
		GLdouble m[16], p[16], winx, winy, winz;
		GLint v[4];
		int i;
		for (i=0;i<16;i++)
			m[i] = SvNV(ST(i+3));
		for (i=0;i<16;i++)
			p[i] = SvNV(ST(i+3+16));
		for (i=0;i<4;i++)
			v[i] = SvIV(ST(i+3+16+16));
		i = gluProject(objx, objy, objz, m, p, v, &winx, &winy, &winz);
		if (i) {
			EXTEND(sp, 3);
			PUSHs(sv_2mortal(newSVnv(winx)));
			PUSHs(sv_2mortal(newSVnv(winy)));
			PUSHs(sv_2mortal(newSVnv(winz)));
		}
	}

#// gluPwlCurve_c(nurb, count, data, stride, type);
void
gluPwlCurve_c(nurb, count, data, stride, type)
	GLUnurbsObj *	nurb
	GLint	count
	void *	data
	GLint	stride
	GLenum	type
	CODE:
	gluPwlCurve(nurb, count, data, stride, type);


#// gluQuadricDrawStyle(quad, draw);
void
gluQuadricDrawStyle(quad, draw)
	GLUquadricObj *	quad
	GLenum	draw

#// gluQuadricNormals(quad, normal);
void
gluQuadricNormals(quad, normal)
	GLUquadricObj *	quad
	GLenum	normal

#// gluQuadricOrientation(quad, orientation);
void
gluQuadricOrientation(quad, orientation)
	GLUquadricObj *	quad
	GLenum	orientation

#// gluQuadricTexture(quad, texture);
void
gluQuadricTexture(quad, texture)
	GLUquadricObj *	quad
	GLboolean	texture

#//# gluScaleImage_s($format, $wIn, $hIn, $typeIn, (PACKED)dataIn, $wOut, $hOut, $typeOut, (PACKED)dataOut);
GLint
gluScaleImage_s(format, wIn, hIn, typeIn, dataIn, wOut, hOut, typeOut, dataOut)
	GLenum	format
	GLsizei	wIn
	GLsizei	hIn
	GLenum	typeIn
	SV *	dataIn
	GLsizei	wOut
	GLsizei	hOut
	GLenum	typeOut
	SV *	dataOut
	CODE:
	{
		GLvoid * inptr, * outptr;
		STRLEN discard;
		ELI(dataIn, wIn, hIn, format, typeIn, gl_pixelbuffer_unpack);
		ELI(dataOut, wOut, hOut, format, typeOut, gl_pixelbuffer_pack);
		inptr = SvPV(dataIn, discard);
		outptr = SvPV(dataOut, discard);
		RETVAL = gluScaleImage(format, wIn, hIn, typeIn, inptr, wOut, hOut, typeOut, outptr);
	}
	OUTPUT:
	RETVAL

#// gluSphere(quad, radius, slices, stacks);
void
gluSphere(quad, radius, slices, stacks)
	GLUquadricObj *	quad
	GLdouble	radius
	GLint	slices
	GLint	stacks

#ifdef GLU_VERSION_1_2

#// gluGetTessProperty_p(tess, property);
GLdouble
gluGetTessProperty_p(tess, property)
	PGLUtess *	tess
	GLenum	property
	CODE:
	{
		GLdouble param;
		gluGetTessProperty(tess->triangulator, property, &param);
		RETVAL = param;
	}
	OUTPUT:
	RETVAL

#// #gluNurbsCallback_p(nurb, which, handler, ...);
#void
#gluNurbsCallback_p(nurb, which, handler, ...)

#// gluNurbsCallbackDataEXT
#void
#gluNurbsCallbackDataEXT

#// gluQuadricCallback
#void
#gluQuadricCallback

#// gluTessBeginCountour(tess);
void
gluTessBeginCountour(tess)
	PGLUtess *	tess
	CODE:
	gluTessBeginContour(tess->triangulator);

#// gluTessEndContour(tess);
void
gluTessEndContour(tess)
	PGLUtess *	tess
	CODE:
	gluTessEndContour(tess->triangulator);

#// gluTessBeginPolygon(tess, ...);
void
gluTessBeginPolygon(tess, ...)
	PGLUtess *	tess
	CODE:
	{
		if (tess->polygon_data_av) {
			SvREFCNT_dec(tess->polygon_data_av);
			tess->polygon_data_av = 0;
		}
		if (items > 1) {
			tess->polygon_data_av = newAV();
			PackCallbackST(tess->polygon_data_av, 1);
		}
		gluTessBeginPolygon(tess->triangulator, tess);
	}

#// gluTessEndPolygon(tess);
void
gluTessEndPolygon(tess)
	PGLUtess *	tess
	CODE:
	{
		if (tess->polygon_data_av) {
			SvREFCNT_dec(tess->polygon_data_av);
			tess->polygon_data_av = 0;
		}
	}

#// gluTessNormal(tess, valueX, valueY, valueZ)
void
gluTessNormal(tess, valueX, valueY, valueZ)
	PGLUtess *	tess
	GLdouble	valueX
	GLdouble	valueY
	GLdouble	valueZ
	CODE:
	gluTessNormal(tess->triangulator, valueX, valueY, valueZ);

#// gluTessProperty(tess, which, data);
void
gluTessProperty(tess, which, data)
	PGLUtess *	tess
	GLenum	which
	GLdouble	data
	CODE:
	gluTessProperty(tess->triangulator, which, data);

#// gluTessCallback(tess, which, ...);
void
gluTessCallback(tess, which, ...)
	PGLUtess *	tess
	GLenum	which
	CODE:
	{
		switch (which) {
		case GLU_TESS_BEGIN:
		case GLU_TESS_BEGIN_DATA:
			if (tess->begin_callback) {
				SvREFCNT_dec(tess->begin_callback);
				tess->begin_callback = 0;
			}
			break;
		case GLU_TESS_END:
		case GLU_TESS_END_DATA:
			if (tess->end_callback) {
				SvREFCNT_dec(tess->end_callback);
				tess->end_callback = 0;
			}
			break;
		}
		
		if ((items > 3) && !SvOK(ST(2))) {
			AV * callback = newAV();
			PackCallbackST(callback, 2);

			switch (which) {
			case GLU_TESS_BEGIN:
			case GLU_TESS_BEGIN_DATA:
				tess->begin_callback = callback;
				gluTessCallback(tess->triangulator, which, (void (CALLBACK*)()) _s_marshal_glu_t_callback_begin);
				break;
			case GLU_TESS_END:
			case GLU_TESS_END_DATA:
				tess->end_callback = callback;
				gluTessCallback(tess->triangulator, which, (void (CALLBACK*)()) _s_marshal_glu_t_callback_end);
				break;
			}
		}
	}
	

#endif

#// gluTessVertex(tess, x, y, z, ...);
void
gluTessVertex(tess, x, y, z, ...)
	PGLUtess *	tess
	GLdouble	x
	GLdouble	y
	GLdouble	z
	CODE:
	{
		AV * data = 0;
		GLdouble v[3];
		v[0] = x;
		v[1] = y;
		v[2] = z;

		if (items > 4) {
			data = newAV();
			PackCallbackST(data, 4);
			
			if (!tess->vertex_datas)
				tess->vertex_datas = newAV();
			
			av_push(tess->vertex_datas, newRV_inc((SV*)data));
			SvREFCNT_dec(data);
		}

		gluTessVertex(tess->triangulator, &v[0], (void*)data);
	}

#//# gluUnProject_p($winx,$winy,$winz, @m4x4, @o4x4, $v1,$v2,$v3,$v4);
void
gluUnProject_p(winx,winy,winz, m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16, o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16, v1,v2,v3,v4)
	GLdouble	winx
	GLdouble	winy
	GLdouble	winz
	PPCODE:
	{
		GLdouble m[16], p[16], objx, objy, objz;
		GLint v[4];
		int i;

		for (i=0;i<16;i++)
			m[i] = SvNV(ST(i+3));
		for (i=0;i<16;i++)
			p[i] = SvNV(ST(i+3+16));
		for (i=0;i<4;i++)
			v[i] = SvIV(ST(i+3+16+16));

		i = gluUnProject(winx,winy,winz, m, p, v, &objx,&objy,&objz);

		if (i) {
			EXTEND(sp, 3);
			PUSHs(sv_2mortal(newSVnv(objx)));
			PUSHs(sv_2mortal(newSVnv(objy)));
			PUSHs(sv_2mortal(newSVnv(objz)));
		}
	}

#endif

#endif /* End IN_POGL_GLU_XS */

############################## GLUT #########################

#ifdef IN_POGL_GLUT_XS

#ifdef GLUT_API_VERSION

# GLUT

#//# glutInit();
void
glutInit()
	CODE:
	{
	int argc;
	char ** argv;
	AV * ARGV;
	SV * ARGV0;
	SV * sv;
	int i;

			if (_done_glutInit)
				croak("illegal glutInit() reinitialization attempt");

			argv  = 0;
			ARGV = perl_get_av("ARGV", FALSE);
			ARGV0 = perl_get_sv("0", FALSE);
			
			argc = av_len(ARGV)+2;
			if (argc) {
				argv = malloc(sizeof(char*)*argc);
				argv[0] = SvPV(ARGV0, PL_na);
				for(i=0;i<=av_len(ARGV);i++)
					argv[i+1] = SvPV(*av_fetch(ARGV, i, 0), PL_na);
			}
			
			i = argc;
			glutInit(&argc, argv);

			_done_glutInit = 1;

			while(argc<i--)
				sv = av_shift(ARGV);
			
			if (argv)
				free(argv);
	}

#//# glutInitWindowSize($width, $height);
void
glutInitWindowSize(width, height)
	int	width
	int	height

#//# glutInitWindowPosition($x, $y);
void
glutInitWindowPosition(x, y)
	int	x
	int	y

#//# glutInitDisplayMode($mode);
void
glutInitDisplayMode(mode)
	int	mode

#//# glutMainLoop();
void
glutMainLoop()

#//# glutCreateWindow($name);
int
glutCreateWindow(name)
	char *	name
	CODE:
	RETVAL = glutCreateWindow(name);
	destroy_glut_win_handlers(RETVAL);
	OUTPUT:
	RETVAL

#//# glutCreateSubWindow($win, $x, $y, $width, $height);
int
glutCreateSubWindow(win, x, y, width, height)
	int	win
	int	x
	int	y
	int	width
	int	height
	CODE:
	RETVAL = glutCreateSubWindow(win, x, y, width, height);
	destroy_glut_win_handlers(RETVAL);
	OUTPUT:
	RETVAL

#//# glutSetWindow($win);
void
glutSetWindow(win)
	int	win

#//# glutGetWindow();
int
glutGetWindow()

#//# glutDestroyWindow($win);
void
glutDestroyWindow(win)
	int	win
	CODE:
	glutDestroyWindow(win);
	destroy_glut_win_handlers(win);

#//# glutPostRedisplay();
void
glutPostRedisplay()

#//# glutSwapBuffers();
void
glutSwapBuffers()

#//# glutPositionWindow($x, $y);
void
glutPositionWindow(x, y)
	int	x
	int	y

#//# glutReshapeWindow($width, $height);
void
glutReshapeWindow(width, height)
	int	width
	int	height

#if GLUT_API_VERSION >= 3

#//# glutFullScreen();
void
glutFullScreen()

#endif

#//# glutPopWindow();
void
glutPopWindow()

#//# glutPushWindow();
void
glutPushWindow()

#//# glutShowWindow();
void
glutShowWindow()

#//# glutHideWindow();
void
glutHideWindow()

#//# glutIconifyWindow();
void
glutIconifyWindow()

#//# glutSetWindowTitle($title);
void
glutSetWindowTitle(title)
	char *	title

#//# glutSetIconTitle($title);
void
glutSetIconTitle(title)
	char *	title

#if GLUT_API_VERSION >= 3

#//# glutSetCursor(cursor);
void
glutSetCursor(cursor)
	int	cursor

#endif

# Overlays


#if GLUT_API_VERSION >= 3

#//# glutEstablishOverlay(); 
void
glutEstablishOverlay()

#//# glutUseLayer(layer);
void
glutUseLayer(layer)
	GLenum	layer

#//# glutRemoveOverlay();
void
glutRemoveOverlay()

#//# glutPostOverlayRedisplay();
void
glutPostOverlayRedisplay()

#//# glutShowOverlay();
void
glutShowOverlay()

#//# glutHideOverlay();
void
glutHideOverlay()

#endif

# Menus

#//# $ID = glutCreateMenu(\&callback);
int
glutCreateMenu(handler=0, ...)
	SV *	handler
	CODE:
	{
		if (!handler || !SvOK(handler)) {
			croak("A handler must be specified");
		} else {
			AV * handler_data = newAV();
		
			PackCallbackST(handler_data, 0);

			RETVAL = glutCreateMenu(generic_glut_menu_handler);
			
			if (!glut_menu_handlers)
				glut_menu_handlers = newAV();
			
			av_store(glut_menu_handlers, RETVAL, newRV_inc((SV*)handler_data));
			
			SvREFCNT_dec(handler_data);
			
		}
	}
	OUTPUT:
	RETVAL

#//# glutSetMenu($menu);
void
glutSetMenu(menu)
	int	menu

#//# glutGetMenu();
int
glutGetMenu()

#//# glutDestroyMenu($menu);
void
glutDestroyMenu(menu)
	int	menu
	CODE:
	{
		glutDestroyMenu(menu);
		av_store(glut_menu_handlers, menu, newSVsv(&PL_sv_undef));
	}

#//# glutAddMenuEntry($name, $value);
void
glutAddMenuEntry(name, value)
	char *	name
	int	value

#//# glutAddSubMenu($name, $menu);
void
glutAddSubMenu(name, menu)
	char *	name
	int	menu

#//# glutChangeToMenuEntry($entry, $name, $value);
void
glutChangeToMenuEntry(entry, name, value)
	int	entry
	char *	name
	int	value

#//# glutChangeToSubMenu($entry, $name, $menu);
void
glutChangeToSubMenu(entry, name, menu)
	int	entry
	char *	name
	int	menu

#//# glutRemoveMenuItem($entry);
void
glutRemoveMenuItem(entry)
	int	entry

#//# glutAttachMenu(button);
void
glutAttachMenu(button)
	int	button

#//# glutDetachMenu(button);
void
glutDetachMenu(button)
	int	button

# Callbacks

#//# glutDisplayFunc(\&callback);
void
glutDisplayFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs_nullfail(Display, ("Display function must be specified"))

#if GLUT_API_VERSION >= 3

#//# glutOverlayDisplayFunc(\&callback);
void
glutOverlayDisplayFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(OverlayDisplay)

#endif

#//# glutReshapeFunc(\&callback);
void
glutReshapeFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(Reshape)

#//# glutKeyboardFunc(\&callback);
void
glutKeyboardFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(Keyboard)

#if GLUT_API_VERSION >= 4

#//# glutKeyboardUpFunc(\&callback);
void
glutKeyboardUpFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(KeyboardUp)

#//# glutWindowStatusFunc(\&callback);
void
glutWindowStatusFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(WindowStatus)

#endif

#//# glutMouseFunc(\&callback);
void
glutMouseFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(Mouse)

#//# glutMouseWheelFunc(\&callback);
void
glutMouseWheelFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(MouseWheel)

#//# glutMotionFunc(\&callback);
void
glutMotionFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(Motion)

#//# glutPassiveMotionFunc(\&callback);
void
glutPassiveMotionFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(PassiveMotion)

#//# glutVisibilityFunc(\&callback);
void
glutVisibilityFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(Visibility)

# OS/2 PM implementation calls itself v2, but does not support these functions
# It is very hard to test for this, so we check for some other omission...

#if !defined(GL_SRC_ALPHA_SATURATE) || defined(GL_CONSTANT_COLOR)

#//# glutEntryFunc(\&callback);
void
glutEntryFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(Entry)

#endif

#if GLUT_API_VERSION >= 2

#//# glutSpecialFunc(\&callback);
void
glutSpecialFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(Special)

# OS/2 PM implementation calls itself v2, but does not support these functions
# It is very hard to test for this, so we check for some other omission...

#  if !defined(GL_SRC_ALPHA_SATURATE) || defined(GL_CONSTANT_COLOR)

#//# glutJoystickFunc(\&callback);	/* Open/FreeGLUT -chm */
# void					/* Not implemented, don't know how */
# glutJoystickFunc(handler=0, ...)
# 	SV *	handler
# 	CODE:
# 	decl_gwh_xs(Joystick)

#//# glutSpaceballMotionFunc(\&callback);
void
glutSpaceballMotionFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(SpaceballMotion)

#//# glutSpaceballRotateFunc(\&callback);
void
glutSpaceballRotateFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(SpaceballRotate)

#//# glutSpaceballButtonFunc(\&callback);
void
glutSpaceballButtonFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(SpaceballButton)

#//# glutButtonBoxFunc(\&callback);
void
glutButtonBoxFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(ButtonBox)

#//# glutDialsFunc(\&callback);
void
glutDialsFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(Dials)

#//# glutTabletMotionFunc(\&callback);
void
glutTabletMotionFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(TabletMotion)

#//# glutTabletButtonFunc(\&callback);
void
glutTabletButtonFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(TabletButton)

#  endif

#endif

#if GLUT_API_VERSION >= 3

#//# glutMenuStatusFunc(\&callback);
void
glutMenuStatusFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_ggh_xs(MenuStatus)

#endif

#//# glutMenuStateFunc(\&callback);
void
glutMenuStateFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_ggh_xs(MenuState)

#//# glutIdleFunc(\&callback);
void
glutIdleFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_ggh_xs(Idle)

#//# glutTimerFunc($msecs, \&callback);
void
glutTimerFunc(msecs, handler=0, ...)
	unsigned int	msecs
	SV *	handler
	CODE:
	{
		if (!handler || !SvOK(handler)) {
			croak("A handler must be specified");
		} else {
			AV * handler_data = newAV();
		
			PackCallbackST(handler_data, 1);
			
			glutTimerFunc(msecs, generic_glut_timer_handler, (int)handler_data);
		}
	ENSURE_callback_thread;}


# Colors

#//# glutSetColor($cell, $red, $green, $blue)
void
glutSetColor(cell, red, green, blue)
	int	cell
	GLfloat	red
	GLfloat	green
	GLfloat	blue

#//# glutGetColor($cell, $component);
GLfloat
glutGetColor(cell, component)
	int	cell
	int	component

#//# glutCopyColormap($win);
void
glutCopyColormap(win)
	int	win

# State

#//# glutGet($state);
int
glutGet(state)
	GLenum	state

#if GLUT_API_VERSION >= 3

#//# glutLayerGet(info);
int
glutLayerGet(info)
	GLenum	info

#endif

int
glutDeviceGet(info)
	GLenum	info

#if GLUT_API_VERSION >= 3

#//# glutGetModifiers();
int
glutGetModifiers()

#endif

#if GLUT_API_VERSION >= 2

#//# glutExtensionSupported($extension);
int
glutExtensionSupported(extension)
	char *	extension

#endif

# Font

#//# glutBitmapCharacter($font, $character);
void
glutBitmapCharacter(font, character)
	void *	font
	int	character

#//# glutStrokeCharacter($font, $character);
void
glutStrokeCharacter(font, character)
	void *	font
	int	character

# OS/2 PM implementation calls itself v2, but does not support these functions
# It is very hard to test for this, so we check for some other omission...

#if GLUT_API_VERSION >= 2 && (!defined(GL_SRC_ALPHA_SATURATE) || defined(GL_CONSTANT_COLOR))

#//# glutBitmapWidth($font, $character);
int
glutBitmapWidth(font, character)
	void *	font
	int	character

#//# glutStrokeWidth($font, $character);
int
glutStrokeWidth(font, character)
	void *	font
	int	character

#endif


#if GLUT_API_VERSION >= 3

#//# glutIgnoreKeyRepeat($ignore);
void
glutIgnoreKeyRepeat(ignore)
	int	ignore

#//# glutSetKeyRepeat($repeatMode);
void
glutSetKeyRepeat(repeatMode)
	int	repeatMode

#//# glutForceJoystickFunc();
void
glutForceJoystickFunc()

#endif


# Solids

#//# glutSolidSphere($radius, $slices, $stacks);
void
glutSolidSphere(radius, slices, stacks)
	GLdouble	radius
	GLint	slices
	GLint	stacks

#//# glutWireSphere($radius, $slices, $stacks);
void
glutWireSphere(radius, slices, stacks)
	GLdouble	radius
	GLint	slices
	GLint	stacks

#//# glutSolidCube($size);
void
glutSolidCube(size)
	GLdouble	size

#//# glutWireCube($size);
void
glutWireCube(size)
	GLdouble	size

#//# glutSolidCone($base, $height, $slices, $stacks);
void
glutSolidCone(base, height, slices, stacks)
	GLdouble	base
	GLdouble	height
	GLint	slices
	GLint	stacks

#//# glutWireCone($base, $height, $slices, $stacks);
void
glutWireCone(base, height, slices, stacks)
	GLdouble	base
	GLdouble	height
	GLint	slices
	GLint	stacks

#//# glutSolidTorus($innerRadius, $outerRadius, $nsides, $rings);
void
glutSolidTorus(innerRadius, outerRadius, nsides, rings)
	GLdouble	innerRadius
	GLdouble	outerRadius
	GLint	nsides
	GLint	rings

#//# glutWireTorus($innerRadius, $outerRadius, $nsides, $rings);
void
glutWireTorus(innerRadius, outerRadius, nsides, rings)
	GLdouble	innerRadius
	GLdouble	outerRadius
	GLint	nsides
	GLint	rings

#//# glutSolidDodecahedron();
void
glutSolidDodecahedron()

#//# glutWireDodecahedron();
void
glutWireDodecahedron()

#//# glutSolidOctahedron();
void
glutSolidOctahedron()

#//# glutWireOctahedron();
void
glutWireOctahedron()

#//# glutSolidTetrahedron();
void
glutSolidTetrahedron()

#//# glutWireTetrahedron();
void
glutWireTetrahedron()

#//# glutSolidIcosahedron();
void
glutSolidIcosahedron()

#//# glutWireIcosahedron();
void
glutWireIcosahedron()

#//# glutSolidTeapot(size);
void
glutSolidTeapot(size)
	GLdouble	size

#//# glutWireTeapot($size);
void
glutWireTeapot(size)
	GLdouble	size

#if GLUT_API_VERSION >= 4

#//# glutSpecialUpFunc(\&callback);
void
glutSpecialUpFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(SpecialUp)

#//# glutGameModeString($string);
GLboolean
glutGameModeString(string)
	char *	string
	CODE:
	{
		char mode[1024];
		if (!string || !string[0])
		{
			int w = glutGet(0x00C8);	// GLUT_SCREEN_WIDTH
			int h = glutGet(0x00C9);	// GLUT_SCREEN_HEIGHT

			sprintf(mode,"%dx%d:%d@%d",w,h,32,60);
			string = mode;
		}

		glutGameModeString(string);
		RETVAL = glutGameModeGet(0x0001);	// GLUT_GAME_MODE_POSSIBLE
	}
	OUTPUT:
		RETVAL

#//# glutEnterGameMode();
int
glutEnterGameMode()

#//# glutLeaveGameMode();
void
glutLeaveGameMode()

#//# glutGameModeGet($mode);
int
glutGameModeGet(mode)
	GLenum	mode

##//## CHM implementation of missing FreeGLUT/OpenGLUT features

#//# int  glutBitmapHeight (void *font)
int
glutBitmapHeight(font)
	void * font

#//# int  glutBitmapLength (void *font, const unsigned char *string)
int
glutBitmapLength(font, string)
	void * font
	const unsigned char * string

#//# void  glutBitmapString (void *font, const unsigned char *string)
void
glutBitmapString(font, string)
	void * font
	const unsigned char * string

#//# void *  glutGetMenuData (void)
# void *
# glutGetMenuData()

#//# void *  glutGetProcAddress (const char *procName)
# void *
# glutGetProcAddress(procName)
# 	const char * procName

#//# void *  glutGetWindowData (void)
# void *
# glutGetWindowData()

#//# void  glutMainLoopEvent (void)
void
glutMainLoopEvent()

#//# void  glutPostWindowOverlayRedisplay (int windowID)
void
glutPostWindowOverlayRedisplay(windowID)
	int windowID

#//# void  glutPostWindowRedisplay (int windowID)
void
glutPostWindowRedisplay(windowID)
	int windowID

#//# void  glutReportErrors (void)
void
glutReportErrors()

#//# void  glutSetMenuData (void *data)
# void
# glutSetMenuData(data)
# 	void * data

#//# void  glutSetWindowData (void *data)
# void
# glutSetWindowData(data)
# 	void * data

#//# void  glutSolidCylinder (GLdouble radius, GLdouble height, GLint slices, GLint stacks)
void
glutSolidCylinder(radius, height, slices, stacks)
	GLdouble radius
	GLdouble height
	GLint slices
	GLint stacks

#//# void  glutSolidRhombicDodecahedron (void)
void
glutSolidRhombicDodecahedron()

#//# void  glutSolidSierpinskiSponge (int num_levels, const GLdouble offset[3], GLdouble scale)
# void
# glutSolidSierpinskiSponge(num_levels, offset, scale)
# 	int num_levels
# 	const GLdouble offset[3]
# 	GLdouble scale

#//# float  glutStrokeHeight (void *font)
GLfloat
glutStrokeHeight(font)
	void * font

#//# float  glutStrokeLength (void *font, const unsigned char *string)
GLfloat
glutStrokeLength(font, string)
	void * font
	const unsigned char * string

#//# void  glutStrokeString (void *fontID, const unsigned char *string)
void
glutStrokeString(font, string)
	void * font
	const unsigned char * string

#//# void  glutWarpPointer (int x, int y)
void
glutWarpPointer(x, y)
	int x
	int y

#//# void  glutWireCylinder (GLdouble radius, GLdouble height, GLint slices, GLint stacks)
void
glutWireCylinder(radius, height, slices, stacks)
	GLdouble radius
	GLdouble height
	GLint slices
	GLint stacks

#//# void  glutWireRhombicDodecahedron (void)
void
glutWireRhombicDodecahedron()

#//# void  glutWireSierpinskiSponge (int num_levels, const GLdouble offset[3], GLdouble scale)
# void
# glutWireSierpinskiSponge(num_levels, offset, scale)
# 	int num_levels
# 	const GLdouble offset[3]
# 	GLdouble scale

#endif

# /* FreeGLUT APIs */

#//# glutSetOption($option_flag, $value);
void
glutSetOption(option_flag, value)
	GLenum		option_flag
	int		value
	CODE:
	{
#if defined HAVE_FREEGLUT
		glutSetOption(option_flag, value);
#endif
	}

#//# glutLeaveMainLoop();
void
glutLeaveMainLoop()
	CODE:
	{
#if defined HAVE_FREEGLUT
		glutLeaveMainLoop();
#else
		int win = glutGetWindow();
		glutDestroyWindow(win);
		destroy_glut_win_handlers(win);
#endif
	}

#//# glutMenuDestroyFunc(\&callback);
void
glutMenuDestroyFunc(handler=0, ...)
	SV *	handler
	CODE:
	decl_gwh_xs(MenuDestroy)


#//# glutCloseFunc(\&callback);
void
glutCloseFunc(handler=0, ...)
	SV *	handler
	CODE:
        {
#if defined HAVE_FREEGLUT
		decl_gwh_xs(Close)
#endif
        }

#endif /* def GLUT_API_VERSION */

#endif /* End IN_POGL_GLUT_XS */

# /* This is assigned to GLX for now.  The glp*() functions should be split out */

#ifdef IN_POGL_GLX_XS

# /* The following material is directly copied from Stan Melax's original OpenGL-0.4 */

#ifdef __PM__

#// morphPM();
void
morphPM()

#endif

int
__had_dbuffer_hack()

#ifdef HAVE_GLpc			/* GLX or __PM__ */

#// $ID = glpcOpenWindow($x,$y,$w,$h,$pw,$steal,$event_mask,@attribs);
GLXDrawable
glpcOpenWindow(x,y,w,h,pw,steal,event_mask, ...)
	int	x
	int	y
	int	w
	int	h
	int	pw
	int	steal
	long	event_mask
	CODE:
	{
	    XEvent event;
	    Window pwin=(Window)pw;
	    int *attributes = default_attributes + 1;
	    int *a_buf = NULL;

	    if(items>NUM_ARG){
	        int i;
	        a_buf = (int *)malloc((items-NUM_ARG+2)* sizeof(int));
		a_buf[0] = GLX_DOUBLEBUFFER; /* Preallocate */
		attributes = a_buf + 1;
	        for(i=NUM_ARG;i<items;i++) {
	            attributes[i-NUM_ARG]=SvIV(ST(i));
	        }
	        attributes[items-NUM_ARG]=None;
	    }
	    /* get a connection */
	    if (!dpy_open) {
		dpy = XOpenDisplay(0);
		dpy_open = 1;
	    }
	    if (!dpy)
		croak("No display!");

	    /* get an appropriate visual */
	    vi = glXChooseVisual(dpy, DefaultScreen(dpy),attributes);
	    if (!vi) { /* Might have happened that one does not
			* *need* DOUBLEBUFFER, but the display does
			* not provide SINGLEBUFFER; and the semantic
			* of GLX_DOUBLEBUFFER is that if it misses,
			* only SINGLEBUFFER visuals are selected.  */
			attributes--; /* GLX_DOUBLEBUFFER preallocated there */
		vi = glXChooseVisual(dpy, DefaultScreen(dpy),attributes); /* Retry */
		if (vi)
	    		DBUFFER_HACK = 1;
	    }
	    if (a_buf)
		free(a_buf);
	    if(!vi)
		croak("No visual!");

	    /* A blank line here will confuse xsubpp ;-) */
#ifdef HAVE_GLX
	    /* create a GLX context */
	    cx = glXCreateContext(dpy, vi, 0, GL_TRUE);
	    if(!cx)
		croak("No context\n");
	
	    /* create a color map */
	    cmap = XCreateColormap(dpy, RootWindow(dpy, vi->screen),
				   vi->visual, AllocNone);
	
	    /* create a window */
	    swa.colormap = cmap;
	    swa.border_pixel = 0;
	    swa.event_mask = event_mask;
#endif	/* defined HAVE_GLX */

	    if(!pwin){pwin=RootWindow(dpy, vi->screen);}
	    if (steal)
		win = nativeWindowId(dpy, pwin); /* What about depth/visual */
	    else
		win = XCreateWindow(dpy, pwin, 
				    x, y, w, h,
				    0, vi->depth, InputOutput, vi->visual,
				    CWBorderPixel|CWColormap|CWEventMask, &swa);
	    if(!win)
	        croak("No Window");
	    XMapWindow(dpy, win);
#ifndef HAVE_GLX
	    /* On OS/2: cannot create a context before mapping something... */
	    /* create a GLX context */
	    cx = glXCreateContext(dpy, vi, 0, GL_TRUE);
	    if(!cx)
		croak("No context!\n");

	    LastEventMask = event_mask;
#else	/* HAVE_GLX */
	    if((event_mask & StructureNotifyMask) && !steal) {
	        XIfEvent(dpy, &event, WaitForNotify, (char*)win);
	    }
#endif	/* HAVE_GLX */

	    /* connect the context to the window */
	    if (!glXMakeCurrent(dpy, win, cx))
	        croak("Non current");
	
	    /* clear the buffer */
	    glClearColor(0,0,0,1);
	    RETVAL = win;
	}

#// glpDisplay();
void *
glpDisplay()
	CODE:
	    /* get a connection */
	    if (!dpy_open) {
		dpy = XOpenDisplay(0);
		dpy_open = 1;
	    }
	    if (!dpy)
		croak("No display!");
	    RETVAL = dpy;

#// glpMoveResizeWindow($x, $y, $width, $height[, $winID[, $display]]);
void
glpMoveResizeWindow(x, y, width, height, w=win, d=dpy)
    void* d
    GLXDrawable w
    int x
    int y
    unsigned int width
    unsigned int height

#// glpMoveWindow($x, $y[, $winID[, $display]]);
void
glpMoveWindow(x, y, w=win, d=dpy)
    void* d
    GLXDrawable w
    int x
    int y

#// glpResizeWindow($width, $height[, $winID[, $display]])
void
glpResizeWindow(width, height, w=win, d=dpy)
    void* d
    GLXDrawable w
    unsigned int width
    unsigned int height

# If glpOpenWindow was used then glXSwapBuffers should be called
# without parameters (i.e. use the default parameters)

#// glXSwapBuffers([$winID[, $display]])
void
glXSwapBuffers(w=win,d=dpy)
	void *	d
	GLXDrawable	w
	CODE:
	{
	    glXSwapBuffers(d,w);
	}

#// XPending([$display]);
int
XPending(d=dpy)
	void *	d
	CODE:
	{
		RETVAL = XPending(d);
	}
	OUTPUT:
	RETVAL

#// glpXNextEvent([$display]);
void
glpXNextEvent(d=dpy)
	void *	d
	PPCODE:
	{
		XEvent event;
		char buf[10];
		KeySym ks;
		XNextEvent(d,&event);
		switch(event.type) {
			case ConfigureNotify:
				EXTEND(sp,3);
				PUSHs(sv_2mortal(newSViv(event.type)));
				PUSHs(sv_2mortal(newSViv(event.xconfigure.width)));
				PUSHs(sv_2mortal(newSViv(event.xconfigure.height)));				
				break;
			case KeyPress:
			case KeyRelease:
				EXTEND(sp,2);
				PUSHs(sv_2mortal(newSViv(event.type)));
				XLookupString(&event.xkey,buf,sizeof(buf),&ks,0);
				buf[0]=(char)ks;buf[1]='\0';
				PUSHs(sv_2mortal(newSVpv(buf,1)));
				break;
			case ButtonPress:
			case ButtonRelease:
				EXTEND(sp,4);
				PUSHs(sv_2mortal(newSViv(event.type)));
				PUSHs(sv_2mortal(newSViv(event.xbutton.button)));
				PUSHs(sv_2mortal(newSViv(event.xbutton.x)));
				PUSHs(sv_2mortal(newSViv(event.xbutton.y)));
				break;
			case MotionNotify:
				EXTEND(sp,4);
				PUSHs(sv_2mortal(newSViv(event.type)));
				PUSHs(sv_2mortal(newSViv(event.xmotion.state)));
				PUSHs(sv_2mortal(newSViv(event.xmotion.x)));
				PUSHs(sv_2mortal(newSViv(event.xmotion.y)));
				break;
			case Expose:
			default:
				EXTEND(sp,1);
				PUSHs(sv_2mortal(newSViv(event.type)));
				break;
		}
	}

#// glpXQueryPointer([$winID[, $display]]);
void
glpXQueryPointer(w=win,d=dpy)
	void *	d
	GLXDrawable	w
	PPCODE:
	{
		int x,y,rx,ry;
		Window r,c;
		unsigned int m;
		XQueryPointer(d,w,&r,&c,&rx,&ry,&x,&y,&m);
		EXTEND(sp,3);
		PUSHs(sv_2mortal(newSViv(x)));
		PUSHs(sv_2mortal(newSViv(y)));
		PUSHs(sv_2mortal(newSViv(m)));
	}

#endif


#//# glpReadTex($file);
void
glpReadTex(file)
	char *	file
	CODE:
	{
		GLsizei w,h;
		int d,i;
		char buf[250];
		unsigned char *image;
		FILE *fp;
		char *ret;

		fp=fopen(file,"r");

		if(!fp)	croak("couldn't open file %s",file);

		ret = fgets(buf,250,fp);		/* P3 */

		if (buf[0] != 'P' || buf[1] != '3')
			croak("Format is not P3 in file %s",file);

		ret = fgets(buf,250,fp);

		while (buf[0] == '#' && fgets(buf,250,fp));	/* Empty */

		if (2 != sscanf(buf,"%d%d",&w,&h))
			croak("couldn't read image size from file %s",file);
		if (1 != fscanf(fp,"%d",&d))
			croak("couldn't read image depth from file %s",file);
		if(d != 255)
			croak("image depth != 255 in file %s unsupported",file);
		if(w>10000 || h>10000)
			croak("suspicious size w=%d d=%d in file %s", w, d, file);

		New(1431, image, w*h*3, unsigned char);

		for(i=0;i<w*h*3;i++) {
			int v;

			if (1 != fscanf(fp,"%d",&v)) {
				Safefree(image);
				croak("Error reading number #%d of %d from file %s", i, w*h*3,file);
			}

			image[i]=(unsigned char) v;
		}

		fclose(fp);

		glTexImage2D(GL_TEXTURE_2D, 0, 3, w,h, 
			0, GL_RGB, GL_UNSIGNED_BYTE,image);
	}

#//# glpHasGLUT();
int
glpHasGLUT()
	CODE:
	{
#if defined(HAVE_GLUT) || defined(HAVE_FREEGLUT)
		RETVAL = 1;
#else
		RETVAL = 0;
#endif
	}
	OUTPUT:
		RETVAL


#//# glpHasGPGPU();
int
glpHasGPGPU()
	CODE:
		RETVAL = gpgpu_size();
	OUTPUT:
		RETVAL

#endif /* End IN_POGL_GLX_XS */

BOOT:
#ifdef __PM__
  InitSys();
#endif /* defined __PM__ */
