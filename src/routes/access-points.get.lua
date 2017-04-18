return function(req, res)
    res:addheader("Content-Type", "application/json; charset=utf-8")

    wifi.sta.getap(function(ssids)
        local ssid_table = {}
        for ssid in pairs(ssids) do
            table.insert(ssid_table, ssid)
        end

        res:send(cjson.encode({ ssids = ssid_table }))
    end)
end