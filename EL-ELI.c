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
