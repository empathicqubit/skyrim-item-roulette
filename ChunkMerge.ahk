SetTitleMatchMode, RegEx
WinWait, ahk_exe i)ChunkMerge.exe
WinGet, ChunkMain, ID, ahk_exe i)ChunkMerge.exe
WinActivate, ahk_id %ChunkMain%

Clipboard := ChunkMerge_NifFile
ControlFocus Edit1, ahk_id %ChunkMain%
Send +{Insert}

Clipboard := ChunkMerge_CollisionFile
ControlFocus Edit2, ahk_id %ChunkMain%
Send +{Insert}

ControlFocus, ComboBox1, ahk_id %ChunkMain%
Send, %ChunkMerge_TemplateFile%
ControlClick, Mesh Data, ahk_id %ChunkMain%
ControlClick, Name of NiTriShape, ahk_id %ChunkMain%

ControlSend Convert, {Space}, ahk_id %ChunkMain%

Loop {
    Sleep 100
    ControlGetText, FinishedText, RichEdit20W1, ahk_id %ChunkMain%
    IfInString, FinishedText, Nif converted successfully
    {
        Break
    }
}