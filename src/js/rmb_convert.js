/** 中文互联网上迄今为止实现最正确、代码最漂亮且效率最高的大写人民币金额转换代码 
 * Javascript 版本
 * 作者：李维 <oldrev@gmail.com>
 * 版权所有 (c) 2013 昆明维智众源企业管理咨询有限公司。保留所有权利。
 * 本代码基于 BSD License 授权。
 * */

var RMBConverter = (function() {
    var RmbDigits = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖' ];
    var SectionChars = ["", "拾", "佰", "仟", "万"];

    var parseDecimal = function(sb, integerPart, decPart, zeroCount) {
        //assert(decPart > 0 && decPart <= 99);
        var jiao = Math.floor(decPart / 10);
        var fen = decPart % 10;

        if (zeroCount > 0 && (jiao > 0 || fen > 0) && integerPart > 0) {
            sb.push("零");
        }

        if (jiao > 0) {
            sb.push(RmbDigits[jiao]);
            sb.push("角");
        }
        if (zeroCount == 0 && jiao == 0 && fen > 0 && integerPart > 0) {
            sb.push("零");
        }
        if (fen > 0) {
            sb.push(RmbDigits[fen]);
            sb.push("分");
        }
        else {
            sb.push("整");
        }
    };

    var parseInteger = function(sb, integer, isFirstSection, zeroCount) {
        //assert(integer > 0 && integer <= 9999);
        var nDigits = Math.floor(Math.log(integer + 0.5) / Math.log(10)) + 1;
        if (!isFirstSection && integer < 1000) {
            zeroCount++;
        }

        for (var i = 0; i < nDigits; i++) {
            var factor = Math.floor(Math.pow(10, nDigits - 1 - i));
            var digit = Math.floor(integer / factor);

            if (digit != 0) {
                if (zeroCount > 0) {
                    sb.push("零");
                }
                sb.push(RmbDigits[digit]);
                sb.push(SectionChars[nDigits - i - 1]);
                zeroCount = 0;
            }
            else {
                zeroCount++;
            }
            integer -= Math.floor(integer / factor) * factor;
        }
        return zeroCount;
    }


    var toUpper = function(price) {

        var sb = [];

        var integerPart = Math.trunc(price);
        var wanyiPart = Math.trunc(integerPart / 1000000000000);
        var yiPart = integerPart % 1000000000000 / 100000000;
        var wanPart = Math.trunc(integerPart % 100000000 / 10000);
        var qianPart = integerPart % 10000;
        var decPart = Math.round(price * 100 % 100);

        var zeroCount = 0;

        //处理万亿以上的部分
        if (integerPart >= 1000000000000 && wanyiPart > 0) {
            zeroCount = parseInteger(sb, wanyiPart, true, zeroCount);
            sb.push("万");
        }

        //处理亿到千亿的部分
        if (integerPart >= 100000000 && yiPart > 0) {
            var isFirstSection = integerPart >= 100000000 && integerPart < 1000000000000;
            zeroCount = parseInteger(sb, yiPart, isFirstSection, zeroCount);
            sb.push("亿");
        }

        //处理万的部分
        if (integerPart >= 10000 && wanPart > 0) {
            var isFirstSection = integerPart >= 1000 && integerPart < 10000000;
            zeroCount = parseInteger(sb, wanPart, isFirstSection, zeroCount);
            sb.push("万");
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
            sb.push("元");
        }

        //处理小数
        if (decPart > 0) {
            parseDecimal(sb, integerPart, decPart, zeroCount);
        }
        else if (decPart <= 0 && integerPart > 0) {
            sb.push("整");
        }
        else {
            sb.push("零元整");
        }

        return sb.join("");
    };


    return {
        toUpper: toUpper
    };

})();


