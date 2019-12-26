package Perl::Critic::Policy::DataValidator::RequireStrictSequenced;
use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

use List::Util qw( any );
use Perl::Critic::Utils qw{ :severities :classification :ppi };
 
use parent 'Perl::Critic::Policy';
 
sub supported_parameters { return () }
sub default_severity     { return $SEVERITY_HIGHEST }
sub default_themes       { return qw( bugs ) }
sub applies_to           { return 'PPI::Statement::Variable'  }

use DDP +{ deparse => 1, use_prototypes => 0 };

my $DESCRIPTION = 'Please use StrictSequenced';
my $EXPLAIN = 'You forgot StrictSequenced';
 
sub violates {
    my ($self, $stmt, $doc) = @_;

    return unless $stmt->symbols != 1;

    my @tokens = $stmt->schildren;

    # match 'state $v = Data::Validator->new()'
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
        && $tokens[5]->content eq 'new'
        && $tokens[6]->isa('PPI::Structure::List')
    ) {
        # TODO: expression 2つ以上のケースはありますか
        my ($expression) = $tokens[6]->schildren;
        # TODO: カンマが連続している場合はどうするんですかあああ！！！
        my @list_tokens = $expression->schildren;
        # XXX: @list_tokens の中身はチェックしなくて大丈夫ですか
        # 4 = hash key, comma operation, hash value, cooma operation
        if ( @list_tokens % 4 == 0 || @list_tokens % 4 == 3 ) {
            my $args_num = int( (@list_tokens + 3) / 4 );

            # match '->with(qw/ /)'
            # TODO: with を別に呼び出している場合
            if ( $tokens[7]->isa('PPI::Token::Operator')
                && $tokens[7]->content eq '->'
                && $tokens[8]->isa('PPI::Token::Word')
                && $tokens[8]->content eq 'with'
                && $tokens[9]->isa('PPI::Structure::List')
            ) {
                my ($expression) = $tokens[9]->schildren;
                my ($words)      = $expression->schildren;
                my @role_names   = $words->literal;
                my $has_strict_sequenced = any { $_ eq 'StrictSequenced' } @role_names;
                if ($args_num == 1 && !$has_strict_sequenced) {
                    return $self->violation($DESCRIPTION, $EXPLAIN, $stmt);
                }
                elsif ($args_num > 1 && $has_strict_sequenced) {
                    return $self->violation($DESCRIPTION, $EXPLAIN, $stmt);
                }
            }
        }
    }

    return;
    return $self->violation('Description', 'Explain', $stmt);
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

