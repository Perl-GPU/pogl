/*
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or (at your
 * option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307  USA.
 *
 */

#ifndef _PGOPOGL_H_
#define _PGOPOGL_H_

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

/*
 * miscellaneous
 */

/* These macros used in BOOT */
#define OGL_CONST_i(test) newCONSTSUB(stash, #test, newSViv((int)test));
#define OGL_CONST_f(test) newCONSTSUB(stash, #test, newSVnv((double)test));
#define OGL_CONST_p(test) newCONSTSUB(stash, #test, newSViv(PTR2IV(test)));

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

#endif
