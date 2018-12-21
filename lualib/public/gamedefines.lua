--import module

SCENE_AOI_DIS = 20

ERRCODE = {
    ok = 0,
    common = 1,
--login
    in_login = 1001,
    in_logout = 1002,
    not_exist_player = 1003,
}

LOGIN_CONNECTION_STATUS = {
    no_account = 1,
    in_login_account = 2,
    login_account = 3,
    in_login_role = 4,
    login_role = 5,
}

SCENE_ENTITY_TYPE = {
    ENTITY_TYPE = 0,
    PLAYER_TYPE = 1,
}

WAR_WARRIOR_TYPE = {
    WARRIOR_TYPE = 0,
    PLAYER_TYPE = 1,
}

WAR_WARRIOR_STATUS = {
    NULL = 0,
    ALIVE = 1,
    DEAD = 2,
}

WAR_BOUT_STATUS = {
    NULL = 0,
    OPERATE = 1,
    ANIMATION = 2,
}

WAR_RECV_DAMAGE_FLAG = {
    NULL = 0,
    MISS = 1,
    DEFENSE = 2,
    CRIT = 3,
}
