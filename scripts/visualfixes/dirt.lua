-----------------------------------------
--additional dirt sprites functionality--
-----------------------------------------
--this is an updated More Dirt Sprites functionality by piber20 https://steamcommunity.com/sharedfiles/filedetails/?id=1201700604 but only dirt, womb, scarred, and flooded sprites as to be consistent with the version added to the game.

local BackdropType = { --we make this enum here to make it easier for us to deal with backdrops
	BASEMENT = 1,
	CELLAR = 2,
	BURNING_BASEMENT = 3,
	CAVES = 4,
	CATACOMBS = 5,
	FLOODED_CAVES = 6,
	DEPTHS = 7,
	NECROPOLIS = 8,
	DANK_DEPTHS = 9,
	WOMB = 10,
	UTERO = 11,
	SCARRED_WOMB = 12,
	BLUE_WOMB = 13,
	SHEOL = 14,
	CATHEDRAL = 15,
	DARK_ROOM = 16,
	CHEST = 17,
	MEGA_SATAN = 18,
	LIBRARY = 19,
	SHOP = 20,
	ISAACS_ROOM = 21,
	BARREN_ROOM = 22,
	SECRET_ROOM = 23,
	DICE_ROOM = 24,
	ARCADE = 25,
	ERROR_ROOM = 26,
	BLUE_SECRET = 27,
	ULTRA_GREED = 28
}

local DirtType = { --custom enum that tells us which dirt sprite to use
	NONE = -1,
	DIRT = 0,
	WOMB = 1,
	SCARRED = 2,
	FLOODED = 3
}

local BackdropToDirt = { --this table is used to quickly get what dirt type is used for what backdrop, if not specified uses brown dirt
	[BackdropType.FLOODED_CAVES] = DirtType.FLOODED,
	[BackdropType.WOMB] = DirtType.WOMB,
	[BackdropType.UTERO] = DirtType.WOMB,
	[BackdropType.SCARRED_WOMB] = DirtType.SCARRED,
	[BackdropType.ERROR_ROOM] = DirtType.NONE
}

local deliriumWasInRoom = false --set to true if delirium was in the room, when the room changes this gets set back to false
function CommunityVisualFixesScriptedChanges.GetDirtToUse(backdrop) --this is a function that returns what dirt type we should use, uses the DirtType enum we created just above
	
	local dirtToUse = BackdropToDirt[backdrop] or DirtType.DIRT --if there is no entry in BackdropToDirt, defaults to regular brown dirt
	
	--this disables ourselves if we're in a custom stage added by a mod (like revelations)
	if StageAPI and StageAPI.InNewStage and StageAPI.InNewStage() then
		dirtToUse = DirtType.NONE
	end
	
	--return our dirtToUse value
	return dirtToUse
	
end

CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites = {}
function CommunityVisualFixesScriptedChanges.UpdateDirtSprite(entity)

	local sprite = entity:GetSprite()
	local spritePath = string.lower(sprite:GetFilename())

	if CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites[spritePath] then
		
		local frameCount = entity.FrameCount
		
		local thisType = entity.Type
		local thisVariant = entity.Variant
		local thisSubType = entity.SubType
		local thisSecondInt = entity.I2
		
		local room = Game():GetRoom()
		local thisBackdrop = room:GetBackdropType()
		
		local data = entity:GetData()
		
		data.CVFLastType = data.CVFLastType or thisType
		data.CVFLastVariant = data.CVFLastVariant or thisVariant
		data.CVFLastSubType = data.CVFLastSubType or thisSubType
		data.CVFLastBackdrop = data.CVFLastBackdrop or thisBackdrop
		data.CVFLastSecondInt = data.CVFLastSecondInt or thisSecondInt
		
		local isDelirium = data.CVFIsDeliriousBoss or deliriumWasInRoom

		--the health one is the only way i can think of to detect the frail's second phase
		if frameCount <= 1
		or data.CVFLastType ~= thisType
		or data.CVFLastVariant ~= thisVariant
		or data.CVFLastSubType ~= thisSubType
		or data.CVFLastBackdrop ~= thisBackdrop
		or data.CVFLastSecondInt ~= thisSecondInt
		or isDelirium and frameCount == 2 then
		
			if thisType == EntityType.ENTITY_PIN and thisVariant == 2 and thisSecondInt == 1 then
				data.CVFfrailSecondPhase = true --special handling for the frail, ugh
			end
			
			local dirtTable = CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites[spritePath]
			local layerTable = CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites[spritePath].Layers or {0}
			local dirtToUse = CommunityVisualFixesScriptedChanges.GetDirtToUse(thisBackdrop) --get what dirt sprite we should use
			if dirtToUse ~= DirtType.NONE then
			
				local spritesheet = dirtTable[dirtToUse]
				
				if spritesheet ~= nil then --if the spritesheet local var was set...
				
					--trying to make the frail's second phase work, ugh
					if data.CVFfrailSecondPhase then
					
						local frailPrefix = string.sub(spritesheet, 0, 35)
						local frailSuffix = string.sub(spritesheet, 36, string.len(spritesheet))
						if string.match(frailPrefix, "gfx/bosses/afterbirth/boss_thefrail") then
							spritesheet = frailPrefix .. "2" .. frailSuffix --this basically modifies the spritesheet to add 2 after "boss_thefrail"
						end
						
					end
					
					--delirium dirt sprites
					local spritesheetPrefix = string.sub(spritesheet, 0, 11)
					local spritesheetSuffix = string.sub(spritesheet, 12, string.len(spritesheet))
					if string.match(spritesheetPrefix, "gfx/bosses/") and (data.CVFIsDeliriousBoss or deliriumWasInRoom) then
					
						spritesheet = spritesheetPrefix .. "afterbirthplus/deliriumforms/" .. spritesheetSuffix --this points the spritesheet to the delirium version instead
						
						spritesheet = string.gsub(spritesheet, "_dirt", "")
						spritesheet = string.gsub(spritesheet, "_womb", "")
						spritesheet = string.gsub(spritesheet, "_scarred", "")
						spritesheet = string.gsub(spritesheet, "_flooded", "")
						
					end
					
					--apply the sprites
					for _,layer in pairs(layerTable) do
						sprite:ReplaceSpritesheet(layer, spritesheet) --replace every layer with the spritesheet
					end
					sprite:LoadGraphics() --apply the graphics
					
				end
				
			end
			
		end
		
		data.CVFLastType = thisType
		data.CVFLastVariant = thisVariant
		data.CVFLastSubType = thisSubType
		data.CVFLastBackdrop = thisBackdrop
		data.CVFLastSecondInt = thisSecondInt
	
	end
	
end

CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
	deliriumWasInRoom = true --set this to true as if this callback happens then delirium probably exists
end, EntityType.ENTITY_DELIRIUM)

CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	deliriumWasInRoom = false
	if Isaac.CountEntities(nil, EntityType.ENTITY_DELIRIUM, -1, -1) > 0 then --get if delirium was in the room
		deliriumWasInRoom = true
	end
end)

CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, rng)
	for _, entity in pairs(Isaac.GetRoomEntities()) do
		if entity.FrameCount <= 1 and entity:IsBoss() and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then --try to figure out if a friendly boss has just spawned
			local data = entity:GetData()
			data.CVFIsDeliriousBoss = true
		end
	end
end, CollectibleType.COLLECTIBLE_DELIRIOUS)

-----------
--ENEMIES--
-----------
CommunityVisualFixesScriptedChanges.DirtSpritesEntitiesFixes = {
	EntityType.ENTITY_FRED,
	EntityType.ENTITY_LUMP,
	EntityType.ENTITY_NIGHT_CRAWLER,
	EntityType.ENTITY_PARA_BITE,
	EntityType.ENTITY_ROUNDY,
	EntityType.ENTITY_ULCER,
	EntityType.ENTITY_PIN,
	EntityType.ENTITY_POLYCEPHALUS,
	EntityType.ENTITY_MR_FRED,
	EntityType.ENTITY_STAIN,
	EntityType.ENTITY_DELIRIUM
}
local function fixesUpdate(_, npc)
	CommunityVisualFixesScriptedChanges.UpdateDirtSprite(npc)
end
for _,entityId in ipairs(CommunityVisualFixesScriptedChanges.DirtSpritesEntitiesFixes) do
	CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, fixesUpdate, entityId)
	CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NPC_INIT, fixesUpdate, entityId)
end

