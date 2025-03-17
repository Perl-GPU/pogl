package OpenGL::GLUT;

=head1 NAME

OpenGL::GLUT - module encapsulating GLUT functions

=cut

use strict;
use warnings;

use Exporter 'import';
require DynaLoader;

our $VERSION = '0.7003';
our @ISA = qw(DynaLoader);

__PACKAGE__->bootstrap;

1;
