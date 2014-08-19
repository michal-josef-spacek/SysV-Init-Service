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
our $VERSION = 0.04;

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
	if ($self->{'service'} =~ m/\.sh$/ms) {
		err "Service with .sh suffix doesn't possible.";
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
	if ($stderr) {
		$stdout .= $stderr;
	}
	my @commands;
	if ($stdout =~ m/{([\w\|\-]+)}/ms) {
		@commands = split m/\|/ms, $1;
	} elsif ($stdout =~ m/([\w\-]+)\s*$/ms) {
		@commands = $1;
	}
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
	return $self->_command('start');
}

# Get status.
sub status {
	my $self = shift;
	return $self->_command('status');
}

# Stop service.
sub stop {
	my $self = shift;
	return $self->_command('stop');
}

# Common command.
sub _service_command {
	my ($self, $command) = @_;
	my ($stdout, $stderr, $success, $exit_code);
	if (any { $_ eq $command } $self->commands) {
		($stdout, $stderr, $success, $exit_code)
			= capture_exec($self->{'_service_path'}.' '.$command);
		if ($stderr) {
			chomp $stderr;
			err "Problem with service '$self->{'service'}' $command.",
				'STDERR', $stderr;
		}
	} else {
		err "Service hasn't $command command.";
	}
	return $exit_code >> 8;
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
         Service with .sh suffix doesn't possible.
         From Class::Utils::set_params():
                 Unknown parameter '%s'.

 start():
         Problem with service '%s' start.
                 STDERR: %s
         Service hasn't start command.

 status():
         Problem with service '%s' status.
                 STDERR: %s
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

0.04

=cut
