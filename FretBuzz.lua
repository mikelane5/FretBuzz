-- FretBuzz.lua: Main GUI Application
package.path = reaper.GetResourcePath() .. "\\Scripts\\FretBuzz\\?.lua;" .. reaper.ImGui_GetBuiltinPath() .. "/?.lua;" .. package.path

local ImGui = require 'imgui' '0.9.3'
local ctx = ImGui.CreateContext('FretBuzz')

-- Set path before each require as a workaround for ImGui resetting it
local fretbuzz_path = reaper.GetResourcePath() .. "\\Scripts\\FretBuzz\\?.lua;"

package.path = fretbuzz_path .. package.path
local Buttons = require('Buttons')

package.path = fretbuzz_path .. package.path
local HandmapData = require('HandmapData')

package.path = fretbuzz_path .. package.path
local UIHelpers = require('UIHelpers')

package.path = fretbuzz_path .. package.path
local CopyPaste = require('CopyPaste')

package.path = fretbuzz_path .. package.path
local Tracks = require('Tracks')

-- Main GUI loop
local function loop()
    ImGui.SetNextWindowSize(ctx, 704, 620, ImGui.Cond_FirstUseEver)
    local visible, open = ImGui.Begin(ctx, 'FretBuzz', true)
    
    if visible then
        ImGui.Text(ctx, 'Left Hand Fret Numbers')
        ImGui.Separator(ctx)
        
        -- Fret buttons 1-12
        if ImGui.Button(ctx, '1', 50, 40) then
            Buttons.Fret_1()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '2', 50, 40) then
            Buttons.Fret_2()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '3', 50, 40) then
            Buttons.Fret_3()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '4', 50, 40) then
            Buttons.Fret_4()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '5', 50, 40) then
            Buttons.Fret_5()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '6', 50, 40) then
            Buttons.Fret_6()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '7', 50, 40) then
            Buttons.Fret_7()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '8', 50, 40) then
            Buttons.Fret_8()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '9', 50, 40) then
            Buttons.Fret_9()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '10', 50, 40) then
            Buttons.Fret_10()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '11', 50, 40) then
            Buttons.Fret_11()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, '12', 50, 40) then
            Buttons.Fret_12()
        end
        
        -- Separator
        ImGui.Separator(ctx)
        
        -- LH Handmap Section
        ImGui.Spacing(ctx)
        
        -- Header row
        UIHelpers.DrawHandmapHeader(ctx)
        
        -- Data rows
        for i, row in ipairs(HandmapData.ROWS) do
            UIHelpers.DrawHandmapRow(ctx, row, i, function(buttonName, index)
                -- Get the text event for this row
                local textEvent = HandmapData.ROWS[index].text_event
                if textEvent then
                    Buttons.HandmapButton(textEvent)
                end
            end)
        end
        
        -- Separator
        ImGui.Separator(ctx)
        ImGui.Spacing(ctx)
        
        -- Copy Paste Animations Section
        ImGui.Text(ctx, 'Copy Paste Animations')
        ImGui.Spacing(ctx)
        
        -- Check marker state each frame (uses timeline markers now)
        local markerState = CopyPaste.CheckMarkerState()
        
        -- Start button
        local startColor = CopyPaste.GetStartButtonColor(markerState)
        ImGui.PushStyleColor(ctx, ImGui.Col_Button, startColor)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, startColor | 0x33000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive, startColor | 0x66000000)
        
        local startEnabled = markerState.can_place_start
        if not startEnabled then
            ImGui.BeginDisabled(ctx)
        end
        
        if ImGui.Button(ctx, 'Copy Start', 100, 40) then
            Buttons.PlaceStartMarker()
        end
        
        if not startEnabled then
            ImGui.EndDisabled(ctx)
        end
        ImGui.PopStyleColor(ctx, 3)
        ImGui.SameLine(ctx)
        
        -- End button
        local endColor = CopyPaste.GetEndButtonColor(markerState)
        ImGui.PushStyleColor(ctx, ImGui.Col_Button, endColor)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, endColor | 0x33000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive, endColor | 0x66000000)
        
        local endEnabled = markerState.can_place_end
        if not endEnabled then
            ImGui.BeginDisabled(ctx)
        end
        
        if ImGui.Button(ctx, 'Copy End', 100, 40) then
            Buttons.PlaceEndMarker()
        end
        
        if not endEnabled then
            ImGui.EndDisabled(ctx)
        end
        ImGui.PopStyleColor(ctx, 3)
        ImGui.SameLine(ctx)
        
        -- Copy button (with same styling as Start/End)
        local copyColor = CopyPaste.GetCopyButtonColor()
        ImGui.PushStyleColor(ctx, ImGui.Col_Button, copyColor)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, copyColor)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive, copyColor)
        
        local copyButtonX, copyButtonY = ImGui.GetCursorScreenPos(ctx)
        
        if ImGui.Button(ctx, 'Copy', 100, 40) then
            Buttons.CopyMarkedRegion()
        end
        
        -- Draw badges on top of Copy button if clipboard has data
        local noteCount = #CopyPaste.clipboard.notes
        local eventCount = #CopyPaste.clipboard.events
        
        if noteCount > 0 or eventCount > 0 then
            local draw_list = ImGui.GetWindowDrawList(ctx)
            
            -- Orange badge (top right) for notes
            if noteCount > 0 then
                local badgeSize = 22
                local badgeX = copyButtonX + 100 - badgeSize
                local badgeY = copyButtonY
                
                -- Draw orange square
                ImGui.DrawList_AddRectFilled(draw_list, badgeX, badgeY, 
                                            badgeX + badgeSize, badgeY + badgeSize, 
                                            0xFF8000FF)
                
                -- Draw note count in white (centered)
                local text = tostring(noteCount)
                local textX = badgeX + (badgeSize / 2) - 5
                local textY = badgeY + 4
                ImGui.DrawList_AddText(draw_list, textX, textY, 
                                      0xFFFFFFFF, text)
            end
            
            -- Deep red badge (bottom right) for text events
            if eventCount > 0 then
                local badgeSize = 22
                local badgeX = copyButtonX + 100 - badgeSize
                local badgeY = copyButtonY + 40 - badgeSize
                
                -- Draw deep red square
                ImGui.DrawList_AddRectFilled(draw_list, badgeX, badgeY, 
                                            badgeX + badgeSize, badgeY + badgeSize, 
                                            0x8B0000FF)
                
                -- Draw event count in white (centered)
                local text = tostring(eventCount)
                local textX = badgeX + (badgeSize / 2) - 5
                local textY = badgeY + 4
                ImGui.DrawList_AddText(draw_list, textX, textY, 
                                      0xFFFFFFFF, text)
            end
        end
        
        ImGui.PopStyleColor(ctx, 3)
        ImGui.SameLine(ctx)
        
        -- Paste button
        if ImGui.Button(ctx, 'Paste', 100, 40) then
            Buttons.PasteAtCursor()
        end
        ImGui.SameLine(ctx)
        
        -- Clear Markers button (wider)
        if ImGui.Button(ctx, 'Clear Markers', 212, 40) then
            Buttons.ClearMarkers()
        end
        
        -- Separator
        ImGui.Separator(ctx)
        ImGui.Spacing(ctx)
        ImGui.Text(ctx, 'Strum Maps (Bass Only)')
        
        -- Strum Map Buttons (PART_BASS only)
        if ImGui.Button(ctx, 'Fingers (Default)', 150, 40) then
            Buttons.StrumMap_Default()
        end
        
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, 'Pick', 150, 40) then
            Buttons.StrumMap_Pick()
        end
        
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, 'Slap', 150, 40) then
            Buttons.StrumMap_Slap()
        end
        
        -- Separator
        ImGui.Separator(ctx)
        ImGui.Spacing(ctx)
        ImGui.Text(ctx, 'Character Animations')
        
        -- Character Animation Buttons
        if ImGui.Button(ctx, 'Idle Realtime', 100, 40) then
            Buttons.CharAnim_IdleRealtime()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, 'Idle', 100, 40) then
            Buttons.CharAnim_Idle()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, 'Idle Intense', 100, 40) then
            Buttons.CharAnim_IdleIntense()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, 'Play', 100, 40) then
            Buttons.CharAnim_Play()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, 'Mellow', 100, 40) then
            Buttons.CharAnim_Mellow()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, 'Intense', 100, 40) then
            Buttons.CharAnim_Intense()
        end
        ImGui.SameLine(ctx)
        
        if ImGui.Button(ctx, 'Play Solo', 100, 40) then
            Buttons.CharAnim_PlaySolo()
        end
        
        ImGui.End(ctx)
    end
    
    -- Keep loop active while the window is open
    if open then
        reaper.defer(loop)
    end
end

-- Starting the loop
reaper.defer(loop)