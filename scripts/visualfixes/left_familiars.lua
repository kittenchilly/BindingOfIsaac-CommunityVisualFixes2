----------------------------------------
--restore familiar left facing sprites--
----------------------------------------
function CommunityVisualFixesScriptedChanges:onLeftFacingFamiliarUpdate(familiar)
	local sprite = familiar:GetSprite() --get the familiar's sprite
	local data = familiar:GetData()
	
	if sprite.FlipX then --the game flips the familiar's sprite, so we check for this, undo it, and play the unique animations based on what animation it is currently playing
		sprite.FlipX = false
		if sprite:IsPlaying("IdleSide") then
			sprite:Play("IdleSide2", false)
		elseif sprite:IsPlaying("FloatSide") then
			sprite:Play("FloatSide2", false)
		elseif sprite:IsPlaying("ShootSide") then
			sprite:Play("ShootSide2", false)
		elseif sprite:IsPlaying("FloatShootSide") then
			sprite:Play("FloatShootSide2", false)
		end
	end
	
	local player = familiar.Player --get the player that owns this familiar
	if player ~= nil then --check all these things to be absolutely sure the player is real
		if player:Exists() then
			if player.Type == EntityType.ENTITY_PLAYER then
				if player:ToPlayer() then --at this point we should be pretty confident that this is a player
					player = player:ToPlayer() --enable the player-specific functions
					--we have to manually set the sprite's frames because if the player is holding the left arrow key it will constantly play this animation
					if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
						if sprite:IsPlaying("FloatSide2") or sprite:IsPlaying("FloatShootSide2") then
							local animation = "FloatShootSide2"
							if sprite:IsPlaying("FloatSide2") then
								animation = "FloatSide2"
							end
							
							sprite:Play(animation, false)
							if not data.CVFShootLeftFrame or not data.CVFLastShootLeft or not data.CVFLastLeftAnimation or (data.CVFShootLeftFrame and data.CVFShootLeftFrame >= 16) or (familiar.FrameCount - data.CVFLastShootLeft > 1) or (data.CVFLastLeftAnimation ~= animation) then
								data.CVFShootLeftFrame = -1
							end
							data.CVFShootLeftFrame = data.CVFShootLeftFrame + 1
							sprite:SetFrame(animation, data.CVFShootLeftFrame)
							data.CVFLastShootLeft = familiar.FrameCount
							data.CVFLastLeftAnimation = animation
						end
					elseif data.CVFLastLeftAnimation then
						sprite:Play(data.CVFLastLeftAnimation, false)
						data.CVFShootLeftFrame = nil
						data.CVFLastShootLeft = nil
						data.CVFLastLeftAnimation = nil
					end
				end
			end
		end
	end
end
CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, CommunityVisualFixesScriptedChanges.onLeftFacingFamiliarUpdate, FamiliarVariant.MONGO_BABY)

function CommunityVisualFixesScriptedChanges:onLeftFacingFamiliarRequiresResourcesUpdate(familiar)
	if CommunityVisualFixesResources then --check if the resources mod exists
		CommunityVisualFixesScriptedChanges:onLeftFacingFamiliarUpdate(familiar)
	end
end
CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, CommunityVisualFixesScriptedChanges.onLeftFacingFamiliarRequiresResourcesUpdate, FamiliarVariant.ROTTEN_BABY)
CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, CommunityVisualFixesScriptedChanges.onLeftFacingFamiliarRequiresResourcesUpdate, FamiliarVariant.BALL_OF_BANDAGES_2)
