package OpenGL::Array;

use strict;
use warnings;

use Exporter 'import';
require DynaLoader;

our $VERSION = '0.7101';
our @ISA = qw(DynaLoader);
our @EXPORT_OK = qw(glpHasGPGPU);

__PACKAGE__->bootstrap;

sub CLONE_SKIP { 1 } # OpenGL::Array is not thread safe

1;

__END__

=head1 NAME

OpenGL::Array - Perl Array handling and conversion between Perl arrays and C array pointers.

=head1 SYNOPSIS

    use OpenGL qw(GL_FLOAT);

    my $array = OpenGL::Array->new(4, GL_FLOAT);
    my $c_ptr = $array->ptr(); # can be passed to OpenGL _c based functions
    $array->calc('col,27,+');
    my @val = $array->retrieve(0, 4);

=head1 DESCRIPTION

OpenGL::Array (OGA) objects provide Perl Array handling and conversion
between Perl arrays and C array pointers.

Due to the difference between how Perl and C handle pointers, all Perl
OpenGL (POGL) APIs that require pointers are suffixed with _c. OGAs
provide a means to convert Perl arrays into C pointers that can be
passed into these APIs.

Many POGL _c APIs also have a _s version to support SDL's packed
string APIs; OGA provides APIs to convert between C arrays and packed
strings.

POGL also provides many _p APIs that accept native Perl arrays, or in
some cases OGAs directly. In the case of VBOs, OGAs may be bound to
GPU buffers, automatically switching buffers at render time.

Note: Since OGAs are stored as typed C arrays, there is no
conversion/copy/casting when passing them to POGL APIs, resulting in
significant performance improvements over other non-compiled bindings
(SDL, PyOpenGL, etc).

=head1 CREATING OpenGL::Array OBJECTS

=over 4

=item C<new>

    my $array = OpenGL::Array->new($count,@types);

Creates an empty array object of $count rows made up data types @types.

=item C<new_list>

    my $array = OpenGL::Array->new_list($type,@data);

Creates and populates a uniform array object made up @data of type $type.

=item C<new_pointer>

    my $array = OpenGL::Array->new_pointer($type,ptr,$elements);

Creates an array object wrapper around a C pointer ptr of type $type
and array length $elements. Caches C pointer directly; does not copy
data.

Note: because OpenGL::Arrays store to direct memory addresses, it is
possible to assign to the array the pointer was obtained from and the
results will be available in the array created by new_pointer - and
vice versa (because they are viewing portions of the same memory).

=item C<new_scalar>

    my $str = pack 'C*', 1 .. 255;
    my $array = OpenGL::Array->new_scalar(GL_UNSIGNED_BYTE, $str, length($str));

Creates an array object from a perl scalar.

=item C<new_from_pointer>

    my $array1 = OpenGL::Array->new_list(GL_UNSIGNED_BYTE, 1..9);
    my $array2 = OpenGL::Array->new_from_pointer($array1->ptr(), 9);

Special case, creates a uniform GL_UNSIGNED_BYTE from a pointer.

=back

=head1 USING OpenGL::Array OBJECT'S C POINTERS

OpenGL::Array objects are Perl references; in order to use them in
OpenGL APIs that expect C pointers, you need to use the native
pointer:

      my $array = OpenGL::Array->new(4, GL_INT);
      glGetIntegerv_c(GL_VIEWPORT, $array->ptr);
      my @viewport = $array->retrieve(0, 4);

=head1 OpenGL::Array ACCESSORS

=over 4

=item C<assign>

    $array->assign($pos, @data);

Sets array data starting at element position $pos using @data.

=item C<assign_data>

    $array->assign_data($pos, $data);

Sets array data element position $pos using packed string $data.

=item C<retrieve>

    my @data = $array->retrieve($pos, $len);

Returns an array of $len elements from an array object.

=item C<retrieve_data>

    my $data = $array->retrieve_data($pos, $len);

Returns a packed string of length $len bytes from an array object.

=item C<elements>

    my $count = $array->elements();

Returns the element count from an array object.

=item C<ptr>

    ptr = $array->ptr(); # typically passed to opengl _c functions

