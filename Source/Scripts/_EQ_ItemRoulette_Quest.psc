Scriptname _EQ_ItemRoulette_Quest extends Quest  

Actor Property PlayerRef Auto
Static Property _EQ_ItemRoulette_Roulette Auto

ObjectReference[] DisplayItems

Int MAX_ITEMS = 6
Int CIRCLE_RADIUS = 16

Event OnInit()
	DisplayItems = New ObjectReference[127]
	int index = 0
	While index < MAX_ITEMS
		DisplayItems[index] = None
		index += 1
	EndWhile

	Main()
EndEvent

Function Main()
	Debug.Trace("Item Roulette loaded")
	RegisterForModEvent("_EQ_ItemRoulette_Activate", "OnMyAction")
	VRIK.VrikAddGestureAction("_EQ_ItemRoulette_Activate", "Activate Item Roulette")
	RegisterForSingleUpdate(0.01)
EndFunction

Event OnUpdate()
	Int index = 0
	While index < MAX_ITEMS && DisplayItems[index] != None
		DisplayItems[index].SetPosition(VRIK.VrikGetHandX(true) + CIRCLE_RADIUS * Math.sin(60 * index), VRIK.VrikGetHandY(true), VRIK.VrikGetHandZ(true) + CIRCLE_RADIUS * Math.cos(60 * index))
		index += 1
	EndWhile

	RegisterForSingleUpdate(0.01)
EndEvent

Event OnMyAction(string eventName, string strArg, float numArg, Form sender)
	Debug.Trace("VRIK activated me!")
	PlayerRef.PlaceAtMe(_EQ_ItemRoulette_Roulette)
	;/
	Int numItems = PlayerRef.getNumItems()
	Int formIndex = numItems
	Int count = 0
	While formIndex > 0 && formIndex > numItems - MAX_ITEMS
		formIndex -= 1
		count = numItems - formIndex
		Form invItem = PlayerRef.GetNthForm(formIndex)
		ObjectReference invItemInst = PlayerRef.DropObject(invItem)
		invItemInst.SetScale(0.1)
		invItemInst.SetMotionType(invItemInst.Motion_Keyframed)
		DisplayItems[count - 1] = invItemInst
	EndWhile
	/;
EndEvent