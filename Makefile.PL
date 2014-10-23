# Pragmas.
use strict;
use warnings;

# Modules.
use inc::Module::Install;

# Definition.
abstract 'Class for SysV init service manipulation.';
author 'Michal Spacek <skim@cpan.org>';
license 'bsd';
name 'SysV-Init-Service';
readme_from 'Service.pm';
requires 'Class::Utils' => 0.05;
requires 'English' => 0;
requires 'Error::Pure' => 0.15;
requires 'File::Spec::Functions' => 0;
requires 'IO::CaptureOutput' => 0;
requires 'List::MoreUtils' => 0;
requires 'perl' => '5.6.2';
resources 'bugtracker' => 'https://rt.cpan.org/Public/Dist/Display.html'.
	'?Name=SysV-Init-Service';
resources 'homepage' => 'https://github.com/tupinek/SysV-Init-Service';
resources 'repository' => 'git://github.com/tupinek/SysV-Init-Service';
test_requires 'English' => 0;
test_requires 'File::Object' => 0.07;
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
test_requires 'Test::Pod' => 0;
test_requires 'Test::Pod::Coverage' => 0;
tests_recursive;
version '0.04';

# Run.
WriteAll();
