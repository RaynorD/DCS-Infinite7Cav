-- Utility
function DestroyGroups(prefix)
  local GroupSet = SET_GROUP:New():FilterPrefixes(prefix):FilterStart()
  if GroupSet:Count() > 0 then
    GroupSet:ForEachGroup(function(g) g:Destroy() end)
  end
end

-- CAS
function SpawnCASTarget()
  DestroyGroups("CAS Target")
  
  local CasGroup = Spawn_Group_CAS_Target:SpawnInZone(Zone_AO,true)

  MESSAGE:New("New CAS group spawned at "..CasGroup:GetCoordinate():ToStringLLDMS(),300,"Debug"):ToBlue()
  
  CasGroup:HandleEvent(EVENTS.Dead)
  function CasGroup:OnEventDead(EventData)
    local unitGroup = EventData.IniDCSGroup
    local unitName = EventData.IniUnitName
    local groupHealth = unitGroup:GetSize() / unitGroup:GetInitialSize()
    MESSAGE:New("CAS target ("..unitName..") killed, group health: "..groupHealth,10,"Debug"):ToBlue()
  end
  
  SpawnAlliesForCas(CasGroup)
  SpawnJtacForCas(CasGroup)
  
  -- Debug cas
  --CONTROLLABLE:GetWayPoints()
end

function SpawnJtacForCas(group)
  DestroyGroups("CAS JTAC")
  local jtac = Spawn_CAS_JTAC:SpawnFromVec3(group:GetPointVec2():SetAlt(2000))
  jtac:SetTask(jtac:TaskOrbitCircle(2000,150,group:GetCoordinate()))
end

function SpawnAlliesForCas(group)
  DestroyGroups("CAS Allies")
  local vec2 = group:GetCoordinate():GetRandomVec2InRadius(2000,2000)
  Spawn_CAS_Allies:SpawnFromPointVec2(COORDINATE:NewFromVec2(vec2))
end

--function CasGroupUnitKilled(unit)
--  local unitGroup = unit:GetGroup()
  
  --if groupHealth < 0.15 then
  --  if CasGradualKillSched ~= nil then
  --    SCHEDULER:Remove(CasGradualKillSched)
  --    CasGradualKillSched = nil
  --  end
  --  SCHEDULER:New( nil, respawnCAS, {unitGroup}, 1)
  --end
--end

function DebugCasGradualKill()
  MESSAGE:New("Starting CAS gradual kill.",10,"Debug"):ToBlue()
  local GroupTarget, Index = Spawn_Group_CAS_Target:GetFirstAliveGroup()
  -- loop through and kill each vehicle slowly
  CasGradualKillSched = SCHEDULER:New( nil, 
    function(GroupTarget)
      local units = GroupTarget:GetUnits()
      local unitToKill = nil
      for unitCount = 1, #units do
        if units[unitCount]:IsAlive() then
          unitToKill = units[unitCount]
          break
        end
      end
      if unitToKill ~= nill then
        unitToKill:Destroy()
      end
    end, {GroupTarget}, 1, 1
  ):Start()
end

function DebugDestroyCAS()
  MESSAGE:New("Destroying CAS target and associated groups.",10,"Debug"):ToBlue()
  --local GroupTarget, Index = Spawn_Group_CAS_Target:GetFirstAliveGroup()
  --GroupTarget:Destroy(true)
  DestroyGroups("CAS Target")
  DestroyGroups("CAS JTAC")
  DestroyGroups("CAS Allies")
end

-- CAP
function DebugDestroyCAP()
  MESSAGE:New("Destroying CAP target group.",10,"Debug"):ToBlue()
  DestroyGroups("CAP Target")
end

function SpawnCAPTarget()
  --DestroyGroups("CAP Target")
  local CapGroup = Spawn_CAP:Spawn()

  MESSAGE:New("New CAP target spawned at "..CapGroup:GetCoordinate():ToStringLLDMS(),20,"Debug"):ToBlue()
end

-- SEAD
function SpawnSEADTarget()
  DestroyGroups("SEAD Target")
  local SeadGroup = Spawn_SEAD:Spawn()

  MESSAGE:New("New SEAD target spawned at "..SeadGroup:GetCoordinate():ToStringLLDMS(),30,"Debug"):ToBlue()
end

function DebugDestroySEAD()
  MESSAGE:New("Destroying SEAD target group.",10,"Debug"):ToBlue()
  DestroyGroups("SEAD Target")
end



