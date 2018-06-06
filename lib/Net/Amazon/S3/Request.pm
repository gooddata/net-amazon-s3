package Net::Amazon::S3::Request;

use Moose 0.85;
use MooseX::StrictConstructor 0.16;
use Moose::Util::TypeConstraints;
use Regexp::Common qw /net/;

# ABSTRACT: Base class for request objects

enum 'AclShort' =>
    [ qw(private public-read public-read-write authenticated-read) ];
enum 'LocationConstraint' => [
    # https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region
    'ap-northeast-1',
    'ap-northeast-2',
    'ap-northeast-3',
    'ap-south-1',
    'ap-southeast-1',
    'ap-southeast-2',
    'ca-central-1',
    'cn-north-1',
    'cn-northwest-1',
    'eu-central-1',
    'eu-west-1',
    'eu-west-2',
    'eu-west-3',
    'sa-east-1',
    'us-east-1',
    'us-east-2',
    'us-west-1',
    'us-west-2',
];

subtype 'MaybeLocationConstraint'
    => as 'Maybe[LocationConstraint]'
    ;

# maintain backward compatiblity with 'US' and 'EU' values
my %location_constraint_alias = (
    US => 'us-east-1',
    EU => 'eu-west-1',
);

enum 'LocationConstraintAlias' => [ keys %location_constraint_alias ];

coerce 'LocationConstraint'
    => from 'LocationConstraintAlias'
    => via { $location_constraint_alias{$_} }
    ;

coerce 'MaybeLocationConstraint'
    => from 'LocationConstraintAlias'
    => via { $location_constraint_alias{$_} }
    ;

# To comply with Amazon S3 requirements, bucket names must:
# Contain lowercase letters, numbers, periods (.), underscores (_), and dashes (-)
# Start with a number or letter
# Be between 3 and 255 characters long
# Not be in an IP address style (e.g., "192.168.5.4")

subtype 'BucketName1' => as 'Str' => where {
    $_ =~ /^[a-zA-Z0-9._-]+$/;
} => message {
    "Bucket name ($_) must contain lowercase letters, numbers, periods (.), underscores (_), and dashes (-)";
};

subtype 'BucketName2' => as 'BucketName1' => where {
    $_ =~ /^[a-zA-Z0-9]/;
} => message {
    "Bucket name ($_) must start with a number or letter";
};

subtype 'BucketName3' => as 'BucketName2' => where {
    length($_) >= 3 && length($_) <= 255;
} => message {
    "Bucket name ($_) must be between 3 and 255 characters long";
};

subtype 'BucketName' => as 'BucketName3' => where {
    $_ !~ /^$RE{net}{IPv4}$/;
} => message {
    "Bucket name ($_) must not be in an IP address style (e.g., '192.168.5.4')";
};

has 's3' => ( is => 'ro', isa => 'Net::Amazon::S3', required => 1 );

__PACKAGE__->meta->make_immutable;

sub _uri {
    my ( $self, $key ) = @_;
    my $bucket = $self->bucket->bucket;

    return (defined($key))
        ? $bucket . "/" . (join '/', map {$self->s3->_urlencode($_)} split /\//, $key)
        : $bucket . "/";
}

sub _build_signed_request {
    my ($self, %params) = @_;

    return Net::Amazon::S3::HTTPRequest->new(
        %params,
        s3 => $self->s3,
        $self->can( 'bucket' ) ? (bucket => $self->bucket) : (),
    );
}

sub _build_http_request {
    my ($self, %params) = @_;

    return $self->_build_signed_request( %params )->http_request;
}

1;

__END__

=head1 SYNOPSIS

  # do not instantiate directly

=head1 DESCRIPTION

This module is a base class for all the Net::Amazon::S3::Request::*
classes.
