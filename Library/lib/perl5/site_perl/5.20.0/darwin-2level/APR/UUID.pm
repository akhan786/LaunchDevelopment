# 
# /*
#  * *********** WARNING **************
#  * This file generated by ModPerl::WrapXS/0.01
#  * Any changes made here will be lost
#  * ***********************************
#  * 01: lib/ModPerl/Code.pm:709
#  * 02: lib/ModPerl/WrapXS.pm:633
#  * 03: lib/ModPerl/WrapXS.pm:1182
#  * 04: Makefile.PL:427
#  * 05: Makefile.PL:329
#  * 06: Makefile.PL:58
#  */
# 


package APR::UUID;

use strict;
use warnings FATAL => 'all';


use APR ();
use APR::XSLoader ();
our $VERSION = '0.009000';
APR::XSLoader::load __PACKAGE__;



1;
__END__

=head1 NAME

APR::UUID - Perl API for manipulating APR UUIDs




=head1 Synopsis

  use APR::UUID ();
  
  # get a random UUID and format it as a string
  my $uuid = APR::UUID->new->format;
  # $uuid = e.g. 'd48889bb-d11d-b211-8567-ec81968c93c6';
  
  # same as the object returned by APR::UUID->new
  my $uuid_parsed = APR::UUID->parse($uuid);


=head1 Description

C<APR::UUID> is used to get and manipulate random UUIDs.

It allows you to C<L<create|/C_new_>> random UUIDs, which when
C<L<format|/C_format_>ted> returns a string like:

  'd48889bb-d11d-b211-8567-ec81968c93c6';

which can be parsed back into the C<APR::UUID> object with
C<L<parse()|/C_parse_>>.









=head1 API

C<APR::UUID> provides the following functions and/or methods:






=head2 C<format>

Convert an C<L<APR::UUID object|docs::2.0::api::APR::UUID>> object
into a string presentation:

  my $uuid_str = $uuid->format;

=over 4

=item obj: C<$uuid>
( C<L<APR::UUID object|docs::2.0::api::APR::UUID>> )

=item ret: C<$uuid_str>

returns a string representation of the object (.e.g
C<'d48889bb-d11d-b211-8567-ec81968c93c6'>).

=item since: 2.0.00

=back






=head2 C<new>

Create a C<L<APR::UUID object|docs::2.0::api::APR::UUID>> using the
random engine:

  my $uuid = APR::UUID->new;

=over 4

=item class: C<APR::UUID>
( C<L<APR::UUID class|docs::2.0::api::APR::UUID>> )

=item ret: C<$uuid>
( C<L<APR::UUID object|docs::2.0::api::APR::UUID>> )

=item since: 2.0.00

=back





=head2 C<DESTROY>

  $uuid->DESTROY;

=over 4

=item obj: C<APR::UUID>
( C<L<APR::UUID object|docs::2.0::api::APR::UUID>> )

=item ret: no return value

=item since: 2.0.00

=back

Do not call this method, it's designed to be only called by Perl when
the variable goes out of scope. If you call it yourself you will get a
segfault when perl will call DESTROY on its own.






=head2 C<parse>

Convert a UUID string into an C<L<APR::UUID
object|docs::2.0::api::APR::UUID>> object:

  $uuid = APR::UUID->parse($uuid_str)

=over 4

=item arg1: C<$uuid_str> (string)

UUID string (.e.g C<'d48889bb-d11d-b211-8567-ec81968c93c6'>)

=item ret: C<$uuid>
( C<L<APR::UUID object|docs::2.0::api::APR::UUID>> )

The new object.

=item since: 2.0.00

=back






=head1 See Also

L<mod_perl 2.0 documentation|docs::2.0::index>.




=head1 Copyright

mod_perl 2.0 and its core modules are copyrighted under
The Apache Software License, Version 2.0.




=head1 Authors

L<The mod_perl development team and numerous
contributors|about::contributors::people>.

=cut
