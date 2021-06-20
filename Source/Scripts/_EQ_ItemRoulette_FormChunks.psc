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
	SortByName()
	Int childIndex = 0
	Form child
	While childIndex < Children.Length
		child = Children[childIndex]
		_EQ_ItemRoulette_FormChunks subChunk = (child as _EQ_ItemRoulette_FormChunks)
		If(subChunk != None)
			subChunk.SortByNameRecursive()
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

_EQ_ItemRoulette_FormChunks Function GroupByName(ObjectReference placer)
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
	While i < names.Length
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

	_EQ_ItemRoulette_FormChunks finalChunks = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	finalChunks.Children = currentChunks

	Return finalChunks
EndFunction