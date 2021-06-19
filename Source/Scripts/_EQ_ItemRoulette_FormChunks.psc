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
			Debug.Trace(i)
			If Children[i] != None
				names[i] = GetSortName(Children[i].GetName())
				Debug.Trace(names[i])
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

Function PrintNamesRecursive()
	Int childIndex = 0
	While childIndex < Children.Length
		Form child = Children[childIndex]
		_EQ_ItemRoulette_FormChunks subChunk = (child as _EQ_ItemRoulette_FormChunks)
		If(subChunk != None)
			Debug.Trace("Chunk " + subChunk.ChunkName)
			subChunk.PrintNamesRecursive()
		ElseIf child != None
            Debug.Trace(child.GetName())
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

	return StringUtil.Substring(source, 0, i)
EndFunction

Function FinishLastChunk(_EQ_ItemRoulette_FormChunks prevChunk, _EQ_ItemRoulette_FormChunks newChunk)
	String prevChunkEndName = ""
	if prevChunk != None
		prevChunkEndName = prevChunk.EndName
	EndIf
	newChunk.ChunkName = Disambiguate(newChunk.StartName, prevChunkEndName, newChunk.EndName)
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
	_EQ_ItemRoulette_FormChunks groupChunks = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	groupChunks.Children = new Form[127]

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

	Int chunkItemIndex = 5
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
			If chunkItemIndex >= 5
				chunkItemIndex = 0
				chunkIndex += 1
				prevChunk = newChunk
				newChunk = ((placer.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
				newChunk.Children = new Form[5]
				groupChunks.Children[chunkIndex] = newChunk
			EndIf

			index = indices[minIndex]
			currentItem = (Children[minIndex] as _EQ_ItemRoulette_FormChunks).Children[index]
			newChunk.Children[chunkItemIndex] = currentItem
			if chunkItemIndex == 0
				newChunk.StartName = names[minIndex]
				if prevChunk != None
					prevChunk.ChunkName += "-" + Disambiguate(prevChunk.EndName, prevChunk.StartName, newChunk.StartName)
				EndIf
			ElseIf chunkItemIndex == newChunk.Children.Length - 1
				newChunk.EndName = names[minIndex]
				FinishLastChunk(prevChunk, newChunk)
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
	FinishLastChunk(prevChunk, newChunk)

	Return groupChunks
EndFunction