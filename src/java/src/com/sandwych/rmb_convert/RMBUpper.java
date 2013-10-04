/** 中文互联网上迄今为止实现最正确、代码最漂亮且效率最高的大写人民币金额转换代码 
 * Java 版本
 * 作者：李维 <oldrev@gmail.com>
 * 版权所有 (c) 2013 昆明维智众源企业管理咨询有限公司。保留所有权利。
 * 本代码基于 BSD License 授权。
 * */


package com.sandwych.rmb_convert;

public class RMBUpper {
	
    private static final char[] RMB_DIGITS = {
        '零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖' };

    private static final String[] SECTION_CHARS = {
         "", "拾", "佰", "仟", "万" };

    public static String toRmbUpper(double price) {
    	price = Math.round(price * 100) / 100;
    	
        StringBuilder sb = new StringBuilder();

        long integerPart = (long)price;
        int wanyiPart = (int)(integerPart / 1000000000000L);
        int yiPart = (int)(integerPart % 1000000000000L / 100000000L);
        int wanPart = (int)(integerPart % 100000000L / 10000L);
        int qianPart = (int)(integerPart % 10000L);
        int decPart = (int)(price * 100 % 100);

        int zeroCount = 0;
        //处理万亿以上的部分
        if (integerPart >= 1000000000000L && wanyiPart > 0) {
            zeroCount = parseInteger(sb, wanyiPart, true, zeroCount);
            sb.append("万");
        }

        //处理亿到千亿的部分
        if (integerPart >= 100000000L && yiPart > 0) {
            boolean isFirstSection = integerPart >= 100000000L && integerPart < 1000000000000L;
            zeroCount = parseInteger(sb, yiPart, isFirstSection, zeroCount);
            sb.append("亿");
        }

        //处理万的部分
        if (integerPart >= 10000L && wanPart > 0) {
            boolean isFirstSection = integerPart >= 1000L && integerPart < 10000000L;
            zeroCount = parseInteger(sb, wanPart, isFirstSection, zeroCount);
            sb.append("万");
        }

        //处理千及以后的部分
        if (qianPart > 0) {
            boolean isFirstSection = integerPart < 1000L;
            zeroCount = parseInteger(sb, qianPart, isFirstSection, zeroCount);
        }
        else {
            zeroCount += 1;
        }

        if (integerPart > 0) {
            sb.append("元");
        }

        //处理小数
        if (decPart > 0) {
            parseDecimal(sb, integerPart, decPart, zeroCount);
        }
        else if (decPart <= 0 && integerPart > 0) {
            sb.append("整");
        }
        else {
            sb.append("零元整");
        }

        return sb.toString();
    }
    
    private static void parseDecimal(StringBuilder sb, long integerPart, int decPart, int zeroCount) {
        assert decPart > 0 && decPart <= 99;
        int jiao = decPart / 10;
        int fen = decPart % 10;

        if (zeroCount > 0 && (jiao > 0 || fen > 0) && integerPart > 0) {
            sb.append("零");
        }

        if (jiao > 0) {
            sb.append(RMB_DIGITS[jiao]);
            sb.append("角");
        }
        if (zeroCount == 0 && jiao == 0 && fen > 0 && integerPart > 0) {
            sb.append("零");
        }
        if (fen > 0) {
            sb.append(RMB_DIGITS[fen]);
            sb.append("分");
        }
        else {
            sb.append("整");
        }
    }
    
    private static int parseInteger(StringBuilder sb, int integer, boolean isFirstSection, int zeroCount) {
        assert integer > 0 && integer <= 9999;    	
        int nDigits = (int)Math.floor(Math.log10(integer)) + 1;
        if (!isFirstSection && integer < 1000) {
            zeroCount++;
        }
        for (int i = 0; i < nDigits; i++) {
            int factor = (int)Math.pow(10, nDigits - 1 - i);
            assert factor > 0;
            int digit = (int)(integer / factor);            
            assert digit >= 0 && digit <= 9;
            if (digit > 0) {
                if (zeroCount > 0) {
                    sb.append("零");
                }
                sb.append(RMB_DIGITS[digit]);
                sb.append(SECTION_CHARS[nDigits - i - 1]);
                zeroCount = 0;
            }
            else {
                zeroCount++;
            }
            integer -= integer / factor * factor;
        }
        return zeroCount;
    }

}
