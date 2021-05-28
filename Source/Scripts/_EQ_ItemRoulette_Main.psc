Scriptname _EQ_ItemRoulette_Main extends ReferenceAlias

Event OnPlayerLoadGame()
	(GetOwningQuest() as _EQ_ItemRoulette_Quest).Main()
EndEvent
