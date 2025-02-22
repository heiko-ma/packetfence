package pfappserver::Form::Config::ProfileCommon;

=head1 NAME

pfappserver::Form::Profile::Common add documentation

=cut

=head1 DESCRIPTION

pfappserver::Config::Form::ProfileCommon

=cut

use strict;
use warnings;

use HTML::FormHandler::Moose::Role;
use List::MoreUtils qw(uniq);

use pf::config qw($fqdn);
use pf::authentication;
use pf::ConfigStore::Provisioning;
use pf::ConfigStore::BillingTiers;
use pf::ConfigStore::Scan;
use pf::ConfigStore::SelfService;
use pf::ConfigStore::PortalModule;
use pf::web::constants;
use pf::constants::Connection::Profile;
use pf::constants::role qw( $POOL_USERNAMEHASH $POOL_RANDOM $POOL_ROUND_ROBBIN $POOL_PER_USER_VLAN);
use pfappserver::Form::Field::Duration;
use pfappserver::Base::Form;
use pf::config qw(%Profiles_Config);
with 'pfappserver::Base::Form::Role::Help';

=head1 BLOCKS

=head2 definition

The main definition block

=cut

has_block 'definition' =>
  (
    render_list => [qw(id description root_module preregistration autoregister reuse_dot1x_credentials dot1x_recompute_role_from_portal mac_auth_recompute_role_from_portal dot1x_unset_on_unmatch dpsk unbound_dpsk default_psk_key unreg_on_acct_stop vlan_pool_technique)],
  );

=head2 captive_portal

The captival portal block

=cut

has_block 'captive_portal' =>
  (
    render_list => [qw(logo redirecturl always_use_redirecturl block_interval sms_pin_retry_limit sms_request_limit login_attempt_limit access_registration_when_registered network_logoff network_logoff_popup)],
  );

=head1 Fields

=head2 id

Id of the profile

=cut

has_field 'id' =>
  (
   type => 'Text',
   label => 'Profile Name',
   required => 1,
   apply => [ pfappserver::Base::Form::id_validator('profile name') ],
   tags => { after_element => \&help,
             option_pattern => \&pfappserver::Base::Form::id_pattern,
             help => 'A profile id can only contain alphanumeric characters, dashes, period and or underscores.' },
  );

=head2 description

Description of the profile

=cut

has_field 'description' =>
  (
   type => 'Text',
   label => 'Profile Description',
  );

=head2 logo

The logo field

=cut

has_field 'logo' =>
  (
   type => 'Text',
   label => 'Logo',
  );

=head2 root_module

The root module of the portal

=cut

has_field 'root_module' =>
  (
   type => 'Select',
   multiple => 0,
   required => 1,
   label => 'Root Portal Module',
   options_method => \&options_root_module,
   element_class => ['chzn-select'],
   default => "default_policy",
#   element_attr => {'data-placeholder' => 'Click to add a required field'},
   tags => { after_element => \&help,
             help => 'The Root Portal Module to use' },
  );

=head2 locale

Accepted languages for the profile

=cut

has_field 'locale' =>
(
    'type' => 'DynamicTable',
    'label' => 'Locales',
    'sortable' => 1,
    'do_label' => 0,
);

has_field 'locale.contains' =>
(
    type => 'Select',
    options_method => \&options_locale,
    widget_wrapper => 'DynamicTableRow',
);

=head2 redirecturl

Redirection URL

=cut

has_field 'redirecturl' =>
  (
   type => 'Text',
   label => 'Redirection URL',
   tags => { after_element => \&help,
             help => 'Default URL to redirect to on registration/mitigation release. This is only used if a per security event redirect URL is not defined.' },
  );

=head2 always_use_redirecturl

Controls whether or not we always use the redirection URL

=cut

has_field 'always_use_redirecturl' =>
  (
   type => 'Toggle',
   label => 'Force redirection URL',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
   tags => { after_element => \&help,
             help => 'Under most circumstances we can redirect the user to the URL he originally intended to visit. However, you may prefer to force the captive portal to redirect the user to the redirection URL.' },
  );

=head2 preregistration

Controls whether or not this connection profile is used for preregistration

=cut

