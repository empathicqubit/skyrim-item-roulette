Scriptname _EQ_ItemRoulette_Quest extends Quest  

Actor Property PlayerRef Auto
Static Property _EQ_ItemRoulette_Roulette Auto
Activator Property FormChunks Auto

MiscObject Property Slot01 Auto
MiscObject Property Slot02 Auto
MiscObject Property Slot03 Auto
MiscObject Property Slot04 Auto
MiscObject Property Slot05 Auto

ObjectReference[] DisplayItems
Form[] Slots
_EQ_ItemRoulette_FormChunks SpawnedNode
_EQ_ItemRoulette_FormChunks SelectedNode
_EQ_ItemRoulette_FormChunks ItemTree
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

	Slots = New Form[5]
	Slots[0] = Slot01
	Slots[1] = Slot02
	Slots[2] = Slot03
	Slots[3] = Slot04
	Slots[4] = Slot05

	DisplayItems = New ObjectReference[5]
	int index = 0
	While index < MAX_ITEMS
		DisplayItems[index] = None
		index += 1
	EndWhile

	ItemTree = None
	SelectedNode = None
	SpawnedNode = None

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
	If SelectedNode != None && SpawnedNode != SelectedNode
		ObjectReference[] newItems = new ObjectReference[5]
		Form child
		_EQ_ItemRoulette_FormChunks subChunk = (SelectedNode.Children[0] as _EQ_ItemRoulette_FormChunks)
		If subChunk != None
			While index < SelectedNode.Children.Length
				subChunk = (SelectedNode.Children[index] as _EQ_ItemRoulette_FormChunks)
				if subChunk != None
					Slots[index].SetName(subChunk.ChunkName)
					ObjectReference newItem = Roulette.PlaceAtMe(Slots[index])
					newItem.SetScale(UI_ITEM_SCALE)
					newItem.SetMotionType(newItem.Motion_Keyframed)
					newItems[index] = newItem
					index += 1
				EndIf
			EndWhile
		Else
			While index < SelectedNode.Children.Length
				child = SelectedNode.Children[index]
				If child != None
					newItems[index] = Roulette.PlaceAtMe(child)
					index += 1
				EndIf
			EndWhile
		EndIf

		index = 0
		While index < MAX_ITEMS
			If DisplayItems[index] != None
				DisplayItems[index].Delete()
			EndIf
		EndWhile

		DisplayItems = newItems

		SpawnedNode = SelectedNode
	EndIf

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

	Debug.Trace("Start generating list")
	_EQ_ItemRoulette_FormChunks top = sortChunks.GroupByType(Roulette)

	ItemTree = top
	Debug.Trace("Finish generating list")
EndFunction

Function PlayerItemAdded(Form baseItem, Int itemCount, ObjectReference itemRef, ObjectReference destContainer)
	ShouldSortInventoryItems = True
EndFunction

Function PlayerItemRemoved(Form baseItem, Int itemCount, ObjectReference itemRef, ObjectReference destContainer)
	ShouldSortInventoryItems = True
EndFunction

Event OnMyAction(string eventName, string strArg, float numArg, Form sender)
	Debug.Trace("VRIK activated me!")

	If SelectedNode == None
		SelectedNode = ItemTree
	EndIf
EndEvent