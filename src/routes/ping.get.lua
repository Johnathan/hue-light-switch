return function(req, res)
    local response = { device = 'Light Switch' }
    res:addheader("Content-Type", "application/json; charset=utf-8")
    res:send(cjson.encode(response))
end