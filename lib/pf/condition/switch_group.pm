package pf::condition::switch_group;

=head1 NAME

pf::condition::switch_group - check if a iswitch is inside a switch group

=cut

=head1 DESCRIPTION

pf::condition::switch_group

=cut

use strict;
use warnings;
use Moose;
use pf::constants qw($TRUE $FALSE);
extends qw(pf::condition::key);
use Scalar::Util qw(reftype);
use pf::log;

our $logger = get_logger();

=head1 METHODS

=head2 match

match the last ip to see if it is in defined network

=cut

sub match {
    my ($self, $arg, $args) = @_;
    if (!(defined($args))) {
        $args = $arg
    }
    return $FALSE unless defined $arg && reftype ($arg) eq 'HASH';
    my $key = $self->key;
    return $FALSE unless exists $arg->{$key};
    require pf::SwitchFactory;
    my $last_switch = $arg->{$key};
    my $switch = pf::SwitchFactory->instantiate($last_switch);
    return $FALSE if(!defined($switch) || !$switch);
    return $self->condition->match($switch->{_group}, $args);
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
