local t = require('luatest')
local g = t.group('helpers')

local helpers = t.helpers

g.test_uuid = function()
    t.assertEquals(helpers.uuid('a'), 'aaaaaaaa-0000-0000-0000-000000000000')
    t.assertEquals(helpers.uuid('ab', 1), 'abababab-0000-0000-0000-000000000001')
    t.assertEquals(helpers.uuid(1, 2, 3), '00000001-0002-0000-0000-000000000003')
    t.assertEquals(helpers.uuid('1', '2', '3'), '11111111-2222-0000-0000-333333333333')
    t.assertEquals(helpers.uuid('12', '34', '56', '78', '90'), '12121212-3434-5656-7878-909090909090')
end

g.test_rescuing = function()
    local retry = 0
    local result = helpers.retrying({}, function(a, b)
        t.assertEquals(a, 1)
        t.assertEquals(b, 2)
        retry = retry + 1
        if (retry < 3) then
            error('test')
        end
        return 'result'
    end, 1, 2)
    t.assertEquals(retry, 3)
    t.assertEquals(result, result)
end

g.test_rescuing_failure = function()
    local retry = 0
    t.assertErrorMsgContains('test-error', function()
        helpers.retrying({delay = 0.1, timeout = 0.5}, function(a, b)
            t.assertEquals(a, 1)
            t.assertEquals(b, 2)
            retry = retry + 1
            error('test-error')
        end, 1, 2)
    end)
    t.assertAlmostEquals(retry, 6, 1)
end
