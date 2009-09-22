#!/usr/bin/perl

=head1 NAME

tessellation.pl - Show workings of perl based tessellation

=head1 SOURCE

general ideas taken from:
http://glprogramming.com/red/chapter11.html

=head1 AUTHOR

Paul Seamons

=cut

use OpenGL qw(:all);
use strict;
use warnings;

print "Starting $0\n";

my $color_toggle = 1;
my $edge_toggle  = 1;
my $solid_toggle = 1;
my $alias_toggle = 0;
my $defaults_toggle = 0;
my($w, $h) = (800, 600);

main();
exit;

sub main {
    glutInit();
    glutInitWindowSize($w, $h);
    glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE);
    glutCreateWindow("Tessellation");
    glClearColor (0.0, 0.0, 0.0, 0.0);

    init();

    glutDisplayFunc(\&render_scene);
    glutKeyboardFunc(sub {
        if ($_[0] == 27 || $_[0] == ord('q')) {
            exit;
        } elsif ($_[0] == ord('e')) {
            $edge_toggle = ($edge_toggle) ? 0 : 1;
        } elsif ($_[0] == ord('a')) {
            $alias_toggle = ($alias_toggle) ? 0 : 1;
        } elsif ($_[0] == ord('s')) {
            $solid_toggle = ($solid_toggle) ? 0 : 1;
        } elsif ($_[0] == ord('d')) {
            $defaults_toggle = ($defaults_toggle) ? 0 : 1;
        } else {
            $color_toggle = ($color_toggle) ? 0 : 1;
        }
        render_scene();
    });

    print "'q' - Quit
'e' - Toggle edge flags (show triangles)
's' - Toggle solid (polygon vs lines)
'd' - Toggle perl callbacks vs default c callbacks
'c' - Toggle color (perl callbacks only)
";
    glutMainLoop();
}

sub init {
    glViewport(0,0, $w,$h);

    glMatrixMode(GL_PROJECTION());
    glLoadIdentity();

    if ( @_ ) {
        gluPerspective(45.0,4/3,0.1,100.0);
    } else {
        glFrustum(-0.1,0.1,-0.075,0.075,0.175,100.0);
    }

    glMatrixMode(GL_MODELVIEW());
    glLoadIdentity();
}

