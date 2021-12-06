
local M = {}

function M.delete_files(params)
    os.execute('rm -fr "/etc/vuci-upload/openvpn/' ..params.path..'"');
end


function M.FileReader (params)
    local file = io.open(params.filename, "r")
    if not file then return "error" end
    lines = {}
    for line in io.lines(params.filename) do 
      lines[#lines + 1] = line
    end
    file:close()
    params.filename = lines
    return params
end

return M