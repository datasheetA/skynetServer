--import module

SCENE_AOI_DIS = 20

ERRCODE = {
    ok = 0,
    common = 1,
--login
    in_login = 1001,
    in_logout = 1002,
}

BASEOBJ_STATUS = {
    is_alive = 1,
    is_release = 2,
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
