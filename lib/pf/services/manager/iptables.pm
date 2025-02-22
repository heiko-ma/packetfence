package pf::services::manager::iptables;

=head1 NAME

pf::services::manager::iptables add documentation

=cut

=head1 DESCRIPTION

pf::services::manager::iptables

=cut

use strict;
use warnings;
use Moo;
use pf::file_paths qw($install_dir);
use pf::log;
use pf::util;
use pf::iptables;
use pf::config qw(%Config);

extends 'pf::services::manager';

has '+name' => (default => sub { 'iptables' } );

has '+shouldCheckup' => ( default => sub { 1 }  );

has 'runningServices' => (is => 'rw', default => sub { 0 } );


=head2 start

start iptables

=cut

sub startService {
    my ($self) = @_;
    my $technique;
    unless ($self->isAlive()) {
        $technique = getIptablesTechnique();
        $technique->iptables_save($install_dir . '/var/iptables.bak');
    }
    $technique ||= getIptablesTechnique();
    $technique->iptables_generate();
    return 1;
}

=head2

generateConfig

=cut

sub generateConfig {
    my $technique;
    $technique ||= getIptablesTechnique();
    $technique->iptables_generate();
    return 1;
}

=head2 getIptablesTechnique

getIptablesTechnique

=cut

sub getIptablesTechnique {
    require pf::inline::custom;
    my $iptables = pf::inline::custom->new();
    return $iptables->{_technique};
}

=head2 start

Wrapper around systemctl. systemctl should in turn call the actuall _start.

=cut

sub start {
    my ($self,$quick) = @_;
    system('sudo systemctl start packetfence-iptables');
    return $? == 0;
}

=head2 _start

start the service (called from systemd)

=cut

sub _start {
    my ($self) = @_;
    my $result = 0;
    unless ( $self->isAlive() ) {
        $result = $self->startService();
    }
    return $result;
}

sub startAndCheck {
    my ($self) = @_;

    while(1) {
        $self->_start() unless($self->isAlive());
        sleep 60;
    }
}

=head2 stop

Wrapper around systemctl. systemctl should in turn call the actual _stop.

=cut

sub stop {
    my ($self) = @_;
    system('sudo systemctl stop packetfence-iptables');
    return 1;
}

=head2 _stop

stop iptables (called from systemd)

=cut

sub _stop {
    my ($self) = @_;
    my $logger = get_logger();
    pf_run("sudo iptables -F");
    pf_run("sudo iptables -X");
    pf_run("sudo iptables -t nat -F");
    pf_run("sudo iptables -t nat -X");
    pf_run("sudo iptables -t mangle -F");
    pf_run("sudo iptables -t mangle -X");
    pf_run("sudo iptables -P INPUT ACCEPT");
    pf_run("sudo iptables -P FORWARD ACCEPT");
    pf_run("sudo iptables -P OUTPUT ACCEPT");
    pf_run("sudo iptables -t nat -N DOCKER");
    pf_run("sudo iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER");
    pf_run("sudo iptables -t nat -A OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER");
    pf_run("sudo iptables -t nat -A POSTROUTING -s 100.64.0.0/10 ! -o docker0 -j MASQUERADE");
    pf_run("sudo iptables -t nat -A DOCKER -i docker0 -j RETURN");

    return 1;
}

=head2 isAlive

Check if iptables is alive.
Since it's never really stopped then we check if the fake PID exists

=cut

sub isAlive {
    my ($self) = @_;
    my $logger = get_logger();
    my $result;
    my $pid = $self->pid;
    my $_EXIT_CODE_EXISTS = "0";
    my $rules_applied = pf_run( "sudo iptables -S | grep -- \"-A input-management-if -p tcp -m tcp --dport 1443 -j ACCEPT\"",accepted_exit_status => [$_EXIT_CODE_EXISTS, 1]);
    return ($rules_applied) ? 1 : 0;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>


=head1 COPYRIGHT

Copyright (C) 2005-2022 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

