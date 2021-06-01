import bpy
import os
import itertools
from pathlib import Path
import sys

argv = sys.argv
try:
    index = argv.index("--") + 1
except ValueError:
    index = len(argv)

argv = argv[index:]

curdir = Path(__file__).parent
blend_path = Path(argv[0])
nif_path = Path(argv[1])
nif_parent = nif_path.parent

print("CONVERTING: " + str(blend_path) + " -> " + str(nif_path))
try:
    nif_parent.mkdir(parents=True)
except FileExistsError:
    pass
bpy.ops.wm.open_mainfile(filepath=str(blend_path))
bpy.ops.export_scene.nif(filepath=str(nif_path))