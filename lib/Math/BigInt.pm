use NativeCall;

sub bdNew() returns OpaquePointer is native("libbd") { ... }
# sub bdFreeSol(OpaquePointer $bd) is native("libbd") { ... }
sub bdSetEqual(OpaquePointer $bd1, OpaquePointer $bd2) returns Int is native("libbd") { ... }
sub bdConvFromDecimal(OpaquePointer $bd, Str $digits) returns Int is native("libbd") { ... }
sub bdIncrement(OpaquePointer $w) returns Int is native("libbd") { ... }
sub bdDecrement(OpaquePointer $w) returns Int is native("libbd") { ... }
sub bdAdd(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdSubtract(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdMultiply(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdDivide(OpaquePointer $q, OpaquePointer $r, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdModulo(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdGcd(OpaquePointer $g, OpaquePointer $x, OpaquePointer $y) returns Int is native("libbd") { ... }
sub bdConvToDecimal(OpaquePointer $bd, OpaquePointer $s, Int $smax) returns Int is native("libbd") { ... }
sub bdIsEqual(OpaquePointer $a, OpaquePointer $b) returns Int is native("libbd") { ... }
sub bdCompare(OpaquePointer $a, OpaquePointer $b) returns Int is native("libbd") { ... }
sub bdIsZero(OpaquePointer $a) returns Int is native("libbd") { ... }

sub bdSolMalloc(Int $n) returns OpaquePointer is native("libbd") { ... }
sub bdSolFree(OpaquePointer $p) is native("libbd") { ... }
sub bdSolStrCast(OpaquePointer $s) returns Str is native("libbd") { ... }

class Math::BigInt does Real {
    has $.bd;
    has $.negative;
    
    multi method new(Math::BigInt $other, :$negate) {
        my $bd = bdNew();
        bdSetEqual($bd, $other.bd);
        self.bless(*, :$bd, :negative($negate ?? !$other.negative !! $other.negative));
    }
    
    multi method new(Str $digits) {
        if $digits ~~ /(\-?)(\d+)/ {
            my $bd = bdNew();
            bdConvFromDecimal($bd, $1);
            self.bless(*, :$bd, :negative($0 eq "-"));
        } else {
            fail "Improper format for BigInt";
        }
    }

    multi method new(Int $n) {
        my $bd = bdNew();
        bdConvFromDecimal($bd, ~$n.abs);
        self.bless(*, :$bd, :negative($n < 0));
    }
    
    multi method perl() {
        qq<Math::BigInt.new("{ self.Str }")>;
    }
    
    method Str() {
        my $space = bdSolMalloc(1000);
        my $size = bdConvToDecimal($.bd, $space, 0);
        if $size > 999 {
            bdSolFree($space);
            $space = bdSolMalloc($size + 1);
        }
        bdConvToDecimal($.bd, $space, $size + 1);
        my $result = bdSolStrCast($space);
        bdSolFree($space);
        $.negative ?? "-$result" !! $result;
    }
    
    method Bridge(Math::BigInt $x:) {
        +$x.Str;
    }
    
    method Bool(Math::BigInt $x:) {
        !bdIsZero($x.bd);
    }
    
    method succ(Math::BigInt $x:) { $x + 1; }
    method pred(Math::BigInt $x:) { $x - 1; } 
    
    method gcd(Math::BigInt $b) {
        my $result = Math::BigInt.new("1");
        bdGcd($result.bd, $.bd, $b.bd);
        $result;
    }

    multi sub postfix:<L>(Str $a) is export(:DEFAULT) {
        Math::BigInt.new($a);
    }
    
    multi sub postfix:<L>(Int $a) is export(:DEFAULT) {
        Math::BigInt.new(~$a);
    }
    
    my sub Add(Math::BigInt $a, Math::BigInt $b) {
        my $result;
        if $a.negative == $b.negative {
            $result = Math::BigInt.new($a);
            bdAdd($result.bd, $a.bd, $b.bd);
        } else {
            given bdCompare($a.bd, $b.bd) {
                when 0 {
                    $result = Math::BigInt.new(0);
                }
                when -1 {
                    $result = Math::BigInt.new($b);
                    bdSubtract($result.bd, $b.bd, $a.bd);
                }
                when 1 {
                    $result = Math::BigInt.new($a);
                    bdSubtract($result.bd, $a.bd, $b.bd);
                }
            }
        }
        $result;
    }
    
    multi sub infix:<+>(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        Add($a, $b);
    }

    multi sub infix:<+>(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        Add($a, Math::BigInt.new($b));
    }

    multi sub infix:<+>(Int $a, Math::BigInt $b) is export(:DEFAULT) {
        Add(Math::BigInt.new($a), $b);
    }

    multi sub infix:<->(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        Add($a, Math::BigInt.new($b, :negate));
    }

    multi sub infix:<->(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        Add($a, Math::BigInt.new(-$b));
    }

    multi sub infix:<->(Int $a, Math::BigInt $b) is export(:DEFAULT) {
        Add(Math::BigInt.new($a), Math::BigInt.new($b, :negate));
    }

    multi sub infix:<*>(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdMultiply($result.bd, $a.bd, $b.bd);
        $result;
    }

    multi sub infix:<*>(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdMultiply($result.bd, $a.bd, Math::BigInt.new($b).bd);
        $result;
    }

    multi sub infix:<*>(Int $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdMultiply($result.bd, Math::BigInt.new($a).bd, $b.bd);
        $result;
    }
    
    multi sub infix:<div>(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        my $r = Math::BigInt.new("1");
        bdDivide($result.bd, $r.bd, $a.bd, $b.bd);
        $result;
    }

    multi sub infix:<div>(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        my $r = Math::BigInt.new("1");
        bdDivide($result.bd, $r.bd, $a.bd, Math::BigInt.new($b).bd);
        $result;
    }

    multi sub infix:<%>(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdModulo($result.bd, $a.bd, $b.bd);
        $result;
    }

    multi sub infix:<%>(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdModulo($result.bd, $a.bd, Math::BigInt.new($b).bd);
        $result.Int;
    }

    multi sub infix:<**>(Math::BigInt $a, Math::BigInt $b is copy) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        my $power = $a;
        loop {
            my $r = $b % 2;
            if $r {
                $result = $result * $power;
            }
            $b = ($b - $r) div 2;
            last unless $b;
            $power = $power * $power;
        }
        $result;
    }

    multi sub infix:<**>(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        $a ** Math::BigInt.new($b);
    }
    
    multi sub infix:<gcd>(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdGcd($result.bd, $a.bd, $b.bd);
        $result;
    }

    multi sub infix:<gcd>(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdGcd($result.bd, $a.bd, Math::BigInt.new($b).bd);
        $result;
    }

    multi sub infix:<gcd>(Int $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdGcd($result.bd, Math::BigInt.new($a).bd, $b.bd);
        $result;
    }
    
    # Comparison operators

    multi sub infix:<cmp>(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        $a <=> $b;
    }

    multi sub infix:«<=>»(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        bdCompare($a.bd, $b.bd);
    }

    multi sub infix:«==»(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        ?bdIsEqual($a.bd, $b.bd);
    }

    multi sub infix:«!=»(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        !bdIsEqual($a.bd, $b.bd);
    }

    multi sub infix:«<»(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        ($a <=> $b) == -1;
    }

    multi sub infix:«>»(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        ($a <=> $b) == 1;
    }

    multi sub infix:«<=»(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        ($a <=> $b) != 1;
    }

    multi sub infix:«>=»(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        ($a <=> $b) != -1;
    }
    
    # Bonus operators (to work around a Rakudo bug affecting meta-operators)
    our multi sub infix:<L+>(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdAdd($result.bd, $a.bd, $b.bd);
        $result;
    }

    our multi sub infix:<L+>(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdAdd($result.bd, $a.bd, Math::BigInt.new($b).bd);
        $result;
    }

    our multi sub infix:<L+>(Int $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdAdd($result.bd, Math::BigInt.new($a).bd, $b.bd);
        $result;
    }

    our multi sub infix:<L+>(Int $a, Int $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdAdd($result.bd, Math::BigInt.new($a).bd, Math::BigInt.new($b).bd);
        $result;
    }

    our multi sub infix:<L*>(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdMultiply($result.bd, $a.bd, $b.bd);
        $result;
    }

    our multi sub infix:<L*>(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdMultiply($result.bd, $a.bd, Math::BigInt.new($b).bd);
        $result;
    }

    our multi sub infix:<L*>(Int $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdMultiply($result.bd, Math::BigInt.new($a).bd, $b.bd);
        $result;
    }

    our multi sub infix:<L*>(Int $a, Int $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdMultiply($result.bd, Math::BigInt.new($a).bd, Math::BigInt.new($b).bd);
        $result;
    }
}
