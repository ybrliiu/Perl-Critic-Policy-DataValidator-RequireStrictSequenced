package Perl::Critic::Policy::DataValidator::RequireStrictSequenced;
use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

use Perl::Critic::Utils qw{ :severities :classification :ppi };
 
use parent 'Perl::Critic::Policy';
 
sub supported_parameters { return () }
sub default_severity     { return $SEVERITY_HIGHEST }
sub default_themes       { return qw( bugs ) }
sub applies_to           { return 'PPI::Statement::Variable'  }

use DDP +{ deparse => 1, use_prototypes => 0 };
 
sub violates {
    my ($self, $stmt, $doc) = @_;

    $self->is_data_validator($stmt);

    return;
    return $self->violation('Description', 'Explain', $stmt);
}

sub is_data_validator {
    my ($self, $stmt) = @_;

    return unless $stmt->symbols != 1;

    my @tokens = $stmt->schildren;

    # match 'state $v = Data::Validator->new()'
    if ( $tokens[0]->isa('PPI::Token::Word')
        && $tokens[1]->isa('PPI::Token::Symbol')
        && $tokens[2]->isa('PPI::Token::Operator')
        && $tokens[2]->content eq '='
        && $tokens[3]->isa('PPI::Token::Word')
        && $tokens[3]->content eq 'Data::Validator'
        && $tokens[4]->isa('PPI::Token::Operator')
        && $tokens[4]->content eq '->'
        && $tokens[5]->isa('PPI::Token::Word')
        && $tokens[5]->content eq 'new'
        && $tokens[6]->isa('PPI::Structure::List')
    ) {
        # TODO: expression 2つ以上のケースはありますか
        my ($expression) = $tokens[6]->schildren;
        # TODO: カンマが連続している場合はどうするんですかあああ！！！
        # 1つめ PPI::Token::Word || PPI::Token::Quote
        # 2つめ 
        my @list_tokens = $expression->schildren;
        while ( my @tokens = splice @list_tokens, 0, 4 ) {
            if (@tokens == 4) {
                if ( ( $tokens[0]->isa('PPI::Token::Word') || $tokens[0]->isa('PPI::Token::Quote') )
                    && $tokens[1]->isa('PPI::Token::Operator')
                    && ( $tokens[1]->content eq '=>' || $tokens[1]->content eq ',' )
                    && $tokens[2]->isa('PPI::Token::Quote')
                    && ( $tokens[3]->content eq '=>' || $tokens[3]->content eq ',' )
                ) {
                }
            }
        }
        # 引数が1つなら RequireStrictSequenced あるかチェック
        # 引数が2つ以上なら RequireStrictSequenced ないかチェック
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