Returns a C pointer to an array object.

Returns a C pointer to an array object.

=item C<offset>

    ptr = $array->offset($pos);

Returns a C pointer to the $pos element of an array object.

=item C<update_ptr>

    $array->update_pointer($ptr);

Points the existing OpenGL::Array to a different data pointer.

=back

=head1 BINDING TO VBOs

Helps abstract Vertex Array and VBO rendering.

# Requires GL_ARB_vertex_buffer_object extension and POGL 0.55_01 or newer

=over 4

=item C<bind>

    $array->bind($id);

Binds a GPU buffer to an array object.  If bound, glXxxPointer_p APIs
will call glBindBufferARB.

=item C<bound>

    my $id = $array->bound();

Return bound buffer ID, or 0 if not bound.

=back

=head1 AFFINE TRANSFORMS ON OpenGL::Array OBJECTS

Eventually, this API will abstract CPU vs GPU-based affine transforms
for the best performance.

=over 4

=item C<affine>

    $array->affine($xform);

    # $xform is an NxN OpenGL::Array object used to transform $array.

    #N must be one element wider than the width of the array.

=back

=head1 Calc: POPULATING AND MANIPULATING OpenGL::Array OBJECTS

=over 4

=item C<calc>

Used to populate or mathematically modify an POGL array. Uses Reverse
Polish Notation (RPN) for mathematical operations.  At the moment, any
array used with calc must be made of only of GL_FLOAT types.

    $array->calc($value);

Populates the array with $value.

    $array->calc(@values);

Populates each row of the array with @values, assuming rows have the
same width as the length of @values.  If the number of passed values
must be evenly divisible by the number of elements in the array.
The number of values becomes the number of "columns."  The number of
"rows" is the total number of elements of the array divided by the
columns.

    $array->calc(1.0, '3,*', '2,*,rand,+', '');

Resets the first column of each row to 1.0; multiplies the values in
the second column by 3; multiplies the third column by 2, then adds a
random number between 0 and 1; leaves the fourth column alone.  During
this particular calc operation there would be 4 columns.

C<calc> maintains a push/pop stack and a "register" for each column.

C<calc> also allows for other OpenGL::Arrays to be passed in.  If
multiple arrays are passed they must all have the same number of
elements.  Only the calling array will be operated on, but as each
element is visited, the values from the other arrays are pre-added to
the stack (in reverse order).

    $array->calc($array2, $array3, $array4, @values);

calc currently supports the following primitives:

=over 4

=item C<!>

Logical "Not" for End of Stack (S0) for the current column; becomes
1.0 if empty or 0. otherwise 1.0

=item C<->

Arithmetic Negation of S0

=item C<+>

Add S0 and Next on Stack (S1), pop operands and push result (Result)

=item C<*>

Multiply S0 and S1; Result

=item C</>

Divide S1 by S0; Result

=item C<%>

S1 Modulus S0; Result

=item C<=>

Test S0 equality to S1; pop operands and push non-zero (1.0) for true,
otherwise 0.0 (Boolean)

=item C<< > >>

Test if S0 Greater than S1; Boolean

=item C<< < >>

Test if S0 Lesser than S1; Boolean

=item C<?>

If S0 is true (non-zero), pop S0 and S1; otherwise pop s0-3, push s1

=item C<pop>

Pop s0

=item C<rand>

Push a random number from 0.0 to 1.0

=item C<dup>

Push a copy of S0

=item C<swap>

Swap values of S0 and S1

=item C<set>

Copy S0 to the column's Register

=item C<get>

Push the column's Register onto the column's Stack

=item C<store>

Pop S0, and copy the values from the matching row of the passed
OpenGL::Array at that index.  Values are copied into the current
column registers.

  my $o1 = OpenGL::Array->new_list(GL_FLOAT, 1, 2, 3,  4, 5, 6);
  my $o2 = OpenGL::Array->new_list(GL_FLOAT, 7, 8 ,9,  10, 11, 12);
  $o1->calc($o2, "1,store,get","","get");
  $o1->retreive(0,6) will be (7, 2, 9,  10, 5, 12)

