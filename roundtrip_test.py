#!/usr/bin/env python3

# quick check that rdkit is installed and working
# upon success, the installed rdkit version is printed out
# upon failure, an assert will fail or some other error will
# be printed out

import rdkit
from rdkit import Chem

in_smi = 'c1ccncc1'
mol = Chem.MolFromSmiles(in_smi)
out_smi = Chem.MolToSmiles(mol)
assert(in_smi == out_smi)
print(rdkit.__version__)
