-- 1
soldier = {}
-- 2
function soldier:new(game)  
    local object = { 
        game = game,
    }
    setmetatable(object, { __index = soldier })

    return object
end 
-- 3
function soldier:interact()
    if self.game:getMetaValueForKey("town_soldier_greeting") == "true" then
        --self.game:playSound("scenereplace.mp3")
        self.game:npc_say("soldier","公主在哪里????")
    else
        self.game:npc_say("soldier", "公主不在这里！！！")
        self.game:setMeta_forKey("true","town_soldier_greeting")
    end
end

-- 4
soldier = soldier:new(game)
npcs["soldier"] = soldier
