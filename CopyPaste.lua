-- CopyPaste.lua: Copy/Paste functionality with timeline selection
local CopyPaste = {}

-- Clipboard storage
CopyPaste.clipboard = {notes = {}, events = {}}

-- Constants
local NOTE_MIN = 40
local NOTE_MAX = 56

-- Get button color for Copy button
function CopyPaste.GetCopyButtonColor()
    if #CopyPaste.clipboard.notes > 0 or #CopyPaste.clipboard.events > 0 then
        return 0x0CA50CFF
    else
        return 0x4D4D4DFF
    end
end

-- Copy notes and events within timeline selection
-- Returns true if successful, false otherwise
function CopyPaste.CopyMarkedRegion(take)
    if not take then 
        return false
    end
    
    -- Get time selection
    local startTime, endTime = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    
    if startTime >= endTime then
        reaper.ShowMessageBox("Make a time selection first.", "Error", 0)
        return false
    end
    
    -- Convert to PPQ
    local startQN = reaper.TimeMap2_timeToQN(0, startTime)
    local startPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, startQN)
    local endQN = reaper.TimeMap2_timeToQN(0, endTime)
    local endPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, endQN)
    
    -- Clear clipboard
    CopyPaste.clipboard = {notes = {}, events = {}}
    
    -- Find earliest PPQ position (notes and events)
    local earliestPPQ = nil
    
    -- Check notes
    local _, noteCount = reaper.MIDI_CountEvts(take)
    
    for i = 0, noteCount - 1 do
        local _, _, _, startppq, _, _, pitch, _ = reaper.MIDI_GetNote(take, i)
        
        if startppq >= startPPQ and startppq <= endPPQ and pitch >= NOTE_MIN and pitch <= NOTE_MAX then
            if not earliestPPQ or startppq < earliestPPQ then
                earliestPPQ = startppq
            end
        end
    end
    
    -- Check text events
    local _, _, _, textEventCount = reaper.MIDI_CountEvts(take)
    
    for i = 0, textEventCount - 1 do
        local _, _, _, ppqpos, type, _ = reaper.MIDI_GetTextSysexEvt(take, i)
        
        if type == 1 and ppqpos >= startPPQ and ppqpos <= endPPQ then
            if not earliestPPQ or ppqpos < earliestPPQ then
                earliestPPQ = ppqpos
            end
        end
    end
    
    -- If nothing found, show error
    if not earliestPPQ then
        reaper.ShowMessageBox("No animation notes or text events found in selection.", "Error", 0)
        return false
    end
    
    -- Copy notes relative to earliest position
    for i = 0, noteCount - 1 do
        local _, _, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
        
        if startppq >= startPPQ and startppq <= endPPQ and pitch >= NOTE_MIN and pitch <= NOTE_MAX then
            table.insert(CopyPaste.clipboard.notes, {
                muted = muted,
                startppq = startppq - earliestPPQ,
                endppq = endppq - earliestPPQ,
                chan = chan,
                pitch = pitch,
                vel = vel
            })
        end
    end
    
    -- Copy text events relative to earliest position
    for i = 0, textEventCount - 1 do
        local _, _, muted, ppqpos, type, msg = reaper.MIDI_GetTextSysexEvt(take, i)
        
        if type == 1 and ppqpos >= startPPQ and ppqpos <= endPPQ then
            table.insert(CopyPaste.clipboard.events, {
                muted = muted,
                ppqpos = ppqpos - earliestPPQ,
                type = type,
                msg = msg
            })
        end
    end
    
    return true
end

-- Paste notes and events at cursor position
-- Returns true if successful, false otherwise
function CopyPaste.PasteAtCursor(take)
    if not take then 
        return false
    end
    
    if #CopyPaste.clipboard.notes == 0 and #CopyPaste.clipboard.events == 0 then
        return false
    end
    
    local cursorPos = reaper.GetCursorPosition()
    local cursorQN = reaper.TimeMap2_timeToQN(0, cursorPos)
    local cursorPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, cursorQN)
    
    reaper.Undo_BeginBlock()
    
    for _, note in ipairs(CopyPaste.clipboard.notes) do
        local startPPQ = cursorPPQ + note.startppq
        local endPPQ = cursorPPQ + note.endppq
        
        reaper.MIDI_InsertNote(take, false, note.muted, startPPQ, endPPQ, note.chan, note.pitch, note.vel, false)
    end
    
    for _, event in ipairs(CopyPaste.clipboard.events) do
        local ppqpos = cursorPPQ + event.ppqpos
        
        reaper.MIDI_InsertTextSysexEvt(take, false, event.muted, ppqpos, event.type, event.msg)
    end
    
    reaper.MIDI_Sort(take)
    reaper.UpdateArrange()
    
    reaper.Undo_EndBlock("Paste Animation", -1)
    
    return true
end

return CopyPaste