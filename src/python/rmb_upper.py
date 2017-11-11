#encoding: utf-8
'''
中文互联网上迄今为止实现最正确、代码最漂亮且效率最高的大写人民币金额转换代码
作者：李维 <oldrev@gmail.com>
版权所有 (c) 2013 李维。保留所有权利。
本代码基于 BSD License 授权。
'''

from io import StringIO
import math

_RMB_DIGITS = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖' ]
_SECTION_CHARS = ['', '拾', '佰', '仟', '万' ]

def to_rmb_upper(price):
    price = round(price, 2)
    integer_part = int(price)
    wanyi_part = integer_part / 1000000000000
    yi_part = integer_part % 1000000000000 / 100000000
    wan_part = integer_part % 100000000 / 10000
    qian_part = integer_part % 10000
    dec_part = int(price * 100 % 100)

    strio = StringIO()

    zero_count = 0
    #处理万亿以上的部分
    if integer_part >= 1000000000000 and wanyi_part > 0:
        zero_count = _parse_integer(strio, wanyi_part, zero_count, True)
        strio.write('万')

    #处理亿到千亿的部分
    if integer_part >= 100000000 and yi_part > 0:
        is_first_section = integer_part >= 100000000 and integer_part < 1000000000000 
        zero_count = _parse_integer(strio, yi_part, zero_count, is_first_section)
        strio.write('亿')

    #处理万的部分
    if integer_part >= 10000 and wan_part > 0:
        is_first_section = integer_part >= 1000 and integer_part < 10000000 
        zero_count = _parse_integer(strio, wan_part, zero_count, is_first_section)
        strio.write('万')

    #处理千及以后的部分
    if qian_part > 0:
        is_first_section = integer_part < 1000
        zero_count = _parse_integer(strio, qian_part, zero_count, is_first_section)
    else:
        zero_count += 1
    if integer_part > 0:
        strio.write('元')

    #处理小数
    if dec_part > 0: 
        _parse_decimal(strio, integer_part, dec_part, zero_count)
    elif dec_part == 0 and integer_part > 0:
        strio.write('整')
    else:
        strio.write('零元整')

    return strio.getvalue()

def _parse_integer(strio, value, zero_count = 0, is_first_section = False):
    assert value > 0 and value <= 9999
    ndigits = int(math.floor(math.log10(value))) + 1
    if value < 1000 and not is_first_section:
        zero_count += 1
    for i in range(0, ndigits):
        factor = int(pow(10, ndigits - 1 - i))
        digit = int(value / factor)
        if digit != 0:
            if zero_count > 0:
                strio.write('零')
            strio.write(_RMB_DIGITS[digit])
            strio.write(_SECTION_CHARS[ndigits - i - 1])
            zero_count = 0
        else:
            zero_count += 1
        value -= value / factor * factor
    return zero_count

def _parse_decimal(strio, integer_part, value, zero_count):
    assert value > 0 and value <= 99
    jiao = value / 10
    fen = value % 10
    if zero_count > 0 and (jiao > 0 or fen > 0) and integer_part > 0:
        strio.write('零')
    if jiao > 0:
        strio.write(_RMB_DIGITS[jiao])
        strio.write('角')
    if zero_count == 0 and jiao == 0 and fen > 0 and integer_part > 0:
        strio.write('零')
    if fen > 0:
        strio.write(_RMB_DIGITS[fen])
        strio.write('分')
    else:
        strio.write('整')

