package pf::condition::multi_empty;

=head1 NAME

pf::condition::multi_empty -

=head1 DESCRIPTION

pf::condition::multi_empty

=cut

use strict;
use warnings;
use Moose;
extends qw(pf::condition::multi);
use List::MoreUtils qw(true);
use pf::constants qw($TRUE $FALSE);

has condition => (
    is => 'ro',
    required => 1,
    isa => 'pf::condition',
);

=head2 match

matches when there are no matches for condition

=cut

sub match {
    my ($self, $args) = @_;
    if (@$args == 0) {
        return $TRUE;
    }
    my $condition = $self->condition;

    local $_;
    return ((true {my $a = $_; $condition->match($a) } @$args) == 0) ? $TRUE : $FALSE;
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

