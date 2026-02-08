-- Buttons.lua: Button action functions
local Tracks = require('Tracks')
local MIDIFunctions = require('MIDIFunctions')

local Buttons = {}

-- Lazy load CopyPaste module (only when needed)
local CopyPaste = nil
local function GetCopyPaste()
    if not CopyPaste then
        CopyPaste = require('CopyPaste')
    end
    return CopyPaste
end

-- Helper function to add fret note (reduces code duplication)
local function AddFretNote(noteNumber, fretNumber)
    local track, take = Tracks.GetActiveMIDITrack()
    
    if not track or not take then
        reaper.ShowMessageBox("No active MIDI editor or track!", "Error", 0)
        return
    end
    
    -- Get track name
    local trackName = Tracks.GetTrackName(track)
    
    -- Check if track is in GUITARS group
    if not Tracks.IsTrackInGroup(trackName, "GUITARS") then
        reaper.ShowMessageBox("This button only works on GUITARS tracks!\n(PART BASS, PART GUITAR, PART RHYTHM)", "Error", 0)
        return
    end
    
    -- Add note with velocity 96, length 32nd note (0.125 quarter notes)
    reaper.Undo_BeginBlock()
    MIDIFunctions.AddNote(take, noteNumber, 96, 0.125)
    reaper.Undo_EndBlock("Add Fret " .. fretNumber .. " Note", -1)
end

-- Fret button functions
function Buttons.Fret_1()
    AddFretNote(40, 1)
end

function Buttons.Fret_2()
    AddFretNote(43, 2)
end

function Buttons.Fret_3()
    AddFretNote(45, 3)
end

function Buttons.Fret_4()
    AddFretNote(47, 4)
end

function Buttons.Fret_5()
    AddFretNote(49, 5)
end

function Buttons.Fret_6()
    AddFretNote(50, 6)
end

function Buttons.Fret_7()
    AddFretNote(52, 7)
end

function Buttons.Fret_8()
    AddFretNote(53, 8)
end

function Buttons.Fret_9()
    AddFretNote(55, 9)
end

function Buttons.Fret_10()
    AddFretNote(56, 10)
end

function Buttons.Fret_11()
    AddFretNote(57, 11)
end

function Buttons.Fret_12()
    AddFretNote(59, 12)
end

-- Button Function: StrumMap_Default - Add text event to PART_BASS
function Buttons.StrumMap_Default()
    local bassTrack = Tracks.GetTrack(Tracks.NAMES.PART_BASS)
    
    if not bassTrack then
        reaper.ShowMessageBox("PART BASS track not found!", "Error", 0)
        return
    end
    
    -- Add text event
    reaper.Undo_BeginBlock()
    MIDIFunctions.AddTextEvent(bassTrack, "[map StrumMap_Default]")
    reaper.Undo_EndBlock("Add Strum Map: Default", -1)
end

-- Button Function: StrumMap_Pick - Add text event to PART_BASS
function Buttons.StrumMap_Pick()
    local bassTrack = Tracks.GetTrack(Tracks.NAMES.PART_BASS)
    
    if not bassTrack then
        reaper.ShowMessageBox("PART BASS track not found!", "Error", 0)
        return
    end
    
    -- Add text event
    reaper.Undo_BeginBlock()
    MIDIFunctions.AddTextEvent(bassTrack, "[map StrumMap_Pick]")
    reaper.Undo_EndBlock("Add Strum Map: Pick", -1)
end

-- Button Function: StrumMap_Slap - Add text event to PART_BASS
function Buttons.StrumMap_Slap()
    local bassTrack = Tracks.GetTrack(Tracks.NAMES.PART_BASS)
    
    if not bassTrack then
        reaper.ShowMessageBox("PART BASS track not found!", "Error", 0)
        return
    end
    
    -- Add text event
    reaper.Undo_BeginBlock()
    MIDIFunctions.AddTextEvent(bassTrack, "[map StrumMap_SlapBass]")
    reaper.Undo_EndBlock("Add Strum Map: Slap", -1)
end

