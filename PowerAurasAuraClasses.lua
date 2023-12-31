------------cPowaAura----------------
--   cPowaAura is the base class and is not instanced directly, the other classes inherit properties and methods from it
--===========================

cPowaAura = PowaClass(function(aura, id, base)
	--PowaAuras:ShowText("cPowaAura constructor id=", id, " base=", base);
	aura.off = false;
	aura.Debug = nil;
	
	aura.bufftype = PowaAuras.BuffTypes.Buff;
	aura.buffname = "";
	
	aura.texmode = 1;
	aura.wowtex = false;
	aura.customtex = false;
	aura.textaura = false;
	aura.owntex = false;
	aura.realaura = 1;
	aura.texture = 1;
	aura.customname = "";
	aura.aurastext = "";
	aura.aurastextfont = 1;
	aura.icon = "";

	aura.timerduration = 0;
	
	-- Sound Settings
	aura.sound = 0;
	aura.customsound = "";	
	aura.soundend = 0;
	aura.customsoundend = "";	
	
	-- Animation Settings
	aura.begin = 0;
	aura.anim1 = 1;
	aura.anim2 = 0;
	aura.speed = 1.00;
	aura.finish = 1;
	aura.isSecondary = false;
	aura.beginSpin = false;

	aura.duration = 0;
	
	-- Appearance Settings
	aura.alpha = 0.75;
	aura.size = 0.75;
	aura.torsion = 1;
	aura.symetrie = 0;
	aura.x = 0;
	aura.y = -30;
	aura.randomcolor = false;
	aura.r = 1.0;
	aura.g = 1.0;
	aura.b = 1.0;
	
	aura.inverse = false;
	aura.ignoremaj = true;
	aura.exact = false;

	aura.stacks = 0;
	aura.stacksLower = 0;
	aura.stacksOperator = PowaAuras.DefaultOperator;

	aura.threshold = 50;
	aura.thresholdinvert = false;

	aura.mine = false;

	aura.focus = false;
	aura.target = false;
	aura.targetfriend = false;
	aura.raid = false;
	aura.groupOrSelf = false;
	aura.party = false;

	aura.groupany = true;
	aura.optunitn = false;
	aura.unitn = "";

	aura.inRaid = 0;
	aura.inParty = 0;
	aura.ismounted = false;
	aura.isResting = false;
	aura.inVehicle = false;	
	aura.combat = 0;
	aura.isAlive = true;
	aura.PvP = 0;
	
	aura.Instance5Man = 0;
	aura.Instance5ManHeroic = 0;
	aura.Instance10Man = 0;
	aura.Instance10ManHeroic = 0;
	aura.Instance25Man = 0;
	aura.Instance25ManHeroic = 0;
	aura.InstanceBg = 0;
	aura.InstanceArena = 0;
	
	aura.spec1 = true;
	aura.spec2 = true;
	aura.spec3 = true;
	aura.gcd = false;
	aura.stance = 10;
	aura.GTFO = 0;
	aura.multiids = "";
	aura.tooltipCheck = "";
	aura.UseOldAnimations = false;

	if (base) then
		for k, v in pairs (aura) do
			local varType = type(v);
			if (varType == "string"
			 or varType == "boolean"
			 or varType == "number"
			 or k=="ShowOptions"
			 or k=="CheckBoxes"
			 or k=="OptionText"
			 or k=="OptionTernary") then
				if (base[k] ~= nil) then
					aura[k] = base[k];
				end
			end
		end
	end

	aura.Showing = false;
	aura.Active = false;
	aura.HideRequest = false;
	aura.id = id;
	
	if (aura.minDuration) then
		aura.duration = math.max(aura.duration, aura.minDuration);
		--PowaAuras:ShowText("duration ", aura.duration, " minDuration ", aura.minDuration);
	end
	
	--PowaAuras:ShowText("base ", base);

	if (base) then
		local tempForSettings = PowaAuras.AuraClasses[base.bufftype];
		--PowaAuras:ShowText("base.Timer ", base.Timer, " isSecondary ", base.isSecondary);
		if (base.Timer and not aura.isSecondary) then
			aura.Timer = cPowaTimer(aura, base.Timer);
		end				
		
		if (base.Stacks and not base.isSecondary and tempForSettings:StacksAllowed()) then
			aura.Stacks = cPowaStacks(aura, base.Stacks);
		end				
	end
	
	aura:Init();
	
end);

function cPowaAura:Init()
end

function cPowaAura:CustomEvents()
end

function cPowaAura:TimerShowing()
	if (not self.Timer) then return false; end
	return self.Timer.Showing;
end

function cPowaAura:StacksShowing()
	if (not self.Stacks) then return false; end
	return self.Stacks.Showing;
end

function cPowaAura:FullTimerAllowed()
	--PowaAuras:ShowText("TimerAllowed CanHaveTimer", self.CanHaveTimer, " inverse ", self.inverse, " CanHaveTimerOnInverse ", self.CanHaveTimerOnInverse);
	return (self.CanHaveTimer and not self.inverse) or (self.CanHaveTimerOnInverse and self.inverse);
end

function cPowaAura:StacksAllowed()
	return (self.CanHaveStacks and not self.inverse);
end

function cPowaAura:HideShowTabs()
	if (self:StacksAllowed()) then 
		PowaEditorTab5:Show();
		if (not self.Stacks) then
			self.Stacks = cPowaStacks(self);
		end
	else
		PowaEditorTab5:Hide();
		if (self.Stacks) then
			self.Stacks.enabled = false;
		end
	end
end

cPowaAura.TooltipOptions = {r=1.0, g=1.0, b=1.0};
function cPowaAura:AddExtraTooltipInfo(tooltip)
	tooltip:SetText("|cffFFFFFF["..self.id.."] |r"..self.OptionText.typeText, self.TooltipOptions.r, self.TooltipOptions.g, self.TooltipOptions.b, 1);
	if (self.TooltipOptions.showBuffName and self.buffname ~= "???") then
		tooltip:AddLine(self.buffname, nil, nil, nil, nil, 1);
	end
	if (self.TooltipOptions.stacksColour) then
		tooltip:AddLine(PowaAuras.Text.nomStacks..self.stacksOperator..self.stacks, self.TooltipOptions.stacksColour.r, self.TooltipOptions.stacksColour.g, self.TooltipOptions.stacksColour.b, 1);
	end
	if (self.TooltipOptions.showThreshold) then
		tooltip:AddLine(self.threshold, self.TooltipOptions.r, self.TooltipOptions.g, self.TooltipOptions.b, 1);
	end
	if (self.TooltipOptions.showStance) then
		tooltip:AddLine(PowaAuras.PowaStance[self.stance], self.TooltipOptions.r, self.TooltipOptions.g, self.TooltipOptions.b, 1);
	end
	if (self.TooltipOptions.showGTFO) then
		tooltip:AddLine(PowaAuras.PowaGTFO[self.GTFO], self.TooltipOptions.r, self.TooltipOptions.g, self.TooltipOptions.b, 1);
	end
end

function cPowaAura:CreateFrames()
	local frame = self:GetFrame();
	if (frame==nil) then
		--PowaAuras:UnitTestInfo("New Frames", self.id);
		--PowaAuras:UnitTestDebug("Creating frame for aura ", self.id);
		--- Frame --- 
		frame = CreateFrame("Frame","Frame"..self.id, UIParent);
		self:SetFrame(frame);
		
		frame:SetFrameStrata("LOW");
		frame:Hide();  
		
		frame.baseL = 256;
		frame.baseH = 256;
	end
	
	local texture = self:GetTexture();
	if (texture==nil) then
		--PowaAuras:UnitTestInfo("New Texture", self.id);
		if self.textaura then
			--PowaAuras:UnitTestDebug("Creating new textstring texture for aura ", self.id);
			texture = frame:CreateFontString(nil, "OVERLAY");
			texture:ClearAllPoints();
			texture:SetPoint("CENTER",frame);
			texture:SetFont(STANDARD_TEXT_FONT, 20);
			texture:SetTextColor(self.r,self.g,self.b);
			texture:SetJustifyH("CENTER");
		else
			texture = frame:CreateTexture(nil,"BACKGROUND");
			texture:SetBlendMode("ADD");
			texture:SetAllPoints(frame); --- attache la texture a la frame
			frame.texture = texture;
		end
		self:SetTexture(texture);
	else
		if self.textaura then
			--PowaAuras:UnitTestDebug("textaura ", texture:GetObjectType());
			if texture:GetObjectType() == "Texture" then
				--PowaAuras:UnitTestInfo("Converting to textstring texture for aura ", self.id);
				--PowaAuras:UnitTestDebug("Converting to textstring texture for aura ", self.id);
				texture:SetTexture(nil);
				texture = frame:CreateFontString(nil, "OVERLAY");
				texture:ClearAllPoints();
				texture:SetPoint("CENTER",frame);
				texture:SetFont(STANDARD_TEXT_FONT, 20);
				texture:SetTextColor(self.r,self.g,self.b);
				texture:SetJustifyH("CENTER");
				self:SetTexture(texture);
			end
		else
			if texture:GetObjectType() == "FontString" then
				--PowaAuras:UnitTestInfo("Converting from textstring texture for aura ", self.id);
				texture:SetText("");
				texture = frame:CreateTexture(nil,"BACKGROUND");
				texture:SetBlendMode("ADD");	
				texture:SetAllPoints(frame); --- attache la texture a la frame
				frame.texture = texture;
				self:SetTexture(texture);
			end
		end
	end	
	return frame, texture;
end


function cPowaAura:Hide(skipEndAnimationStop)	
	--PowaAuras:UnitTestInfo("Aura.Hide ", self.id);
	--PowaAuras:ShowText("cPowaAura:Hide ", self.id);
	
	if (self.BeginAnimation and self.BeginAnimation:IsPlaying()) then
		self.BeginAnimation:Stop();
	end
	if (self.MainAnimation and self.MainAnimation:IsPlaying()) then
		self.MainAnimation:Stop();
	end
	if (not skipEndAnimationStop and (self.EndAnimation and self.EndAnimation:IsPlaying())) then
		self.EndAnimation:Stop();
	end

	local frame = self:GetFrame();

	if (frame) then
		frame:Hide();
	end

	if (not self.isSecondary) then
		if (self.Timer and (PowaAuras.ModTest or self.off)) then self.Timer:Hide(); end -- Hide Aura
		if (self.Stacks) then self.Stacks:Hide(); end
		local frame = PowaAuras.Frames[self.id];
		if (frame) then
			frame:Hide();
		end
		local secondaryAura = PowaAuras.SecondaryAuras[self.id];
		if (secondaryAura) then
			secondaryAura:Hide();
		end
	end

	self.Showing = false;
end

function cPowaAura:AddEffect()
	table.insert(PowaAuras.AurasByType[self.AuraType], self.id);
end

function cPowaAura:IsPlayerAura()
	return 	(not self.target) 
		and (not self.targetfriend)
		and (not self.party)
		and (not self.raid) 
		and (not (self.groupOrSelf and (GetNumPartyMembers()>0 or GetNumRaidMembers()>0))) 
		and (not self.focus)
		and (not self.optunitn);
end

function cPowaAura:ShowTimerDurationSlider()
	return false;
end

function cPowaAura:IconIsRequired()
	--PowaAuras:Message("  owntex=",self.owntex, " .icon=",self.icon, " IconRequired=",self.IconRequired);
	return (self.owntex == true or self.icon == "" or self.IconRequired);
end

function cPowaAura:SetIcon(texturePath)
	if (texturePath==nil or string.len(texturePath)==0 or not self:IconIsRequired()) then
		return;
	end
	if (texturePath ~= self.icon) then
		if (self.owntex) then
			local texture = self:GetTexture();
			if (texture) then
				texture:SetTexture(texturePath);
			end
		end
		self.icon = texturePath;
	end
	self.IconRequired = nil;
end

