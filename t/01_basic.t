use v5.18;
use warnings;
use utf8;
use Test2::V0;
use Perl::Critic;

my $critic = Perl::Critic->new(
    '-single-policy' => 'DataValidator::RequireStrictSequenced',
);

my @violations = $critic->critique(\q{
    sub one_args {
        my $v = Data::Validator->new(
            "num" => 'Int',
        )->with(qw/ Method StrictSequenced /);
    }
});
is @violations, 0;

@violations = $critic->critique(\q{
    sub two_args {
        state $v = Data::Validator->new(
            x => 'Int',
            y => 'Int',
        )->with(qw/ Method /);
    }
});
is @violations, 0;

@violations = $critic->critique(\q{
    sub one_args {
        my $v = Data::Validator->new(
            "num" => 'Int',
        )->with(qw/ Method /);
    }
});
is @violations, 1;

@violations = $critic->critique(\q{
    sub two_args {
        state $v = Data::Validator->new(
            x => 'Int',
            y => 'Int',
        )->with(qw/ Method StrictSequenced /);
    }
});
is @violations, 1;
 
done_testing;
