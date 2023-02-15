local cluster = require('luatest.replica_set')
local server = require('luatest.server')
local t = require('luatest')

local g = t.group()

g.test_cluster_path_with_correct_name = function()
    local c = cluster:new({name = '/my_cluster'})
    local node1 = c:build_and_add_server({alias = 'node1'})
    local node2 = c:build_and_add_server({alias = 'node2'})

    t.assert_str_contains(node1.workdir, server.vardir .. '/my_cluster/node1-')
    t.assert_str_contains(node2.workdir, server.vardir .. '/my_cluster/node2-')
end

g.test_cluster_path_with_name_by_default = function()
    local c = cluster:new({})
    local node1 = c:build_and_add_server({alias = 'node1'})
    local node2 = c:build_and_add_server({alias = 'node2'})

    t.assert_str_contains(c.name, '/rs-')

    t.assert_str_contains(node1.workdir, server.vardir .. c.name .. '/node1-')
    t.assert_str_contains(node2.workdir, server.vardir .. c.name .. '/node2-')
end

local pg = t.group('bad_cluster_name', {
    {name = 'cluster'},
    {name = ''},
    {name = ' '}
})

pg.test_cluster_path_with_bad_name = function(q)
    local function foo()
        cluster:new({name = q.params.name})
    end

    t.assert_error_msg_contains(
        ('replica set "%s" name:'):format(q.params.name), foo)
end

g.test_cluster_path_with_incorrect_slash_position = function()
    local function at_the_end()
        cluster:new({name = 'my_cluster/'})
    end
    local function on_the_middle()
        cluster:new({name = 'my/super/cluster'})
    end

    t.assert_error_msg_contains('my_cluster/', at_the_end)
    t.assert_error_msg_contains('my/super/cluster', on_the_middle)
end
