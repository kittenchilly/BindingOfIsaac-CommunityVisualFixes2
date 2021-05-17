---------------------------------------------------------
--add float animations to buddy in a box using overlays--
---------------------------------------------------------

--this table converts the name of an animation and its frame into other animations
local buddyAnimations = {
	[Direction.LEFT] = {
		[0] = "LeftFloat",
		[1] = "LeftFloatShoot"
	},
	[Direction.UP] = {
		[0] = "UpFloat",
		[1] = "UpFloatShoot"
	},
	[Direction.RIGHT] = {
		[0] = "RightFloat",
		[1] = "RightFloatShoot"
	},
	[Direction.DOWN] = {
		[0] = "DownFloat",
		[1] = "DownFloatShoot"
	}
}

CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, buddy, offset)
	if CommunityVisualFixesResources then
		local sprite = buddy:GetSprite()
		local data = buddy:GetData()
		
		if not Game():IsPaused() then
			if buddy.FrameCount >= 5 and not data.CVFBlankedBuddySpritesheet then
				sprite:ReplaceSpritesheet(0,"gfx/characters/player2/blank.png")
				sprite:LoadGraphics()
				data.CVFBlankedBuddySpritesheet = true
			end
			
			local currentFrame = math.floor(sprite:GetFrame()*0.5)
			local shootDirection = buddy.Player:GetFireDirection()
			
			if shootDirection == Direction.NO_DIRECTION then
				if currentFrame == 1 and data.CVFShootDirection then
					shootDirection = data.CVFShootDirection
				else
					shootDirection = Direction.DOWN
				end
			end
			
			for direction, frameTable in pairs(buddyAnimations) do
				if direction == shootDirection then
					for frame, animationShouldPlay in pairs(frameTable) do
						if currentFrame == frame and not sprite:IsOverlayPlaying(animationShouldPlay) then
							data.CVFShootDirection = nil
							if currentFrame == 1 then
								data.CVFShootDirection = shootDirection
							end
							sprite:PlayOverlay(animationShouldPlay, true)
						end
					end
				end
			end
		end
	end
end, FamiliarVariant.BUDDY_IN_A_BOX)

CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if CommunityVisualFixesResources then
		for _, buddy in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BUDDY_IN_A_BOX, -1, false, false)) do
			local data = buddy:GetData()
			data.CVFBlankedBuddySpritesheet = false
		end
	end
end)
