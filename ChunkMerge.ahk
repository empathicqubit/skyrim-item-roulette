SetTitleMatchMode, RegEx
WinWait, ahk_exe i)ChunkMerge.exe
WinActivate, ahk_exe i)ChunkMerge.exe

ControlFocus Button1, A
Send {Space}
Clipboard := ChunkMerge_NifFile
Send +{Insert}
Send {Enter}

WinWaitActive, i)ChunkMerge

ControlFocus Button2, A
Send {Space}
Clipboard := ChunkMerge_CollisionFile
Send +{Insert}
Send {Enter}

WinWaitActive, i)ChunkMerge

ControlFocus, ComboBox1, A
Send, %ChunkMerge_TemplateFile%
ControlFocus, Mesh Data, A
Send {Space}
ControlFocus, Name of NiTriShape, A
Send {Space}

Send {Enter}

Sleep 3000

WinClose, ahk_exe i)ChunkMerge.exe