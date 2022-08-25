local dialogs = require("dialogs")
local class = require("class")

local TechCreditsController = class()

function TechCreditsController:init()
end

function TechCreditsController:initialize(document)
    self.document = document
    self.elements = {}
    self.section = 1

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		local fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end

    --[[ui.CampaignMenu.loadCampaignList();

    local names, fileNames, descriptions = ui.CampaignMenu.getCampaignList()

    local currentCampaignFile = ba.getCurrentPlayer():getCampaignFilename()
    local selectedCampaign = nil

    self.names = names
    self.descriptions = {}
    self.fileNames = {}
    for i, v in ipairs(names) do
        self.descriptions[v] = descriptions[i]
        self.fileNames[v] = fileNames[i]

        if fileNames[i] == currentCampaignFile then
            selectedCampaign = v
        end
    end

    self:init_campaign_list()

    -- Initialize selection
    self:selectCampaign(selectedCampaign)]]--
	
	self.document:GetElementById("data_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("mission_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("cutscene_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("credits_btn"):SetPseudoClass("checked", true)
	
end

function TechCreditsController:ChangeSection(section)

	if section == 1 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_TECH_MENU"])
	end
	if section == 2 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_SIMULATOR_ROOM"])
	end
	if section == 3 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_GOTO_VIEW_CUTSCENES_SCREEN"])
	end
	if section == 4 then
		--ba.postGameEvent(ba.GameEvents["GS_EVENT_CREDITS"])
	end
	
end

function TechCreditsController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

function TechCreditsController:selectCampaign(campaign)
    if self.selection == campaign then
        -- No changes
        return
    end

    if self.selection ~= nil and self.elements[self.selection] ~= nil then
        self.elements[self.selection]:SetPseudoClass("checked", false)
    end

    self.selection = campaign

    local desc_el = self.document:GetElementById("desc_text")
    if self.selection ~= nil then
        desc_el.inner_rml = self.descriptions[campaign]
    else
        desc_el.inner_rml = ""
    end

    if self.selection ~= nil and self.elements[self.selection] ~= nil then
        self.elements[self.selection]:SetPseudoClass("checked", true)
        self.elements[self.selection]:ScrollIntoView()
    end
end

function TechCreditsController:create_pilot_li(campaign)
    local li_el = self.document:CreateElement("li")

    li_el.inner_rml = campaign
    li_el:SetClass("campaignlist_element", true)
    li_el:AddEventListener("click", function(_, _, _)
        self:selectCampaign(campaign)
    end)

    self.elements[campaign] = li_el

    return li_el
end

function TechCreditsController:init_campaign_list()
    local campaign_list_el = self.document:GetElementById("campaignlist_ul")
    for _, v in ipairs(self.names) do
        -- Add all the elements
        campaign_list_el:AppendChild(self:create_pilot_li(v))
    end
end

function TechCreditsController:commit_pressed(element)
    if self.selection == nil then
        ui.playElementSound(element, "click", "error")
        return
    end
    assert(self.fileNames[self.selection] ~= nil)

    ui.CampaignMenu.selectCampaign(self.fileNames[self.selection])

    ui.playElementSound(element, "click", "success")
    ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
end

function TechCreditsController:restart_pressed(element)
    if self.selection == nil then
        ui.playElementSound(element, "click", "error")
        return
    end
    assert(self.fileNames[self.selection] ~= nil)

    local builder = dialogs.new()
    builder:title(ba.XSTR("Warning", -1));
    builder:text(ba.XSTR("This will cause all progress in your\nCurrent campaign to be lost", -1))
    builder:button(dialogs.BUTTON_TYPE_POSITIVE, ba.XSTR("Ok", -1), true)
    builder:button(dialogs.BUTTON_TYPE_NEGATIVE, ba.XSTR("Cancel", -1), false)
    builder:show(self.document.context):continueWith(function(accepted)
        if not accepted then
            ui.playElementSound(element, "click", "error")
            return
        end

        ui.CampaignMenu.resetCampaign(self.fileNames[self.selection])

        ba.savePlayer(ba.getCurrentPlayer())
        ui.playElementSound(element, "click", "success")
    end)
end

return TechCreditsController
