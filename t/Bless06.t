BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
}

use Test::More tests => 11;
use strict;
use warnings;

use threads;
use threads::shared;

eval <<'EOD';
# package => [qw(Without WithDestroy)],
use Thread::Bless (
 package => [qw(Without WithDestroy)],

 package => 'WithDestroyAll',
  destroy => 1,

 initialize => 1,
);
EOD
ok (!$@, "Evalling Thread::Bless itself: $@" );

my $count : shared;

$count = 0;
eval { Thread::Bless->register( Without->new ) };
ok (!$@, "Object going out of scope: $@" );
is( $count,0,"Check # of destroys of WithoutDestroy" );

$count = 0;
eval { Thread::Bless->register( WithDestroy->new ) };
ok (!$@, "Object going out of scope: $@" );
is( $count,1,"Check # of destroys of WithDestroy" );

$count = 0;
eval {
    my $object = WithDestroy->new;
    Thread::Bless->register( $object );
    threads->new( sub {1} )->join foreach 1..5;
};
ok (!$@, "Object going out of scope: $@" );
is( $count,1,"Check # of destroys of WithDestroy, with threads" );

$count = 0;
eval { Thread::Bless->register( WithDestroyAll->new ) };
ok (!$@, "Object going out of scope: $@" );
is( $count,1,"Check # of destroys of WithDestroyAll" );

$count = 0;
eval {
    my $object = WithDestroyAll->new;
    Thread::Bless->register( $object );
    threads->new( sub {1} )->join foreach 1..5;
};
ok (!$@, "Object going out of scope: $@" );
is( $count,6,"Check # of destroys of WithDestroyAll, with threads" );


package Without;
sub new { bless [] }

package WithDestroy;
sub new { bless {} }
sub DESTROY { $count++ }

package WithDestroyAll;
sub new { bless {} }
sub DESTROY { $count++ }
