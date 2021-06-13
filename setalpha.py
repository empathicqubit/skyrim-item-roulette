from io import UnsupportedOperation
import pyffi
import pickle
from pyffi.formats.nif import NifFormat
import sys

def validate_nif(mesh_data, nif_stream):
    mesh_data.inspect_version_only(nif_stream)
    if mesh_data.version >= 0:
        mesh_data.read(nif_stream)
    elif mesh_data.version == -1:
        raise UnsupportedOperation("Unsupported NIF version")
    else:
        raise UnsupportedOperation("Not a NIF")

argv = sys.argv
try:
    index = argv.index("--") + 1
except ValueError:
    index = len(argv)
argv = argv[index:]

print(argv[0] + ' --> ' + argv[1] + ' TEMPLATE: ' + argv[2])

mesh_data = NifFormat.Data()
with open(argv[0], 'rb') as mesh_file:
    validate_nif(mesh_data, mesh_file)

alpha_index = len(mesh_data.header.block_types)

for child in mesh_data.get_global_iterator():
    # Replace the generic collision data with data from the template,
    # but preserve the collision vertices
    if isinstance(child, NifFormat.bhkCollisionObject):
        template_data = NifFormat.Data()
        with open(argv[2], 'rb') as template_file:
            validate_nif(template_data, template_file)

        new_collision = template_data.roots[0].collision_object
        new_collision.body.shape = child.body.shape

        child.target.collision_object = new_collision
    # Fix the alpha value
    if isinstance(child, NifFormat.NiTriShape):
        alpha = NifFormat.NiAlphaProperty(parent=child)
        alpha.flags = 4845
        child.bs_properties[-1] = alpha
        mesh_data.blocks.append(alpha)

with open(argv[1], 'wb') as nif_out:
    mesh_data.write(nif_out)