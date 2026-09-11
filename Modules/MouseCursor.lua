local Private = select(2, ...)

function Private:SetupMouseCursor()
	if not Private.MouseCursorFrame then
		local MouseCursorFrame = CreateFrame("Frame", nil, UIParent)
		MouseCursorFrame.Anchor = CreateFrame("Frame", nil, UIParent)

		MouseCursorFrame.Texture = MouseCursorFrame:CreateTexture(nil, "OVERLAY")
		MouseCursorFrame.Texture:SetAllPoints()

		MouseCursorFrame.UpdatePosition = function(MouseCursorFrame)
			local MouseX, MouseY = GetCursorPosition()
			local UIScale = UIParent:GetEffectiveScale()
			MouseCursorFrame.Anchor:ClearAllPoints()
			MouseCursorFrame.Anchor:SetPoint("CENTER", UIParent, "BOTTOMLEFT", MouseX / UIScale, MouseY / UIScale)
			MouseCursorFrame:ClearAllPoints()
			local DB = Private.DB.global.MouseCursor
			if DB.Texture == "CURSOR_01" or DB.Texture == "CURSOR_02" then
				MouseCursorFrame:SetPoint("CENTER", MouseCursorFrame.Anchor, "CENTER", 13, -13)
			else
				MouseCursorFrame:SetPoint(DB.Layout[1], MouseCursorFrame.Anchor, DB.Layout[2], DB.Layout[3], DB.Layout[4])
			end
		end

		MouseCursorFrame:SetScript("OnEvent", function(MouseCursorFrame, Event) MouseCursorFrame:SetShown(Event == "PLAYER_REGEN_DISABLED") end)
		Private.MouseCursorFrame = MouseCursorFrame
	end

	Private:UpdateMouseCursor()
end

function Private:UpdateMouseCursor()
	local DB = Private.DB.global.MouseCursor
	local MouseCursorFrame = Private.MouseCursorFrame
	if not MouseCursorFrame then Private:SetupMouseCursor() return end
	local TexturePath = Private.MouseCursors.Path[DB.Texture]

	MouseCursorFrame:UnregisterAllEvents()
	MouseCursorFrame:SetScript("OnUpdate", nil)

	local AtlasCursor = DB.Texture == "CURSOR_01" or DB.Texture == "CURSOR_02"
	if AtlasCursor then
		MouseCursorFrame.Texture:SetAtlas(TexturePath)
		MouseCursorFrame.Texture:SetVertexColor(1, 1, 1, 1)
		MouseCursorFrame:SetSize(90, 90)
		MouseCursorFrame.Anchor:SetSize(90, 90)
	else
		MouseCursorFrame.Texture:SetTexture(TexturePath)
		MouseCursorFrame.Texture:SetTexCoord(0, 1, 0, 1)
		MouseCursorFrame.Texture:SetVertexColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])
		MouseCursorFrame:SetSize(DB.Layout[5], DB.Layout[6])
		MouseCursorFrame.Anchor:SetSize(DB.Layout[5], DB.Layout[6])
	end

	MouseCursorFrame:Hide()
	if not DB.Enabled then return end

	MouseCursorFrame:UpdatePosition()
	MouseCursorFrame:SetScript("OnUpdate", MouseCursorFrame.UpdatePosition)
	if DB.ShowInCombatOnly then
		MouseCursorFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		MouseCursorFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		MouseCursorFrame:SetShown(InCombatLockdown())
	else
		MouseCursorFrame:Show()
	end
end