-- CommunityVisualFixesScriptedChanges.DirtSpritesEntitiesExtras = {
	-- EntityType.ENTITY_PITFALL,
	-- EntityType.ENTITY_LITTLE_HORN,
	-- EntityType.ENTITY_BIG_HORN
-- }
-- local function extrasUpdate(_, npc)
	-- if CommunityVisualFixesResources then
		-- CommunityVisualFixesScriptedChanges.UpdateDirtSprite(npc)
	-- end
-- end
-- for _,entityId in ipairs(CommunityVisualFixesScriptedChanges.DirtSpritesEntitiesExtras) do
	-- CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, extrasUpdate, entityId)
	-- CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NPC_INIT, extrasUpdate, entityId)
-- end

local prefix = "gfx/monsters/classic/monster_197_fred"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/059.000_fred.anm2"] = {
	[DirtType.DIRT] = prefix .. "_dirt" .. suffix,
	[DirtType.WOMB] = prefix .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/monsters/classic/monster_198_lump"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/056.000_lump.anm2"] = {
	[DirtType.DIRT] = prefix .. "_dirt" .. suffix,
	[DirtType.WOMB] = prefix .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/monsters/rebirth/monster_255_nightcrawler"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/255.000_nightcrawler.anm2"] = {
	[DirtType.DIRT] = prefix .. suffix,
	[DirtType.WOMB] = prefix .. "_womb" .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/monsters/classic/monster_199_parabite"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/058.000_para-bite.anm2"] = {
	[DirtType.DIRT] = prefix .. "_dirt" .. suffix,
	[DirtType.WOMB] = prefix .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/monsters/afterbirth/058.001_scarredparabite"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/058.001_scarred para-bite.anm2"] = {
	[DirtType.DIRT] = prefix .. "_dirt" .. suffix,
	[DirtType.WOMB] = prefix .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/monsters/rebirth/monster_244_roundworm"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/244.000_round worm.anm2"] = {
	[DirtType.DIRT] = prefix .. suffix,
	[DirtType.WOMB] = prefix .. "_womb" .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/monsters/afterbirthplus/tubeworm"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/244.001_tube worm.anm2"] = {
	[DirtType.DIRT] = prefix .. "_dirt" .. suffix,
	[DirtType.WOMB] = prefix .. "_womb" .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. suffix
}

local prefix = "gfx/monsters/afterbirth/276.000_roundy"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/276.000_roundy.anm2"] = {
	[DirtType.DIRT] = prefix .. suffix,
	[DirtType.WOMB] = prefix .. "_womb" .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/monsters/afterbirth/289.000_ulcer"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/289.000_ulcer.anm2"] = {
	[DirtType.DIRT] = prefix .. suffix,
	[DirtType.WOMB] = prefix .. "_womb" .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

-- local prefix = "gfx/monsters/afterbirth/291.000_pitfall"
-- local suffix = ".png"
-- CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/291.000_pitfall.anm2"] = {
	-- [DirtType.DIRT] = prefix .. suffix,
	-- [DirtType.WOMB] = prefix .. "_womb" .. suffix,
	-- [DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	-- [DirtType.FLOODED] = prefix .. "_flooded" .. suffix
-- }

----------
--BOSSES--
----------
local prefix = "gfx/bosses/classic/boss_019_pin"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/062.000_pin.anm2"] = {
	[DirtType.DIRT] = prefix .. suffix,
	[DirtType.WOMB] = prefix .. "_womb" .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/bosses/classic/boss_062_scolex"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/062.001_scolex.anm2"] = {
	[DirtType.DIRT] = prefix .. "_dirt" .. suffix,
	[DirtType.WOMB] = prefix .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/bosses/afterbirth/boss_thefrail"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/062.002_thefrail.anm2"] = {
	["Layers"] = {0,1,2,3,4},
	[DirtType.DIRT] = prefix .. suffix,
	[DirtType.WOMB] = prefix .. "_womb" .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/bosses/rebirth/polycephalus"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/269.000_polycephalus.anm2"] = {
	["Layers"] = {0,1,2},
	[DirtType.DIRT] = prefix .. suffix,
	[DirtType.WOMB] = prefix .. "_womb" .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/bosses/rebirth/megafred"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/270.000_megafred.anm2"] = {
	["Layers"] = {0,1},
	[DirtType.DIRT] = prefix .. "_dirt" .. suffix,
	[DirtType.WOMB] = prefix .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

local prefix = "gfx/bosses/afterbirth/thestain"
local suffix = ".png"
CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/401.000_thestain.anm2"] = {
	["Layers"] = {0,1,2,3},
	[DirtType.DIRT] = prefix .. suffix,
	[DirtType.WOMB] = prefix .. "_womb" .. suffix,
	[DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	[DirtType.FLOODED] = prefix .. "_flooded" .. suffix
}

-- local prefix = "gfx/bosses/afterbirth/littlehorn"
-- local suffix = ".png"
-- CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/404.000_littlehorn.anm2"] = {
	-- ["Layers"] = {0,1,2},
	-- [DirtType.DIRT] = prefix .. suffix,
	-- [DirtType.WOMB] = prefix .. "_womb" .. suffix,
	-- [DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	-- [DirtType.FLOODED] = prefix .. "_flooded" .. suffix
-- }

-- local prefix = "gfx/items/pick ups/pickup_016_bomb"
-- local suffix = ".png"
-- CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/004.004_megatroll bomb.anm2"] = {
	-- ["Layers"] = {1},
	-- [DirtType.DIRT] = prefix .. suffix,
	-- [DirtType.WOMB] = prefix .. "_womb" .. suffix,
	-- [DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	-- [DirtType.FLOODED] = prefix .. "_flooded" .. suffix
-- }
-- CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/004.003_troll bomb.anm2"] = {
	-- ["Layers"] = {1},
	-- [DirtType.DIRT] = prefix .. suffix,
	-- [DirtType.WOMB] = prefix .. "_womb" .. suffix,
	-- [DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	-- [DirtType.FLOODED] = prefix .. "_flooded" .. suffix
-- }
-- function CommunityVisualFixesScriptedChanges:onBombUpdate(entity) --resprite little horn's bombs too
	-- if CommunityVisualFixesResources then --check if the resources mod exists
		-- local sprite = entity:GetSprite()
		-- if sprite:IsPlaying("BombReturn") then
			-- CommunityVisualFixesScriptedChanges.UpdateDirtSprite(entity)
		-- end
	-- end
-- end
-- CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, CommunityVisualFixesScriptedChanges.onBombUpdate)
-- CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, CommunityVisualFixesScriptedChanges.onBombUpdate)

