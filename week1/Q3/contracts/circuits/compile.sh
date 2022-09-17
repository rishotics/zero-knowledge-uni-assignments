#!/bin/bash

# [assignment] create your own bash script to compile sudokuModified.circom modeling after compile-HelloWorld.sh below

# cd ../contracts/circuits

mkdir sudokuModified

rm sudokuModified/sudokuModified.r1cs
rm sudokuModified/sudokuModified.sym
rm sudokuModified/circuit_0000.zkey
rm sudokuModified/sudokuModified_js
rm sudokuModified/witness.wtns
rm sudokuModified/pot12_0000.ptau
rm sudokuModified/pot12_0001.ptau
rm sudokuModified/pot12_final.ptau

if [ -f ./powersOfTau28_hez_final_16.ptau ]; then
    echo "powersOfTau28_hez_final_16.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_16.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau
fi

echo "Compiling sudokuModified.circom..."

circom sudokuModified.circom --r1cs --wasm --sym -o sudokuModified
node sudokuModified/sudokuModified_js/generate_witness.js sudokuModified/sudokuModified_js/sudokuModified.wasm sudokuModified/input.json sudokuModified/witness.wtns
# cp sudokuModified/witness.wtns ../witness.wtns

snarkjs r1cs info sudokuModified/sudokuModified.r1cs

# phase 1 of ceremony
snarkjs powersoftau new bn128 12 sudokuModified/pot12_0000.ptau -v
snarkjs powersoftau contribute sudokuModified/pot12_0000.ptau sudokuModified/pot12_0001.ptau --name="First contribution" -v

# phase 2 of ceremony
snarkjs powersoftau prepare phase2 sudokuModified/pot12_0001.ptau sudokuModified/pot12_final.ptau -v
snarkjs groth16 setup sudokuModified/sudokuModified.r1cs powersOfTau28_hez_final_16.ptau sudokuModified/circuit_0000.zkey
snarkjs zkey contribute sudokuModified/circuit_0000.zkey sudokuModified/circuit_final.zkey --name="1st Contribution Name" -v -e="random text"
snarkjs zkey export verificationkey sudokuModified/circuit_final.zkey sudokuModified/verification_key.json
snarkjs groth16 prove sudokuModified/circuit_final.zkey sudokuModified/witness.wtns sudokuModified/proof.json sudokuModified/public.json
snarkjs groth16 verify sudokuModified/verification_key.json sudokuModified/public.json sudokuModified/proof.json



snarkjs zkey export solidityverifier sudokuModified/circuit_final.zkey sudokuModified/sudokuModifiedVerifier.sol

cd ../.. 