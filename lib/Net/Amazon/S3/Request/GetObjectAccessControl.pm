package Net::Amazon::S3::Request::GetObjectAccessControl;

use Moose 0.85;
use MooseX::StrictConstructor 0.16;
extends 'Net::Amazon::S3::Request';

# ABSTRACT: An internal class to get an object's access control

with 'Net::Amazon::S3::Role::Bucket';

has 'key'    => ( is => 'ro', isa => 'Str',         required => 1 );

__PACKAGE__->meta->make_immutable;

sub http_request {
    my $self = shift;

    return $self->_build_http_request(
        method => 'GET',
        path   => $self->_uri($self->key) . '?acl',
    );
}

1;

__END__

=for test_synopsis
no strict 'vars'

=head1 SYNOPSIS

  my $http_request = Net::Amazon::S3::Request::GetObjectAccessControl->new(
    s3     => $s3,
    bucket => $bucket,
    key    => $key,
  )->http_request;

=head1 DESCRIPTION

This module gets an object's access control.

=head1 METHODS

=head2 http_request

This method returns a HTTP::Request object.

