package SysV::Init::Service;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use English qw(-no_match_vars);
use Error::Pure qw(err);
use File::Spec::Functions qw(catfile);
use IO::CaptureOutput qw(capture_exec);
use List::MoreUtils qw(any);

# Version.
our $VERSION = 0.01;

# Construct.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Service.
	$self->{'service'} = undef;

	# Service directory.
	$self->{'service_dir'} = '/etc/init.d';

	# Process parameters.
	set_params($self, @params);

	# Check for service.
	if (! defined $self->{'service'}) {
		err "Parameter 'service' is required.";
	}
	$self->{'_service_path'} = catfile($self->{'service_dir'},
		$self->{'service'});
	if (! -x $self->{'_service_path'}) {
		err "Service '$self->{'service'}' doesn't present.";
	}

	# Object.
	return $self;
}

# Get service commands.
sub commands {
	my $self = shift;
	my ($stdout, $stderr, $success, $exit_code)
		= capture_exec($self->{'_service_path'});
	# TODO Check.
	my $commands;
	if ($stdout =~ m/{([\w\|\-]+)}/ms) {
		$commands = $1;
	}
	my @commands = split m/\|/ms, $commands;
	return @commands;
}

# Get service name.
sub name {
	my $self = shift;
	return $self->{'service'};
}

# Start service.
sub start {
	my $self = shift;
	my ($stdout, $stderr, $success, $exit_code) = (undef, undef, undef, 1);
	if (any { $_ eq 'start'} $self->commands) {
		($stdout, $stderr, $success, $exit_code)
			= capture_exec($self->{'_service_path'}.' start');
		if ($stderr) {
			chomp $stderr;
			err "Problem with service '$self->{'service'}' start.",
				'STDERR', $stderr;
		}
	} else {
		err "Service hasn't start command.";
	}
	return $exit_code;
}

# Get status.
sub status {
	my $self = shift;
	my ($stdout, $stderr, $success, $exit_code) = (undef, undef, undef, 1);
	if (any { $_ eq 'status'} $self->commands) {
		($stdout, $stderr, $success, $exit_code)
			= capture_exec($self->{'_service_path'}.' status');
	} else {
		err "Service hasn't status command.";
	}
	return $exit_code;
}

# Stop service.
sub stop {
	my $self = shift;
	my ($stdout, $stderr, $success, $exit_code) = (undef, undef, undef, 1);
	if (any { $_ eq 'stop'} $self->commands) {
		($stdout, $stderr, $success, $exit_code)
			= capture_exec($self->{'_service_path'}.' stop');
		if ($stderr) {
			chomp $stderr;
			err "Problem with service '$self->{'service'}' stop.",
				'STDERR', $stderr;
		}
	} else {
		err "Service hasn't stop command.";
	}
	return $exit_code;
}

1;