=item C<load>

Pop S0, and set the values of the matching row of the passed
OpenGL::Array named at that index.  Values are copied from the current
column registers.

  my $o1 = OpenGL::Array->new_list(GL_FLOAT, 1, 2, 3,  4, 5, 6);
  my $o2 = OpenGL::Array->new_list(GL_FLOAT, 7, 8 ,9,  10, 11, 12);
  $o1->calc($o2, "set","", "set,1,load");
  $o2->retreive(0,6) will be (1, 0, 3,  5, 0, 6)

=item C<colget>

Pop S0, and push the column S0 value onto the current stack.

   $o = OpenGL::Array->new_list(GL_FLOAT, 1, 2, 3,  4, 5, 6);
   $o->calc('2,colget','','');
   # $o->retreive(0,6) will be (3, 2, 3, 6, 5, 6)

=item C<colset>

Pop S0, and set the column S0 value to the new top of the stack.

   $o = OpenGL::Array->new_list(GL_FLOAT, 1, 2, 3,  4, 5, 6);
   $o->calc('27,2,colset','','');
   # $o->retreive(0,6) will be (1, 2, 27,  4, 5, 27)

=item C<rowget>

Pop S0 and S1, and push the column S0 value from row S1 onto the current stack.

   $o = OpenGL::Array->new_list(GL_FLOAT, 1, 2, 3,  4, 5, 6);
   $o->calc('1,2,rowget','','');
   # $o->retreive(0,6) equiv (6, 2, 3,  6, 5, 6)

=item C<rowset>

Pop S0 and S1, and set the column S0 value of row S1 to the new top of the stack.

   $o = OpenGL::Array->new_list(GL_FLOAT, 1, 2, 3,  4, 5, 6);
   $o->calc('27,1,2,rowset','','');
   # $o->retreive(0,6) will be (1, 2, 3,  4, 5, 27)

=item C<end>

End processing; column unchanged

=item C<endif>

Pop S0, End if true; column unchanged

=item C<endrow>

End processing of current row; column unchanged

=item C<endrowif>

Pop S0, End processing of current row if true; column unchanged

=item C<return>

End processing; column value set to s0

=item C<returnif>

Pop S0, End if true; column value set to s0

=item C<returnrow>

End processing of current row; column value set to s0

=item C<returnrowif>

Pop S0, End processing of current row if true; column value set to s0

=item C<if>

alias to C<?>

=item C<or>

alias to C<+>

=item C<and>

alias to C<*>

=item C<inc>

Add 1 to S0

=item C<dec>

Subtract 1 from S0

=item C<sum>

Add and pop everything in stack; push result

=item C<avg>

Average and pop everything in stack; push result

=item C<abs>

Replace S0 with its absolute value

=item C<power>

Raise S1 to the power of S0; Result

=item C<min>

The lower of S0 and S1; Result

=item C<max>

The higher of S0 and S1; Result

=item C<sin>

Sine of S0 in Radians; Result

=item C<cos>

Cosine of S0; Result

=item C<tan>

Tangent of S0; Result

=item C<atan2>

ArcTangent of S1 over s0; Result

=item C<count>

Push the number of elements in the array

=item C<index>

Push the current element index (zero-based)

=item C<columns>

Push the number of columns in the array

=item C<column>

Push the current column index

=item C<rows>

Push the number of rows in the array

=item C<row>

Push the current row index

=item C<pi>

Push the the value of PI (but remember calc is just for floats)

=item C<dump>

Print a dump of the current stack to standard out.

    OpenGL::Array->new_list(GL_FLOAT,7)->calc("dup,dec,2,swap,10,4,set,dump");

Would print:

    -----------------(row: 0, col: 0)----
    Register: 4.0000000
    Stack  4: 7.0000000
    Stack  3: 2.0000000
    Stack  2: 6.0000000
    Stack  1: 10.0000000
    Stack  0: 4.0000000

=back

=back

=head1 AUTHOR

Bulk of documentation taken from http://graphcomp.com/pogl.cgi?v=0111s3p1&r=s3p6

Additions by Paul Seamons

=cut
