#!/bin/bash

# [assignment] create your own bash script to compile SystemOfEquations.circom modeling after compile-HelloWorld.sh below

# cd ../contracts/circuits

mkdir SystemOfEquations

rm SystemOfEquations/SystemOfEquations.r1cs
rm SystemOfEquations/SystemOfEquations.sym
rm SystemOfEquations/circuit_0000.zkey
rm SystemOfEquations/SystemOfEquations_js
rm SystemOfEquations/witness.wtns
rm SystemOfEquations/pot12_0000.ptau
rm SystemOfEquations/pot12_0001.ptau
rm SystemOfEquations/pot12_final.ptau

if [ -f ./powersOfTau28_hez_final_16.ptau ]; then
    echo "powersOfTau28_hez_final_16.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_16.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau
fi

echo "Compiling SystemOfEquations.circom..."

circom SystemOfEquations.circom --r1cs --wasm --sym -o SystemOfEquations
node SystemOfEquations/SystemOfEquations_js/generate_witness.js SystemOfEquations/SystemOfEquations_js/SystemOfEquations.wasm SystemOfEquations/input.json SystemOfEquations/witness.wtns
# cp SystemOfEquations/witness.wtns ../witness.wtns

snarkjs r1cs info SystemOfEquations/SystemOfEquations.r1cs

# phase 1 of ceremony
snarkjs powersoftau new bn128 12 SystemOfEquations/pot12_0000.ptau -v
snarkjs powersoftau contribute SystemOfEquations/pot12_0000.ptau SystemOfEquations/pot12_0001.ptau --name="First contribution" -v

# phase 2 of ceremony
snarkjs powersoftau prepare phase2 SystemOfEquations/pot12_0001.ptau SystemOfEquations/pot12_final.ptau -v
snarkjs groth16 setup SystemOfEquations/SystemOfEquations.r1cs powersOfTau28_hez_final_16.ptau SystemOfEquations/circuit_0000.zkey
snarkjs zkey contribute SystemOfEquations/circuit_0000.zkey SystemOfEquations/circuit_final.zkey --name="1st Contribution Name" -v -e="random text"
snarkjs zkey export verificationkey SystemOfEquations/circuit_final.zkey SystemOfEquations/verification_key.json
snarkjs groth16 prove SystemOfEquations/circuit_final.zkey SystemOfEquations/witness.wtns SystemOfEquations/proof.json SystemOfEquations/public.json
snarkjs groth16 verify SystemOfEquations/verification_key.json SystemOfEquations/public.json SystemOfEquations/proof.json



snarkjs zkey export solidityverifier SystemOfEquations/circuit_final.zkey SystemOfEquations/SystemOfEquationsVerifier.sol

cd ../.. 