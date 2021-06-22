Scriptname _EQ_ItemRoulette_FormChunks extends Form

Activator Property FormChunks Auto

Form[] Property Children Auto
String Property ChunkName Auto

String Property StartName Auto
String Property EndName Auto

String[] ChildNames
Bool ChildNamesInitialized

String[] Function GetChildNames()
	if !ChildNamesInitialized
		String[] names = new String[127]
		Int i = 0
		ChildNamesInitialized = True
		
		While(i < Children.Length)
			If Children[i] != None
				names[i] = GetSortName(Children[i].GetName())
			Else
				names[i] = ""
			EndIf
			i += 1
		EndWhile

		ChildNames = names
	EndIf

	return ChildNames
EndFunction

Bool Function StartsWith(String haystack, String needle)
	return StringUtil.Find(haystack, needle, 0) == 0
EndFunction

String Function GetSortName(String name)
	If StartsWith(name, "A ")
		name = StringUtil.Substring(name, 2, StringUtil.GetLength(name) - 2)
	ElseIf StartsWith(name, "The ")
		name = StringUtil.Substring(name, 4, StringUtil.GetLength(name) - 4)
	EndIf

	return name
EndFunction

Function AddToNested(ObjectReference placer, _EQ_ItemRoulette_FormChunks root, Int[] indices, Form item)
	Int index = indices[0]
	Int subIndex = indices[1]
	If subIndex == 0
		_EQ_ItemRoulette_FormChunks newChunk = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
		newChunk.Children = new Form[127]
		root.Children[index] = newChunk
	EndIf
	_EQ_ItemRoulette_FormChunks subChunk = (root.Children[index] as _EQ_ItemRoulette_FormChunks)
	subChunk.Children[subIndex] = item
	subIndex += 1
	If subIndex >= subChunk.Children.Length
		subIndex = 0
		index += 1
	EndIf

	indices[0] = index
	indices[1] = subIndex
EndFunction

