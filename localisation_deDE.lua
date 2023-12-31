if (GetLocale() == "deDE") then

PowaAuras.Anim[0] = "[Nichts]";
PowaAuras.Anim[1] = "Statisch";
PowaAuras.Anim[2] = "Blitzend";
PowaAuras.Anim[3] = "Wachsend";
PowaAuras.Anim[4] = "Pulsierend";
PowaAuras.Anim[5] = "Blase";
PowaAuras.Anim[6] = "Wassertropfen";
PowaAuras.Anim[7] = "Elektrisch";
PowaAuras.Anim[8] = "Schrumpfend";
PowaAuras.Anim[9] = "Flamme";
PowaAuras.Anim[10] = "Orbit";

PowaAuras.BeginAnimDisplay[0] = "[Nichts]";
PowaAuras.BeginAnimDisplay[1] = "Reinzoomend";
PowaAuras.BeginAnimDisplay[2] = "Rauszoomend";
PowaAuras.BeginAnimDisplay[3] = "Nur Alpha";
PowaAuras.BeginAnimDisplay[4] = "Links";
PowaAuras.BeginAnimDisplay[5] = "Oben links";
PowaAuras.BeginAnimDisplay[6] = "Oben";
PowaAuras.BeginAnimDisplay[7] = "Oben rechts";
PowaAuras.BeginAnimDisplay[8] = "Rechts";
PowaAuras.BeginAnimDisplay[9] = "Unten rechts";
PowaAuras.BeginAnimDisplay[10] = "Unten";
PowaAuras.BeginAnimDisplay[11] = "Unten links";
PowaAuras.BeginAnimDisplay[12] = "Hüpfen";

PowaAuras.EndAnimDisplay[0] = "[Nichts]";
PowaAuras.EndAnimDisplay[1] = "Wachsen";
PowaAuras.EndAnimDisplay[2] = "Schrumpfen";
PowaAuras.EndAnimDisplay[3] = "Nur Alpha";
PowaAuras.EndAnimDisplay[4] = "Drehen";
PowaAuras.EndAnimDisplay[5] = "Reindrehen"; 

PowaAuras.Sound[0] = "Kein";