function cPowaAura:CheckState(giveReason)
	
	--- player aura but player is dead
	if (self:IsPlayerAura() and ((PowaAuras.WeAreAlive == true and self.isAlive == false) or (PowaAuras.WeAreAlive == false and self.isAlive == true))) then
		if (not giveReason) then return false; end
		if (PowaAuras.WeAreAlive == false) then
			return false, PowaAuras.Text.nomReasonPlayerDead;
		else
			return false, PowaAuras.Text.nomReasonPlayerAlive;
		end
	end
	
	--- target checks
	if (not self.targetfriend or self.AuraType~="SpellAlert") then
		if (self.target or self.targetfriend) then
			if (UnitName("target") == nil) then
				if (not giveReason) then return false; end
				return false, PowaAuras.Text.nomReasonNoTarget;
			end
			if (UnitName("target") == UnitName("player")) then
				if (not giveReason) then return false; end
				return false, PowaAuras.Text.nomReasonTargetPlayer;
			end		
			local targetIsDead = UnitIsDead("target");
			if ((targetIsDead and self.isAlive == true) or (not PowaAuras.targetIsDead and self.isAlive == false)) then
				if (not giveReason) then return false; end
				if (targetIsDead) then
					return false, PowaAuras.Text.nomReasonTargetDead;
				end
				return false, PowaAuras.Text.nomReasonTargetAlive;
			end
		end
					
		--- regarde si la cible est ennemie
		if (self.target and self.targetfriend == false and UnitIsFriend("player","target")) then --- cible amie alors que faut pas
			if (not giveReason) then return false; end
			return false, PowaAuras.Text.nomReasonTargetFriendly;
		end
			
		--- regarde si la cible est amie
		if (self.target == false and self.targetfriend and not UnitIsFriend("player","target")) then --- cible ennemie
			if (not giveReason) then return false; end
			return false, PowaAuras.Text.nomReasonTargetNotFriendly;
		end
	end
	
	--- party
	if (self.party and not ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0))) then --- partycheck yes, but not in party
		if (not giveReason) then return false; end
		return false, PowaAuras.Text.nomReasonNotInParty;
	end
        
    --- focus
	if (self.focus and (UnitName("focus") == nil or UnitName("focus") == UnitName("player"))) then --- focuscheck
		if (not giveReason) then return false; end
		return false, PowaAuras.Text.nomReasonNoFocus;
	end
        
    --- unit
	if (self.optunitn and not ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0) or UnitExists("pet"))) then --- Unitn yes, but not in party/raid or with pet
		if (not giveReason) then return false; end
		return false, self:InsertText(self.Text.nomReasonNoCustomUnit, self.unitn);
	end
        
    --- raid
	if (self.raid and numrm == 0) then --- raidcheck yes, but not in raid
		if (not giveReason) then return false; end
		return false, PowaAuras.Text.nomReasonNotInRaid;
	end

	--- dual spec check
	if ((not self.spec2 and PowaAuras.ActiveTalentGroup == 2) or (not self.spec1 and PowaAuras.ActiveTalentGroup == 1)  or (not self.spec3 and PowaAuras.ActiveTalentGroup == 3)) then
            if (not giveReason) then return false; end
            return false, PowaAuras.Text.nomReasonNotForTalentSpec;
        end
	
	--- mode combat
	if ((PowaAuras.WeAreInCombat == true and self.combat == false) or (PowaAuras.WeAreInCombat == false and self.combat == true)) then
		if (not giveReason) then return false; end
		if (self.combat == true) then
			return false, PowaAuras.Text.nomReasonNotInCombat;
		end
		return false, PowaAuras.Text.nomReasonInCombat;		
	end

	--if (self.PvP==true) then
	--	PowaAuras:ShowText("PvPFlagSet=", PowaAuras.PvPFlagSet, " aura.PvP=", self.PvP);
	--end
	
	if ((PowaAuras.PvPFlagSet == 1 and self.PvP == false) or (PowaAuras.PvPFlagSet ~= 1 and self.PvP == true)) then
		if (not giveReason) then return false; end
		if (self.PvP == true) then
			return false, PowaAuras.Text.nomReasonPvPFlagNotSet;
		end
		return false, PowaAuras.Text.nomReasonPvPFlagSet;		
	end
		
	if ((PowaAuras.WeAreInRaid == true and self.inRaid == false) or (PowaAuras.WeAreInRaid == false and self.inRaid == true)) then
		if (not giveReason) then return false; end
		if (self.inRaid == true) then
			return false, PowaAuras.Text.nomReasonNotInRaid;
		end
		return false, PowaAuras.Text.nomReasonInRaid;		
	end
		
	if ((PowaAuras.WeAreInParty == true and self.inParty == false) or (PowaAuras.WeAreInParty == false and self.inParty == true)) then
		if (not giveReason) then return false; end
		if (self.inParty == true) then
			return false, PowaAuras.Text.nomReasonNotInParty;
		end
		return false, PowaAuras.Text.nomReasonInParty;		
	end
		
	if ((PowaAuras.WeAreMounted == true and self.ismounted == false) or (PowaAuras.WeAreMounted == false and self.ismounted == true)) then
		if (not giveReason) then return false; end
		if (self.ismounted == true) then
			return false, PowaAuras.Text.nomReasonNotMounted;
		end
		return false, PowaAuras.Text.nomReasonMounted;		
	end
		
	if ((PowaAuras.WeAreInVehicle == true and self.inVehicle == false) or (PowaAuras.WeAreInVehicle == false and self.inVehicle == true)) then
		if (not giveReason) then return false; end
		if (self.inVehicle == true) then
			return false, PowaAuras.Text.nomReasonNotInVehicle;
		end
		return false, PowaAuras.Text.nomReasonInVehicle;		
	end
	
	-- Instance checks
	--PowaAuras:ShowText("Instance ", PowaAuras.Instance);
	--PowaAuras:ShowText("  Instance5Man ", self.Instance5Man);
	local show, reason;
	
	show, reason = self:ShouldShowForInstanceType("5Man", giveReason);
	if (not show) then return show, reason; end
	
	show, reason = self:ShouldShowForInstanceType("5ManHeroic", giveReason);
	if (not show) then return show, reason; end
	
	show, reason = self:ShouldShowForInstanceType("10Man", giveReason);
	if (not show) then return show, reason; end
	
	show, reason = self:ShouldShowForInstanceType("10ManHeroic", giveReason);
	if (not show) then return show, reason; end
	
	show, reason = self:ShouldShowForInstanceType("25Man", giveReason);
	if (not show) then return show, reason; end
	
	show, reason = self:ShouldShowForInstanceType("25ManHeroic", giveReason);
	if (not show) then return show, reason; end
	
	show, reason = self:ShouldShowForInstanceType("Bg", giveReason);
	if (not show) then return show, reason; end
	
	show, reason = self:ShouldShowForInstanceType("Arena", giveReason);
	if (not show) then return show, reason; end
	
	-- It's not dead it's restin'
	if ((self.isResting==false and IsResting()==1 and not PowaAuras.WeAreInCombat) or (self.isResting==true and (IsResting()~=1))) then	
		if (not giveReason) then return false; end
		if (self.isResting == true) then
			return false, PowaAuras.Text.nomReasonNotResting;
		end
		return false, PowaAuras.Text.nomReasonResting;		
	end	
	
	if (not giveReason) then return true; end
	return true, PowaAuras.Text.nomReasonStateOK;
end

function cPowaAura:ShouldShowForInstanceType(instanceType, giveReason)
	local flag = "Instance"..instanceType;
	--PowaAuras:ShowText(PowaAuras.Instance, "  ", instanceType, "  ", flag, "=", self[flag]);
	if ((PowaAuras.Instance==instanceType and self[flag] == false) or (PowaAuras.Instance~=instanceType and self[flag] == true)) then
		if (not giveReason) then return false; end
		if (self[flag] == true) then
			return false, PowaAuras.Text["nomReasonNotIn"..instanceType.."Instance"];
		end
		return false, PowaAuras.Text["nomReasonIn"..instanceType.."Instance"];		
	end
	return true;
end

function cPowaAura:ShouldShow(giveReason, reverse)
	----PowaAuras:UnitTestInfo("ShouldShow", self.id);
	--PowaAuras:ShowText("ShouldShow", self.id);
	if (PowaMisc.Disabled) then
		return false,  PowaAuras.Text.nomReasonDisabled;
	end
	--PowaAuras.AuraCheckCount = PowaAuras.AuraCheckCount + 1;
	local stateResult, reason = self:CheckState(giveReason);	
	if (not stateResult) then
		self.InactiveDueToState = true;
		return stateResult, reason;
	end
	--PowaAuras.AuraCheckShowCount = PowaAuras.AuraCheckShowCount + 1;
	self.InactiveDueToState = false;
	local result, reason = self:CheckIfShouldShow(giveReason);
	--PowaAuras:ShowText("ShouldShow result=",result, " inv=", self.inverse, " rev=", reverse);
	if (result==-1) then
		return result, reason;
	end
	if (result~=nil and (self.inverse or reverse) and not (self.inverse and reverse)) then
		result = not result;
		if (giveReason) then
			reason = PowaAuras:InsertText(PowaAuras.Text.nomReasonInverted, reason);
		end
	end
	return result, reason;
end

function cPowaAura:Display()
	PowaAuras:Message("Aura Display id=", self.id); --OK
	for k,v in pairs (self) do
		PowaAuras:Message("  "..tostring(k).." = "..tostring(v)); --OK
	end
end

function cPowaAura:GetFrame()
	if (self.isSecondary) then
		return PowaAuras.SecondaryFrames[self.id];
	end
	return PowaAuras.Frames[self.id];
end

function cPowaAura:GetTexture()
	if (self.isSecondary) then
		return PowaAuras.SecondaryTextures[self.id];
	end
	return PowaAuras.Textures[self.id];
end

function cPowaAura:SetFrame(frame)
	if (self.isSecondary) then
		PowaAuras.SecondaryFrames[self.id] = frame;
		return;
	end
	PowaAuras.Frames[self.id] = frame;
end

function cPowaAura:SetTexture(texture)
	if (self.isSecondary) then
		PowaAuras.SecondaryTextures[self.id] = texture;
		return;
	end
	PowaAuras.Textures[self.id] = texture;
end

function cPowaAura:GetSpellNameFromMatch(spellMatch)
	local _, _,spellId = string.find(spellMatch, "%[(%d+)%]")
	if (spellId) then		
		local spellName, rank, spellIcon = GetSpellInfo(tonumber(spellId));
		return spellName, spellIcon;
	end
	return spellMatch;
end

function cPowaAura:SetStacks(text)
	local _, _,curStacksLower, curOperator, curStacks = string.find(text, "(%d*)(%D+)(%d*)")

	if (curStacks == nil or curStacks == "") then curStacks = "0"; end
	local stacks = tonumber(curStacks);
	--PowaAuras:Debug(stacks);
		
	if (stacks ~= self.stacks) then
		if (stacks > 100) or (stacks < 0) then stacks = 0; end
		self.stacks = stacks or 0;
	end
	
	if (curStacksLower == nil or curStacksLower == "") then curStacksLower = "0"; end
	local stacksLower = tonumber(curStacksLower);
	--PowaAuras:Debug(stacksLower);
	
	if (stacksLower ~= self.stacksLower) then
		if (stacksLower > 100) or (stacksLower < 0) or (stacksLower > stacks) then stacksLower = 0; end
		self.stacksLower = stacksLower or 0;
	end
	
	if (curOperator ~= self.stacksOperator) then
		if (not PowaAuras.allowedOperators[curOperator]) then
			curOperator = PowaAuras.DefaultOperator;
		end	
		self.stacksOperator = curOperator;
	end	
end

function cPowaAura:Trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"));
end

function cPowaAura:MatchSpell(spellName, spellTexture, textToFind)
	if (spellName==nil or textToFind==nil) then
		return false;
	end
	if (textToFind=="*") then
		return true;
	end
	if (self.Debug) then
		PowaAuras:Message("  MatchSpell spellName   =",spellName); --OK
		--PowaAuras:Message("             spellTexture=",spellTexture); --OK
		PowaAuras:Message("             textToFind  =",textToFind); --OK
	end
	for pword in string.gmatch(textToFind, "[^/]+") do
		pword = self:Trim(pword);
		if (string.len(pword)>0) then
			local textToSearch;
			local textureMatch;
			if string.find(pword, "_") then
				 _, _,textToSearch = string.find(spellTexture, "([%w_]*)$")
			else
				textToSearch = spellName;
				pword, textureMatch = self:GetSpellNameFromMatch(pword);
			end
			--PowaAuras:ShowText("textureMatch=", textureMatch);
			if (not textureMatch or textureMatch==spellTexture) then
				if (textToSearch) then
					if (self.ignoremaj) then
						textToSearch = string.upper(textToSearch)
						pword = string.upper(pword);
					end
					if (self.Debug) then
						PowaAuras:Message("pword="..tostring(pword).."<<");
						PowaAuras:Message("search="..tostring(textToSearch).."<<");
					end
					if (self.exact) then
						if (self.Debug) then
							PowaAuras:Message("exact=", (textToSearch == pword)); --OK
						end
						if (textToSearch == pword) then
							return true;
						end
					else
						if (self.Debug) then
							PowaAuras:Message("find=", string.find(textToSearch, pword, 1, true)); --OK
						end
						if (string.find(textToSearch, pword, 1, true)) then
							return true;
						end
					end
				end
			end
		end
	end

	return nil;
end