has_field 'preregistration' =>
  (
   type => 'Toggle',
   label => 'Activate preregistration',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
   tags => { after_element => \&help,
             help => 'This activates preregistration on the connection profile. Meaning, instead of applying the access to the currently connected device, it displays a local account that is created while registering. Note that activating this disables the on-site registration on this connection profile. Also, make sure the sources on the connection profile have "Create local account" enabled.' },
  );


=head2 autoregister

Controls whether or not this connection profile will autoregister users

=cut

has_field 'autoregister' =>
  (
   type => 'Toggle',
   label => 'Automatically register devices',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
   tags => { after_element => \&help,
             help => 'This activates automatic registation of devices for the profile. Devices will not be shown a captive portal and RADIUS authentication credentials will be used to register the device. This option only makes sense in the context of an 802.1x authentication.' },
  );

=head2 unbound_dpsk

Controls whether or not this connection profile to enabled Dynamic Unbound PSK

=cut

has_field 'unbound_dpsk' =>
  (
   type => 'Toggle',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
   default => 'disabled',
  );

=head2 dpsk

Controls whether or not this connection profile to enabled Dynamic PSK

=cut

has_field 'dpsk' =>
  (
   type => 'Toggle',
   label => 'Enable DPSK',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
   default => 'disabled',
   tags => { after_element => \&help,
             help => 'This enables the Dynamic PSK feature on this connection profile. It means that the RADIUS server will answer requests with specific attributes like the PSK key to use to connect on the SSID.'},
  );

=head2 default_psk_key

Define the default PSK key to connect on this connection profile

=cut

has_field 'default_psk_key' =>
  (
   type => 'Text',
   label => 'Default PSK key',
   minlength => 8,
   tags => { after_element => \&help,
             help => 'This is the default PSK key when you enable DPSK on this connection profile. The minimum length is eight characters.' },
  );

=head2 unreg_on_acct_stop

Controls whether or not this connection profile will unregister a devices on accounting stop

=cut

has_field 'unreg_on_acct_stop' =>
  (
   type => 'Toggle',
   label => 'Automatically deregister devices on accounting stop',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
   default => 'disabled',
   tags => { after_element => \&help,
             help => 'This activates automatic deregistation of devices for the profile if PacketFence receives a RADIUS accounting stop.' },
  );

=head2 sources

Collection Authentication Sources for the profile

=cut

has_field 'sources' =>
  (
    'type' => 'DynamicTable',
    'sortable' => 1,
    'do_label' => 0,
  );

=head2 sources.contains

The definition for Authentication Sources field

=cut

has_field 'sources.contains' =>
  (
    type => 'Select',
    options_method => \&options_sources,
    widget_wrapper => 'DynamicTableRow',
  );


=head2 billing_tiers

Collection Billing tiers for the profile

=cut

has_field 'billing_tiers' =>
  (
    'type' => 'DynamicTable',
    'sortable' => 1,
    'do_label' => 0,
  );

=head2 billing_tiers.contains

The definition for Billing tiers field

=cut

has_field 'billing_tiers.contains' =>
  (
    type => 'Select',
    options_method => \&options_billing_tiers,
    widget_wrapper => 'DynamicTableRow',
);

=head2 provisioners

Collectiosn Authentication Sources for the profile

=cut

has_field 'provisioners' =>
  (
    'type' => 'DynamicTable',
    'sortable' => 1,
    'do_label' => 0,
  );

=head2 provisioners.contains

The definition for Authentication Sources field

=cut

has_field 'provisioners.contains' =>
  (
    type => 'Select',
    options_method => \&options_provisioners,
    widget_wrapper => 'DynamicTableRow',
  );

=head2 reuse_dot1x_credentials

=cut

has_field 'reuse_dot1x_credentials' =>
  (
    type => 'Checkbox',
    checkbox_value => 'enabled',
    unchecked_value => 'disabled',
    tags => {
        after_element   =>    \&help,
        help            => 'This option emulates SSO when someone needs to face the captive portal after a successful 802.1x connection. 802.1x credentials are reused on the portal to match an authentication and get the appropriate actions. As a security precaution, this option will only reuse 802.1x credentials if there is an authentication source matching the provided realm. This means, if users use 802.1x credentials with a domain part (username@domain, domain\username), the domain part needs to be configured as a realm under the RADIUS section and an authentication source needs to be configured for that realm. If users do not use 802.1x credentials with a domain part, only the NULL realm will be match IF an authentication source is configured for it.'
    },
  );

=head2 dot1x_recompute_role_from_portal

=cut

