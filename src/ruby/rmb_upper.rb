#encoding: UTF-8
=begin
中文互联网上迄今为止实现最正确、代码最漂亮且效率最高的大写人民币金额转换代码
Ruby 1.9+ 版本
作者：李维 <oldrev@gmail.com>
版权所有 (c) 2013 李维。保留所有权利。
本代码基于 BSD License 授权。
=end

module RmbConverter

  @@_RMB_DIGITS = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖' ]
  @@_SECTION_CHARS = ['', '拾', '佰', '仟', '万' ]

  def self.to_rmb_upper(price)
    price = price.round(2)
    integer_part = Integer(price)
    wanyi_part = integer_part / 1000000000000
    yi_part = integer_part % 1000000000000 / 100000000
    wan_part = integer_part % 100000000 / 10000
    qian_part = integer_part % 10000
    dec_part = Integer(price * 100 % 100)

    strio = String.new

    zero_count = 0
    #处理万亿以上的部分
    if integer_part >= 1000000000000 and wanyi_part > 0 then
      zero_count = _parse_integer(strio, wanyi_part, zero_count, true)
      strio << '万'
    end

    #处理亿到千亿的部分
    if integer_part >= 100000000 and yi_part > 0 then
      is_first_section = integer_part >= 100000000 and integer_part < 1000000000000 
      zero_count = _parse_integer(strio, yi_part, zero_count, is_first_section)
      strio << '亿'
    end

    #处理万的部分
    if integer_part >= 10000 and wan_part > 0 then
      is_first_section = integer_part >= 1000 and integer_part < 10000000 
      zero_count = _parse_integer(strio, wan_part, zero_count, is_first_section)
      strio << '万'
    end

    #处理千及以后的部分
    if qian_part > 0 then
      is_first_section = integer_part < 1000
      zero_count = _parse_integer(strio, qian_part, zero_count, is_first_section)
    else
      zero_count += 1
    end

    strio << '元' if integer_part > 0

    #处理小数
    if dec_part > 0 then
      _parse_decimal(strio, integer_part, dec_part, zero_count)
    elsif dec_part == 0 and integer_part > 0 then
      strio << '整'
    else
      strio << '零元整'
    end

    strio
  end

  def self._parse_integer(strio, value, zero_count = 0, is_first_section = False)
    raise RuntimeError unless value > 0 and value <= 9999
    ndigits = Integer(Math.log10(value).floor) + 1
    zero_count += 1 if value < 1000 and not is_first_section
    for i in 0...ndigits do
      factor = Integer(10 ** (ndigits - 1 - i))
      digit = Integer(value / factor)
      if digit != 0 then
        strio << '零' if zero_count > 0
        strio << @@_RMB_DIGITS[digit]
        strio << @@_SECTION_CHARS[ndigits - i - 1]
        zero_count = 0
      else
        zero_count += 1
      end
      value -= value / factor * factor
    end
    return zero_count
  end

  def self._parse_decimal(strio, integer_part, value, zero_count)
    raise RuntimeError unless value > 0 and value <= 99
    jiao = value / 10
    fen = value % 10
    strio << '零' if zero_count > 0 and (jiao > 0 or fen > 0) and integer_part > 0
    if jiao > 0 then
      strio << @@_RMB_DIGITS[jiao]
      strio << '角'
    end
    strio << '零' if zero_count == 0 and jiao == 0 and fen > 0 and integer_part > 0
    if fen > 0 then
      strio << @@_RMB_DIGITS[fen]
      strio << '分'
    else
      strio << '整'
    end
  end

end #module

