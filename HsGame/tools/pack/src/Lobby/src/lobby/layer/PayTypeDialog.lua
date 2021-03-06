--[[
    名称  :   PayTypeDialog  支付类型弹窗
    作者  :   Xiaxb   
    描述  :   PayTypeDialog 	支付类型弹窗
    时间  :   2017-8-07
--]]


-- 支付类型弹窗
local PayTypeDialog = class("PayTypeDialog", lib.layer.Window)

-- 支付按钮配置
local btnPayIcon= {}

-- 支付按钮配置
btnPayIcon[1] = {}
btnPayIcon[1]["Pos_X"] = 0.26
btnPayIcon[1]["Pos_Y"] = 0.65
btnPayIcon[1]["payment"] = ""

-- 支付按钮配置
btnPayIcon[2] = {}
btnPayIcon[2]["Pos_X"] = 0.74
btnPayIcon[2]["Pos_Y"] = 0.65
btnPayIcon[2]["payment"] = ""

-- 支付按钮配置
btnPayIcon[3] = {}
btnPayIcon[3]["Pos_X"] = 0.26
btnPayIcon[3]["Pos_Y"] = 0.3
btnPayIcon[3]["payment"] = ""

-- 支付按钮配置
btnPayIcon[4] = {}
btnPayIcon[4]["Pos_X"] = 0.74
btnPayIcon[4]["Pos_Y"] = 0.3
btnPayIcon[4]["payment"] = ""

function PayTypeDialog:ctor(mallData)
	print("PayTypeDialog:ctor")
	PayTypeDialog.super.ctor(self, lib.layer.Window.MIDDLE)
	self:_initView(mallData)
end

-- 初始化试图视图
function PayTypeDialog:_initView(mallData)
	-- 弹窗背景
	local dialogBg = self._root
	-- dialogBg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
	-- self:addChild(dialogBg)
	-- self:_onRootPanelInit(dialogBg)

	-- local dialogTitle = ccui.ImageView:create("TP/Mall/mall_title_pay_type.png", ccui.TextureResType.plistType)
	-- dialogTitle:setPosition(cc.p(dialogBg:getContentSize().width/2, dialogBg:getContentSize().height - dialogTitle:getContentSize().height/2 + 10))
	-- dialogBg:addChild(dialogTitle)

	local titleBg = ccui.ImageView:create("res/common/common_title_bg.png")
    titleBg:setPosition(cc.p(dialogBg:getContentSize().width/2, dialogBg:getContentSize().height - titleBg:getContentSize().height/2 + 10))
    dialogBg:addChild(titleBg)

    local title = cc.Label:createWithTTF("支付方式",GameUtils.getFontName(), 36)
    title:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2+3)
    title:setTextColor(cc.c3b(141,62,30))
    title:enableOutline(cc.c3b(255, 250, 152),2)
    titleBg:addChild(title)

	-- local dialogClose = ccui.Button:create("res/common/common_btn_close.png")
	-- dialogClose:setPosition(cc.p(dialogBg:getContentSize().width - dialogClose:getContentSize().width/2 - 10, dialogBg:getContentSize().height - dialogClose:getContentSize().height/2 + 5 ))
	-- dialogBg:addChild(dialogClose)

	-- local function callback_Close(sender)
	-- 	self:onCloseCallback()
	-- end

	-- dialogClose:addClickEventListener(callback_Close)

	-- 切换登陆点击事件
	local function callback_buy(sender)
		self:removeFromParent()
		mallData.curPayment = btnPayIcon[sender:getTag()]["payment"]
		Mall.MallManager:getInstance():buyGoods(mallData)
	end

	local paymentList = GameUtils.split(mallData.payment, "|") 

	for i=1,#paymentList do
		local btnNormallBg = "TP/Mall/mall_btn_bg_normall.png"
		local btnSelectBg = "TP/Mall/mall_btn_bg_select.png"

		local btnbg = ccui.Button:create(btnNormallBg, btnSelectBg, "", ccui.TextureResType.plistType)
		btnbg:setPosition(cc.p(dialogBg:getContentSize().width*btnPayIcon[i]["Pos_X"], dialogBg:getContentSize().height*btnPayIcon[i]["Pos_Y"]))
		dialogBg:addChild(btnbg)

		print("xiaxb----pay:", paymentList[i])

		local payType = ""

		if "alipay" == paymentList[i] then
			payType = "zfb"
		elseif "union" == paymentList[i] then
			payType = "un"
		else
			payType = paymentList[i]
		end

		local btnIcon = ccui.ImageView:create(string.format("TP/Mall/mall_btn_%s.png", payType), ccui.TextureResType.plistType)
		btnIcon:setPosition(cc.p(btnbg:getContentSize().width/2, btnbg:getContentSize().height/2))
		btnbg:addChild(btnIcon)

		btnbg:setTag(i)
		btnPayIcon[i]["payment"] = paymentList[i]
		btnbg:addClickEventListener(callback_buy)
	end
end

return PayTypeDialog