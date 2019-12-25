package Perl::Critic::Policy::DataValidator::RequireStrictSequenced;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Readonly;
use Perl::Critic::Utils qw{ :severities :classification :ppi };
 
use base 'Perl::Critic::Policy';
 
# sub supported_parameters { return () }
# sub default_severity     { return $SEVERITY_HIGHEST }
# sub default_themes       { return qw( bugs ) }
# sub applies_to           { return 'PPI::Token::Word'  }
 
sub violates {
    my ($self, undef, $doc) = @_;
}
 
1;

__END__

=encoding utf-8

=head1 NAME

Perl::Critic::Policy::DataValidator::RequireStrictSequenced - It's new $module

=head1 SYNOPSIS

    use Perl::Critic::Policy::DataValidator::RequireStrictSequenced;

=head1 DESCRIPTION

Perl::Critic::Policy::DataValidator::RequireStrictSequenced is ...

=head1 LICENSE

Copyright (C) mp0liiu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

mp0liiu E<lt>raian@reeshome.orgE<gt>

=cut