-- local prefix = "gfx/bosses/afterbirthplus/boss_bighorn"
-- local suffix = ".png"
-- CommunityVisualFixesScriptedChanges.Anm2ToDirtSprites["gfx/411.000_bighorn.anm2"] = {
	-- ["Layers"] = {0,1,2,3},
	-- [DirtType.DIRT] = prefix .. suffix,
	-- [DirtType.WOMB] = prefix .. "_womb" .. suffix,
	-- [DirtType.SCARRED] = prefix .. "_scarred" .. suffix,
	-- [DirtType.FLOODED] = prefix .. "_flooded" .. suffix
-- }

----------------------------------------
--additional pit sprites functionality--
----------------------------------------
CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()

	--dont do this if we're in a custom stage added by a mod (like revelations)
	if StageAPI and StageAPI.InNewStage and StageAPI.InNewStage() then
		return
	end
	
	if CommunityVisualFixesResources then --check if the resources mod exists
	
		local room = Game():GetRoom() --get the current room
		local backdrop = room:GetBackdropType() --get the room's current backdrop
		
		--get what pit sprite we should use
		local pitSprite = nil
		if backdrop == BackdropType.SCARRED_WOMB then
			local level = Game():GetLevel()
			local stage = level:GetStage()
			if stage == 12 then
				pitSprite = "grid_pit_scarredwomb" --replace scarred womb pits in the void with a bloodless texture because they appear as regular caves pits for some reason
			end
		end
		
		--only replace the pit sprites if the value isn't still nil
		if pitSprite ~= nil then
		
			for i=1, room:GetGridSize() do
			
				local gridEntity = room:GetGridEntity(i)
				if gridEntity ~= nil then
				
					if gridEntity:ToPit() then
					
						local sprite = gridEntity.Sprite
						local spritePath = string.lower(sprite:GetFilename())
						
						if spritePath == "gfx/grid/grid_pit.anm2" then
						
							sprite:ReplaceSpritesheet(0, "gfx/grid/" .. pitSprite .. ".png")
							sprite:LoadGraphics()
							
							gridEntity.Sprite = sprite
							
						end
						
					end
					
				end
			end
			
		end
	
	end
	
end)
