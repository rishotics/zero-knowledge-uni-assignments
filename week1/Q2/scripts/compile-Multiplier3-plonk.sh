#!/bin/bash

# [assignment] create your own bash script to compile Multiplier3.circom modeling after compile-HelloWorld.sh below

cd ../contracts/circuits

mkdir Multiplier3_plonk

rm Multiplier3_plonk/Multiplier3.r1cs
rm Multiplier3_plonk/Multiplier3.sym
rm Multiplier3_plonk/circuit_0000.zkey
rm Multiplier3_plonk/Multiplier3_js
rm Multiplier3_plonk/witness.wtns
rm Multiplier3_plonk/pot12_0000.ptau
rm Multiplier3_plonk/pot12_0001.ptau
rm Multiplier3_plonk/pot12_final.ptau

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling Multiplier3.circom..."

circom Multiplier3.circom --r1cs --wasm --sym -o Multiplier3_plonk
# using input.json of groth16
node Multiplier3_plonk/Multiplier3_js/generate_witness.js Multiplier3_plonk/Multiplier3_js/Multiplier3.wasm Multiplier3/input.json Multiplier3_plonk/witness.wtns
# cp Multiplier3_plonk/witness.wtns ./witness.wtns

# snarkjs r1cs info Multiplier3_plonk/Multiplier3.r1cs

# # phase 1 of ceremony
snarkjs powersoftau new bn128 12 Multiplier3_plonk/pot12_0000.ptau -v
snarkjs powersoftau contribute Multiplier3_plonk/pot12_0000.ptau Multiplier3_plonk/pot12_0001.ptau --name="First contribution" -v

# # phase 2 of ceremony
snarkjs powersoftau prepare phase2 Multiplier3_plonk/pot12_0001.ptau Multiplier3_plonk/pot12_final.ptau -v
snarkjs plonk setup Multiplier3_plonk/Multiplier3.r1cs powersOfTau28_hez_final_10.ptau Multiplier3_plonk/circuit_final.zkey

snarkjs zkey export verificationkey Multiplier3_plonk/circuit_final.zkey Multiplier3_plonk/verification_key.json
snarkjs plonk prove Multiplier3_plonk/circuit_final.zkey Multiplier3_plonk/witness.wtns Multiplier3_plonk/proof.json Multiplier3_plonk/public.json
snarkjs plonk verify Multiplier3_plonk/verification_key.json Multiplier3_plonk/public.json Multiplier3_plonk/proof.json



# snarkjs zkey export solidityverifier Multiplier3_plonk/circuit_final.zkey Multiplier3_plonk/Multiplier3Verifier.sol

cd ../.. 
# [assignment] create your own bash script to compile Multiplier3.circom using PLONK below