sub render_scene {
    glClear (GL_COLOR_BUFFER_BIT);

    glLoadIdentity();
    glTranslatef(0, 0, -6);

    my $tess = gluNewTess();

    # ideally - these would be loaded into a call list - but this is just a sampling
    if ($defaults_toggle) {
        print "Use default tess callbacks\n";
        gluTessCallback($tess, GLU_TESS_BEGIN(),     'DEFAULT');
        gluTessCallback($tess, GLU_TESS_ERROR(),     'DEFAULT');
        gluTessCallback($tess, GLU_TESS_END(),       'DEFAULT');
        gluTessCallback($tess, GLU_TESS_VERTEX(),    'DEFAULT');
        gluTessCallback($tess, GLU_TESS_EDGE_FLAG(), 'DEFAULT') if $edge_toggle;
        gluTessCallback($tess, GLU_TESS_COMBINE(),   'DEFAULT');
    } else {
        print "Use perl tess callbacks\n";
        gluTessCallback($tess, GLU_TESS_BEGIN(),     sub { glBegin(shift) });
        gluTessCallback($tess, GLU_TESS_ERROR(),     sub { my $errno = shift; my $err = gluErrorString($errno); print "got an error ($errno - $err)\n" });
        gluTessCallback($tess, GLU_TESS_END(),       sub { glEnd() });
        gluTessCallback($tess, GLU_TESS_VERTEX(),    sub {
            my ($x, $y, $z, $r, $g, $b, $a) = @_;
            glColor3f($r, $g, $b) if $color_toggle;
            glVertex3f($x, $y, $z);
        });
        gluTessCallback($tess, GLU_TESS_EDGE_FLAG(), sub { glEdgeFlag(shift) }) if $edge_toggle;
        gluTessCallback($tess, GLU_TESS_COMBINE(),   sub {
            my ($x, $y, $z,
            $v0x, $v0y, $v0z, $v0r, $v0g, $v0b, $v0a,
            $v1x, $v1y, $v1z, $v1r, $v1g, $v1b, $v1a,
            $v2x, $v2y, $v2z, $v2r, $v2g, $v2b, $v2a,
            $v3x, $v3y, $v3z, $v3r, $v3g, $v3b, $v3a,
            $w0, $w1, $w2, $w3) = @_;
            return (
                $x, $y, $z,
                $w0*$v0r + $w1*$v1r + $w2*$v2r + $w3*$v3r,
                $w0*$v0g + $w1*$v1g + $w2*$v2g + $w3*$v3g,
                $w0*$v0b + $w1*$v1b + $w2*$v2b + $w3*$v3b,
                $w0*$v0a + $w1*$v1a + $w2*$v2a + $w3*$v3a,
                );
        });
    }

    glPolygonMode(GL_FRONT_AND_BACK, $solid_toggle ? GL_FILL : GL_LINE);

    glEnable (GL_LINE_SMOOTH);
    glEnable (GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glHint (GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
    glHint (GL_POLYGON_SMOOTH_HINT, GL_DONT_CARE);

    glColor3f(1,1,1);

    # triangle
    glPushMatrix();
    glTranslatef(-2.2, 1.2, 0);
    glScalef(.9, .9, 0);
    my $tri1 = [[0,1,0, 1,0,0], [-1,-1,0, 0,1,0], [1,-1,0, 0,0,1]];
    gluTessBeginPolygon($tess);
    gluTessBeginContour($tess);
    for my $q (@$tri1) {
        gluTessVertex($tess, @$q);
    }
    gluTessEndContour($tess);
    gluTessEndPolygon($tess);
    glPopMatrix();

    # square
    glPushMatrix();
    glTranslatef(0, 1.2, 0);
    glScalef(.9, .9, 0);
    my $quad0 = [[-1,1,0, 1,0,0], [1,1,0, 0,1,0], [1,-1,0, 0,0,1], [-1,-1,0, 1,1,0]];
    $quad0 = [reverse @$quad0];
    gluTessBeginPolygon($tess, sub { "hey" });
    gluTessBeginContour($tess);
    for my $q (@$quad0) {
        gluTessVertex($tess, @$q);
    }
    gluTessEndContour($tess);
    gluTessEndPolygon($tess);
    glPopMatrix();

    # pontiac
    glPushMatrix();
    glTranslatef(2.2, .1, 0);
    glScalef(.7, .7, 0);
    my $quad1 = [[-1,3,0, 1,0,0], [0,0,0, 1,1,0], [1,3,0, 0,0,1], [0,2,0, 0,1,0]];
    gluTessBeginPolygon($tess);
    gluTessBeginContour($tess);
    for my $q (@$quad1) {
        gluTessVertex($tess, @$q);
    }
    gluTessEndContour($tess);
    gluTessEndPolygon($tess);
    glPopMatrix();


    # window
    glPushMatrix();
    glTranslatef(-2.2, -2.1, 0);
    glScalef(.45, .45, 0);
    my $quad2 = [
        [[-2,3,0, 1,0,0], [-2,0,0, 1,1,0], [2,0,0, 0,0,1], [2,3,0, 0,1,0]],
        [[-1,2,0, 1,0,0], [-1,1,0, 1,1,0], [1,1,0, 0,0,1], [1,2,0, 0,1,0]],
        ];
    gluTessBeginPolygon($tess);
    for my $c (@$quad2) {
        gluTessBeginContour($tess);
        for my $q (@$c) {
            gluTessVertex($tess, @$q);
        }
        gluTessEndContour($tess);
    }
    gluTessEndPolygon($tess);
    glPopMatrix();


    # star
    glPushMatrix();
    glTranslatef(0, -2.1, 0);
    glScalef(.6, .6, 0);
    my $coord3 = [
        [ 0.0, 3.0, 0,  1, 0, 0],
        [-1.0, 0.0, 0,  0, 1, 0],
        [ 1.6, 1.9, 0,  1, 0, 1],
        [-1.6, 1.9, 0,  1, 1, 0],
        [ 1.0, 0.0, 0,  0, 0, 1],
        ];
    gluTessProperty($tess, GLU_TESS_WINDING_RULE(), GLU_TESS_WINDING_NONZERO());
    gluTessBeginPolygon($tess);
    gluTessBeginContour($tess);
    for my $q (@$coord3) {
        gluTessVertex($tess, @$q);
    }
    gluTessEndContour($tess);
    gluTessEndPolygon($tess);
    glPopMatrix();

    # octagon
    glPushMatrix();
    glTranslatef(2, -1.3, 0);
    glScalef(.35, .35, 0);
    my $coord4 = [
        [   -1,  2.4, 0,  1, 0, 0],
        [    1,  2.4, 0,  1, 1, 0],
        [  2.4,    1, 0,  0, 1, 0],
        [  2.4,   -1, 0,  0, 1, 1],
        [    1, -2.4, 0,  0, 0, 1],
        [   -1, -2.4, 0,  1, 0, 1],
        [ -2.4,   -1, 0,  1, 1, 1],
        [ -2.4,    1, 0,  .5, .5, .5],
        ];
    $coord4 = [reverse @$coord4];
    gluTessProperty($tess, GLU_TESS_WINDING_RULE(), GLU_TESS_WINDING_ODD());
    gluTessBeginPolygon($tess);
    gluTessBeginContour($tess);
    for my $q (@$coord4) {
        gluTessVertex($tess, @$q);
    }
    gluTessEndContour($tess);
    gluTessEndPolygon($tess);
    glPopMatrix();


    gluDeleteTess($tess);

    glutSwapBuffers();
}

