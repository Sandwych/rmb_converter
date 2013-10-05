/*
中文互联网上迄今为止实现最正确、代码最漂亮且效率最高的大写人民币金额转换代码
Mozilla Rust 0.8 版本（写的好痛苦）
作者：李维 <oldrev@gmail.com>
版权所有 (c) 2013 李维。保留所有权利。
本代码基于 BSD License 授权。
*/

mod rmb_converter {

    use std::cmath::c_double_utils;

    struct StringBuffer {
        s: ~str
    }

    impl StringBuffer {
        pub fn append(&mut self, v: &str) {
            self.s.push_str(v);
        }

        fn to_str(&mut self) -> ~str {
            return self.s.clone();
        }
    }

    static _RMB_DIGITS: &'static[&'static str] = &["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" ];
    static _SECTION_CHARS: &'static[&'static str] = &["", "拾", "佰", "仟", "万" ];

    pub fn to_rmb_upper(price: f64) -> ~str {

        let integer_part = price as i64;
        let wanyi_part = (integer_part / 1000000000000) as int;
        let yi_part = (integer_part % 1000000000000 / 100000000) as int;
        let wan_part = (integer_part % 100000000 / 10000) as int;
        let qian_part = (integer_part % 10000) as int;
        let dec_part = (price * 100.0 % 100.0) as int;

        let mut strio = StringBuffer {s: ~""};

        let mut zero_count = 0;
        //处理万亿以上的部分
        if integer_part >= 1000000000000 && wanyi_part > 0 {
            zero_count = _parse_integer(&mut strio, wanyi_part, zero_count, true);
            strio.append("万");
        }

        //处理亿到千亿的部分
        if integer_part >= 100000000 && yi_part > 0 {
            let is_first_section = integer_part >= 100000000 && integer_part < 1000000000000 ;
            zero_count = _parse_integer(&mut strio, yi_part, zero_count, is_first_section);
            strio.append("亿");
        }

        //处理万的部分
        if integer_part >= 10000 && wan_part > 0 {
            let is_first_section = integer_part >= 1000 && integer_part < 10000000 ;
            zero_count = _parse_integer(&mut strio, wan_part, zero_count, is_first_section);
            strio.append("万");
        }

        //处理千及以后的部分
        if qian_part > 0 {
            let is_first_section = integer_part < 1000;
            zero_count = _parse_integer(&mut strio, qian_part, zero_count, is_first_section);
        } else {
            zero_count += zero_count;
        }

        if integer_part > 0 {
            strio.append("元");
        }

        //#处理小数
        if dec_part > 0 {
            _parse_decimal(&mut strio, integer_part, dec_part, zero_count);
        } else if  dec_part == 0 && integer_part > 0 {
            strio.append("整");
        } else{
            strio.append("零元整");
        }

        return strio.to_str();
    }

    #[fixed_stack_segment]
    fn _parse_integer(strio: &mut StringBuffer, value: int, zero_count: int, is_first_section: bool) -> int {
        assert!(value > 0 && value <= 9999);
        let ndigits = unsafe { c_double_utils::log10(value as f64) as int + 1 };
        let mut my_zero_count = zero_count;
        if(value < 1000 && !is_first_section) {
            my_zero_count += 1;
        }
        let mut my_value = value;
        for i in range(0, ndigits) {
            let factor = unsafe { c_double_utils::pow(10.0, (ndigits - 1 - i) as f64) as int };
            let digit = (my_value / factor) as int;
            if digit != 0 {
                if my_zero_count > 0 {
                    strio.append("零");
                }
                strio.append(_RMB_DIGITS[digit]);
                strio.append(_SECTION_CHARS[ndigits - i - 1]);
                my_zero_count = 0;
            }
            else{
                my_zero_count += 1;
            }
            my_value -= my_value / factor * factor;
        }
        return zero_count
    }

    fn _parse_decimal(strio: &mut StringBuffer, integer_part: i64, value: int, zero_count: int) {
        assert!(value > 0 && value <= 99);
        let jiao = value / 10;
        let fen = value % 10;
        if zero_count > 0 && (jiao > 0 || fen > 0) && integer_part > 0 {
            strio.append("零");
        }
        if jiao > 0 {
            strio.append(_RMB_DIGITS[jiao]);
            strio.append("角");
        }
        if zero_count == 0 && jiao == 0 && fen > 0 && integer_part > 0 {
            strio.append("零");
        }
        if fen > 0 {
            strio.append(_RMB_DIGITS[fen]);
            strio.append("分");
        } else{ 
            strio.append("整");
        }
    }

}
