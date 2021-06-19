Scriptname _EQ_ItemRoulette_Quest extends Quest  

Actor Property PlayerRef Auto
Static Property _EQ_ItemRoulette_Roulette Auto
Activator Property FormChunks Auto

ObjectReference[] DisplayItems
Form[] SpawnedForms
Form[] UnspawnedForms
ObjectReference Roulette

Bool ShouldSortInventoryItems
Int MAX_ITEMS
Float UI_TRANSLATE_SPEED
Float UI_DISTANCE
Float UI_DEGREES
Float UI_ZEES
Float UI_ITEM_SCALE

Event OnInit()
	; Placeholder for things to happen only on first load for this save
	Main()
EndEvent

Function Main()
	MAX_ITEMS = 5
	UI_DISTANCE = 48.0
	UI_DEGREES = 14.0
	UI_ZEES = 12.0
	UI_ITEM_SCALE = 0.25
	UI_TRANSLATE_SPEED = 10000

	DisplayItems = New ObjectReference[127]
	int index = 0
	While index < MAX_ITEMS
		DisplayItems[index] = None
		index += 1
	EndWhile

	UnspawnedForms = New Form[127]
	index = 0
	While index < MAX_ITEMS
		UnspawnedForms[index] = None
		index += 1
	EndWhile

	SpawnedForms = New Form[127]
	index = 0
	While index < MAX_ITEMS
		SpawnedForms[index] = None
		index += 1
	EndWhile

	ShouldSortInventoryItems = True

	Debug.Trace("Item Roulette loaded")

	Roulette = PlayerRef.PlaceAtMe(_EQ_ItemRoulette_Roulette)
	Roulette.SetMotionType(Roulette.Motion_Keyframed)

	RegisterForModEvent("_EQ_ItemRoulette_Activate", "OnMyAction")
	VRIK.VrikAddGestureAction("_EQ_ItemRoulette_Activate", "Activate Item Roulette")
	RegisterForSingleUpdate(0.01)
EndFunction

Event OnUpdate()
	Float playerAngle = PlayerRef.GetAngleZ()

	if ShouldSortInventoryItems
		ShouldSortInventoryItems = False
		SortInventoryItems()
	EndIf

	Int index = 0
	While index < MAX_ITEMS
		Form unspawnedForm = UnspawnedForms[index]
		if unspawnedForm != None
			If unspawnedForm != SpawnedForms[index]
				SpawnedForms[index] = unspawnedForm
				ObjectReference displayItem = Roulette.PlaceAtMe(unspawnedForm)
				DisplayItems[index] = displayItem
				displayItem.SetScale(UI_ITEM_SCALE)
				displayItem.SetMotionType(displayItem.Motion_Keyframed)
			EndIf
		Else
			index += 1000
		EndIf
		index += 1
	EndWhile

	Roulette.TranslateTo(PlayerRef.X + UI_DISTANCE * Math.sin(playerAngle), PlayerRef.Y + UI_DISTANCE * Math.cos(playerAngle), VRIK.VrikGetHmdZ(), 0, 0, playerAngle, UI_TRANSLATE_SPEED)

	index = 0
	While index < MAX_ITEMS && DisplayItems[index] != None
		; T-LCR-B
		Float top = 0
		Float left = 0
		If index == 0
			top = -UI_ZEES
		ElseIf index == 1
			left = -UI_DEGREES
		ElseIf index == 2
			top = 0
			left = 0
		ElseIf index == 3
			left = UI_DEGREES
		Else
			top = UI_ZEES
		EndIf
		DisplayItems[index].TranslateTo(PlayerRef.X + UI_DISTANCE * Math.sin(playerAngle - left), PlayerRef.Y + UI_DISTANCE * Math.cos(playerAngle - left), VRIK.VrikGetHmdZ() - top, 0, 0, playerAngle, UI_TRANSLATE_SPEED)
		index += 1
	EndWhile

	RegisterForSingleUpdate(0.01)
EndEvent

Function SortInventoryItems()
	_EQ_ItemRoulette_FormChunks sortChunks = ((Roulette.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
	sortChunks.Children = new Form[127]
	Int formIndex = 0
	Int chunkIndex = -1
	Int chunkItemIndex = 127
	Int numItems = PlayerRef.getNumItems()
	_EQ_ItemRoulette_FormChunks chunk
	While formIndex < numItems
		If chunkItemIndex >= 127
			chunkItemIndex = 0
			chunkIndex += 1
			chunk = ((Roulette.PlaceAtMe(FormChunks) as Form) as _EQ_ItemRoulette_FormChunks)
			chunk.Children = new Form[127]
			sortChunks.Children[chunkIndex] = chunk
		EndIf
		chunk.Children[chunkItemIndex] = PlayerRef.GetNthForm(formIndex)
		formIndex += 1
		chunkItemIndex += 1
	EndWhile

	Debug.StartStackProfiling()
	Debug.Trace("Sorting")
	sortChunks.SortByNameRecursive()
	Debug.Trace("Printing")
	sortChunks.PrintNamesRecursive()
	Debug.Trace("Grouping")
	_EQ_ItemRoulette_FormChunks groupChunks = sortChunks.GroupByName(Roulette)
	Debug.Trace("Printing")
	Debug.StopStackProfiling()
	groupChunks.PrintNamesRecursive()
EndFunction

Function PlayerItemAdded(Form baseItem, Int itemCount, ObjectReference itemRef, ObjectReference destContainer)
	ShouldSortInventoryItems = True
EndFunction

Function PlayerItemRemoved(Form baseItem, Int itemCount, ObjectReference itemRef, ObjectReference destContainer)
	ShouldSortInventoryItems = True
EndFunction

Event OnMyAction(string eventName, string strArg, float numArg, Form sender)
	Debug.Trace("VRIK activated me!")
	;/
	Get list of all inventory item names, sorted alphabetically
	break into groups of five
	find a common label for that group
	group the groups in a similar manner until there are only five?
	/;
	Int numItems = PlayerRef.GetNumItems()
	Debug.Trace("Found " + numItems + " items")

	Int count = 0
	Int formIndex = numItems
	While formIndex > 0 && formIndex > numItems - MAX_ITEMS
		formIndex -= 1
		count = numItems - formIndex
		Form invItem = PlayerRef.GetNthForm(formIndex)
		UnspawnedForms[count - 1] = invItem
	EndWhile
EndEvent