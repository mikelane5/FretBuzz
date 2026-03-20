-- FretBuzz.lua: Main GUI Application
package.path = reaper.GetResourcePath() .. "\\Scripts\\FretBuzz\\?.lua;" .. reaper.ImGui_GetBuiltinPath() .. "/?.lua;" .. package.path

local ImGui = require 'imgui' '0.9.3'
local ctx = ImGui.CreateContext('FretBuzz')

-- Set path before each require as a workaround for ImGui resetting it
local fretbuzz_path = reaper.GetResourcePath() .. "\\Scripts\\FretBuzz\\?.lua;"

-- Clear any cached modules to force reload
package.loaded['Buttons'] = nil
package.loaded['HandmapData'] = nil
package.loaded['UIHelpers'] = nil
package.loaded['CopyPaste'] = nil
package.loaded['Tracks'] = nil

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
    -- Restore package path each loop iteration (ImGui may reset it)
    package.path = fretbuzz_path .. package.path
    
    ImGui.SetNextWindowSize(ctx, 765, 840, ImGui.Cond_FirstUseEver)
    local visible, open = ImGui.Begin(ctx, 'FretBuzz', true, ImGui.WindowFlags_NoDocking)
    
    if visible then
        ImGui.SeparatorText(ctx, 'Left Hand Fret Numbers')
        
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
        
        ImGui.Spacing(ctx)
        ImGui.SeparatorText(ctx, 'Copy/Paste (Timeline Selection)')
        ImGui.Spacing(ctx)
        
        -- Copy button
        local copyColor = CopyPaste.GetCopyButtonColor()
        local hasClipboardData = (#CopyPaste.clipboard.notes > 0 or #CopyPaste.clipboard.events > 0)
        
        -- Only apply custom color if clipboard has data (green), otherwise use default
        if hasClipboardData then
            ImGui.PushStyleColor(ctx, ImGui.Col_Button, copyColor)
            ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, copyColor)
            ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive, copyColor)
        end
        
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
                
                ImGui.DrawList_AddRectFilled(draw_list, badgeX, badgeY, 
                                            badgeX + badgeSize, badgeY + badgeSize, 
                                            0xFF8000FF)
                
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
                
                ImGui.DrawList_AddRectFilled(draw_list, badgeX, badgeY, 
                                            badgeX + badgeSize, badgeY + badgeSize, 
                                            0x8B0000FF)
                
                local text = tostring(eventCount)
                local textX = badgeX + (badgeSize / 2) - 5
                local textY = badgeY + 4
                ImGui.DrawList_AddText(draw_list, textX, textY, 
                                      0xFFFFFFFF, text)
            end
        end
        
        if hasClipboardData then
            ImGui.PopStyleColor(ctx, 3)
        end
        
        ImGui.SameLine(ctx)
        
        -- Paste button
        if ImGui.Button(ctx, 'Paste', 100, 40) then
            Buttons.PasteAtCursor()
        end
        
        ImGui.Spacing(ctx)
        ImGui.SeparatorText(ctx, 'Strum Maps (Bass Only)')
        
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
        
        ImGui.Spacing(ctx)
        ImGui.SeparatorText(ctx, 'Character Animations')
        
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
        
        ImGui.Spacing(ctx)
        ImGui.SeparatorText(ctx, 'YARG Range Shift Text Events')
        ImGui.Spacing(ctx)
        
        -- Easy row
        local labelW, labelH = 100, 40
        
        -- "Easy" label: transparent background, centered text
        local labelX, labelY = ImGui.GetCursorScreenPos(ctx)
        local easyTextW = ImGui.CalcTextSize(ctx, 'Easy')
        local easyDL = ImGui.GetWindowDrawList(ctx)
        ImGui.DrawList_AddText(easyDL, labelX + (labelW - easyTextW) / 2, labelY + (labelH - 13) / 2, 0xFFFFFFFF, 'Easy')
        ImGui.Dummy(ctx, labelW, labelH)
        ImGui.SameLine(ctx)
        
        -- Three colored squares as a single button, overdrawn with colored rects
        local squareSize = 40
        local btnW = squareSize * 3
        
        ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, 0)
        ImGui.PushStyleColor(ctx, ImGui.Col_Button,        0x00000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, 0x00000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,  0x00000000)
        
        local btnX, btnY = ImGui.GetCursorScreenPos(ctx)
        ImGui.Button(ctx, '##yarg_easy_gry', btnW, squareSize)
        local isHovered = ImGui.IsItemHovered(ctx)
        local isActive  = ImGui.IsItemActive(ctx)
        local clicked   = ImGui.IsItemClicked(ctx)
        
        ImGui.PopStyleColor(ctx, 3)
        ImGui.PopStyleVar(ctx)
        
        -- Pick colors based on interaction state
        local green, red, yellow
        if isActive then
            green  = 0x009900FF
            red    = 0x990000FF
            yellow = 0x999900FF
        elseif isHovered then
            green  = 0x00FF00FF
            red    = 0xFF0000FF
            yellow = 0xFFFF00FF
        else
            green  = 0x00BF00FF
            red    = 0xBF0000FF
            yellow = 0xBFBF00FF
        end
        
        -- Overdraw the button area with colored rects
        local draw_list = ImGui.GetWindowDrawList(ctx)
        ImGui.DrawList_AddRectFilled(draw_list, btnX,                  btnY, btnX + squareSize,     btnY + squareSize, green)
        ImGui.DrawList_AddRectFilled(draw_list, btnX + squareSize,     btnY, btnX + squareSize * 2, btnY + squareSize, red)
        ImGui.DrawList_AddRectFilled(draw_list, btnX + squareSize * 2, btnY, btnX + squareSize * 3, btnY + squareSize, yellow)
        
        if clicked then
            Buttons.HandmapButton("[ld_range_shift 0 1]")
        end
        
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 80, 0)
        ImGui.SameLine(ctx)
        
        -- Button 2: red, yellow, blue
        ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, 0)
        ImGui.PushStyleColor(ctx, ImGui.Col_Button,        0x00000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, 0x00000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,  0x00000000)
        
        local btn2X, btn2Y = ImGui.GetCursorScreenPos(ctx)
        ImGui.Button(ctx, '##yarg_easy_ryb', btnW, squareSize)
        local isHovered2 = ImGui.IsItemHovered(ctx)
        local isActive2  = ImGui.IsItemActive(ctx)
        local clicked2   = ImGui.IsItemClicked(ctx)
        
        ImGui.PopStyleColor(ctx, 3)
        ImGui.PopStyleVar(ctx)
        
        local red2, yellow2, blue2
        if isActive2 then
            red2    = 0x990000FF
            yellow2 = 0x999900FF
            blue2   = 0x000099FF
        elseif isHovered2 then
            red2    = 0xFF0000FF
            yellow2 = 0xFFFF00FF
            blue2   = 0x0000FFFF
        else
            red2    = 0xBF0000FF
            yellow2 = 0xBFBF00FF
            blue2   = 0x0000BFFF
        end
        
        local draw_list2 = ImGui.GetWindowDrawList(ctx)
        ImGui.DrawList_AddRectFilled(draw_list2, btn2X,                  btn2Y, btn2X + squareSize,     btn2Y + squareSize, red2)
        ImGui.DrawList_AddRectFilled(draw_list2, btn2X + squareSize,     btn2Y, btn2X + squareSize * 2, btn2Y + squareSize, yellow2)
        ImGui.DrawList_AddRectFilled(draw_list2, btn2X + squareSize * 2, btn2Y, btn2X + squareSize * 3, btn2Y + squareSize, blue2)
        
        if clicked2 then
            Buttons.HandmapButton("[ld_range_shift 0 2]")
        end
        
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 80, 0)
        ImGui.SameLine(ctx)
        
        -- Button 3: yellow, blue, orange
        ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, 0)
        ImGui.PushStyleColor(ctx, ImGui.Col_Button,        0x00000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, 0x00000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,  0x00000000)
        
        local btn3X, btn3Y = ImGui.GetCursorScreenPos(ctx)
        ImGui.Button(ctx, '##yarg_easy_ybo', btnW, squareSize)
        local isHovered3 = ImGui.IsItemHovered(ctx)
        local isActive3  = ImGui.IsItemActive(ctx)
        local clicked3   = ImGui.IsItemClicked(ctx)
        
        ImGui.PopStyleColor(ctx, 3)
        ImGui.PopStyleVar(ctx)
        
        local yellow3, blue3, orange3
        if isActive3 then
            yellow3 = 0x999900FF
            blue3   = 0x000099FF
            orange3 = 0x996600FF
        elseif isHovered3 then
            yellow3 = 0xFFFF00FF
            blue3   = 0x0000FFFF
            orange3 = 0xFF9900FF
        else
            yellow3 = 0xBFBF00FF
            blue3   = 0x0000BFFF
            orange3 = 0xBF7300FF
        end
        
        local draw_list3 = ImGui.GetWindowDrawList(ctx)
        ImGui.DrawList_AddRectFilled(draw_list3, btn3X,                  btn3Y, btn3X + squareSize,     btn3Y + squareSize, yellow3)
        ImGui.DrawList_AddRectFilled(draw_list3, btn3X + squareSize,     btn3Y, btn3X + squareSize * 2, btn3Y + squareSize, blue3)
        ImGui.DrawList_AddRectFilled(draw_list3, btn3X + squareSize * 2, btn3Y, btn3X + squareSize * 3, btn3Y + squareSize, orange3)
        
        if clicked3 then
            Buttons.HandmapButton("[ld_range_shift 0 3]")
        end
        
        -- Medium row
        ImGui.Spacing(ctx)
        local medLabelW, medLabelH = 100, 40
        local medSquareSize = 40
        local medBtnW = medSquareSize * 4
        
        local medLabelX, medLabelY = ImGui.GetCursorScreenPos(ctx)
        local medTextW = ImGui.CalcTextSize(ctx, 'Medium')
        local medDL = ImGui.GetWindowDrawList(ctx)
        ImGui.DrawList_AddText(medDL, medLabelX + (medLabelW - medTextW) / 2, medLabelY + (medLabelH - 13) / 2, 0xFFFFFFFF, 'Medium')
        ImGui.Dummy(ctx, medLabelW, medLabelH)
        ImGui.SameLine(ctx)
        
        -- Medium Button 1: G R Y B
        ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, 0)
        ImGui.PushStyleColor(ctx, ImGui.Col_Button,        0x00000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, 0x00000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,  0x00000000)
        
        local medBtn1X, medBtn1Y = ImGui.GetCursorScreenPos(ctx)
        ImGui.Button(ctx, '##yarg_med_gryb', medBtnW, medSquareSize)
        local medHovered1 = ImGui.IsItemHovered(ctx)
        local medActive1  = ImGui.IsItemActive(ctx)
        local medClicked1 = ImGui.IsItemClicked(ctx)
        
        ImGui.PopStyleColor(ctx, 3)
        ImGui.PopStyleVar(ctx)
        
        local mGreen1, mRed1, mYellow1, mBlue1
        if medActive1 then
            mGreen1  = 0x009900FF
            mRed1    = 0x990000FF
            mYellow1 = 0x999900FF
            mBlue1   = 0x000099FF
        elseif medHovered1 then
            mGreen1  = 0x00FF00FF
            mRed1    = 0xFF0000FF
            mYellow1 = 0xFFFF00FF
            mBlue1   = 0x0000FFFF
        else
            mGreen1  = 0x00BF00FF
            mRed1    = 0xBF0000FF
            mYellow1 = 0xBFBF00FF
            mBlue1   = 0x0000BFFF
        end
        
        local medDL1 = ImGui.GetWindowDrawList(ctx)
        ImGui.DrawList_AddRectFilled(medDL1, medBtn1X,                    medBtn1Y, medBtn1X + medSquareSize,     medBtn1Y + medSquareSize, mGreen1)
        ImGui.DrawList_AddRectFilled(medDL1, medBtn1X + medSquareSize,    medBtn1Y, medBtn1X + medSquareSize * 2, medBtn1Y + medSquareSize, mRed1)
        ImGui.DrawList_AddRectFilled(medDL1, medBtn1X + medSquareSize * 2, medBtn1Y, medBtn1X + medSquareSize * 3, medBtn1Y + medSquareSize, mYellow1)
        ImGui.DrawList_AddRectFilled(medDL1, medBtn1X + medSquareSize * 3, medBtn1Y, medBtn1X + medSquareSize * 4, medBtn1Y + medSquareSize, mBlue1)
        
        if medClicked1 then
            Buttons.HandmapButton("[ld_range_shift 1 1]")
        end
        
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 40, 0)
        ImGui.SameLine(ctx)
        
        -- Medium Button 2: R Y B O
        ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding, 0)
        ImGui.PushStyleColor(ctx, ImGui.Col_Button,        0x00000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, 0x00000000)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,  0x00000000)
        
        local medBtn2X, medBtn2Y = ImGui.GetCursorScreenPos(ctx)
        ImGui.Button(ctx, '##yarg_med_rybo', medBtnW, medSquareSize)
        local medHovered2 = ImGui.IsItemHovered(ctx)
        local medActive2  = ImGui.IsItemActive(ctx)
        local medClicked2 = ImGui.IsItemClicked(ctx)
        
        ImGui.PopStyleColor(ctx, 3)
        ImGui.PopStyleVar(ctx)
        
        local mRed2, mYellow2, mBlue2, mOrange2
        if medActive2 then
            mRed2    = 0x990000FF
            mYellow2 = 0x999900FF
            mBlue2   = 0x000099FF
            mOrange2 = 0x996600FF
        elseif medHovered2 then
            mRed2    = 0xFF0000FF
            mYellow2 = 0xFFFF00FF
            mBlue2   = 0x0000FFFF
            mOrange2 = 0xFF9900FF
        else
            mRed2    = 0xBF0000FF
            mYellow2 = 0xBFBF00FF
            mBlue2   = 0x0000BFFF
            mOrange2 = 0xBF7300FF
        end
        
        local medDL2 = ImGui.GetWindowDrawList(ctx)
        ImGui.DrawList_AddRectFilled(medDL2, medBtn2X,                    medBtn2Y, medBtn2X + medSquareSize,     medBtn2Y + medSquareSize, mRed2)
        ImGui.DrawList_AddRectFilled(medDL2, medBtn2X + medSquareSize,    medBtn2Y, medBtn2X + medSquareSize * 2, medBtn2Y + medSquareSize, mYellow2)
        ImGui.DrawList_AddRectFilled(medDL2, medBtn2X + medSquareSize * 2, medBtn2Y, medBtn2X + medSquareSize * 3, medBtn2Y + medSquareSize, mBlue2)
        ImGui.DrawList_AddRectFilled(medDL2, medBtn2X + medSquareSize * 3, medBtn2Y, medBtn2X + medSquareSize * 4, medBtn2Y + medSquareSize, mOrange2)
        
        if medClicked2 then
            Buttons.HandmapButton("[ld_range_shift 1 2]")
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