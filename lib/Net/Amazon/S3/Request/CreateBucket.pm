package Net::Amazon::S3::Request::CreateBucket;

use Moose 0.85;
extends 'Net::Amazon::S3::Request';

# ABSTRACT: An internal class to create a bucket

with 'Net::Amazon::S3::Role::Bucket';

has 'acl_short' => ( is => 'ro', isa => 'Maybe[AclShort]', required => 0 );
has 'location_constraint' =>
    ( is => 'ro', isa => 'MaybeLocationConstraint', coerce => 1, required => 0 );

__PACKAGE__->meta->make_immutable;

sub http_request {
    my $self = shift;

    my $headers
        = ( $self->acl_short )
        ? { 'x-amz-acl' => $self->acl_short }
        : {};

    my $content = '';
    if ( defined $self->location_constraint &&
         $self->location_constraint ne 'us-east-1') {
        $content
            = "<CreateBucketConfiguration><LocationConstraint>"
            . $self->location_constraint
            . "</LocationConstraint></CreateBucketConfiguration>";
    }

    return $self->_build_http_request(
        method  => 'PUT',
        path    => $self->_uri,
        headers => $headers,
        content => $content,
        region  => 'us-east-1',
    );
}

1;

__END__

=for test_synopsis
no strict 'vars'

=head1 SYNOPSIS

  my $http_request = Net::Amazon::S3::Request::CreateBucket->new(
    s3                  => $s3,
    bucket              => $bucket,
    acl_short           => $acl_short,
    location_constraint => $location_constraint,
  )->http_request;

=head1 DESCRIPTION

This module creates a bucket.

=head1 METHODS

=head2 http_request

This method returns a HTTP::Request object.