function cPowaAura:MatchText(textToSearch, textToFind)
	if (textToSearch==nil or textToFind==nil) then
		return false;
	end
	if (textToFind=="*") then
		return true;
	end
	if (self.Debug) then
		PowaAuras:Message("MatchText textToSearch=",textToSearch," textToFind=",textToFind); --OK
	end
	if (self.ignoremaj) then
		textToFind = string.upper(textToFind);
		textToSearch = string.upper(textToSearch);
	end
	if (self.Debug) then
		PowaAuras:Message("MatchText textToSearch=",textToSearch," textToFind=",textToFind, " ignoremaj=", self.ignoremaj, " exact=", self.exact); --OK
	end
	for pword in string.gmatch(textToFind, "[^/]+") do	
		if (self.Debug) then
			PowaAuras:Message("pword=", pword," find=",string.find(textToSearch, pword, 1, true)); --OK
		end
		if (self.exact and textToSearch == textToFind) then
			return true;
		elseif (string.find(textToSearch, pword, 1, true)) then
			return true;
		end
	end
	return nil;
end

function cPowaAura:CreateAuraString(keepLink)
	local tempstr = "Version:st"..PowaMisc.Version.."; ";
	local varpref = "";
	for k, v in pairs (self) do
		--- multi condition checks not supported for export.
		if ((k == "multiids" and not keepLink) or k=="Debug") then
			v = "";
		end
		local varType = type(v);
		if (varType == "string" or varType == "boolean" or varType == "number") then
			tempstr = tempstr..k..":"..string.sub(varType,1,2)
			if (varType == "string") then
				tempstr = tempstr..v;
			else
				tempstr = tempstr..tostring(v);
			end
			tempstr = tempstr.."; ";
		end
	end
	if (self.Timer and self.Timer.enabled) then
		for k, v in pairs (self.Timer) do
			local varType = type(v);
			if (varType == "string" or varType == "boolean" or varType == "number") then
				tempstr = tempstr.."timer."..k..":"..string.sub(varType,1,2);
				if (varType == "string") then
					tempstr = tempstr..v;
				else
					tempstr = tempstr..tostring(v);
				end
				tempstr = tempstr.."; ";
			end
		end
	end
	if (self.Stacks and self.Stacks.enabled) then
		for k, v in pairs (self.Stacks) do
			local varType = type(v);
			if (varType == "string" or varType == "boolean" or varType == "number") then
				tempstr = tempstr.."stacks."..k..":"..string.sub(varType,1,2);
				if (varType == "string") then
					tempstr = tempstr..v;
				else
					tempstr = tempstr..tostring(v);
				end
				tempstr = tempstr.."; ";
			end
		end
	end

	if tempstr and tempstr ~= "" then
		tempstr = strtrim(tempstr);
		tempstr = string.sub(tempstr, 1, string.len(tempstr)-1);
	end
	--PowaAuras:Debug("Aura-string length: "..tostring(string.len(tempstr)));
	return tempstr;
end

function cPowaAura:GetUnit()
	if (self.target or self.targetfriend) then
		return "target";
	elseif (self.focus) then
		return "focus";
	elseif (self.party) then
		return "party";
	elseif (self.raid) then
		return "raid";
	elseif (self.groupOrSelf) then
		return "groupOrSelf";
	elseif (self.optunitn) then
		return self.unitn;
	else 
		return "player";
	end	
	return nil;
end

function cPowaAura:CheckAllUnits(giveReason)
	local unit = self:GetUnit();		
	--PowaAuras:Debug("on unit "..unit);
	local numpm = GetNumPartyMembers();
	local numrm = GetNumRaidMembers();

	if unit == "party" then
		for pm = 1, numpm do
			unit = "party"..pm;
			if self:CheckUnit(unit) then
				if (not giveReason) then return true; end
				return true, PowaAuras:InsertText(PowaAuras.Text.ReasonStat[self.ValueName].MatchReason, unit);
			end
		end
	elseif unit == "raid" then
		for rm = 1, numrm do
			unit = "raid"..rm;
			if self:CheckUnit(unit) then
				if (not giveReason) then return true; end
				return true, PowaAuras:InsertText(PowaAuras.Text.ReasonStat[self.ValueName].MatchReason, unit);
			end
		end
	elseif  unit == "groupOrSelf" then
		if (numrm>0) then
			for rm = 1, numrm do
				unit = "raid"..rm;
				if self:CheckUnit(unit) then
					if (not giveReason) then return true; end
					return true, PowaAuras:InsertText(PowaAuras.Text.ReasonStat[self.ValueName].MatchReason, unit);
				end
			end
		elseif (numpm>0) then
			for pm = 1, numpm do
				unit = "party"..pm;
				if self:CheckUnit(unit) then
					if (not giveReason) then return true; end
					return true, PowaAuras:InsertText(PowaAuras.Text.ReasonStat[self.ValueName].MatchReason, unit);
				end
			end
			if self:CheckUnit("player") then
				if (not giveReason) then return true; end
				return true, PowaAuras:InsertText(PowaAuras.Text.ReasonStat[self.ValueName].MatchReason, unit);
			end
		end
	else
		if self:CheckUnit(unit) then
			if (not giveReason) then return true; end
			return true, PowaAuras:InsertText(PowaAuras.Text.ReasonStat[self.ValueName].MatchReason, unit);
		end
	end
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.ReasonStat[self.ValueName].NoMatchReason, unit);
end

function cPowaAura:CheckStacks(count)
	local operator = self.stacksOperator or PowaAuras.DefaultOperator;
	local stacks = self.stacks or 0;
	local stacksLower = self.stacksLower or 0;
	--PowaAuras:Debug("Stack op=",operator," stacks=",stacks,"Stack Count=",count);
	return    ((operator == "="  and stacks == 0)
			or (operator == ">=" and count >= stacks)
			or (operator == "<=" and count <= stacks)
			or (operator == ">"  and count > stacks)
			or (operator == "<"  and count < stacks)
			or (operator == "="  and count == stacks)
			or (operator == "-"  and count >= stacksLower and count <= stacks)
			or (operator == "!"  and count ~= stacks));
end

function cPowaAura:StacksText()
	local stacksText = self.stacksOperator..tostring(self.stacks);
	if (self.stacksOperator=="-") then
		stacksText =  tostring(self.stacksLower)..stacksText;
	end
	return stacksText;
end

function cPowaAura:CheckTimerInvert()
	if (PowaAuras.ModTest or self.Timer.InvertAuraBelow==nil or self.Timer.InvertAuraBelow==0 or self.InvertTest) then
		return;
	end

	local timeValue = 0;
	if (self.Timer.DurationInfo and self.Timer.DurationInfo > 0) then
		timeValue = math.max(self.Timer.DurationInfo - GetTime(), 0);
	end
	
	if (PowaAuras.DebugCycle or self.Debug) then
		PowaAuras:DisplayText("=================");
		PowaAuras:DisplayText("CheckTimerInvert");
		PowaAuras:DisplayText("id=",self.id);
		PowaAuras:DisplayText("timeValue=",timeValue);
		PowaAuras:DisplayText("InvertAuraBelow=",self.Timer.InvertAuraBelow);
		PowaAuras:DisplayText("ForceTimeInvert=",self.ForceTimeInvert);
		PowaAuras:DisplayText("InvertTimeHides=",self.InvertTimeHides);
	end
	
	local oldForceTimeInvert = self.ForceTimeInvert;
	if (timeValue and timeValue > 0 and ((not self.InvertTimeHides and timeValue<=self.Timer.InvertAuraBelow))
									or (self.InvertTimeHides and timeValue>=self.Timer.InvertAuraBelow) ) then
		self.ForceTimeInvert = true;
	else
		self.ForceTimeInvert = nil;
	end
	if (oldForceTimeInvert ~= self.ForceTimeInvert) then
		self.InvertTest = true; -- To prevent infinite loop
		--PowaAuras:ShowText("Change in ForceTimeInvert=", self.ForceTimeInvert);
		PowaAuras:TestThisEffect(self.id);
		self.InvertTest = nil;
	end
end
				
cPowaBuffBase = PowaClass(cPowaAura, {CanHaveTimer=true, CanHaveStacks=true, CanHaveInvertTime=true, InvertTimeHides=true});

function cPowaBuffBase:AddEffect()

	if not self.target 
   and not self.targetfriend 
   and not self.party
   and not self.raid 
   and not self.groupOrSelf
   and not self.focus
   and not self.optunitn then --- self-buff
		table.insert(PowaAuras.AurasByType.Buffs, self.id);
	end
	if self.party then --- party buffs
		table.insert(PowaAuras.AurasByType.PartyBuffs, self.id);
	end
	if self.focus then --- focus buffs
		table.insert(PowaAuras.AurasByType.FocusBuffs, self.id);
	end
	if self.raid then --- raid buffs
		table.insert(PowaAuras.AurasByType.RaidBuffs, self.id);
	end
	if self.groupOrSelf then --- groupOrSelf buffs
		table.insert(PowaAuras.AurasByType.GroupOrSelfBuffs, self.id);
	end
	if self.optunitn then --- unit buffs
		table.insert(PowaAuras.AurasByType.UnitBuffs, self.id);
	end
	if (self.target or self.targetfriend) then --- target buff
		table.insert(PowaAuras.AurasByType.TargetBuffs, self.id);
	end			
end

function cPowaBuffBase:IsPresent(unittarget, s, giveReason, textToCheck)

	--PowaAuras:Debug("IsPresent on ",unittarget,"  buffid ",s," type", self.buffAuraType);
	--PowaAuras.BuffSlotCount = PowaAuras.BuffSlotCount + 1;

	local auraName, _, auraTexture, count, _, _, expirationTime, caster = UnitAura(unittarget, s, self.buffAuraType);
	
	if (auraName == nil) then return nil; end

	--PowaAuras:Debug("Aura=",auraName," count=",count," expirationTime=", expirationTime," caster=",caster);

	if (not self:CompareAura(unittarget, s, auraName, auraTexture, textToCheck)) then
		--PowaAuras:Debug("CompareAura not found");
		return false;
	end
	
	local isMine = (caster~=nil) and UnitExists(caster) and UnitIsUnit("player", caster);
	local bemine = self.mine;
	--PowaAuras:ShowText("Bemine=",bemine," isMine=",isMine);
	if (bemine and not isMine) then
		if (not giveReason) then return nil; end
		return nil, PowaAuras.Text.nomReasonBuffPresentNotMine;
	end
	
	if (not self:CheckStacks(count)) then
		if (giveReason) then return nil, PowaAuras:InsertText(PowaAuras.Text.nomReasonStacksMismatch, count, self:StacksText()); end
		return nil;
	end
	if (self.Stacks) then
		self.Stacks:SetStackCount(count);
	end			
	--PowaAuras:ShowText("Present!");
	if (self.Timer) then
		self.Timer:SetDurationInfo(expirationTime);
		self:CheckTimerInvert();
		if (self.ForceTimeInvert) then
			if (not giveReason) then return false; end
			return false, PowaAuras.Text.nomReasonBuffPresentTimerInvert;
		end
	end
	if (giveReason) then return true, PowaAuras.Text.nomReasonBuffFound; end
	return true;
end	

function cPowaBuffBase:CheckTooltip(text, target, index)
	if (text==nil or string.len(text) == 0) then
		return true;
	end

	--PowaAuras:Debug("Search in tooltip for ",text);

	PowaAuras_Tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	PowaAuras_Tooltip:SetUnitAura(target, index, self.buffAuraType);
	
	for z = 1, PowaAuras_Tooltip:NumLines() do
		--PowaAuras:UnitTestDebug("Check tooltip line ",z);
		local textlinel = getglobal("PowaAuras_TooltipTextLeft"..z);
		local textl = textlinel:GetText();
		local tooltipText = "";
		if textl then
			tooltipText = tooltipText..textl;
		end
		local textliner = getglobal("PowaAuras_TooltipTextRight"..z);
		local textr = textliner:GetText();
		if textr then
			tooltipText = tooltipText..textr;
		end
		if (tooltipText ~= "") then
			--PowaAuras:UnitTestDebug("| "..text.." |");		
			if (string.find(tooltipText, text, 1, true)) then
				PowaAuras_Tooltip:Hide();
				return true;
			end
		end
	end	
	PowaAuras_Tooltip:Hide();
	return false;
end

function cPowaBuffBase:CompareAura(target, z, auraName, auraTexture, textToCheck)
	
	--PowaAuras:Debug("CompareAura",z," ",auraName, auraTexture);
	
	if self:MatchSpell(auraName, auraTexture, textToCheck) then
		--PowaAuras:UnitTestDebug("Aura match found! ", self.id);
		if (not self:CheckTooltip(self.tooltipCheck, target, z)) then
			--PowaAuras:UnitTestDebug("Tooltip no match found!");
			return false;
		end
		self:SetIcon(auraTexture);
		return true;	
	end
	return false;
end

