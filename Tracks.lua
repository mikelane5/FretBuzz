-- Tracks.lua: Track name definitions and groups

local Tracks = {}

-- Define track names
Tracks.NAMES = {
    PART_BASS = "PART BASS",
    PART_GUITAR = "PART GUITAR",
    PART_RHYTHM = "PART RHYTHM"
}

-- Define track groups for different button types
Tracks.GROUPS = {
    BASS_ONLY = {"PART BASS"},
    GUITARS = {"PART BASS", "PART GUITAR", "PART RHYTHM"}
}

-- Function to get track by name
function Tracks.GetTrack(trackName)
    for i = 0, reaper.CountTracks(0) - 1 do
        local track = reaper.GetTrack(0, i)
        local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
        if name == trackName then
            return track
        end
    end
    return nil
end

-- Function to get track name from track object
function Tracks.GetTrackName(track)
    if not track then return nil end
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    return name
end

-- Function to check if a track exists in a group
function Tracks.IsTrackInGroup(trackName, groupName)
    local group = Tracks.GROUPS[groupName]
    if not group then return false end
    
    for _, name in ipairs(group) do
        if name == trackName then
            return true
        end
    end
    return false
end

-- Function to get currently selected MIDI editor track
function Tracks.GetActiveMIDITrack()
    local midiEditor = reaper.MIDIEditor_GetActive()
    if not midiEditor then return nil end
    
    local take = reaper.MIDIEditor_GetTake(midiEditor)
    if not take then return nil end
    
    local item = reaper.GetMediaItemTake_Item(take)
    if not item then return nil end
    
    local track = reaper.GetMediaItemTrack(item)
    return track, take
end

return Tracks