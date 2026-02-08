-- UIHelpers.lua: Reusable UI component functions

-- Load ImGui
package.path = reaper.ImGui_GetBuiltinPath() .. '/?.lua'
local ImGui = require 'imgui' '0.9.3'

local UIHelpers = {}

-- Function: Draw centered text in a box
function UIHelpers.CenteredTextBox(ctx, id, text, width, height)
    ImGui.BeginChild(ctx, id, width, height, ImGui.ChildFlags_None)
    local textWidth = ImGui.CalcTextSize(ctx, text)
    ImGui.SetCursorPosX(ctx, (width - textWidth) / 2)
    ImGui.SetCursorPosY(ctx, (height - 15) / 2)  -- Approximate vertical center
    ImGui.Text(ctx, text)
    ImGui.EndChild(ctx)
end

-- Function: Draw handmap header row
function UIHelpers.DrawHandmapHeader(ctx)
    local headers = {"LH Handmap", "Single Fingers", "Vibrato", "Chords", "Open Hand"}
    
    for i, header in ipairs(headers) do
        UIHelpers.CenteredTextBox(ctx, 'header_' .. i, header, 108, 30)
        if i < #headers then
            ImGui.SameLine(ctx)
        end
    end
end

-- Function: Draw handmap data row
function UIHelpers.DrawHandmapRow(ctx, row, index, buttonCallback)
    if not row.button then return end
    
    -- Button
    if ImGui.Button(ctx, row.button .. '##handmap' .. index, 108, 30) then
        if buttonCallback then
            buttonCallback(row.button, index)
        end
    end
    ImGui.SameLine(ctx)
    
    -- Data boxes
    local data = {row.single_finger, row.vibrato, row.chord, row.open_hand}
    for i, value in ipairs(data) do
        UIHelpers.CenteredTextBox(ctx, 'data_' .. index .. '_' .. i, value, 108, 30)
        if i < #data then
            ImGui.SameLine(ctx)
        end
    end
end

return UIHelpers