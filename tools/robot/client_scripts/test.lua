
client.server_request_handlers = {
    ["GS2CHello"] = function(self, args)
        client:run_cmd("C2GSLoginAccount", {account = "lin"})
    end,

    ["GS2CLoginAccount"] = function(self, args)
        client:run_cmd("C2GSLoginRole", {account = args.account, pid = 123})
    end,
}
