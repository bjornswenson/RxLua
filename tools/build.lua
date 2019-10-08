--- Less horrible :) script to bundle all sources into a single portable Lua file.
-- It uses lua-amalg to scan for `require()`d modules and prepare intermediate output
-- file which is then used to produce final files with metadata in two variants:
-- one for more-or-less standard Lua envs (like LOVE 2D) and separate one for Luvit.
--
-- @usage lua tools/build.lua

local VERSION = os.getenv("RXLUA_VERSION") or "0.0.1"

local MAIN = [[
return require('rx.init')
]]

local HEADER = [[
-- RxLua v]] .. VERSION .. [[ (Portable single-file build)
-- https://github.com/bjornbytes/rxlua
-- MIT License

]]

local LUVIT_METADATA = [[
exports.name = 'bjornbytes/rx'
exports.version = ']] .. VERSION .. [['
exports.description = 'Reactive Extensions for Lua'
exports.license = 'MIT'
exports.author = { url = 'https://github.com/bjornbytes' }
exports.homepage = 'https://github.com/bjornbytes/rxlua'

]]

function withFile(path, opts, doCallback)
  local file = io.open(path, opts)
  assert(file)
  doCallback(file)
  file:close()
end

for _, path in ipairs({
  ".tmp/rxlua-portable-luvit/rx.lua",
  ".tmp/rxlua-portable/rx.lua",
  ".tmp/rxlua-portable-luvit",
  ".tmp/rxlua-portable",
  ".tmp/main.lua",
  ".tmp/out.lua",
  ".tmp",
})
do
  os.remove(path)
end

os.execute("mkdir .tmp .tmp/rxlua-portable-luvit .tmp/rxlua-portable")

withFile(".tmp/main.lua", "w", function (file)
  file:write(MAIN)
end)

assert(os.execute("lua -ltools/amalg .tmp/main.lua") == 0)
assert(os.execute("lua tools/amalg.lua -o .tmp/out.lua -c -s .tmp/main.lua") == 0)

local amalgOut

withFile(".tmp/out.lua", "r", function (file)
  amalgOut = file:read("*a")
end)

withFile(".tmp/rxlua-portable/rx.lua", "w", function (file)
  file:write(table.concat({HEADER, amalgOut}, ""))
end)

withFile(".tmp/rxlua-portable-luvit/rx.lua", "w", function (file)
  file:write(table.concat({HEADER, LUVIT_METADATA, amalgOut}, ""))
end)

os.exit(0)