use Math::BigInt;
use Test;

plan *;

{
    my $a = Math::BigInt.new("100000000000000000");
    my $b = Math::BigInt.new("1");

    my $c = $a + $b;
    isa_ok $c, Math::BigInt, "100000000000000000 + 1 is a BigInt";
    is $c, "100000000000000001", "and it's 100000000000000001";
}

# adding normal ints and BigInts
{
    my $a = Math::BigInt.new("100000000000000000");
    
    my $b = $a + 1;
    isa_ok $b, Math::BigInt, "100000000000000000 + 1 is a BigInt";
    is $b, "100000000000000001", "and it's 100000000000000001";
    
    $a = 1 + $b;
    isa_ok $a, Math::BigInt, "1 + 100000000000000001 is a BigInt";
    is $a, "100000000000000002", "and it's 100000000000000002";

    todo "+= ignoring new operators", 2;
    $a += 3;
    isa_ok $a, Math::BigInt, "1 + 100000000000000001 is a BigInt";
    is $a, "100000000000000003", "and it's 100000000000000003";
}



done;