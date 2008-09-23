use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	NAME              => 'SMS::Claro',
        DISTNAME          => 'SMS-Claro',
	VERSION_FROM      => 'lib/SMS/Claro.pm', # finds $VERSION
	PREREQ_PM         => {
		'WWW::Mechanize'    => 1.18,
		'Crypt::SSLeay'     => 0.51,
		'Test::Simple'      => 0.44,
	},
	
	($] >= 5.006001 ?     ## Add these new keywords supported since 5.006001
	(ABSTRACT_FROM  => 'lib/SMS/Claro.pm', # retrieve abstract from module
	AUTHOR         => 'Thiago Rondon <thiago@aware.com.br>') : ()),
);
