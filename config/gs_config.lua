root = "./"
config_file = "config/"
thread = 20
logger = nil
harbor = 0
start = "gs_launcher"
cluster_name = "gs"
server_id = 1
proto_file = "cs_common/proto/proto.pb"
proto_define = "cs_common/proto/netdefines.lua"
db_file = config_file.."db.lua"
res_file = "lualib/public/resfile.lua"

-- 决定log输出到哪个文件
APPNAME = "n1_server"
SCENE_SERVICE_COUNT = 5
WAR_SERVICE_COUNT = 5

-- 端口配置
GM_CONSOLE_PORT = 7001
GATEWAY_PORTS = "7011,7012"

-- 是不是正式产品运行环境
PRODUCTION_ENV = false

-----------------程序配置, sa无需理会-------------------
luaservice = root.."service/?.lua;"..root.."service/?/main.lua;"..root.."skynet/service/?.lua;"..root.."skynet/service/?/main.lua"
lua_path = root .. "lualib/?.lua;"..root.."skynet/lualib/?.lua"
lua_cpath = root.."build/clualib/?.so;"
cpath = root .. "build/cservice/?.so"
lualoader = root.."skynet/lualib/loader.lua"
preload = root .. "lualib/base/preload.lua"

----------------程序配置, sa无需理会-------------------
