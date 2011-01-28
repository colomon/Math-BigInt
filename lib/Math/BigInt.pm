use NativeCall;

sub bdNew() returns OpaquePointer is native("libbd") { ... }
sub bdFreeSol(OpaquePointer $bd) is native("libbd") { ... }
sub bdConvFromDecimal(OpaquePointer $bd, Str $digits) returns Int is native("libbd") { ... }
sub bdAdd(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdSubtract(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdMultiply(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdModulo(OpaquePointer $w, OpaquePointer $u, OpaquePointer $v) returns Int is native("libbd") { ... }
sub bdConvToDecimal(OpaquePointer $bd, OpaquePointer $s, Int $smax) returns Int is native("libbd") { ... }

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
}

our multi sub infix:<+>(Math::BigInt $a, Math::BigInt $b) {
    my $result = Math::BigInt.new("1");
    bdAdd($result.bd, $a.bd, $b.bd);
    $result;
}

our multi sub infix:<->(Math::BigInt $a, Math::BigInt $b) {
    my $result = Math::BigInt.new("1");
    bdSubtract($result.bd, $a.bd, $b.bd);
    $result;
}

our multi sub infix:<*>(Math::BigInt $a, Math::BigInt $b) {
    my $result = Math::BigInt.new("1");
    bdMultiply($result.bd, $a.bd, $b.bd);
    $result;
}


multi MAIN() {
    my $a = Math::BigInt.new("131414212321313141");
    say Math::BigInt.new("131414212321313141") + Math::BigInt.new("1000000000000000000000000000000");
    my @crazy := Math::BigInt.new("1"), -> $x { $x * Math::BigInt.new("2") } ... *;
    say ~@crazy[100];
    my @crazier := Math::BigInt.new("1"), -> $x { $x + Math::BigInt.new("1") } ... *;
    say [*] @crazier[^50];
}

multi MAIN("playing") {
    my $a = bdNew();
    my $b = bdNew();
    my $c = bdNew();
    bdConvFromDecimal($a, "43857389573984758937458347535");
    bdConvFromDecimal($b, "1");
    bdAdd($c, $a, $b);
    # bdConvFromDecimal($b, "10");
    # bdModulo($a, $c, $b);

    my $space = malloc(1000);
    bdConvToDecimal($c, $space, 999);

    say strcat($space, "");

    free($space);

    bdFreeSol($a);
    bdFreeSol($b);
    bdFreeSol($c);
}