has_field 'dot1x_recompute_role_from_portal' =>
  (
    type => 'Checkbox',
    checkbox_value => 'enabled',
    unchecked_value => 'disabled',
    default => 'enabled',
    tags => { after_element => \&help,
             help => 'When enabled, PacketFence will not use the role initialy computed on the portal but will use the dot1x username to recompute the role.' },
  );

=head2 mac_auth_recompute_role_from_portal

=cut

has_field 'mac_auth_recompute_role_from_portal' =>
  (
    type => 'Checkbox',
    checkbox_value => 'enabled',
    unchecked_value => 'disabled',
    default => 'disabled',
    tags => { after_element => \&help,
             help => 'When enabled, PacketFence will not use the role initialy computed on the portal but will use an authorized source if defined to recompute the role.' },
  );
  
=head2 dot1x_unset_on_unmatch

=cut

has_field 'dot1x_unset_on_unmatch' =>
  (
    type => 'Checkbox',
    checkbox_value => 'enabled',
    unchecked_value => 'disabled',
    default => 'disabled',
    tags => { after_element => \&help,
             help => 'When enabled, PacketFence will unset the role of the device if no authentication sources returned one.' },
  );

=head2 show_manage_devices_on_max_nodes

=cut

has_field 'show_manage_devices_on_max_nodes' =>
  (
    type => 'Checkbox',
    checkbox_value => 'enabled',
    unchecked_value => 'disabled',
    default => 'disabled',
  );

=head2 block_interval

The amount of time a user is blocked after reaching the defined limit for login, sms request and sms pin retry

=cut

has_field 'block_interval' =>
  (
    type => 'Duration',
    label => 'Block Interval',
    #Use the inflate method from pfappserver::Form::Field::Duration
    validate_when_empty => 1,
    default_method => sub {
        pfappserver::Form::Field::Duration->duration_inflate($pf::constants::Connection::Profile::BLOCK_INTERVAL_DEFAULT_VALUE)
    },
    tags => { after_element => \&help,
             help => 'The amount of time a user is blocked after reaching the defined limit for login, sms request and sms pin retry.' },
  );

=head2 sms_pin_retry_limit

The amount of times a pin can try use a pin

=cut

has_field 'sms_pin_retry_limit' =>
  (
    type => 'PosInteger',
    label => 'SMS Pin Retry Limit',
    default => 0,
    tags => { after_element => \&help,
             help => 'Maximum number of times a user can retry a SMS PIN before having to request another PIN. A value of 0 disables the limit.' },

  );

=head2 login_attempt_limit

The amount of login attempts allowed per mac

=cut

has_field 'login_attempt_limit' =>
  (
    type => 'PosInteger',
    label => 'Login Attempt Limit',
    default => 0,
    tags => { after_element => \&help,
             help => 'Limit the number of login attempts. A value of 0 disables the limit.' },
  );

=head2 sms_request_limit

The amount of sms request allowed per mac

=cut

has_field 'sms_request_limit' =>
  (
    type => 'PosInteger',
    label => 'SMS Request Retry Limit',
    default => 0,
    tags => { after_element => \&help,
             help => 'Maximum number of times a user can request a SMS PIN. A value of 0 disables the limit.' },

  );

=head2 scan

Collection Scan engines for the profile

=cut

has_field 'scans' =>
  (
    'type' => 'DynamicTable',
    'sortable' => 1,
    'do_label' => 0,
  );

=head2 scan.contains

The definition for Scan Sources field

=cut

has_field 'scans.contains' =>
  (
    type => 'Select',
    options_method => \&options_scan,
    widget_wrapper => 'DynamicTableRow',
  );

=head2 self_service

The definition for Device registration Sources field

=cut

has_field 'self_service' =>
  (
    type => 'Select',
    options_method => \&options_self_service,
  );


=head2 network_logoff

Controls whether or not this connection profile allows access to /networklogoff to terminate network access

=cut

has_field 'network_logoff' =>
  (
   type => 'Toggle',
   label => 'Network Logoff',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
   tags => { after_element => \&help,
             help => "This allows users to access the network logoff page (http://$fqdn/networklogoff) in order to terminate their network access (switch their device back to unregistered)" },
  );

=head2 network_logoff_popup

Controls whether or not this connection profile will automatically open the network logoff page in a popup at the end of the registration

=cut