_EQ_ItemRoulette_FormChunks Function GroupByType(ObjectReference placer)
	_EQ_ItemRoulette_FormChunks top = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	top.Children = new Form[5]

	_EQ_ItemRoulette_FormChunks wearables = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	wearables.Children = new Form[2]
	wearables.ChunkName = "Wearables"
	top.Children[0] = wearables

	_EQ_ItemRoulette_FormChunks weapons = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	weapons.ChunkName = "Weapons"
	weapons.Children = new Form[127]
	wearables.Children[0] = weapons
	Int[] weaponsIndices = new Int[2]
	weaponsIndices[0] = 0
	weaponsIndices[1] = 0

	_EQ_ItemRoulette_FormChunks apparel = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	apparel.ChunkName = "Apparel"
	apparel.Children = new Form[127]
	wearables.Children[1] = apparel
	Int[] apparelIndices = new Int[2]
	apparelIndices[0] = 0
	apparelIndices[1] = 0

	_EQ_ItemRoulette_FormChunks magic = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	magic.Children = new Form[2]
	magic.ChunkName = "Magic"
	top.Children[1] = magic

	_EQ_ItemRoulette_FormChunks potions = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	potions.ChunkName = "Potions"
	potions.Children = new Form[127]
	magic.Children[0] = potions
	Int[] potionsIndices = new Int[2]
	potionsIndices[0] = 0
	potionsIndices[1] = 0

	_EQ_ItemRoulette_FormChunks scrolls = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	scrolls.ChunkName = "Scrolls"
	scrolls.Children = new Form[127]
	magic.Children[1] = scrolls
	Int[] scrollsIndices = new Int[2]
	scrollsIndices[0] = 0
	scrollsIndices[1] = 0

	_EQ_ItemRoulette_FormChunks edibles = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	edibles.Children = new Form[2]
	edibles.ChunkName = "Edibles"
	top.Children[2] = edibles

	_EQ_ItemRoulette_FormChunks food = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	food.ChunkName = "Food"
	food.Children = new Form[127]
	edibles.Children[0] = food
	Int[] foodIndices = new Int[2]
	foodIndices[0] = 0
	foodIndices[1] = 0

	_EQ_ItemRoulette_FormChunks ingredients = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	ingredients.ChunkName = "Ingredients"
	ingredients.Children = new Form[127]
	edibles.Children[1] = ingredients
	Int[] ingredientsIndices = new Int[2]
	ingredientsIndices[0] = 0
	ingredientsIndices[1] = 0

	_EQ_ItemRoulette_FormChunks plot = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	plot.Children = new Form[2]
	plot.ChunkName = "Plot"
	top.Children[3] = plot

	_EQ_ItemRoulette_FormChunks books = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	books.ChunkName = "Books"
	books.Children = new Form[127]
	plot.Children[0] = books
	Int[] booksIndices = new Int[2]
	booksIndices[0] = 0
	booksIndices[1] = 0

	_EQ_ItemRoulette_FormChunks keys = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	keys.ChunkName = "Keys"
	keys.Children = new Form[127]
	plot.Children[1] = keys
	Int[] keysIndices = new Int[2]
	keysIndices[0] = 0
	keysIndices[1] = 0

	_EQ_ItemRoulette_FormChunks misc = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	misc.ChunkName = "Misc"
	misc.Children = new Form[127]
	top.Children[4] = misc
	Int[] miscIndices = new Int[2]
	miscIndices[0] = 0
	miscIndices[1] = 0

	_EQ_ItemRoulette_FormChunks subChunk
	Form child
	Form currentItem
	Int subChunkIndex = 0
	Int itemIndex = 0
	Weapon weap
	Potion pot
	Scroll scr
	Book bk
	Ingredient ig
	Key k
	Outfit ou
	Armor ar
	MiscObject ms
	Ammo am
	While subChunkIndex < Children.Length
		child = Children[subChunkIndex]
		subChunk = (child as _EQ_ItemRoulette_FormChunks)
		If subChunk != None
			While itemIndex < subChunk.Children.Length
				currentItem = subChunk.Children[itemIndex]
				weap = (currentItem as Weapon)
				pot = (currentItem as Potion)
				scr = (currentItem as Scroll)
				bk = (currentItem as Book)
				ig = (currentItem as Ingredient)
				k = (currentItem as Key)
				ou = (currentItem as Outfit)
				ar = (currentItem as Armor)
				ms = (currentItem as MiscObject)
				am = (currentItem as Ammo)
				If weap != None || am != None
					AddToNested(placer, weapons, weaponsIndices, currentItem)
				ElseIf pot != None
					If pot.IsFood()
						AddToNested(placer, food, foodIndices, currentItem)
					Else
						AddToNested(placer, potions, potionsIndices, currentItem)
					EndIf
				ElseIf scr != None
					AddToNested(placer, scrolls, scrollsIndices, currentItem)
				ElseIf bk != None
					AddToNested(placer, books, booksIndices, currentItem)
				ElseIf ig != None
					AddToNested(placer, ingredients, ingredientsIndices, currentItem)
				ElseIf k != None
					AddToNested(placer, keys, keysIndices, currentItem)
				ElseIf ou != None || ar != None
					AddToNested(placer, apparel, apparelIndices, currentItem)
				ElseIf ms != None
					AddToNested(placer, misc, miscIndices, currentItem)
				EndIf
				itemIndex += 1
			EndWhile
		EndIf
		subChunkIndex += 1
		itemIndex = 0
	EndWhile

	weapons.ResizeChildArray(weaponsIndices[0] + 1)
	if weaponsIndices[1] > 0
		(weapons.Children[weaponsIndices[0]] as _EQ_ItemRoulette_FormChunks).ResizeChildArray(weaponsIndices[1])
	EndIf
	weapons.SortByNameRecursive()
	weapons.Children = weapons.GroupByName(placer)

	food.ResizeChildArray(foodIndices[0] + 1)
	if foodIndices[1] > 0
		(food.Children[foodIndices[0]] as _EQ_ItemRoulette_FormChunks).ResizeChildArray(foodIndices[1])
	EndIf
	food.SortByNameRecursive()
	food.Children = food.GroupByName(placer)

	potions.ResizeChildArray(potionsIndices[0] + 1)
	if potionsIndices[1] > 0
		(potions.Children[potionsIndices[0]] as _EQ_ItemRoulette_FormChunks).ResizeChildArray(potionsIndices[1])
	EndIf
	potions.SortByNameRecursive()
	potions.Children = potions.GroupByName(placer)

	scrolls.ResizeChildArray(scrollsIndices[0] + 1)
	if scrollsIndices[1] > 0
		(scrolls.Children[scrollsIndices[0]] as _EQ_ItemRoulette_FormChunks).ResizeChildArray(scrollsIndices[1])
	EndIf
	scrolls.SortByNameRecursive()
	scrolls.Children = scrolls.GroupByName(placer)

	books.ResizeChildArray(booksIndices[0] + 1)
	if booksIndices[1] > 0
		(books.Children[booksIndices[0]] as _EQ_ItemRoulette_FormChunks).ResizeChildArray(booksIndices[1])
	EndIf
	books.SortByNameRecursive()
	books.Children = books.GroupByName(placer)

	ingredients.ResizeChildArray(ingredientsIndices[0] + 1)
	if ingredientsIndices[1] > 0
		(ingredients.Children[ingredientsIndices[0]] as _EQ_ItemRoulette_FormChunks).ResizeChildArray(ingredientsIndices[1])
	EndIf
	ingredients.SortByNameRecursive()
	ingredients.Children = ingredients.GroupByName(placer)

	keys.ResizeChildArray(keysIndices[0] + 1)
	if keysIndices[1] > 0
		(keys.Children[keysIndices[0]] as _EQ_ItemRoulette_FormChunks).ResizeChildArray(keysIndices[1])
	EndIf
	keys.SortByNameRecursive()
	keys.Children = keys.GroupByName(placer)

	apparel.ResizeChildArray(apparelIndices[0] + 1)
	if apparelIndices[1] > 0
		(apparel.Children[apparelIndices[0]] as _EQ_ItemRoulette_FormChunks).ResizeChildArray(apparelIndices[1])
	EndIf
	apparel.SortByNameRecursive()
	apparel.Children = apparel.GroupByName(placer)

	misc.ResizeChildArray(miscIndices[0] + 1)
	if miscIndices[1] > 0
		(misc.Children[miscIndices[0]] as _EQ_ItemRoulette_FormChunks).ResizeChildArray(miscIndices[1])
	EndIf
	misc.SortByNameRecursive()
	misc.Children = misc.GroupByName(placer)

	Return top