function cPowaBuffBase:CheckAllAuraSlots(target, giveReason)
	--PowaAuras:UnitTestDebug("-------------");
	--PowaAuras:UnitTestDebug("CheckAllAuraSlots for ", target);
	--PowaAuras.BuffUnitCount = PowaAuras.BuffUnitCount + 1;
	local present, reason;
	local startFrom = 0;
	if (self.CurrentSlot and self.CurrentMatch) then
		--PowaAuras:ShowText("buff for current slot (", self.CurrentSlot, ")");
		present, reason = self:IsPresent(target, self.CurrentSlot, giveReason, self.CurrentMatch);
		if (present) then
			--PowaAuras:ShowText("Found again ", self.CurrentSlot);
			if (not giveReason) then return true; end
			return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonBuffPresent, target, self.auraType, self.buffname);
		end	
		startFrom = self.CurrentSlot;
		self.CurrentSlot = nil;
		self.CurrentMatch = nil;
	end
	if (not startFrom) then startFrom = 0; end
	for pword in string.gmatch(self.buffname, "[^/]+") do
		for i = startFrom - 1, 1, -1 do
			--PowaAuras:ShowText("Buff for slot down (", i, ") ", pword);
			present, reason = self:IsPresent(target, i, giveReason, pword);
			if (present) then
				--PowaAuras:UnitTestDebug("CheckAllAuraSlots Present!");
				--PowaAuras:ShowText("Found ", i);
				self.CurrentSlot = i;
				self.CurrentMatch = pword;
				if (not giveReason) then return true; end
				return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonBuffPresent, target, self.auraType, self.buffname);
			end	
		end
		for i = startFrom + 1, 40 do
			--PowaAuras:ShowText("Buff for slot up (", i, ") ", pword);
			present, reason = self:IsPresent(target, i, giveReason, pword);
			if (present==nil) then
				break;
			end
			if (present) then
				--PowaAuras:UnitTestDebug("CheckAllAuraSlots Present!");
				--PowaAuras:ShowText("Found ", i);
				self.CurrentSlot = i;
				self.CurrentMatch = pword;
				if (not giveReason) then return true; end
				return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonBuffPresent, target, self.auraType, self.buffname);
			end	
		end
	end
	if (present==nil) then
		if (not giveReason) then return false; end
		if (reason) then
			return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonBuffFoundButIncomplete, target, self.auraType, self.buffname, reason);
		end
		return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonBuffMissing, target, self.auraType, self.buffname);
	end
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonBuffMissing, target, self.auraType, self.buffname);
end

function cPowaBuffBase:CheckSingleUnit(group, unit, giveReason)
	if (not unit) then return; end
	local present = self:CheckAllAuraSlots(unit, false);
	if (present) then
		if (self.groupany == true) then
			--PowaAuras:UnitTestDebug("CheckGroup("..group..") Present!");
			self.CurrentUnit = unit;
			if (not giveReason) then return true; end
			return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonOneInGroupHasBuff, unit, self.auraType, self.buffname);
		end
	elseif (self.groupany==false) then
		if (not giveReason) then return false; end
		return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonNotAllInGroupHaveBuff, group, self.auraType, self.buffname);
	end
end

function cPowaBuffBase:CheckGroup(group, count, giveReason)
	local show, reason;
	show, reason = self:CheckSingleUnit(group, self.CurrentUnit, giveReason);
	if (show ~= nil) then
		--PowaAuras:ShowText("buff for existing unit (", self.CurrentUnit, ") found");
		return show, reason;
	end
	self.CurrentSlot = nil;
	if (not PowaAuras:TableEmpty(PowaAuras.ChangedUnits.Buffs)) then
		--PowaAuras.BuffUnitSetCount = PowaAuras.BuffUnitSetCount + 1;
		for unit in pairs(PowaAuras.ChangedUnits.Buffs) do
			if (unit~=self.CurrentUnit) then
				--PowaAuras:ShowText("Checking buff for changed unit (", unit, ")");
				show, reason = self:CheckSingleUnit(group, unit, giveReason);
				if (show ~= nil) then
					return show, reason;
				end
			end
		end
	else
		--PowaAuras.BuffRaidCount = PowaAuras.BuffRaidCount + 1;
		for groupId = 1, count do
			local unit = group..groupId;
			if (unit~=self.CurrentUnit) then
				show, reason = self:CheckSingleUnit(group, unit, giveReason);
				if (show ~= nil) then return show, reason; end
			end
		end
	end
	if (self.groupany==false) then
		--PowaAuras:UnitTestDebug("CheckGroup("..group..") All Present!");
		if (not giveReason) then return true; end
		return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonAllInGroupHaveBuff, group, self.auraType, self.buffname);
	end
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonNoOneInGroupHasBuff, group, self.auraType, self.buffname);
end

function cPowaBuffBase:CheckIfShouldShow(giveReason)
	--PowaAuras:UnitTestInfo("CheckIfShouldShow ",self.buffAuraType," aura");
	--PowaAuras:Debug("Check " .. self.buffAuraType .. " aura");
	local numpm = GetNumPartyMembers();
	local numrm = GetNumRaidMembers();
	--- targets
	if (self.target or self.targetfriend) then
		--PowaAuras:UnitTestDebug("on target or friendlytarget");
		return self:CheckAllAuraSlots("target", giveReason);
	end	
	--- focus buff    
	if self.focus then
		--PowaAuras:UnitTestDebug("on focus");
		return self:CheckAllAuraSlots("focus", giveReason);
	end		
	--- unit buff    
	if self.optunitn then
		--PowaAuras:UnitTestDebug("on unit "..self.unitn);
		return self:CheckAllAuraSlots(self.unitn, giveReason);
	end		
	--- raid buff
	if self.raid then
		--PowaAuras:UnitTestDebug("on raid size=", numrm);
		return self:CheckGroup("raid", numrm, giveReason);
	end			
	--- partybuff    
	if self.party then
		--PowaAuras:UnitTestDebug("on party size=", numpm);
		return self:CheckGroup("party", numpm, giveReason);
	end
	
	if (self.groupOrSelf) then --- Group or Self Buff
		--PowaAuras:UnitTestDebug("on Group or Self");
		if (numrm>0) then
			PowaAuras:UnitTestDebug("GoS on raidunit");
			return self:CheckGroup("raid", numrm, giveReason); -- includes player
		end
		if (numpm>0) then
			--PowaAuras:UnitTestDebug("GoS on partyunit or self");
			local presentOnSelf, reason = self:CheckAllAuraSlots("player", giveReason);
			if (presentOnSelf and self.groupany) then
				if (not giveReason) then return true; end
				return true, reason;
			end
			if (not presentOnSelf and not self.groupany) then
				if (not giveReason) then return false; end
				return false, reason;
			end
			return self:CheckGroup("party", numpm, giveReason);
		end
		--PowaAuras:UnitTestDebug("GoS on player");
		--PowaAuras:ShowText("GoS on player");
		return self:CheckAllAuraSlots("player", giveReason);
	end
			
	--- player buff    

	--PowaAuras:Debug("on player");
	return self:CheckAllAuraSlots("player", giveReason);
end
function cPowaBuffBase:ShowTimerDurationSlider()
	return (self.target
		 or self.targetfriend
		 or self.party
		 or self.focus
		 or self.raid
		 or self.optunitn);
end

cPowaBuffBase.ShowOptions = {
	["PowaBarBuffStacks"]=1,
	["PowaGroupAnyButton"]=1,
	["PowaBarTooltipCheck"]=1,
};
cPowaBuffBase.CheckBoxes = {
	["PowaTargetButton"]=1,
	["PowaPartyButton"]=1,
	["PowaFocusButton"]=1,
	["PowaRaidButton"]=1,
	["PowaGroupOrSelfButton"]=1,
	["PowaGroupAnyButton"]=1,
	["PowaOptunitnButton"]=1,
	["PowaInverseButton"]=1,
	["PowaIngoreCaseButton"]=1,
	["PowaOwntexButton"]=1,
};

cPowaBuff = PowaClass(cPowaBuffBase, {buffAuraType="HELPFUL", auraType="buff"});
cPowaBuff.OptionText={buffNameTooltip=PowaAuras.Text.aideBuff, 
					  exactTooltip=PowaAuras.Text.aideExact,
					  typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Buff], 
					  mineText=PowaAuras.Text.nomMine, mineTooltip=PowaAuras.Text.aideMine,
					  targetFriendText=PowaAuras.Text.nomCheckFriend, targetFriendTooltip=PowaAuras.Text.aideTargetFriend,
					};

cPowaBuff.TooltipOptions = {r=0.0, g=1.0, b=1.0, showBuffName=true, stacksColour={r=0.7,g=1.0,b=0.7}};

									  
cPowaDebuff = PowaClass(cPowaBuffBase, {buffAuraType = "HARMFUL", auraType="debuff"});
cPowaDebuff.OptionText={buffNameTooltip=PowaAuras.Text.aideBuff2,
						 exactTooltip=PowaAuras.Text.aideExact,
						 typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Debuff],
						 mineText=PowaAuras.Text.nomMine, mineTooltip=PowaAuras.Text.aideMine,
						 targetFriendText=PowaAuras.Text.nomCheckFriend, targetFriendTooltip=PowaAuras.Text.aideTargetFriend,
						};

cPowaDebuff.TooltipOptions = {r=1.0, g=0.8, b=0.8, showBuffName=true, stacksColour={r=1.0,g=0.7,b=0.7}};						 
						 
cPowaTypeDebuff = PowaClass(cPowaBuffBase, {buffAuraType = "HARMFUL", auraType="debuff type"});
cPowaTypeDebuff.OptionText={
						buffNameTooltip=PowaAuras.Text.aideBuff3,
						exactTooltip=PowaAuras.Text.aideExact,
						typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.TypeDebuff],
						mineText=PowaAuras.Text.nomDispellable, mineTooltip=PowaAuras.Text.aideDispellable,
						targetFriendText=PowaAuras.Text.nomCheckFriend, targetFriendTooltip=PowaAuras.Text.aideTargetFriend,
						};
 cPowaTypeDebuff.ShowOptions = {["PowaGroupAnyButton"]=1,
							   ["PowaBarTooltipCheck"]=1};						 
cPowaTypeDebuff.CheckBoxes = {["PowaTargetButton"]=1,
							  ["PowaPartyButton"]=1,
							  ["PowaFocusButton"]=1,
							  ["PowaRaidButton"]=1,
							  ["PowaGroupOrSelfButton"]=1,
							  ["PowaGroupAnyButton"]=1,
							  ["PowaOptunitnButton"]=1,
							  ["PowaInverseButton"]=1,
							  ["PowaIngoreCaseButton"]=1,
							  };
cPowaTypeDebuff.TooltipOptions = {r=0.8, g=1.0, b=0.8, showBuffName=true};

function cPowaTypeDebuff:IsPresent(target, z)
	local removeable;
	if (self.mine) then
		removeable = 1;
	end
	local name, _, texture, count, typeDebuff, _, expirationTime = UnitDebuff(target, z, removeable);
	if (not name) then
		return nil;
	end
	--PowaAuras:Debug("TypeDebuff IsPresent on ",target,"  buffid ",z,"  removeable ",removeable);
	if (self.mine and typeDebuff==nil) then
		return false;
	end

	--PowaAuras:UnitTestDebug("Debuff ",name," type ",typeDebuff);
		
	local typeDebuffName;
	if (typeDebuff ~= nil) then
		typeDebuffName = PowaAuras.Text.DebuffType[typeDebuff];
	end
	local typeDebuffCatName = PowaAuras.Text.DebuffCatType[PowaAuras.DebuffCatSpells[name]];
	if (typeDebuffName == nil and typeDebuffCatName==nil) then
		typeDebuffName = PowaAuras.Text.aucun;
	end

	--PowaAuras:UnitTestDebug("typeDebuffName ",typeDebuffName);
	--PowaAuras:UnitTestDebug("typeDebuffCatName ",typeDebuffCatName);
	--PowaAuras:UnitTestDebug("self.buffname ",self.buffname);
	
	if self:MatchText(typeDebuffName, self.buffname)
	or self:MatchText(typeDebuffCatName, self.buffname) then
		if (self.Stacks) then
			self.Stacks:SetStackCount(count);
		end
		self:SetIcon(texture);
		if (self.Timer) then
			self.Timer:SetDurationInfo(expirationTime);
			self:CheckTimerInvert();
			if (self.ForceTimeInvert) then
				return false;
			end
		end
		return true;
	end

	return false;
end


cPowaStealableSpell = PowaClass(cPowaBuffBase, {buffAuraType = "HARMFUL", auraType="stealable spell type", target=true, CanHaveTimer=true, CanHaveTimerOnInverse=false, CanHaveStacks=true, CanHaveInvertTime=true});
cPowaStealableSpell.OptionText={buffNameTooltip=PowaAuras.Text.aideStealableSpells, exactTooltip=PowaAuras.Text.aideExact, typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.StealableSpell]};
cPowaStealableSpell.ShowOptions = {["PowaBarTooltipCheck"]=1};						 
cPowaStealableSpell.CheckBoxes={["PowaTargetButton"]=1,
							["PowaFocusButton"]=1,
							["PowaInverseButton"]=1,
							["PowaIngoreCaseButton"]=1,
							["PowaOwntexButton"]=1,
							};
												  
