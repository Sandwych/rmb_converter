/** 中文互联网上迄今为止实现最正确、代码最漂亮且效率最高的大写人民币金额转换代码 
 * 作者：李维 <oldrev@gmail.com>
 * 版权所有 (c) 2013 昆明维智众源企业管理咨询有限公司。保留所有权利。
 * 本代码基于 BSD License 授权。
 * */

using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;

namespace Sandwych.RmbConverter {

    public static class RmbUpperConverter {

        private static readonly Char[] RmbDigits = {
            '零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖' };

        private static readonly string[] SectionChars = {
             string.Empty, "拾", "佰", "仟", "万" };

        public static string ToRmbUpper(this decimal price) {
            if (price < 0M || price >= 9999999999999999.99M) {
                throw new ArgumentOutOfRangeException("price");
            }

            price = Math.Round(price, 2);
            var sb = new StringBuilder();

            var integerPart = (long)price;
            var wanyiPart = integerPart / 1000000000000L;
            var yiPart = integerPart % 1000000000000L / 100000000L;
            var wanPart = integerPart % 100000000L / 10000L;
            var qianPart = integerPart % 10000L;
            var decPart = (long)(price * 100) % 100;

            int zeroCount = 0;
            //处理万亿以上的部分
            if (integerPart >= 1000000000000L) {
                zeroCount = ParseInteger(sb, wanyiPart, zeroCount);
                sb.Append("万");
            }

            //处理亿到千亿的部分
            if (integerPart >= 100000000L) {
                zeroCount = ParseInteger(sb, yiPart, zeroCount);
                sb.Append("亿");
            }

            //处理万的部分
            if (integerPart >= 10000L) {
                zeroCount = ParseInteger(sb, wanPart, zeroCount);
                sb.Append("万");
            }

            //处理千及以后的部分
            if (integerPart >= 10000L && qianPart > 0 && qianPart <= 999) {
                sb.Append("零");
            }
            if (qianPart > 0) {
                zeroCount = ParseInteger(sb, qianPart, zeroCount);
            }

            if (integerPart > 0) {
                sb.Append("元");
            }

            //处理小数
            if (decPart > 0) {
                ParseDecimal(sb, integerPart, decPart, zeroCount);
            }
            else if (decPart <= 0 && integerPart > 0) {
                sb.Append("整");
            }
            else {
                sb.Append("零元整");
            }

            return sb.ToString();
        }

        private static void ParseDecimal(StringBuilder sb, long integerPart, long decPart, int zeroCount = 0) {
            Debug.Assert(decPart > 0 && decPart <= 99);
            var jiao = decPart / 10;
            var fen = decPart % 10;

            if (zeroCount > 0 && (jiao > 0 || fen > 0)) {
                sb.Append("零");
            }

            if (jiao > 0) {
                sb.Append(RmbDigits[jiao]);
                sb.Append("角");
            }
            if ((jiao == 0 && fen > 0 && integerPart > 0)) {
                sb.Append("零");
            }
            if (fen > 0) {
                sb.Append(RmbDigits[fen]);
                sb.Append("分");
            }
            else {
                sb.Append("整");
            }
        }

        private static int ParseInteger(StringBuilder sb, long integer, int zeroCount = 0) {
            Debug.Assert(integer > 0 && integer <= 9999);
            int nDigits = (int)Math.Floor(Math.Log10(integer)) + 1;
            for (var i = 0; i < nDigits; i++) {
                var factor = (long)Math.Pow(10, nDigits - 1 - i);
                var digit = integer / factor;

                if (digit != 0) {
                    if (zeroCount > 0) {
                        sb.Append("零");
                    }
                    sb.Append(RmbDigits[digit]);
                    sb.Append(SectionChars[nDigits - i - 1]);
                    zeroCount = 0;
                }
                else {
                    if (i < nDigits) {
                        zeroCount++;
                    }
                }
                integer -= integer / factor * factor;
            }
            return zeroCount;
        }

    }

}
