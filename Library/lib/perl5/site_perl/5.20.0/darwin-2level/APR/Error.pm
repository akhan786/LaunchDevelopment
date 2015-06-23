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


package APR::Error;

use strict;
use warnings FATAL => 'all';


use APR ();
use APR::XSLoader ();
our $VERSION = '0.009000';
APR::XSLoader::load __PACKAGE__;

require Carp;
require Carp::Heavy;

use APR::Util ();

use overload
    nomethod => \&fatal,
    'bool'   => \&str,
    '=='     => \&num_cmp,
    '!='     => \&num_cmp_not,
    '0+'     => \&num,
    '""'     => \&str;

sub fatal {  die __PACKAGE__ . ": Can't handle '$_[3]'" }

# normally the object is created on the C side, but if you want to
# create one from Perl, you can. just pass a hash with args:
# rc, file, line, func
sub new {
    my $class = shift;
    my %args = @_;
    bless \%args, $class;
}

#
# - even though most of the time the error id is not useful to the end
#   users, developers may need to know it. For example in case of a
#   non-english user locale setting, the error string could be
#   incomprehensible to a developer, but by having the error id it's
#   possible to find the english equivalent
# - the filename and line number are needed because perl doesn't
#   provide that info when exception objects are involved
sub str {
    return sprintf "%s: (%d) %s at %s line %d", $_[0]->{func},
        $_[0]->{rc}, APR::Error::strerror($_[0]->{rc}),
        $_[0]->{file}, $_[0]->{line};
}

sub num { $_[0]->{rc} }

sub num_cmp     { $_[0]->{rc} == $_[1] }
sub num_cmp_not { $_[0]->{rc} != $_[1] }

# skip the wrappers from this package from the long callers trace
$Carp::CarpInternal{+__PACKAGE__}++;

# XXX: Carp::(confess|cluck) see no calls stack when Perl_croak is
# called with (char *)NULL (which is the way exception objects are
# returned), so we fixup it here (doesn't quite work for croak
# caller).
sub cluck {
    if (ref $_[0] eq __PACKAGE__) {
        Carp::cluck("$_[0]->{func}: ($_[0]->{rc}) " .
                    APR::Error::strerror($_[0]->{rc}));
    }
    else {
        &Carp::cluck;
    }
}

sub confess {
    if (ref $_[0] eq __PACKAGE__) {
        Carp::confess("$_[0]->{func}: ($_[0]->{rc}) " .
                    APR::Error::strerror($_[0]->{rc}));
    }
    else {
        &Carp::confess;
    }
}


1;
__END__

=head1 NAME

APR::Error - Perl API for APR/Apache/mod_perl exceptions




=head1 Synopsis

  eval { $obj->mp_method() };
  if ($@ && $ref $@ eq 'APR::Error' && $@ == $some_code) {
      # handle the exception
  }
  else {
      die $@; # rethrow it
  }


=head1 Description

C<APR::Error> handles APR/Apache/mod_perl exceptions for you, while
leaving you in control.

Apache and APR API return a status code for almost all methods, so if
you didn't check the return code and handled any possible problems,
you may have silent failures which may cause all kind of obscure
problems. On the other hand checking the status code after each call
is just too much of a kludge and makes quick prototyping/development
almost impossible, not talking about the code readability. Having
methods return status codes, also complicates the API if you need to
return other values.

Therefore to keep things nice and make the API readable we decided to
not return status codes, but instead throw exceptions with
C<APR::Error> objects for each method that fails. If you don't catch
those exceptions, everything works transparently - perl will intercept
the exception object and C<die()> with a proper error message. So you
get all the errors logged without doing any work.

Now, in certain cases you don't want to just die, but instead the
error needs to be trapped and handled. For example if some IO
operation times out, may be it is OK to trap that and try again. If we
were to die with an error message, you would have had to match the
error message, which is ugly, inefficient and may not work at all if
locale error strings are involved. Therefore you need to be able to
get the original status code that Apache or APR has generated. And the
exception objects give you that if you want to. Moreover the objects
contain additional information, such as the function name (in case you
were eval'ing several commands in one block), file and line number
where that function was invoked from. More attributes could be added
in the future.

C<APR::Error> uses Perl operator overloading, such that in boolean and
numerical contexts, the object returns the status code; in the string
context the full error message is returned.

When intercepting exceptions you need to check whether C<$@> is an
object (reference). If your application uses other exception objects
you additionally need to check whether this is a an C<APR::Error>
object. Therefore most of the time this is enough:

  eval { $obj->mp_method() };
  if ($@ && $ref $@ && $@ == $some_code)
      warn "handled exception: $@";
  }

