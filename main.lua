--make this a global just in case other mods want to know that we're active.
CommunityVisualFixesScriptedChanges = RegisterMod("Community Visual Fixes - Scripted Changes", 1)

--legacy variable just in case some mod checks for this.
RealConeHeadVisualFixesMod = CommunityVisualFixesScriptedChanges

--we're trying to keep this as visual fixes, nothing gameplay altering.
--this script is only used for cases where simply replacing an animation or png isn't enough to fix a visual oddity.

--im going to try to add a lot of comments here to avoid confusion and maybe to help people learn a bit.

--load the scripts
require("scripts.visualfixes.incubus")
require("scripts.visualfixes.dirt")
require("scripts.visualfixes.gusher")
require("scripts.visualfixes.left_familiars")
require("scripts.visualfixes.buddy_box")
