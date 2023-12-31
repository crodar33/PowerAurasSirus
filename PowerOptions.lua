-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< MAIN OPTIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- ---------------------------------------------------------------------------------------------------------------------

function PowaAuras:ResetPositions()
	PowaBarConfigFrame:ClearAllPoints();
	PowaBarConfigFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 50);
	PowaOptionsFrame:ClearAllPoints();
	PowaOptionsFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 50);
end

-- ---------------------------------------------------------------------------------------------------------------------
function PowaAuras:UpdateMainOption()
	PowaOptionsHeader:SetText("POWER AURAS "..self.Version);
	PowaMainHideAllButton:SetText(self.Text.nomHide);
	PowaMainTestButton:SetText(self.Text.nomTest);
	PowaEditButton:SetText(self.Text.nomEdit);
	PowaOptionsRename:SetText(self.Text.nomRename);
	--self:ShowText("Setting Enabled button to: ", PowaMisc.Disabled~=true);
	PowaEnableButton:SetChecked(PowaMisc.Disabled~=true);
	PowaDebugButton:SetChecked(PowaMisc.debug==true);
	PowaTimerRoundingButton:SetChecked(PowaMisc.TimerRoundUp==true);

	-- affiche les icones
	for i = 1, 24 do
		local k = ((self.MainOptionPage-1)*24) + i;
		--self:Message("icon ", k);
		local aura = self.Auras[k];
		-- icone
		if (aura == nil) then
			getglobal("PowaIcone"..i):SetNormalTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot");
			getglobal("PowaIcone"..i):SetText("");
			getglobal("PowaIcone"..i):SetAlpha(0.33);
		else
			--self:Message("buffname ", aura.buffname, "icon", aura.icon);
			if (aura.buffname == "" or aura.buffname == " ") then -- pas de nom -> desactive
				getglobal("PowaIcone"..i):SetNormalTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot");
			elseif (aura.icon == "") then -- active mais pas d'icone
				getglobal("PowaIcone"..i):SetNormalTexture("Interface\\Icons\\Inv_Misc_QuestionMark");
			else
				getglobal("PowaIcone"..i):SetNormalTexture(aura.icon);	
			end	
			-- off ou ON
			if (aura.buffname ~= "" and aura.buffname ~= " " and aura.off) then
				getglobal("PowaIcone"..i):SetText("OFF");
			else
				getglobal("PowaIcone"..i):SetText("");
			end
			-- surbrillance de l'effet en cours
			if (self.CurrentAuraId == k) then -- le bouton en cours
				if (aura == nil or aura.buffname == "" or aura.buffname == " ") then -- nulle
					getglobal("PowaSelected"):Hide();
				else
					getglobal("PowaSelected"):SetPoint("CENTER", "PowaIcone"..i, "CENTER");
					getglobal("PowaSelected"):Show();
				end
			end
			-- grisage des effets non visibles
			if (not aura.Showing) then
				getglobal("PowaIcone"..i):SetAlpha(0.33);
			else
				getglobal("PowaIcone"..i):SetAlpha(1.0);
			end
		end
	end
	-- choisi la liste en cours
	getglobal("PowaOptionsList"..self.MainOptionPage):SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight");
	getglobal("PowaOptionsList"..self.MainOptionPage):LockHighlight();
end

-- ---------------------------------------------------------------------------------------------------------------------
function PowaAuras:IconeClick(owner, button)
	local iconeID = owner:GetID();
	local auraId = ((self.MainOptionPage-1)*24) + iconeID;

	if (self.MoveEffect > 0) then -- mode move, annule
		return;
	end
	if (ColorPickerFrame:IsVisible()) then -- color picker visible, ca deconne
		return;
	end
	local aura = self.Auras[auraId];
	if (self.Auras[auraId] == nil or aura.buffname == "" or aura.buffname == " ") then -- ne fait rien si bouton vide
		return;
	end
	if IsShiftKeyDown() then -- Toggle ON ou OFF
		if (aura.off) then
			aura.off = false;
			getglobal("PowaIcone"..iconeID):SetText("");
		else
			aura.off = true;
			getglobal("PowaIcone"..iconeID):SetText("OFF");
		end
	elseif IsControlKeyDown() then
		local show, reason = self:TestThisEffect(auraId, true);
		if (show) then
			self:Message(self:InsertText(self.Text.nomReasonShouldShow, reason)); --OK
		else	
			self:Message(self:InsertText(self.Text.nomReasonWontShow, reason)); --OK
		end
	elseif (self.CurrentAuraId == auraId) then
		if (button == "RightButton") then
			self:EditorShow();
			return;
		else
			if (aura.Showing) then 
				getglobal("PowaIcone"..iconeID):SetAlpha(0.33);
			else
				getglobal("PowaIcone"..iconeID):SetAlpha(1.0);
			end
			PowaAuras:OptionTest();
		end
	elseif (self.CurrentAuraId ~= auraId) then -- clicked a different button
		self.CurrentAuraId = auraId;
		self.CurrentAuraPage = self.MainOptionPage;
		getglobal("PowaSelected"):SetPoint("CENTER", owner, "CENTER");
		getglobal("PowaSelected"):Show();
		self:InitPage(); -- change de page dans l'editeur d'effet
	end
end

function PowaAuras:IconeEntered(owner)
	local iconeID = owner:GetID();
	local k = ((self.MainOptionPage-1)*24) + iconeID;
	local aura = self.Auras[k];
	if (self.MoveEffect > 0) then -- mode move, annule
		return;
	elseif (aura == nil) then
		-- rien si pas actif
	elseif (aura.buffname == "" or aura.buffname == " ") then
		-- rien si pas de nom
	else
		GameTooltip:SetOwner(owner, "ANCHOR_RIGHT");
		aura:AddExtraTooltipInfo(GameTooltip);
		
		if (aura.party) then
			GameTooltip:AddLine("("..self.Text.nomCheckParty..")", 1.0, 0.2, 0.2, 1);
		end		
		if (aura.exact) then
			GameTooltip:AddLine("("..self.Text.nomExact..")", 1.0, 0.2, 0.2, 1);
		end	
		if (aura.mine) then
			GameTooltip:AddLine("("..self.Text.nomMine..")", 1.0, 0.2, 0.2, 1);
		end
		if (aura.focus) then
			GameTooltip:AddLine("("..self.Text.nomCheckFocus..")", 1.0, 0.2, 0.2, 1);
		end
		if (aura.raid) then
			GameTooltip:AddLine("("..self.Text.nomCheckRaid..")", 1.0, 0.2, 0.2, 1);
	    end
		if (aura.groupOrSelf) then
			GameTooltip:AddLine("("..self.Text.nomCheckGroupOrSelf..")", 1.0, 0.2, 0.2, 1);
		end
		if (aura.optunitn) then
			GameTooltip:AddLine("("..self.Text.nomCheckOptunitn..")", 1.0, 0.2, 0.2, 1);
		end
		if (aura.target) then
			GameTooltip:AddLine("("..self.Text.nomCheckTarget..")", 1.0, 0.2, 0.2, 1);
		end
		if (aura.targetfriend) then
			GameTooltip:AddLine("("..self.Text.nomCheckFriend..")", 0.2, 1.0, 0.2, 1);
		end
		GameTooltip:AddLine(self.Text.aideEffectTooltip,1.0,1.0,1.0,1);
		GameTooltip:AddLine(self.Text.aideEffectTooltip2,1.0,1.0,1.0,1);

		GameTooltip:Show();
	end
end

function PowaAuras:MainListClick(owner)
	local listeID = owner:GetID();

	if (self.MoveEffect == 1) then
		-- deplace l'effet
		self:BeginCopyEffect(self.CurrentAuraId, listeID)
		return;
	elseif (self.MoveEffect == 2) then
		-- deplace l'effet
		self:BeginMoveEffect(self.CurrentAuraId, listeID)
		return;
	end
	
	if IsShiftKeyDown() then -- Toggle ON ou OFF
		local min = ((listeID-1)*24) + 1;
		local max = min + 23;

		local allEnabled = true;
		local offText = "OFF";
		for i = min, max do
			local aura = self.Auras[i];
			if (aura and aura.off) then
				allEnabled = false;
				offText = "";
				break;
			end
		end
		
		for i = min, max do
			--self:ShowText("Toggle aura ", i);
			local aura = self.Auras[i];
			if (aura) then
				local auraIcon = getglobal("PowaIcone"..(i - min + 1));
				aura.off = allEnabled;
				auraIcon:SetText(offText);
			end
			self.SecondaryAuras[i] = nil;
		end
		
		self.DoCheck.All = true;
		return;
	end
	
	getglobal("PowaOptionsList"..self.MainOptionPage):SetHighlightTexture("");
	getglobal("PowaOptionsList"..self.MainOptionPage):UnlockHighlight();
	getglobal("PowaSelected"):Hide();
	self.MainOptionPage = listeID;

	-- selectionne le premier effet de la page
	self.CurrentAuraId = ((self.MainOptionPage-1)*24)+1;
	self.CurrentAuraPage = self.MainOptionPage;
	-- change de page dans l'editeur d'effet ou cache l'editeur
	if (self.Auras[auraId] ~= nil and self.Auras[self.CurrentAuraId].buffname ~= "" and self.Auras[ self.CurrentAuraId].buffname ~= " ") then
		self:InitPage(); 
	else
		self:EditorClose();
	end

	-- set text for rename
	--local pageButton = "PowaOptionsList"..self.MainOptionPage;
	--self:ShowText(pageButton, getglobal(pageButton));
	local currentText = getglobal("PowaOptionsList"..self.MainOptionPage):GetText();
	if (currentText==nil) then currentText = "" end;
	getglobal("PowaOptionsRenameEditBox"):SetText( currentText );

	self:UpdateMainOption();
end

function PowaAuras:MainListEntered(owner)
	local listeID = owner:GetID();

	if (self.MainOptionPage ~= listeID) then
		if (self.MoveEffect > 0) then
			getglobal("PowaOptionsList"..listeID):SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight"); 
		else
			getglobal("PowaOptionsList"..listeID):SetHighlightTexture("");
			getglobal("PowaOptionsList"..listeID):UnlockHighlight();
		end
	end
	if (self.MoveEffect == 1) then
		GameTooltip:SetOwner(owner, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.Text.aideCopy, nil, nil, nil, nil, 1);
		GameTooltip:Show();
	elseif (self.MoveEffect == 2) then
		GameTooltip:SetOwner(owner, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.Text.aideMove, nil, nil, nil, nil, 1);
		GameTooltip:Show();
	end
end
-- ---------------------------------------------------------------------------------------------------------------------
function PowaAuras:OptionRename()
	getglobal("PowaOptionsRename"):Hide();
	getglobal("PowaOptionsRenameEditBox"):Show();

	local currentText = getglobal("PowaOptionsList"..self.MainOptionPage):GetText();
	if (currentText==nil) then currentText = "" end;
	getglobal("PowaOptionsRenameEditBox"):SetText( currentText );
end

function PowaAuras:OptionRenameEdited()
	getglobal("PowaOptionsRename"):Show();
	getglobal("PowaOptionsRenameEditBox"):Hide();

	getglobal("PowaOptionsList"..self.MainOptionPage):SetText( getglobal("PowaOptionsRenameEditBox"):GetText() );
	if (self.MainOptionPage > 5) then
		PowaGlobalListe[self.MainOptionPage-5] = getglobal("PowaOptionsRenameEditBox"):GetText();
	else
		PowaPlayerListe[self.MainOptionPage] = getglobal("PowaOptionsRenameEditBox"):GetText();
	end
end
-- ---------------------------------------------------------------------------------------------------------------------
function PowaAuras:TriageIcones(nPage)
	  local min = ((nPage-1)*24) + 1;
	  local max = min + 23;


	-- masque les effets de la page
	for i = min, max do
		local aura = self.Auras[i];
		if (aura) then
			aura:Hide();
		end
		self.SecondaryAuras[i] = nil;
	end

	local a = min;
	for i = min, max do
		if (self.Auras[i]) then
			if (i~=a) then
				self:ReindexAura(i, a);
			end
			if (i>a) then
				self.Auras[i] = nil;
			end
			a = a + 1;
		end
	end
	-- gere les liens vers les effets globaux
	for i = 121, 360 do
		if (self.Auras[i]) then 
			PowaGlobalSet[i] = self.Auras[i]; 
		else
			PowaGlobalSet[i] = nil;
		end
	end
end

function PowaAuras:ReindexAura(oldId, newId)
	self.Auras[newId] = self.Auras[oldId];
	self.Auras[newId].id = newId;
	if (self.Auras[newId].Timer) then
		self.Auras[newId].Timer.id = newId;
	end
	if (self.Auras[newId].Stacks) then
		self.Auras[newId].Stacks.id = newId;
	end
	for i = 1, 360 do
		local aura = self.Auras[i];
		if (aura) then 
			if (aura.multiids and aura.multiids~="") then
				local newMultiids = "";
				local sep = "";
				for multiId in string.gmatch(aura.multiids, "[^/]+") do
					if (tonumber(multiId)==oldId) then
						newMultiids = newMultiids .. sep .. tostring(newId);
					else
						newMultiids = newMultiids .. sep .. multiId;
					end
					sep = "/";
				end
				aura.multiids = newMultiids;
			end
		end
	end
end

function PowaAuras:DeleteAura(aura)
	if (aura.Timer) then aura.Timer:Delete(); end
	if (aura.Stacks) then aura.Stacks:Delete(); end
	
	self.Frames[aura.id] = nil;
	self.Textures[aura.id] = nil;
	self.SecondaryAuras[aura.id] = nil;
	self.SecondaryFrames[aura.id] = nil;
	self.SecondaryTextures[aura.id] = nil;

	self.Auras[aura.id] = nil;
	if (aura.id > 120) then
		PowaGlobalSet[aura.id] = nil;
	end

end

function PowaAuras:OptionDeleteEffect(auraId)

	if (not IsControlKeyDown()) then return; end

	local aura = self.Auras[auraId];
	if (not aura) then return; end
	
	aura:Hide();
	self:DeleteAura(aura);

	getglobal("PowaSelected"):Hide();

	if (getglobal("PowaBarConfigFrame"):IsVisible()) then
		getglobal("PowaBarConfigFrame"):Hide();
	end

	self:TriageIcones(self.MainOptionPage);
	self:UpdateMainOption();
end

function PowaAuras:GetNextFreeSlot(page)
	if (page==nil) then
		page = self.MainOptionPage;
	end
	local min = ((page-1)*24) + 1;
	local max = min + 23;

	for i = min, max do
		if (self.Auras[i] == nil or self.Auras[i].buffname == "" or self.Auras[i].buffname == " ") then -- Found a free slot		
			return i;
		end
	end
	return nil;
