--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"
local res = require "base.res"

local gamedefines = import(lualib_path("public.gamedefines"))
local playernet = import(service_path("netcmd/player"))
local playerctrl = import(service_path("playerctrl.init"))


function NewPlayer(...)
    local o = CPlayer:New(...)
    return o
end


PropHelperFunc = {}
PropHelperDef = {}

PropHelperDef.grade = 2
function PropHelperFunc.grade(oPlayer)
    return oPlayer:GetGrade()
end

PropHelperDef.name = 3
function PropHelperFunc.name(oPlayer)
    return oPlayer:GetName()
end

PropHelperDef.title_list = 4
function PropHelperFunc.title_list(oPlayer)
    return {}
end

PropHelperDef.goldcoin = 5
function PropHelperFunc.goldcoin(oPlayer)
    return 0
end

PropHelperDef.gold = 6
function PropHelperFunc.gold(oPlayer)
    return oPlayer.m_oActiveCtrl:GetData("gold")
end

PropHelperDef.silver = 7
function PropHelperFunc.silver(oPlayer)
    return oPlayer.m_oActiveCtrl:GetData("silver")
end

PropHelperDef.exp = 8
function PropHelperFunc.exp(oPlayer)
    return oPlayer.m_oActiveCtrl:GetData("exp")
end

PropHelperDef.chubei_exp = 9
function PropHelperFunc.chubei_exp(oPlayer)
    return oPlayer.m_oActiveCtrl:GetData("chubei_exp")
end

PropHelperDef.max_hp = 10
function PropHelperFunc.max_hp(oPlayer)
    return oPlayer:GetMaxHp()
end

PropHelperDef.max_mp = 11
function PropHelperFunc.max_mp(oPlayer)
    return oPlayer:GetMaxMp()
end

PropHelperDef.hp = 12
function PropHelperFunc.hp(oPlayer)
    return oPlayer:GetHp()
end

PropHelperDef.mp = 13
function PropHelperFunc.mp(oPlayer)
    return oPlayer:GetMp()
end

PropHelperDef.enegy = 14
function PropHelperFunc.enegy(oPlayer)
    return oPlayer.m_oActiveCtrl:GetData("enegy")
end

PropHelperDef.physique = 15
function PropHelperFunc.physique(oPlayer)
    return oPlayer.m_oBaseCtrl:GetData("physique")
end

PropHelperDef.strength = 16
function PropHelperFunc.strength(oPlayer)
    return oPlayer.m_oBaseCtrl:GetData("strength")
end

PropHelperDef.magic = 17
function PropHelperFunc.magic(oPlayer)
    return oPlayer.m_oBaseCtrl:GetData("magic")
end

PropHelperDef.endurance = 18
function PropHelperFunc.endurance(oPlayer)
    return oPlayer.m_oBaseCtrl:GetData("endurance")
end

PropHelperDef.agility = 19
function PropHelperFunc.agility(oPlayer)
    return oPlayer.m_oBaseCtrl:GetData("agility")
end


CPlayer = {}
CPlayer.__index = CPlayer
inherit(CPlayer, logic_base_cls())

function CPlayer:New(mConn, mRole)
    local o = super(CPlayer).New(self)

    o.m_iNetHandle = mConn.handle
    o.m_iPid = mRole.pid
    o.m_sAccount = mRole.account
    o.m_iDisconnectedTime = nil
    o.m_fHeartBeatTime = get_time()

    o.m_oBaseCtrl = playerctrl.NewBaseCtrl(o.m_iPid)
    o.m_oActiveCtrl = playerctrl.NewActiveCtrl(o.m_iPid)
    o.m_oItemCtrl = playerctrl.NewItemCtrl(o.m_iPid)
    o.m_oThisTemp = playerctrl.NewThisTempCtrl(o.m_iPid)
    o.m_oToday = playerctrl.NewTodayCtrl(o.m_iPid)
    o.m_oThisWeek = playerctrl.NewWeekCtrl(o.m_iPid)
    o.m_oSeveralDay = playerctrl.NewSeveralDayCtrl(o.m_iPid)
    o.m_oTimeCtrl = playerctrl.NewTimeCtrl(o.m_iPid,{
         ["Today"] = o.m_oToday,
        ["Week"] = o.m_oThisWeek,
        ["ThisTemp"] = o.m_oThisTemp,
        ["SeveralDay"] = o.m_oSeveralDay,
        })
    return o
end

function CPlayer:Release()
    self.m_oBaseCtrl:Release()
    self.m_oActiveCtrl:Release()
    super(CPlayer).Release(self)
end

