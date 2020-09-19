using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Text;

namespace Sandwych.RmbConverter.Test
{
    [TestFixture]
    public class IssueTests
    {
        [Test]
        public void Test_Issue_3()
        {
            Assert.AreEqual(2323.22M.ToRmbUpper(), "贰仟叁佰贰拾叁元贰角贰分");
        }
    }
}