cPowaStealableSpell.TooltipOptions = {r=0.8, g=0.8, b=0.2, showBuffName=true};

function cPowaStealableSpell:AddEffect()
	if not self.target and not self.focus then --- any enemy casts
		table.insert(PowaAuras.AurasByType.StealableSpells, self.id);
	end
	if self.target then --- target casts
		table.insert(PowaAuras.AurasByType.StealableTargetSpells, self.id);
	end
	if self.focus then --- focus casts
		table.insert(PowaAuras.AurasByType.StealableFocusSpells, self.id);
	end
end

function cPowaStealableSpell:CheckUnit(unit)
	if not UnitExists(unit) or UnitIsDead(unit) or not UnitCanAttack(unit, "player") then
		--PowaAuras:UnitTestDebug(unit, " exists=", UnitExists(unit), " dead=", UnitIsDeadOrGhost(unit), " hostile=", UnitCanAttack(unit, "player"));
		return false;
	end
	
	for pword in string.gmatch(self.buffname, "[^/]+") do

		for i = 1, 40 do
		
			local auraName, _, auraTexture, count, typeDebuff, _, expirationTime, _, isStealable = UnitAura(unit, i);
			
			if (auraName == nil) then return nil; end

			--PowaAuras:ShowText("Aura=",auraName," count=",count," expirationTime=", expirationTime," isStealable=",isStealable);

			if (isStealable and self:CompareAura(unit, s, auraName, auraTexture, pword)) then
				if (self.Stacks) then
					self.Stacks:SetStackCount(count);
				end			
				if (self.Timer) then
					self.Timer:SetDurationInfo(expirationTime);
					self:CheckTimerInvert();
					if (self.ForceTimeInvert) then
						return false;
					end
				end
				return true;
			end	
		end
	end
	
	--PowaAuras:UnitTestDebug(unit, "  has stealable spell ", spellname, " no match");
	return false;
end	

function cPowaStealableSpell:CheckIfShouldShow(giveReason)
	--PowaAuras:Debug("Check if target/focus is casting ", self.buffname);
	
	-- Check self target/focus first
	if (self:CheckUnit("target")) then
		if (not giveReason) then return true; end
		return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonStealablePresent, PowaAuras.Text.nomCheckTarget, self.buffname);
	end
	if (self:CheckUnit("focus")) then
		if (not giveReason) then return true; end
		return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonStealablePresent, PowaAuras.Text.nomCheckFocus, self.buffname);
	end	

	--- Scan raid targets
	local numrm = GetNumRaidMembers();
	if numrm > 0 then
		for i=1, numrm do
			if (self:CheckUnit("raid"..i.."target")) then
				if (not giveReason) then return true; end
				return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonRaidTargetStealablePresent, i, self.buffname);
			end
		end
	else
	    -- Scan party targets
		local numpm = GetNumPartyMembers();
		if numpm > 0 then
			for i=1, numpm do
				if (self:CheckUnit("party"..i.."target")) then
					if (not giveReason) then return true; end
					return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonPartyTargetStealablePresent, i, self.buffname);
				end
			end
		end
	end
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonNoStealablePresent, self.buffname);
end

cPowaPurgeableSpell = PowaClass(cPowaBuffBase, {buffAuraType = "HARMFUL", auraType="purgeable spell type", target=true, CanHaveTimer=true, CanHaveTimerOnInverse=false, CanHaveStacks=true, CanHaveInvertTime=true});
cPowaPurgeableSpell.OptionText={buffNameTooltip=PowaAuras.Text.aidePurgeableSpells, exactTooltip=PowaAuras.Text.aideExact, typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.PurgeableSpell]};
cPowaPurgeableSpell.ShowOptions = {["PowaBarTooltipCheck"]=1};						 
cPowaPurgeableSpell.CheckBoxes={["PowaTargetButton"]=1,
							["PowaFocusButton"]=1,
							["PowaInverseButton"]=1,
							["PowaIngoreCaseButton"]=1,
							["PowaOwntexButton"]=1,
							};
												  
cPowaPurgeableSpell.TooltipOptions = {r=0.2, g=0.8, b=0.2, showBuffName=true};

function cPowaPurgeableSpell:AddEffect()
	if not self.target and not self.focus then --- any enemy casts
		table.insert(PowaAuras.AurasByType.PurgeableSpells, self.id);
	end
	if self.target then --- target casts
		table.insert(PowaAuras.AurasByType.PurgeableTargetSpells, self.id);
	end
	if self.focus then --- focus casts
		table.insert(PowaAuras.AurasByType.PurgeableFocusSpells, self.id);
	end
end

function cPowaPurgeableSpell:CheckUnit(unit)
	if (not UnitExists(unit) or UnitIsDead(unit)) then
		--PowaAuras:UnitTestDebug(unit, " exists=", UnitExists(unit), " dead=", UnitIsDeadOrGhost(unit));
		return false;
	end
	
	for pword in string.gmatch(self.buffname, "[^/]+") do

		for i = 1, 40 do
		
			local auraName, _, auraTexture, count, typeDebuff, _, expirationTime = UnitAura(unit, i, "CANCELABLE");
			
			if (auraName == nil) then return nil; end

			--PowaAuras:ShowText(i," C Aura=",auraName," count=",count," expirationTime=", expirationTime);

			if (auraName and self:CompareAura(unit, s, auraName, auraTexture, pword)) then
				if (self.Stacks) then
					self.Stacks:SetStackCount(count);
				end			
				--PowaAuras:Debug("CompareAura not found");
				if (self.Timer) then
					self.Timer:SetDurationInfo(expirationTime);
					self:CheckTimerInvert();
					if (self.ForceTimeInvert) then
						return false;
					end
				end
				return true;
			end	
		end
		
	end
		
	--PowaAuras:UnitTestDebug(unit, " has Purgeable spell ", spellname, " no match");
	return false;
end	

function cPowaPurgeableSpell:CheckIfShouldShow(giveReason)
	--PowaAuras:Debug("Check if target/focus is casting ", self.buffname);
	
	-- Check self target/focus first
	if (self:CheckUnit("target")) then
		if (not giveReason) then return true; end
		return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonPurgeablePresent, PowaAuras.Text.nomCheckTarget, self.buffname);
	end
	if (self:CheckUnit("focus")) then
		if (not giveReason) then return true; end
		return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonPurgeablePresent, PowaAuras.Text.nomCheckFocus, self.buffname);
	end	

	--- Scan raid targets
	local numrm = GetNumRaidMembers();
	if numrm > 0 then
		for i=1, numrm do
			if (self:CheckUnit("raid"..i.."target")) then
				if (not giveReason) then return true; end
				return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonRaidTargetPurgeablePresent, i, self.buffname);
			end
		end
	else
	    -- Scan party targets
		local numpm = GetNumPartyMembers();
		if numpm > 0 then
			for i=1, numpm do
				if (self:CheckUnit("party"..i.."target")) then
					if (not giveReason) then return true; end
					return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonPartyTargetPurgeablePresent, i, self.buffname);
				end
			end
		end
	end
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonNoPurgeablePresent, self.buffname);
end

-- This is not really AoE it is periodic damage, could be a DoT or a ground effect damage
cPowaAoE = PowaClass(cPowaAura, {AuraType = "Aoe"});
cPowaAoE.OptionText={buffNameTooltip=PowaAuras.Text.aideBuff4, exactTooltip=PowaAuras.Text.aideExact, typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.AoE]};
cPowaAoE.ShowOptions={["PowaBarTooltipCheck"]=1};				 
cPowaAoE.CheckBoxes={["PowaIngoreCaseButton"]=1};
cPowaAoE.TooltipOptions = {r=0.6, g=0.4, b=1.0, showBuffName=true};
function cPowaAoE:CheckIfShouldShow(giveReason)
	--PowaAuras:Debug("Check AoE");

	for spellId, spell in pairs (PowaAuras.AoeAuraAdded) do
		--PowaAuras:ShowText("checking AoE "..spell.." ("..spellId..")");
		if self:MatchSpell(spell, PowaAuras.AoeAuraTexture[spellId], self.buffname) then
			--PowaAuras:ShowText("Found! Showing=", self.Showing, " Active=", self.Active);
			self:SetIcon("Interface\\icons\\Spell_fire_meteorstorm");
			if (self.duration>0) then
				self.TimeToHide = GetTime() + self.duration;
			end
			if (not giveReason) then return true; end
			return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonAoETrigger, spell);
		end
	end
	
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonAoENoTrigger, self.buffname);
end

cPowaEnchant = PowaClass(cPowaAura, {AuraType = "Enchants", CanHaveTimer=true, CanHaveTimerOnInverse=true, CanHaveStacks=true, CanHaveInvertTime=true, InvertTimeHides=true});
cPowaEnchant.OptionText = {buffNameTooltip=PowaAuras.Text.aideBuff5, exactTooltip=PowaAuras.Text.aideExact, typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Enchant]};
cPowaEnchant.ShowOptions={["PowaBarBuffStacks"]=1};
cPowaEnchant.CheckBoxes={["PowaIngoreCaseButton"]=1,
						 ["PowaInverseButton"]=1,
						 ["PowaOwntexButton"]=1};
cPowaEnchant.TooltipOptions = {r=1.0, g=0.8, b=1.0, showBuffName=true};

function cPowaEnchant:CheckforEnchant(slot, enchantText, textToFind)
	--PowaAuras:Debug("Check enchant ("..enchantText..") active in slot",slot);
	--PowaAuras:ShowText("Check enchant ("..enchantText..") active in slot",slot);
	PowaAuras_Tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	PowaAuras_Tooltip:SetInventoryItem("player", slot);
	--PowaAuras:UnitTestDebug("search in tooltip for ", textToFind);			
	--PowaAuras:ShowText("search in tooltip for ", textToFind);			
	for z = 1, PowaAuras_Tooltip:NumLines() do
		--PowaAuras:UnitTestDebug("Check tooltip line ",z);
		--PowaAuras:ShowText("Check tooltip line ",z);
		local textlinel = getglobal("PowaAuras_TooltipTextLeft"..z);
		local textl = textlinel:GetText();
		local text = "";
		if textl then
			text = text..textl;
		end
		local textliner = getglobal("PowaAuras_TooltipTextRight"..z);
		local textr = textliner:GetText();
		if textr then
			text = text..textr;
		end
		if (text ~= "") then
			--PowaAuras:UnitTestDebug("| "..text.." |");
			--PowaAuras:ShowText("| "..text.." |");
			if (self:MatchText(text, textToFind)) then
				PowaAuras_Tooltip:Hide();
				return true;
			end
		end
	end	
	PowaAuras_Tooltip:Hide();
	return false;		
end
				
function cPowaEnchant:SetForEnchant(loc, slot, charges, index)
	--PowaAuras:Debug(loc,":found ",self.buffname," in the tooltip!");
	if (self:CheckStacks(charges)) then
		if (self:IconIsRequired()) then
			self:SetIcon(GetInventoryItemTexture("player", slot));
		end
		if (self.Stacks) then
			self.Stacks:SetStackCount(count);
		end			
		return true;
	end
	return false;
end
		
function cPowaEnchant:CheckIfShouldShow(giveReason)
	--PowaAuras:Debug("Check weapon enchant");
	--PowaAuras:ShowText("Check weapon enchant");
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();
	--PowaAuras:ShowText("mainHandExpiration=", mainHandExpiration);

	local checkMain = true;
	local checkOff = true;
	for pword in string.gmatch(self.buffname, "[^/]+") do
		if (pword==PowaAuras.Text.mainHand) then
			checkMain = true;
			checkOff = false;
		elseif (pword==PowaAuras.Text.offHand) then
			checkOff = true;
			checkMain = false;
		else
			if (hasMainHandEnchant and checkMain) then		
				if (self:CheckforEnchant(16, PowaAuras.Text.mainHand, pword)) then
					if (self:SetForEnchant("MH", 16, mainHandCharges, 1)) then
						if (self.Stacks) then
							self.Stacks:SetStackCount(mainHandCharges);
						end
						PowaAuras.Pending[self.id] = GetTime() + mainHandExpiration / 1000;
						if (self.Timer) then
							self.Timer:SetDurationInfo(PowaAuras.Pending[self.id]);
							self:CheckTimerInvert();
							if (self.ForceTimeInvert) then
								if (not giveReason) then return false; end
								return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonEnchantMainInvert, self.buffname);
							end
						end
						if (not giveReason) then return true; end
						return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonEnchantMain, self.buffname);
					end
				end
			end
			if (hasOffHandEnchant and checkOff) then
				if (self:CheckforEnchant(17, PowaAuras.Text.offHand, pword)) then
					if (self:SetForEnchant("OH", 17, offHandCharges, 2)) then
						if (self.Stacks) then
							self.Stacks:SetStackCount(offHandCharges);
						end
						PowaAuras.Pending[self.id] = GetTime() + offHandExpiration / 1000;
						if (self.Timer) then
							self.Timer:SetDurationInfo(PowaAuras.Pending[self.id]);
							self:CheckTimerInvert();
							if (self.ForceTimeInvert) then
								if (not giveReason) then return false; end
								return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonEnchantOffInvert, self.buffname);
							end
						end		
						if (not giveReason) then return true; end
						return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonEnchantOff, self.buffname);
					end
				end	
			end
		end
	end
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonNoEnchant, self.buffname);
end

