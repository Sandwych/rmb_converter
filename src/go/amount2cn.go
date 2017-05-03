// Package amount2cn provides ...
package amount2cn

import (
	"bytes"
	"fmt"
	"math"
)

var (
	// 金额单位
	SECTION_CHARS = []string{
		"", "拾", "佰", "仟", "万",
	}

	// 金额数字
	RMB_DIGITS = []string{
		"零", "壹", "贰", "叁", "肆",
		"伍", "陆", "柒", "捌", "玖",
	}
)

// 转换接口
func Amount2CN(amount float64) (cn string, err error) {
	// 第三位小数四舍五入
	amount = math.Floor(amount*100+0.5)/100 + 0.000001

	// 缓存
	buf := &bytes.Buffer{}
	if amount < 0 {
		amount = -amount
		buf.WriteString("负")
	}

	intAmount := int(amount)
	wanyiPart := intAmount / 1e12
	if wanyiPart > 9999 {
		return "", fmt.Errorf("too big")
	}
	yiPart := intAmount % 1e12 / 1e8
	wanPart := intAmount % 1e8 / 1e4
	qianPart := intAmount % 1e4
	decPart := int(amount*100) % 100

	zeroCount := 0

	// 处理万一部分
	if intAmount >= 1e12 && wanyiPart > 0 {
		zeroCount = parseInteger(buf, wanyiPart, true, zeroCount)
		buf.WriteString("万")
	}

	// 处理亿到千亿的部分
	if intAmount >= 1e8 && yiPart > 0 {
		isFirstSection := intAmount >= 1e8 && intAmount < 1e12
		zeroCount = parseInteger(buf, yiPart, isFirstSection, zeroCount)
		buf.WriteString("亿")
	}

	// 处理万的部分
	if intAmount >= 1e4 && wanPart > 0 {
		isFirstSection := intAmount >= 1e4 && intAmount < 1e8
		zeroCount = parseInteger(buf, wanPart, isFirstSection, zeroCount)
		buf.WriteString("万")
	}

	// 处理千的部分
	if qianPart > 0 {
		isFirstSection := intAmount < 1e4
		zeroCount = parseInteger(buf, qianPart, isFirstSection, zeroCount)
	} else {
		zeroCount += 1
	}

	if intAmount > 0 {
		buf.WriteString("元")
	}

	// 处理小数
	if decPart > 0 {
		parseDecimal(buf, decPart)
	} else if decPart == 0 && intAmount > 0 {
		buf.WriteString("整")
	} else {
		buf.WriteString("零元整")
	}

	return buf.String(), nil
}

func parseInteger(buf *bytes.Buffer, integer int, isFirstSection bool, zeroCount int) int {
	nDigits := int(math.Floor(math.Log10(float64(integer)))) + 1
	if !isFirstSection && integer < 1000 {
		zeroCount++
	}

	for i := 0; i < nDigits; i++ {
		factor := int(math.Pow10(nDigits - 1 - i))
		digit := integer / factor

		if digit > 0 {
			if zeroCount > 0 {
				buf.WriteString("零")
			}

			buf.WriteString(RMB_DIGITS[digit])
			buf.WriteString(SECTION_CHARS[nDigits-i-1])
			zeroCount = 0
		} else {
			zeroCount++
		}

		integer -= integer / factor * factor
	}

	return zeroCount
}

func parseDecimal(buf *bytes.Buffer, decPart int) {
	jiao := decPart / 10
	fen := decPart % 10

	if jiao > 0 {
		buf.WriteString(RMB_DIGITS[jiao])
		buf.WriteString("角")
	}

	if fen > 0 {
		buf.WriteString(RMB_DIGITS[fen])
		buf.WriteString("分")
	}
}
