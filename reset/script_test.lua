local test_decl = {}

local function assertEqual(name, want, got)
    if type(want) ~= type(got) then
        error(string.format("type(%s): expected %s, got %s", name, type(want), type(got)))
    end

    if type(want) ~= "table" then
        if want ~= got then
            error(string.format("%s: expected %q, got %q", name, want, got))
        end
        return
    end

    for key in pairs(want) do
        local child = string.format("%s[%q]", name, key)
        assertEqual(child, want[key], got[key])
    end
    for key in pairs(got) do
        local child = string.format("%s[%q]", name, key)
        assertEqual(child, want[key], got[key])
    end
end

function test_decl.testOnTick(t)
    local tt = {
        {
            in_input_bool_tbl = {[1] = false},
            in_btn = false,
            want_async_log = {},
            want_btn = false,
        },
        {
            in_input_bool_tbl = {[1] = true},
            in_btn = false,
            want_async_log = {{52149, "/stop"}},
            want_btn = true,
        },
        {
            in_input_bool_tbl = {[1] = false},
            in_btn = true,
            want_async_log = {},
            want_btn = false,
        },
        {
            in_input_bool_tbl = {[1] = true},
            in_btn = true,
            want_async_log = {},
            want_btn = true,
        },
    }

    for _, tc in ipairs(tt) do
        t:reset()
        t.env.property._number_tbl = {["HTTP Port"] = 52149}
        t.fn()

        t.env.input._bool_tbl = tc.in_input_bool_tbl
        t.env.g_btn = tc.in_btn
        t.env.onTick()

        assertEqual("async._log", tc.want_async_log, t.env.async._log)
        assertEqual("g_btn", tc.want_btn, t.env.g_btn)
    end
end

local function buildMockInput()
    local input = {
        _bool_tbl = {},
    }

    function input.getBool(index)
        return input._bool_tbl[index] or false
    end

    return input
end

local function buildMockProperty()
    local property = {
        _number_tbl = {},
    }

    function property.getNumber(label)
        return property._number_tbl[label] or 0
    end

    return property
end

local function buildMockAsync()
    local async = {
        _log = {},
    }

    function async.httpGet(...)
        table.insert(async._log, {...})
    end

    return async
end

local function buildT()
    local env = {}
    local fn, err = loadfile("script.lua", "t", env)
    if fn == nil then
        error(err)
    end

    local t = {
        env = env,
        fn = fn,
        reset = function(self)
            for k, _ in pairs(self.env) do
                self.env[k] = nil
            end

            self.env.pairs = pairs
            self.env.ipairs = ipairs
            self.env.next = next
            self.env.tostring = tostring
            self.env.tonumber = tonumber
            self.env.type = type
            self.env.math = math
            self.env.table = table
            self.env.string = string

            self.env.input = buildMockInput()
            self.env.property = buildMockProperty()
            self.env.async = buildMockAsync()
        end,
    }
    t:reset()
    return t
end

local function testAll()
    local test_list = {}
    for test_name, test_fn in pairs(test_decl) do
        table.insert(test_list, {test_name, test_fn})
    end
    table.sort(test_list, function(x, y)
        return x[1] < y[1]
    end)

    local function msgh(err)
        return {
            err = err,
            traceback = debug.traceback(),
        }
    end

    local t = buildT()
    local s = "PASS"
    for _, test_entry in ipairs(test_list) do
        local test_name, test_fn = table.unpack(test_entry)

        t:reset()
        local is_success, err = xpcall(test_fn, msgh, t)
        if is_success then
            io.write(string.format("PASS %s\n", test_name))
        else
            io.write(string.format("FAIL %s\n", test_name))
            io.write(string.format("%s\n", err.err))
            io.write(string.format("%s\n", err.traceback))
            s = "FAIL"
        end
    end
    io.write(string.format("%s\n", s))
end

testAll()
