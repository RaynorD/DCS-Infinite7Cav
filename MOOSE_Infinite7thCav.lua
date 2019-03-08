function SpawnCAS()
  if JTACGroup ~= nil then
    JTACGroup:Destroy()
  end
  
  CASGroup = SPAWN:New( "Anchor CAS" )
    :InitRandomizeTemplatePrefixes( "Spawn CAS" ) 
    :SpawnInZone(Zone_AO, true)
  
  local vector3 = CASGroup:GetPointVec2():SetAlt(2000)
  
  JTACGroup = Spawn_JTAC:SpawnFromVec3(vector3)
  JTACGroup:SetTask(JTACGroup:TaskOrbitCircle(2000,150,CASGroup:GetCoordinate()))
  
  MESSAGE:New("New CAS Mission Available.",10,"New Mission"):ToBlue()
end


Zone_AO = ZONE:New( "AO" )

-- Command Center
HQ = GROUP:FindByName("HQ")
CommandCenter = COMMANDCENTER:New( HQ, "Pegasus" )
CommandCenter:MessageToCoalition("Pegasus online")

-- Setup Menus
--MenuCoalitionBlue = MENU_COALITION:New( coalition.side.BLUE, "Missions" )

-- CAP Missions ===============================================================
--ZoneTable_CAP = SET_ZONE:New():FilterPrefixes( "Zone CAP" ):FilterStart()

-- Missions
Scoring = SCORING:New( "CAS" )
Mission_CAS = MISSION
  :New(CommandCenter, "CAS", "Primary", "Destroy vehicles in the valley", coalition.side.BLUE)
  :AddScoring( Scoring )
  
AttackGroups = SET_GROUP:New():FilterCoalitions("blue"):FilterStart()

TargetSetUnit = SET_UNIT:New():FilterCoalitions("red"):FilterStart()

TaskCAS = TASK_A2G_CAS:New( Mission_CAS, AttackGroups,"CAS", TargetSetUnit, "Kill all the things")

--Task_CAS = TASK_A2G_CAS:New(Mission_CAS, SET_CLIENT:New(), "Engage Enemy Ground", TargetSetUnit, "")

---- CAS Missions ===============================================================

JtacSetGroup = SET_GROUP:New():FilterPrefixes( "JTAC" ):FilterStart()
JtacDetection = DETECTION_AREAS:New( JtacSetGroup, 1000 )
CAS_Designate = DESIGNATE:New(CommandCenter, JtacDetection, SET_GROUP:New():FilterCoalitions("blue"):FilterStart())
--CAS_Designate:SetLaseDuration(9999999)
--CAS_Designate:SetLaserCodes({1688,1687,1686,1685})
--CAS_Designate:SetMaximumDesignations(1)
--CAS_Designate:SetMaximumDistanceAirDesignation(20000)
--CAS_Designate:SetThreatLevelPrioritization(true)
--CAS_Designate:AddMenuLaserCode( 1113, "Lase with %d for Su-25T" )

Spawn_JTAC = SPAWN:New( "JTAC" )
--MenuSpawnCAS = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "CAS Mission", MenuCoalitionBlue, SpawnCAS )
SpawnCAS()
--utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/Common/JTAC.lua', getfenv()))(4)


-- SEAD Missions ===============================================================
--ZoneTable_SEAD = SET_ZONE:New():FilterPrefixes( "Zone SEAD" ):FilterStart()



