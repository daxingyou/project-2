-- 牛牛游戏数据
-- @author Tangwen
-- @date 2017.7.31

local RuleTitle = {"底        分:","局        数:","回  合  数:","底        注:","顶        注:","支付方式:"}
local TextColor = cc.c4b(191, 169, 125, 255) --标题颜色
local ValueColor = cc.c4b(255,255,255,255) --数值颜色

local ZhaJinHuaRule = class("ZhaJinHuaRule")

function ZhaJinHuaRule:reset()
	self.GameID = 1   	     	-- 游戏的ID号 唯一标识号
	self.score = 1 --底分
	self.chess = 10 --局数
	self.isAutoNiu = 0 --是否自动算牛
	self.isOpenRightToSeat = 0 --是否开启授权入座
	self.isCostToSeat = 0 --是否开启收费入座
	self.cost = 3 --房卡消耗
	self.roomNum = 5

	self._MAX_FLOOR_SCORE = 10 --最大底分
	self._MAX_CHESS_NUM = 100 --最大局数
end

--算牛方法   游戏底分  授权入座 收费入座
function ZhaJinHuaRule:createRule()
	local rule = ""..self.isAutoNiu..(self.score-1)..self.isOpenRightToSeat..self.isCostToSeat
	return rule
end

function ZhaJinHuaRule:parseRule( __str )
	assert(__str and type(__str) == "string" and  __str ~= "" ,"invalid params")
	local data = {}
	local i = 1
	data.AccountType = tonumber(string.sub(__str,i ,i))
	i = i + 1
	data.GameBet =  tonumber(string.sub(__str,i ,i )) + 1 
	i = i + 1
	data.AuthorizeSit  =  tonumber(string.sub(__str,i ,i))
	i = i + 1
	data.ChargeSit  =  tonumber(string.sub(__str,i ,i))
	return data
end

function ZhaJinHuaRule:isOpen( __value )
	return __value == 1
end

function ZhaJinHuaRule:createRuleLayer()
	self:reset()
	local layer = cc.Layer:create()

	local listView=ccui.ListView:create()
	listView:setPosition(300,170)
	listView:setTouchEnabled(false)--触摸的属性
    listView:setBounceEnabled(false)--弹回的属性
    listView:setInertiaScrollEnabled(false)--滑动的惯性
    listView:setScrollBarEnabled(false)
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setContentSize(1000,380)
	layer:addChild(listView)

	for i=1,#RuleTitle do
		local item = self:createRuleItem(i)
		if item then
			listView:pushBackCustomItem(item)
		end
	end

	return layer
end

