package Exception::Delayed;

# ABSTRACT: Execute code and throw exceptions later

use strict;
use warnings;

# VERSION

=head1 SYNOPSIS

    my $x = Exception::Delayed->wantscalar(sub {
        ...
        die "meh";
        ...
    }); # code is immediately executed

    my $y = $x->result; # dies with "meh"

=head1 DESCRIPTION

This module is useful whenever an exception should be thrown at a later moment, without using L<Try::Tiny> or similiar.

Since the context cannot be guessed, this module provides two entry-points: L</wantscalar> and L</wantlist>.

=head1 METHODS

=head2 wantscalar

    my $x = Exception::Delayed->wantscalar($coderef, @arguments);
    # same as:
    my $x = scalar $coderef->(@arguments);

Execute code in a scalar context. If an exception is thrown, it will be catched and stored, but not thrown (yet).

=cut

sub wantscalar {
    my ($class, $code, @args) = @_;
    my $RV;
    eval {
        $RV = scalar $code->(@args);
    };
    if ($@) {
        return bless { error => $@ } => $class;
    } else {
        return bless { result => \$RV } => $class;
    }
}

=head2 wantlist

    my @x = Exception::Delayed->wantscalar($coderef, @arguments);
    # same as:
    my @x = $coderef->(@arguments);

Execute code in a list context. If an exception is thrown, it will be catched and stored, but not thrown (yet).

=cut

sub wantlist {
    my ($class, $code, @args) = @_;
    my @RV;
    eval {
        @RV = $code->(@args);
    };
    if ($@) {
        return bless { error => $@ } => $class;
    } else {
        return bless { result => \@RV } => $class;
    }
}

=head2 result

Return the result of the executed code. Or dies, if there was any exception.

=cut

sub result {
    my ($self) = @_;
    if (exists $self->{error}) {
        die $self->{error};
    } else {
        my $result = delete $self->{result};
        if (ref $result eq 'ARRAY') {
            return @$result;
        } elsif (ref $result eq 'SCALAR') {
            return $$result;
        } else {
            return;
        }
    }
}

1;
