local folderName = ...
local L = LibStub("AceAddon-3.0"):NewAddon(folderName, "AceTimer-3.0")

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("GOSSIP_SHOW")
eventFrame:RegisterEvent("QUEST_GREETING")
eventFrame:RegisterEvent("QUEST_PROGRESS")
eventFrame:RegisterEvent("QUEST_COMPLETE")

eventFrame:RegisterEvent("QUEST_FINISHED")


eventFrame:RegisterEvent("QUEST_DETAIL")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("QUEST_TURNED_IN")



local questDetailsOpened = 0


eventFrame:SetScript("OnEvent", function(self, event, ...)

  -- print(event, questDetailsOpened)

  -- Initialise NPC interaction.
  -- Some NPC interaction is initialised with just QUESTLINE_UPDATE,
  -- but we leave this out here for now!
  if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" or event == "QUEST_PROGRESS" or event == "QUEST_COMPLETE" then
    L:CancelAllTimers()
    questDetailsOpened = 0


  -- To reset the questDetailsOpened counter,
  -- if a quest started with QUEST_DETAIL is declined.
  elseif event == "QUEST_FINISHED" then
    if QuestFrame and not QuestFrame:IsShown() then
      questDetailsOpened = 0
    end


  -- The order in which QUEST_ACCEPTED and QUEST_DETAIL of the next quest happen is indeterministic.
  -- Hence we have to use this counter such that CloseIfDone() finds 1 or 0 depending
  -- on whether another QUEST_DETAIL has been opened.
  elseif event == "QUEST_DETAIL" then
    questDetailsOpened = questDetailsOpened + 1
    L:ScheduleTimer("ResetQuestDetailsOpened", 1.0)

  elseif event == "QUEST_ACCEPTED" and not QuestGetAutoAccept() then
    questDetailsOpened = questDetailsOpened - 1
    -- Must not be negative, otherwise a later QUEST_DETAIL may not increase over 0.
    if questDetailsOpened < 0 then
      questDetailsOpened = 0
    end
    -- print("QUEST_ACCEPTED", GetTime())
    L:ScheduleTimer("CloseIfDone", 0.75)


  -- Some quests (e.g. "Wolves at Our Heels") also do not close after handing them in!
  elseif event == "QUEST_TURNED_IN" then
    -- print("QUEST_TURNED_IN", GetTime())
    L:ScheduleTimer("CloseIfDone", 0.75)
  end

  -- print("questDetailsOpened", questDetailsOpened)

end)



function L:CloseIfDone()
  if questDetailsOpened < 1 and QuestFrame and QuestFrame:IsShown() then
    -- print("Closing Quest !!!!!!!!!!!!!!!!!!!!", GetTime())
    CloseQuest()
  end
end


-- For some quest givers it is possible to click on the NPC repeatedly and get a
-- QUEST_DETAIL event every time without another event in between. To prevent the
-- questDetailsOpened counter from growing infinitely we reset it after 1 second.
-- We cannot reset it immediately because the actual purpose of this counter is
-- to register the indeterministic opening and closing of two successive quests.
function L:ResetQuestDetailsOpened()
  if questDetailsOpened > 1 then
    -- print("Reseting")
    questDetailsOpened = 1
  end
end