end

function PowaAuras:OptionNewEffect()

	local i = self:GetNextFreeSlot();
	if (not i) then
		self:Message("All aura slots filled"); --OK
		return;
	end
                   
	--self:Message("New Effect slot=", i)
	self.CurrentAuraId = i;
	self.CurrentAuraPage = self.MainOptionPage;
	local aura = self:AuraFactory(PowaAuras.BuffTypes.Buff, i, {buffname = "???", off = false});
	--self:Message("Timer.enabled=", aura.Timer.enabled)
	self.Auras[i] = aura;
	self.Showing = true;
	-- effet global ?
	if (i > 120) then
		PowaGlobalSet[i] = aura;
	end
	self:DisplayAura(i);
	self:UpdateMainOption();
	self:InitPage();
	self:UpdateTimerOptions();
	if (not getglobal("PowaBarConfigFrame"):IsVisible()) then
		getglobal("PowaBarConfigFrame"):Show();
		PlaySound("TalentScreenOpen");
	end
	--self:Debug("New aura ", i);
	--aura:Display();

end


function PowaAuras:ExtractImportValue(valueType, value)
	if valueType == "st" then
		return value;
	elseif valueType == "bo" then
		if value == "false" then
			return false;
		elseif value == "true" then
			return true;
		end
	elseif valueType == "nu" then
		return tonumber(value);
	end
	return nil;
end

function PowaAuras:ImportAura(aurastring, auraId, offset)

	--self:Message("Import ", auraId);
	--self:Message(aurastring);

	local aura = cPowaAura(auraId);

	local aurastring = string.gsub(aurastring,";%s*",";");
	local temptbl = {strsplit(";", aurastring)};
	local importAuraSettings = {};
	local importTimerSettings = {};
	local importStacksSettings = {};
	local hasTimerSettings = false;
	local hasStacksSettings = false;

	for i, val in ipairs(temptbl) do
		local key, var = strsplit(":", val);
		local varpref = string.sub(var,1,2);
		var = string.sub(var,3);
		if (string.sub(key,1,6) == "timer.") then
			importTimerSettings[key] = self:ExtractImportValue(varpref, var);
			hasTimerSettings = true;
		elseif (string.sub(key,1,7) == "stacks.") then
			importStacksSettings[key] = self:ExtractImportValue(varpref, var);
			hasStacksSettings = true;
		else
		    importAuraSettings[key] = self:ExtractImportValue(varpref, var);
		end
 	end
	
	for k, v in pairs(aura) do
		local varType = type(v);
		if (k=="combat") then
			if (importAuraSettings[k]==0) then
				aura[k] = 0;
			elseif (importAuraSettings[k]==1) then
				aura[k] = true;
			elseif (importAuraSettings[k]==2) then
				aura[k] = false;
			else
				aura[k] = importAuraSettings[k];
			end
		elseif (k=="isResting") then
			if (importAuraSettings.ignoreResting==true) then
				aura[k] = true;
			elseif (importAuraSettings.ignoreResting==true) then
				aura[k] = 0;
			else
				aura[k] = importAuraSettings[k];
			end
		elseif (k=="inRaid") then
			if (importAuraSettings.isinraid==true) then
				aura[k] = true;
			elseif (importAuraSettings.isinraid==false) then
				aura[k] = 0;
			else
				aura[k] = importAuraSettings[k];
			end	
		elseif (k=="multiids" and offset) then
			local newMultiids = "";
			local sep = "";
			for multiId in string.gmatch(importAuraSettings[k], "[^/]+") do
				newMultiids = newMultiids .. sep .. tostring(offset + multiId);
				sep = "/";
			end
			aura[k] = newMultiids;
		elseif (varType == "string" or varType == "boolean" or varType == "number" and k~="id") then
			aura[k] = importAuraSettings[k];
		end
	end	
	
	if (aura.bufftype==self.BuffTypes.Combo) then --backwards compatability
		if (string.len(aura.buffname)>1 and string.find(aura.buffname, "/", 1, true)==nil) then
			local newBuffName=string.sub(aura.buffname, 1, 1);
			for i=2, string.len(aura.buffname) do
				newBuffName = newBuffName.."/"..string.sub(aura.buffname, i, i);
			end
			aura.buffname = newBuffName
		end
	end
	
	if (importAuraSettings.timer) then --backwards compatability
		aura.Timer = cPowaTimer(aura);
	end
	
	--self:Message("hasTimerSettings=", hasTimerSettings);
	if (hasTimerSettings) then
		--self:CreateTimerFrameIfMissing(aura.id)
		if (aura.Timer==nil) then
			aura.Timer = cPowaTimer(aura);
		end
		for k in pairs(aura.Timer) do
			aura.Timer[k] = importTimerSettings["timer."..k];
		end
	end
	if (hasStacksSettings) then
		--self:CreateTimerFrameIfMissing(aura.id)
		if (aura.Stacks==nil) then
			aura.Stacks = cPowaStacks(aura);
		end
		for k in pairs(aura.Stacks) do
			aura.Stacks[k] = importStacksSettings["stacks."..k];
		end
	end
	--self:Message("new Aura created from import");
	--aura:Display();
	return self:AuraFactory(aura.bufftype, auraId, aura);
end


function PowaAuras:CreateNewAuraFromImport(auraId, importString, updateLink)
	if importString==nil or importString == "" then
		return;
	end
	self.Auras[auraId] = self:ImportAura(importString, auraId, updateLink);
	if (auraId > 120) then
		PowaGlobalSet[auraId] = self.Auras[auraId];
	end				
end

function PowaAuras:CreateNewAuraSetFromImport(importString)
	if importString==nil or importString == "" then
		return;
	end

	local min = ((self.MainOptionPage-1)*24) + 1;
	local max = min + 23;

	for i = min, max do
		if (self.Auras[i] ~= nil) then	
			PowaAuras:DeleteAura(self.Auras[i]);
		end
	end

	local auraId = min;
	local offset;
	local setName;
	for k, v in string.gmatch(importString, "([^\n=@]+)=([^@]+)@") do
		--self:ShowText("k=", k, " len=", string.len(v));
		if (k=="Set") then
			setName = v;		
		else
			if (not offset) then
				local _, _, oldAuraId = string.find(k, "(%d+)");
				--self:ShowText("oldAuraId=", oldAuraId);
				offset = min - oldAuraId;
				--self:ShowText(" offset=", offset);
			end
			self.Auras[auraId] = self:ImportAura(v, auraId, offset);
			if (auraId > 120) then
				PowaGlobalSet[auraId] = self.Auras[auraId];
			end				
			auraId = auraId + 1;
		end
    end
	if (setName~=nil) then
		local nameFound = false;
		for i = 1, 5 do
			if (PowaPlayerListe[i] == setName) then
				nameFound = true;
			end
		end
		for i = 1, 10 do
			if (PowaGlobalListe[i] == setName) then
				nameFound = true;
			end
		end
		if (not nameFound) then
			getglobal("PowaOptionsList"..self.MainOptionPage):SetText( setName );
			if (self.MainOptionPage > 5) then
				PowaGlobalListe[self.MainOptionPage-5] = setName;
			else
				PowaPlayerListe[self.MainOptionPage] = setName;
			end
		end
	end

	self:UpdateMainOption();
end

function PowaAuras:OptionImportEffect()

	local i = self:GetNextFreeSlot();
	if (not i) then
		self:Message("All aura slots filled"); -- OK
		return;
	end
                       
	self.ImportAuraId = i;
	self.CurrentAuraPage = self.MainOptionPage;

	StaticPopup_Show("POWERAURAS_IMPORT_AURA");
			
end

function PowaAuras:OptionExportEffect()
	if self.Auras[self.CurrentAuraId] then
		StaticPopup_Show("POWERAURAS_EXPORT_AURA");
	end
end

function PowaAuras:CreateAuraSetString()
	local setString = "Set=";
	if (self.MainOptionPage > 5) then
		setString = setString .. PowaGlobalListe[self.MainOptionPage-5];
	else
		setString = setString .. PowaPlayerListe[self.MainOptionPage];
	end
	setString = setString .. "@";
	local min = ((self.MainOptionPage-1)*24) + 1;
	local max = min + 23;

	for i = min, max do
		--self:ShowText(i);
		if (self.Auras[i] ~= nil and self.Auras[i].buffname ~= "" and self.Auras[i].buffname ~= " ") then	
			setString = setString .. "\nAura[" .. tostring(i) .. "]=" .. self.Auras[i]:CreateAuraString(true).."@";
			--self:ShowText("Aura[" .. tostring(i) .. "]");
		end
	end
	return setString;
end

function PowaAuras:OptionImportSet()
	StaticPopup_Show("POWERAURAS_IMPORT_AURA_SET");		
end

function PowaAuras:OptionExportSet()
	StaticPopup_Show("POWERAURAS_EXPORT_AURA_SET");
end

function PowaAuras:DisableMoveMode()
	getglobal("PowaOptionsMove"):UnlockHighlight();
	getglobal("PowaOptionsCopy"):UnlockHighlight();
	self.MoveEffect = 0;
	for i = 1, 15 do
		getglobal("PowaOptionsList"..i.."Glow"):Hide();
	end
	-- reactive les boutons
	getglobal("PowaOptionsMove"):Enable();
	getglobal("PowaOptionsCopy"):Enable();
	getglobal("PowaOptionsRename"):Enable();
	getglobal("PowaEditButton"):Enable();
	getglobal("PowaMainTestButton"):Enable();
	getglobal("PowaMainHideAllButton"):Enable();
	getglobal("PowaOptionsSelectorNew"):Enable();
	getglobal("PowaOptionsSelectorDelete"):Enable();
end

function PowaAuras:OptionMoveEffect(isMove)

	if (self.Auras[self.CurrentAuraId] == nil or self.Auras[self.CurrentAuraId].buffname == "" or self.Auras[self.CurrentAuraId].buffname == " ") then
		return; -- on essaye de deplacer un effet vide !!
	end

	-- illumine le bouton pour dire que c'est actif
	if (self.MoveEffect == 0) then
		if (isMove) then
			self.MoveEffect = 2;
			getglobal("PowaOptionsMove"):LockHighlight();
			getglobal("PowaOptionsCopy"):Disable();
		else
			self.MoveEffect = 1;
			getglobal("PowaOptionsCopy"):LockHighlight();
			getglobal("PowaOptionsMove"):Disable();
		end
		for i = 1, 15 do
			getglobal("PowaOptionsList"..i.."Glow"):SetVertexColor(0.5,0.5,0.5);
			getglobal("PowaOptionsList"..i.."Glow"):Show();
		end
		-- annule tous les boutons
		getglobal("PowaOptionsRename"):Disable();
		getglobal("PowaEditButton"):Disable();
		getglobal("PowaMainTestButton"):Disable();
		getglobal("PowaMainHideAllButton"):Disable();
		getglobal("PowaOptionsSelectorNew"):Disable();
		getglobal("PowaOptionsSelectorDelete"):Disable();
	else
		self:DisableMoveMode();
	end
end

function PowaAuras:BeginMoveEffect(Pfrom, ToPage)

	local i = self:GetNextFreeSlot(ToPage);
	if (not i) then
		self:Message("All aura slots filled"); --OK
		return;
	end

	self:DoCopyEffect(Pfrom, i, true); -- copie et efface effet actuel
	self:TriageIcones(self.CurrentAuraPage); -- trie les pages pour eviter les trous
	self.CurrentAuraId = ((self.MainOptionPage-1)*24)+1; -- nouvelle aura en cours sera le premier effet de cette page
	-- gere les visus
	self:DisableMoveMode();
	-- met a jour la page
	self:UpdateMainOption();

end

function PowaAuras:BeginCopyEffect(Pfrom, ToPage)
 	local i = self:GetNextFreeSlot(ToPage);
	if (not i) then
		self:Message("All aura slots filled"); --OK
		return;
	end

	self:DoCopyEffect(Pfrom, i, false); -- copie et efface effet actuel
	self.CurrentAuraId = i; -- nouvelle aura en cours sera l'effet cree
	-- gere les visus
	self:DisableMoveMode();
	-- met a jour la page
	self:UpdateMainOption();

end

function PowaAuras:DoCopyEffect(idFrom, idTo, isMove)
	self.Auras[idTo] = self:AuraFactory(self.Auras[idFrom].bufftype, idTo, self.Auras[idFrom]);
	
	if (self.Auras[idFrom].Timer) then
		self.Auras[idTo].Timer = cPowaTimer(self.Auras[idTo], self.Auras[idFrom].Timer);
	end
	
	if (self.Auras[idFrom].Stacks) then
		self.Auras[idTo].Stacks = cPowaStacks(self.Auras[idTo], self.Auras[idFrom].Stacks);
	end

	if (idTo > 120) then
		PowaGlobalSet[idTo] = self.Auras[idTo];
	end

	if (isMove) then
		self:DeleteAura(self.Auras[idFrom]);
	end
end
-- ---------------------------------------------------------------------------------------------------------------------
function PowaAuras:MainOptionShow()
	--self:ShowText("MainOptionShow");
	if (PowaOptionsFrame:IsVisible()) then
		self:MainOptionClose();
	else
		self:OptionHideAll();
		self.ModTest = true;
		self:UpdateMainOption();
		getglobal("PowaOptionsFrame"):Show();
		PlaySound("TalentScreenOpen");
		if (PowaMisc.Disabled) then
			self:DisplayText("Power Auras "..self.Colors.Red..ADDON_DISABLED.."|r");
		end
	end
end

function PowaAuras:MainOptionClose()
	--self:ShowText("MainOptionClose");
	self:DisableMoveMode();
	self.ModTest = false;
	if ColorPickerFrame:IsVisible() then
		self.CancelColor();
		ColorPickerFrame:Hide();
	end
	getglobal("FontSelectorFrame"):Hide();
	getglobal("PowaBarConfigFrame"):Hide();
	getglobal("PowaOptionsFrame"):Hide();
	PlaySound("TalentScreenClose");

	PowaAuras:OptionHideAll();
    
	self:FindAllChildren();
	self:CreateEffectLists();	
	self.DoCheck.All = true;
	self:NewCheckBuffs();
 	self:MemorizeActions();
end
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< MAIN OPTIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

