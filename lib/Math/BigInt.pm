use NativeCall;

sub bdNew() returns OpaquePointer is native("libbd") { ... }
# sub bdFreeSol(OpaquePointer $bd) is native("libbd") { ... }
sub bdConvFromDecimal(OpaquePointer $bd, Str $digits) returns Int is native("libbd") { ... }
sub bdIncrement(OpaquePointer $w) returns Int is native("libbd") { ... }
sub bdDecrement(OpaquePointer $w) returns Int is native("libbd") { ... }
sub bdAdd(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdSubtract(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdMultiply(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdDivide(OpaquePointer $q, OpaquePointer $r, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdModulo(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdConvToDecimal(OpaquePointer $bd, OpaquePointer $s, Int $smax) returns Int is native("libbd") { ... }
sub bdIsEqual(OpaquePointer $a, OpaquePointer $b) returns Int is native("libbd") { ... }
sub bdCompare(OpaquePointer $a, OpaquePointer $b) returns Int is native("libbd") { ... }

sub malloc(Int $n) returns OpaquePointer is native("libSystem") { ... }
sub free(OpaquePointer $p) is native("libSystem") { ... }
sub strcat(OpaquePointer $s, Str $t) returns Str is native("libSystem") { ... }

class Math::BigInt does Real {
    has $.bd;
    
    multi method new(Str $digits) {
        my $bd = bdNew();
        bdConvFromDecimal($bd, $digits);
        self.bless(*, :$bd)
    }

    multi method new(Int $n) {
        my $bd = bdNew();
        bdConvFromDecimal($bd, ~$n);
        self.bless(*, :$bd)
    }
    
    method Str() {
        my $space = malloc(1000);
        my $size = bdConvToDecimal($.bd, $space, 0);
        if $size > 999 {
            free($space);
            $space = malloc($size + 1);
        }
        bdConvToDecimal($.bd, $space, $size + 1);
        my $result = strcat($space, "");
        free($space);
        $result;
    }
    
    method Bridge() {
        +self.Str;
    }
    
    method succ(Math::BigInt $x:) { bdIncrement($x.bd); self; }
    method pred(Math::BigInt $x:) { bdDecrement($x.bd); self; } 

    multi sub postfix:<¹>(Int $a) is export(:DEFAULT) {
        Math::BigInt.new(~$a);
    }

    multi sub postfix:<¹>(Str $a) is export(:DEFAULT) {
        Math::BigInt.new($a);
    }
    
    multi sub infix:<+>(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdAdd($result.bd, $a.bd, $b.bd);
        $result;
    }

    multi sub infix:<+>(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdAdd($result.bd, $a.bd, Math::BigInt.new($b).bd);
        $result;
    }

    multi sub infix:<+>(Int $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdAdd($result.bd, Math::BigInt.new($a).bd, $b.bd);
        $result;
    }

    multi sub infix:<->(Math::BigInt $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdSubtract($result.bd, $a.bd, $b.bd);
        $result;
    }

    multi sub infix:<->(Math::BigInt $a, Int $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdSubtract($result.bd, $a.bd, Math::BigInt.new($b).bd);
        $result;
    }

    multi sub infix:<->(Int $a, Math::BigInt $b) is export(:DEFAULT) {
        my $result = Math::BigInt.new("1");
        bdSubtract($result.bd, Math::BigInt.new($a).bd, $b.bd);
        $result;
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
}
