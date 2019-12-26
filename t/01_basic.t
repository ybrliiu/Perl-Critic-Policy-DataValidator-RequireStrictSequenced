use v5.18;
use warnings;
use utf8;
use Test2::V0;
 
use Perl::Critic;
 
my $critic = Perl::Critic->new(
    '-single-policy' => 'DataValidator::RequireStrictSequenced',
);
my @violations = $critic->critique(\q{
    package Something;
    use v5.18;
    use Data::Validator;
    sub one_args {
        my $v = Data::Validator->new(
            "num" => 'Int',
        )->with(qw/ Method /);
    }
    sub two_args {
        state $v = Data::Validator->new(
            x => 'Int',
            y => 'Int',
        )->with(qw/ Method /);
    }
});
 
done_testing;
