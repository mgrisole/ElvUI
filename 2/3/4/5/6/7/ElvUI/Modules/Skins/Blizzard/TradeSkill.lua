local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins");

--Cache global variables
--Lua functions
local _G = getfenv()
local unpack = unpack
local select = select
local find = string.find
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradeSkillItemLink = GetTradeSkillItemLink
local GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
local GetTradeSkillReagentItemLink = GetTradeSkillReagentItemLink

local function LoadSkin()
	-- if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tradeskill ~= true then return end

	E:StripTextures(TradeSkillFrame, true)
	E:CreateBackdrop(TradeSkillFrame, "Transparent")
	TradeSkillFrame.backdrop:SetPoint("TOPLEFT", 10, -11)
	TradeSkillFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 74)

	E:StripTextures(TradeSkillRankFrameBorder)
	TradeSkillRankFrame:SetWidth(322)
	TradeSkillRankFrame:SetHeight(16)
	TradeSkillRankFrame:ClearAllPoints()
	TradeSkillRankFrame:SetPoint("TOP", -10, -45)
	E:CreateBackdrop(TradeSkillRankFrame)
	TradeSkillRankFrame:SetStatusBarTexture(E["media"].normTex)
	TradeSkillRankFrame:SetStatusBarColor(0.13, 0.35, 0.80)
	E:RegisterStatusBar(TradeSkillRankFrame)

	E:StripTextures(TradeSkillExpandButtonFrame)

	TradeSkillCollapseAllButton:SetNormalTexture("")
	TradeSkillCollapseAllButton.SetNormalTexture = E.noop
	TradeSkillCollapseAllButton:SetHighlightTexture("")
	TradeSkillCollapseAllButton.SetHighlightTexture = E.noop
	TradeSkillCollapseAllButton:SetDisabledTexture("")
	TradeSkillCollapseAllButton.SetDisabledTexture = E.noop

	TradeSkillCollapseAllButton.Text = TradeSkillCollapseAllButton:CreateFontString(nil, "OVERLAY")
	E:FontTemplate(TradeSkillCollapseAllButton.Text, nil, 22)
	TradeSkillCollapseAllButton.Text:SetPoint("LEFT", 3, 0)
	TradeSkillCollapseAllButton.Text:SetText("+")

	hooksecurefunc(TradeSkillCollapseAllButton, "SetNormalTexture", function(self, texture)
		if(find(texture, "MinusButton")) then
			self.Text:SetText("-")
		else
			self.Text:SetText("+")
		end
	end)

	S:HandleDropDownBox(TradeSkillInvSlotDropDown, 140)
	TradeSkillSubClassDropDown:ClearAllPoints()
	TradeSkillInvSlotDropDown:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -32, -68)

	S:HandleDropDownBox(TradeSkillSubClassDropDown, 140)
	TradeSkillSubClassDropDown:ClearAllPoints()
	TradeSkillSubClassDropDown:SetPoint("RIGHT", TradeSkillInvSlotDropDown, "RIGHT", -120, 0)

	TradeSkillFrameTitleText:ClearAllPoints()
	TradeSkillFrameTitleText:SetPoint("TOP", TradeSkillFrame, "TOP", 0, -18)

	for i = 1, TRADE_SKILLS_DISPLAYED do
		local skillButton = _G["TradeSkillSkill" .. i]
		skillButton:SetNormalTexture("")
		skillButton.SetNormalTexture = E.noop

		_G["TradeSkillSkill" .. i .. "Highlight"]:SetTexture("")
		_G["TradeSkillSkill" .. i .. "Highlight"].SetTexture = E.noop

		skillButton.Text = skillButton:CreateFontString(nil, "OVERLAY")
		E:FontTemplate(skillButton.Text, nil, 22)
		skillButton.Text:SetPoint("LEFT", 3, 0)
		skillButton.Text:SetText("+")

		hooksecurefunc(skillButton, "SetNormalTexture", function(self, texture)
			if texture == "Interface\\Buttons\\UI-MinusButton-Up" then
				self.Text:SetText("-")
			elseif texture == "Interface\\Buttons\\UI-PlusButton-Up" then
				self.Text:SetText("+")
			else
				self.Text:SetText("")
			end
		end)
	end

	E:StripTextures(TradeSkillDetailScrollFrame)
	E:StripTextures(TradeSkillListScrollFrame)
	E:StripTextures(TradeSkillDetailScrollChildFrame)

	S:HandleScrollBar(TradeSkillListScrollFrameScrollBar)
	S:HandleScrollBar(TradeSkillDetailScrollFrameScrollBar)

	E:StyleButton(TradeSkillSkillIcon, nil, true)
	E:SetTemplate(TradeSkillSkillIcon, "Default")

	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local reagent = _G["TradeSkillReagent" .. i]
		local icon = _G["TradeSkillReagent" .. i .. "IconTexture"]
		local count = _G["TradeSkillReagent" .. i .. "Count"]
		local nameFrame = _G["TradeSkillReagent" .. i .. "NameFrame"]

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer("OVERLAY")

		icon.backdrop = CreateFrame("Frame", nil, reagent)
		icon.backdrop:SetFrameLevel(reagent:GetFrameLevel() - 1)
		E:SetTemplate(icon.backdrop, "Default")
		E:SetOutside(icon.backdrop, icon)

		icon:SetParent(icon.backdrop)
		count:SetParent(icon.backdrop)
		count:SetDrawLayer("OVERLAY")

		E:Kill(nameFrame)
	end

	S:HandleButton(TradeSkillCancelButton)
	S:HandleButton(TradeSkillCreateButton)
	S:HandleButton(TradeSkillCreateAllButton)

	S:HandleNextPrevButton(TradeSkillDecrementButton)
	TradeSkillInputBox:SetHeight(16)
	S:HandleEditBox(TradeSkillInputBox)
	S:HandleNextPrevButton(TradeSkillIncrementButton)

	S:HandleCloseButton(TradeSkillFrameCloseButton)

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		if TradeSkillSkillIcon:GetNormalTexture() then
			TradeSkillSkillIcon:SetAlpha(1)
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			E:SetInside(TradeSkillSkillIcon:GetNormalTexture())
		else
			TradeSkillSkillIcon:SetAlpha(0)
		end

		local skillLink = GetTradeSkillItemLink(id)
		local skillID = select(3, strfind(skillLink, "item:(%d+)"))
		if skillLink then
			TradeSkillRequirementLabel:SetTextColor(1, 0.80, 0.10)
			local quality = select(3, GetItemInfo(skillID))

			if quality and quality > 1 then
				TradeSkillSkillIcon:SetBackdropBorderColor(GetItemQualityColor(quality))
				TradeSkillSkillName:SetTextColor(GetItemQualityColor(quality))
			else
				TradeSkillSkillIcon:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end

		local numReagents = GetTradeSkillNumReagents(id)
		for i = 1, numReagents, 1 do
			local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i)
			local reagentLink = GetTradeSkillReagentItemLink(id, i)
			local reagentID = select(3, strfind(reagentLink, "item:(%d+)"))
			local icon = _G["TradeSkillReagent" .. i .. "IconTexture"]
			local name = _G["TradeSkillReagent" .. i .. "Name"]

			if reagentLink then
				local quality = select(3, GetItemInfo(reagentID))
				if quality and quality > 1 then
					icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					if(playerReagentCount < reagentCount) then
						name:SetTextColor(0.5, 0.5, 0.5)
					else
						name:SetTextColor(GetItemQualityColor(quality))
					end
				else
					icon.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				end
			end
		end
	end)
end

S:AddCallbackForAddon("Blizzard_TradeSkillUI", "TradeSkill", LoadSkin)