EndFunction

Function SortByName()
	; based on "Optimized QuickSort - C Implementation" by darel rex finley (http://alienryderflex.com/quicksort/)		
	Int[] Beg = new Int[127]
	Int[] End = new Int[127]
	Int i
	Int L
	Int R
	Int swap
	Form piv
	String pivName
	String[] Names = GetChildNames()

	Beg[0] = 0
	End[0] = Children.Length
	
	i = 0
	While (i >= 0)
		L = Beg[i]
		R = End[i] - 1;
		If (L < R)
			piv = Children[L]
			pivName = Names[L]
			While (L < R)
				While ((Names[R] == "" || Names[R] >= pivName) && (L < R))
					R -= 1
				EndWhile
				If (L < R)					
					Names[L] = Names[R]
					Children[L] = Children[R]					
					L += 1
				EndIf
				While ((pivName == "" || Names[L] <= pivName) && (L < R))
					L += 1
				EndWhile
				If (L < R)					
					Names[R] = Names[L]
					Children[R] = Children[L]
					R -= 1
				EndIf
			EndWhile
			Children[L] = piv
			Names[L] = pivName
			Beg[i + 1] = L + 1
			End[i + 1] = End[i]			
			End[i] = L
			i += 1
			If (End[i] - Beg[i] > End[i - 1] - Beg[i - 1])
				swap = Beg[i]
				Beg[i] = Beg[i - 1]
				Beg[i - 1] = swap
				swap = End[i]
				End[i] = End[i - 1]
				End[i - 1] = swap
			EndIf
		Else
			i -= 1
		EndIf
	EndWhile

	ChildNamesInitialized = False
EndFunction

Function SortByNameRecursive()
	Int childIndex = 0
	Bool ImSorted = False
	Form child
	While childIndex < Children.Length
		child = Children[childIndex]
		_EQ_ItemRoulette_FormChunks subChunk = (child as _EQ_ItemRoulette_FormChunks)
		If(subChunk != None)
			subChunk.SortByNameRecursive()
		ElseIf !ImSorted && child != None
			SortByName()
			ImSorted = True
		EndIf
		childIndex += 1
	EndWhile
EndFunction

Function IndentTrace(String line, Int indentLevel = 0)
	Int i = 0
	String indent = ""
	While i < indentLevel
		indent += "    "
		i += 1
	EndWhile
	Debug.Trace(indent + line)
EndFunction

Function PrintNamesRecursive(Int level = 0)
	Int childIndex = 0
	While childIndex < Children.Length
		Form child = Children[childIndex]
		_EQ_ItemRoulette_FormChunks subChunk = (child as _EQ_ItemRoulette_FormChunks)
		If(subChunk != None)
			IndentTrace("Chunk " + subChunk.ChunkName, level)
			subChunk.PrintNamesRecursive(level + 1)
		ElseIf child != None
			IndentTrace(child.GetName(), level)
		EndIf
		childIndex += 1
	EndWhile
EndFunction

String Function Disambiguate(String source, String prev, String next)
	Int i = 0
	Int sourceLength = StringUtil.GetLength(source)
	Int nextLength = StringUtil.GetLength(next)
	Bool finished = False
	String substr
	if prev != ""
		Int prevLength = StringUtil.GetLength(prev)
		While !finished && i < sourceLength && i < prevLength
			If StringUtil.GetNthChar(source, i) != StringUtil.GetNthChar(prev, i)
				finished = True
			Else
				i += 1
			EndIf
		EndWhile
	EndIf
	While i < sourceLength && i < nextLength
		If StringUtil.GetNthChar(source, i) != StringUtil.GetNthChar(next, i)
			return StringUtil.Substring(source, 0, i + 1)
		EndIf
		i += 1
	EndWhile

	return StringUtil.Substring(source, 0, sourceLength)
EndFunction

Function NameNewChunk(_EQ_ItemRoulette_FormChunks prevChunk, _EQ_ItemRoulette_FormChunks newChunk)
	String prevChunkEndName = ""
	if prevChunk != None
		prevChunkEndName = prevChunk.EndName
	EndIf
	newChunk.ChunkName = Disambiguate(newChunk.StartName, prevChunkEndName, newChunk.EndName)
EndFunction

Function NamePreviousChunk(_EQ_ItemRoulette_FormChunks prevChunk, _EQ_ItemRoulette_FormChunks newChunk)
	String newChunkStartName = ""
	If prevChunk != None
		If newChunk != None
			newChunkStartName = newChunk.StartName
		EndIf
		prevChunk.ChunkName += "-" + Disambiguate(prevChunk.EndName, prevChunk.StartName, newChunkStartName)
	EndIf
EndFunction

Int Function FindMinIndex(Int[] indices, String[] names)
	Form currentItem
	Int minIndex = -1
	Int index
	String min
	String currentName
	Int i = 0
	_EQ_ItemRoulette_FormChunks oldChunk
	While i < Children.Length
		oldChunk = (Children[i] as _EQ_ItemRoulette_FormChunks)
		If oldChunk != None
			index = indices[i]
			If index < oldChunk.Children.Length
				currentItem = oldChunk.Children[index]
				If currentItem != None
					currentName = names[i]
					If minIndex == -1 || currentName < min
						min = currentName
						minIndex = i
					EndIf
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile

	return minIndex
EndFunction

Form[] Function GroupByName(ObjectReference placer)
	Int MAX_ITEMS = 5
	Form[] groupChunks = new Form[127]

	Int[] indices = new Int[127]
	Int i = 0
	While i < indices.Length
		indices[i] = 0
		i += 1
	EndWhile

	Form currentItem
	_EQ_ItemRoulette_FormChunks oldChunk
	String[] names = new String[127]
	i = 0
	While i < Children.Length
		oldChunk = (Children[i] as _EQ_ItemRoulette_FormChunks)
		If oldChunk != None
			names[i] = oldChunk.GetChildNames()[indices[i]]
		EndIf
		i += 1
	EndWhile

	Int chunkItemIndex = MAX_ITEMS
	Int chunkIndex = -1
	Bool finishedScanningIndices = False
	Int index
	Int minIndex
	_EQ_ItemRoulette_FormChunks newChunk
	_EQ_ItemRoulette_FormChunks prevChunk

	While !finishedScanningIndices
		finishedScanningIndices = True
		minIndex = FindMinIndex(indices, names)
		If minIndex > -1
			finishedScanningIndices = False
			If chunkItemIndex >= MAX_ITEMS
				chunkItemIndex = 0
				chunkIndex += 1
				prevChunk = newChunk
				newChunk = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
				newChunk.Children = new Form[5]
				groupChunks[chunkIndex] = newChunk
			EndIf

			index = indices[minIndex]
			currentItem = (Children[minIndex] as _EQ_ItemRoulette_FormChunks).Children[index]
			newChunk.Children[chunkItemIndex] = currentItem
			If chunkItemIndex == 0
				newChunk.StartName = names[minIndex]
				NamePreviousChunk(prevChunk, newChunk)
			ElseIf chunkItemIndex == newChunk.Children.Length - 1
				newChunk.EndName = names[minIndex]
				NameNewChunk(prevChunk, newChunk)
			EndIf
			indices[minIndex] = index + 1

			names[minIndex] = ""
			oldChunk = (Children[minIndex] as _EQ_ItemRoulette_FormChunks)
			If oldChunk != None
				If index + 1 < oldChunk.Children.Length
					names[minIndex] = oldChunk.GetChildNames()[index + 1]
				EndIf
			EndIf
			chunkItemIndex += 1
		EndIf
	EndWhile
	NameNewChunk(prevChunk, newChunk)

	Form[] currentChunks = groupChunks
	Int currentChunkIndex
	Int currentChunksLength = chunkIndex
	If chunkItemIndex == 0
		currentChunksLength = chunkIndex - 1
	EndIf
	Form[] newChunks
	newChunk = None
	prevChunk = None

	While currentChunksLength > MAX_ITEMS
		chunkIndex = 0
		chunkItemIndex = 0
		currentChunkIndex = 0
		newChunks = new Form[127]
		While currentChunkIndex < currentChunksLength
			prevChunk = newChunk
			newChunk = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
			newChunk.Children = new Form[5]
			chunkItemIndex = 0
			While currentChunkIndex < currentChunksLength && chunkItemIndex < newChunk.Children.Length
				oldChunk = currentChunks[currentChunkIndex] as _EQ_ItemRoulette_FormChunks
				newChunk.Children[chunkItemIndex] = currentChunks[currentChunkIndex]
				If chunkItemIndex == 0
					newChunk.StartName = oldChunk.StartName
					NamePreviousChunk(prevChunk, newChunk)
				EndIf
				chunkItemIndex += 1
				currentChunkIndex += 1
			EndWhile
			newChunks[chunkIndex] = newChunk
			newChunk.EndName = oldChunk.EndName
			NameNewChunk(prevChunk, newChunk)
			chunkIndex += 1
		EndWhile
		currentChunks = newChunks
		currentChunksLength = chunkIndex
	EndWhile
	NamePreviousChunk(newChunk, None)

	Return currentChunks
EndFunction

Function ResizeChildArray(Int count)
	Children = ResizeArray(Children, count)
EndFunction

Form[] Function ResizeArray(Form[] oldArray, Int count)
	Form[] newArray = NewFormArray(count)
	Int i = 0
	While i < count
		newArray[i] = oldArray[i]
		i += 1
	EndWhile

	Return newArray
EndFunction

Form[] Function NewFormArray(Int count)
	If count == 0
		Return None
	ElseIf count == 1
		Return new Form[1]
	ElseIf count == 2
		Return new Form[2]
	ElseIf count == 3
		Return new Form[3]
	ElseIf count == 4
		Return new Form[4]
	ElseIf count == 5
		Return new Form[5]
	ElseIf count == 6
		Return new Form[6]
	ElseIf count == 7
		Return new Form[7]
	ElseIf count == 8
		Return new Form[8]
	ElseIf count == 9
		Return new Form[9]
	ElseIf count == 10
		Return new Form[10]
	ElseIf count == 11
		Return new Form[11]
	ElseIf count == 12
		Return new Form[12]
	ElseIf count == 13
		Return new Form[13]
	ElseIf count == 14
		Return new Form[14]
	ElseIf count == 15
		Return new Form[15]
	ElseIf count == 16
		Return new Form[16]
	ElseIf count == 17
		Return new Form[17]
	ElseIf count == 18
		Return new Form[18]
	ElseIf count == 19
		Return new Form[19]
	ElseIf count == 20
		Return new Form[20]
	ElseIf count == 21
		Return new Form[21]
	ElseIf count == 22
		Return new Form[22]
	ElseIf count == 23
		Return new Form[23]
	ElseIf count == 24
		Return new Form[24]
	ElseIf count == 25
		Return new Form[25]
	ElseIf count == 26
		Return new Form[26]
	ElseIf count == 27
		Return new Form[27]
	ElseIf count == 28
		Return new Form[28]
	ElseIf count == 29
		Return new Form[29]
	ElseIf count == 30
		Return new Form[30]
	ElseIf count == 31
		Return new Form[31]
	ElseIf count == 32
		Return new Form[32]
	ElseIf count == 33
		Return new Form[33]
	ElseIf count == 34
		Return new Form[34]
	ElseIf count == 35
		Return new Form[35]
	ElseIf count == 36
		Return new Form[36]
	ElseIf count == 37
		Return new Form[37]
	ElseIf count == 38
		Return new Form[38]
	ElseIf count == 39
		Return new Form[39]
	ElseIf count == 40
		Return new Form[40]
	ElseIf count == 41
		Return new Form[41]
	ElseIf count == 42
		Return new Form[42]
	ElseIf count == 43
		Return new Form[43]
	ElseIf count == 44
		Return new Form[44]
	ElseIf count == 45
		Return new Form[45]
	ElseIf count == 46
		Return new Form[46]
	ElseIf count == 47
		Return new Form[47]
	ElseIf count == 48
		Return new Form[48]
	ElseIf count == 49
		Return new Form[49]
	ElseIf count == 50
		Return new Form[50]
	ElseIf count == 51
		Return new Form[51]
	ElseIf count == 52
		Return new Form[52]
	ElseIf count == 53
		Return new Form[53]
	ElseIf count == 54
		Return new Form[54]
	ElseIf count == 55
		Return new Form[55]
	ElseIf count == 56
		Return new Form[56]
	ElseIf count == 57
		Return new Form[57]
	ElseIf count == 58
		Return new Form[58]
	ElseIf count == 59
		Return new Form[59]
	ElseIf count == 60
		Return new Form[60]
	ElseIf count == 61
		Return new Form[61]
	ElseIf count == 62
		Return new Form[62]
	ElseIf count == 63
		Return new Form[63]
	ElseIf count == 64
		Return new Form[64]
	ElseIf count == 65
		Return new Form[65]
	ElseIf count == 66
		Return new Form[66]
	ElseIf count == 67
		Return new Form[67]
	ElseIf count == 68
		Return new Form[68]
	ElseIf count == 69
		Return new Form[69]
	ElseIf count == 70
		Return new Form[70]
	ElseIf count == 71
		Return new Form[71]
	ElseIf count == 72
		Return new Form[72]
	ElseIf count == 73
		Return new Form[73]
	ElseIf count == 74
		Return new Form[74]
	ElseIf count == 75
		Return new Form[75]
	ElseIf count == 76
		Return new Form[76]
	ElseIf count == 77
		Return new Form[77]
	ElseIf count == 78
		Return new Form[78]
	ElseIf count == 79
		Return new Form[79]
	ElseIf count == 80
		Return new Form[80]
	ElseIf count == 81
		Return new Form[81]
	ElseIf count == 82
		Return new Form[82]
	ElseIf count == 83
		Return new Form[83]
	ElseIf count == 84
		Return new Form[84]
	ElseIf count == 85
		Return new Form[85]
	ElseIf count == 86
		Return new Form[86]
	ElseIf count == 87
		Return new Form[87]
	ElseIf count == 88
		Return new Form[88]
	ElseIf count == 89
		Return new Form[89]
	ElseIf count == 90
		Return new Form[90]
	ElseIf count == 91
		Return new Form[91]
	ElseIf count == 92
		Return new Form[92]
	ElseIf count == 93
		Return new Form[93]
	ElseIf count == 94
		Return new Form[94]
	ElseIf count == 95
		Return new Form[95]
	ElseIf count == 96
		Return new Form[96]
	ElseIf count == 97
		Return new Form[97]
	ElseIf count == 98
		Return new Form[98]
	ElseIf count == 99
		Return new Form[99]
	ElseIf count == 100
		Return new Form[100]
	ElseIf count == 101
		Return new Form[101]
	ElseIf count == 102
		Return new Form[102]
	ElseIf count == 103
		Return new Form[103]
	ElseIf count == 104
		Return new Form[104]
	ElseIf count == 105
		Return new Form[105]
	ElseIf count == 106
		Return new Form[106]
	ElseIf count == 107
		Return new Form[107]
	ElseIf count == 108
		Return new Form[108]
	ElseIf count == 109
		Return new Form[109]
	ElseIf count == 110
		Return new Form[110]
	ElseIf count == 111
		Return new Form[111]
	ElseIf count == 112
		Return new Form[112]
	ElseIf count == 113
		Return new Form[113]
	ElseIf count == 114
		Return new Form[114]
	ElseIf count == 115
		Return new Form[115]
	ElseIf count == 116
		Return new Form[116]
	ElseIf count == 117
		Return new Form[117]
	ElseIf count == 118
		Return new Form[118]
	ElseIf count == 119
		Return new Form[119]
	ElseIf count == 120
		Return new Form[120]
	ElseIf count == 121
		Return new Form[121]
	ElseIf count == 122
		Return new Form[122]
	ElseIf count == 123
		Return new Form[123]
	ElseIf count == 124
		Return new Form[124]
	ElseIf count == 125
		Return new Form[125]
	ElseIf count == 126
		Return new Form[126]
	ElseIf count == 127
		Return new Form[127]
	EndIf
EndFunction
