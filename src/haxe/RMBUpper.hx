/** 中文互联网上迄今为止实现最正确、代码最漂亮且效率最高的大写人民币金额转换代码 
 * 作者：李维 <oldrev@gmail.com>
 * HaXe 3 版本
 * 版权所有 (c) 2013 昆明维智众源企业管理咨询有限公司。保留所有权利。
 * 本代码基于 BSD License 授权。
 * */


class RMBUpper {

    private static var RMB_DIGITS = ["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" ];

    private static var SECTION_CHARS = ["", "拾", "佰", "仟", "万" ];

    public static function toUpper(price: Float) : String {
        if (price < 0 || price >= 9999999999999999.99) {
            throw "'price' is out of range";
        }

        //price = Math.Round(price, 2);
        var sb = new StringBuf();

        var integerPart = Std.int(price);
        var wanyiPart  = Std.int(integerPart / 1000000000000);
        var yiPart = Std.int(integerPart % 1000000000000 / 100000000);
        var wanPart = Std.int(integerPart % 100000000 / 10000);
        var qianPart = integerPart % 10000;
        var decPart = Std.int(price * 100) % 100;

        var zeroCount = 0;
        //处理万亿以上的部分
        if (integerPart >= 1000000000000 && wanyiPart > 0) {
            zeroCount = parseInteger(sb, wanyiPart, true, zeroCount);
            sb.add("万");
        }

        //处理亿到千亿的部分
        if (integerPart >= 100000000 && yiPart > 0) {
            var isFirstSection = integerPart >= 100000000 && integerPart < 1000000000000;
            zeroCount = parseInteger(sb, yiPart, isFirstSection, zeroCount);
            sb.add("亿");
        }

        //处理万的部分
        if (integerPart >= 10000 && wanPart > 0) {
            var isFirstSection = integerPart >= 1000 && integerPart < 10000000;
            zeroCount = parseInteger(sb, wanPart, isFirstSection, zeroCount);
            sb.add("万");
        }

        //处理千及以后的部分
        if (qianPart > 0) {
            var isFirstSection = integerPart < 1000;
            zeroCount = parseInteger(sb, qianPart, isFirstSection, zeroCount);
        }
        else {
            zeroCount += 1;
        }

        if (integerPart > 0) {
            sb.add("元");
        }

        //处理小数
        if (decPart > 0) {
            parseDecimal(sb, integerPart, decPart, zeroCount);
        }
        else if (decPart <= 0 && integerPart > 0) {
            sb.add("整");
        }
        else {
            sb.add("零元整");
        }

        return sb.toString();
    }

    private static function parseDecimal(sb: StringBuf, integerPart: Int, decPart: Int, zeroCount: Int) {
        if(!(decPart > 0 && decPart <= 99)) {
            throw "Argument 'decPart' is out of range";
        }
        var jiao = Std.int(decPart / 10);
        var fen = decPart % 10;

        if (zeroCount > 0 && (jiao > 0 || fen > 0) && integerPart > 0) {
            sb.add("零");
        }

        if (jiao > 0) {
            sb.add(RMB_DIGITS[jiao]);
            sb.add("角");
        }
        if (zeroCount == 0 && jiao == 0 && fen > 0 && integerPart > 0) {
            sb.add("零");
        }
        if (fen > 0) {
            sb.add(RMB_DIGITS[fen]);
            sb.add("分");
        }
        else {
            sb.add("整");
        }
    }

    private static function parseInteger(sb: StringBuf, integer: Int, isFirstSection: Bool, zeroCount: Int) : Int {
        if(!(integer > 0 && integer <= 9999)) {
            throw "Argument 'integer' is out of range";
        }
        var nDigits = Std.int(Math.floor(Math.log(integer) / Math.log(10))) + 1;
        if (!isFirstSection && integer < 1000) {
            zeroCount++;
        }
        for (i in 0...nDigits) {
            var factor = Std.int(Math.pow(10, nDigits - 1 - i));
            var digit = Std.int(integer / factor);

            if (digit != 0) {
                if (zeroCount > 0) {
                    sb.add("零");
                }
                sb.add(RMB_DIGITS[digit]);
                sb.add(SECTION_CHARS[nDigits - i - 1]);
                zeroCount = 0;
            }
            else {
                zeroCount++;
            }
            integer -= Std.int(integer / factor * factor);
        }
        return zeroCount;
    }
}

