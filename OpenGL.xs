/*  Last saved: Tue 09 Jun 2009 09:37:02 AM  */

/*  Copyright (c) 1998 Kenneth Albanowski. All rights reserved.
 *  Copyright (c) 2007 Bob Free. All rights reserved.
 *  This program is free software; you can redistribute it and/or
 *  modify it under the same terms as Perl itself.
 */

/* All OpenGL constants---should split */
#define IN_POGL_CONST_XS

/* This ends up being OpenGL.pm */
#define IN_POGL_MAIN_XS

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

#ifdef HAVE_GL
#include "gl_util.h"
#endif

#ifdef HAVE_GLX
#include "glx_util.h"
#endif

#ifdef HAVE_GLU
#include "glu_util.h"
#endif

#if defined(HAVE_GLUT) || defined(HAVE_FREEGLUT)
#ifndef GLUT_API_VERSION
#define GLUT_API_VERSION 4
#endif
#include "glut_util.h"
#endif

static int _done_glutInit = 0;



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





##################### GLU #########################


############################## GLUT #########################


# /* This is assigned to GLX for now.  The glp*() functions should be split out */


BOOT:
  PGOPOGL_CALL_BOOT(boot_PDL__Graphics__OpenGL__Perl__OpenGL__RPN);
  PGOPOGL_CALL_BOOT(boot_PDL__Graphics__OpenGL__Perl__OpenGL__Rest);
  PGOPOGL_CALL_BOOT(boot_PDL__Graphics__OpenGL__Perl__OpenGL__GLUT);
#ifdef __PM__
  InitSys();
#endif /* defined __PM__ */
