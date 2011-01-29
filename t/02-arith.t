use Math::BigInt;
use Test;

plan *;

# adding BigInts and BigInts
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

# subtracting BigInts and BigInts
{
    my $a = Math::BigInt.new("100000000000000000");
    my $b = Math::BigInt.new("1");

    my $c = $a - $b;
    isa_ok $c, Math::BigInt, "100000000000000000 - 1 is a BigInt";
    is $c, "99999999999999999", "and it's 99999999999999999";

    $c = $b - $a;
    isa_ok $c, Math::BigInt, "1 - 100000000000000000 is a BigInt";
    todo "BigDigits can't handle negative numbers?";
    is $c, "-99999999999999999", "and it's -99999999999999999";
}

# subtracting normal ints and BigInts
{
    my $a = Math::BigInt.new("100000000000000000");
    
    my $b = $a - 1;
    isa_ok $b, Math::BigInt, "100000000000000000 - 1 is a BigInt";
    is $b, "99999999999999999", "and it's 99999999999999999";
    
    $a = 1 - $b;
    isa_ok $a, Math::BigInt, "1 - 99999999999999999 is a BigInt";
    todo "BigDigits can't handle negative numbers?";
    is $a, "-99999999999999998", "and it's -99999999999999998";

    todo "-= ignoring new operators", 2;
    $a -= 3;
    isa_ok $a, Math::BigInt, "-99999999999999998 - 3 is a BigInt";
    is $a, "-100000000000000001", "and it's -100000000000000001";
}

# multiplying BigInts and BigInts
{
    my $a = Math::BigInt.new("100000000000000000");
    my $b = Math::BigInt.new("2");

    my $c = $a * $b;
    isa_ok $c, Math::BigInt, "100000000000000000 * 2 is a BigInt";
    is $c, "200000000000000000", "and it's 200000000000000000";
}

# multiplying normal ints and BigInts
{
    my $a = Math::BigInt.new("100000000000000000");
    
    my $b = $a * 2;
    isa_ok $b, Math::BigInt, "100000000000000000 * 2 is a BigInt";
    is $b, "200000000000000000", "and it's 200000000000000000";
    
    $a = 2 * $b;
    isa_ok $a, Math::BigInt, "2 * 200000000000000000 is a BigInt";
    is $a, "400000000000000000", "and it's 400000000000000000";

    todo "*= ignoring new operators", 2;
    $a *= 2;
    isa_ok $a, Math::BigInt, "400000000000000000 * 2 is a BigInt";
    is $a, "800000000000000000", "and it's 800000000000000000";
}

# div BigInts and BigInts
{
    my $a = Math::BigInt.new("43452454234524532423");
    my $b = Math::BigInt.new("2");

    my $c = ($a * $b) div $b;
    isa_ok $c, Math::BigInt, "43452454234524532423 * 2 div 2 is a BigInt";
    is $c, "43452454234524532423", "and it's 43452454234524532423";
    
    $c = ($a * $b) div 2;
    isa_ok $c, Math::BigInt, "43452454234524532423 * 2 div 2 is a BigInt";
    is $c, "43452454234524532423", "and it's 43452454234524532423";
}

# modulo BigInts and BigInts
{
    my $a = Math::BigInt.new("43452454234524532423");
    my $b = Math::BigInt.new("2");

    my $c = $a % $b;
    isa_ok $c, Math::BigInt, "43452454234524532423 % 2 is a BigInt";
    is $c, "1", "and it's 1";
    
    $c = $a % 2;
    isa_ok $c, Int, "43452454234524532423 % 2 is an Int";
    is $c, 1, "and it's 1";
}





done;