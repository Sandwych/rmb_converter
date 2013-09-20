using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using NUnit.Framework;

namespace Sandwych.RmbConverter.Test {

    [TestFixture]
    public class RmbUpperTests {

        [Test]
        public void TestRandomly([Random(0.00, 99999999999.99, 5)] double price) {
            var d = new decimal(price);
            Assert.IsNotNullOrEmpty(d.ToRmbUpper());
        }

        [Test]
        public void TestConverts() {
            decimal i;

            i = 1034567890.1299999999999999M;
            Assert.AreEqual("壹拾亿叁仟肆佰伍拾陆万柒仟捌佰玖拾元壹角叁分", i.ToRmbUpper());

            Assert.That(10000000.00M.ToRmbUpper() == "壹仟万元整");

            Assert.That(100100.00M.ToRmbUpper() == "壹拾万零壹佰元整");

            Assert.That(3456789.10M.ToRmbUpper() == "叁佰肆拾伍万陆仟柒佰捌拾玖元壹角整");

            i = 999909009.10M;
            Assert.AreEqual("玖亿玖仟玖佰玖拾万玖仟零玖元壹角整", i.ToRmbUpper());

            i = 3456789.10M;
            Assert.AreEqual("叁佰肆拾伍万陆仟柒佰捌拾玖元壹角整", i.ToRmbUpper());

            i = 345000012.33M;
            Assert.AreEqual("叁亿肆仟伍佰万零壹拾贰元叁角叁分", i.ToRmbUpper());

            i = 10100.03M;
            Assert.AreEqual("壹万零壹佰元零叁分", i.ToRmbUpper());

            i = 20000.12M;
            Assert.AreEqual("贰万元壹角贰分", i.ToRmbUpper());

            i = 9009999999999999.12M;
            Assert.AreEqual("玖仟零玖万玖仟玖佰玖拾玖亿玖仟玖佰玖拾玖万玖仟玖佰玖拾玖元壹角贰分", i.ToRmbUpper());

            i = 11010.12M;
            Assert.AreEqual("壹万壹仟零壹拾元壹角贰分", i.ToRmbUpper());

        }

        [Test]
        public void TestDecimalProcessing() {
            Assert.AreEqual("叁角整", 0.30M.ToRmbUpper());
            Assert.AreEqual("叁角叁分", 0.33M.ToRmbUpper());
            Assert.AreEqual("叁分", 0.03M.ToRmbUpper());
        }

        [Test]
        public void TestZero() {
            Assert.AreEqual("零元整", 0.00M.ToRmbUpper());
        }
    }

}
