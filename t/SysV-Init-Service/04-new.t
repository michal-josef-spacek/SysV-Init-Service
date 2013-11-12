# Pragmas.
use strict;
use warnings;

# Modules.
use English qw(-no_match_vars);
use Error::Pure::Utils qw(clean);
use File::Object;
use SysV::Init::Service;
use Test::More 'tests' => 5;
use Test::NoWarnings;

# Service dir.
my $service_dir = File::Object->new->up->dir('services');

# Test.
eval {
	SysV::Init::Service->new('');
};
is($EVAL_ERROR, "Unknown parameter ''.\n", 'Bad \'\' parameter.');
clean();

# Test.
eval {
	SysV::Init::Service->new(
		'something' => 'value',
	);
};
is($EVAL_ERROR, "Unknown parameter 'something'.\n",
	'Bad \'something\' parameter.');
clean();

# Test.
eval {
	SysV::Init::Service->new;
};
is($EVAL_ERROR, "Parameter 'service' is required.\n",
	"Parameter 'service' is required.");
clean();

# Test.
my $obj = SysV::Init::Service->new(
	'service' => 'service',
	'service_dir' => $service_dir->s,
);
isa_ok($obj, 'SysV::Init::Service');
