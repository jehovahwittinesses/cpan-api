use strict;
use warnings;

use MetaCPAN::Server::Test;
use Test::More;

my %tests = (
    '/mirror'             => 200,
    '/mirror/DOESNEXIST'  => 404,
    '/mirror/_search?q=*' => 200,
);

test_psgi app, sub {
    my $cb = shift;
    while ( my ( $k, $v ) = each %tests ) {
        ok( my $res = $cb->( GET $k), "GET $k" );
        is( $res->code, $v, "code $v" );
        is(
            $res->header('content-type'),
            'application/json; charset=utf-8',
            'Content-type'
        );
        ok( my $json = eval { decode_json( $res->content ) }, 'valid json' );
    }
};

done_testing;
