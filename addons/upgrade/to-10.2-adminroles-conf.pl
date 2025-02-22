#!/usr/bin/perl

=head1 NAME

to-10.2-adminroles-conf.pl

=cut

=head1 DESCRIPTION

Rename PFMON -> PFCRON

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib /usr/local/pf/lib_perl/lib/perl5);
use pf::IniFiles;
use pf::file_paths qw(
    $admin_roles_config_file
);
use List::MoreUtils qw(any);
use pf::util;
use File::Copy;

run_as_pf();

exit 0 unless -e $admin_roles_config_file;
my $admin_ini = pf::IniFiles->new(-file => $admin_roles_config_file, -allowempty => 1);

my $modified = 0;
for my $section ($admin_ini->Sections()) {
    if (my $actions = $admin_ini->val($section, 'actions')) {
        $actions = [ split(/\s*,\s*/, $actions) ];
        if(any {$_ =~ /^PFMON/} @$actions) {
            print "Renaming pfmon actions in section $section in file $admin_roles_config_file\n";
            $actions = [ map { $_ =~ s/^PFMON/PFCRON/g ? $_ : $_ } @$actions ];
            $admin_ini->setval($section, 'actions', join(',', @$actions));
            $modified |= 1;
        }
    }
}

if ($modified) {
    $admin_ini->RewriteConfig();
    print "All done\n";
} else {
    print "Nothing modified\n";
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