function CPlayer:PackWarInfo()
    local mRet = {}
    mRet.hp = self:GetHp()
    mRet.mp = self:GetMp()
    mRet.max_hp = self:GetMaxHp()
    mRet.max_mp = self:GetMaxMp()
    mRet.model_info = self:GetModelInfo()
    return mRet
end

function CPlayer:PackSceneInfo()
    local mRet = {}
    mRet.name = self:GetName()
    mRet.model_info = self:GetModelInfo()
    return mRet
end

function CPlayer:SyncSceneInfo(m)
    local oNowScene = self.m_oActiveCtrl:GetNowScene()
    if oNowScene then
        oNowScene:SyncPlayerInfo(self, m)
    end
end

function CPlayer:GetAccount()
    return self.m_sAccount
end

function CPlayer:GetPid()
    return self.m_iPid
end

function CPlayer:GetConn()
    local oWorldMgr = global.oWorldMgr
    return oWorldMgr:GetConnection(self.m_iNetHandle)
end

function CPlayer:SetNetHandle(iNetHandle)
    self.m_iNetHandle = iNetHandle
    if iNetHandle then
        self.m_iDisconnectedTime = nil
    else
        self.m_iDisconnectedTime = get_msecond()
        self:OnDisconnected()
    end
end

function CPlayer:Send(sMessage, mData)
    local oConn = self:GetConn()
    if oConn then
        oConn:Send(sMessage, mData)
    end
end

function CPlayer:MailAddr()
    local oConn = self:GetConn()
    if oConn then
        return oConn:MailAddr()
    end
end

function CPlayer:OnLogout()
    local oWarMgr = global.oWarMgr
    oWarMgr:OnLogout(self)
    local oSceneMgr = global.oSceneMgr
    oSceneMgr:OnLogout(self)
    --disconnect
    local oWorldMgr = global.oWorldMgr
    local oConn = self:GetConn()
    if oConn then
        oWorldMgr:KickConnection(oConn.m_iHandle)
    end
    --save db
    self:SaveDb()
end

function CPlayer:OnLogin(bReEnter)
    local oWorldMgr = global.oWorldMgr

    if not bReEnter then
        self:PreCheck()
    end

    oWorldMgr:LoadRW(self.m_iPid,function (oRW)
        self.m_oBaseCtrl:SetData("goldcoin",oRW:GoldCoin())
        self:GS2CLoginRole()
    end)
    self.m_fHeartBeatTime = get_time()

    local oWar = self.m_oActiveCtrl:GetNowWar()
    if oWar then
        local oWarMgr = global.oWarMgr
        oWarMgr:OnLogin(self, bReEnter)
    else
        local oSceneMgr = global.oSceneMgr
        oSceneMgr:OnLogin(self, bReEnter)
    end
    
    self.m_oItemCtrl:OnLogin()

    if not bReEnter then
        self:Schedule()
    end
    local mArgs = {
        sName = self.m_oBaseCtrl:GetData("name"),
        iGrade = self.m_oBaseCtrl:GetData("grade")
    }
    local oWorldMgr = global.oWorldMgr
    oWorldMgr:LoadRO(self.m_iPid,function (oRO)
        oRO:OnLogin(mArgs)
    end)
    oWorldMgr:LoadRW(self.m_iPid,function(oRW)
        oRW:OnLogin()
    end)
end

function CPlayer:OnDisconnected()
    local oWarMgr = global.oWarMgr
    oWarMgr:OnDisconnected(self)
    local oSceneMgr = global.oSceneMgr
    oSceneMgr:OnDisconnected(self)
end

function CPlayer:PreCheck()
    if not self.m_oBaseCtrl:GetData("model_info") then
        local mModelInfo = {
            shape = 0,
            scale = 0,
            color = {0,},
            mutate_texture = 0,
            weapon = 0,
            adorn = 0,
        }
        self.m_oBaseCtrl:SetData("model_info", mModelInfo)
    end

    if not self.m_oActiveCtrl:GetData("scene_info") then
        local mSceneInfo = {
            map_id = 10001,
            pos = {
                x = 100,
                y = 100,
                z = 0,
                face_x = 0,
                face_y = 0,
                face_z = 0,
            },
        }
        self.m_oActiveCtrl:SetData("scene_info", mSceneInfo)
    end

    if not self.m_oActiveCtrl:GetData("hp") or self.m_oActiveCtrl:GetData("hp") > self:GetMaxHp() then
        self.m_oActiveCtrl:SetData("hp", self:GetMaxHp())
    end
    if not self.m_oActiveCtrl:GetData("mp") or self.m_oActiveCtrl:GetData("mp") > self:GetMaxMp() then
        self.m_oActiveCtrl:SetData("mp", self:GetMaxMp())
    end
    if not self.m_oActiveCtrl:GetData("sp") or self.m_oActiveCtrl:GetData("sp") > self:GetMaxSp() then
        self.m_oActiveCtrl:SetData("sp", self:GetMaxSp())
    end
