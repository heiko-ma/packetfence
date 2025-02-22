package pf::Switch::Nortel::BPS2000;

=head1 NAME

pf::Switch::Nortel::BPS2000 - Object oriented module to access SNMP enabled Nortel BPS2000 switches

=head1 SYNOPSIS

The pf::Switch::Nortel::BPS2000 module implements an object
oriented interface to access SNMP enabled Nortel::BPS2000 switches.

=head1 STATUS

BPS2000 switches don't support LLDP.

Otherwise this module is identical to pf::Switch::Nortel.

=head1 SNMP

This switch can parse SNMP traps and change a VLAN on a switch port using SNMP.

=cut

use strict;
use warnings;
use Net::SNMP;

use base ('pf::Switch::Nortel');

use pf::constants;
use pf::Switch::constants;
use pf::util;

sub description { 'Nortel BPS 2000' }

# special features
# LLDP is not available on BPS2000
use pf::SwitchSupports qw(
    -Lldp
);

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

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
