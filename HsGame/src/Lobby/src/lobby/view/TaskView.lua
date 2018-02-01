-- 任务
-- @date 2017.08.22
-- @author tangwen

local TaskView = class("TaskView", lib.layer.Window)

-- 这里初始化所有滑动界面信息，如有特殊的单独处理
local TASK_SCROLLVIEW_SIZE = cc.size(1060, 560)  -- 滑动界面大小
local TASK_VIEW_POSITION = cc.p(-463, -270)		-- 滑动界面初始化位置
local RECORD_SIZE = cc.size(925,93)   			--滑动界面节点大小 记录节点大小 
local TASK_INTERVAL_V = 119   --每条记录之间的间距 竖 
local TASK_MAX_COL = 1		 -- 列数

function TaskView:ctor(data)
	self._taskData = data
    TaskView.super.ctor(self,ConstantsData.WindowType.WINDOW_TASK)
	self:initView()
end

function TaskView:initView()
    local bg = self._root
    self._bg = bg

    local bgSize = bg:getContentSize()
    local title = ccui.ImageView:create("Lobby_task_title.png", ccui.TextureResType.plistType)
    title:setPosition(bgSize.width/2, bgSize.height - 60)
    bg:addChild(title)

	self._taskScrollView = self:createScrollView(#self._taskData)
	self._taskScrollView:setPosition(25,20)
	bg:addChild(self._taskScrollView,1)

	local contentSize = cc.size(TASK_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (#self._taskData - 1) * TASK_INTERVAL_V + 36)
	if contentSize.height < TASK_SCROLLVIEW_SIZE.height then
		contentSize = TASK_SCROLLVIEW_SIZE
	end

    local offset = cc.p(0, contentSize.height)
    local PosY = 0

    self._TaskList = {}

	for k, v in ipairs(self._taskData) do
        local record= self:createTaskRecord(v)
        local row = k
        local x =40 + offset.x +RECORD_SIZE.width/2 
        local y =50 + offset.y - row * TASK_INTERVAL_V -- 第一个点最高
        record:setPosition(x,y)
        self._taskScrollView:addChild(record)
        table.insert(self._TaskList,record)
    end

    self._NoTaskText = cc.Label:createWithTTF("暂时没有任务哟!",GameUtils.getFontName(),32)
    self._NoTaskText:setPosition(bgSize.width/2, bgSize.height/2)
    bg:addChild(self._NoTaskText)
    self._NoTaskText:hide()

    if #self._taskData == 0 then
        self._NoTaskText:show()
    end

end

-- 创建scrollView界面
function TaskView:createScrollView(rowNum)
	local contentSize = cc.size(TASK_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (rowNum - 1) * TASK_INTERVAL_V + 36)

	local _ScrollView = ccui.ScrollView:create()
    _ScrollView:setTouchEnabled(true)--触摸的属性
    _ScrollView:setBounceEnabled(true)--弹回的属性
    _ScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _ScrollView:setScrollBarEnabled(false)
    _ScrollView:setDirection(ccui.ScrollViewDir.vertical)
    _ScrollView:setContentSize(TASK_SCROLLVIEW_SIZE)
    _ScrollView:setInnerContainerSize(contentSize)
    _ScrollView:setPosition(TASK_VIEW_POSITION)

    return _ScrollView
end


-- 创建排行榜记录条
function TaskView:createTaskRecord(data)
	if data == nil then
		return
	end

	-- local taskData = cc.exports.lib.JsonUtil:decode(data.Award)
    print("任务记录任务记录任务记录")
    dump(data)

	local size = cc.size(1043, 117)
	local record = ccui.Layout:create()

   	local bg =  ccui.ImageView:create("Lobby_task_record.png",ccui.TextureResType.plistType)
    -- bg:setContentSize(size)
    bg:setPosition(cc.p(20,0))
    record:addChild(bg)

    record.GameID = data.gameId
    record.GameType = data.gameType
    record.TaskID = data.id

    -- local iconBg = ccui.ImageView:create("Lobby_task_record_icon_bg.png", ccui.TextureResType.plistType)
    -- iconBg:setPosition(cc.p(-size.width/2 + 50,-1))
    -- record:addChild(iconBg)

    local PropsId = 0
    local taskNum = 0
    local taskName = ""
    if data.bonusScore > 0 then  -- 金币 
        PropsId = ConstantsData.PointType.POINT_COINS
        taskNum = data.bonusScore
        taskName = "金币"
    elseif data.bonusDiamond > 0 then --钻石
        PropsId = ConstantsData.PointType.POINT_DIAMOND
        taskNum = data.bonusScore
        taskName = "钻石"
    elseif data.bonusRoomCard > 0 then --房卡
        PropsId = ConstantsData.PointType.POINT_ROOMCARD
        taskNum = data.bonusScore
        taskName = "房卡"
    else
        print("任务奖励物品格式错误:")
    end

    local iconImg = ""
    if PropsId == ConstantsData.PointType.POINT_COINS then  -- 金币 
    	iconImg = "Lobby_task_record_icon.png"
    elseif PropsId == ConstantsData.PointType.POINT_DIAMOND then --钻石
    	iconImg = "Reward_icon_diamond.png"
    elseif PropsId == ConstantsData.PointType.POINT_ROOMCARD then --房卡
    	iconImg = "Reward_icon_roomcard.png"
    else
    	print("奖励物品格式错误:",PropsId)
    end

    local IsFinish = false
    local taskProcessStr = ""
    if data.roundPlayed > 0 then
        taskProcessStr = data.userRoundPlayed .."/".. data.roundPlayed
        print("11111",data.userRoundPlayed,data.roundPlayed)
        if data.userRoundPlayed  >=  data.roundPlayed then -- 完成任务
            IsFinish = true
        end
    elseif data.roundWin > 0 then
        taskProcessStr = data.userRoundWin .."/".. data.roundWin
        if data.userRoundWin  >=  data.roundWin then -- 完成任务
            IsFinish = true
        end
    elseif data.scoreWin > 0 then
        taskProcessStr = data.userScoreWin .."/".. data.scoreWin
        if data.userScoreWin  >=  data.scoreWin then -- 完成任务
            IsFinish = true
        end
    end
    
    local giftIcon = ccui.ImageView:create(iconImg, ccui.TextureResType.plistType)
    giftIcon:setContentSize(86,82)
    giftIcon:setScale(0.7)
    giftIcon:setPosition(cc.p(-size.width/2 + 65,0))
    record:addChild(giftIcon)

    local getBtnImg = "Lobby_task_btn.png"
    record._getBtn = lib.uidisplay.createUIButton({
        normal = getBtnImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            logic.LobbyManager:getInstance():requestTaskGetAwardData(record.TaskID,function( result )
                if result then
                    local data = result.data
                    local taskType = 0
                    local taskNum = 0
                    if data.bonusScore > 0 then  -- 金币 
                        taskType = ConstantsData.PointType.POINT_COINS
                        taskNum = data.bonusScore
                    elseif data.bonusDiamond > 0 then --钻石
                        taskType = ConstantsData.PointType.POINT_COINS
                        taskNum = data.bonusScore
                    elseif data.bonusRoomCard > 0 then --房卡
                        taskType = ConstantsData.PointType.POINT_COINS
                        taskNum = data.bonusScore
                    end

                    local __params = {{type = taskType, score = taskNum}}
                    GameUtils.showGiftAccount(__params)
                    self:updateScrollView(record)
                    local event = cc.EventCustom:new(config.EventConfig.EVENT_REFRESH_USER_INFO)
                    lib.EventUtils.dispatch(event)
                end
            end)
        end
        })
	record._getBtn:setPosition(size.width/2 - 60, 0)
	record:addChild(record._getBtn)
	record._getBtn:hide()
    local titleGet = ccui.ImageView:create("Lobby_task_title_get.png", ccui.TextureResType.plistType)
    titleGet:setPosition(cc.p(record._getBtn:getContentSize().width/2, record._getBtn:getContentSize().height/2))
    record._getBtn:addChild(titleGet)

    local goBtnImg = "Lobby_task_btn.png"
    record._goBtn = lib.uidisplay.createUIButton({
        normal = goBtnImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            self:onCloseCallback()           
            local event = cc.EventCustom:new(config.EventConfig.EVENT_TASK_GOTO_GAME_SCENE)
            event.userdata = {
                gameId = data.gameId,
                gameType = data.gameType
            }
            lib.EventUtils.dispatch(event)
        end
        })
	record._goBtn:setPosition(size.width/2 - 60, 0)
    record:addChild(record._goBtn)
	record._goBtn:hide()
    local titleGo = ccui.ImageView:create("Lobby_task_title_go.png", ccui.TextureResType.plistType)
    titleGo:setPosition(cc.p(record._goBtn:getContentSize().width/2, record._goBtn:getContentSize().height/2))
    record._goBtn:addChild(titleGo)

	local taskNameText = cc.Label:createWithTTF(data.title,GameUtils.getFontName(),24)
    taskNameText:setAnchorPoint(cc.p(0, 0.5))
    taskNameText:setPosition(-size.width/2 + 130, 0)
    record:addChild(taskNameText)


    print("taskProcessStrtaskProcessStr",taskProcessStr,IsFinish)
    record._processText = cc.Label:createWithTTF(taskProcessStr,GameUtils.getFontName(),24)
    record._processText:setPosition(0-50, 0)
    record:addChild(record._processText)

    local TextBg = ccui.ImageView:create("renwu_xinxikuang.png", ccui.TextureResType.plistType)
    TextBg:setPosition(cc.p(220, 0))
    record:addChild(TextBg)

    local __RichTextList = {{Color3B = cc.c3b(255,255,255), opacity = 255, richText = "奖励:", fontSize = 24},
                        {Color3B = cc.c3b(255,255,0), opacity = 255, richText = taskNum, fontSize = 24},
                    	{Color3B = cc.c3b(255,255,255), opacity = 255, richText = taskName, fontSize = 22}}

	local _richText = GameUtils.createRichText(__RichTextList)
	_richText:setAnchorPoint(cc.p(0, 0.5))
	_richText:setPosition(24,TextBg:getContentSize().height/2)
	TextBg:addChild(_richText)


    -- if data.process  >=  data.Count then -- 完成任务
    --     record._getBtn:show()
    --     record._goBtn:hide()
    --     record._processText:hide()
    -- else
    --     record._getBtn:hide()
    --     record._goBtn:show() 
    --     record._processText:show()     
    -- end

    

    if IsFinish then
        record._getBtn:show()
        record._goBtn:hide()
        record._processText:hide()
    else
        record._getBtn:hide()
        record._goBtn:show() 
        record._processText:show()
    end
 
    return record
end

-- 更新ScrollView
function TaskView:updateScrollView(record)
	local index = 0
	for k, v in ipairs(self._taskData) do
		if v.id == record.id then
			index = k
			table.remove(self._taskData,k) 
			table.remove(self._TaskList,k) 
		end
	end
	GameUtils.removeNode(record)


	local contentSize = cc.size(TASK_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (#self._taskData - 1) * TASK_INTERVAL_V + 36)
	if contentSize.height < TASK_SCROLLVIEW_SIZE.height then
		contentSize = TASK_SCROLLVIEW_SIZE
	end
	self._taskScrollView:setInnerContainerSize(contentSize)

    local offset = cc.p(0, contentSize.height)
    local PosY = 0

	for k, v in ipairs(self._TaskList) do
        local row = k
        local x =40 + offset.x +RECORD_SIZE.width/2
        local y =50 + offset.y - row * TASK_INTERVAL_V -- 第一个点最高
        v:setPosition(x,y)
    end

    if #self._TaskList == 0 then
        self._NoTaskText:show()
    end
end

function TaskView:onEnter( ... )
	TaskView.super.onEnter(self)
end

function TaskView:onExit()

end

return TaskView
