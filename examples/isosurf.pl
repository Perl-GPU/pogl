use strict;
use warnings;
use OpenGL qw(:all);
use FindBin;

my $speed_test = GL_FALSE;
my $use_vertex_arrays = GL_TRUE;

my $doubleBuffer = GL_TRUE;

my $smooth = GL_TRUE;
my $lighting = GL_TRUE;
my $light0 = GL_TRUE;
my $light1 = GL_TRUE;

my $MAXVERTS = 10000;

my $verts = OpenGL::Array->new($MAXVERTS * 3, GL_FLOAT);
my $norms = OpenGL::Array->new($MAXVERTS * 3, GL_FLOAT);
my $numverts = 0;

my $xrot=0;
my $yrot=0;

sub read_surface_dat {
	my ($filename) = @_;
	
	open(F, "<$filename") || die "couldn't read $filename\n";
	
	$numverts = 0;
	while ($numverts < $MAXVERTS and defined($_ = <F>)) {
		chop;
		my @d = split(/\s+/, $_);
		$verts->assign($numverts*3, @d[0..2]);
		$norms->assign($numverts*3, @d[3..5]);
		$numverts++;
	}
	
	$numverts--;
	
	printf "%d vertices, %d triangles\n", $numverts, $numverts-2;
	
	close(F);
}

sub read_surface_bin {
	my ($filename) = @_;
	
	open(F, "<$filename") || die "couldn't read $filename\n";
	binmode(F);
	$numverts = 0;
	while ($numverts < $MAXVERTS and read(F, $_, 12)==12) {
		my @d = map(($_-32000) / 10000 , unpack("nnnnnn", $_));
		$verts->assign($numverts*3, @d[0..2]);
		$norms->assign($numverts*3, @d[3..5]);
		$numverts++;
	}
	
	$numverts--;
	
	printf "%d vertices, %d triangles\n", $numverts, $numverts-2;
	
	close(F);
}

sub draw_surface {
   my ($i);

   if ($use_vertex_arrays) {
      glDrawArrays( GL_TRIANGLE_STRIP, 0, $numverts );
   }
   else {
      glBegin( GL_TRIANGLE_STRIP );
      for ($i=0;$i<$numverts;$i++) {
         glNormal3d( $norms->retrieve($i*3, 3) );
         glVertex3d( $verts->retrieve($i*3, 3) );
      }
      glEnd();
  }
}

sub draw1 {

    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glPushMatrix();
    glRotated( $yrot, 0.0, 1.0, 0.0 );
    glRotated( $xrot, 1.0, 0.0, 0.0 );

    draw_surface();

    glPopMatrix();

    glFlush();
    if ($doubleBuffer) {
	glutSwapBuffers();
    }
}


sub Draw {
   if ($speed_test) {
      for ($xrot=0.0;$xrot<=360.0;$xrot+=10.0) {
	 draw1();
      }
      MyExit(0);
   }
   else {
      draw1();
   }
}

sub InitMaterials {

	my(@ambient) = (0.1, 0.1, 0.1, 1.0);
    my(@diffuse) = (0.5, 1.0, 1.0, 1.0);
    my (@position0) = (0.0, 0.0, 20.0, 0.0);
    my (@position1) = (0.0, 0.0, -20.0, 0.0);
    my (@front_mat_shininess) = (60.0);
    my (@front_mat_specular) = (0.2, 0.2, 0.2, 1.0);
    my (@front_mat_diffuse) = (0.5, 0.28, 0.38, 1.0);
#    /*
#    my (@back_mat_shininess) = (60.0);
#    my (@back_mat_specular) = (0.5, 0.5, 0.2, 1.0);
#    my (@back_mat_diffuse) = (1.0, 1.0, 0.2, 1.0);
#    */
    my (@lmodel_ambient) = (1.0, 1.0, 1.0, 1.0);
    my (@lmodel_twoside) = (GL_FALSE);

    glLightfv_p(GL_LIGHT0, GL_AMBIENT, @ambient);
    glLightfv_p(GL_LIGHT0, GL_DIFFUSE, @diffuse);
    glLightfv_p(GL_LIGHT0, GL_POSITION, @position0);
    glEnable(GL_LIGHT0);
    
    glLightfv_p(GL_LIGHT1, GL_AMBIENT, @ambient);
    glLightfv_p(GL_LIGHT1, GL_DIFFUSE, @diffuse);
    glLightfv_p(GL_LIGHT1, GL_POSITION, @position1);
    glEnable(GL_LIGHT1);
    
    glLightModelfv_p(GL_LIGHT_MODEL_AMBIENT, @lmodel_ambient);
    glLightModelfv_p(GL_LIGHT_MODEL_TWO_SIDE, @lmodel_twoside);
    glEnable(GL_LIGHTING);

    glMaterialfv_p(GL_FRONT_AND_BACK, GL_SHININESS, @front_mat_shininess);
    glMaterialfv_p(GL_FRONT_AND_BACK, GL_SPECULAR, @front_mat_specular);
    glMaterialfv_p(GL_FRONT_AND_BACK, GL_DIFFUSE, @front_mat_diffuse);
}

