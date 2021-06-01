Scriptname _EQ_ItemRoulette_Quest extends Quest  

Actor Property PlayerRef Auto
Static Property _EQ_ItemRoulette_Roulette Auto

ObjectReference[] DisplayItems
ObjectReference Roulette

Int MAX_ITEMS = 5
Float UI_DISTANCE = 32.0
Float UI_DEGREES = 7.0
Float UI_ZEES = 4.0

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
	Roulette = PlayerRef.PlaceAtMe(_EQ_ItemRoulette_Roulette)
	RegisterForModEvent("_EQ_ItemRoulette_Activate", "OnMyAction")
	VRIK.VrikAddGestureAction("_EQ_ItemRoulette_Activate", "Activate Item Roulette")
	RegisterForSingleUpdate(0.01)
EndFunction

Event OnUpdate()
	Float handX = VRIK.VrikGetHandX(true)
	Float handY = VRIK.VrikGetHandY(true)
	Float handZ = VRIK.VrikGetHandZ(true)
	Float playerAngle = PlayerRef.GetAngleZ()

	Roulette.MoveTo(PlayerRef, UI_DISTANCE * Math.sin(playerAngle), UI_DISTANCE * Math.cos(playerAngle), VRIK.VrikGetHmdZ(), true)

	Int index = 0
	While index < MAX_ITEMS && DisplayItems[index] != None
		; TLRB
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
		DisplayItems[index].MoveTo(PlayerRef, UI_DISTANCE * Math.sin(playerAngle - left), UI_DISTANCE * Math.cos(playerAngle - left), (VRIK.VrikGetHmdZ() - PlayerRef.Z) + top)
		index += 1
	EndWhile

	RegisterForSingleUpdate(0.01)
EndEvent

Event OnMyAction(string eventName, string strArg, float numArg, Form sender)
	Debug.Trace("VRIK activated me!")
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
EndEvent