require 5.008;
use threads (); # just to force breakage if threads are not available
use ExtUtils::MakeMaker;

WriteMakefile (
 NAME		=> "Thread::Bless",
 AUTHOR		=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
 ABSTRACT	=> 'make blessed objects thread-aware',
 VERSION_FROM	=> 'lib/Thread/Bless.pm',
 PREREQ_PM	=> {
		    'Scalar::Util'	=> '1.08', # need refaddr()
                   },
);