function PowaAuras:UpdateTimerOptions()

	local aura = self.Auras[self.CurrentAuraId];
	
	if (not aura.Timer) then
		aura.Timer = cPowaTimer(self);
	end
	local timer = aura.Timer;
	
	if (timer) then
		
		getglobal("PowaShowTimerButton"):SetChecked(timer.enabled);

		getglobal("PowaTimerAlphaSlider"):SetValue(timer.a);
		getglobal("PowaTimerSizeSlider"):SetValue(timer.h);
		-- ajuste slider Y
		getglobal("PowaTimerCoordSlider"):SetMinMaxValues(timer.y-5000,timer.y+5000);
		getglobal("PowaTimerCoordSliderLow"):SetText(timer.y-100);
		getglobal("PowaTimerCoordSliderHigh"):SetText(timer.y+100);
		getglobal("PowaTimerCoordSlider"):SetValue(timer.y);
		getglobal("PowaTimerCoordSlider"):SetMinMaxValues(timer.y-100,timer.y+100);
		-- ajuste slider X
		getglobal("PowaTimerCoordXSlider"):SetMinMaxValues(timer.x-5000,timer.x+5000);
		getglobal("PowaTimerCoordXSliderLow"):SetText(timer.x-100);
		getglobal("PowaTimerCoordXSliderHigh"):SetText(timer.x+100);
		getglobal("PowaTimerCoordXSlider"):SetValue(timer.x);
		getglobal("PowaTimerCoordXSlider"):SetMinMaxValues(timer.x-100,timer.x+100);

		getglobal("PowaBuffTimerCentsButton"):SetChecked(timer.cents);
		getglobal("PowaBuffTimerLeadingZerosButton"):SetChecked(timer.HideLeadingZeros);
		
		getglobal("PowaBuffTimerTransparentButton"):SetChecked(timer.Transparent);
		
		if (aura:FullTimerAllowed()) then 
			-- show full timer options
			PowaBuffTimerUpdatePingButton:SetChecked(timer.UpdatePing);
			self:EnableCheckBox("PowaBuffTimerUpdatePingButton");
			PowaBuffTimerActivationTime:Enable();
		else
			-- Show cut-down timer options
			PowaBuffTimerUpdatePingButton:SetChecked(false);
			self:DisableCheckBox("PowaBuffTimerUpdatePingButton");
			timer.ShowActivation = true;
			PowaBuffTimerActivationTime:Disable();
		end
		getglobal("PowaBuffTimerActivationTime"):SetChecked(timer.ShowActivation);

		
		UIDropDownMenu_SetSelectedValue(PowaDropDownTimerTexture, timer.Texture);
		
		PowaTimerInvertAuraSlider:SetValue(timer.InvertAuraBelow);

	end
end

function PowaAuras:UpdateStacksOptions()

	local stacks = self.Auras[self.CurrentAuraId].Stacks;
	if (stacks) then
		
		getglobal("PowaShowStacksButton"):SetChecked(stacks.enabled);

		getglobal("PowaStacksAlphaSlider"):SetValue(stacks.a);
		getglobal("PowaStacksSizeSlider"):SetValue(stacks.h);
		-- ajuste slider Y
		getglobal("PowaStacksCoordSlider"):SetMinMaxValues(stacks.y-5000,stacks.y+5000);
		getglobal("PowaStacksCoordSliderLow"):SetText(stacks.y-100);
		getglobal("PowaStacksCoordSliderHigh"):SetText(stacks.y+100);
		getglobal("PowaStacksCoordSlider"):SetValue(stacks.y);
		getglobal("PowaStacksCoordSlider"):SetMinMaxValues(stacks.y-100,stacks.y+100);
		-- ajuste slider X
		getglobal("PowaStacksCoordXSlider"):SetMinMaxValues(stacks.x-5000,stacks.x+5000);
		getglobal("PowaStacksCoordXSliderLow"):SetText(stacks.x-100);
		getglobal("PowaStacksCoordXSliderHigh"):SetText(stacks.x+100);
		getglobal("PowaStacksCoordXSlider"):SetValue(stacks.x);
		getglobal("PowaStacksCoordXSlider"):SetMinMaxValues(stacks.x-100,stacks.x+100);

		getglobal("PowaBuffStacksTransparentButton"):SetChecked(stacks.Transparent);
		getglobal("PowaBuffStacksUpdatePingButton"):SetChecked(stacks.UpdatePing);
		
		UIDropDownMenu_SetSelectedValue(PowaDropDownStacksTexture, stacks.Texture);

	end
end


function PowaAuras:SetOptionText(optionsText)
	--self:ShowText("typeText=", optionsText.typeText);
	PowaDropDownBuffTypeText:SetText(optionsText.typeText);
	if (optionsText.buffNameTooltip) then
		PowaBarBuffName:Show();
		PowaBarBuffName.aide = optionsText.buffNameTooltip;
	else
		self:DisableTextfield("PowaBarBuffName");
	end
	if (optionsText.exactTooltip) then
		self:EnableCheckBox("PowaExactButton");
		PowaExactButton.aide = optionsText.exactTooltip;
	else
		self:DisableCheckBox("PowaExactButton");
	end
	if (optionsText.mineText) then
		self:EnableCheckBox("PowaMineButton");
		PowaMineButtonText:SetText(optionsText.mineText);
		PowaMineButton.tooltipText = optionsText.mineTooltip; 
	else
		PowaMineButton:SetChecked(false);
		self:DisableCheckBox("PowaMineButton");
	end
	if (optionsText.targetFriendText) then
		self:EnableCheckBox("PowaTargetFriendButton");
		PowaTargetFriendButtonText:SetText(optionsText.targetFriendText);
		PowaTargetFriendButton.tooltipText = optionsText.targetFriendTooltip; 
	else
		PowaTargetFriendButton:SetChecked(false);
		self:DisableCheckBox("PowaTargetFriendButton");
	end
	
end

function PowaAuras:ShowOptions(optionsToShow)
	for k,v in pairs(self.OptionHideables) do
		if (optionsToShow and optionsToShow[v]) then
			getglobal(v):Show();
		else
			getglobal(v):Hide();
		end
	end
end

function PowaAuras:EnableCheckBoxes(checkBoxesToEnable)
	--self:ShowText("EnableCheckBoxes");
	for k,v in pairs(self.OptionCheckBoxes) do
		--self:ShowText(v, " checkBoxesToEnable=", checkBoxesToEnable[v]);
		if (checkBoxesToEnable and checkBoxesToEnable[v]) then
			--self:ShowText(v, " Colours=", self.SetColours[v]);
			self:EnableCheckBox(v, self.SetColours[v]);
		else
			getglobal(v):SetChecked(false);
			self:DisableCheckBox(v);	
		end
	end
end

function PowaAuras:EnableTernary(ternariesToEnable)
	--self:ShowText("EnableTernary");
	for k,v in pairs(self.OptionTernary) do
		--self:ShowText(v, " ternariesToEnable=", ternariesToEnable[v]);
		if (not ternariesToEnable or not ternariesToEnable[v]) then
			--self:ShowText("Disable Ternary ",v);
			--self:Ternary_Set(getglobal(v));
			self:DisableTernary(getglobal(v));
		end
	end
end


function PowaAuras:SetupOptionsForAuraType(aura)
	--self:ShowText("aura=", aura);

	self:SetOptionText(aura.OptionText);
	self:ShowOptions(aura.ShowOptions);
	self:EnableCheckBoxes(aura.CheckBoxes);
	self:EnableTernary(aura.Ternary);

	if (aura:ShowTimerDurationSlider()) then
		PowaTimerDurationSlider:Show();
	else
		PowaTimerDurationSlider:Hide();
	end
	
	if (aura.CanHaveInvertTime) then
		PowaTimerInvertAuraSlider:Show();
	else
		PowaTimerInvertAuraSlider:Hide();
	end
end