cPowaCombo = PowaClass(cPowaAura,
{
	AuraType = "Combo", 
	CanHaveStacks=true,
	OptionText={buffNameTooltip=PowaAuras.Text.aideBuff6, exactTooltip=PowaAuras.Text.aideExact, typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Combo]},
	CheckBoxes={["PowaIngoreCaseButton"]=1,
				},
});

							  					 
cPowaCombo.TooltipOptions = {r=1.0, g=1.0, b=0.0, showBuffName=true};
							  

function cPowaCombo:CheckIfShouldShow(giveReason)
	if (not(PowaAuras.playerclass == "ROGUE" or (PowaAuras.playerclass=="DRUID" and GetShapeshiftForm()==3))) then
		if (not giveReason) then return nil; end
		return nil, PowaAuras.Text.nomReasonNoUseCombo;
	end
	--PowaAuras:Debug("Check Combos");
	local nCombo = tostring(GetComboPoints("player"));
	--PowaAuras:UnitTestDebug("nCombo=", nCombo, " self.buffname=", self.buffname);
	if self:MatchText(nCombo, self.buffname) then
		self:SetIcon("Interface\\icons\\inv_sword_48");
		if (self.Stacks) then
			self.Stacks:SetStackCount(nCombo);
		end			
		if (not giveReason) then return true; end
		return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonComboMatch, nCombo, self.buffname);
	end
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonNoComboMatch, nCombo, self.buffname);
end

---=== ACTION READY ===--
cPowaActionReady = PowaClass(cPowaAura, {AuraType = "Actions", CanHaveTimer=true, CanHaveTimerOnInverse=true, CooldownAura=true, CanHaveInvertTime=true});
cPowaActionReady.OptionText={
							buffNameTooltip=PowaAuras.Text.aideBuff7,
							exactTooltip=PowaAuras.Text.aideExact,
							typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.ActionReady],
							mineText=PowaAuras.Text.nomIgnoreUseable, mineTooltip=PowaAuras.Text.aideIgnoreUseable,
							};

cPowaActionReady.CheckBoxes={["PowaIngoreCaseButton"]=1,
							 ["PowaInverseButton"]=1,
							 ["PowaOwntexButton"]=1,
							};
				
							  					 
cPowaActionReady.TooltipOptions = {r=0.8, g=0.8, b=1.0, showBuffName=true};
							  
function cPowaActionReady:CheckIfShouldShow(giveReason)
	--PowaAuras:Debug("Check Action / Button:", self.slot);
	--PowaAuras:ShowText("-----ACTION READY---------");
	--PowaAuras:ShowText("Slot=", self.slot);
	if (not self.slot or self.slot == 0) then 
		if (not giveReason) then return false; end
		return false, PowaAuras.Text.nomReasonActionNotFound; 
	end 

	local cdstart, cdduration, enabled = GetActionCooldown(self.slot);
	--PowaAuras:ShowText("cdstart= ",cdstart," duration= ",cdduration," enabled= ",enabled);
	if (not enabled) then
		if (self.Timer) then
			self.Timer:SetDurationInfo(0);
		end
		if (not giveReason) then return false; end
		return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonActionlNotEnabled, spellName);
	end

	--PowaAuras:ShowText("self.mine= ",self.mine," usable= ",IsUsableAction(self.slot));
	if (not self.mine) then
		local usable, noMana = IsUsableAction(self.slot);
		if (not usable) then
			--PowaAuras:ShowText("HIDE!!");
			if (not giveReason) then return false; end
			return false, PowaAuras.Text.nomReasonActionNotUsable;
		end
	end
	
	-- Ignore if this is just Global Cooldown
	if (self.Debug) then
		PowaAuras:Message("CooldownOver= ",self.CooldownOver," cdduration= ",cdduration," InGCD= ",PowaAuras.InGCD); --OK
	end
	local globalCD = not self.CooldownOver and (cdduration > 0.2 and cdduration < 1.7) and PowaAuras.InGCD==true;
	if (self.Debug) then
		PowaAuras:Message("globalCD=",globalCD); --OK
	end
	
	if (globalCD) then
		if (self.Debug) then
			PowaAuras:Message("GCD no change"); --OK
		end
		PowaAuras.Pending[self.id] = cdstart + cdduration;
		if (not giveReason) then return -1; end
		return -1, PowaAuras:InsertText(PowaAuras.Text.nomReasonGlobalCooldown, spellName);
	end
	
	if (cdstart == 0 or self.CooldownOver) then
		if (self.Debug) then
			PowaAuras:Message("SHOW!!"); --OK
		end
		if (not giveReason) then return true; end
		return true, PowaAuras.Text.nomReasonActionReady;
	end

	PowaAuras.Pending[self.id] = cdstart + cdduration;
	if (self.Debug) then
		PowaAuras:Message("Set Spell Pending= ",PowaAuras.Pending[self.id]); --OK
	end

	local reason = PowaAuras.Text.nomReasonActionNotReady;
	if (self.Timer) then
		self.Timer:SetDurationInfo(cdstart + cdduration);
		self:CheckTimerInvert();
		if (self.ForceTimeInvert) then
			if (not giveReason) then return true; end
			return true, PowaAuras.Text.nomReasonActionNotReadyInvert;
		end
		if (giveReason) then
			reason = PowaAuras.Text.nomReasonActionNotUsable;
		end
	end		
	--PowaAuras:ShowText("HIDE!!");
	if (not giveReason) then return false; end
	return false, reason;
end

function cPowaActionReady:ShowTimerDurationSlider()
	return true;
end

cPowaOwnSpell = PowaClass(cPowaAura, {AuraType = "OwnSpells", CanHaveTimer=true, CanHaveTimerOnInverse=true, CooldownAura=true, CanHaveInvertTime=true});
cPowaOwnSpell.OptionText={
						buffNameTooltip=PowaAuras.Text.aideBuff8,
						exactTooltip=PowaAuras.Text.aideExact,
						typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.OwnSpell],
						mineText=PowaAuras.Text.nomIgnoreUseable, mineTooltip=PowaAuras.Text.aideIgnoreUseable,
						};
cPowaOwnSpell.ShowOptions={["PowaBarTooltipCheck"]=1};
cPowaOwnSpell.CheckBoxes={
						  ["PowaInverseButton"]=1,
						  ["PowaInverseButton"]=1,
						  ["PowaIngoreCaseButton"]=1,
						  ["PowaOwntexButton"]=1,
						  };
						  
							  					 
cPowaOwnSpell.TooltipOptions = {r=1.0, g=0.6, b=0.2, showBuffName=true};


function cPowaOwnSpell:CheckIfShouldShow(giveReason)
	--PowaAuras:Debug("Check Spell:", self.buffname);
	--PowaAuras:ShowText("-----OWN SPELL---------");
	--PowaAuras:ShowText("Spell=", self.buffname);
	for pword in string.gmatch(self.buffname, "[^/]+") do
		local spellName, spellIcon = self:GetSpellNameFromMatch(pword);
		if (self:IconIsRequired()) then
			if (not spellIcon) then
				_, _, spellIcon = GetSpellInfo(spellName);
			end
			self:SetIcon(spellIcon);
		end
		local cdstart, cdduration, enabled = GetSpellCooldown(spellName);
		--PowaAuras:UnitTestDebug("cdstart= ",cdstart," duration= ",cdduration," enabled= ",enabled);
		--PowaAuras:ShowText("cdstart= ",cdstart," duration= ",cdduration," enabled= ",enabled);
		if (not enabled) then
			if (not giveReason) then return false; end
			return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonSpellNotEnabled, spellName);
		end

		local globalCD = not self.CooldownOver and (cdduration > 0.2 and cdduration < 1.7) and PowaAuras.InGCD==true;
		--PowaAuras:ShowText("globalCD=",globalCD);
		
		if (globalCD) then
			--PowaAuras:ShowText("GCD no change");
			PowaAuras.Pending[self.id] = cdstart + cdduration;
			if (not giveReason) then return -1; end
			return -1, PowaAuras:InsertText(PowaAuras.Text.nomReasonGlobalCooldown, spellName);
		end
		
		if (cdstart == 0 or self.CooldownOver) then
			--PowaAuras:ShowText("SHOW!!");
			if (not giveReason) then return true; end
			return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonSpellUsable, spellName);
		end
		
		PowaAuras.Pending[self.id] = cdstart + cdduration;
		--PowaAuras:ShowText("Set Pending= ",PowaAuras.Pending[self.id]);

		if (giveReason) then
			local reason = PowaAuras:InsertText(PowaAuras.Text.nomReasonSpellNotFound, self.buffname);
		end
		if (self.Timer) then
			self.Timer:SetDurationInfo(PowaAuras.Pending[self.id]);
			self:CheckTimerInvert();
			if (self.ForceTimeInvert) then
				--PowaAuras:ShowText("SHOW2!!");
				if (not giveReason) then return true; end
				return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonSpellNotReady, spellName);
			end
			--PowaAuras:ShowText("Set DurationInfo= ",self.Timer.DurationInfo);
		end
		if (giveReason) then
			reason = PowaAuras:InsertText(PowaAuras.Text.nomReasonSpellOnCooldown, spellName);
		end
	end
	--PowaAuras:ShowText("HIDE!!");
	if (not giveReason) then return false; end
	return false, reason
end
function cPowaOwnSpell:ShowTimerDurationSlider()
	return true;
end

cPowaAuraStats = PowaClass(cPowaAura);
cPowaAuraStats.OptionText={targetFriendText=PowaAuras.Text.nomCheckFriend, targetFriendTooltip=PowaAuras.Text.aideTargetFriend,};

cPowaAuraStats.ShowOptions={["PowaBarThresholdSlider"]=1,
						    ["PowaThresholdInvertButton"]=1};					 
cPowaAuraStats.CheckBoxes={["PowaTargetButton"]=1,
						   ["PowaPartyButton"]=1,
						   ["PowaFocusButton"]=1,
						   ["PowaRaidButton"]=1,
						   ["PowaGroupOrSelfButton"]=1,
						   ["PowaGroupAnyButton"]=1,
						   ["PowaOptunitnButton"]=1,
						   ["PowaInverseButton"]=1,};

							  
function cPowaAuraStats:AddEffect()
  if not self.target 
  and not self.targetfriend 
  and not self.party 
  and not self.raid 
  and not self.focus
  and not self.optunitn then
		table.insert(PowaAuras.AurasByType[self.ValueName], self.id);
	end
	if self.optunitn then
		table.insert(PowaAuras.AurasByType["NamedUnit"..self.ValueName], self.id);
	end
	if self.focus then     
		table.insert(PowaAuras.AurasByType["Focus"..self.ValueName], self.id);
	end
	if (self.target or self.targetfriend) then --- TargetHealth
		table.insert(PowaAuras.AurasByType["Target"..self.ValueName], self.id);
	end
	if self.party then
		table.insert(PowaAuras.AurasByType["Party"..self.ValueName], self.id);
	end
	if self.raid then
		table.insert(PowaAuras.AurasByType["Raid"..self.ValueName], self.id);
	end
end
function cPowaAuraStats:CheckUnit(unit)
	--PowaAuras:Debug("CheckUnit " .. unit);
	if (not self:IsCorrectPowerType(unit)) then
		--PowaAuras:UnitTestDebug("Correct powertype " ,self:IsCorrectPowerType(unit));
		return nil;
	end			
	if (UnitIsDeadOrGhost(unit)) then
		--PowaAuras:UnitTestDebug("Correct powertype dead ", UnitIsDeadOrGhost(unit));
		return false;
	end			

	local curValue = self:UnitValue(unit);
	local maxValue = self:UnitValueMax(unit);
	--PowaAuras:UnitTestDebug("curValue=", curValue, " maxValue=", maxValue);
	if (curValue==nil or maxValue==nil) then return false; end

	local curpercenthp = (curValue / maxValue) * 100;
	if self.thresholdinvert then 
		thresholdvalidate = (curpercenthp > self.threshold);
	else
		thresholdvalidate = (curpercenthp < self.threshold)
	end	
	if (thresholdvalidate) then
		self:SetIcon("Interface\\icons\\Spell_fire_meteorstorm");
		return true;
	end
	return false;
