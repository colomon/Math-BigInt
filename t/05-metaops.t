use Math::BigInt;
use Test;

plan *;

{
    my @fib := 1L, 1L, *+* ... *;
    my @fib2 := 1, 1, * L+ * ... *;
        
    is ~@fib[200], ~@fib2[200], "1L, 1L, *+* ... * agrees with 1, 1, * L+ * ... *";
}

{
    my $a = Math::BigInt.new(1);
    for 1..50 {
        $a = $a * $_;
    }
    my $b = 1;
    for 1..50 {
        $b = $b L* $_;
    }

    is ~$b, ~$a, 'L* and * both generate is exactly 50!';
    # skip "Rakudo does not properly find infix:<L*> for [L*]";
    # is ~([L*] 1..50), ~$a, 'and so does [L*] 1..50';
}


done;