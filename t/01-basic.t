use Math::BigInt;
use Test;

plan *;

{
    my $a = Math::BigInt.new("1");
    isa_ok $a, Math::BigInt, "We successfully made a BigInt";
    ok $a ~~ Numeric & Real, "It's Numeric and Real, too";
    is ~$a, "1", "Stringifies properly";
    is +$a, 1, "Numifies properly";
}

{
    my $a = Math::BigInt.new("1234567890098765432100123456789");
    isa_ok $a, Math::BigInt, "We successfully made a BigInt";
    ok $a ~~ Numeric & Real, "It's Numeric and Real, too";
    is ~$a, "1234567890098765432100123456789", "Stringifies properly";
    todo "Rakudo's handling of long ints is very broken";
    is_approx +$a, 1234567890098765432100123456789, "Numifies properly";
}

{
    my $a = Math::BigInt.new("21");
    isa_ok $a, Math::BigInt, "We successfully made a BigInt";
    ok $a ~~ Numeric & Real, "It's Numeric and Real, too";
    is +$a, 21, "Starts with proper value";
    my $b = $a.succ;
    is +$b, 22, ".succ works";
    $a = $b.pred;
    is +$a, 21, ".pred works";
    
    $a++;
    is +$a, 22, "Increment works";
    isa_ok $a, Math::BigInt, "It's still a BigInt";
    $a--;
    is +$a, 21, "Decrement works";
    isa_ok $a, Math::BigInt, "It's still a BigInt";
}

done;