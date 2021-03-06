#!/usr/local/perlbrew/perls/perl-5.16.2/bin/perl

# usage: perl bin/daemon_control.pl get_init_file > /path/to/init/script

use strict;
use warnings;

use Daemon::Control;
use File::Path 2.06 ();    # core

my $name = 'metacpan-api';
my $user = 'metacpan';
my $root = '/home/metacpan';
my $home = "$root/api.metacpan.org";
my %dirs = (
    pid => "$home/var/run",
    log => "$home/var/log",
);
my $carton    = '/usr/local/perlbrew/perls/perl-5.16.2/bin/carton';
my $workers   = 10;
my $plack_env = 'production';

# If running in the development vm change the user to avoid permission problems.
if ( -d '/vagrant' ) {
    $user      = 'vagrant';
    $workers   = 3;
    $plack_env = 'development';
}

$ENV{PERL_CARTON_PATH} = "/home/$user/carton/api.metacpan.org";

my @program_args = (
    'exec', '/usr/local/perlbrew/perls/perl-5.16.2/bin/plackup',
    '--port'    => 5000,
    '--workers' => $workers,
    '-E'        => $plack_env,
    '-Ilib',
    '-a'  => 'app.psgi',
    '-s', => 'Starman',
);

File::Path::make_path( values %dirs );

# Notes on unused args
# scan_name: seems to be just 'starman master' (not useful)
# stdout_file: always seems to be just empty

my $args = {
    directory    => $home,
    fork         => 2,
    group        => $user,
    init_config  => "$root/.metacpanrc",
    lsb_desc     => "Starts $name",
    lsb_sdesc    => "Starts $name",
    name         => $name,
    path         => "$home/bin/daemon-control.pl",
    pid_file     => "$dirs{pid}/$name.pid",
    program      => $carton,
    program_args => \@program_args,
    stderr_file  => "$dirs{log}/starman_error.log",
    user         => $user,
};

exit Daemon::Control->new($args)->run;
