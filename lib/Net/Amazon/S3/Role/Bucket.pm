
use strict;
use warnings;

package Net::Amazon::S3::Role::Bucket;

use Moose::Role;
use Scalar::Util;

around BUILDARGS => sub {
    my ($orig, $class, %params) = @_;

    $params{bucket} = $params{bucket}->name
        if $params{bucket}
        and Scalar::Util::blessed( $params{bucket} )
        and $params{bucket}->isa( 'Net::Amazon::S3::Client::Bucket' )
        ;

    $params{bucket} = Net::Amazon::S3::Bucket->new(
        bucket => $params{bucket},
        account => $params{s3},
    ) if $params{bucket} and ! ref $params{bucket};

    $class->$orig( %params );
};

has bucket => (
    is => 'ro',
    isa => 'Net::Amazon::S3::Bucket',
    required => 1,
);

1;

