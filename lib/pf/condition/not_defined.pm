package pf::condition::not_defined;

=head1 NAME

pf::condition::not_defined

=cut

=head1 DESCRIPTION

pf::condition::not_defined

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition);

=head2 match

Match if the argument is not defined

=cut

sub match {
    my ($self,$arg,$args) = @_;
    return !defined($arg);
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
