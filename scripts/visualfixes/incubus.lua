------------------------------------------
--play incubus brimstone shoot animation--
------------------------------------------

--these tables contain the animations we should play if a certain other animation was playing.
local incubusShootToBrimstone = {
	ShootDown = "Shoot2Down",
	ShootSide = "Shoot2Side",
	ShootUp = "Shoot2Up",
	FloatShootDown = "FloatShoot2Down",
	FloatShootSide = "FloatShoot2Side",
	FloatShootUp = "FloatShoot2Up"
}

--this table is used instead of the above table if CommunityVisualFixesResources is not found.
local incubusShootToBrimstoneNoResources = {
	ShootDown = "Shoot2Down",
	ShootSide = "Shoot2Side",
	ShootUp = "Shoot2Up",
	FloatShootDown = "Shoot2Down",
	FloatShootSide = "Shoot2Side",
	FloatShootUp = "Shoot2Up"
}

CommunityVisualFixesScriptedChanges:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, incubus)
	local player = incubus.Player --get the player that owns this familiar
	if player ~= nil and player:Exists() and player.Type == EntityType.ENTITY_PLAYER then --check all these things to be absolutely sure the player is real
		if player:ToPlayer() then --at this point we should be pretty confident that this is a player
			player = player:ToPlayer() --enable the player-specific functions
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then --check if the player has brimstone
				local sprite = incubus:GetSprite() --get incubus' sprite
				
				--choose which table to use to select what animations to play
				local animationTable = incubusShootToBrimstone
				if not CommunityVisualFixesResources then
					animationTable = incubusShootToBrimstoneNoResources
				end
				
				for animationPlaying, animationShouldPlay in pairs(animationTable) do
					if sprite:IsPlaying(animationPlaying) then
						sprite:Play(animationShouldPlay, false)
					end
				end
			end
		end
	end
end, FamiliarVariant.INCUBUS)
