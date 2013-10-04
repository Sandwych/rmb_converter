/** ���Ļ�����������Ϊֹʵ������ȷ��������Ư����Ч����ߵĴ�д����ҽ��ת������ 
 * Java �汾
 * ���ߣ���ά <oldrev@gmail.com>
 * ��Ȩ���� (c) 2013 ����ά����Դ��ҵ������ѯ���޹�˾����������Ȩ����
 * ��������� BSD License ��Ȩ��
 * */


package com.sandwych.rmb_convert;

public class RMBUpper {
	
    private static final char[] RMB_DIGITS = {
        '��', 'Ҽ', '��', '��', '��', '��', '½', '��', '��', '��' };

    private static final String[] SECTION_CHARS = {
         "", "ʰ", "��", "Ǫ", "��" };

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
        //�����������ϵĲ���
        if (integerPart >= 1000000000000L && wanyiPart > 0) {
            zeroCount = parseInteger(sb, wanyiPart, true, zeroCount);
            sb.append("��");
        }

        //�����ڵ�ǧ�ڵĲ���
        if (integerPart >= 100000000L && yiPart > 0) {
            boolean isFirstSection = integerPart >= 100000000L && integerPart < 1000000000000L;
            zeroCount = parseInteger(sb, yiPart, isFirstSection, zeroCount);
            sb.append("��");
        }

        //������Ĳ���
        if (integerPart >= 10000L && wanPart > 0) {
            boolean isFirstSection = integerPart >= 1000L && integerPart < 10000000L;
            zeroCount = parseInteger(sb, wanPart, isFirstSection, zeroCount);
            sb.append("��");
        }

        //����ǧ���Ժ�Ĳ���
        if (qianPart > 0) {
            boolean isFirstSection = integerPart < 1000L;
            zeroCount = parseInteger(sb, qianPart, isFirstSection, zeroCount);
        }
        else {
            zeroCount += 1;
        }

        if (integerPart > 0) {
            sb.append("Ԫ");
        }

        //����С��
        if (decPart > 0) {
            parseDecimal(sb, integerPart, decPart, zeroCount);
        }
        else if (decPart <= 0 && integerPart > 0) {
            sb.append("��");
        }
        else {
            sb.append("��Ԫ��");
        }

        return sb.toString();
    }
    
    private static void parseDecimal(StringBuilder sb, long integerPart, int decPart, int zeroCount) {
        assert decPart > 0 && decPart <= 99;
        int jiao = decPart / 10;
        int fen = decPart % 10;

        if (zeroCount > 0 && (jiao > 0 || fen > 0) && integerPart > 0) {
            sb.append("��");
        }

        if (jiao > 0) {
            sb.append(RMB_DIGITS[jiao]);
            sb.append("��");
        }
        if (zeroCount == 0 && jiao == 0 && fen > 0 && integerPart > 0) {
            sb.append("��");
        }
        if (fen > 0) {
            sb.append(RMB_DIGITS[fen]);
            sb.append("��");
        }
        else {
            sb.append("��");
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
                    sb.append("��");
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
