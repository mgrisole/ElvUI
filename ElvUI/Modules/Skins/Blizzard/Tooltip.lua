local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins");
local TT = E:GetModule("Tooltip");

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tooltip ~= true then return end

	S:HandleCloseButton(ItemRefCloseButton)

	local GameTooltip = _G["GameTooltip"]
	local GameTooltipStatusBar =  _G["GameTooltipStatusBar"]
	local tooltips = {
		GameTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ItemRefShoppingTooltip3,
		AutoCompleteBox,
		FriendsTooltip,
		ConsolidatedBuffsTooltip,
		ShoppingTooltip1,
		ShoppingTooltip2,
		ShoppingTooltip3,
		WorldMapTooltip,
		WorldMapCompareTooltip1,
		WorldMapCompareTooltip2,
		WorldMapCompareTooltip3
	}
	for _, tt in pairs(tooltips) do
		TT:SecureHookScript(tt, "OnShow", "SetStyle")
	end

	GameTooltipStatusBar:SetStatusBarTexture(E["media"].normTex)
	E:RegisterStatusBar(GameTooltipStatusBar)
	E:CreateBackdrop(GameTooltipStatusBar, "Transparent")
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
	GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))

	TT:SecureHookScript(GameTooltip, "OnSizeChanged", "CheckBackdropColor")
	TT:SecureHookScript(GameTooltip, "OnUpdate", "CheckBackdropColor")
	TT:RegisterEvent("CURSOR_UPDATE", "CheckBackdropColor")
end

S:AddCallback("SkinTooltip", LoadSkin)