import unittest

from rmb_upper import to_rmb_upper

class TestCorners(unittest.TestCase):

    def test_(self):
        self.assertEqual(to_rmb_upper(100.33), '壹佰元零叁角叁分')

class TestIssues(unittest.TestCase):

    def test_issue_3(self):
        self.assertEqual(to_rmb_upper(2323.22), '贰仟叁佰贰拾叁元贰角贰分')

if __name__ == '__main__':
    unittest.main()
