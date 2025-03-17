package OpenGL::GLU;

=head1 NAME

OpenGL::GLU - module encapsulating GLU functions

=cut

use strict;
use warnings;

use Exporter 'import';
require DynaLoader;

our $VERSION = '0.7003';
our @ISA = qw(DynaLoader);

__PACKAGE__->bootstrap;

1;
