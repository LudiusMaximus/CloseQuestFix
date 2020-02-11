local folderName = ...
local L = LibStub("AceAddon-3.0"):NewAddon(folderName, "AceTimer-3.0")

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("GOSSIP_SHOW")
eventFrame:RegisterEvent("QUEST_GREETING")
eventFrame:RegisterEvent("GOSSIP_CLOSED")
eventFrame:RegisterEvent("QUEST_DETAIL")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("QUEST_TURNED_IN")


local gossipShown = false
local questDetailsOpened = 0


eventFrame:SetScript("OnEvent", function(self, event, ...)

  -- print(event, questDetailsOpened)

  if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" then
    questDetailsOpened = 0
    gossipShown = true
    L:CancelAllTimers()
  end

  if event == "GOSSIP_CLOSED" then
    gossipShown = false
    
  elseif event == "QUEST_DETAIL" then
    questDetailsOpened = questDetailsOpened + 1
    
  elseif event == "QUEST_TURNED_IN" or (event == "QUEST_ACCEPTED" and not QuestGetAutoAccept()) then
    questDetailsOpened = questDetailsOpened - 1
    L:ScheduleTimer("closeIfDone", 0.3)
    
  end

  -- print(questDetailsOpened)

end)



function L:closeIfDone()

  if questDetailsOpened < 1 and not gossipShown then
    -- print("Closing Quest")
    CloseQuest()
  end
  
end

