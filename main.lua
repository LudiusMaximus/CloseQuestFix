local folderName = ...
local L = LibStub("AceAddon-3.0"):NewAddon(folderName, "AceTimer-3.0")

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("GOSSIP_SHOW")
eventFrame:RegisterEvent("QUEST_GREETING")
eventFrame:RegisterEvent("QUEST_FINISHED")
eventFrame:RegisterEvent("GOSSIP_CLOSED")
eventFrame:RegisterEvent("QUEST_DETAIL")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("QUEST_TURNED_IN")


local gossipShown = false
local questDetailsOpened = 0


eventFrame:SetScript("OnEvent", function(self, event, ...)

  -- print(event, questDetailsOpened)

  -- Initialise NPC interaction.
  -- Some NPC interaction is initialised with just QUESTLINE_UPDATE,
  -- but we leave this out here for now!
  if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" then
    questDetailsOpened = 0
    gossipShown = true
    L:CancelAllTimers()


  -- To reset the questDetailsOpened counter,
  -- if a quest is started with QUEST_DETAIL is declined.
  elseif event == "QUEST_FINISHED" then
    if not QuestFrame:IsShown() then
      questDetailsOpened = 0
      gossipShown = false
    end
    
    
    
  elseif event == "GOSSIP_CLOSED" then
    gossipShown = false
    

  -- The order in which QUEST_ACCEPTED and QUEST_DETAIL of the next quest happen is indeterministic.
  -- Hence we have to use this counter such that CloseIfDone() finds 1 or 0 depending
  -- on whether another QUEST_DETAIL has been opened.
  elseif event == "QUEST_DETAIL" then
    questDetailsOpened = questDetailsOpened + 1
    -- Must not set gossipShown = true here, otherwise it will not close after QUEST_ACCEPTED.
    
  elseif event == "QUEST_ACCEPTED" and not QuestGetAutoAccept() then
    questDetailsOpened = questDetailsOpened - 1
    -- Must not be negative, otherwise a later QUEST_DETAIL may not increase over 0.
    if questDetailsOpened < 0 then
      questDetailsOpened = 0
    end
    L:ScheduleTimer("CloseIfDone", 0.3)
  
  
  -- Some quests (e.g. "Wolves at Our Heels") also do not close after handing them in!
  elseif event == "QUEST_TURNED_IN" then
    L:ScheduleTimer("CloseIfDone", 0.3)
  
  end

  -- print("questDetailsOpened", questDetailsOpened, gossipShown)

end)



function L:CloseIfDone()

  if questDetailsOpened < 1 and not gossipShown then
    -- print("Closing Quest")
    CloseQuest()
  end
  
end