has_field 'network_logoff_popup' =>
  (
   type => 'Toggle',
   label => 'Network Logoff Popup',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
   tags => { after_element => \&help,
             help => 'When the "Network Logoff" feature is enabled, this will have it opened in a popup at the end of the registration process.' },
  );

=head2 preregistration

Controls whether or not this connection profile is used for preregistration

=cut

has_field 'access_registration_when_registered' =>
  (
   type => 'Toggle',
   label => 'Allow access to registration portal when registered',
   checkbox_value => 'enabled',
   unchecked_value => 'disabled',
   tags => { after_element => \&help,
             help => 'This allows already registered users to be able to re-register their device by first accessing the status page and then accessing the portal. This is useful to allow users to extend their access even though they are already registered.' },
  );

=head2 vlan_pool

Control the vlan pool technique you want to use

=cut

has_field 'vlan_pool_technique' =>
  (
   type => 'Select',
   multiple => 0,
   required => 0,
   label => 'Vlan Pool Technique',
   options_method => \&options_vlan_pool,
   element_class => ['chzn-select'],
   default_method => \&field_default_value,
   tags => { after_element => \&help,
             help => 'The Vlan Pool Technique to use' },
  );

=head1 METHODS

=head2 options_locale

=cut

sub options_locale {
    return map { { value => $_, label => $_ } } @WEB::LOCALES;
}

=head2 options_sources

Returns the list of sources to be displayed

=cut

sub options_sources {
    return map { { value => $_->id, label => $_->id, attributes => { 'data-source-class' => $_->class  } } } grep { !$_->isa("pf::Authentication::Source::AdminProxySource") } @{getAllAuthenticationSources()};
}

=head2 options_billing_tiers

Returns the list of sources to be displayed

=cut

sub options_billing_tiers {
    return  map { { value => $_, label => $_ } } @{pf::ConfigStore::BillingTiers->new->readAllIds};
}

=head2 options_provisioners

Returns the list of sources to be displayed

=cut

sub options_provisioners {
    return  map { { value => $_, label => $_ } } @{pf::ConfigStore::Provisioning->new->readAllIds};
}

=head2 options_scan

Returns the list of scan to be displayed

=cut

sub options_scan {
    return  map { { value => $_, label => $_ } } @{pf::ConfigStore::Scan->new->readAllIds};
}

=head2 options_self_service

Returns the list of self_service profile to be displayed

=cut

sub options_self_service {
    return  map { { value => $_, label => $_ } } '',@{pf::ConfigStore::SelfService->new->readAllIds};
}


=head2 options_root_module

Returns the list of root modules to be displayed

=cut

sub options_root_module {
    my $cs = pf::ConfigStore::PortalModule->new;
    return map { ($_->{type} eq "Root" || $_->{type} eq 'RootSSO')  ? { value => $_->{id}, label => $_->{description} } : () } @{$cs->readAll("id")};
}

=head2 options_vlan_pool

Returns the list of the vlan pool technique

=cut

sub options_vlan_pool {

    return map{ { value => $_, label => $_ } } ( $POOL_ROUND_ROBBIN, $POOL_RANDOM, $POOL_USERNAMEHASH, $POOL_PER_USER_VLAN );
}


=head2 validate

Remove duplicates and make sure only one external authentication source is selected for each type.

=cut

sub validate {
    my $self = shift;

    my @uniq_locales = uniq @{$self->value->{'locale'}};
    $self->field('locale')->value(\@uniq_locales);

    my @uniq_sources = uniq @{$self->value->{'sources'}};
    my %sources = map { $_ => 1 } @uniq_sources;
    $self->field('sources')->value(\@uniq_sources);

    my %external;
    foreach my $source_id (@uniq_sources) {
        my $source = pf::authentication::getAuthenticationSource($source_id);
        next unless $source;
        my $class = $source->class;
        my $type = $source->type;
        if ($class eq 'exclusive' && @uniq_sources > 1) {
            $self->field('sources')->add_error("Only one authentication source of type '$type' can be selected.");
        }
        next if $class ne 'external';
        $external{$type}++;
        if ($external{$type} > 1) {
            $self->field('sources')->add_error('Only one authentication source of each external type can be selected.');
            last;
        }
    }
}

=head2 field_default_value

field_default_value

=cut

sub field_default_value {
    my ($f) = @_;
    return $Profiles_Config{default}{$f->name};
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

