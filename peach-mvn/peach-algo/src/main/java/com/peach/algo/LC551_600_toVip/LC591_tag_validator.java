package com.peach.algo.LC551_600_toVip;

import java.util.ArrayDeque;
import java.util.Deque;

/**
 * @author feitao.zt
 * @date 2025/7/23
 * 给定一个表示代码片段的字符串，你需要实现一个验证器来解析这段代码，并返回它是否合法。合法的代码片段需要遵守以下的所有规则：
 * 代码必须被合法的闭合标签包围。否则，代码是无效的。
 * 闭合标签（不一定合法）要严格符合格式：<TAG_NAME>TAG_CONTENT</TAG_NAME>。其中，<TAG_NAME>是起始标签，</TAG_NAME>是结束标签。起始和结束标签中的 TAG_NAME 应当相同。当且仅当 TAG_NAME 和 TAG_CONTENT 都是合法的，闭合标签才是合法的。
 * 合法的 TAG_NAME 仅含有大写字母，长度在范围 [1,9] 之间。否则，该 TAG_NAME 是不合法的。
 * 合法的 TAG_CONTENT 可以包含其他合法的闭合标签，cdata （请参考规则7）和任意字符（注意参考规则1）除了不匹配的<、不匹配的起始和结束标签、不匹配的或带有不合法 TAG_NAME 的闭合标签。否则，TAG_CONTENT 是不合法的。
 * 一个起始标签，如果没有具有相同 TAG_NAME 的结束标签与之匹配，是不合法的。反之亦然。不过，你也需要考虑标签嵌套的问题。
 * 一个<，如果你找不到一个后续的>与之匹配，是不合法的。并且当你找到一个<或</时，所有直到下一个>的前的字符，都应当被解析为 TAG_NAME（不一定合法）。
 * cdata 有如下格式：<![CDATA[CDATA_CONTENT]]>。CDATA_CONTENT 的范围被定义成 <![CDATA[ 和后续的第一个 ]]>之间的字符。
 * CDATA_CONTENT 可以包含任意字符。cdata 的功能是阻止验证器解析CDATA_CONTENT，所以即使其中有一些字符可以被解析为标签（无论合法还是不合法），也应该将它们视为常规字符。
 * 合法代码的例子:
 * 输入: "<DIV>This is the first line <![CDATA[<div>]]></DIV>"
 * 输出: True
 * 解释:
 * 代码被包含在了闭合的标签内： <DIV> 和 </DIV> 。
 * TAG_NAME 是合法的，TAG_CONTENT 包含了一些字符和 cdata 。
 * 即使 CDATA_CONTENT 含有不匹配的起始标签和不合法的 TAG_NAME，它应该被视为普通的文本，而不是标签。
 * 所以 TAG_CONTENT 是合法的，因此代码是合法的。最终返回True。
 * 输入: "<DIV>>>  ![cdata[]] <![CDATA[<div>]>]]>]]>>]</DIV>"
 * 输出: True
 * 解释:
 * 我们首先将代码分割为： start_tag|tag_content|end_tag 。
 * start_tag -> "<DIV>"
 * end_tag -> "</DIV>"
 * tag_content 也可被分割为： text1|cdata|text2 。
 * text1 -> ">>  ![cdata[]] "
 * cdata -> "<![CDATA[<div>]>]]>" ，其中 CDATA_CONTENT 为 "<div>]>"
 * text2 -> "]]>>]"
 * start_tag 不是 "<DIV>>>" 的原因参照规则 6 。
 * cdata 不是 "<![CDATA[<div>]>]]>]]>" 的原因参照规则 7 。
 * 不合法代码的例子:
 * 输入: "<A>  <B> </A>   </B>"
 * 输出: False
 * 解释: 不合法。如果 "<A>" 是闭合的，那么 "<B>" 一定是不匹配的，反之亦然。
 * 输入: "<DIV>  div tag is not closed  <DIV>"
 * 输出: False
 * 输入: "<DIV>  unmatched <  </DIV>"
 * 输出: False
 * 输入: "<DIV> closed tags with invalid tag name  <b>123</b> </DIV>"
 * 输出: False
 * 输入: "<DIV> unmatched tags with invalid tag name  </1234567890> and <CDATA[[]]>  </DIV>"
 * 输出: False
 * 输入: "<DIV>  unmatched start tag <B>  and unmatched end tag </C>  </DIV>"
 * 输出: False
 * 注意:
 * 为简明起见，你可以假设输入的代码（包括提到的任意字符）只包含数字, 字母, '<','>','/','!','[',']'和' '。
 */
public class LC591_tag_validator {

    String CDATA1 = "<![CDATA[", CDATA2 = "]]>";

    public boolean isValid(String s) {
        Deque<String> d = new ArrayDeque<>();
        int n = s.length(), i = 0;
        while (i < n) {
            if (i + 8 < n && s.substring(i, i + 9).equals(CDATA1)) {
                if (i == 0) return false;
                int j = i + 9;
                boolean ok = false;
                while (j < n && !ok) {
                    if (j + 2 < n && s.substring(j, j + 3).equals(CDATA2)) {
                        j = j + 3; ok = true;
                    } else {
                        j++;
                    }
                }
                if (!ok) return false;
                i = j;
            } else if (s.charAt(i) == '<') {
                if (i == n - 1) return false;
                boolean isEnd = s.charAt(i + 1) == '/';
                int p = isEnd ? i + 2 : i + 1, j = p;
                while (j < n && s.charAt(j) != '>') {
                    if (!Character.isUpperCase(s.charAt(j))) return false;
                    j++;
                }
                if (j == n) return false;
                int len = j - p;
                if (len < 1 || len > 9) return false;
                String tag = s.substring(p, j);
                i = j + 1;
                if (!isEnd) {
                    d.addLast(tag);
                } else {
                    if (d.isEmpty() || !d.pollLast().equals(tag)) return false;
                    if (d.isEmpty() && i < n) return false;
                }
            } else {
                if (i == 0) return false;
                i++;
            }
        }
        return d.isEmpty();
    }

    //char[] chars;
    //
    //public boolean isValid(String code) {
    //    this.chars = code.toCharArray();
    //    if (code.charAt(0) != '<') {
    //        return false;
    //    }
    //    return checkTag(0, chars.length - 1);
    //}
    //
    //private boolean checkTag(int beginIndex, int endIndex) {
    //    if (chars[beginIndex] != '<' || chars[endIndex] != '>') {
    //        return false;
    //    }
    //
    //}
    //
    //private boolean checkTagValue(int beginIndex, int endIndex, int beginIndex2, int endIndex2) {
    //    if (chars[beginIndex2] != '<' || chars[beginIndex2 + 1] != '/') {
    //        return false;
    //    }
    //    int length = endIndex - beginIndex;
    //    if (length == 1) {
    //        return false;
    //    }
    //    int length2 = endIndex2 - beginIndex2;
    //    if (length2 - length != 1) {
    //        return false;
    //    }
    //    for (int i = beginIndex + 1; i < endIndex; i++) {
    //        if (!Character.isUpperCase(chars[i]) || chars[i] != chars[beginIndex2 - beginIndex + i + 1]) {
    //            return false;
    //        }
    //    }
    //    return true;
    //}
    //
    //private boolean checkContent(int beginIndex, int endIndex) {
    //
    //}

}
