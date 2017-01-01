function save_setting(name, value)
  file.open(name, 'w') -- you don't need to do file.remove if you use the 'w' method of writing
  file.writeline(value)
  file.close()
end

function read_setting(name)
  if (file.open(name)~=nil) then
      result = string.sub(file.readline(), 1, -2) -- to remove newline character
      file.close()
      return true, result
  else
      return false, nil
  end
end

function remove_setting(name)
  if (file.exists(name)) then
      file.remove(name)
      return true
  end
end
