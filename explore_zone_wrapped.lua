
----------------------------------------------------------------------------
--  drive_to.lua
--
--  Created: Sat Jul 12 13:25:47 2014
--  Copyright  2008       Tim Niemueller [www.niemueller.de]
--             2014-2015  Tobias Neumann
--
----------------------------------------------------------------------------

--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Library General Public License for more details.
--
--  Read the full text in the LICENSE.GPL file in the doc directory.

-- Initialize module
module(..., skillenv.module_init)

-- Crucial skill information
name               = "explore_zone_wrapped"
fsm                = SkillHSM:new{name=name, start="EXPLORE_ZONE", debug=false}
depends_skills     = { "explore_zone" }
depends_interfaces = { }

documentation      = [==[Explore zone given the zone identification e.g. "Z22"

Parameters:
      zone:         Zone identification
]==]

local ZONE_HEIGHT = 1.5
local ZONE_WIDTH  = 2.0
local DISABLE_CLUSTER = false

-- Initialize as skill module
skillenv.skill_module(_M)

function node_is_valid(self)
  if self.fsm.vars.point_set then
    return self.fsm.vars.point_valid
  end
  return true
end

fsm:define_states{ export_to=_M,
  closure={navgraph=navgraph, node_is_valid=node_is_valid},
  {"EXPLORE_ZONE",       SkillJumpState, skills={{explore_zone}},            final_to="FINAL", fail_to="FAILED"},
}

--fsm:add_transitions{
--  { "FORCE_SET_JUST_ORI", "TIMEOUT",       cond=true },
--  { "TIMEOUT", "SKILL_GLOBAL_MOTOR_MOVE",  timeout=0.5 },
--}

function EXPLORE_ZONE:init()
         print("explore ", string.sub(self.fsm.vars.zone, 2))
         -- This code is directly ported from the utils-get-zone-edges - function of the CLIPS-Agent
         zone = tonumber(string.sub(self.fsm.vars.zone, 2))
         zone_cyan = zone
         if self.fsm.vars.team == "CYAN" then
            search_tags = {65,1,17,33,177,66,2,18,34,178, 81,82}
         else
            search_tags = {161,97,113,129,145,162,98,114,130,146,49,50}
         end

         if zone > 12 then
            zone_cyan = zone_cyan - 12
         end
         zone_x = math.floor((zone_cyan - 1) / 4)
         zone_y = (zone_cyan - 1) % 4
         
         y_min =  zone_y * ZONE_HEIGHT
         y_max = (zone_y + 1) * ZONE_HEIGHT
         x_min =  zone_x * ZONE_WIDTH
         x_max = (zone_x + 1) * ZONE_WIDTH

         if zone > 12 then
            x_min = -x_min
            x_max = -x_max
         end

	 self.args["explore_zone"] = {min_x = x_min, min_y = y_min, max_x = x_max, max_y = y_max, search_tags = search_tags}
end
