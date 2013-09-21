/** 中文互联网上迄今为止实现最正确、代码最漂亮且效率最高的大写人民币金额转换代码 
 * C++ 版本
 * 作者：李维 <oldrev@gmail.com>
 * 版权所有 (c) 2013 昆明维智众源企业管理咨询有限公司。保留所有权利。
 * 本代码基于 BSD License 授权。
 * */

#include <iostream>
#include <string>
#include <sstream>
#include <cmath>
#include <stdint.h>
#include <cassert>

#include "rmb_convert.hpp"

using namespace std;

namespace Sandwych { namespace RmbConverter {

    inline static double round(double value, int precision) {
        const int adjustment = pow(10,precision);
        return floor( value*(adjustment) + 0.5 )/adjustment;
    }


    inline const char* rmb_digit(int i) {
        static const char* RMB_DIGITS[] = { "零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" };
        return RMB_DIGITS[i];
    }


    inline const char* section_char(int i) {
        static const char* SECTION_CHARS[] = { "", "拾", "佰", "仟", "万" };
        return SECTION_CHARS[i];
    }


    template<class OStreamType> 
    static int parse_integer(OStreamType& ss, int64_t integer, bool isFirstSection, int zeroCount) {
        assert(integer > 0 && integer <= 9999);
        int nDigits = (int)floor(log10(integer)) + 1;
        if (!isFirstSection && integer < 1000) {
            zeroCount++;
        }
        for (int i = 0; i < nDigits; i++) {
            int64_t factor = (int64_t)pow(10, nDigits - 1 - i);
            int64_t digit = integer / factor;

            if (digit != 0) {
                if (zeroCount > 0) {
                    ss << "零";
                }
                ss << rmb_digit((int)digit);
                ss << section_char(nDigits - i - 1);
                zeroCount = 0;
            }
            else {
                zeroCount++;
            }
            integer -= integer / factor * factor;
        }
        return zeroCount;
    }


    template<class OStreamType> 
    static void parse_decimal(OStreamType& ss, int64_t integerPart, int64_t decPart, int zeroCount) {
        assert(decPart > 0 && decPart <= 99);
        int64_t jiao = decPart / 10;
        int64_t fen = decPart % 10;

        if (zeroCount > 0 && (jiao > 0 || fen > 0) && integerPart > 0) {
            ss << "零";
        }

        if (jiao > 0) {
            ss << rmb_digit(jiao);
            ss << "角";
        }
        if (zeroCount == 0 && jiao == 0 && fen > 0 && integerPart > 0) {
            ss << "零";
        }
        if (fen > 0) {
            ss << rmb_digit(fen);
            ss << "分";
        }
        else {
            ss << "整";
        }
    }

    template<class OStreamType> 
    string to_upper_rmb(double price) {

        OStreamType ss;
        price = round(price, 2);

        int64_t integerPart = (int64_t)price;
        int64_t wanyiPart = integerPart / 1000000000000L;
        int64_t yiPart = integerPart % 1000000000000L / 100000000L;
        int64_t wanPart = integerPart % 100000000L / 10000L;
        int64_t qianPart = integerPart % 10000L;
        int64_t decPart = (int64_t)(price * 100) % 100;

        int zeroCount = 0;
        //处理万亿以上的部分
        if (integerPart >= 1000000000000L && wanyiPart > 0) {
            zeroCount = parse_integer(ss, wanyiPart, true, zeroCount);
            ss << "万";
        }


        //处理亿到千亿的部分
        if (integerPart >= 100000000L && yiPart > 0) {
            bool isFirstSection = integerPart >= 100000000L && integerPart < 1000000000000L;
            zeroCount = parse_integer(ss, yiPart, isFirstSection, zeroCount);
            ss << "亿";
        }

        //处理万的部分
        if (integerPart >= 10000L && wanPart > 0) {
            bool isFirstSection = integerPart >= 1000L && integerPart < 10000000L;
            zeroCount = parse_integer(ss, wanPart, isFirstSection, zeroCount);
            ss << "万";
        }

        //处理千及以后的部分
        if (qianPart > 0) {
            bool isFirstSection = integerPart < 1000L;
            zeroCount = parse_integer(ss, qianPart, isFirstSection, zeroCount);
        }
        else {
            zeroCount += 1;
        }

        if (integerPart > 0) {
            ss << "元";
        }

        //处理小数
        if (decPart > 0) {
            parse_decimal(ss, integerPart, decPart, zeroCount);
        }
        else if (decPart <= 0 && integerPart > 0) {
            ss << "整";
        }
        else {
            ss << "零元整";
        }

        return ss.str();
    }


}} //namespaces

