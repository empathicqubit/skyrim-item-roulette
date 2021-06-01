PATH=/sbin:/bin:/usr/sbin:/usr/bin:/c/ProgramData/chocolatey/bin:$(SystemRoot)/System32/WindowsPowerShell/v1.0

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
			"$^" \
			"-f=$(SKYRIM_BASE)/Data/Source/Scripts/TESV_Papyrus_Flags.flg" \
			"-i=$(SKYRIM_BASE)/Data/Source/Scripts;Source/Scripts" \
			"-o=$@"

textures: $(textureFiles)

plugin/Data/Textures/_EQ_ItemRoulette/%.dds: Source/Textures/_EQ_ItemRoulette/%.xcf
		GIMP=$$(powershell -Command '(Get-Item "$(ProgramW6432)/GIMP*/bin/gimp-console*.exe").FullName')
		"$$GIMP" -n -i --batch-interpreter python-fu-eval -b 'import export_gimp_textures ; export_gimp_textures.main("$<", "$@")'

models: $(modelFiles) textures

build/ChunkMerge/ChunkMerge.exe: build/chunkmerge.7z
		7z x -y "-obuild" "$<"

build/chunkmerge.7z:
		powershell -Command 'Invoke-WebRequest -Uri "https://github.com/downloads/skyfox69/NifUtils/ChunkMerge0155.7z" -OutFile build/chunkmerge.7z'

build/ChunkMerge/ChunkMerge.xml: build/ChunkMerge/ChunkMerge.exe
		cat > "$@" <<'HERE'
		<Config>
			<PathSkyrim>$(SKYRIM_BASE)</PathSkyrim>
			<PathNifXML>$(current_dir)/nif.xml</PathNifXML>
			<PathTemplate>$(current_dir)\\Source\\Meshes\\_EQ_ItemRoulette</PathTemplate>
			<LastTexture></LastTexture>
			<LastTemplate></LastTemplate>
			<DirSource></DirSource>
			<DirDestination></DirDestination>
			<DirCollision></DirCollision>
			<MatHandling>0</MatHandling>
			<VertexColorHandling>0</VertexColorHandling>
			<UpdateTangentSpace>1</UpdateTangentSpace>
			<ReorderProperties>1</ReorderProperties>
			<CollTypeHandling>1</CollTypeHandling>
			<CollMaterial>-553455049</CollMaterial>
			<MaterialScan>
				<MatScanTag>SkyrimHavokMaterial</MatScanTag>
				<MatScanName>SKY_HAV_</MatScanName>
				<MatScanPrefixList>
					<MatScanPrefix>Material</MatScanPrefix>
				</MatScanPrefixList>
				<MatScanIgnoreList>
					<MatScanIgnore>Unknown</MatScanIgnore>
				</MatScanIgnoreList>
			</MaterialScan>
			<DirectXView>
				<ShowTexture>1</ShowTexture>
				<ShowWireframe>0</ShowWireframe>
				<ShowColorWire>0</ShowColorWire>
				<ForceDDS>0</ForceDDS>
				<ColorWireframe>ffffffff</ColorWireframe>
				<ColorWireCollision>ffffff00</ColorWireCollision>
				<ColorBackground>ff200020</ColorBackground>
				<ColorSelected>ffff00ff</ColorSelected>
				<TexturePathList>
				</TexturePathList>
			</DirectXView>
		</Config>
	HERE


plugin/Data/Meshes/_EQ_ItemRoulette/%_final.nif: Source/Meshes/_EQ_ItemRoulette/%_template.nif plugin/Data/Meshes/_EQ_ItemRoulette/%_collision.nif plugin/Data/Meshes/_EQ_ItemRoulette/%_mesh.nif build/ChunkMerge/ChunkMerge.xml
		cp "$(filter %_mesh.nif,$^)" "$@"
		build/ChunkMerge/ChunkMerge.exe &
		powershell -Command '$$env:ChunkMerge_NifFile=Split-Path (Join-Path "$@" "."); $$env:ChunkMerge_CollisionFile=Split-Path (Join-Path "$(filter %_collision.nif,$^)" ".") ; $$env:ChunkMerge_TemplateFile="$(notdir $(filter %_template.nif,$^))" ; Start-Process -Wait -FilePath AutoHotKey -ArgumentList @("ChunkMerge.ahk") ; Stop-Process -Name ChunkMerge'

plugin/Data/Meshes/_EQ_ItemRoulette/%_mesh.nif: Source/Meshes/_EQ_ItemRoulette/%_mesh.blend
		BLENDER=$$(powershell -Command '(Get-Item "$(ProgramW6432)/Blender*/Blender*/blender.exe").FullName')
		"$$BLENDER" --background --python "./export_blender_models.py" -- "$^" "$@"

plugin/Data/Meshes/_EQ_ItemRoulette/%_collision.nif: Source/Meshes/_EQ_ItemRoulette/%_collision.blend
		BLENDER=$$(powershell -Command '(Get-Item "$(ProgramW6432)/Blender*/Blender*/blender.exe").FullName')
		"$$BLENDER" --background --python "./export_blender_models.py" -- "$^" "$@"