end

function cPowaAuraStats:CheckIfShouldShow(giveReason)
	--PowaAuras:Debug("Check Stat "..self.ValueName);
	return self:CheckAllUnits(giveReason);
end


cPowaHealth = PowaClass(cPowaAuraStats, {ValueName = "Health"});
cPowaHealth.OptionText={typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Health]};
cPowaHealth.TooltipOptions = {r=0.2, g=1.0, b=0.2, showThreshold=true};
function cPowaHealth:IsCorrectPowerType(unit)
	return true;
end
function cPowaHealth:UnitValue(unit)
	return UnitHealth(unit);
end
function cPowaHealth:UnitValueMax(unit)
	return UnitHealthMax(unit);
end


cPowaMana = PowaClass(cPowaAuraStats, {ValueName = "Mana"});
cPowaMana.OptionText={typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Mana]};
cPowaMana.TooltipOptions = {r=0.2, g=0.2, b=1.0, showThreshold=true};
function cPowaMana:IsCorrectPowerType(unit)
	local powerType = UnitPowerType(unit);
	return (powerType and powerType == 0);
end
function cPowaMana:UnitValue(unit)
	--PowaAuras:Debug("Mana UnitValue for ", unit);
	return UnitPower(unit);
end
function cPowaMana:UnitValueMax(unit)
	--PowaAuras:Debug("Mana UnitValueMax for ", unit);
	return UnitPowerMax(unit);
end

cPowaEnergyRagePower = PowaClass(cPowaMana, {ValueName = "RageEnergy"});
cPowaEnergyRagePower.OptionText={typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.EnergyRagePower]};
cPowaEnergyRagePower.TooltipOptions = {r=1.0, g=0.4, b=0.0, showThreshold=true};
function cPowaEnergyRagePower:IsCorrectPowerType(unit)
	local powerType = UnitPowerType(unit);
	return (powerType and powerType > 0);
end

cPowaAggro = PowaClass(cPowaAura, {ValueName = "Aggro"});
cPowaAggro.OptionText={typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Aggro]};
cPowaAggro.CheckBoxes={["PowaPartyButton"]=1,
					   ["PowaRaidButton"]=1,
					   ["PowaGroupOrSelfButton"]=1,
					   ["PowaInverseButton"]=1};
cPowaAggro.TooltipOptions = {r=1.0, g=0.4, b=0.2};
function cPowaAggro:AddEffect()

	if not self.target 
   and not self.targetfriend 
   and not self.party
   and not self.raid 
   and not self.focus
   and not self.optunitn then --- self Aggro
	table.insert(PowaAuras.AurasByType.Aggro, self.id);
	end
	if self.party then --- party Aggro
		table.insert(PowaAuras.AurasByType.PartyAggro, self.id);
	end
	if self.raid then --- raid Aggro
		table.insert(PowaAuras.AurasByType.RaidAggro, self.id);
	end
end

function cPowaAggro:CheckUnit(unit)
	--PowaAuras:Message(unit," UnitThreatSituation=", UnitThreatSituation(unit));
	return (UnitThreatSituation(unit) or -1)> 0;
end	
function cPowaAggro:CheckIfShouldShow(giveReason)
	self:SetIcon("Interface\\icons\\Ability_Warrior_EndlessRage");
	--PowaAuras:Debug("Check Aggro status");
	return self:CheckAllUnits(giveReason);
end

cPowaPvP = PowaClass(cPowaAura, {ValueName = "PvP"});
cPowaPvP.OptionText={typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.PvP],
					 targetFriendText=PowaAuras.Text.nomCheckFriend, targetFriendTooltip=PowaAuras.Text.aideTargetFriend,};
cPowaPvP.CheckBoxes={["PowaTargetButton"]=1,
					 ["PowaPartyButton"]=1,
					 ["PowaGroupOrSelfButton"]=1,
					 ["PowaRaidButton"]=1,};						
							  
cPowaPvP.TooltipOptions = {r=1.0, g=1.0, b=0.8};

function cPowaPvP:AddEffect()
	if not self.target 
  and not self.targetfriend 
  and not self.party
	and not self.raid 
	and not self.focus
  and not self.optunitn then --- self pvp flag
		table.insert(PowaAuras.AurasByType.PvP, self.id);
	end
	if (self.target or self.targetfriend) then --- target flag
		table.insert(PowaAuras.AurasByType.TargetPvP, self.id);
	end
	if self.party then --- party pvp flagged
		table.insert(PowaAuras.AurasByType.PartyPvP, self.id);
	end
	if self.raid then --- raid pvp flagged
		table.insert(PowaAuras.AurasByType.RaidPvP, self.id);
	end
end
function cPowaPvP:CheckUnit(unit)
	return UnitIsPVP(unit);
end	
function cPowaPvP:CheckIfShouldShow(giveReason)
	--PowaAuras:Debug("Check PvP Flag");
	return self:CheckAllUnits(giveReason);
end


cPowaSpellAlert = PowaClass(cPowaAura, {AuraType = "SpellAlert", CanHaveInvertTime=true});
cPowaSpellAlert.OptionText={buffNameTooltip=PowaAuras.Text.aideSpells, 
                            exactTooltip=PowaAuras.Text.aideExact, 
                            typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.SpellAlert], 
					        mineText=PowaAuras.Text.nomCanInterrupt, mineTooltip=PowaAuras.Text.aideCanInterrupt,
					        targetFriendText=PowaAuras.Text.nomPlayerSpell, targetFriendTooltip=PowaAuras.Text.aidePlayerSpell,
							};
cPowaSpellAlert.CheckBoxes={["PowaTargetButton"]=1,
							["PowaFocusButton"]=1,
							["PowaInverseButton"]=1,
							["PowaIngoreCaseButton"]=1,
							["PowaOwntexButton"]=1,
							};
					
							  
cPowaSpellAlert.TooltipOptions = {r=0.4, g=0.4, b=1.0, showBuffName=true};

function cPowaSpellAlert:AddEffect()
	if self.targetfriend then --- player
		table.insert(PowaAuras.AurasByType.PlayerSpells, self.id);
	else
		if not self.target and not self.focus then --- any enemy casts
			table.insert(PowaAuras.AurasByType.Spells, self.id);
		end
		if self.target then --- target casts
			table.insert(PowaAuras.AurasByType.TargetSpells, self.id);
		end
		if self.focus then --- focus casts
			table.insert(PowaAuras.AurasByType.FocusSpells, self.id);
		end
	end
end

function cPowaSpellAlert:CheckUnit(unit)
	if not UnitExists(unit) or UnitIsDead(unit) or (unit~="player" and not UnitCanAttack(unit, "player")) then
		--PowaAuras:UnitTestDebug(unit, " exists=", UnitExists(unit), " dead=", UnitIsDeadOrGhost(unit), " hostile=", UnitCanAttack(unit, "player"));
		return false;
	end
	local spellname, _, _, spellicon, _, endtime, _, _, notInterruptible  = UnitCastingInfo(unit);
	if not spellname then
		spellname, _, _, spellicon, _, endtime, _, notInterruptible  = UnitChannelInfo(unit);
	end

	if not spellname then -- not casting
		--PowaAuras:UnitTestDebug(unit, " is not casting");
		return false;
	end
	--PowaAuras:ShowText(unit, " is casting ", spellname);
	--PowaAuras:ShowText(" mine= ", self.mine, " notInterruptible =", notInterruptible );
	
	if (self.mine and notInterruptible) then
		PowaAuras:ShowText(unit, " is casting ", spellname, " but can't interrupt it");
		return false;
	end
		
	if self:MatchSpell(spellname, spellicon, self.buffname, true) then
		if (self.Timer) then
			self.Timer:SetDurationInfo(GetTime() + endtime/1000);
			self:CheckTimerInvert();
			if (self.ForceTimeInvert) then
				return false;
			end
		end
		self:SetIcon(spellicon);
		return true;
	end
	
	--PowaAuras:UnitTestDebug(unit, " is casting ", spellname, " no match");
	return false;
end	

function cPowaSpellAlert:CheckIfShouldShow(giveReason)
	--PowaAuras:UnitTestDebug("Check for spell being cast ", self.buffname);
	--PowaAuras:ShowText("Check for spell being cast ", self.buffname);
	
	-- Check self target/focus first
	if (self.target and self:CheckUnit("target")) then
		if (not giveReason) then return true; end
		return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonTargetCasting, self.buffname);
	end
	if (self.focus and self:CheckUnit("focus")) then
		if (not giveReason) then return true; end
		return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonFocusCasting, self.buffname);
	end	

	if not self.target and not self.focus then
		if (self.targetfriend) then
			--PowaAuras:ShowText("Check player");
			if (self:CheckUnit("player")) then
				if (not giveReason) then return true; end
				return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonYouAreCasting, self.buffname);
			end	
			if (not giveReason) then return false; end
			return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonYouAreNotCasting, self.buffname);
		end
		--- Scan raid targets
		local numrm = GetNumRaidMembers();
		if numrm > 0 then
			for i=1, numrm do
				if (self:CheckUnit("raid"..i.."target")) then
					if (not giveReason) then return true; end
					return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonRaidTargetCasting, i, self.buffname);
				end
			end
		else
			-- Scan party targets
			local numpm = GetNumPartyMembers();
			if numpm > 0 then
				for i=1, numpm do
					if (self:CheckUnit("party"..i.."target")) then
						if (not giveReason) then return true; end
						return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonPartyTargetCasting, i, self.buffname);
					end
				end
			end
		end
	end
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonNoCasting, self.buffname);
end
function cPowaSpellAlert:ShowTimerDurationSlider()
	return true;
end

cPowaStance = PowaClass(cPowaAura, {AuraType = "Stance"});
cPowaStance.OptionText={typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Stance]};
cPowaStance.ShowOptions={["PowaDropDownStance"]=1};
cPowaStance.CheckBoxes={["PowaInverseButton"]=1};
							  
cPowaStance.TooltipOptions = {r=1.0, g=0.6, b=0.2, showStance=true};

function cPowaStance:CheckIfShouldShow(giveReason)
	--PowaAuras:Debug("Check Stance");
	local nStance = GetShapeshiftForm(false);
	--PowaAuras:UnitTestDebug("nStance = "..tostring(nStance).." / self.stance = "..tostring(self.stance));
	--PowaAuras:ShowText("nStance = "..tostring(nStance).." / self.stance = "..tostring(self.stance));
	if (nStance == self.stance)then
		if (nStance>0 and self:IconIsRequired()) then
			self:SetIcon(GetShapeshiftFormInfo(nStance));
		end
		if (not giveReason) then return true; end
		return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonStance, nStance, self.stance);
	end
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonNoStance, nStance, self.stance);
end


cPowaGTFO = PowaClass(cPowaAura, {ValueName = "GTFO Alert"});
cPowaGTFO.OptionText={typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.GTFO]};
cPowaGTFO.CheckBoxes={};
cPowaGTFO.TooltipOptions = {r=1.0, g=0.4, b=0.2, showGTFO=true};
cPowaGTFO.ShowOptions={["PowaDropDownGTFO"]=1};

function cPowaGTFO:AddEffect()
	if (self.GTFO == 0) then
		table.insert(PowaAuras.AurasByType.GTFOHigh, self.id);
	elseif (self.GTFO == 1) then
		table.insert(PowaAuras.AurasByType.GTFOLow, self.id);
	elseif (self.GTFO == 2) then
		table.insert(PowaAuras.AurasByType.GTFOFail, self.id);
	end
	
end

function cPowaGTFO:CheckIfShouldShow(giveReason)

	if (self.GTFO == 1) then
		self:SetIcon("Interface\\icons\\spell_fire_bluefire");
	elseif (self.GTFO == 2) then
		self:SetIcon("Interface\\icons\\ability_suffocate");
	else
		self:SetIcon("Interface\\icons\\spell_fire_fire");
	end

	--PowaAuras:Debug("GTFO alert");
	if (GTFO) then
	    if (GTFO.ShowAlert) then
	        return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonGTFOAlerts);
	    end
	end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonGTFOAlerts);
end

-- Totem Aura--
cPowaTotems = PowaClass(cPowaAura, {AuraType = "Totems", CanHaveTimer=true});
cPowaTotems.OptionText={buffNameTooltip=PowaAuras.Text.aideTotems, 
                            exactTooltip=PowaAuras.Text.aideExact, 
                            typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Totems], 
							};
cPowaTotems.CheckBoxes={["PowaInverseButton"]=1,
						["PowaIngoreCaseButton"]=1,
						["PowaOwntexButton"]=1,
						};

