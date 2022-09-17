pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";

template RangeProof(n) {
    assert(n <= 252);
    signal input in; // this is the number to be proved inside the range
    signal input range[2]; // the two elements should be the range, i.e. [lower bound, upper bound]
    signal output out;

    component lt = LessEqThan(n);
    component gt = GreaterEqThan(n);

    // [assignment] insert your code here
    in ==> lt.in[0];
    range[0] ==> lt.in[1];

    in ==> gt.in[0];
    range[1] ==> gt.in[1];

    out <== lt.out * gt.out;
}