end

function CPlayer:Schedule()
    local f1
    f1 = function ()
        self:DelTimeCb("_CheckSaveDb")
        self:AddTimeCb("_CheckSaveDb", 5*60*1000, f1)
        self:_CheckSaveDb()
    end
    f1()

    local f2
    f2 = function ()
        self:DelTimeCb("_CheckHeartBeat")
        self:AddTimeCb("_CheckHeartBeat", 10*1000, f2)
        self:_CheckHeartBeat()
    end
    f2()
end

function CPlayer:SaveDb()
    if self.m_oBaseCtrl:IsDirty() then
        local mData = self.m_oBaseCtrl:Save()
        interactive.Send(".gamedb", "playerdb", "SavePlayerBase", {pid = self:GetPid(), data = mData})
        self.m_oBaseCtrl:UnDirty()
    end
    if self.m_oActiveCtrl:IsDirty() then
        local mData = self.m_oActiveCtrl:Save()
        interactive.Send(".gamedb", "playerdb", "SavePlayerActive", {pid = self:GetPid(), data = mData})
        self.m_oActiveCtrl:UnDirty()
    end
    if self.m_oItemCtrl:IsDirty() then
        local mData = self.m_oItemCtrl:Save()
        interactive.Send(".gamedb","playerdb","SavePlayerItem",{pid=self:GetPid(),data=mData})
        self.m_oItemCtrl:UnDirty()
    end
   
    if self.m_oTimeCtrl:IsDirty() then
        local mData = self.m_oTimeCtrl:Save()
        interactive.Send(".gamedb","playerdb","SavePlayerTimeInfo",{pid=self:GetPid(),data=mData})
        self.m_oTimeCtrl:UnDirty()
    end
end

function CPlayer:ClientHeartBeat()
    self.m_fHeartBeatTime = get_time()
    self:Send("GS2CHeartBeat", {time = math.floor(self.m_fHeartBeatTime)})
end

function CPlayer:_CheckSaveDb()
    assert(not self:IsRelease(), "_CheckSaveDb fail")
    self:SaveDb()
end

function CPlayer:_CheckHeartBeat()
    assert(not self:IsRelease(), "_CheckHeartBeat fail")
    local fTime = get_time()
    if fTime - self.m_fHeartBeatTime >= 3*60 then
        local oWorldMgr = global.oWorldMgr
        oWorldMgr:Logout(self:GetPid())
    end
end

--道具相关
function CPlayer:RewardItem(itemobj,sReason,iKey,mArgs)
    if itemobj:SID() < 10000 then
        local oRealObj = itemobj:RealObj()
        if oRealObj then
            --
        else
            itemobj:Reward(self)
            return
        end
    end
    local retobj = self.m_oItemCtrl:AddItem(itemobj,sReason)
    --添加失败，放入邮件，功能稍后增加
    if retobj then
        return
    end
end

function CPlayer:GiveItem(ItemList,sReason)
    self.m_oItemCtrl:GiveItem(ItemList)
end

--ItemList:{sid:amount}
function CPlayer:ValidGive(ItemList)
    local bSuc = self.m_oItemCtrl:ValidGive(ItemList)
    return bSuc
end

function CPlayer:RemoveItemAmount(sid,iAmount)
    local bSuc = self.m_oItemCtrl:RemoveItemAmount(sid,iAmount)
    return bSuc
end

function CPlayer:GetItemAmount(sid)
    local iAmount = self.m_oItemCtrl:GetItemAmount(sid)
    return iAmount
end

function CPlayer:RewardGold(iVal,sReason,mArgs)
    self.m_oActiveCtrl:RewardGold(iVal,sReason,mArgs)
end

function CPlayer:RewardSilver(iVal,sReason,mArgs)
    self.m_oActiveCtrl:RewardSilver(iVal,sReason,mArgs)
end

function CPlayer:RewardExp(iVal,sReason,mArgs)
    self.m_oActiveCtrl:RewardExp(iVal,sReason,mArgs)
end

function CPlayer:AddChubeiExp(iVal, sReason)
    sReason = sReason or ""
    self.m_oActiveCtrl:AddChubeiExp(iVal, sReason)
end

function CPlayer:GetGrade()
    return self.m_oBaseCtrl:GetData("grade")
end

function CPlayer:GetName()
    return self.m_oBaseCtrl:GetData("name")
end

function CPlayer:GetModelInfo()
    local m = self.m_oBaseCtrl:GetData("model_info")
    local mRet = {}
    mRet.shape = m.shape
    mRet.scale = m.scale
    mRet.color = m.color
    mRet.mutate_texture = m.mutate_texture
    mRet.weapon = m.weapon
    mRet.adorn = m.adorn
    return mRet
