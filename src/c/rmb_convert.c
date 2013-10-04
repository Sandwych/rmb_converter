/** 中文互联网上迄今为止实现最正确、代码最漂亮且效率最高的大写人民币金额转换代码 
 * C 语言版本
 * 作者：李维 <oldrev@gmail.com>
 * 版权所有 (c) 2013 昆明维智众源企业管理咨询有限公司。保留所有权利。
 * 本代码基于 BSD License 授权。
 * */

#include <string.h>
#include <math.h>
#include <stdint.h>
#include <assert.h>
#include <malloc.h>

#include "rmb_convert.h"

const size_t MAX_RMB_BUF = 256;

typedef struct StringBuilderStruct {
    char* buf;
    size_t index;
    size_t max;
} StringBuilder;


static void sb_append(StringBuilder* sb, const char* str) {
    size_t l = strlen(str);
    assert(sb->index + l < MAX_RMB_BUF - 1);
    memcpy(sb->buf + sb->index, str, l);
    sb->index += l;
}


static double round_decimal(double value, int precision) {
    const int adjustment = pow(10, precision);
    return floor(value * adjustment + 0.5) / adjustment;
}


static const char* rmb_digit(int i) {
    static const char* RMB_DIGITS[] = { "零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" };
    return RMB_DIGITS[i];
}


static const char* section_char(int i) {
    static const char* SECTION_CHARS[] = { "", "拾", "佰", "仟", "万" };
    return SECTION_CHARS[i];
}


static int parse_integer(
        StringBuilder* ss, int integer, int isFirstSection, int zeroCount) {
    assert(integer > 0 && integer <= 9999);
    int i;
    int nDigits = (int)log10(integer) + 1;
    if (!isFirstSection && integer < 1000) {
        zeroCount++;
    }
    for (i = 0; i < nDigits; i++) {
        int factor = (int)pow(10, nDigits - 1 - i);
        int digit = integer / factor;

        if (digit != 0) {
            if (zeroCount > 0) {
                sb_append(ss, "零");
            }
            sb_append(ss, rmb_digit((int)digit));
            sb_append(ss, section_char(nDigits - i - 1));
            zeroCount = 0;
        }
        else {
            zeroCount++;
        }
        integer -= integer / factor * factor;
    }
    return zeroCount;
}


static void parse_decimal(StringBuilder* ss, int64_t integerPart, int decPart, int zeroCount) {
    assert(decPart > 0 && decPart <= 99);
    int jiao = decPart / 10;
    int fen = decPart % 10;

    if (zeroCount > 0 && (jiao > 0 || fen > 0) && integerPart > 0) {
        sb_append(ss, "零");
    }

    if (jiao > 0) {
        sb_append(ss, rmb_digit(jiao));
        sb_append(ss, "角");
    }
    if (zeroCount == 0 && jiao == 0 && fen > 0 && integerPart > 0) {
        sb_append(ss, "零");
    }
    if (fen > 0) {
        sb_append(ss, rmb_digit(fen));
        sb_append(ss, "分");
    }
    else {
        sb_append(ss, "整");
    }
}

char* to_upper_rmb(double price) {

    char buf[MAX_RMB_BUF];
    memset(buf, 0, sizeof(buf));
    StringBuilder ss;
    ss.buf = buf;
    ss.index = 0;
    price = round_decimal(price, 2);

    int64_t integerPart = (int64_t)price;
    int wanyiPart = (int)(integerPart / 1000000000000L);
    int yiPart = (int)(integerPart % 1000000000000L / 100000000L);
    int wanPart = (int)(integerPart % 100000000L / 10000L);
    int qianPart = (int)(integerPart % 10000L);
    int decPart = (int)(integerPart * 100 % 100);

    int zeroCount = 0;
    //处理万亿以上的部分
    if (integerPart >= 1000000000000L && wanyiPart > 0) {
        zeroCount = parse_integer(&ss, wanyiPart, 1, zeroCount);
        sb_append(&ss, "万");
    }


    //处理亿到千亿的部分
    if (integerPart >= 100000000L && yiPart > 0) {
        int isFirstSection = integerPart >= 100000000L && integerPart < 1000000000000L;
        zeroCount = parse_integer(&ss, yiPart, isFirstSection, zeroCount);
        sb_append(&ss, "亿");
    }

    //处理万的部分
    if (integerPart >= 10000L && wanPart > 0) {
        int isFirstSection = integerPart >= 1000L && integerPart < 10000000L;
        zeroCount = parse_integer(&ss, wanPart, isFirstSection, zeroCount);
        sb_append(&ss, "万");
    }

    //处理千及以后的部分
    if (qianPart > 0) {
        int isFirstSection = integerPart < 1000L;
        zeroCount = parse_integer(&ss, qianPart, isFirstSection, zeroCount);
    }
    else {
        zeroCount += 1;
    }

    if (integerPart > 0) {
        sb_append(&ss, "元");
    }

    //处理小数
    if (decPart > 0) {
        parse_decimal(&ss, integerPart, decPart, zeroCount);
    }
    else if (decPart <= 0 && integerPart > 0) {
        sb_append(&ss, "整");
    }
    else {
        sb_append(&ss, "零元整");
    }

    return strdup(ss.buf);
}
