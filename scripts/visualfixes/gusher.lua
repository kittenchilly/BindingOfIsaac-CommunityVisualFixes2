------------------------------
--unique gusher body sprites--
------------------------------
function CommunityVisualFixesScriptedChanges:onGusherUpdate(entity)
	if CommunityVisualFixesResources then --check if the resources mod exists
		if entity.Variant == 0 or entity.Variant == 1 then
			local data = entity:GetData()
			if data.CVFReplaceSprite and not data.CVFReplacedSprite then --we set this to the spritesheet we want to replace this with
				local sprite = entity:GetSprite()
				local anm2 = sprite:GetFilename() --get the current animation file
				sprite:Reset() --reset it, as it has a color tint in the animation's layer that we cant control
				sprite:Load(anm2, true) --reload the animation file
				sprite:ReplaceSpritesheet(0, data.CVFReplaceSprite) --apply our custom spritesheet
				sprite:LoadGraphics()
				data.CVFReplacedSprite = true --set this to true so it doesnt happen again
			end
		end
	end
end
CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_NPC_UPDATE, CommunityVisualFixesScriptedChanges.onGusherUpdate, EntityType.ENTITY_GUSHER)
CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NPC_INIT, CommunityVisualFixesScriptedChanges.onGusherUpdate, EntityType.ENTITY_GUSHER)

function CommunityVisualFixesScriptedChanges:onMrMawUpdate(entity)
	if CommunityVisualFixesResources then --check if the resources mod exists
		local data = entity:GetData()
		if not data.CVFReplacedSprite then
			if entity.Variant == 0 or entity.Variant == 1 then
				data.CVFReplaceSprite = "gfx/monsters/classic/monster_141_mr_maw_body_gush.png"
			elseif entity.Variant == 2 or entity.Variant == 3 then
				data.CVFReplaceSprite = "gfx/monsters/classic/monster_142_mr_redmaw_body_gush.png"
			end
		end
	end
end
CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_NPC_UPDATE, CommunityVisualFixesScriptedChanges.onMrMawUpdate, EntityType.ENTITY_MRMAW)
CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NPC_INIT, CommunityVisualFixesScriptedChanges.onMrMawUpdate, EntityType.ENTITY_MRMAW)

function CommunityVisualFixesScriptedChanges:onLeperUpdate(entity)
	if CommunityVisualFixesResources then --check if the resources mod exists
		local data = entity:GetData()
		if not data.CVFReplacedSprite then
			if entity.Variant == 0 then
				data.CVFReplaceSprite = "gfx/monsters/classic/monster_000_bodies02_scarred.png"
			end
		end
	end
end
CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_NPC_UPDATE, CommunityVisualFixesScriptedChanges.onLeperUpdate, EntityType.ENTITY_LEPER)
CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NPC_INIT, CommunityVisualFixesScriptedChanges.onLeperUpdate, EntityType.ENTITY_LEPER)
