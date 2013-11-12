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
our $VERSION = 0.02;

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
	if ($exit_code > 0) {
		my @err;
		if ($stderr) {
			push @err, 'STDERR', $stderr;
		}
		err "Problem with run service '$self->{'service'}'.", @err;
	}
	my $commands;
	if ($stdout =~ m/{([\w\|\-]+)}/ms) {
		$commands = $1;
	}
	my @commands = split m/\|/ms, $commands;
	return sort @commands;
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

__END__

=pod

=encoding utf8

=head1 NAME

SysV::Init::Service - Class for SysV init service manipulation.

=head1 SYNOPSIS

 use SysV::Init::Service;
 my $obj = SysV::Init::Service->new(%parameters);
 my @commands = $obj->commands;
 my $name = $obj->name;
 my $exit_code = $obj->start;
 my $exit_code = $obj->status;
 my $exit_code = $obj->stop;

=head1 METHODS

=over 8

=item C<new(%parameters)>

Constructor.

=over 8

=item * C<service>

 Service.
 Default value is undef.
 It is required.

=item * C<service_dir>

 Service directory.
 Default value is '/etc/init.d'.

=back

=item C<commands()>

 Get service commands.
 Returns array of possible commands alphabetically sorted.

=item C<name()>

 Get service name.
 Returns string with service name.

=item C<start()>

 Run service start command.
 Returns exit code.

=item C<status()>

 Run service status command and return exit code.
 Returns exit code.

=item C<stop()>

 Run service stop command.
 Returns exit code.

=back

=head1 ERRORS

 new():
         Parameter 'service' is required.
         Service '%s' doesn't present.
         From Class::Utils::set_params():
                 Unknown parameter '%s'.

 commands():
         Problem with run service '%s'.
                 STDERR: %s

 start():
         Problem with service '%s' start.
                 STDERR: %s
         Service hasn't start command.

 status():
         Service hasn't status command.

 stop():
         Problem with service '%s' stop.
                 STDERR: %s
         Service hasn't stop command.

=head1 EXAMPLE

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use File::Spec::Functions qw(catfile);
 use File::Temp qw(tempfile tempdir);
 use IO::Barf qw(barf);
 use SysV::Init::Service;

 # Temporary directory.
 my $temp_dir = tempdir('CLEANUP' => 1);

 # Create fake service.
 my $fake = <<'END';
 #!/bin/sh
 echo "[ ok ] Usage: /fake {start|stop|status}."
 END

 # Save to file.
 my $fake_file = catfile($temp_dir, 'fake');
 barf($fake_file, $fake);

 # Chmod.
 chmod 0755, $fake_file;
 
 # Service object.
 my $obj = SysV::Init::Service->new(
         'service' => 'fake',
         'service_dir' => $temp_dir,
 );

 # Get commands.
 my @commands = $obj->commands;

 # Print commands to output.
 map { print $_."\n"; } @commands;

 # Clean.
 unlink $fake_file;
 
 # Output:
 # start
 # stop
 # status

=head1 DEPENDENCIES

L<Class::Utils>,
L<English>,
L<Error::Pure>,
L<File::Spec::Functions>,
L<IO::CaptureOutput>,
L<List::MoreUtils>.

=head1 SEE ALSO

L<service>.

=head1 REPOSITORY

L<https://github.com/tupinek/SysV-Init-Service>

=head1 AUTHOR

Michal Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

BSD license.

=head1 VERSION

0.02

=cut
