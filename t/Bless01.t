BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
}

BEGIN {
    if ($ENV{FORKS_FOR_THREADS}) {
        eval {
            require forks; forks->import;
            require forks::shared; forks::shared->import;
        };
    }
} #BEGIN

use Test::More tests => 16;
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
ok (!$@, "Without object going out of scope: $@" );
is( $count,0,"Check # of destroys of WithoutDestroy" );

$count = 0;
eval { NoBless->new };
ok (!$@, "NoBless Object going out of scope: $@" );
is( $count,1,"Check # of destroys of WithDestroy" );

$count = 0;
eval {
    my $object = NoBless->new;
    threads->new( sub {1} )->join foreach 1..5;
};
ok (!$@, "Threads with NoBless object: $@" );
is( $count,6,"Check # of destroys of NoBless, with threads" );

$count = 0;
eval { WithDestroy->new };
ok (!$@, "WithDestroy object going out of scope: $@" );
is( $count,1,"Check # of destroys of WithDestroy" );

$count = 0;
eval {
    my $object = WithDestroy->new;
    threads->new( sub {1} )->join foreach 1..5;
};
ok (!$@, "Threads with WithDestroy object: $@" );
is( $count,1,"Check # of destroys of WithDestroy, with threads" );

$count = 0;
eval { WithDestroyAll->new };
ok (!$@, "WithDestroyAll object going out of scope: $@" );
is( $count,1,"Check # of destroys of WithDestroyAll" );

$count = 0;
eval {
    my $object = WithDestroyAll->new;
    foreach (1..5) {
        threads->new( sub { 1 } )->join;
    }
};
ok (!$@, "Threads with WithDestroyAll object: $@" );
is( $count,6,"Check # of destroys of WithDestroyAll, with threads" );

package Without;
use Thread::Bless;
sub new { bless [] }

package NoBless;
sub new { bless [] }
sub DESTROY { $count++ }

package WithDestroy;
use Thread::Bless;
sub new { bless {} }
sub DESTROY { $count++ }

package WithDestroyAll;
use Thread::Bless destroy => 1;
sub new { bless {} }
sub DESTROY { $count++ }
