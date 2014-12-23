#! perl -T

use lib 't/lib';

use Test::More;
use WG::Test;

ok( my $wg = WG::Test->new() );
ok( $wg->config() , "Ok can get config");
ok( -d $wg->share_dir() , "Ok share dir exists");
ok( $wg->developer() , "Ok can get developer");

done_testing();