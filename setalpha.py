from io import UnsupportedOperation
import pyffi
import pickle
from pyffi.formats.nif import NifFormat
import sys

argv = sys.argv
try:
    index = argv.index("--") + 1
except ValueError:
    index = len(argv)
argv = argv[index:]

print(argv[0] + ' --> ' + argv[1])

data = NifFormat.Data()
with open(argv[0], 'rb') as nif_stream:
    data.inspect_version_only(nif_stream)
    if data.version >= 0:
        data.read(nif_stream)
    elif data.version == -1:
        raise UnsupportedOperation("Unsupported NIF version")
    else:
        raise UnsupportedOperation("Not a NIF")

alpha_index = len(data.header.block_types)

for child in data.get_global_iterator():
    if isinstance(child, NifFormat.NiTriShape):
        alpha = NifFormat.NiAlphaProperty(parent=child)
        alpha.flags = 4845
        child.bs_properties[-1] = alpha
        data.roots.append(alpha)
        data.blocks.append(alpha)

with open(argv[1], 'wb') as nif_out:
    data.write(nif_out)