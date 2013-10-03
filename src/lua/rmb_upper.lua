--[[
encoding: UTF-8

-- 中文互联网上迄今为止实现最正确、代码最漂亮且效率最高的大写人民币金额转换代码
-- Lua 5.1+ 版本
-- 作者：李维 <oldrev@gmail.com>
-- 版权所有 (c) 2013 李维。保留所有权利。
-- 本代码基于 BSD License 授权。
--]]

module("rmbupper", package.seeall)

local _RMB_DIGITS = {'零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖' }
local _SECTION_CHARS = {'', '拾', '佰', '仟', '万' }


local function _parse_integer(strio, value, zero_count, is_first_section)
    assert(value > 0 and value <= 9999)
    local ndigits = math.floor(math.log10(value)) + 1
    if value < 1000 and not is_first_section then
        zero_count = zero_count + 1 
    end
    for i = 1, ndigits do
        local factor = math.floor(math.pow(10, (ndigits - i)))
        local digit = math.floor(value / factor)
        if digit > 0 then
            if zero_count > 0 then
                table.insert(strio, '零')
            end
            table.insert(strio, _RMB_DIGITS[digit + 1])
            table.insert(strio, _SECTION_CHARS[ndigits - i + 1])
            zero_count = 0
        else
            zero_count = zero_count + 1
        end
        value = value - math.floor(value / factor) * factor
    end
    return zero_count
end

local function _parse_decimal(strio, integer_part, value, zero_count)
    assert(value > 0 and value <= 99)
    local jiao = math.floor(value / 10)
    local fen = value % 10
    if zero_count > 0 and (jiao > 0 or fen > 0) and integer_part > 0 then
        table.insert(strio, '零')
    end
    if jiao > 0 then
        table.insert(strio, _RMB_DIGITS[jiao + 1])
        table.insert(strio, '角')
    end
    if zero_count == 0 and jiao == 0 and fen > 0 and integer_part > 0 then
        table.insert(strio, '零')
    end
    if fen > 0 then
        table.insert(strio, _RMB_DIGITS[fen + 1])
        table.insert(strio, '分')
    else
        table.insert(strio, '整')
    end
end


function to_rmb_upper(price)
    local integer_part = math.floor(price)
    local wanyi_part = math.floor(integer_part / 1000000000000)
    local yi_part = math.floor(integer_part % 1000000000000 / 100000000)
    local wan_part = math.floor(integer_part % 100000000 / 10000)
    local qian_part = integer_part % 10000
    local dec_part = math.floor(price * 100 % 100)

    local strio = {}

    local zero_count = 0
    --处理万亿以上的部分
    if integer_part >= 1000000000000 and wanyi_part > 0 then
        zero_count = _parse_integer(strio, wanyi_part, zero_count, true)
        table.insert(strio, '万')
    end

    --处理亿到千亿的部分
    if integer_part >= 100000000 and yi_part > 0 then
        local is_first_section = integer_part >= 100000000 and integer_part < 1000000000000 
        zero_count = _parse_integer(strio, yi_part, zero_count, is_first_section)
        table.insert(strio, '亿')
    end

    --处理万的部分
    if integer_part >= 10000 and wan_part > 0 then
        local is_first_section = integer_part >= 1000 and integer_part < 10000000 
        zero_count = _parse_integer(strio, wan_part, zero_count, is_first_section)
        table.insert(strio, '万')
    end

    --处理千及以后的部分
    if qian_part > 0 then
        local is_first_section = integer_part < 1000
        zero_count = _parse_integer(strio, qian_part, zero_count, is_first_section)
    else
        zero_count = zero_count + 1
    end

    if integer_part > 0 then
        table.insert(strio, '元')
    end

    --处理小数
    if dec_part > 0 then
        _parse_decimal(strio, integer_part, dec_part, zero_count)
    elseif dec_part == 0 and integer_part > 0 then
        table.insert(strio, '整')
    else
        table.insert(strio, '零元整')
    end

    return table.concat(strio, "")
end
