// Package amount2cn provides ...
package amount2cn

import "testing"

var ds = []float64{
	0,
	0.21,
	0.212,
	1.21,
	1.212,
	100,
	100.20,
	199.09,
	10002301301.212,
}

var expect = []string{
	"零元整",
	"贰角壹分",
	"贰角壹分",
	"壹元贰角壹分",
	"壹元贰角壹分",
	"壹佰元整",
	"壹佰元贰角",
	"壹佰玖拾玖元玖分",
	"壹佰亿零贰佰叁拾万零壹仟叁佰零壹元贰角壹分",
}

func TestAmount2CN(t *testing.T) {
	for i, d := range ds {
		cn, err := ToUpperRMB(d)
		if err != nil {
			t.Fatal(err)
		}

		if cn != expect[i] {
			t.Fatal("not equal", cn, d, i)
		}
		t.Log(cn)
	}
}
