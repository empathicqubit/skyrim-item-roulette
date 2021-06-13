PATH=/sbin:/bin:/usr/sbin:/usr/bin:/c/ProgramData/chocolatey/bin:$(SystemRoot)/System32:$(SystemRoot)/System32/WindowsPowerShell/v1.0:$(word 1,$(HOME) $(USERPROFILE))/.pyenv/pyenv-win/bin

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(patsubst %/,%,$(dir $(mkfile_path)))

scriptFiles := $(patsubst Source/Scripts/%.psc,plugin/Data/Scripts/%.pex,$(wildcard Source/Scripts/*.psc))
textureFiles := $(patsubst Source/Textures/%.xcf,plugin/Data/Textures/%.dds,$(wildcard Source/Textures/_EQ_ItemRoulette/*.xcf))
modelFiles := $(patsubst Source/Meshes/%_mesh.blend,plugin/Data/Meshes/%_final.nif,$(wildcard Source/Meshes/_EQ_ItemRoulette/*_mesh.blend))

.ONESHELL:

all: zip

clean:
		rm -rf \
			plugin/Data/Meshes \
			plugin/Data/Scripts \
			plugin/Data/Textures && true

distclean: clean
		rm -rf build && true
		mkdir build

zip: build/Item_Roulette_for_VRIK.zip

build/Item_Roulette_for_VRIK.zip: plugin
		rm -rf "$@"
		powershell -Command 'Compress-Archive -Path "plugin/*" -DestinationPath "$@"'

plugin: scripts models

scripts: $(scriptFiles)

plugin/Data/Scripts/%.pex: Source/Scripts/%.psc
		"$(SKYRIM_BASE)/Papyrus Compiler/PapyrusCompiler.exe" \
			"$(current_dir)/$^" \
			"-f=$(SKYRIM_BASE)/Data/Source/Scripts/TESV_Papyrus_Flags.flg" \
			"-i=$(SKYRIM_BASE)/Data/Source/Scripts;$(SKYRIM_BASE)/Data/Scripts/Source;$(current_dir)/Source/Scripts" \
			"-o=$(dir $(current_dir)/$@)"

textures: $(textureFiles)

pipenv: .venv/pyvenv.cfg

plugin/Data/Textures/_EQ_ItemRoulette/%.dds: Source/Textures/_EQ_ItemRoulette/%.xcf export_gimp_textures.py
		GIMP=$$(powershell -Command '(Get-Item "$(ProgramW6432)/GIMP*/bin/gimp-console*.exe").FullName')
		"$$GIMP" -n -i --batch-interpreter python-fu-eval -b 'import export_gimp_textures ; export_gimp_textures.main("$<", "$@")'

.venv/lib/site-packages/pyffi/formats/kfm/kfmxml/kfm.xml:
		mkdir -p "$(dir $@)"
		powershell -Command 'Invoke-WebRequest -Uri "https://raw.githubusercontent.com/niftools/kfmxml/develop/kfm.xml" -OutFile "$@"'

.venv/lib/site-packages/pyffi/formats/nif/nifxml/nif.xml:
		mkdir -p "$(dir $@)"
		powershell -Command 'Invoke-WebRequest -Uri "https://raw.githubusercontent.com/niftools/nifxml/959cb9c3dd59a319e60e819fc8a1402f821f3684/nif.xml" -OutFile "$@"'

.PRECIOUS: .venv/pyvenv.cfg
.venv/pyvenv.cfg: Pipfile .venv/lib/site-packages/pyffi/formats/nif/nifxml/nif.xml .venv/lib/site-packages/pyffi/formats/kfm/kfmxml/kfm.xml
		pyenv install $$(cat ".python-version")
		pyenv exec pip install --user pipenv
		pyenv exec python -m pipenv install
		touch -c "$@"

models: $(modelFiles) textures

plugin/Data/Meshes/_EQ_ItemRoulette/%_final.nif: setalpha.py .venv/pyvenv.cfg plugin/Data/Meshes/_EQ_ItemRoulette/%_mesh.nif Source/Meshes/_EQ_ItemRoulette/%_template.nif
		pyenv exec python -m pipenv run python "$<" -- "$(word 3,$^)" "$@" "$(word 4,$^)"

.PRECIOUS: build/blender-windows64/blender.exe
build/blender-windows64/blender.exe: build/blender.zip build/blender-windows64/2.93/scripts/addons/io_scene_niftools/__init__.py
		7z x -y "-obuild" "$<"
		touch -c "$@"

.PRECIOUS: build/blender-windows64/2.93/scripts/addons/io_scene_niftools/__init__.py
build/blender-windows64/2.93/scripts/addons/io_scene_niftools/__init__.py: build/blender-niftools.zip
		7z x -y "-o$$(dirname "$$(dirname "$@")")" "$<"
		touch -c "$@"

.PRECIOUS: build/blender-niftools.zip
build/blender-niftools.zip:
		powershell -Command 'Invoke-WebRequest -Uri "https://github.com/niftools/blender_niftools_addon/releases/download/v0.0.6/blender_niftools_addon-v0.0.6-2021-04-24-fa4123d.zip" -OutFile "$@"'

.PRECIOUS: build/blender.zip
build/blender.zip:
		powershell -Command 'Invoke-WebRequest -Uri "https://mirror.clarkson.edu/blender/release/Blender2.93/blender-2.93.0-windows-x64.zip" -OutFile "$@"'

.PRECIOUS: plugin/Data/Meshes/_EQ_ItemRoulette/%_mesh.nif
plugin/Data/Meshes/_EQ_ItemRoulette/%_mesh.nif: Source/Meshes/_EQ_ItemRoulette/%_mesh.blend build/blender-windows64/blender.exe
		BLENDER="$(word 2, $^)"
		"$$BLENDER" --background --python "./export_blender_models.py" -- "$<" "$@"