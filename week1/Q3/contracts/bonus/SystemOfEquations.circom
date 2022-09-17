pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib-matrix/circuits/matElemSum.circom"; 
include "../../node_modules/circomlib-matrix/circuits/matElemMul.circom";
// hint: you can use more than one templates in circomlib-matrix to help you

template SystemOfEquations(n) { // n is the number of variables in the system of equations
    signal input x[n]; // this is the solution to the system of equations
    signal input A[n][n]; // this is the coefficient matrix
    signal input b[n]; // this are the constants in the system of equations
    signal output out; // 1 for correct solution, 0 for incorrect solution

    // [bonus] insert your code here
    component eq[n];
    component o;
    o = matElemSum(1,n);

    component et[n];

    for(var i=0; i<n; i++){
        eq[i] = matElemSum(1,n);
        et[i] = IsEqual();
        for(var j=0; j<n;j++){
            eq[i].a[0][j] <== x[j] * A[i][j];
        }
        et[i].in[0] <== b[i];
        et[i].in[1] <== eq[i].out;
        
        o.a[0][i] <== et[i].out;
    }
    component ie = IsEqual();
    ie.in[0] <== o.out;
    ie.in[1] <== n;
    out <== ie.out;

}

component main {public [A, b]} = SystemOfEquations(3);