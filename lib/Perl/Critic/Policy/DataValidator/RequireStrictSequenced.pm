package Perl::Critic::Policy::DataValidator::RequireStrictSequenced;
use v5.18;
use warnings;
use utf8;

our $VERSION = '0.01';

use List::Util qw( any );
use Perl::Critic::Utils qw(
  $SEVERITY_LOWEST
  parse_arg_list
  is_class_name
  is_method_call
);
 
use parent 'Perl::Critic::Policy';
 
sub supported_parameters { return () }
sub default_severity     { return $SEVERITY_LOWEST }
sub default_themes       { return qw( maintenance ) }
sub applies_to           { return 'PPI::Statement::Variable'  }

sub violates {
  my ($self, $stmt, $doc) = @_;

  # match 'Data::Validator->'
  my $data_validator = $stmt->find_first(sub {
    my (undef, $child) = @_;
    return is_class_name($child) && $child->content eq 'Data::Validator';
  });
  return unless !!$data_validator;

  # match '->new'
  my $guess_new = $data_validator->snext_sibling->snext_sibling;
  return unless is_method_call($guess_new) && $guess_new->content eq 'new';

  # Args passed to new as named arguments
  my @args_passed_to_new = parse_arg_list($guess_new);
  return if @args_passed_to_new % 2 == 1;

  my $params_num = int @args_passed_to_new / 2;
  return if $params_num == 0;

  # TODO: with を別に呼び出している場合

  # match '->with'
  my $guess_method_call_operator = $guess_new->snext_sibling->snext_sibling;
  return unless defined $guess_method_call_operator;

  my $guess_with = $guess_method_call_operator->snext_sibling;
  return unless is_method_call($guess_with) && $guess_with->content eq 'with';

  my @args_passed_to_with = parse_arg_list($guess_with);
  my @extensions_name     = map { $_->literal } map { @$_ } @args_passed_to_with;
  my $has_strict_sequenced = any { $_ eq 'StrictSequenced' } @extensions_name;

  if ( $params_num == 1 && !$has_strict_sequenced ) {
    return $self->violation(
      q{You should use 'StrictSequenced', an extensions of Data::Validator.},
      q{Passing named arguments when a subroutine has only one argument is redundant.},
      $stmt
    );
  }
  elsif ( $params_num > 1 && $has_strict_sequenced ) {
    return $self->violation(
      q{You should not use 'StrictSequenced', an extensions of Data::Validator.},
      q{Use a named arguments for any subroutine that has more than two parameters.},
      $stmt
    );
  }
  else {
    return;
  }
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