Zone_AO = ZONE:New( "AO" )

-- Settings
_SETTINGS:SetPlayerMenuOn()
_SETTINGS:SetA2G_LL_DMS()

-- Tankers
SPAWN:New("Texaco"):InitRepeatOnLanding():Spawn()
SPAWN:New("Arco"):InitRepeatOnLanding():Spawn()

---- Command Center
HQ = GROUP:FindByName("HQ")
CommandCenter = COMMANDCENTER:New( HQ, "Pegasus 1" )
CommandCenter:MessageToCoalition("Operation Watchtower underway. Request tasking using the F10 menu.")

Mission_Defend = MISSION
  :New(CommandCenter, "Watchtower", "Primary", "Defend the valley from hostile invasion.", coalition.side.BLUE)

---- Setup Menus
MenuTesting = MENU_COALITION:New( coalition.side.BLUE, "Spawn Testing" )

MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn CAS", MenuTesting, SpawnCASTarget )
MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn CAP", MenuTesting, SpawnCAPTarget )
--MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Start CAS Gradual kill", MenuTesting, DebugCasGradualKill )
MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Spawn SEAD", MenuTesting, SpawnSEADTarget )

MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Destroy CAS", MenuTesting, DebugDestroyCAS )
MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Destroy CAP", MenuTesting, DebugDestroyCAP )
MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Destroy SEAD", MenuTesting, DebugDestroySEAD )

-- CAP Task ===============================================================
ZoneTable_CAP = {
  ZONE:New("Zone CAP 1"),
  ZONE:New("Zone CAP 2"),
  ZONE:New("Zone CAP 3")
}
Spawn_CAP = SPAWN:New("CAP Target")
Spawn_CAP:InitRandomizeTemplatePrefixes("Spawn CAP")
--Spawn_CAP:InitLimit( 2, 9999 )
Spawn_CAP:InitRepeatOnLanding()
Spawn_CAP:InitRandomizeZones(ZoneTable_CAP)
--Spawn_CAP:SpawnScheduled( 5, 0 )

-- CAS Task ===============================================================
local CASAttackSet = SET_GROUP:New()
  :FilterCoalitions("blue")
  :FilterStart()

local CASJTACSet = SET_GROUP:New()
  :FilterPrefixes( "CAS JTAC" )
  :FilterCoalitions("blue")
  :FilterStart()

local JtacDetection = DETECTION_AREAS:New( CASJTACSet, 16000 )

CASDispatcher = TASK_A2G_DISPATCHER:New(Mission_Defend, CASAttackSet, JtacDetection)

CAS_Designate = DESIGNATE:New(CommandCenter, JtacDetection, CASAttackSet)
--CAS_Designate:SetLaseDuration(300)
CAS_Designate:SetLaserCodes({1688,1687,1686,1685})
--CAS_Designate:SetMaximumDesignations(1)
--CAS_Designate:SetMaximumDistanceAirDesignation(20000)
--CAS_Designate:SetThreatLevelPrioritization(true)
--CAS_Designate:AddMenuLaserCode( 1113, "Lase with %d for Su-25T" )

Spawn_CAS_JTAC = SPAWN:New( "CAS JTAC" )
Spawn_CAS_Allies = SPAWN:New( "CAS Allies" )
--MenuSpawnCAS = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "CAS Mission", MenuCoalitionBlue, SpawnCAS )
Spawn_Group_CAS_Target = SPAWN:New( "CAS Target" )
  :InitRandomizeTemplatePrefixes( "Spawn CAS" ) 
  --:InitRandomizeZones({Zone_AO})
  --:InitRandomizePosition(true, 25000, 0)
  --:InitLimit(999, 3)

SpawnCASTarget()


-- SEAD Task ===============================================================
--ZoneTable_SEAD = SET_ZONE:New():FilterPrefixes( "Zone SEAD" ):FilterStart()
ZoneTable_SEAD = {
  ZONE:New("Zone SEAD 1"),
  ZONE:New("Zone SEAD 2"),
  ZONE:New("Zone SEAD 3"),
  ZONE:New("Zone SEAD 4"),
  ZONE:New("Zone SEAD 5"),
  ZONE:New("Zone SEAD 6")
}
Spawn_SEAD = SPAWN:New("SEAD Target")
Spawn_SEAD:InitRandomizeTemplatePrefixes("Spawn SEAD")
Spawn_SEAD:InitRandomizeZones(ZoneTable_SEAD)

SpawnSEADTarget()

