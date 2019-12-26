package Perl::Critic::Policy::DataValidator::RequireStrictSequenced;
use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

use List::Util qw( any );
use Perl::Critic::Utils qw(
  $SEVERITY_LOWEST
  parse_arg_list
);
 
use parent 'Perl::Critic::Policy';
 
sub supported_parameters { return () }
sub default_severity     { return $SEVERITY_LOWEST }
sub default_themes       { return qw( cosmetic ) }
sub applies_to           { return 'PPI::Statement::Variable'  }

my $DESCRIPTION = q{You should use 'StrictSequenced', an extensions of Data::Validator.};
my $EXPLAIN     = q{Passing named arguments when a subroutine has only one argument is redundant.};

use DDP +{ deparse => 1, use_prototypes => 0 };
 
sub violates {
  my ( $self, $stmt, $doc ) = @_;

  return unless $stmt->symbols != 1;

  my @tokens = $stmt->schildren;

  # match 'state $v = Data::Validator->new'
  # XXX: このようなチェック、もっといい方法で行えないのか
  if ( $tokens[0]->isa('PPI::Token::Word')
    && $tokens[1]->isa('PPI::Token::Symbol')
    && $tokens[2]->isa('PPI::Token::Operator')
    && $tokens[2]->content eq '='
    && $tokens[3]->isa('PPI::Token::Word')
    && $tokens[3]->content eq 'Data::Validator'
    && $tokens[4]->isa('PPI::Token::Operator')
    && $tokens[4]->content eq '->'
    && $tokens[5]->isa('PPI::Token::Word')
    && $tokens[5]->content eq 'new' )
  {
    my @args_passed_to_new = parse_arg_list($tokens[5]);

    # Args passed to new as named arguments
    if ( @args_passed_to_new % 2 == 0 ) {
      my $params_num = int @args_passed_to_new / 2;

      # match '->with(qw/ /)'
      # TODO: with を別に呼び出している場合
      if ( $tokens[7]->isa('PPI::Token::Operator')
        && $tokens[7]->content eq '->'
        && $tokens[8]->isa('PPI::Token::Word')
        && $tokens[8]->content eq 'with'
        && $tokens[9]->isa('PPI::Structure::List') )
      {
        my @args_passed_to_with  = parse_arg_list($tokens[8]);
        my @extensions_name      = map { $_->literal } map { @$_ } @args_passed_to_with;
        my $has_strict_sequenced = any { $_ eq 'StrictSequenced' } @extensions_name;
        if ( $params_num == 1 && !$has_strict_sequenced ) {
          return $self->violation($DESCRIPTION, $EXPLAIN, $stmt);
        }
        elsif ( $params_num > 1 && $has_strict_sequenced ) {
          return $self->violation($DESCRIPTION, $EXPLAIN, $stmt);
        }
      }
    }
  }
  return;
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

