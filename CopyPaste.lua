-- CopyPaste.lua: Copy/Paste functionality with timeline marker system
local CopyPaste = {}

-- Clipboard storage
CopyPaste.clipboard = {notes = {}, events = {}}

-- Constants
local START_MARKER = "COPY_START"
local END_MARKER = "COPY_END"
local NOTE_MIN = 40
local NOTE_MAX = 56

-- Find timeline markers by name
-- Returns: startPos, endPos, startIdx, endIdx (nil if not found)
function CopyPaste.FindMarkers()
    local startPos = nil
    local endPos = nil
    local startIdx = nil
    local endIdx = nil
    
    local numMarkers, numRegions = reaper.CountProjectMarkers(0)
    
    for i = 0, numMarkers + numRegions - 1 do
        local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
        
        if not isrgn then
            if name == START_MARKER then
                startPos = pos
                startIdx = markrgnindexnumber
            elseif name == END_MARKER then
                endPos = pos
                endIdx = markrgnindexnumber
            end
        end
    end
    
    return startPos, endPos, startIdx, endIdx
end

-- Check marker state and return button states
function CopyPaste.CheckMarkerState()
    local state = {
        has_start = false,
        has_end = false,
        order_valid = true,
        can_place_start = true,
        can_place_end = true
    }
    
    local startPos, endPos = CopyPaste.FindMarkers()
    
    state.has_start = (startPos ~= nil)
    state.has_end = (endPos ~= nil)
    
    if state.has_start and state.has_end then
        state.order_valid = (endPos > startPos)
    end
    
    state.can_place_start = not state.has_start
    state.can_place_end = not state.has_end
    
    return state
end

-- Get button color for Start button
function CopyPaste.GetStartButtonColor(markerState)
    if markerState.has_start and markerState.has_end and not markerState.order_valid then
        -- Red: both exist but invalid order
        return 0xFF0000FF
    elseif markerState.has_start and markerState.has_end and markerState.order_valid then
        -- Green: both exist and valid order
        return 0x00FF00FF
    elseif markerState.has_end and not markerState.has_start then
        -- Orange: only end placed, waiting for start
        return 0xFF8000FF
    elseif markerState.has_start and not markerState.has_end then
        -- Green: only start placed
        return 0x00FF00FF
    else
        -- Default gray: neither placed
        return 0x4D4D4DFF
    end
end

-- Get button color for End button
function CopyPaste.GetEndButtonColor(markerState)
    if markerState.has_start and markerState.has_end and not markerState.order_valid then
        -- Red: both exist but invalid order
        return 0xFF0000FF
    elseif markerState.has_start and markerState.has_end and markerState.order_valid then
        -- Green: both exist and valid order
        return 0x00FF00FF
    elseif markerState.has_start and not markerState.has_end then
        -- Orange: only start placed, waiting for end
        return 0xFF8000FF
    elseif markerState.has_end and not markerState.has_start then
        -- Green: only end placed
        return 0x00FF00FF
    else
        -- Default gray: neither placed
        return 0x4D4D4DFF
    end
end

-- Get button color for Copy button
function CopyPaste.GetCopyButtonColor()
    if #CopyPaste.clipboard.notes > 0 or #CopyPaste.clipboard.events > 0 then
        return 0x0CA50CFF
    else
        return 0x4D4D4DFF
    end
end

-- Copy notes and events between timeline markers
function CopyPaste.CopyMarkedRegion(take)
    if not take then 
        return false
    end
    
    local startPos, endPos = CopyPaste.FindMarkers()
    
    if not startPos or not endPos then
        return false
    end
    
    if endPos <= startPos then
        return false
    end
    
    local startQN = reaper.TimeMap2_timeToQN(0, startPos)
    local startPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, startQN)
    local endQN = reaper.TimeMap2_timeToQN(0, endPos)
    local endPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, endQN)
    
    CopyPaste.clipboard = {notes = {}, events = {}}
    
    local _, noteCount = reaper.MIDI_CountEvts(take)
    for i = 0, noteCount - 1 do
        local _, _, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
        
        if startppq >= startPPQ and startppq <= endPPQ and pitch >= NOTE_MIN and pitch <= NOTE_MAX then
            table.insert(CopyPaste.clipboard.notes, {
                muted = muted,
                startppq = startppq - startPPQ,
                endppq = endppq - startPPQ,
                chan = chan,
                pitch = pitch,
                vel = vel
            })
        end
    end
    
    local _, _, _, textEventCount = reaper.MIDI_CountEvts(take)
    
    for i = 0, textEventCount - 1 do
        local _, _, muted, ppqpos, type, msg = reaper.MIDI_GetTextSysexEvt(take, i)
        
        if type == 1 and ppqpos >= startPPQ and ppqpos <= endPPQ then
            table.insert(CopyPaste.clipboard.events, {
                muted = muted,
                ppqpos = ppqpos - startPPQ,
                type = type,
                msg = msg
            })
        end
    end
    
    return true
end

-- Paste notes and events at cursor position
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

-- Remove all COPY_START and COPY_END timeline markers
function CopyPaste.ClearMarkers()
    local startPos, endPos, startIdx, endIdx = CopyPaste.FindMarkers()
    
    if startIdx and endIdx then
        if startIdx > endIdx then
            reaper.DeleteProjectMarker(0, startIdx, false)
            reaper.DeleteProjectMarker(0, endIdx, false)
        else
            reaper.DeleteProjectMarker(0, endIdx, false)
            reaper.DeleteProjectMarker(0, startIdx, false)
        end
    elseif startIdx then
        reaper.DeleteProjectMarker(0, startIdx, false)
    elseif endIdx then
        reaper.DeleteProjectMarker(0, endIdx, false)
    end
    
    reaper.UpdateArrange()
    
    return true
end

return CopyPaste