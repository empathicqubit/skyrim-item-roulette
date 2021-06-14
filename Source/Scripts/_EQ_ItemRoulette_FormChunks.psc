Scriptname _EQ_ItemRoulette_FormChunks extends Form

Form[] Property Children Auto

Function SortByName()
	; based on "Optimized QuickSort - C Implementation" by darel rex finley (http://alienryderflex.com/quicksort/)		
	Int[] Beg = new Int[127]
	Int[] End = new Int[127]
	String[] Names = new String[127]
	Int i = 0
	Int L
	Int R
	Int swap
	Form piv
	String pivName
	
	Beg[0] = 0
	End[0] = Children.Length

	While(i < Children.Length)
		If Children[i] != None
			Names[i] = Children[i].GetName()
		Else
			Names[i] = ""
		EndIf
		i += 1
	EndWhile
	
	i = 0
	While (i >= 0)
		L = Beg[i]
		R = End[i] - 1;
		If (L < R)
			piv = Children[L]
			pivName = Names[L]
			While (L < R)
				While ((Names[R] >= pivName) && (L < R))
					R -= 1
				EndWhile
				If (L < R)					
					Names[L] = Names[R]
					Children[L] = Children[R]					
					L += 1
				EndIf
				While ((Names[L] <= pivName) && (L < R))
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
EndFunction

Function SortByNameRecursive()
	SortByName()
	Int childIndex = 0
	While childIndex < Children.Length
		Form child = Children[childIndex]
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
			Debug.Trace("Chunk")
			subChunk.PrintNamesRecursive()
		ElseIf child != None
            Debug.Trace(child.GetName())
		EndIf
		childIndex += 1
	EndWhile
EndFunction