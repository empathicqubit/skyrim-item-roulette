Scriptname _EQ_ItemRoulette_Main extends ReferenceAlias

Event OnItemAdded(Form baseItem, Int itemCount, ObjectReference itemRef, ObjectReference destContainer)
	(GetOwningQuest() as _EQ_ItemRoulette_Quest).PlayerItemAdded(baseItem, itemCount, itemRef, destContainer)
EndEvent

Event OnItemRemoved(Form baseItem, Int itemCount, ObjectReference itemRef, ObjectReference destContainer)
	(GetOwningQuest() as _EQ_ItemRoulette_Quest).PlayerItemRemoved(baseItem, itemCount, itemRef, destContainer)
EndEvent

Event OnPlayerLoadGame()
	(GetOwningQuest() as _EQ_ItemRoulette_Quest).Main()
EndEvent
