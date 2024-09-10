package com.peach.algo.LC201_250_toVip;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/8/28
 * 请你设计一个数据结构，支持 添加新单词 和 查找字符串是否与任何先前添加的字符串匹配 。
 * 实现词典类 WordDictionary ：
 * WordDictionary() 初始化词典对象
 * void addWord(word) 将 word 添加到数据结构中，之后可以对它进行匹配
 * bool search(word) 如果数据结构中存在字符串与 word 匹配，则返回 true ；否则，返回  false 。word 中可能包含一些 '.' ，每个 . 都可以表示任何一个字母。
 * 示例：
 * 输入：
 * ["WordDictionary","addWord","addWord","addWord","search","search","search","search"]
 * [[],["bad"],["dad"],["mad"],["pad"],["bad"],[".ad"],["b.."]]
 * 输出：
 * [null,null,null,null,false,true,true,true]
 * 解释：
 * WordDictionary wordDictionary = new WordDictionary();
 * wordDictionary.addWord("bad");
 * wordDictionary.addWord("dad");
 * wordDictionary.addWord("mad");
 * wordDictionary.search("pad"); // 返回 False
 * wordDictionary.search("bad"); // 返回 True
 * wordDictionary.search(".ad"); // 返回 True
 * wordDictionary.search("b.."); // 返回 True
 * 提示：
 * 1 <= word.length <= 25
 * addWord 中的 word 由小写英文字母组成
 * search 中的 word 由 '.' 或小写英文字母组成
 * 最多调用 104 次 addWord 和 search
 */
public class LC211_design_add_and_search_words_data_structure {

    /**
     * Your WordDictionary object will be instantiated and called as such:
     * WordDictionary obj = new WordDictionary();
     * obj.addWord(word);
     * boolean param_2 = obj.search(word);
     */
    class WordDictionary {

        Node head = new Node(' ');

        public WordDictionary() {

        }

        public void addWord(String word) {
            head.add(word.toCharArray(), 0);
        }

        public boolean search(String word) {
            return head.search(word.toCharArray(), 0);
        }
    }

    class Node {

        boolean hasFinish = false;
        char c;
        Map<Character, Node> map = new HashMap<>();

        public Node(char c) {
            this.c = c;
        }

        public void add(char[] array, int index) {
            char cur = array[index];
            map.putIfAbsent(cur, new Node(cur));
            Node curNode = map.get(cur);
            if (index == array.length - 1) {
                curNode.hasFinish = true;
                return;
            }
            curNode.add(array, index + 1);
        }

        public boolean search(char[] array, int index) {
            char cur = array[index];
            boolean isLast = index == array.length - 1;
            if (cur == '.') {
                for (Node value : map.values()) {
                    if (isLast) {
                        if (value.hasFinish) {
                            return true;
                        }
                    } else {
                        if (value.search(array, index + 1)) {
                            return true;
                        }
                    }
                }
                return false;
            }
            if (!map.containsKey(cur)) {
                return false;
            }
            Node node = map.get(cur);
            if (index == array.length - 1) {
                return node.hasFinish;
            }
            return node.search(array, index + 1);
        }
    }

}
