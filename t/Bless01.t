BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
}

use Test::More tests => 12;
use strict;
use warnings;

use threads;
use threads::shared;

use_ok( 'Thread::Bless' ); # just for the record
can_ok( 'Thread::Bless',qw(
 destroy
 fixup
 import
) );

my $count : shared;

$count = 0;
eval { Without->new };
ok (!$@, "Object going out of scope: $@" );
is( $count,0,"Check # of destroys of WithoutDestroy" );

$count = 0;
eval { WithDestroy->new };
ok (!$@, "Object going out of scope: $@" );
is( $count,1,"Check # of destroys of WithDestroy" );

$count = 0;
eval {
    my $object = WithDestroy->new;
    threads->new( sub {1} )->join foreach 1..5;
};
ok (!$@, "Object going out of scope: $@" );
is( $count,1,"Check # of destroys of WithDestroy, with threads" );

$count = 0;
eval { WithDestroyAll->new };
ok (!$@, "Object going out of scope: $@" );
is( $count,1,"Check # of destroys of WithDestroyAll" );

$count = 0;
eval {
    my $object = WithDestroyAll->new;
    foreach (1..5) {
        threads->new( sub { 1 } )->join;
    }
};
ok (!$@, "Object going out of scope: $@" );
is( $count,6,"Check # of destroys of WithDestroyAll, with threads" );


package Without;
use Thread::Bless;
sub new { bless [] }

package WithDestroy;
use Thread::Bless;
sub new { bless {} }
sub WithDestroy::DESTROY { $count++ }

package WithDestroyAll;
use Thread::Bless destroy => 1;
sub new { bless {} }
sub WithDestroyAll::DESTROY { $count++ }
