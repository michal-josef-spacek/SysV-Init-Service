# Pragmas.
use strict;
use warnings;

# Modules.
use English;
use Error::Pure::Utils qw(clean);
use File::Object;
use SysV::Init::Service;
use Test::More 'tests' => 3;
use Test::NoWarnings;

# Service dir.
my $service_dir = File::Object->new->up->dir('services');

# Test.
my $obj = SysV::Init::Service->new(
	'service' => 'service1',
	'service_dir' => $service_dir->s,
);
my $ret = $obj->status;
is($ret, '0', 'Get service status.');

# Test.
$obj = SysV::Init::Service->new(
	'service' => 'service2',
	'service_dir' => $service_dir->s,
);
eval {
	$obj->status;
};
is($EVAL_ERROR, "Service hasn't status command.\n",
	"Service hasn't status command.");
clean();
