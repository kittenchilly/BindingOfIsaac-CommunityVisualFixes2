--add a global just in case other mods want to know that we're active
CommunityVisualFixesResources = RegisterMod("Community Visual Fixes - Resources", 1)

--legacy variable just in case some mod checks for this
RealConeHeadVisualFixesResourcesMod = CommunityVisualFixesResources

--we have to put most of our other scripted changes in a separate mod because of crappy load order stuff. zzzzzCommunity Visual Fixes is a great workaround for resources, but it causes the code to load after all other mods too.