function PowaAuras:InitPage()

	--self:ShowText("InitPage ", self.CurrentAuraId);

	local CheckTexture = 0;
    local aura = self.Auras[self.CurrentAuraId];
	--self:Message("aura ", aura);
	self:UpdateTimerOptions();

	getglobal("PowaDropDownAnim1Text"):SetText(self.Anim[aura.anim1]);
	getglobal("PowaDropDownAnim2Text"):SetText(self.Anim[aura.anim2]);
	getglobal("PowaDropDownAnimBeginText"):SetText(self.BeginAnimDisplay[aura.begin]);
	getglobal("PowaDropDownAnimEndText"):SetText(self.EndAnimDisplay[aura.finish]);
	if (aura.sound<30) then
		getglobal("PowaDropDownSoundText"):SetText(self.Sound[aura.sound]);
		getglobal("PowaDropDownSound2Text"):SetText(self.Sound[30]);
	else
		getglobal("PowaDropDownSoundText"):SetText(self.Sound[0]);
		getglobal("PowaDropDownSound2Text"):SetText(self.Sound[aura.sound]);
	end
	
	if (aura.soundend<30) then
		getglobal("PowaDropDownSoundEndText"):SetText(self.Sound[aura.soundend]);
		getglobal("PowaDropDownSound2EndText"):SetText(self.Sound[30]);
	else
		getglobal("PowaDropDownSoundEndText"):SetText(self.Sound[0]);
		getglobal("PowaDropDownSound2EndText"):SetText(self.Sound[aura.soundend]);
	end
	getglobal("PowaDropDownStanceText"):SetText(self.PowaStance[aura.stance]);
	getglobal("PowaDropDownGTFOText"):SetText(self.PowaGTFO[aura.GTFO]);
	getglobal("PowaBarCustomSound").aide = self.Text.aideCustomSound;
	getglobal("PowaBarCustomSoundEnd").aide = self.Text.aideCustomSoundEnd;
	getglobal("PowaBarBuffStacks").aide = self.Text.aideStacks;
	-- ---------------
	getglobal("PowaOwntexButton"):SetChecked(aura.owntex);
	getglobal("PowaWowTextureButton"):SetChecked(aura.wowtex);
	getglobal("PowaCustomTextureButton"):SetChecked(aura.customtex);
	getglobal("PowaTextAuraButton"):SetChecked(aura.textaura);
	getglobal("PowaRandomColorButton"):SetChecked(aura.randomcolor);
	getglobal("PowaShowSpinAtBeginning"):SetChecked(aura.beginSpin);
	getglobal("PowaOldAnimation"):SetChecked(aura.UseOldAnimations);
	getglobal("PowaIngoreCaseButton"):SetChecked(aura.ignoremaj);
	getglobal("PowaInverseButton"):SetChecked(aura.inverse);
	getglobal("PowaTargetButton"):SetChecked(aura.target);
	getglobal("PowaTargetFriendButton"):SetChecked(aura.targetfriend);
	getglobal("PowaPartyButton"):SetChecked(aura.party);
	getglobal("PowaFocusButton"):SetChecked(aura.focus);
	getglobal("PowaRaidButton"):SetChecked(aura.raid);
	getglobal("PowaGroupOrSelfButton"):SetChecked(aura.groupOrSelf);
	getglobal("PowaGroupAnyButton"):SetChecked(aura.groupany);
	getglobal("PowaOptunitnButton"):SetChecked(aura.optunitn);
	getglobal("PowaExactButton"):SetChecked(aura.exact);
	getglobal("PowaMineButton"):SetChecked(aura.mine);
	getglobal("PowaThresholdInvertButton"):SetChecked(aura.thresholdinvert);
	-- ----------------
	getglobal("PowaTexModeButton"):SetChecked(aura.texmode == 1);

	-- Ternary Logic
	self:TernarySetState(getglobal("PowaInCombatButton"), aura.combat);
	self:TernarySetState(getglobal("PowaIsInRaidButton"), aura.inRaid);
	self:TernarySetState(getglobal("PowaIsInPartyButton"), aura.inParty);
	self:TernarySetState(getglobal("PowaRestingButton"), aura.isResting);
	self:TernarySetState(getglobal("PowaIsMountedButton"), aura.ismounted);
	self:TernarySetState(getglobal("PowaInVehicleButton"), aura.inVehicle);
	self:TernarySetState(getglobal("PowaIsAliveButton"), aura.isAlive);
	self:TernarySetState(getglobal("PowaPvPButton"), aura.PvP);
	
	self:TernarySetState(getglobal("Powa5ManInstanceButton"), aura.Instance5Man);
	self:TernarySetState(getglobal("Powa5ManHeroicInstanceButton"), aura.Instance5ManHeroic);
	self:TernarySetState(getglobal("Powa10ManInstanceButton"), aura.Instance10Man);
	self:TernarySetState(getglobal("Powa10ManHeroicInstanceButton"), aura.Instance10ManHeroic);
	self:TernarySetState(getglobal("Powa25ManInstanceButton"), aura.Instance25Man);
	self:TernarySetState(getglobal("Powa25ManHeroicInstanceButton"), aura.Instance25ManHeroic);

	self:TernarySetState(getglobal("PowaBgInstanceButton"), aura.InstanceBg);
	self:TernarySetState(getglobal("PowaArenaInstanceButton"), aura.InstanceArena);

	
	getglobal("PowaTimerDurationSlider"):SetValue(aura.timerduration);
	getglobal("PowaBarThresholdSlider"):SetValue(aura.threshold);
	----------------
	-- dual specs
	self:EnableCheckBox("PowaTalentGroup1Button");
	self:EnableCheckBox("PowaTalentGroup2Button");
	self:EnableCheckBox("PowaTalentGroup3Button");
	getglobal("PowaTalentGroup1Button"):SetChecked(aura.spec1);
	getglobal("PowaTalentGroup2Button"):SetChecked(aura.spec2);
	getglobal("PowaTalentGroup3Button"):SetChecked(aura.spec3);
	
	self:EnableCheckBox("PowaAuraDebugButton");
	getglobal("PowaAuraDebugButton"):SetChecked(aura.Debug);
	
	
	aura:HideShowTabs();
	self:SetupOptionsForAuraType(aura);

	-- changement de page
	if (getglobal("PowaBarConfigFrameEditor4"):IsVisible() and not PowaEditorTab3:IsVisible() ) then
		PanelTemplates_SelectTab(PowaEditorTab2);
		PanelTemplates_DeselectTab(PowaEditorTab1);
		PanelTemplates_DeselectTab(PowaEditorTab3);
		getglobal("PowaBarConfigFrameEditor2"):Show();
		getglobal("PowaBarConfigFrameEditor3"):Hide();
		getglobal("PowaBarConfigFrameEditor4"):Hide();
	end
	-- Visuels auras
	getglobal("PowaBarAuraAlphaSlider"):SetValue(aura.alpha);
	getglobal("PowaBarAuraSizeSlider"):SetValue(aura.size);
	-- ajuste slider Y
	getglobal("PowaBarAuraCoordSlider"):SetMinMaxValues(aura.y-5000,aura.y+5000);
	getglobal("PowaBarAuraCoordSliderLow"):SetText(aura.y-200);
	getglobal("PowaBarAuraCoordSliderHigh"):SetText(aura.y+200);
	getglobal("PowaBarAuraCoordSlider"):SetValue(aura.y);
	getglobal("PowaBarAuraCoordSlider"):SetMinMaxValues(aura.y-200,aura.y+200);
	getglobal("PowaBarAuraCoordYEdit"):SetText(aura.y);
	-- ajuste slider X
	getglobal("PowaBarAuraCoordXSlider"):SetMinMaxValues(aura.x-5000,aura.x+5000);
	getglobal("PowaBarAuraCoordXSliderLow"):SetText(aura.x-200);
	getglobal("PowaBarAuraCoordXSliderHigh"):SetText(aura.x+200);
	getglobal("PowaBarAuraCoordXSlider"):SetValue(aura.x);
	getglobal("PowaBarAuraCoordXSlider"):SetMinMaxValues(aura.x-200,aura.x+200);
	getglobal("PowaBarAuraCoordXEdit"):SetText(aura.x);

	getglobal("PowaBarAuraAnimSpeedSlider"):SetValue(aura.speed);
	
	getglobal("PowaBarAuraDurationSlider"):SetValue(aura.duration);
	getglobal("PowaBarAuraDurationSlider"):SetMinMaxValues(aura.minDuration or 0,30);
	if (not aura.minDuration or aura.minDuration==0) then
		getglobal("PowaBarAuraDurationSliderLow"):SetText(PowaAuras.Text.aucune);
	else
		getglobal("PowaBarAuraDurationSliderLow"):SetText(aura.minDuration);
	end
	
	getglobal("PowaBarAuraSymSlider"):SetValue(aura.symetrie);
	getglobal("PowaBarAuraDeformSlider"):SetValue(aura.torsion);
	getglobal("PowaBarBuffName"):SetText(aura.buffname);
	getglobal("PowaBarMultiID"):SetText(aura.multiids);
	getglobal("PowaBarTooltipCheck"):SetText(aura.tooltipCheck);

	getglobal("PowaBarCustomSound"):SetText(aura.customsound);
	PowaAuras:CustomSoundTextChanged(true);	
	
	getglobal("PowaBarUnitn"):SetText(aura.unitn);
	
	getglobal("PowaBarBuffStacks"):SetText(aura:StacksText());	
    
	if (aura.optunitn == true) then
		self:EnableTextfield("PowaBarUnitn");
	elseif (aura.optunitn == false) then
		self:DisableTextfield("PowaBarUnitn");
	end

	
	if (aura.icon==nil or aura.icon == "") then
		getglobal("PowaIconTexture"):SetTexture("Interface\\Icons\\Inv_Misc_QuestionMark");
	else
		getglobal("PowaIconTexture"):SetTexture(aura.icon);
	end

	if (aura.owntex) then
		--self:ShowText("owntex tex=", aura.icon);	
		CheckTexture = getglobal("AuraTexture"):SetTexture(getglobal("PowaIconTexture"):GetTexture());
		getglobal("PowaBarAuraTextureSlider"):Hide();
		getglobal("PowaBarCustomTexName"):Hide();
		getglobal("PowaBarAurasText"):Hide();
		getglobal("PowaFontsButton"):Hide();
		
	elseif (aura.wowtex) then
		getglobal("PowaBarAuraTextureSlider"):Show();
		getglobal("PowaBarCustomTexName"):Hide();
		getglobal("PowaBarAurasText"):Hide();
		getglobal("PowaFontsButton"):Hide();
		if (#self.WowTextures > self.maxtextures) then
			getglobal("PowaBarAuraTextureSlider"):SetMinMaxValues(1,#self.WowTextures);
			getglobal("PowaBarAuraTextureSlider"):SetValue(aura.texture);
		else
			getglobal("PowaBarAuraTextureSlider"):SetValue(aura.texture);
			getglobal("PowaBarAuraTextureSlider"):SetMinMaxValues(1,#self.WowTextures);
		end
		getglobal("PowaBarAuraTextureSliderHigh"):SetText(#self.WowTextures);
		CheckTexture = getglobal("AuraTexture"):SetTexture(self.WowTextures[aura.texture]);

	elseif (aura.customtex) then
		getglobal("PowaBarAuraTextureSlider"):Hide();
		getglobal("PowaBarAurasText"):Hide();
		getglobal("PowaFontsButton"):Hide();
		getglobal("PowaBarCustomTexName"):Show();
		getglobal("PowaBarCustomTexName"):SetText(aura.customname);
		CheckTexture = getglobal("AuraTexture"):SetTexture(self:CustomTexPath(aura.customname));
	elseif (aura.textaura) then
		getglobal("PowaBarAuraTextureSlider"):Hide();
		getglobal("PowaBarCustomTexName"):Hide();
		getglobal("PowaBarAurasText"):Show();
		getglobal("PowaFontsButton"):Show();
		getglobal("PowaBarAurasText"):SetText(aura.aurastext);
		CheckTexture = getglobal("AuraTexture"):SetTexture("Interface\\Icons\\INV_Scroll_02");  --- Driizt: check if need to test as well
	else
		getglobal("PowaBarAuraTextureSlider"):Show();
		getglobal("PowaBarCustomTexName"):Hide();
		getglobal("PowaBarAurasText"):Hide();
		getglobal("PowaFontsButton"):Hide();
		if (#self.WowTextures < self.maxtextures) then
			getglobal("PowaBarAuraTextureSlider"):SetMinMaxValues(1,self.maxtextures);
			getglobal("PowaBarAuraTextureSlider"):SetValue(aura.texture);
		else
			getglobal("PowaBarAuraTextureSlider"):SetValue(aura.texture);
			getglobal("PowaBarAuraTextureSlider"):SetMinMaxValues(1,self.maxtextures);
		end
		getglobal("PowaBarAuraTextureSliderHigh"):SetText(self.maxtextures);
		CheckTexture = getglobal("AuraTexture"):SetTexture("Interface\\Addons\\PowerAuras\\Auras\\Aura"..aura.texture..".tga");
	end

	--self:ShowText("CheckTexture=", CheckTexture);	
	if (CheckTexture ~= 1) then
		getglobal("AuraTexture"):SetTexture("Interface\\CharacterFrame\\TempPortrait.tga");
	end

	getglobal("PowaColorNormalTexture"):SetVertexColor(aura.r,aura.g,aura.b);
	getglobal("AuraTexture"):SetVertexColor(aura.r,aura.g,aura.b);

	-- affiche la symetrie
	if (aura.symetrie == 1) then 
		getglobal("AuraTexture"):SetTexCoord(1, 0, 0, 1); -- inverse X
	elseif (aura.symetrie == 2) then 
		getglobal("AuraTexture"):SetTexCoord(0, 1, 1, 0); -- inverse Y
	elseif (aura.symetrie == 3) then 
		getglobal("AuraTexture"):SetTexCoord(1, 0, 1, 0); -- inverse XY
	else 
		getglobal("AuraTexture"):SetTexCoord(0, 1, 0, 1); 
	end

	getglobal("PowaColor_SwatchBg").r = aura.r;
	getglobal("PowaColor_SwatchBg").g = aura.g;
	getglobal("PowaColor_SwatchBg").b = aura.b;

	getglobal("PowaHeader"):SetText(self.Text.nomEffectEditor);
end
-----------------------------------------------------------------------------------------------------------------------
-- Sliders Changed
-----------------------------------------------------------------------------------------------------------------------

function PowaAuras:BarAuraTextureSliderChanged()
	if (self.Initialising) then return; end
	local SliderValue = getglobal("PowaBarAuraTextureSlider"):GetValue();
	local CheckTexture = 0;
	local auraId = self.CurrentAuraId;
	
	if (self.Auras[auraId].owntex == true) then
		CheckTexture = getglobal("AuraTexture"):SetTexture(self.Auras[auraId].icon);

	elseif (self.Auras[auraId].wowtex == true) then
		CheckTexture = getglobal("AuraTexture"):SetTexture(self.WowTextures[SliderValue]);

	elseif (self.Auras[auraId].customtex == true) then
		CheckTexture = getglobal("AuraTexture"):SetTexture(self:CustomTexPath(self.Auras[auraId].customname));
	
	elseif (self.Auras[auraId].textaura == true) then
		CheckTexture = getglobal("AuraTexture"):SetTexture("Interface\\Icons\\INV_Scroll_02"); 
	
	else
		CheckTexture = getglobal("AuraTexture"):SetTexture("Interface\\Addons\\PowerAuras\\Auras\\Aura"..SliderValue..".tga");
	end
	
	if (CheckTexture ~= 1) then
		getglobal("AuraTexture"):SetTexture("Interface\\CharacterFrame\\TempPortrait.tga");
	end
		
	getglobal("PowaBarAuraTextureSliderText"):SetText(self.Text.nomTexture.." : "..SliderValue);
	getglobal("AuraTexture"):SetVertexColor(self.Auras[auraId].r,self.Auras[auraId].g,self.Auras[auraId].b);
	
	PowaBarAuraTextureEdit:SetText(SliderValue);
	
	self.Auras[auraId].texture = SliderValue;
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:TextAuraTextureChanged()
	local thisText = getglobal("PowaBarAuraTextureEdit"):GetText();
	local thisNumber = tonumber(thisText);
	getglobal("PowaBarAuraTextureSlider"):SetValue(thisNumber or 0);
end

 
function PowaAuras:BarAuraAlphaSliderChanged()
	if (self.Initialising) then return; end
	local SliderValue = getglobal("PowaBarAuraAlphaSlider"):GetValue();

	getglobal("PowaBarAuraAlphaSliderText"):SetText(self.Text.nomAlpha.." : "..format("%.0f",SliderValue*100).."%");

	self.Auras[self.CurrentAuraId].alpha = SliderValue;
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:BarAuraSizeSliderChanged()
	if (self.Initialising) then return; end
	local SliderValue = getglobal("PowaBarAuraSizeSlider"):GetValue();
	local auraId = self.CurrentAuraId;
	
	getglobal("PowaBarAuraSizeSliderText"):SetText(self.Text.nomTaille.." : "..format("%.0f",SliderValue*100).."%");

	self.Auras[auraId].size = SliderValue;
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:BarAuraCoordSliderChanged()
	if (self.Initialising) then return; end
	local SliderValue = getglobal("PowaBarAuraCoordSlider"):GetValue();
	local auraId = self.CurrentAuraId;
	
	getglobal("PowaBarAuraCoordSliderText"):SetText(self.Text.nomPos.." Y : "..SliderValue);
	if (getglobal("PowaBarAuraCoordYEdit")) then
		getglobal("PowaBarAuraCoordYEdit"):SetText(SliderValue);
	end

	self.Auras[auraId].y = SliderValue;
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:BarAuraCoordXSliderChanged()
	if (self.Initialising) then return; end
	local SliderValue = getglobal("PowaBarAuraCoordXSlider"):GetValue();
	local auraId = self.CurrentAuraId;
	
	getglobal("PowaBarAuraCoordXSliderText"):SetText(self.Text.nomPos.." X : "..SliderValue);
	if (getglobal("PowaBarAuraCoordXEdit")) then
		getglobal("PowaBarAuraCoordXEdit"):SetText(SliderValue);
	end

	self.Auras[auraId].x = SliderValue;
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:BarAuraAnimSpeedSliderChanged()
	if (self.Initialising) then return; end
	local SliderValue = getglobal("PowaBarAuraAnimSpeedSlider"):GetValue();
	local auraId = self.CurrentAuraId;

	getglobal("PowaBarAuraAnimSpeedSliderText"):SetText(self.Text.nomSpeed.." : "..format("%.0f",SliderValue*100).."%");

	self.Auras[auraId].speed = SliderValue;
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:BarAuraAnimDurationSliderChanged(control)
	if (self.Initialising) then return; end
	local sliderValue = control:GetValue();

	getglobal(control:GetName().."Text"):SetText(self.Text.nomDuration.." : "..sliderValue.." sec");

	--self:ShowText("Duration set to ", sliderValue);
	self.Auras[self.CurrentAuraId].duration = sliderValue;
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:BarAuraSymSliderChanged()
	if (self.Initialising) then return; end

	local SliderValue = getglobal("PowaBarAuraSymSlider"):GetValue();

	if (SliderValue == 0) then
		getglobal("PowaBarAuraSymSliderText"):SetText(self.Text.nomSymetrie.." : "..self.Text.aucune);
		getglobal("AuraTexture"):SetTexCoord(0, 1, 0, 1);
	elseif (SliderValue == 1) then
		getglobal("PowaBarAuraSymSliderText"):SetText(self.Text.nomSymetrie.." : X");
		getglobal("AuraTexture"):SetTexCoord(1, 0, 0, 1);
	elseif (SliderValue == 2) then
		getglobal("PowaBarAuraSymSliderText"):SetText(self.Text.nomSymetrie.." : Y");
		getglobal("AuraTexture"):SetTexCoord(0, 1, 1, 0);
	elseif (SliderValue == 3) then
		getglobal("PowaBarAuraSymSliderText"):SetText(self.Text.nomSymetrie.." : XY");
		getglobal("AuraTexture"):SetTexCoord(1, 0, 1, 0);
	end
	
	self.Auras[self.CurrentAuraId].symetrie = SliderValue;
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:BarAuraDeformSliderChanged()
	if (self.Initialising) then return; end
	local SliderValue = getglobal("PowaBarAuraDeformSlider"):GetValue();

	getglobal("PowaBarAuraDeformSliderText"):SetText(self.Text.nomDeform.." : "..format("%.2f", SliderValue));

	self.Auras[self.CurrentAuraId].torsion = SliderValue;
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:BarThresholdSliderChanged()
	if (self.Initialising) then return; end
	local SliderValue = getglobal("PowaBarThresholdSlider"):GetValue();
	local auraId = self.CurrentAuraId;

	getglobal("PowaBarThresholdSliderText"):SetText(self.Text.nomThreshold.." : "..SliderValue.."%");

	self.Auras[auraId].threshold = SliderValue;
end

------------------------------------------------------------------
-- Text Changed
------------------------------------------------------------------

function PowaAuras:TextCoordXChanged()
	local thisText = getglobal("PowaBarAuraCoordXEdit"):GetText();
	local thisNumber = tonumber(thisText);
	local auraId = self.CurrentAuraId;

	if (thisNumber == nil) then
		getglobal("PowaBarAuraCoordXSliderText"):SetText(self.Text.nomPos.." X : "..0);
		getglobal("PowaBarAuraCoordXSlider"):SetValue(0);
		getglobal("PowaBarAuraCoordXEdit"):SetText(0);
		self.Auras[auraId].x = 0;	
	else
		if (thisNumber > 300 or thisNumber < -300) then
			getglobal("PowaBarAuraCoordXEdit"):SetText(thisNumber);
			self:DisableSlider("PowaBarAuraCoordXSlider");
		else
			self:EnableSlider("PowaBarAuraCoordXSlider");
			getglobal("PowaBarAuraCoordXSliderText"):SetText(self.Text.nomPos.." X : "..thisNumber);
			getglobal("PowaBarAuraCoordXSlider"):SetValue(thisNumber);
		end
		self.Auras[auraId].x = thisNumber;
	end
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:TextCoordYChanged()
	local thisText = getglobal("PowaBarAuraCoordYEdit"):GetText();
	local thisNumber = tonumber(thisText);
	local auraId = self.CurrentAuraId;

	if (thisNumber == nil) then
		getglobal("PowaBarAuraCoordSliderText"):SetText(self.Text.nomPos.." Y : "..0);
		getglobal("PowaBarAuraCoordSlider"):SetValue(0);
		getglobal("PowaBarAuraCoordYEdit"):SetText(0);
		self.Auras[auraId].y = 0;	
	else
		if (thisNumber > 300 or thisNumber < -300) then
			getglobal("PowaBarAuraCoordYEdit"):SetText(thisNumber);
			self:DisableSlider("PowaBarAuraCoordSlider");
		else
			self:EnableSlider("PowaBarAuraCoordSlider");
			getglobal("PowaBarAuraCoordSliderText"):SetText(self.Text.nomPos.." Y : "..thisNumber);
			getglobal("PowaBarAuraCoordSlider"):SetValue(thisNumber);
		end
		self.Auras[auraId].y = thisNumber;
	end
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:TextChanged()
	local oldText = PowaBarBuffName:GetText();
	local auraId = self.CurrentAuraId;

	if (oldText ~= self.Auras[auraId].buffname) then
		self.Auras[auraId].buffname = PowaBarBuffName:GetText();
		self.Auras[auraId].icon = "";
		PowaIconTexture:SetTexture("Interface\\Icons\\Inv_Misc_QuestionMark");
	end
end

function PowaAuras:MultiIDChanged()
	local oldText = getglobal("PowaBarMultiID"):GetText();
	local auraId = self.CurrentAuraId;
	if (oldText ~= self.Auras[auraId].multiids) then
		self.Auras[auraId].multiids = getglobal("PowaBarMultiID"):GetText();
		self:FindAllChildren();
	end
end

function PowaAuras:TooltipCheckChanged()
	local oldText = getglobal("PowaBarTooltipCheck"):GetText();
	local auraId = self.CurrentAuraId;
	if (oldText ~= self.Auras[auraId].tooltipCheck) then
		self.Auras[auraId].tooltipCheck = getglobal("PowaBarTooltipCheck"):GetText();
	end
end

function PowaAuras:StacksTextChanged()
	local aura = self.Auras[self.CurrentAuraId];
	aura:SetStacks(getglobal("PowaBarBuffStacks"):GetText());
end

function PowaAuras:UnitnTextChanged()
	local oldUnitnText = getglobal("PowaBarUnitn"):GetText();
	local auraId = self.CurrentAuraId;

	if (oldUnitnText ~= self.Auras[auraId].unitn) then
		self.Auras[auraId].unitn = getglobal("PowaBarUnitn"):GetText();
	end
end

function PowaAuras:CustomTextChanged()
	local auraId = self.CurrentAuraId;
	self.Auras[auraId].customname = getglobal("PowaBarCustomTexName"):GetText();
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:AurasTextCancel()
	local auraId = self.CurrentAuraId;
	getglobal("PowaBarAurasText"):SetText(self.Auras[auraId].aurastext);
end

function PowaAuras:AurasTextChanged()
	local auraId = self.CurrentAuraId;
	self.Auras[auraId].aurastext = getglobal("PowaBarAurasText"):GetText();
	--self:Message("aura text changed to ", self.Auras[auraId].aurastext);
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:CustomSoundTextChanged(force)
	local oldCustomSound = getglobal("PowaBarCustomSound"):GetText();
	local aura = self.Auras[self.CurrentAuraId];

	if (oldCustomSound ~= aura.customsound or force) then -- custom sound changed
		aura.customsound = oldCustomSound;
		if (aura.customsound ~= "") then
			aura.sound = 0;
			PowaDropDownSoundText:SetText(self.Sound[0]);
			PowaDropDownSound2Text:SetText(self.Sound[30]);
			PowaDropDownSoundButton:Disable();
			PowaDropDownSound2Button:Disable();
			local pathToSound = "Interface\\AddOns\\PowerAuras\\Sounds\\"..aura.customsound;
			--self:ShowText("Playing sound "..pathToSound);
			local played = PlaySoundFile(pathToSound);
			--self:ShowText("played = "..played);
			if (not played) then
				self:DisplayText("Failed to play sound "..pathToSound);
			end
		else
			PowaDropDownSoundButton:Enable();
			PowaDropDownSound2Button:Enable();
		end
	end	
end

function PowaAuras:CustomSoundEndTextChanged(force)
	local oldCustomSound = getglobal("PowaBarCustomSoundEnd"):GetText();
	local aura = self.Auras[self.CurrentAuraId];

	if (oldCustomSound ~= aura.customsoundend or force) then -- custom sound changed
		aura.customsoundend = oldCustomSound;
		if (aura.customsoundend ~= "") then
			aura.soundend = 0;
			PowaDropDownSoundEndText:SetText(self.Sound[0]);
			PowaDropDownSound2EndText:SetText(self.Sound[30]);
			PowaDropDownSoundEndButton:Disable();
			PowaDropDownSound2EndButton:Disable();
			local pathToSound = "Interface\\AddOns\\PowerAuras\\Sounds\\"..aura.customsoundend;
			--self:ShowText("Playing sound "..pathToSound);
			local played = PlaySoundFile(pathToSound);
			--self:ShowText("played = "..played);
			if (not played) then
				self:DisplayText("Failed to play sound "..pathToSound);
			end
		else
			PowaDropDownSoundEndButton:Enable();
			PowaDropDownSound2EndButton:Enable();
		end
	end	
end

---------------------------------
-- Checkboxes changed
---------------------------------

function PowaAuras:InverseChecked()
	local aura = self.Auras[self.CurrentAuraId];
	if (getglobal("PowaInverseButton"):GetChecked()) then
		aura.inverse = true;
	else
		aura.inverse = false;
	end
	aura:HideShowTabs();
end

function PowaAuras:IgnoreMajChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaIngoreCaseButton"):GetChecked()) then
		self.Auras[auraId].ignoremaj = true;
	else
		self.Auras[auraId].ignoremaj = false;
	end
end

function PowaAuras:ExactChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaExactButton"):GetChecked()) then
		self.Auras[auraId].exact = true;
	else
		self.Auras[auraId].exact = false;
	end
end

function PowaAuras:CheckedButtonOnClick(button, key)
	self.Auras[self.CurrentAuraId][key] = (button:GetChecked()~=nil);
end

function PowaAuras:RandomColorChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaRandomColorButton"):GetChecked()) then
		self.Auras[auraId].randomcolor = true;
	else
		self.Auras[auraId].randomcolor = false;
	end
end

function PowaAuras:TexModeChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaTexModeButton"):GetChecked()) then
		self.Auras[auraId].texmode = 1;
	else
		self.Auras[auraId].texmode = 2;
	end
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:ThresholdInvertChecked(owner)
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaThresholdInvertButton"):GetChecked()) then
		self.Auras[auraId].thresholdinvert = true;
	else
		self.Auras[auraId].thresholdinvert = false;
	end
end

------------------------------------

function PowaAuras:OwntexChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaOwntexButton"):GetChecked()) then
		self.Auras[auraId].owntex = true;
		self.Auras[auraId].wowtex = false;
		self.Auras[auraId].customtex = false;
		self.Auras[auraId].textaura = false;
		getglobal("PowaWowTextureButton"):SetChecked(false);
		getglobal("PowaCustomTextureButton"):SetChecked(false);
		getglobal("PowaTextAuraButton"):SetChecked(false);
		getglobal("PowaBarAuraTextureSlider"):Hide();
		getglobal("PowaBarCustomTexName"):Hide();
		getglobal("PowaBarAurasText"):Hide();
		getglobal("PowaFontsButton"):Hide();
	else
		self.Auras[auraId].owntex = false;
	end	
	PowaAuras:InitPage();
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:WowTexturesChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaWowTextureButton"):GetChecked()) then
		self.Auras[auraId].wowtex = true;
		self.Auras[auraId].owntex = false;
		self.Auras[auraId].customtex = false;
		self.Auras[auraId].textaura = false;
		
		getglobal("PowaBarAuraTextureSlider"):SetMinMaxValues(1,#self.WowTextures);
		getglobal("PowaBarAuraTextureSlider"):SetValue(1);
		getglobal("PowaBarAuraTextureSliderHigh"):SetText(#self.WowTextures);
		getglobal("PowaOwntexButton"):SetChecked(false);
		getglobal("PowaCustomTextureButton"):SetChecked(false);
		getglobal("PowaTextAuraButton"):SetChecked(false);
		getglobal("PowaBarAuraTextureSlider"):Show();
		getglobal("PowaBarCustomTexName"):Hide();
		getglobal("PowaBarAurasText"):Hide();
		getglobal("PowaFontsButton"):Hide();
	else
		self.Auras[auraId].wowtex = false;
		getglobal("PowaBarAuraTextureSlider"):SetMinMaxValues(1,self.maxtextures);
		getglobal("PowaBarAuraTextureSlider"):SetValue(1);
		getglobal("PowaBarAuraTextureSliderHigh"):SetText(self.maxtextures);
	end
	PowaAuras:BarAuraTextureSliderChanged();
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:CustomTexturesChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaCustomTextureButton"):GetChecked()) then
		self.Auras[auraId].customtex = true;
		self.Auras[auraId].owntex = false;
		self.Auras[auraId].wowtex = false;
		self.Auras[auraId].textaura = false;
		getglobal("PowaBarAuraTextureSlider"):Hide();
		getglobal("PowaBarCustomTexName"):Show();
		getglobal("PowaBarCustomTexName"):SetText(self.Auras[auraId].customname);
		getglobal("PowaOwntexButton"):SetChecked(false);
		getglobal("PowaWowTextureButton"):SetChecked(false);
		getglobal("PowaTextAuraButton"):SetChecked(false);
		getglobal("PowaBarAurasText"):Hide();
		getglobal("PowaFontsButton"):Hide();
	else
		self.Auras[auraId].customtex = false;
		getglobal("PowaBarAuraTextureSlider"):Show();
		getglobal("PowaBarCustomTexName"):Hide();
	end
	PowaAuras:BarAuraTextureSliderChanged();
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:TextAuraChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaTextAuraButton"):GetChecked()) then
		self.Auras[auraId].textaura = true;
		self.Auras[auraId].owntex = false;
		self.Auras[auraId].wowtex = false;
		self.Auras[auraId].customtex = false;
		getglobal("PowaBarAuraTextureSlider"):Hide();
		getglobal("PowaBarAurasText"):Show();
		getglobal("PowaFontsButton"):Show();
		getglobal("PowaBarAurasText"):SetText(self.Auras[auraId].aurastext);
		getglobal("PowaOwntexButton"):SetChecked(false);
		getglobal("PowaWowTextureButton"):SetChecked(false);
		getglobal("PowaCustomTextureButton"):SetChecked(false);
		getglobal("PowaBarCustomTexName"):Hide();
	else
		self.Auras[auraId].textaura = false;
		getglobal("PowaBarAuraTextureSlider"):Show();
		getglobal("PowaBarAurasText"):Hide();
		getglobal("PowaFontsButton"):Hide();
	end
	self:BarAuraTextureSliderChanged();
	self:RedisplayAura(self.CurrentAuraId);
end

-----------------------------------------------
-- Targets, Party, Raid, ... Checkboxes
-----------------------------------------------

function PowaAuras:TargetChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaTargetButton"):GetChecked()) then
		self.Auras[auraId].target = true;
	else
		self.Auras[auraId].target = false;
	end
	self:InitPage();
end

function PowaAuras:TargetFriendChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaTargetFriendButton"):GetChecked()) then
		self.Auras[auraId].targetfriend = true;
	else
		self.Auras[auraId].targetfriend = false;
	end
	self:InitPage();
end

function PowaAuras:PartyChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaPartyButton"):GetChecked()) then
		self.Auras[auraId].party = true;
	else
		self.Auras[auraId].party = false;
	end
	self:InitPage();
end

function PowaAuras:GroupOrSelfChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaGroupOrSelfButton"):GetChecked()) then
		self.Auras[auraId].groupOrSelf = true;
	else
		self.Auras[auraId].groupOrSelf = false;
	end
	self:InitPage();
end

function PowaAuras:FocusChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaFocusButton"):GetChecked()) then
		self.Auras[auraId].focus = true;
	else
		self.Auras[auraId].focus = false;
	end
	self:InitPage();
end

function PowaAuras:RaidChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaRaidButton"):GetChecked()) then
		self.Auras[auraId].raid = true;
	else
		self.Auras[auraId].raid = false;
	end
	self:InitPage();
end

function PowaAuras:GroupAnyChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaGroupAnyButton"):GetChecked()) then
		self.Auras[auraId].groupany = true;
	else
		self.Auras[auraId].groupany = false;
	end
	self:InitPage();
end

function PowaAuras:OptunitnChecked()
	local auraId = self.CurrentAuraId;
	if (getglobal("PowaOptunitnButton"):GetChecked()) then
		self.Auras[auraId].optunitn = true;		
		getglobal("PowaBarUnitn"):Show();
		getglobal("PowaBarUnitn"):SetText(self.Auras[auraId].unitn);
	else
		self.Auras[auraId].optunitn = false;
		getglobal("PowaBarUnitn"):Hide();
	end
end

------------------------------------------
-- Dropdownmenus
------------------------------------------

function PowaAuras.DropDownMenu_Initialize(owner)
	local info;
	local aura = PowaAuras.Auras[PowaAuras.CurrentAuraId];
	if (aura == nil) then
		aura = PowaAuras:AuraFactory(PowaAuras.BuffTypes.Buff, 0);
	end
	
	if (owner:GetName() == "PowaDropDownAnim1Button" or owner:GetName() == "PowaDropDownAnim1") then
		for i = 1, #(PowaAuras.Anim) do
			info = {}; 
			info.text = PowaAuras.Anim[i]; 
			info.func = PowaAuras.DropDownMenu_OnClickAnim1;
			UIDropDownMenu_AddButton(info);
		end
		UIDropDownMenu_SetSelectedValue(PowaDropDownAnim1, PowaAuras.Anim[aura.anim1]);
	elseif (owner:GetName() == "PowaDropDownAnim2Button" or owner:GetName() == "PowaDropDownAnim2") then
		for i = 0, #(PowaAuras.Anim) do
			info = {}; 
			info.text = PowaAuras.Anim[i]; 
			info.func = PowaAuras.DropDownMenu_OnClickAnim2;
			UIDropDownMenu_AddButton(info);
		end
		UIDropDownMenu_SetSelectedValue(PowaDropDownAnim2, PowaAuras.Anim[aura.anim2]);
	elseif (owner:GetName() == "PowaDropDownStanceButton" or owner:GetName() == "PowaDropDownStance") then
		info = {func = PowaAuras.DropDownMenu_OnClickStance, owner = owner};
		for i = 0, #(PowaAuras.PowaStance) do
			info.text = PowaAuras.PowaStance[i]; 
			info.value = i;
			UIDropDownMenu_AddButton(info);
		end				
		UIDropDownMenu_SetSelectedValue(PowaDropDownStance, PowaAuras.PowaStance[aura.stance]);
		UIDropDownMenu_SetWidth(PowaDropDownStance, 210, 1);
	elseif (owner:GetName() == "PowaDropDownGTFOButton" or owner:GetName() == "PowaDropDownGTFO") then
		info = {func = PowaAuras.DropDownMenu_OnClickGTFO, owner = owner};
		for i = 0, #(PowaAuras.PowaGTFO) do
			info.text = PowaAuras.PowaGTFO[i]; 
			info.value = i;
			UIDropDownMenu_AddButton(info);
		end				
		UIDropDownMenu_SetSelectedValue(PowaDropDownGTFO, PowaAuras.PowaGTFO[aura.GTFO]);
		UIDropDownMenu_SetWidth(PowaDropDownGTFO, 110, 1);
	elseif (owner:GetName() == "PowaDropDownSoundButton" or owner:GetName() == "PowaDropDownSound") then
		info = {func = PowaAuras.DropDownMenu_OnClickSound, owner = owner};
		for i = 0, 29 do
			if (PowaAuras.Sound[i]) then
				info.text = PowaAuras.Sound[i]; 
				info.value = i;
				UIDropDownMenu_AddButton(info);
			end
		end
		if (aura.sound<30) then
			UIDropDownMenu_SetSelectedValue(PowaDropDownSound, PowaAuras.Sound[aura.sound]);	
		else
			UIDropDownMenu_SetSelectedValue(PowaDropDownSound, PowaAuras.Sound[0]);	
		end
		UIDropDownMenu_SetWidth(PowaDropDownSound, 220, 1);
	elseif (owner:GetName() == "PowaDropDownSound2Button" or owner:GetName() == "PowaDropDownSound2") then
		info = {func = PowaAuras.DropDownMenu_OnClickSound, owner = owner};
		for i = 30, #PowaAuras.Sound do
			if (PowaAuras.Sound[i]) then
				info.text = PowaAuras.Sound[i]; 
				info.value = i;
				UIDropDownMenu_AddButton(info);
			end
		end
		if (aura.sound>=30) then
			UIDropDownMenu_SetSelectedValue(PowaDropDownSound2, PowaAuras.Sound[aura.sound]);	
		else
			UIDropDownMenu_SetSelectedValue(PowaDropDownSound2, PowaAuras.Sound[30]);	
		end
		UIDropDownMenu_SetWidth(PowaDropDownSound2, 220, 1);
	elseif (owner:GetName() == "PowaDropDownSoundEndButton" or owner:GetName() == "PowaDropDownSoundEnd") then
		info = {func = PowaAuras.DropDownMenu_OnClickSoundEnd, owner = owner};
		for i = 0, 29 do
			if (PowaAuras.Sound[i]) then
				info.text = PowaAuras.Sound[i]; 
				info.value = i;
				UIDropDownMenu_AddButton(info);
			end
		end
		if (aura.soundend<30) then
			UIDropDownMenu_SetSelectedValue(PowaDropDownSoundEnd, PowaAuras.Sound[aura.soundend]);	
		else
			UIDropDownMenu_SetSelectedValue(PowaDropDownSoundEnd, PowaAuras.Sound[0]);	
		end
		UIDropDownMenu_SetWidth(PowaDropDownSoundEnd, 220, 1);
	elseif (owner:GetName() == "PowaDropDownSound2EndButton" or owner:GetName() == "PowaDropDownSound2End") then
		info = {func = PowaAuras.DropDownMenu_OnClickSoundEnd, owner = owner};
		for i = 30, #PowaAuras.Sound do
			if (PowaAuras.Sound[i]) then
				info.text = PowaAuras.Sound[i]; 
				info.value = i;
				UIDropDownMenu_AddButton(info);
			end
		end
		if (aura.soundend>=30) then
			UIDropDownMenu_SetSelectedValue(PowaDropDownSound2End, PowaAuras.Sound[aura.soundend]);	
		else
			UIDropDownMenu_SetSelectedValue(PowaDropDownSound2End, PowaAuras.Sound[30]);	
		end
		UIDropDownMenu_SetWidth(PowaDropDownSound2End, 220, 1);
	elseif (owner:GetName() == "PowaDropDownAnimBeginButton" or owner:GetName() == "PowaDropDownAnimBegin") then
		info = {func = PowaAuras.DropDownMenu_OnClickBegin, owner = owner}; 
		for i = 0, #PowaAuras.BeginAnimDisplay do
			info.text = PowaAuras.BeginAnimDisplay[i]; 
			info.value = i;
			UIDropDownMenu_AddButton(info);
		end
		UIDropDownMenu_SetSelectedValue(PowaDropDownAnimBegin, PowaAuras.BeginAnimDisplay[aura.begin]);
	elseif (owner:GetName() == "PowaDropDownAnimEndButton" or owner:GetName() == "PowaDropDownAnimEnd") then
		info = {func = PowaAuras.DropDownMenu_OnClickEnd, owner = owner}; 
		for i = 0, #PowaAuras.EndAnimDisplay do
			info.text = PowaAuras.EndAnimDisplay[i]; 
			info.value = i;
			UIDropDownMenu_AddButton(info);
		end
		UIDropDownMenu_SetSelectedValue(PowaDropDownAnimEnd, PowaAuras.EndAnimDisplay[aura.finish]);
	elseif (owner:GetName() == "PowaDropDownBuffTypeButton" or owner:GetName() == "PowaDropDownBuffType") then
		--PowaAuras:Message("DropDownMenu_Initialize for buff type");

		info = {func = PowaAuras.DropDownMenu_OnClickBuffType, owner = owner};
		for _,v in pairs(PowaAuras.BuffTypes) do
			info.text = PowaAuras.Text.AuraType[v];
			info.value = v;
			UIDropDownMenu_AddButton(info);
		end
		
		UIDropDownMenu_SetSelectedValue(PowaDropDownBuffType, aura.bufftype);
	end
end

function PowaAuras.DropDownMenu_OnClickBuffType()
	--PowaAuras:Message("DropDownMenu_OnClickBuffType bufftype ", this.value, " for aura ", PowaAuras.CurrentAuraId, " ", this.owner);

	UIDropDownMenu_SetSelectedValue(this.owner, this.value);

	aura = PowaAuras:AuraFactory(this.value, PowaAuras.CurrentAuraId, PowaAuras.Auras[PowaAuras.CurrentAuraId]);
	aura.icon= "";
	PowaAuras.Auras[PowaAuras.CurrentAuraId] = aura
	if (PowaAuras.CurrentAuraId > 120) then
		PowaGlobalSet[PowaAuras.CurrentAuraId] = aura;
	end				


	if (aura.bufftype == PowaAuras.BuffTypes.TypeDebuff
	 or aura.bufftype == PowaAuras.BuffTypes.AoE
	 or aura.bufftype == PowaAuras.BuffTypes.Enchant
	 or aura.bufftype == PowaAuras.BuffTypes.Combo
	 or aura.bufftype == PowaAuras.BuffTypes.Health
	 or aura.bufftype == PowaAuras.BuffTypes.Mana
	 or aura.bufftype == PowaAuras.BuffTypes.EnergyRagePower
	 or aura.bufftype == PowaAuras.BuffTypes.Aggro
	 or aura.bufftype == PowaAuras.BuffTypes.PvP
	 or aura.bufftype == PowaAuras.BuffTypes.Stance
	 or aura.bufftype == PowaAuras.BuffTypes.GTFO) then
		aura.owntex = false;
	end

	PowaAuras:InitPage();
end


function PowaAuras:ShowSpinAtBeginningChecked(control)
	local aura = self.Auras[self.CurrentAuraId];
	if (control:GetChecked()) then
		aura.beginSpin = true;
	else
		aura.beginSpin = false;
	end
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:OldAnimationChecked(control)
	local aura = self.Auras[self.CurrentAuraId];
	if (control:GetChecked()) then
		aura.UseOldAnimations = true;
	else
		aura.UseOldAnimations = false;
	end
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras.DropDownMenu_OnClickAnim1(owner)
	local optionID = owner:GetID();
	local auraId = PowaAuras.CurrentAuraId;
	--PowaAuras:ShowText("DropDownMenu_OnClickAnim1 optionID=", optionID, " auraId=", auraId);

	UIDropDownMenu_SetSelectedID(PowaDropDownAnim1, optionID); 
	local optionName =  UIDropDownMenu_GetText(PowaDropDownAnim1); 
	UIDropDownMenu_SetSelectedValue(PowaDropDownAnim1, optionName);

	PowaAuras.Auras[auraId].anim1 = optionID;
	PowaAuras:RedisplayAura(auraId);
end

function PowaAuras.DropDownMenu_OnClickAnim2(owner)
	local optionID = owner:GetID();
	local auraId = PowaAuras.CurrentAuraId;

	UIDropDownMenu_SetSelectedID(PowaDropDownAnim2, optionID); 
	local optionName =  UIDropDownMenu_GetText(PowaDropDownAnim2); 
	UIDropDownMenu_SetSelectedValue(PowaDropDownAnim2, optionName);

	PowaAuras.Auras[auraId].anim2 = optionID -1;
	PowaAuras:RedisplayAura(auraId);
end

function PowaAuras.DropDownMenu_OnClickSound()
	--PowaAuras:ShowText("DropDownMenu_OnClickSound n=", this.owner:GetName()," v=",this.value, " t=", PowaAuras.Sound[this.value]);
	UIDropDownMenu_SetSelectedValue(this.owner, this.value);

	if (this.value==0 or this.value==30 or not PowaAuras.Sound[this.value]) then
		PowaAuras.Auras[PowaAuras.CurrentAuraId].sound = 0;
		return; 
	end

	PowaAuras.Auras[PowaAuras.CurrentAuraId].sound = this.value;
	
	if (this.value<30) then
		PowaDropDownSound2Text:SetText(PowaAuras.Sound[30]);
	else
		PowaDropDownSoundText:SetText(PowaAuras.Sound[0]);
	end

	if (string.find(PowaAuras.Sound[this.value], "%.")) then
		PlaySoundFile("Interface\\AddOns\\PowerAuras\\Sounds\\"..PowaAuras.Sound[this.value]);
	else
		PlaySound(PowaAuras.Sound[this.value]);
	end
end


function PowaAuras.DropDownMenu_OnClickSoundEnd()
	--PowaAuras:ShowText("DropDownMenu_OnClickSoundEnd n=", this.owner:GetName()," v=",this.value, " t=", PowaAuras.Sound[this.value]);
	UIDropDownMenu_SetSelectedValue(this.owner, this.value);

	if (this.value==0 or this.value==30 or not PowaAuras.Sound[this.value]) then
		PowaAuras.Auras[PowaAuras.CurrentAuraId].soundend = 0;
		return; 
	end

	PowaAuras.Auras[PowaAuras.CurrentAuraId].soundend = this.value;
	
	if (this.value<30) then
		PowaDropDownSound2EndText:SetText(PowaAuras.Sound[30]);
	else
		PowaDropDownSoundEndText:SetText(PowaAuras.Sound[0]);
	end

	if (string.find(PowaAuras.Sound[this.value], "%.")) then
		PlaySoundFile("Interface\\AddOns\\PowerAuras\\Sounds\\"..PowaAuras.Sound[this.value]);
	else
		PlaySound(PowaAuras.Sound[this.value]);
	end
end

function PowaAuras.DropDownMenu_OnClickStance()
	UIDropDownMenu_SetSelectedValue(this.owner, this.value);
	local auraId = PowaAuras.CurrentAuraId;

	if (PowaAuras.Auras[auraId].stance ~= this.value) then
		PowaAuras.Auras[auraId].stance = this.value;
		PowaAuras.Auras[auraId].icon = "";
	end
	PowaAuras:InitPage();
end

function PowaAuras.DropDownMenu_OnClickGTFO()
	UIDropDownMenu_SetSelectedValue(this.owner, this.value);
	local auraId = PowaAuras.CurrentAuraId;

	if (PowaAuras.Auras[auraId].GTFO ~= this.value) then
		PowaAuras.Auras[auraId].GTFO = this.value;
		PowaAuras.Auras[auraId].icon = "";
	end
	PowaAuras:InitPage();
end

function PowaAuras.DropDownMenu_OnClickBegin(owner)
	UIDropDownMenu_SetSelectedID(this.owner, this.value + 1); 
	local optionName =  UIDropDownMenu_GetText(PowaDropDownAnimBegin); 
	UIDropDownMenu_SetSelectedValue(PowaDropDownAnimBegin, optionName);

	PowaAuras.Auras[PowaAuras.CurrentAuraId].begin = this.value;
	PowaAuras:RedisplayAura(auraId);
end

function PowaAuras.DropDownMenu_OnClickEnd(owner)
	local optionID = owner:GetID();
	local auraId = PowaAuras.CurrentAuraId;

	UIDropDownMenu_SetSelectedID(PowaDropDownAnimEnd, optionID); 
	local optionName =  UIDropDownMenu_GetText(PowaDropDownAnimEnd); 
	UIDropDownMenu_SetSelectedValue(PowaDropDownAnimEnd, optionName);

	PowaAuras.Auras[auraId].finish = optionID - 1;
	PowaAuras:RedisplayAura(auraId);
end

----------------------------------------------------------
-- OPTIONS DEPLACEMENT

function PowaAuras:Bar_MouseDown(owner, button, frmFrame)
	if( button == "LeftButton") then
		getglobal( frmFrame ):StartMoving( );
	end
end

function PowaAuras:Bar_MouseUp(owner, button, frmFrame)
	getglobal( frmFrame ):StopMovingOrSizing( );
end

----------------------------------------------------------
-- COLOR PICKER

function PowaAuras.SetColor()
	PowaAuras:SetAuraColor(ColorPickerFrame:GetColorRGB());
end

function PowaAuras.CancelColor()
	PowaAuras:SetAuraColor(ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g, ColorPickerFrame.previousValues.b);
end

function PowaAuras:SetAuraColor(r, g, b)
	--self:Message("SetColor r=", r, " g=",g, " b=", b);
	local swatch = getglobal("PowaColorNormalTexture"); -- juste le visuel
	local frame = getglobal("PowaColor_SwatchBg");      -- enregistre la couleur
	swatch:SetVertexColor(r,g,b);
	frame.r = r;
	frame.g = g;
	frame.b = b;

	self.Auras[self.CurrentAuraId].r = r;
	self.Auras[self.CurrentAuraId].g = g;
	self.Auras[self.CurrentAuraId].b = b;

	getglobal("AuraTexture"):SetVertexColor(r,g,b);
	self:RedisplayAura(self.CurrentAuraId);
end

function PowaAuras:OpenColorPicker()
	CloseMenus();
	if ColorPickerFrame:IsVisible() then
		PowaAuras.CancelColor();
		ColorPickerFrame:Hide();
	else
		button = getglobal("PowaColor_SwatchBg");

		ColorPickerFrame.func = self.SetColor -- button.swatchFunc;
		ColorPickerFrame:SetColorRGB(button.r, button.g, button.b);
		ColorPickerFrame.previousValues = {r = button.r, g = button.g, b = button.b, opacity = button.opacity};
		ColorPickerFrame.cancelFunc = self.CancelColor
	
		ColorPickerFrame:SetPoint("TOPLEFT", "PowaBarConfigFrame", "TOPRIGHT", 0, 0)
	
		ColorPickerFrame:Show();
	end
end

----------------------------------------------------------
-- FONT SELECTOR

function PowaAuras:FontSelectorOnShow(owner)
	owner:SetBackdropBorderColor(0.9, 1.0, 0.95); 
	owner:SetBackdropColor(0.6, 0.6, 0.6);
end

function PowaAuras:OpenFontSelector(owner)
	CloseMenus();
	
	if (FontSelectorFrame:IsVisible()) then
		getglobal("FontSelectorFrame"):Hide();
	else
		FontSelectorFrame.selectedFont = self.Auras[self.CurrentAuraId].aurastextfont;	
		getglobal("FontSelectorFrame"):Show();
	end
	
end

function PowaAuras:FontSelectorOkay(owner)
	if FontSelectorFrame.selectedFont then
		self.Auras[self.CurrentAuraId].aurastextfont = FontSelectorFrame.selectedFont;
	else
		self.Auras[self.CurrentAuraId].aurastextfont = 1;
	end
	self:RedisplayAura(self.CurrentAuraId);
	self:FontSelectorClose(owner);
end

function PowaAuras:FontSelectorCancel(owner)
	self:FontSelectorClose(owner);
end

function PowaAuras:FontSelectorClose(owner)
	if (FontSelectorFrame:IsVisible()) then
		getglobal("FontSelectorFrame"):Hide();
	end
end

function PowaAuras:FontButton_OnClick(owner)
	FontSelectorFrame.selectedFont = getglobal("FontSelectorEditorScrollButton"..owner:GetID()).font;
	self:FontScrollBar_Update(owner);
end

function PowaAuras.FontScrollBar_Update(owner)
	local fontOffset = FauxScrollFrame_GetOffset(FontSelectorEditorScrollFrame); 
	local fontIndex;
	local fontName, namestart, nameend;
	
	for i=1, 10, 1 do
		fontIndex = fontOffset + i;
		fontName = PowaAuras.Fonts[fontIndex];
		fontText = getglobal("FontSelectorEditorScrollButton"..i.."Text");
		fontButton = getglobal("FontSelectorEditorScrollButton"..i);
		fontButton.font = fontIndex;
		
		namestart = string.find(fontName, "\\", 1, true);
		nameend = string.find(fontName, ".", 1, true);
		if namestart and nameend and (nameend > namestart) then
			fontName = string.sub(fontName, namestart+1, nameend-1);
			while string.find(fontName, "\\", 1, true) do
				namestart = string.find(fontName, "\\", 1, true)
				fontName = string.sub(fontName, namestart+1);
			end
		end	
		fontText:SetFont(PowaAuras.Fonts[fontIndex], 14, "OUTLINE, MONOCHROME");
		fontText:SetText(fontName);
		if FontSelectorFrame.selectedFont == fontIndex then
			fontButton:LockHighlight();
		else
			fontButton:UnlockHighlight();
		end	
	end
	
	FauxScrollFrame_Update(FontSelectorEditorScrollFrame, #PowaAuras.Fonts, 10, 16 );
	
end

----------------------------------------------------------------------
function PowaAuras:EditorShow()
	if (PowaBarConfigFrame:IsVisible()) then
		self:EditorClose();
		return;
	end
	local aura = self.Auras[self.CurrentAuraId];
	if (aura) then
		--if (aura.Timer and aura.Timer.enabled) then
		--	self:CreateTimerFrameIfMissing(aura.id);
		--end
		self:InitPage();
		getglobal("PowaBarConfigFrame"):Show();
		PlaySound("TalentScreenOpen");
	end
end

function PowaAuras:EditorClose() --- ferme la fenetre d'option
	if (PowaBarConfigFrame:IsVisible()) then
		if (FontSelectorFrame:IsVisible()) then
			getglobal("FontSelectorFrame"):Hide();
		end
		if (ColorPickerFrame:IsVisible()) then
			self.CancelColor();
			ColorPickerFrame:Hide();
		end
		getglobal("PowaBarConfigFrame"):Hide();
		PlaySound("TalentScreenClose");
	end
end

-- <<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- <<<<<<<<<<<<<<<<<<< ADV. OPTIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

function PowaAuras:UpdateOptionsTimer(auraId)

	if (self.Initialising) then return; end
	
	local timerOpts = self.Auras[auraId].Timer;
	
    local frame1 = self.TimerFrame[auraId][1];	
	frame1:SetAlpha(math.min(timerOpts.a,0.99));
	frame1:SetWidth(20 * timerOpts.h);
	frame1:SetHeight(20 * timerOpts.h);
	frame1:SetPoint("Center", timerOpts.x, timerOpts.y);

    local frame2 = self.TimerFrame[auraId][2];
	frame2:SetAlpha(timerOpts.a * 0.75);
	frame2:SetWidth(14 * timerOpts.h);
	frame2:SetHeight(14 * timerOpts.h);
	frame2:SetPoint("LEFT", frame1, "RIGHT", 1, -1.5);

end


function PowaAuras:UpdateOptionsStacks(auraId)
	if (self.Initialising) then return; end  
	
	local stackOpts = self.Auras[auraId].Stacks;
	
    local frame = self.StacksFrames[auraId];	
	frame:SetAlpha(math.min(stackOpts.a, 0.99));
	frame:SetWidth(20 * stackOpts.h);
	frame:SetHeight(20 * stackOpts.h);
	frame:SetPoint("Center", stackOpts.x, stackOpts.y);
end

function PowaAuras:ShowTimerChecked(control)
	if (self.Initialising) then return; end
	if (control:GetChecked()) then
		self.Auras[self.CurrentAuraId].Timer.enabled = true;
		--self:CreateTimerFrameIfMissing(self.CurrentAuraId);	
	else
		self.Auras[self.CurrentAuraId].Timer.enabled = false;
		self.Auras[self.CurrentAuraId].Timer:Delete();
	end
end

function PowaAuras:TimerAlphaSliderChanged()
	local SliderValue = getglobal("PowaTimerAlphaSlider"):GetValue();

	if (self.Initialising) then return; end   -- desactived
	
	getglobal("PowaTimerAlphaSliderText"):SetText(self.Text.nomAlpha.." : "..format("%.2f", SliderValue) );

	self.Auras[self.CurrentAuraId].Timer.a = SliderValue;
	--self:CreateTimerFrameIfMissing(self.CurrentAuraId);
end

function PowaAuras:TimerSizeSliderChanged()
	local SliderValue = getglobal("PowaTimerSizeSlider"):GetValue();

	if (self.Initialising) then return; end   -- desactived

	getglobal("PowaTimerSizeSliderText"):SetText(self.Text.nomTaille.." : "..format("%.2f", SliderValue) );

	self.Auras[self.CurrentAuraId].Timer.h = SliderValue;
	--self:CreateTimerFrameIfMissing(self.CurrentAuraId);
end

function PowaAuras:TimerCoordSliderChanged()
	local SliderValue = getglobal("PowaTimerCoordSlider"):GetValue();

	if (self.Initialising) then return; end   -- desactived

	getglobal("PowaTimerCoordSliderText"):SetText(self.Text.nomPos.." Y : "..SliderValue);

	self.Auras[self.CurrentAuraId].Timer.y = SliderValue;
	--self:CreateTimerFrameIfMissing(self.CurrentAuraId);
end

function PowaAuras:TimerCoordXSliderChanged()
	local SliderValue = getglobal("PowaTimerCoordXSlider"):GetValue();

	if (self.Initialising) then return; end   -- desactived

	getglobal("PowaTimerCoordXSliderText"):SetText(self.Text.nomPos.." X : "..SliderValue);

	self.Auras[self.CurrentAuraId].Timer.x = SliderValue;
	--self:CreateTimerFrameIfMissing(self.CurrentAuraId);
end

function PowaAuras:PowaTimerInvertAuraSliderChanged(slider)
	if (self.Initialising) then return; end

	local text;
	if (self.Auras[self.CurrentAuraId].InvertTimeHides) then
		text = self.Text.nomTimerHideAura;
		slider.aide = PowaAuras.Text.aidePowaTimerHideAuraSlider;
	else
		text = self.Text.nomTimerInvertAura;
		slider.aide = PowaAuras.Text.aidePowaTimerInvertAuraSlider;
	end
	getglobal(slider:GetName().."Text"):SetText(text.." : "..slider:GetValue().." sec");

	self.Auras[self.CurrentAuraId].Timer.InvertAuraBelow = slider:GetValue();
	--self:CreateTimerFrameIfMissing(self.CurrentAuraId);
end

function PowaAuras:TimerDurationSliderChanged()
	if (self.Initialising) then return; end
	local SliderValue = getglobal("PowaTimerDurationSlider"):GetValue();

	getglobal("PowaTimerDurationSliderText"):SetText(self.Text.nomTimerDuration.." : "..SliderValue.." sec");

	self.Auras[self.CurrentAuraId].timerduration = SliderValue;
	--self:CreateTimerFrameIfMissing(self.CurrentAuraId);
end

function PowaAuras:TimerChecked(control, setting)
	if (self.Initialising) then return; end
	if (control:GetChecked()) then
		self.Auras[self.CurrentAuraId].Timer[setting] = true;
	else
		self.Auras[self.CurrentAuraId].Timer[setting] = false;
	end
	self.Auras[self.CurrentAuraId].Timer:Delete();
	--self:CreateTimerFrameIfMissing(self.CurrentAuraId);
end

function PowaAuras:SettingChecked(control, setting)
	if (self.Initialising) then return; end
	if (control:GetChecked()) then
		self.Auras[self.CurrentAuraId][setting] = true;
	else
		self.Auras[self.CurrentAuraId][setting] = false;
	end
end

function PowaAuras:TimerTransparentChecked(control)
	if (self.Initialising) then return; end
	if (control:GetChecked()) then
		self.Auras[self.CurrentAuraId].Timer.Transparent = true;
	else
		self.Auras[self.CurrentAuraId].Timer.Transparent = false;
	end
	self.Auras[self.CurrentAuraId].Timer:Delete();
	--self:CreateTimerFrameIfMissing(self.CurrentAuraId);
end

------ Stacks ----

function PowaAuras:ShowStacksChecked(control)
	if (self.Initialising) then return; end
	if (control:GetChecked()) then
		self.Auras[self.CurrentAuraId].Stacks.enabled = true;
	else
		self.Auras[self.CurrentAuraId].Stacks.enabled = false;
		self.Auras[self.CurrentAuraId].Stacks:Delete();
	end
end

function PowaAuras:StacksAlphaSliderChanged()
	local SliderValue = getglobal("PowaStacksAlphaSlider"):GetValue();

	if (self.Initialising) then return; end   -- desactived
	
	getglobal("PowaStacksAlphaSliderText"):SetText(self.Text.nomAlpha.." : "..format("%.2f", SliderValue) );

	self.Auras[self.CurrentAuraId].Stacks.a = SliderValue;
end

function PowaAuras:StacksSizeSliderChanged()
	local SliderValue = getglobal("PowaStacksSizeSlider"):GetValue();

	if (self.Initialising) then return; end   -- desactived

	getglobal("PowaStacksSizeSliderText"):SetText(self.Text.nomTaille.." : "..format("%.2f", SliderValue) );

	self.Auras[self.CurrentAuraId].Stacks.h = SliderValue;
end

function PowaAuras:StacksCoordSliderChanged()
	local SliderValue = getglobal("PowaStacksCoordSlider"):GetValue();

	if (self.Initialising) then return; end   -- desactived

	getglobal("PowaStacksCoordSliderText"):SetText(self.Text.nomPos.." Y : "..SliderValue);

	self.Auras[self.CurrentAuraId].Stacks.y = SliderValue;
end

function PowaAuras:StacksCoordXSliderChanged()
	local SliderValue = getglobal("PowaStacksCoordXSlider"):GetValue();

	if (self.Initialising) then return; end   -- desactived

	getglobal("PowaStacksCoordXSliderText"):SetText(self.Text.nomPos.." X : "..SliderValue);

	self.Auras[self.CurrentAuraId].Stacks.x = SliderValue;
end


function PowaAuras:StacksChecked(control, setting)
	if (self.Initialising) then return; end
	if (control:GetChecked()) then
		self.Auras[self.CurrentAuraId].Stacks[setting] = true;
	else
		self.Auras[self.CurrentAuraId].Stacks[setting] = false;
	end
	self.Auras[self.CurrentAuraId].Stacks:Delete();
end

-- ----------------------------------------------------------- LIGNE DE COMMANDE

function PowaAuras_CommanLine(msg)
	if (msg=="dump") then
		PowaAuras:Dump();
		PowaAuras:Message("State dumped to"); -- OK
		PowaAuras:Message("WTF \\ Account \\ <ACCOUNT> \\ "..GetRealmName().." \\ "..UnitName("player").." \\ SavedVariables \\ PowerAuras.lua"); -- OK
		PowaAuras:Message("You must log-out to save the values to disk (at end of fight/raid is fine)"); -- OK
	elseif (msg=="toggle" or msg=="tog") then
		PowaAuras:Toggle();
	elseif (msg=="showbuffs") then
		PowaAuras:ShowAurasOnUnit("Buffs", "HELPFUL");
	elseif (msg=="showdebuffs") then
		PowaAuras:ShowAurasOnUnit("Debuffs", "HARMFUL");
	else
		PowaAuras:MainOptionShow();
	end
end

function PowaAuras:ShowAurasOnUnit(display, auraType)
	local index = 1;
	local unit = "player";
	if (UnitExists("target")) then
		unit = "target";
	end
	--PowaAuras:Message(display.." on "..unit);
	local Name, _, _, Applications, Type, Duration, Expires, Source, Stealable, shouldConsolidate, spellId = UnitAura(unit, index, auraType);
	while (Name~=nil) do
		--PowaAuras:Message(index..": "..Name.." (SpellID="..spellId..")");
		index = index + 1;
		Name, _, _, Applications, Type, Duration, Expires, Source, Stealable, shouldConsolidate, spellId = UnitAura(unit, index, auraType);
	end
end

------------------------------------
-- Enable/Disable Options Functions
------------------------------------

function PowaAuras:DisableSlider(slider)
	getglobal(slider):EnableMouse(false);
	getglobal(slider.."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	getglobal(slider.."Low"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	getglobal(slider.."High"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function PowaAuras:EnableSlider(slider)
	getglobal(slider):EnableMouse(true);
	getglobal(slider.."Text"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	getglobal(slider.."Low"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	getglobal(slider.."High"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end

function PowaAuras:DisableTextfield(textfield)
	getglobal(textfield):Hide();
	getglobal(textfield.."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function PowaAuras:EnableTextfield(textfield)
	getglobal(textfield):Show();
	getglobal(textfield.."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function PowaAuras:DisableCheckBox(checkBox)
	getglobal(checkBox):Disable();
	getglobal(checkBox.."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function PowaAuras:EnableCheckBox(checkBox, colour)
	--self:ShowText("EnableCheckBox ", checkBox); 
	getglobal(checkBox):Enable();
	if (not colour) then
		colour = NORMAL_FONT_COLOR;
	end
	--self:ShowText("r=", color.r, " g=", color.g, " b=", color.b); 
	getglobal(checkBox.."Text"):SetTextColor(colour.r, colour.g, colour.b);	
end

---- Blizzard Addon -----

function PowaAuras:EnableChecked()
	--PowaAuras:ShowText("EnableChecked");
	if (PowaEnableButton:GetChecked()) then
		self:Toggle(true);
	else
		self:MainOptionClose();
		self:Toggle(false);
	end
end

function PowaAuras:DebugChecked()
	if (PowaDebugButton:GetChecked()) then
		PowaMisc.debug = true;
	else
		PowaMisc.debug = false;
	end
end

function PowaAuras:TimerRoundingChecked()
	if (PowaTimerRoundingButton:GetChecked()) then
		PowaMisc.TimerRoundUp = true;
	else
		PowaMisc.TimerRoundUp = false;
	end
end

function PowaAuras.OptionsOK()
	PowaMisc.OnUpdateLimit = (100 - PowaOptionsUpdateSlider2:GetValue()) / 200;
	local newFps = PowaOptionsAnimationsSlider2:GetValue();
	if (newFps~=PowaMisc.AnimationFps) then
		PowaMisc.AnimationFps = newFps;
		for auraId in pairs(PowaAuras.Auras) do
			PowaAuras:RedisplayAura(auraId);
		end
	end
	PowaMisc.AnimationLimit = (100 - PowaOptionsTimerUpdateSlider2:GetValue()) / 1000;
	PowaAuras:EnableChecked();
	PowaAuras:DebugChecked();
	PowaAuras:TimerRoundingChecked();

	local newDefaultTimerTexture = UIDropDownMenu_GetSelectedValue(PowaDropDownDefaultTimerTexture);
	if (newDefaultTimerTexture~=PowaMisc.DefaultTimerTexture) then
		PowaMisc.DefaultTimerTexture = newDefaultTimerTexture;
		for auraId, aura in pairs(PowaAuras.Auras) do
			if (aura.Timer and aura.Timer.Texture == "Default") then
				aura.Timer:Hide(); -- Options Recreate
				PowaAuras.TimerFrame[auraId] = {};
				PowaAuras:CreateTimerFrame(auraId, 1);
				PowaAuras:CreateTimerFrame(auraId, 2);
			end
		end
	end
	local newDefaultStacksTexture = UIDropDownMenu_GetSelectedValue(PowaDropDownDefaultStacksTexture);
	if (newDefaultStacksTexture~=PowaMisc.DefaultStacksTexture) then
		PowaMisc.DefaultStacksTexture = newDefaultStacksTexture;
		for auraId, aura in pairs(PowaAuras.Auras) do
			if (aura.Stacks and aura.Stacks.Texture == "Default") then
				aura.Stacks:Hide();
				PowaAuras.StacksFrames[auraId].texture:SetTexture(aura.Stacks:GetTexture());
			end
		end
		PowaAuras.StacksFrames = {};
	end
	PowaAuras.ModTest = false;
	PowaAuras.DoCheck.All = true;
end

function PowaAuras.OptionsCancel()
	PowaOptionsCpuFrame2_OnShow();
	PowaAuras.ModTest = false;
	PowaAuras.DoCheck.All = true;
end

function PowaAuras:OptionsDefault()
	PowaMisc.OnUpdateLimit = 0;
	PowaMisc.AnimationLimit = 0;
	PowaMisc.Disabled = false;
	PowaMisc.debug = false;
	PowaOptionsCpuFrame2_OnShow();
end

function PowaOptionsCpuFrame2_OnLoad(panel)
	panel.name = GetAddOnMetadata("PowerAuras", "Title");
	panel.okay = function (self) PowaAuras.OptionsOK();  end;
	panel.cancel = function (self) PowaAuras:OptionsCancel();  end;
	panel.default = function (self) PowaAuras.OptionsDefault();  end;
	InterfaceOptions_AddCategory(panel);
end

function PowaOptionsCpuFrame2_OnShow(hide)
	--PowaAuras:ShowText("PowaOptionsCpuFrame2_OnShow");
	--PowaAuras:ShowText("OnUpdateLimit=", PowaMisc.OnUpdateLimit);
	--PowaAuras:ShowText("AnimationLimit=", PowaMisc.AnimationLimit);
	--PowaAuras:ShowText("Disabled=", PowaMisc.Disabled ~= false);
	--PowaAuras:ShowText("debug=", PowaMisc.debug);
	PowaOptionsUpdateSlider2:SetValue(100-200*PowaMisc.OnUpdateLimit); 
	PowaOptionsAnimationsSlider2:SetValue(PowaMisc.AnimationFps);
	PowaOptionsTimerUpdateSlider2:SetValue(100-1000*PowaMisc.AnimationLimit);
	--PowaAuras:ShowText("Setting Enabled button to: ", PowaMisc.Disabled~=true);
	PowaEnableButton:SetChecked(PowaMisc.Disabled ~= true);
	PowaDebugButton:SetChecked(PowaMisc.debug);
	PowaTimerRoundingButton:SetChecked(PowaMisc.TimerRoundUp);
	UIDropDownMenu_SetSelectedValue(PowaDropDownDefaultTimerTexture, PowaMisc.DefaultTimerTexture);
	UIDropDownMenu_SetSelectedValue(PowaDropDownDefaultStacksTexture, PowaMisc.DefaultStacksTexture);
end

function PowaAuras:PowaOptionsUpdateSliderChanged2(control)
	PowaOptionsUpdateSlider2Text:SetText(self.Text.nomUpdateSpeed.." : "..control:GetValue().."%");
end

function PowaAuras:PowaOptionsAnimationsSliderChanged2(control)
	PowaOptionsAnimationsSlider2Text:SetText(self.Text.nomFPS.." : "..control:GetValue().." FPS");
end

function PowaAuras:PowaOptionsTimerUpdateSliderChanged2(control)
	PowaOptionsTimerUpdateSlider2Text:SetText(self.Text.nomTimerUpdate.." : "..control:GetValue().."%");
end

function PowaAuras.DropDownDefaultTimerMenu_Initialize(owner)
	PowaAuras:InitializeTextureDropdown(owner, PowaAuras.DropDownMenu_OnClickDefault, PowaMisc.DefaultTimerTexture, false);
end

function PowaAuras.DropDownDefaultStacksMenu_Initialize(owner)
	PowaAuras:InitializeTextureDropdown(owner, PowaAuras.DropDownMenu_OnClickDefault, PowaMisc.DefaultStacksTexture, false);
end

function PowaAuras.DropDownMenu_OnClickDefault()
	UIDropDownMenu_SetSelectedValue(this.owner, this.value);
end

function PowaAuras:InitializeTextureDropdown(owner, onClick, currentValue, addDefaultOption)
	--self:ShowText("InitializeTextureDropdown currentValue=", currentValue, " addDefaultOption=", addDefaultOption);
	local info = {func = onClick, owner = owner, text=PowaAuras.Text.Default};
	if (addDefaultOption) then
		UIDropDownMenu_AddButton(info);
	end
	for k,v in pairs(PowaAuras.TimerTextures) do
		info.text = v; 
		UIDropDownMenu_AddButton(info);
	end
	UIDropDownMenu_SetSelectedValue(owner, currentValue);
end


function PowaAuras.DropDownTimerMenu_Initialize(owner)
	local aura = PowaAuras.Auras[PowaAuras.CurrentAuraId];
	if (aura==nil or aura.Timer==nil) then return; end
	PowaAuras:InitializeTextureDropdown(owner, PowaAuras.DropDownMenu_OnClickTimerTexture, aura.Timer.Texture, true);
end

function PowaAuras.DropDownMenu_OnClickTimerTexture()
	UIDropDownMenu_SetSelectedValue(this.owner, this.value);
	local aura = PowaAuras.Auras[PowaAuras.CurrentAuraId];
	if (aura==nil or aura.Timer==nil) then return; end
	aura.Timer.Texture = this.value;
	aura.Timer:Delete();
	--PowaAuras:CreateTimerFrameIfMissing(PowaAuras.CurrentAuraId);
end

function PowaAuras.DropDownStacksMenu_Initialize(owner)
	local aura = PowaAuras.Auras[PowaAuras.CurrentAuraId];
	if (aura==nil or aura.Stacks==nil) then return; end
	PowaAuras:InitializeTextureDropdown(owner, PowaAuras.DropDownMenu_OnClickStacksTexture, aura.Stacks.Texture, true);
end

function PowaAuras.DropDownMenu_OnClickStacksTexture()
	UIDropDownMenu_SetSelectedValue(this.owner, this.value);
	local aura = PowaAuras.Auras[PowaAuras.CurrentAuraId];
	if (aura==nil or aura.Stacks==nil) then return; end
	aura.Stacks.Texture = this.value;
	aura.Stacks:Delete();
end

--- Ternary Logic ---
function PowaAuras:DisableTernary(control)
	getglobal(control:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	control:Disable();
end

function PowaAuras:TernarySetState(button, value)
	local label = getglobal(button:GetName().."Text")
	button:Enable();
	label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

	if value==0 then
		button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		button:SetChecked(0)
	elseif value==false then
		button:SetCheckedTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
		button:SetChecked(1)
	elseif value==true then
		button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		button:SetChecked(1)
	end
end

function PowaAuras.Ternary_OnClick()

	local aura = PowaAuras.Auras[PowaAuras.CurrentAuraId];
	--PowaAuras:ShowText("Ternary_OnClick control=",this:GetName(), " Parameter=", this.Parameter);
	if (aura[this.Parameter]==0) then
		aura[this.Parameter] = true; -- Ignore => On
	elseif (aura[this.Parameter]==true) then
		aura[this.Parameter] = false; -- On => Off
	else
		aura[this.Parameter] = 0; -- Off => Ignore
	end	

	PowaAuras:TernarySetState(this, aura[this.Parameter]);
	PowaAuras.Ternary_CheckTooltip(this)
end

function PowaAuras.Ternary_CheckTooltip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT"); 
	GameTooltip:SetText(PowaAuras.Text.TernaryAide[button.Parameter], nil, nil, nil, nil, 1); 
	GameTooltip:AddLine(PowaAuras.Text.aideTernary.."\n\124TInterface\\Buttons\\UI-CheckBox-Up:22\124t = "..PowaAuras.Text.nomWhatever.."\n\124TInterface\\Buttons\\UI-CheckBox-Check:22\124t = "..PowaAuras.Text.TernaryYes[button.Parameter].."\n\124TInterface\\RAIDFRAME\\ReadyCheck-NotReady:22\124t = "..PowaAuras.Text.TernaryNo[button.Parameter], .8,.8,.8, 1) 
	GameTooltip:Show()
end


function PowaAuras:OptionTest()

	--self:Message("OptionTest for ", self.CurrentAuraId);
	local aura = self.Auras[self.CurrentAuraId];
	if (not aura or aura.buffname == "" or aura.buffname == " ") then
		return;
	end

	if (aura.Showing) then 
		self:SetAuraHideRequest(aura);
		aura.Active = false;
	else
		aura.Active = true;
		aura:CreateFrames();
		self.SecondaryAuras[aura.id] = nil; -- Force recreate
		self:DisplayAura(aura.id);
	end
end

function PowaAuras:OptionTestAll()

	PowaAuras:OptionHideAll(true);
	--self:ShowText("Test All Active Frames now=", now);
	for id, aura in pairs(self.Auras) do
		if (not aura.off) then 
			aura.Active = true;
			aura:CreateFrames();
			self.SecondaryAuras[aura.id] = nil; -- Force recreate
			self:DisplayAura(aura.id);
		end
	end
	
end


function PowaAuras:OptionHideAll(now) --- Hide all auras
	--self:ShowText("Hide All Frames now=", now);
	for id, aura in pairs(self.Auras) do
		aura.Active = false;
		if now then
			--self:ShowText("Hide aura id=", id);
			aura:Hide();
			if (aura.Timer) then aura.Timer:Hide(); end -- Hide All
		else
			self:SetAuraHideRequest(aura);
			if (aura.Timer)  then aura.Timer.HideRequest  = true; end
		end
	end	

end

function PowaAuras:RedisplayAura(auraId) ---Re-show aura after options changed

	if (self.Initialising) then return; end 

	local aura = self.Auras[auraId];
	if (not aura) then
		return;
	end
	--self:ShowText("RedisplayAura auraId=", aura.id, " showing=", aura.Showing);
	local showing = aura.Showing;
	aura:Hide();
	aura.BeginAnimation = nil;
	aura.MainAnimation = nil;
	aura.EndAnimation = nil;
	aura:CreateFrames();
	self.SecondaryAuras[aura.id] = nil; -- Force recreate
	if (showing) then
		self:DisplayAura(aura.id);
	end
end