sub Init {
  glClearColor(0.0, 0.0, 0.0, 0.0);

  glShadeModel(GL_SMOOTH);
  glEnable(GL_DEPTH_TEST);

  InitMaterials();

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glFrustum( -1.0, 1.0, -1.0, 1.0, 5, 25 );

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glTranslated( 0.0, 0.0, -6.0 );

  if ($use_vertex_arrays) {
    glVertexPointer_c( 3, GL_FLOAT, 0, $verts->ptr );
    glNormalPointer_c( GL_FLOAT, 0, $norms->ptr );
    glEnableClientState( GL_VERTEX_ARRAY );
    glEnableClientState( GL_NORMAL_ARRAY );
  }
  if ($^O ne 'MSWin32') {
    my $errors = '';
    while((my $err = glGetError()) != 0) {
      $errors .= "glError: " . glpErrorString($err) . "\n";
    }
    die $errors if $errors;
  }
}

sub Reshape {
	my ($width, $height) = @_;

    glViewport(0, 0, $width, $height);
}


sub Key {
	my ($key, $x, $y ) = @_;
	
	if ($key == 27 or $key == ord 'q' or $key == ord 'Q') {
		MyExit();
	} elsif ($key == ord('s')) {
		$smooth = !$smooth;
		if ($smooth) {
		    glShadeModel(GL_SMOOTH);
		} else {
		    glShadeModel(GL_FLAT);
		}
	} elsif ($key == ord('0')) {
		$light0 = !$light0;
		if ($light0) {
		    glEnable(GL_LIGHT0);
		} else {
		    glDisable(GL_LIGHT0);
		}
	} elsif ($key == ord('1')) {
		$light1 = !$light1;
		if ($light1) {
		    glEnable(GL_LIGHT1);
		} else {
		    glDisable(GL_LIGHT1);
		}
	} elsif ($key == ord('l')) {
		$lighting = !$lighting;
		if ($lighting) {
		    glEnable(GL_LIGHTING);
		} else {
		    glDisable(GL_LIGHTING);
		}
   } else {
   	return;
   }
   glutPostRedisplay();
}

sub SpecialKey {
	my ($key, $x, $y ) = @_;

	if  ($key ==  GLUT_KEY_LEFT) {
		$yrot -= 15.0;
	} elsif ($key == GLUT_KEY_RIGHT) {
		$yrot += 15.0;
	} elsif ($key == GLUT_KEY_UP) {
		$xrot += 15.0;
	} elsif ($key == GLUT_KEY_DOWN) {
		$xrot -= 15.0;
    } else {
    	return;
    }
    glutPostRedisplay();
}


#sub  Args(int argc, char **argv)
#{
#   GLint i;
#
#   for (i = 1; i < argc; i++) {
#      if (strcmp(argv[i], "-sb") == 0) {
#         doubleBuffer = GL_FALSE;
#      }
#      else if (strcmp(argv[i], "-db") == 0) {
#         doubleBuffer = GL_TRUE;
#      }
#      else if (strcmp(argv[i], "-speed") == 0) {
#         speed_test = GL_TRUE;
#         doubleBuffer = GL_TRUE;
#      }
#      else if (strcmp(argv[i], "-va") == 0) {
#         use_vertex_arrays = GL_TRUE;
#      }
#      else {
#         printf("%s (Bad option).\n", argv[i]);
#         return GL_FALSE;
#      }
#   }
#
#   return GL_TRUE;
#}

my $WindowId;

#int main(int argc, char **argv)
#{
#   GLenum type;
#   char *extensions;

   read_surface_bin( "$FindBin::Bin/isosurf.bin" );

#   if (Args(argc, argv) == GL_FALSE) {
#      exit(0);
#   }

   glutInit();
   glutInitWindowPosition(0, 0);
   glutInitWindowSize(400, 400);
   
   my $type = GLUT_DEPTH;
   $type |= GLUT_RGB;
   $type |= ($doubleBuffer) ? GLUT_DOUBLE : GLUT_SINGLE;
   glutInitDisplayMode($type);

   if (($WindowId = glutCreateWindow("Isosurface")) <= 0) {
      exit(0);
   }

   if (defined &OpenGL::glVertexPointer_c) {
     print "Using Vertex Array...\n";
   } else {
     print "No Vertex Array extension found, using a slow method...\n";
     $use_vertex_arrays = 0;
   }

   Init();

   glutReshapeFunc(\&Reshape);
   glutKeyboardFunc(\&Key);
   glutSpecialFunc(\&SpecialKey);
   glutDisplayFunc(\&Draw);
   glutMainLoop();

sub MyExit { exit }
