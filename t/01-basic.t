use Math::BigInt;
use Test;

plan *;

{
    my $a = Math::BigInt.new("1");
    isa_ok $a, Math::BigInt, "We successfully made a BigInt";
    ok $a ~~ Numeric & Real, "It's Numeric and Real, too";
}

done;
