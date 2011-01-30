use Math::BigInt;
use Test;

plan *;

{
    my $a = Math::BigInt.new(1);
    for 1..50 {
        $a = $a * $_;
    }
    isa_ok $a, Math::BigInt, "50! is a BigInt";
    is $a, "30414093201713378043612608166064768844377641568960512000000000000", 
           "and it's 30414093201713378043612608166064768844377641568960512000000000000";
}

{
    my @fib := 1L, 1L, *+* ... *;
    isa_ok @fib[200], Math::BigInt, "201st Fib is a BigInt";
    is ~@fib[200], "453973694165307953197296969697410619233826", 
                   "201st Fib is 453973694165307953197296969697410619233826";
}

{
    my @powers-of-two := Math::BigInt.new(1), * * 2 ... *;
    isa_ok @powers-of-two[80], Math::BigInt, "2**80 is a BigInt";
    is @powers-of-two[80], "1208925819614629174706176", 
                           "2**80 is 1208925819614629174706176";
}

{
    my @gcd = Math::BigInt.new("51343124325234324234"), Math::BigInt.new("2345298549024520"), * % * ... 0;
    is @gcd[*-2], 2, "The GCD is 2";
}

done;