But with other, non-mod_perl, exception objects you need to do:

  eval { $obj->mp_method() };
  if ($@ && $ref $@ eq 'APR::Error' && $@ == $some_code)
      warn "handled exception: $@";
  }

In theory you could even do:

  eval { $obj->mp_method() };
  if ($@ && $@ == $some_code)
      warn "handled exception: $@";
  }

but it's possible that the method will die with a plain string and not
an object, in which case C<$@ == $some_code> won't quite
work. Remember that mod_perl throws exception objects only when Apache
and APR fail, and in a few other special cases of its own (like
C<L<exit|docs::2.0::api::ModPerl::Util/C_exit_>>).

  warn "handled exception: $@" if $@ && $ref $@;

There are two ways to figure out whether an error fits your case. In
most cases you just compare C<$@> with an the error constant. For
example if a socket has a timeout set and the data wasn't read within
the timeout limit a
C<L<APR::Const::TIMEUP|docs::2.0::api::APR::Const/C_APR__Const__TIMEUP_>>)

  use APR::Const -compile => qw(TIMEUP);
  $sock->timeout_set(1_000_000); # 1 sec
  my $buff;
  eval { $sock->recv($buff, BUFF_LEN) };
  if ($@ && ref $@ && $@ == APR::Const::TIMEUP) {

  }

However there are situations, where on different Operating Systems a
different error code will be returned. In which case to simplify the
code you should use the special subroutines provided by the
C<L<APR::Status|docs::2.0::api::APR::Status>> class. One such
condition is socket C<recv()> timeout, which on Unix throws the
C<EAGAIN> error, but on other system it throws a different error. In
this case
C<L<APR::Status::is_EAGAIN|docs::2.0::api::APR::Status/C_is_EAGAIN_>>
should be used.

Let's look at a complete example. Here is a code that performs L<a
socket read|docs::2.0::api::APR::Socket/C_recv_>:

  my $rlen = $sock->recv(my $buff, 1024);
  warn "read $rlen bytes\n";

and in certain cases it times out. The code will die and log the
reason for the failure, which is fine, but later on you may decide
that you want to have another attempt to read before dying and add
some fine grained sleep time between attempts, which can be achieved
with C<select>. Which gives us:

  use APR::Status ();
  # ....
  my $tries = 0;
  my $buffer;
  RETRY: my $rlen = eval { $sock->recv($buffer, SIZE) };
  if ($@)
      die $@ unless ref $@ && APR::Status::is_EAGAIN($@);
      if ($tries++ < 3) {
          # sleep 250msec
          select undef, undef, undef, 0.25;
          goto RETRY;
      }
      else {
          # do something else
      }
  }
  warn "read $rlen bytes\n"

Notice that we handle non-object and non-C<APR::Error> exceptions as
well, by simply re-throwing them.

Finally, the class is called C<APR::Error> because it needs to be used
outside mod_perl as well, when called from
C<L<APR|docs::2.0::api::APR>> applications written in Perl.



=head1 API

=head2 C<cluck>

C<cluck> is an equivalent of C<Carp::cluck> that works with
C<APR::Error> exception objects.

=head2 C<confess>

C<confess> is an equivalent of C<Carp::confess> that works with
C<APR::Error> exception objects.


=head2 C<strerror>

Convert APR error code to its string representation.

  $error_str = APR::Error::strerror($rc);

=over 4

=item ret: C<$rc> ( C<L<APR::Const status
constant|docs::2.0::api::APR::Const>> )

The numerical value for the return (error) code

=item ret: C<$error_str> ( string )

The string error message corresponding to the numerical value inside
C<$rc>.  (Similar to the C function C<strerror(3)>)

=item since: 2.0.00

=back

Example:

Try to retrieve the bucket brigade, and if the return value doesn't
indicate success or end of file (usually in protocol handlers) die,
but give the user the human-readable version of the error and not just
the code.

  my $rc = $c->input_filters->get_brigade($bb_in,
                                          Apache2::Const::MODE_GETLINE);
  if ($rc != APR::Const::SUCCESS && $rc != APR::Const::EOF) {
      my $error = APR::Error::strerror($rc);
      die "get_brigade error: $rc: $error\n";
  }

It's probably a good idea not to omit the numerical value in the error
message, in case the error string is generated with non-English
locale.





=head1 See Also

L<mod_perl 2.0 documentation|docs::2.0::index>.




=head1 Copyright

mod_perl 2.0 and its core modules are copyrighted under
The Apache Software License, Version 2.0.




=head1 Authors

L<The mod_perl development team and numerous
contributors|about::contributors::people>.

=cut