PowaAuras:MergeTables(PowaAuras.Text, 
{
	welcome = "Gib /powa ein, um die Optionen zu öffnen.",

	aucune = "Nichts",
	aucun = "Nichts",
	largeur = "Breite",
	hauteur = "Höhe",
	mainHand = "Waffenhand",
	offHand = "Schildhand",
	bothHands = "beide",

	DebuffType =
	{
		Magic = "Magie",
		Disease = "Krankheit",
		Curse = "Fluch",
		Poison = "Gift",
	},

	DebuffCatType =
	{
		[PowaAuras.DebuffCatType.CC] = "CC",
		[PowaAuras.DebuffCatType.Silence] = "Stille",
		[PowaAuras.DebuffCatType.Snare] = "Fesseln",
		[PowaAuras.DebuffCatType.Stun] = "Betäubung",
		[PowaAuras.DebuffCatType.Root] = "Wurzeln",
		[PowaAuras.DebuffCatType.Disarm] = "Entwaffnet",
		[PowaAuras.DebuffCatType.PvE] = "PvE",
	},
	
	AuraType =
	{
		[PowaAuras.BuffTypes.Buff] = "Buff",
		[PowaAuras.BuffTypes.Debuff] = "Debuff",
		[PowaAuras.BuffTypes.AoE] = "AOE Debuff",
		[PowaAuras.BuffTypes.TypeDebuff] = "Debuff Typ",
		[PowaAuras.BuffTypes.Enchant] = "Waffenbuffs",
		[PowaAuras.BuffTypes.Combo] = "Kombo Punkte",
		[PowaAuras.BuffTypes.ActionReady] = "Aktion benutzbar",
		[PowaAuras.BuffTypes.Health] = "Leben",
		[PowaAuras.BuffTypes.Mana] = "Mana",
		[PowaAuras.BuffTypes.EnergyRagePower] = "Wut/Energie/Runen",
		[PowaAuras.BuffTypes.Aggro] = "Aggro",
		[PowaAuras.BuffTypes.PvP] = "PvP",
		[PowaAuras.BuffTypes.Stance] = "Haltung",
		[PowaAuras.BuffTypes.SpellAlert] = "Zauberalarm", 
		[PowaAuras.BuffTypes.OwnSpell] = "Mein Zauber", 
		[PowaAuras.BuffTypes.StealableSpell] = "Stehlbarer Zauber", 
		[PowaAuras.BuffTypes.PurgeableSpell] = "Reinigbarer Zauber", 
	},

	-- main
	nomEnable = "Aktiviere Power Auras",
	aideEnable = "Alle Power Auras Effekte einschalten",

	nomDebug = "Aktiviere Debug Meldungen",
	aideDebug = "Zeigt Debug Meldungen im Chatfenster",	
	ListePlayer = "Char",
	ListeGlobal = "Global",
	aideMove = "Effekt hierher verschieben.",
	aideCopy = "Effekt hierher kopieren.",
	nomRename = "Umbenennen",
	aideRename = "Seitentitel umbenennen.",
	nomTest = "Test",
	nomHide = "Alle ausblenden",
	nomEdit = "Editieren",
	nomNew = "Neu",
	nomDel = "Löschen",
	nomImport = "Importieren",
	nomExport = "Exportieren",
	nomImportSet = "Set importieren", 
	nomExportSet = "Set exportieren", 
	aideImport = "Zum Einfügen des Aura-Strings drücke Strg-V und anschließend \'Akzeptieren\'",
	aideExport = "Zum Kopieren und Weitergeben des Aura-Strings drücke Strg-C.",
	aideImportSet = "Zum Einfügen des Aura-Set-Strings drücke Strg-V und anschließends \'Akzeptieren'\. Das wird alle Auras auf dieser Seite löschen.",
	aideExportSet = "Zum Kopieren und Weitergeben aller Auren auf dieser Seite drücke Strg-C.",
	aideDel = "Löscht den ausgewählten Effekt.(Halte STRG zum Löschen gedrückt)",
	nomMove = "Verschieben",
	nomCopy = "Kopieren",
	nomPlayerEffects = "Charakter Effekte",
	nomGlobalEffects = "Globale\nEffekte",
	aideEffectTooltip = "(Shift-Klick um Effekt ein oder auszuschalten.)",

	-- editor
	nomSound = "Sound abspielen:",
	aideSound = "Spielt einen Sound am Anfang ab.",
	nomCustomSound = "ODER Sounddatei:",
	aideCustomSound = "Dateiname der Sounddatei eingeben, die VOR dem Starten von WoW im Sounds Verzeichniss war. mp3 und wav werden unterstützt. Bsp.: 'cookie.mp3' ;)",

	nomTexture = "Grafik",
	aideTexture = "Die Grafik die angezeigt werden soll. Du kannst ganz leicht Grafiken austauschen, indem du die Aura#.tga Dateien im Verzeichnis des Addons veränderst.",

	nomAnim1 = "Hauptanimation",
	nomAnim2 = "Zweitanimation",
	aideAnim1 = "Animiere die Aura oder nicht.",
	aideAnim2 = "Diese Animation wird mit weniger Stärke angezeigt als die Hauptanimation. Achtung vor zu viel Animationen auf dem Bildschirm.",

	nomDeform = "Deformation",
	aideDeform = "Strecke die Grafik in Höhe und Breite.",

	aideColor = "Klicken, um die Farbe der Grafik zu ändern.",
	aideFont = "Klicken, um die Schriftart zu wählen. Drücke OK, um die Auswahl anzuwenden.",
	aideMultiID = "Gib hier andere Aura-IDs für kombinierte Checks ein. Mehrere IDs müssen mit einem '/' getrennt werden. Die Aura ID kann als [#] in der ersten Zeile des Aura Tooltips gefunden werden.",
	aideTooltipCheck = "Checke auch die Tooltips, die diesen Text enthalten.",

	aideBuff = "Gib hier den Namen oder einen Teil vom Namen des Buffs ein, der die Aura ein und ausschalten soll. Mit einem Slash können mehrere Namen getrennt werden. (Bsp.: Super Buff/Power)",
	aideBuff2 = "Gib hier den Namen oder einen Teil vom Namen des Debuffs ein, der die Aura ein und ausschalten soll. Mit einem Slash können mehrere Namen getrennt werden. (Bsp.: Dunkle Krankheit/Säuche)",
	aideBuff3 = "Gib hier den Typ (Gift, Krankheit, Fluch, magie, CC, Stille, Betäubung, Fesseln, Wurzeln oder Nichts) des Debuff ein, der die Aura ein und ausschalten soll. Mit einem Slash können mehrere Typen getrennt werden. (Bsp.: Krankheit/Gift)",
	aideBuff4 = "Gib hier den Namen der Area of Effect(AoE) ein, der die Aura ein oder ausschalten soll (wie z.B. ein Feuerregen. Der Name dieser AoE steht im Kampflog).",
	aideBuff5 = "Gib hier den Namen oder einen Teil vom Namen der temporären Waffenverzauberung ein, die die Aura ein und ausschalten soll. Optional schreibe 'Waffenhand/' oder 'Schildhand' davor, um einen Slot festzulegen. (Bsp.: Waffenhand/Verkrüppelndes)",
	aideBuff6 = "Gib hier die Anzahl Kombopunkte ein, die die Aura ein oder auszuschalten (Bsp.: 1 oder 1/2/3 oder 0/4/5 usw...)",
	aideBuff7 = "Gib hier einen Namen oder einen Teil vom Namen einer Aktion auf deinen Aktionsleisten ein. Der Effekt wird aktiv sein, wenn die Aktion benutzbar ist.",
	aideBuff8 = "Gib hier den Namen oder einen Teil vom Namen eines Zaubers in deinem Zauberbuch ein. Du kannst eine Zauber-ID (Bsp.: [12345]) eingeben.", 
	
	aideSpells = "Gib hier den Namen eines Zaubers ein, der die Zauberalarm-Aura ein oder ausschaltet.",
	aideStacks = "Gib hier den Operator und die Anzahl Stapel ein, die benötigt werden, um den Effekt ein- oder auszuschalten. Ein Operator wird benötigt. Bsp: '<5' '>3' '=11' '!5' '>=0' '<=6' '2-8'",

	aideStealableSpells = "Gib hier den Names des stehlbaren Zaubers ein, der die Aura ein oder ausschalten soll. (Benutze * für alle stehlbaren Zauber)",
	aidePurgeableSpells = "Gib hier den Namen des reinigbaren Zaubers ein, der die Aura ein oder ausschalten soll. (Benutze * für alle reinigbaren Zauber)",

	aideUnitn = "Gib hier den Namen des Spielers ein, welcher den Effekt aktivieren/deaktivieren muss. Funktioniert nur mit Spielern innerhalb des Schlachtzugs oder der Gruppe.",	
	aideUnitn2 = "Nur für Schlachtzug/Gruppe", 

	aideMaxTex = "Definiert die maximale Grafikanzahl, die im Editor zur Verfügung stehen. Wenn du Grafiken im Verzeichnis des Addons hinzufügst (mit den Namen AURA1.tga bis AURA50.tga), muss hier die letzte Zahl eingetragen werden.",
	aideAddEffect = "Füge einen Effekt zum Bearbeiten hinzu.",
	aideWowTextures = "Aktivieren um die WoW-Grafiken anstatt der Grafiken im PowerAuras Verzeichnis zu verwenden.",
	aideTextAura = "Aktivieren um Text einzugeben anstatt zu Grafiken zu wählen.",
	aideRealaura = "Echte Aura",
	aideCustomTextures = "Aktivieren um die Grafiken im 'Custom' Unterverzeichnis zu verwenden. Trage den Namen der Textur unten ein (Bsp.: meineTextur.tga)",
	aideRandomColor = "Aktivieren um dem Effekt bei jeder Aktivierung eine zufällige Farbe zu geben.",

	aideTexMode = "Deaktivieren um die Texturtransparenz zu verwenden. Standardmäßig sind die dunkleren Farben mehr transparent.", 

	nomActivationBy = "Aktiv wenn:",

	nomOwnTex = "Benutze eigene Grafiken",
	aideOwnTex = "Benutze die Buff/Debuff/Fähigkeiten Grafik stattdessen.",
	nomStacks = "Stapel",

	nomUpdateSpeed = "Updatetempo",
	nomSpeed = "Animationstempo",
	nomFPS = "Globale Animations-FPS",
	nomTimerUpdate = "Timer Updatetempo",
	nomBegin = "Animationsstart",
	nomEnd = "Animationsende",
	nomSymetrie = "Symmetrie",
	nomAlpha = "Transparenz",
	nomPos = "Position",
	nomTaille = "Größe",

	nomExact = "Exakter Name",
	nomThreshold = "Schwellwert",
	aideThreshInv = "Aktivieren um die Schwellwertlogik umzukehren. Deaktiviert = Niedrige Warnung / Aktiviert = Hohe Warnung.",
	nomThreshInv = "</>",
	nomStance = "Haltung",

	nomMine = "Von mir gezaubert",
	aideMine = "Aktivieren um nur Buffs/Debuffs zu testen, die vom Spieler gezaubert wurden.",
	nomDispellable = "Ich kann entfernen",
	aideDispellable = "Aktivieren um nur entfernbare Buffs anzuzeigen", 
	nomCanInterrupt = "Kann unterbrochen werden", 
	aideCanInterrupt = "Aktivieren um nur unterbrechbare Zauber anzuzeigen",

	nomPlayerSpell = "Spieler wirkt Zauber",
	aidePlayerSpell = "Aktivieren, falls der Spieler einen Zauber wirkt",

	nomCheckTarget = "Feindliches Ziel",
	nomCheckFriend = "Freundliches Ziel",
	nomCheckParty = "Gruppenmitglied",
	nomCheckFocus = "Fokus",
	nomCheckRaid = "Schlachtzugsmitglied",
	nomCheckGroupOrSelf = "Schlachtzug/Gruppe oder selbst",
	nomCheckGroupAny = "Irgendeiner",
	nomCheckOptunitn = "Charname",

	aideTarget = "Aktivieren um nur feindliche Ziele zu überwachen.",
	aideTargetFriend = "Aktivieren um nur freundliche Ziele zu überwachen.",
	aideParty = "Aktivieren um nur Gruppenmitglieder zu überwachen.",
	aideGroupOrSelf = "Aktivieren um Gruppen- oder Schlachtzugsmitglieder oder selbst zu überwachen.",
	aideFocus = "Aktivieren um nur das Fokusziel zu überwachen.",
	aideRaid = "Aktivieren um nur Schlachtzugsmitglieder zu überwachen.",
	aideGroupAny = "Aktivieren um zu prüfen, ob 'irgendein' Gruppen/Schlachtzugsmitglied gebufft ist. Deaktivieren um zu prüfen, ob 'alle' gebufft sind.", 
	aideOptunitn = "Aktivieren um nur einen bestimmten Char in der Gruppe bzw. im Schlachtzug zu überwachen.",
	aideExact = "Aktivieren um den exakten Namen des Buffs/Debuff/Aktion zu überprüfen.",
	aideStance = "Haltung, Aura oder Form auswählen, die die Aura aktivieren soll.",	

	aideShowSpinAtBeginning= "Zeige am Ende der Anfangsanimation eine 360 Grad Drehung",
	nomCheckShowSpinAtBeginning = "Zeige Drehung am Ende der Anfangsanimation",

	nomCheckShowTimer = "Zeigen",
	nomTimerDuration = "Dauer",
	aideTimerDuration = "Zeigt einen Timer um die Buff/Debuff Dauer auf dem Ziel zu simulieren (0 um zu daktivieren)",
	aideShowTimer = "Aktivieren um den Timer anzuzeigen.",
	aideSelectTimer = "Auswählen welcher Timer die Dauer anzeigen soll.",
	aideSelectTimerBuff = "Auswählen welcher Timer die Dauer anzeigen soll (dieser ist für die Buffs des Spielers reserviert)",
	aideSelectTimerDebuff = "Auswählen welcher Timer die Dauer anzeigen soll (dieser ist für die Debuffs des Spielers reserviert)",

	nomCheckShowStacks = "Zeigen",

	nomCheckInverse = "Umkehren",
	aideInverse = "Kehrt die Logik des Effekts um, sodass er nur angezeigt wird, wenn der Buff/Debuff nicht aktiv ist.",	

	nomCheckIgnoreMaj = "Ignoriere Groß/Kleinschreibung",	
	aideIgnoreMaj = "Aktivieren um die Groß/Kleinschreibung bei Buff- und Debuffnamen zu ignorieren.",

	nomDuration = "Animationsdauer",
	aideDuration = "Nach dieser Zeit wird die Aura verschwinden (0 um zu daktivieren)",

	nomCentiemes = "Zeige hundertstel",
	nomDual = "Zeige zwei Timer",
	nomHideLeadingZeros = "Verstecke führende Nullen",
	nomTransparent = "Verwende transparente Grafiken",
	nomUpdatePing = "Animiere bei Wiederholung",
	nomClose = "Schließen",
	nomEffectEditor = "Effekt Editor",
	nomAdvOptions = "Optionen",
	nomMaxTex = "Maximale Anzahl an Grafiken verfügbar",
	nomTabAnim = "Animation",
	nomTabActiv = "Aktivierung",
	nomTabSound = "Sound",
	nomTabTimer = "Timer",
	nomTabStacks = "Stapel",
	nomWowTextures = "WoW Grafiken",
	nomCustomTextures = "Benutzerdefinierte Grafiken",
	nomTextAura = "Text Aura",
	nomRealaura = "Echte Aura",
	nomRandomColor = "Zufällige Farbe",
	nomTexMode = "Glühen",

	nomTalentGroup1 = "Spec 1",
	aideTalentGroup1 = "Zeige diesen Effekt nur, wenn du in deiner primären Talenzspezialisierung bist.",
	nomTalentGroup2 = "Spec 2",
	aideTalentGroup2 = "Zeige diesen Effekt nur, wenn du in deiner sekundären Talenzspezialisierung bist.",

	nomReset = "Setzte Editorpositionen zurück",	
	nomPowaShowAuraBrowser = "Zeige Auraauswahl",
	
	nomDefaultTimerTexture = "Standard Timer Grafik",
	nomTimerTexture = "Timer Grafik",
	nomDefaultStacksTexture = "Standard Stapel Grafik",
	nomStacksTexture = "Stapel Grafik",
	
	Enabled = "Aktiviert",
	Default = "Standard",

	Ternary = {
		combat = "Im Kampft",
		inRaid = "Im Schlachtzug",
		inParty = "In Gruppe",
		isResting = "Erholen",
		ismounted = "Auf Reittier",
		inVehicle = "In Fahrzeug",
		isAlive= "Am Leben",
	},

	nomWhatever = "Ignoriert",
	aideTernary = "Legt fest, wie der Status die Aura ein/ausschaltet.",
	TernaryYes = {
		combat = "Nur wenn im Kampf",
		inRaid = "Nur wenn in einer Schlachtgruppe",
		inParty = "Nur wenn in einer Gruppe",
		isResting = "Nur wenn erholend",
		ismounted = "Nur wenn auf einem Reittier",
		inVehicle = "Nur wenn in einem Fahrzeug",
		isAlive= "Nur wenn am Leben",
	},
	TernaryNo = {
		combat = "Nur wenn nicht im Kampf",
		inRaid = "Nur wenn in keiner Schlachtgruppe",
		inParty = "Nur wenn in keiner Gruppe",
		isResting = "Nur wenn nicht erholend",
		ismounted = "Nur wenn auf keinem Mount",
		inVehicle = "Nur wenn in keinem Fahrzeug",
		isAlive= "Nur wenn tot",
	},
	TernaryAide = {
		combat = "Effekt beeinflusst durch Kampfstatus.",
		inRaid = "Effekt beeinflusst durch Schlachtzugsstatus.",
		inParty = "Effekt beeinflusst durch Gruppenstatus.",
		isResting = "Effekt beeinflusst durch Erholenstatus.",
		ismounted = "Effekt beeinflusst durch Reittierstatus.",
		inVehicle = "Effekt beeinflusst durch Fahrzeugstatus.",
		isAlive= "Effekt beeinflusst durch Lebensstatus.",
	},

	nomTimerInvertAura = "Kehre Aura um wenn Dauer unterhalb",
	aidePowaTimerInvertAuraSlider = "Kehre die Aura um, wenn die Dauer weniger als dieses Limit ist (0 um zu deaktivieren)",
	nomTimerHideAura = "Verstecke Aura und Timer wenn Dauer oberhalb",
	aidePowaTimerHideAuraSlider = "Verstecke die Aura und den Timer, wenn die Dauer größer als dieses Limit ist (0 um zu deaktivieren)",

	aideTimerRounding = "Aktivieren um den Timer aufzurunden.",
	nomTimerRounding = "Timer aufrunden",

	aideGTFO = "Benutze GTFO (Boss) Zaubertreffer zur AoE Erkennung",
	nomGTFO = "Benutze GTFO für AoE",

	nomIgnoreUseable = "Anzeige nur vom CD abhängig",
	aideIgnoreUseable = "Ignoriert, wenn der Zauber benutzbar ist (benutzt nur die Abklingzeit)",

	-- Diagnostic reason text, these have substitutions (using $1, $2 etc) to allow for different sententance constructions
	nomReasonShouldShow = "Sollte angezeigt werden, weil $1",
	nomReasonWontShow   = "Wird nicht angezeigt, weil $1",
	
	nomReasonMulti = "Alle mehrfachen passen auf $1", --$1=Multiple match ID list
	
	nomReasonDisabled = "Power Auras deaktiviert",
	nomReasonGlobalCooldown = "Ignoriere Globale Abklingzeit",
	
	nomReasonBuffPresent = "$1 hat $2 $3", --$1=Target $2=BuffType, $3=BuffName (e.g. "Unit4 has Debuff Misery")
	nomReasonBuffMissing = "$1 hat nicht $2 $3", --$1=Target $2=BuffType, $3=BuffName (e.g. "Unit4 doesn't have Debuff Misery")
	nomReasonBuffFoundButIncomplete = "$2 $3 bei $1 gefunden, aber\n$4", --$1=Target $2=BuffType, $3=BuffName, $4=IncompleteReason (e.g. "Debuff Sunder Armor found for Target but\nStacks<=2")
	
	nomReasonOneInGroupHasBuff     = "$1 hat $2 $3",            --$1=GroupId   $2=BuffType, $3=BuffName (e.g. "Raid23 has Buff Blessing of Kings")
	nomReasonNotAllInGroupHaveBuff = "Nicht alle in $1 haben $2 $3", --$1=GroupType $2=BuffType, $3=BuffName (e.g. "Not all in Raid have Buff Blessing of Kings")
	nomReasonAllInGroupHaveBuff    = "Alle in $1 haben $2 $3",     --$1=GroupType $2=BuffType, $3=BuffName (e.g. "All in Raid have Buff Blessing of Kings")
	nomReasonNoOneInGroupHasBuff   = "Keiner in $1 hat $2 $3",  --$1=GroupType $2=BuffType, $3=BuffName (e.g. "No one in Raid has Buff Blessing of Kings")

	nomReasonBuffPresentTimerInvert = "der Buff läuft, Timer umgekehrt",
	nomReasonBuffFound              = "der Buff läuft",
	nomReasonStacksMismatch         = "der Stapel = $1. $2 erwartet", --$1=Actual Stack count, $2=Expected Stack logic match (e.g. ">=0")

	nomReasonAuraMissing = "die Aura fehlt",
	nomReasonAuraOff     = "die Aura ist aus",
	nomReasonAuraBad     = "die Aura ist fehlerhaft",
	
	nomReasonNotForTalentSpec = "die Aura nicht für diese Talentspezialisierung aktiviert wurde",
	
	nomReasonPlayerDead     = "der Spieler tot ist",
	nomReasonPlayerAlive    = "der Spieler am Leben ist",
	nomReasonNoTarget       = "kein Ziel",
	nomReasonTargetPlayer   = "das Ziel bist du",
	nomReasonTargetDead     = "das Ziel tot ist",
	nomReasonTargetAlive    = "das Ziel lebt",
	nomReasonTargetFriendly = "das Ziel freundlich ist",
	nomReasonTargetNotFriendly = "das Ziel nicht freundlich ist",
	
	nomReasonNotInCombat = "nicht im Kampf",
	nomReasonInCombat = "im Kampf",
	
	nomReasonInParty = "in Gruppe",
	nomReasonInRaid = "im Schlachtzug",
	nomReasonNotInParty = "nicht in Gruppe",
	nomReasonNotInRaid = "nicht im Schlachtzug",
	nomReasonNoFocus = "kein Fokus",	
	nomReasonNoCustomUnit = "benutzerdefinierte Einheit nicht in der Gruppe, im Schlachtzug oder mit Begleichtereinheit $1 gefunden werden konnte",

	nomReasonNotMounted = "auf keinem Reittier",
	nomReasonMounted = "auf einem Reittier",		
	nomReasonNotInVehicle = "in keinem Fahrzeug",
	nomReasonInVehicle = "in einem Fahrzeug",		
	nomReasonNotResting = "nicht eholend",
	nomReasonResting = "erholend",		
	nomReasonStateOK = "Status OK",

	nomReasonInverted        = "$1 (umgekehrt)", -- $1 is the reason, but the inverted flag is set so the logic is reversed
	
	nomReasonSpellUsable     = "Zauber $1 benutzbar ist",
	nomReasonSpellNotUsable  = "Zauber $1 nicht benutzbar ist",
	nomReasonSpellNotReady   = "Zauber $1 nicht bereit ist, Abklingzeit, Timer umgekehrt",
	nomReasonSpellNotEnabled = "Zauber $1 nicht aktiviert ist",
	nomReasonSpellNotFound   = "Zauber $1 nicht gefunden wurde",
	nomReasonSpellOnCooldown = "Spell $1 on Cooldown",
	
	nomReasonStealablePresent = "$1 has Stealable spell $2", --$1=Target $2=SpellName (e.g. "Focus has Stealable spell Blessing of Wisdom")
	nomReasonNoStealablePresent = "Nobody has Stealable spell $1", --$1=SpellName (e.g. "Nobody has Stealable spell Blessing of Wisdom")
	nomReasonRaidTargetStealablePresent = "Raid$1Target has has Stealable spell $2", --$1=RaidId $2=SpellName (e.g. "Raid21Target has Stealable spell Blessing of Wisdom")
	nomReasonPartyTargetStealablePresent = "Party$1Target has has Stealable spell $2", --$1=PartyId $2=SpellName (e.g. "Party4Target has Stealable spell Blessing of Wisdom")
	
	nomReasonPurgeablePresent = "$1 has Purgeable spell $2", --$1=Target $2=SpellName (e.g. "Focus has Purgeable spell Blessing of Wisdom")
	nomReasonNoPurgeablePresent = "Nobody has Purgeable spell $1", --$1=SpellName (e.g. "Nobody has Purgeable spell Blessing of Wisdom")
	nomReasonRaidTargetPurgeablePresent = "Raid$1Target has has Purgeable spell $2", --$1=RaidId $2=SpellName (e.g. "Raid21Target has Purgeable spell Blessing of Wisdom")
	nomReasonPartyTargetPurgeablePresent = "Party$1Target has has Purgeable spell $2", --$1=PartyId $2=SpellName (e.g. "Party4Target has Purgeable spell Blessing of Wisdom")

	nomReasonAoETrigger = "AoE $1 triggered", -- $1=AoE spell name
	nomReasonAoENoTrigger = "AoE no trigger for $1", -- $1=AoE spell match
	
	nomReasonEnchantMainInvert = "Main Hand $1 enchant found, timer invert", -- $1=Enchant match
	nomReasonEnchantMain = "Main Hand $1 enchant found", -- $1=Enchant match
	nomReasonEnchantOffInvert = "Off Hand $1 enchant found, timer invert"; -- $1=Enchant match
	nomReasonEnchantOff = "Off Hand $1 enchant found", -- $1=Enchant match
	nomReasonNoEnchant = "No enchant found on weapons for $1", -- $1=Enchant match

	nomReasonNoUseCombo = "You do not use combo points",
	nomReasonComboMatch = "Combo points $1 match $2",-- $1=Combo Points, $2=Combo Match
	nomReasonNoComboMatch = "Combo points $1 no match with $2",-- $1=Combo Points, $2=Combo Match

	nomReasonActionNotFound = "not found on Action Bar",
	nomReasonActionReady = "Action Ready",
	nomReasonActionNotReadyInvert = "Action Not Ready (on cooldown), timer invert",
	nomReasonActionNotReady = "Action Not Ready (on cooldown)",
	nomReasonActionlNotEnabled = "Action not enabled",
	nomReasonActionNotUsable = "Action not usable",

	nomReasonYouAreCasting = "You are casting $1", -- $1=Casting match
	nomReasonYouAreNotCasting = "You are not casting $1", -- $1=Casting match
	nomReasonTargetCasting = "Target casting $1", -- $1=Casting match
	nomReasonFocusCasting = "Focus casting $1", -- $1=Casting match
	nomReasonRaidTargetCasting = "Raid$1Target casting $2", --$1=RaidId $2=Casting match
	nomReasonPartyTargetCasting = "Party$1Target casting $2", --$1=PartyId $2=Casting match
	nomReasonNoCasting = "Nobody's target casting $1", -- $1=Casting match
	
	nomReasonStance = "Current Stance $1, matches $2", -- $1=Current Stance, $2=Match Stance
	nomReasonNoStance = "Current Stance $1, does not match $2", -- $1=Current Stance, $2=Match Stance

	ReasonStat = {
		Health     = {MatchReason="$1 Gesundheit niedrig",          NoMatchReason="$1 Gesundheit nicht niedrig genug"},
		Mana       = {MatchReason="$1 Mana niedrig",            NoMatchReason="$1 Mana nicht niedrig genug"},
		RageEnergy = {MatchReason="$1 EnergieWutRunen niedrig", NoMatchReason="$1 EnergieWutRunen nicht niedrig genug"},
		Aggro      = {MatchReason="$1 hat Aggro",           NoMatchReason="$1 hat keine Aggro"},
		PvP        = {MatchReason="$1 PvP Markierung gesetzt",        NoMatchReason="$1 PvP Markierung nicht gesetzt"},
	},

});

end