-- Button Function: Handmap buttons - Add text event to GUITARS tracks
function Buttons.HandmapButton(textEvent)
    local track, take = Tracks.GetActiveMIDITrack()
    
    if not track or not take then
        reaper.ShowMessageBox("No active MIDI editor or track!", "Error", 0)
        return
    end
    
    -- Get track name
    local trackName = Tracks.GetTrackName(track)
    
    -- Check if track is in GUITARS group
    if not Tracks.IsTrackInGroup(trackName, "GUITARS") then
        reaper.ShowMessageBox("Handmap buttons only work on GUITARS tracks!\n(PART BASS, PART GUITAR, PART RHYTHM)", "Error", 0)
        return
    end
    
    -- Add text event to the active track
    reaper.Undo_BeginBlock()
    MIDIFunctions.AddTextEvent(track, textEvent)
    reaper.Undo_EndBlock("Add Handmap: " .. textEvent, -1)
end

-- Copy/Paste Button Functions

-- Place COPY_START timeline marker at cursor
function Buttons.PlaceStartMarker()
    local CP = GetCopyPaste()
    
    -- Check if START already exists
    local startPos = CP.FindMarkers()
    if startPos then
        reaper.ShowMessageBox("COPY_START marker already exists! Use Clear Markers first.", "Error", 0)
        return
    end
    
    -- Get cursor position and add marker
    local cursorPos = reaper.GetCursorPosition()
    
    reaper.Undo_BeginBlock()
    reaper.AddProjectMarker(0, false, cursorPos, 0, "COPY_START", -1)
    reaper.UpdateArrange()
    reaper.Undo_EndBlock("Place COPY_START Marker", -1)
end

-- Place COPY_END timeline marker at cursor
function Buttons.PlaceEndMarker()
    local CP = GetCopyPaste()
    
    -- Check if END already exists
    local _, endPos = CP.FindMarkers()
    if endPos then
        reaper.ShowMessageBox("COPY_END marker already exists! Use Clear Markers first.", "Error", 0)
        return
    end
    
    -- Get cursor position and add marker
    local cursorPos = reaper.GetCursorPosition()
    
    reaper.Undo_BeginBlock()
    reaper.AddProjectMarker(0, false, cursorPos, 0, "COPY_END", -1)
    reaper.UpdateArrange()
    reaper.Undo_EndBlock("Place COPY_END Marker", -1)
end

-- Copy marked region
function Buttons.CopyMarkedRegion()
    local track, take = Tracks.GetActiveMIDITrack()
    
    if not track or not take then
        reaper.ShowMessageBox("No active MIDI editor or track!", "Error", 0)
        return
    end
    
    -- Get track name
    local trackName = Tracks.GetTrackName(track)
    
    -- Check if track is in GUITARS group
    if not Tracks.IsTrackInGroup(trackName, "GUITARS") then
        reaper.ShowMessageBox("Copy only works on GUITARS tracks!\n(PART BASS, PART GUITAR, PART RHYTHM)", "Error", 0)
        return
    end
    
    reaper.Undo_BeginBlock()
    GetCopyPaste().CopyMarkedRegion(take)
    reaper.Undo_EndBlock("Copy Marked Region", -1)
end

-- Paste at cursor
function Buttons.PasteAtCursor()
    local track, take = Tracks.GetActiveMIDITrack()
    
    if not track or not take then
        reaper.ShowMessageBox("No active MIDI editor or track!", "Error", 0)
        return
    end
    
    -- Get track name
    local trackName = Tracks.GetTrackName(track)
    
    -- Check if track is in GUITARS group
    if not Tracks.IsTrackInGroup(trackName, "GUITARS") then
        reaper.ShowMessageBox("Paste only works on GUITARS tracks!\n(PART BASS, PART GUITAR, PART RHYTHM)", "Error", 0)
        return
    end
    
    GetCopyPaste().PasteAtCursor(take)
end

-- Clear all markers
function Buttons.ClearMarkers()
    reaper.Undo_BeginBlock()
    GetCopyPaste().ClearMarkers()
    reaper.Undo_EndBlock("Clear Markers", -1)
end

return Buttons