end

function CPlayer:GetMaxHp()
    local m = res["daobiao"]["point"]
    local iRet = 0
    for k, v in pairs(m) do
        local i = self.m_oBaseCtrl:GetData(v.macro) * v.hp_max_add
        if i then
            iRet = iRet + i
        end
    end
    return iRet
end

function CPlayer:GetMaxMp()
    local m = res["daobiao"]["point"]
    local iRet = 0
    for k, v in pairs(m) do
        local i = self.m_oBaseCtrl:GetData(v.macro) * v.mp_max_add
        if i then
            iRet = iRet + i
        end
    end
    return iRet
end

function CPlayer:GetHp()
    return self.m_oActiveCtrl:GetData("hp")
end

function CPlayer:GetMp()
    return self.m_oActiveCtrl:GetData("mp")
end

function CPlayer:GetMaxSp()
    return 100
end

function CPlayer:GetSp()
    return self.m_oActiveCtrl:GetData("sp")
end

function CPlayer:GetSpeed()
    local m = res["daobiao"]["point"]
    local iRet = 0
    for k, v in pairs(m) do
        local i = self.m_oBaseCtrl:GetData(v.macro) * v.speed_add
        if i then
            iRet = iRet + i
        end
    end
    return iRet
end

function CPlayer:GetCurePower()
    return 100
end

function CPlayer:GetMagDefense()
    local m = res["daobiao"]["point"]
    local iRet = 0
    for k, v in pairs(m) do
        local i = self.m_oBaseCtrl:GetData(v.macro) * v.mag_defense_add
        if i then
            iRet = iRet + i
        end
    end
    return iRet
end

function CPlayer:GetPhyDefense()
    local m = res["daobiao"]["point"]
    local iRet = 0
    for k, v in pairs(m) do
        local i = self.m_oBaseCtrl:GetData(v.macro) * v.phy_defense_add
        if i then
            iRet = iRet + i
        end
    end
    return iRet
end

function CPlayer:GetMagAttack()
    local m = res["daobiao"]["point"]
    local iRet = 0
    for k, v in pairs(m) do
        local i = self.m_oBaseCtrl:GetData(v.macro) * v.mag_attack_add
        if i then
            iRet = iRet + i
        end
    end
    return iRet
end

function CPlayer:GetPhyAttack()
    local m = res["daobiao"]["point"]
    local iRet = 0
    for k, v in pairs(m) do
        local i = self.m_oBaseCtrl:GetData(v.macro) * v.phy_attack_add
        if i then
            iRet = iRet + i
        end
    end
    return iRet
end

function CPlayer:GetPhyCriticalRatio()
    return self.m_oBaseCtrl:GetData("phy_critical_ratio")
end

function CPlayer:GetPhyResCriticalRatio()
    return self.m_oBaseCtrl:GetData("phy_res_critical_ratio")
end

function CPlayer:GetMagCriticalRatio()
    return self.m_oBaseCtrl:GetData("mag_critical_ratio")
end

function CPlayer:GetMagResCriticalRatio()
    return self.m_oBaseCtrl:GetData("mag_res_critical_ratio")
end

function CPlayer:GetSealRatio()
    return self.m_oBaseCtrl:GetData("seal_ratio")
end

function CPlayer:GetSealResRatio()
    return self.m_oBaseCtrl:GetData("seal_res_ratio")
end

function CPlayer:GetHitRatio()
    return self.m_oBaseCtrl:GetData("hit_ratio")
end

function CPlayer:GetHitResRatio()
    return self.m_oBaseCtrl:GetData("hit_res_ratio")
end

function CPlayer:GS2CLoginRole()
    local mNet = {
        account = self:GetAccount(),
        pid = self:GetPid(),
        role = self:RoleInfo(),
    }
    self:Send("GS2CLoginRole", mNet)
end

function CPlayer:RoleInfo(m)
    local mRet = {}
    if not m then
        m = PropHelperDef
    end
    local iMask = 0
    for k, _ in pairs(m) do
        local i = assert(PropHelperDef[k], string.format("RoleInfo fail i get %s", k))
        local f = assert(PropHelperFunc[k], string.format("RoleInfo fail f get %s", k))
        mRet[k] = f(self)
        iMask = iMask | (2^(i-1))
    end
    mRet.mask = iMask
    return mRet
end

function CPlayer:PropChange(...)
    local l = table.pack(...)
    local m = {}
    for _, v in ipairs(l) do
        m[v] = true
    end
    local mRole = self:RoleInfo(m)
    self:Send("GS2CPropChange", {
        role = mRole,
    })
end
