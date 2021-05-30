import bpy
import os
import itertools
from pathlib import Path

curdir = Path(__file__).parent
print("Current directory: " + str(curdir))
plugin_data_dir = curdir.joinpath("plugin/Data")
print("Plugin directory: " + str(plugin_data_dir))
mesh_src_dir = curdir.joinpath("Source/Meshes")
print("Mesh Source directory: " + str(mesh_src_dir))
mesh_dest_dir = plugin_data_dir.joinpath("Meshes")
print("Mesh Dest directory: " + str(mesh_dest_dir))
blend_paths = itertools.chain(Path(mesh_src_dir).rglob("*_mesh.blend"), Path(mesh_src_dir).rglob("*_collision.blend"))
for blend_path in blend_paths:
    dest_blend_path = mesh_dest_dir.joinpath(blend_path.relative_to(mesh_src_dir))
    nif_parent = dest_blend_path.parent
    nif_path = nif_parent.joinpath(dest_blend_path.stem.replace('_mesh', '') + '.nif')
    print("CONVERTING: " + str(blend_path) + " -> " + str(nif_path))
    try:
        nif_parent.mkdir(parents=True)
    except FileExistsError:
        pass
    bpy.ops.wm.open_mainfile(filepath=str(blend_path))
    bpy.ops.export_scene.nif(filepath=str(nif_path))