function ZhaJinHuaRule:createRuleItem(index)
	local item=ccui.Layout:create()
	local itemSize=cc.size(1000,75)	item:setContentSize(itemSize)

	--底分
	if index == 1 then
		local node = cc.exports.lib.uidisplay.createAddMinusNode({
		imgBg = "imgAddMinus.png",
		callback = handler(self,self._onAddMinsScoreClick),
		imgMinus = "btnMinus.png",
		imgMinusPrssed = "btnMinus.png",
		imgMinusDisabled = "btnMinus.png",
		imgMinusSize = cc.size(53,53),
		imgAdd = "btnAdd.png",
		imgAddPrssed = "btnAdd.png",
		imgAddDisabled = "btnAdd.png",
		imgAddSize = cc.size(53,53),

		textureType = ccui.TextureResType.plistType,
		textSize = 30,
		textColor = cc.c4b(255,255,255,255),
		textFont = GameUtils.getFontName(),
		num = self.score,
		maxNum = self._MAX_FLOOR_SCORE,
		minNum = 1,
		dNum = 1
		})
		item:addChild(node)
		node:setPosition(220,30)
	end
	--局数
	if index == 2 then
		local node = cc.exports.lib.uidisplay.createAddMinusNode({
		imgBg = "imgAddMinus.png",
		callback = handler(self,self._onAddMinsChessClick),
		imgMinus = "btnMinus.png",
		imgMinusPrssed = "btnMinus.png",
		imgMinusDisabled = "btnMinus.png",
		imgMinusSize = cc.size(53,53),
		imgAdd = "btnAdd.png",
		imgAddPrssed = "btnAdd.png",
		imgAddDisabled = "btnAdd.png",
		imgAddSize = cc.size(53,53),
		textureType = ccui.TextureResType.plistType,
		textSize = 30,
		textColor = cc.c4b(255,255,255,255),
		textFont = GameUtils.getFontName(),
		num = self.chess,
		maxNum = self._MAX_CHESS_NUM,
		minNum = 10,
		dNum = 10
		})
		item:addChild(node)
		node:setPosition(220,30)
	end

	local btnRadioBg = "btnRadioBg.png"
	local btnRadioSelected =  "btnRadioSelected.png"
	--自动还是手动算牛
	if index == 3 then
		cc.exports.lib.uidisplay.createRadioGroup({
			groupPos = cc.p(160,30),
			parent = item,
			fileSelect = btnRadioSelected,
			fileUnselect = btnRadioBg,
			num = 2,
			textureType = ccui.TextureResType.plistType,
			poses = {cc.p(160,30),cc.p(380,30)},
			callback = handler(self,self._onCalculateRadioGroupClick)
		})

		local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
														fontSize = 24,
														text = "自动算牛",
														alignment = cc.TEXT_ALIGNMENT_CENTER,
														color = ValueColor,
														pos = cc.p(180,30),
														anchorPoint = cc.p(0,0.5)}
														)
		item:addChild(label)

		local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 24,
															text = "手动算牛",
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = ValueColor,
															pos = cc.p(400,30),
															anchorPoint = cc.p(0,0.5)}
															)
		item:addChild(label)
	end

	if index == 4 then
		local isGrantAuthorizationShow = cc.exports.lobby.CreateRoomManager:getInstance():isGrantAuthorizationShow()
		if isGrantAuthorizationShow then
			cc.exports.lib.uidisplay.createRadioGroup({
				groupPos = cc.p(160,30),
				parent = item,
				fileSelect = btnRadioSelected,
				fileUnselect = btnRadioBg,
				num = 2,
				textureType = ccui.TextureResType.plistType,
				poses = {cc.p(160,30),cc.p(380,30)},
				callback = handler(self,self._onOpenClosedRadioGroupClick)
				})

			local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 24,
															text = "关闭",
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = ValueColor,
															pos = cc.p(180,30),
															anchorPoint = cc.p(0,0.5)}
															)
			item:addChild(label)

			local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
																fontSize = 24,
																text = "开启",
																alignment = cc.TEXT_ALIGNMENT_CENTER,
																color = ValueColor,
																pos = cc.p(400,30),
																anchorPoint = cc.p(0,0.5)}
																)
			item:addChild(label)
		else
			return nil
		end
	end
	
	if index == 5 then
		local isCostSitSelectionShow = cc.exports.lobby.CreateRoomManager:getInstance():isCostSitSelectionShow()
		if isCostSitSelectionShow then
			cc.exports.lib.uidisplay.createRadioGroup({
				groupPos = cc.p(160,30),
				parent = item,
				fileSelect = btnRadioSelected,
				fileUnselect = btnRadioBg,
				num = 2,
				textureType = ccui.TextureResType.plistType,
				poses = {cc.p(160,30),cc.p(380,30)},
				callback = handler(self,self._onYesNoRadioGroupClick)
				})

			local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 24,
															text = "AA支付",
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = ValueColor,
															pos = cc.p(180,30),
															anchorPoint = cc.p(0,0.5)}
															)
			item:addChild(label)

			local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
																fontSize = 24,
																text = "房主支付",
																alignment = cc.TEXT_ALIGNMENT_CENTER,
																color = ValueColor,
																pos = cc.p(400,30),
																anchorPoint = cc.p(0,0.5)}
																)
			item:addChild(label)
		else
			return nil
		end
	end

	local line = ccui.ImageView:create("imgCreateRoomLine.png",ccui.TextureResType.plistType)
	line:setPosition(450,0)
	item:addChild(line)

	local titleLabel = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
														fontSize = 24,
														text = RuleTitle[index],
														alignment = cc.TEXT_ALIGNMENT_CENTER,
														color = TextColor,
														pos = cc.p(0,30),
														anchorPoint = cc.p(0,0.5)}
														)
	item:addChild(titleLabel)

	return item
end

--底分
function ZhaJinHuaRule:_onAddMinsScoreClick( __num,__label)
	self.score = __num
end

--局数
function ZhaJinHuaRule:_onAddMinsChessClick(__num,__label)
	self.chess = __num
	local manager = cc.exports.lobby.CreateRoomManager:getInstance()
	local cardCost = manager:findRoomCardCost(__num)
	self.cost = cardCost
end

--自动还是手动算牛
function ZhaJinHuaRule:_onCalculateRadioGroupClick(__selectRadioButton,__index,_eventType)
	self.isAutoNiu = __index
end

--授权入座
function ZhaJinHuaRule:_onOpenClosedRadioGroupClick(__selectRadioButton,__index,_eventType)
	self.isOpenRightToSeat = __index
end

--支付方式
function ZhaJinHuaRule:_onYesNoRadioGroupClick(__selectRadioButton,__index,_eventType)
	self.isCostToSeat = __index
end

function ZhaJinHuaRule:getCurrRule()
	local data = {}
	data.score = self.score
	data.chess = self.chess
	data.isAutoNiu = self.isAutoNiu
	data.isOpenRightToSeat = self.isOpenRightToSeat
	data.isCostToSeat = self.isCostToSeat
	data.cost = self.cost
	data.roomNum = self.roomNum

	return data
end





cc.exports.lib.singleInstance:bind(ZhaJinHuaRule)

cc.exports.lib.rule.ZhaJinHuaRule = ZhaJinHuaRule

return ZhaJinHuaRule