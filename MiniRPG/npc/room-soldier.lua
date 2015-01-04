
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
    if self.game:getMetaValueForKey("room_soldier_greeting") == "true" then
        --self.game:playSound("soft.mp3")
        self.game:shake()
        self.game:flash()
        self.game:npc_say("soldier","千万把公主带回家！！！")
    else
        self.game:npc_say("soldier", "You must save the princess! She has been taken!")
        self.game:setMeta_forKey("true","room_soldier_greeting")
    end
end

-- 4
soldier = soldier:new(game)
npcs["soldier"] = soldier
