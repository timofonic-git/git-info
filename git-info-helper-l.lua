#!/usr/bin/env texlua

-- Helper script for git-info

progname = 'git-info-helper-l'
usage = 'Usage: '..arg[0]..' [filename]';
filename = 'git-info.gih'

-- parse arguments
function parse_args() 
    local n = 0
    if arg[1] then
        filename = arg[1]
        n = 1
    end
    if #arg > n then
        print(usage)
        os.exit(1)
    end
end

-- return the lines outputed by 'cmd'
function os.capturelines(cmd)
    local stream = assert(io.popen(cmd, 'r'))
    local lines = {}
    for line in stream:lines() do
        table.insert(lines, line)
    end
    stream:close()
    return lines
end

do -- restrict the scope of the following variables
-- git commands
local git_ls_tree = 'git ls-tree -r --name-only HEAD'
local git_log = "git log -1 --pretty=format:'%H%n%ct%n%ci%n%ce%n%cn%n' "

-- get the list of files and their informations
function read_file_infos()
    local files_infos = {}
    local files = os.capturelines(git_ls_tree)
    for _, file in ipairs(files) do
        local infos = os.capturelines(git_log .. file)
        table.insert(files_infos, {
            name        = file,
            commit      = infos[1],
            timestamp   = infos[2],
            isodate     = infos[3],
            mail        = infos[4],
            author      = infos[5],
        })
    end
    return files_infos
end
end -- scope of git_<command>

-- write the list of files and their informations in 'files' to 'outfile'
function write_file_infos(files, outfile) 
    local out = assert(io.open(outfile, 'w'))
    for _, file in ipairs(files) do
        out:write(
            file.name, '\n',
            file.commit, '\n',
            file.timestamp, '\n',
            file.isodate, '\n',
            file.mail, '\n',
            file.author, '\n\n')
    end
    out:close()
end

-- main
parse_args()
write_file_infos(read_file_infos(), filename)
os.exit(0)