cPowaTotems.TooltipOptions = {r=1.0, g=1.0, b=0.4, showBuffName=true};

function cPowaTotems:AddEffect()
	table.insert(PowaAuras.AurasByType.Totems, self.id);	
end

function cPowaTotems:CheckIfShouldShow(giveReason)
	--PowaAuras:Message("Totem Aura CheckIfShouldShow");
	if (#PowaAuras.TotemSlots==0) then
		PowaAuras.TotemSlots = {[1]=true,[2]=true,[3]=true,[4]=true};
	end
	for pword in string.gmatch(self.buffname, "[^/]+") do
		--PowaAuras:Message("  pword=",pword);
		local pwordNumber = tonumber(pword);
		if (pwordNumber) then
			--PowaAuras:Message("  SlotCheck=",pwordNumber);
			if (PowaAuras.TotemSlots[pwordNumber]) then
				--PowaAuras:Message("  SlotCheck Requested=",pwordNumber);
				local haveTotem, totemName, startTime, duration = GetTotemInfo(pwordNumber);
				--PowaAuras:Message("  haveTotem=",haveTotem, " totemName=",totemName, " startTime=",startTime, " duration=",duration);
				if (totemName~=nil and totemName~="") then

					if (self:IconIsRequired()) then
						--PowaAuras:Message("  Icon Required");
						local _, _, spellIcon = GetSpellInfo(totemName);
						self:SetIcon(spellIcon);
					end
					if (self.Timer) then
						self.Timer:SetDurationInfo(startTime + duration);
						self:CheckTimerInvert();
						if (self.ForceTimeInvert) then
							if (not giveReason) then return false; end
							return false, getglobal("BINDING_NAME_MULTICASTACTIONBUTTON"..pwordNumber).." found (slot "..pwordNumber..") - "..totemName;
						end
					end
					if (not giveReason) then return true; end
					return true, getglobal("BINDING_NAME_MULTICASTACTIONBUTTON"..pwordNumber).." found (slot "..pwordNumber..") - "..totemName;		
				end
			end
		else
			for slot in pairs (PowaAuras.TotemSlots) do
				local haveTotem, totemName, startTime, duration = GetTotemInfo(slot);
				if (self:MatchText(totemName, pword)) then
					if (self:IconIsRequired()) then
						local _, _, spellIcon = GetSpellInfo(totemName);
						self:SetIcon(spellIcon);
					end
					if (self.Timer) then
						self.Timer:SetDurationInfo(startTime + duration);
						self:CheckTimerInvert();
						if (self.ForceTimeInvert) then
							if (not giveReason) then return false; end
							return false, totemName.." found";
						end
					end
					if (not giveReason) then return true; end
					return true, totemName.." found";				
				end				
			end
		end
	end
	if (not giveReason) then return false; end
	return false, "Totem not found";				
end

-- Pet Aura--
cPowaPet= PowaClass(cPowaAura, {ValueName = "Pet", });
cPowaPet.OptionText={typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Pet]};
cPowaPet.CheckBoxes={["PowaInverseButton"]=1,
						};
cPowaPet.TooltipOptions = {r=0.4, g=1.0, b=0.4};

function cPowaPet:Init()
	if (PowaAuras.playerclass == "DEATHKNIGHT") then
		local name, iconPath, _, _, currentRank = GetTalentInfo(3, 20); -- Master of Ghouls
		--PowaAuras:Message(name, "? currentRank=",currentRank);
		PowaAuras.MasterOfGhouls = (currentRank>0);
		self.CanHaveTimerOnInverse=true;
		if (not PowaAuras.MasterOfGhouls) then
			self.CanHaveTimer=true;
		end
	elseif (PowaAuras.playerclass == "MAGE") then
		self.CanHaveTimerOnInverse=true;
	end
end

function cPowaPet:AddEffect()
	table.insert(PowaAuras.AurasByType.Pet, self.id);	
end

function cPowaPet:CheckIfShouldShow(giveReason)
	if (PowaAuras.playerclass == "WARLOCK") then
		self:SetIcon("Interface\\icons\\Spell_shadow_summonimp");
	elseif (PowaAuras.playerclass == "MAGE") then
		self:SetIcon("Interface\\icons\\Spell_frost_summonwaterelemental_2");
	elseif (PowaAuras.playerclass == "DEATHKNIGHT") then
		self:SetIcon("Interface\\icons\\Spell_shadow_animatedead");
	else
		self:SetIcon("Interface\\icons\\Ability_hunter_pet_bear");
	end

	if(UnitExists("pet")) then
		if (PowaAuras.playerclass == "MAGE") then
			--Get time left for Water Elemental?
		end
		if (not giveReason) then return true; end
		return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonPetExists);
	end	
	
	if (PowaAuras.playerclass=="DEATHKNIGHT" ) then
		if (not PowaAuras.MasterOfGhouls) then
			local haveTotem, name, startTime, duration, icon = GetTotemInfo(1);
			--PowaAuras:Message("  haveTotem=",haveTotem, " totemName=",totemName, " startTime=",startTime, " duration=",duration);
			if (startTime>0) then
				if (self.Timer) then
					self.Timer:SetDurationInfo(startTime + duration);
					self:CheckTimerInvert();
					if (self.ForceTimeInvert) then
						if (not giveReason) then return false; end
						return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonPetExists);
					end
				end
				if (not giveReason) then return true; end
				return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonPetExists);	
			end
		end
	
		if (self.Timer and self.inverse) then
			local startTime, duration, enabled = GetSpellCooldown(46584);
			if (not enabled) then
				if (not giveReason) then return false; end
				local name = GetSpellInfo(46584);
				return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonSpellNotEnabled, name);
			end
			
			self.Timer:SetDurationInfo(startTime + duration);
			self:CheckTimerInvert();
			if (self.ForceTimeInvert) then
				if (not giveReason) then return false; end
				return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonPetExists);
			end
		end
	elseif (PowaAuras.playerclass == "MAGE") then
		if (self.Timer and self.inverse) then
			local startTime, duration, enabled = GetSpellCooldown(31687);
			if (not enabled) then
				if (not giveReason) then return false; end
				local name = GetSpellInfo(31687);
				return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonSpellNotEnabled, name);
			end
			
			self.Timer:SetDurationInfo(startTime + duration);
			self:CheckTimerInvert();
			if (self.ForceTimeInvert) then
				if (not giveReason) then return false; end
				return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonPetExists);
			end
		end
	end
	
	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonPetMissing);
end


-- Runes Aura--
cPowaRunes = PowaClass(cPowaAura, {AuraType = "Runes", CanHaveTimerOnInverse=true});
cPowaRunes.OptionText={buffNameTooltip=PowaAuras.Text.aideRunes, 
                            typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Runes], 
							};
cPowaRunes.CheckBoxes={["PowaInverseButton"]=1,
						["PowaIngoreCaseButton"]=1,
						};

cPowaRunes.TooltipOptions = {r=1.0, g=0.4, b=1.0, showBuffName=true};

function cPowaRunes:AddEffect()
	table.insert(PowaAuras.AurasByType.Runes, self.id);	
end

function cPowaRunes:CheckIfShouldShow(giveReason)
	--PowaAuras:Message("Rune Aura CheckIfShouldShow");

	self:SetIcon("Interface\\icons\\spell_arcane_arcane01");
	
	local runes = {[1]=0, [2]=0, [3]=0, [4]=0};
	local runeEnd = {[1]={}, [2]={}, [3]={}};
	for slot = 1, 6 do
		local startTime, duration, runeReady = GetRuneCooldown(slot);
		local runeType = GetRuneType(slot);
		if (runeReady) then
			runes[runeType] = runes[runeType] + 1;
			if (runeType==4) then
				runes[1] = runes[1] + 1;
				runes[2] = runes[2] + 1;
				runes[3] = runes[3] + 1;
			end
		elseif (runeType~=4 and self.Timer) then
			local endTime = startTime + duration;
			table.insert(runeEnd[runeType], endTime);
		end
	end
	
	if (self.Timer) then
		for runeType = 1, 3 do
			table.sort(runeEnd[runeType]);
		end
	end
	
	local minTimeToActivate;

	for pword in string.gmatch(string.upper(self.buffname), "[^/]+") do
	--PowaAuras:Message("  pword=",pword);
	
		local runesCount = {};

		_, runesCount[1] = string.gsub(pword, "B", "B");
		_, runesCount[2] = string.gsub(pword, "U", "U");
		_, runesCount[3] = string.gsub(pword, "F", "F");
		_, runesCount[4] = string.gsub(pword, "D", "D");
		
		if (runes[1]>=runesCount[1]
		and runes[2]>=runesCount[2]
		and runes[3]>=runesCount[3]
		and runes[4]>=runesCount[4]) then
			if (not giveReason) then return true; end
			return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonRunesReady); 			
		end
		
		if (self.Timer and self.inverse) then		
			local maxTime = 0;
			for runeType = 1, 3 do
				local index = runesCount[runeType];
				local endCount = #runeEnd[runeType];
				--PowaAuras:Message("  runeType=",runeType, " index=",index, " endCount=",endCount);
				if (index>0 and endCount>0) then
					if (index>endCount) then
						index = endCount;
					end
					local endTime = runeEnd[runeType][index];
					--PowaAuras:Message("    runeType=",runeType, " index=",index, " endTime=",endTime);
					if (endTime>maxTime) then
						maxTime = endTime;
					end
				end
			end
		
			if (minTimeToActivate==nil or maxTime<minTimeToActivate) then
				minTimeToActivate = maxTime;
			end
		end
		
	end

	if (self.Timer and minTimeToActivate~=nil and minTimeToActivate>0) then
		self.Timer:SetDurationInfo(minTimeToActivate);
	end

	if (not giveReason) then return false; end
	return false, PowaAuras:InsertText(PowaAuras.Text.nomReasonRunesNotReady); 			
end


-- Static Aura--
cPowaStatic= PowaClass(cPowaAura, {ValueName = "Static"});
cPowaStatic.OptionText={typeText=PowaAuras.Text.AuraType[PowaAuras.BuffTypes.Static]};

cPowaStatic.CheckBoxes={};
cPowaStatic.TooltipOptions = {r=0.4, g=0.4, b=0.4};

function cPowaStatic:AddEffect()
	table.insert(PowaAuras.AurasByType.Static, self.id);	
end

function cPowaStatic:CheckIfShouldShow(giveReason)
	return true, PowaAuras:InsertText(PowaAuras.Text.nomReasonStatic);
end


-- Concrete Classes
PowaAuras.AuraClasses = {
	[PowaAuras.BuffTypes.Buff]=cPowaBuff,
	[PowaAuras.BuffTypes.Debuff]=cPowaDebuff,
	[PowaAuras.BuffTypes.TypeDebuff]=cPowaTypeDebuff,
	[PowaAuras.BuffTypes.AoE]=cPowaAoE,
	[PowaAuras.BuffTypes.Enchant]=cPowaEnchant,
	[PowaAuras.BuffTypes.Combo]=cPowaCombo,
	[PowaAuras.BuffTypes.ActionReady]=cPowaActionReady,
	[PowaAuras.BuffTypes.Health]=cPowaHealth,
	[PowaAuras.BuffTypes.Mana]=cPowaMana,
	[PowaAuras.BuffTypes.EnergyRagePower]=cPowaEnergyRagePower,
	[PowaAuras.BuffTypes.Aggro]=cPowaAggro,
	[PowaAuras.BuffTypes.PvP]=cPowaPvP,
	[PowaAuras.BuffTypes.SpellAlert]=cPowaSpellAlert,
	[PowaAuras.BuffTypes.Stance]=cPowaStance,
	[PowaAuras.BuffTypes.OwnSpell]=cPowaOwnSpell,
	[PowaAuras.BuffTypes.StealableSpell]=cPowaStealableSpell,
	[PowaAuras.BuffTypes.PurgeableSpell]=cPowaPurgeableSpell,
	[PowaAuras.BuffTypes.GTFO]=cPowaGTFO,
	[PowaAuras.BuffTypes.Totems]=cPowaTotems,
	[PowaAuras.BuffTypes.Pet]=cPowaPet,
	[PowaAuras.BuffTypes.Runes]=cPowaRunes,
	[PowaAuras.BuffTypes.Static]=cPowaStatic,
}

-- Instance concrete class based on type
function PowaAuras:AuraFactory(auraType, id, base)
	local class = self.AuraClasses[auraType];
	if (class) then
		--self:Message("AuraFactory "..tostring(auraType).." id="..tostring(id).." class="..tostring(class));
		if (base == nil) then
			base = {};
		end
		base.bufftype = auraType;
		base.Debug = nil;
		return class(id, base);
	end
	self:Message("AuraFactory unknown "..tostring(auraType).." id="..tostring(id)); --OK
	return nil;
end



