-- MIDIFunctions.lua: MIDI note and event operations

local MIDIFunctions = {}

-- Function: Add MIDI note at playhead position
function MIDIFunctions.AddNote(take, noteNumber, velocity, length)
    if not take then return false end
    
    -- Get playhead position
    local playPos = reaper.GetCursorPosition()
    
    -- Convert to QN and PPQ
    local startQN = reaper.TimeMap2_timeToQN(0, playPos)
    local startPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, startQN)
    
    -- Calculate end position (length is in quarter notes)
    local endQN = startQN + length
    local endPPQ = reaper.MIDI_GetPPQPosFromProjQN(take, endQN)
    
    -- Insert MIDI note
    reaper.MIDI_InsertNote(take, true, false, startPPQ, endPPQ, 0, noteNumber, velocity, false)
    
    -- Update MIDI
    reaper.MIDI_Sort(take)
    reaper.UpdateArrange()
    
    return true
end

-- Function: Add text event at playhead position to a specific track
function MIDIFunctions.AddTextEvent(track, text)
    if not track then return false end
    
    -- Get playhead position
    local playPos = reaper.GetCursorPosition()
    
    -- Get or create MIDI item at playhead position
    local itemCount = reaper.CountTrackMediaItems(track)
    local targetItem = nil
    local targetTake = nil
    
    -- Look for existing MIDI item at playhead
    for i = 0, itemCount - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        
        if playPos >= itemStart and playPos <= itemEnd then
            local take = reaper.GetActiveTake(item)
            if take and reaper.TakeIsMIDI(take) then
                targetItem = item
                targetTake = take
                break
            end
        end
    end
    
    -- If no MIDI item found, create one
    if not targetTake then
        targetItem = reaper.CreateNewMIDIItemInProj(track, playPos, playPos + 4.0)
        targetTake = reaper.GetActiveTake(targetItem)
    end
    
    if not targetTake then return false end
    
    -- Convert playhead position to PPQ
    local playPosQN = reaper.TimeMap2_timeToQN(0, playPos)
    local playPosPPQ = reaper.MIDI_GetPPQPosFromProjQN(targetTake, playPosQN)
    
    -- Insert text event
    -- Parameters: take, selected, muted, ppqpos, type, msg
    reaper.MIDI_InsertTextSysexEvt(targetTake, true, false, playPosPPQ, 1, text)
    
    -- Update MIDI
    reaper.MIDI_Sort(targetTake)
    reaper.UpdateArrange()
    
    return true
end

return MIDIFunctions