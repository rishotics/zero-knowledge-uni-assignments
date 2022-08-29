#!/bin/bash

# [assignment] create your own bash script to compile Multiplier3.circom modeling after compile-HelloWorld.sh below

cd ../contracts/circuits

mkdir Multiplier3

rm Multiplier3/Multiplier3.r1cs
rm Multiplier3/Multiplier3.sym
rm Multiplier3/circuit_0000.zkey
rm Multiplier3/Multiplier3_js
rm Multiplier3/witness.wtns
rm Multiplier3/pot12_0000.ptau
rm Multiplier3/pot12_0001.ptau
rm Multiplier3/pot12_final.ptau

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling Multiplier3.circom..."

circom Multiplier3.circom --r1cs --wasm --sym -o Multiplier3
node Multiplier3/Multiplier3_js/generate_witness.js Multiplier3/Multiplier3_js/Multiplier3.wasm Multiplier3/input.json Multiplier3/witness.wtns
# cp Multiplier3/witness.wtns ../witness.wtns

snarkjs r1cs info Multiplier3/Multiplier3.r1cs

snarkjs powersoftau new bn128 12 Multiplier3/pot12_0000.ptau -v
snarkjs powersoftau contribute Multiplier3/pot12_0000.ptau Multiplier3/pot12_0001.ptau --name="First contribution" -v

snarkjs powersoftau prepare phase2 Multiplier3/pot12_0001.ptau Multiplier3/pot12_final.ptau -v

snarkjs groth16 setup Multiplier3/Multiplier3.r1cs powersOfTau28_hez_final_10.ptau Multiplier3/circuit_0000.zkey
snarkjs zkey contribute Multiplier3/circuit_0000.zkey Multiplier3/circuit_final.zkey --name="1st Contribution Name" -v -e="random text"
snarkjs zkey export verificationkey Multiplier3/circuit_final.zkey Multiplier3/verification_key.json
snarkjs groth16 prove Multiplier3/circuit_final.zkey Multiplier3/witness.wtns Multiplier3/proof.json Multiplier3/public.json
snarkjs groth16 verify Multiplier3/verification_key.json Multiplier3/public.json Multiplier3/proof.json



snarkjs zkey export solidityverifier Multiplier3/circuit_final.zkey Multiplier3/Multiplier3Verifier.sol

cd ../.. 