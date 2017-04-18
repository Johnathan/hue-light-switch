return function(req, res)

    local response = {}

    if req.body then

        local success, json = pcall(cjson.decode, req.body)
        if not success then
            error(json)
        end

        connectToNetwork(json["ssid"], json["password"])
    end

    res:addheader("Content-Type", "application/json; charset=utf-8")
    res:send(cjson.encode(response))
end