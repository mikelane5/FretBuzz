-- HandmapData.lua: Data for LH Handmap

local HandmapData = {}

-- Row data
-- Each row: {button_label, text_event, single_finger, vibrato, chord, open_hand}
HandmapData.ROWS = {
    {button = "Default", text_event = "[map HandMap_Default]", single_finger = "Yes", vibrato = "Yes", chord = "All", open_hand = "No"},
    {button = "No Chords", text_event = "[map HandMap_NoChords]", single_finger = "Yes", vibrato = "Yes", chord = "No", open_hand = "No"},
    {button = "All Chords", text_event = "[map HandMap_AllChords]", single_finger = "No", vibrato = "No", chord = "All", open_hand = "No"},
    {button = "Solo", text_event = "[map HandMap_Solo]", single_finger = "Yes", vibrato = "Chords", chord = "D", open_hand = "No"},
    {button = "DropD", text_event = "[map HandMap_DropD]", single_finger = "No", vibrato = "No", chord = "No", open_hand = "Green Gems"},
    {button = "DropD2", text_event = "[map HandMap_DropD2]", single_finger = "No", vibrato = "No", chord = "Yes", open_hand = "Green Gems"},
    {button = "All Bend", text_event = "[map HandMap_AllBend]", single_finger = "No", vibrato = "High Vibrato", chord = "No", open_hand = "No"},
    {button = "A Chord", text_event = "[map HandMap_Chord_A]", single_finger = "No", vibrato = "No", chord = "A", open_hand = "No"},
    {button = "C Chord", text_event = "[map HandMap_Chord_C]", single_finger = "No", vibrato = "No", chord = "C", open_hand = "No"},
    {button = "D Chord", text_event = "[map HandMap_Chord_D]", single_finger = "No", vibrato = "No", chord = "D", open_hand = "No"}
}

return HandmapData