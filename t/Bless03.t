BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
}

use Test::More tests => 10;
use strict;
use warnings;

use threads;
use threads::shared;

use Thread::Bless (
 package => [qw(Without WithDestroy)],
 package => 'WithDestroyAll',
  destroy => 1,
);

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
    threads->new( sub {1} )->join foreach 1..5;
};
ok (!$@, "Object going out of scope: $@" );
is( $count,6,"Check # of destroys of WithDestroyAll, with threads" );


package Without;
sub new { bless [] }

package WithDestroy;
sub new { bless {} }
sub WithDestroy::DESTROY { $count++ }

package WithDestroyAll;
sub new { bless {} }
sub WithDestroyAll::DESTROY { $count++ }
