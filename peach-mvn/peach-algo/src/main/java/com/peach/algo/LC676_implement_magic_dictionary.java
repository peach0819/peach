package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2025/11/6
 * 设计一个使用单词列表进行初始化的数据结构，单词列表中的单词 互不相同 。 如果给出一个单词，请判定能否只将这个单词中一个字母换成另一个字母，使得所形成的新单词存在于你构建的字典中。
 * 实现 MagicDictionary 类：
 * MagicDictionary() 初始化对象
 * void buildDict(String[] dictionary) 使用字符串数组 dictionary 设定该数据结构，dictionary 中的字符串互不相同
 * bool search(String searchWord) 给定一个字符串 searchWord ，判定能否只将字符串中 一个 字母换成另一个字母，使得所形成的新字符串能够与字典中的任一字符串匹配。如果可以，返回 true ；否则，返回 false 。
 * 示例：
 * 输入
 * ["MagicDictionary", "buildDict", "search", "search", "search", "search"]
 * [[], [["hello", "leetcode"]], ["hello"], ["hhllo"], ["hell"], ["leetcoded"]]
 * 输出
 * [null, null, false, true, false, false]
 * 解释
 * MagicDictionary magicDictionary = new MagicDictionary();
 * magicDictionary.buildDict(["hello", "leetcode"]);
 * magicDictionary.search("hello"); // 返回 False
 * magicDictionary.search("hhllo"); // 将第二个 'h' 替换为 'e' 可以匹配 "hello" ，所以返回 True
 * magicDictionary.search("hell"); // 返回 False
 * magicDictionary.search("leetcoded"); // 返回 False
 * 提示：
 * 1 <= dictionary.length <= 100
 * 1 <= dictionary[i].length <= 100
 * dictionary[i] 仅由小写英文字母组成
 * dictionary 中的所有字符串 互不相同
 * 1 <= searchWord.length <= 100
 * searchWord 仅由小写英文字母组成
 * buildDict 仅在 search 之前调用一次
 * 最多调用 100 次 search
 */
public class LC676_implement_magic_dictionary {

    /**
     * Your MagicDictionary object will be instantiated and called as such:
     * MagicDictionary obj = new MagicDictionary();
     * obj.buildDict(dictionary);
     * boolean param_2 = obj.search(searchWord);
     */
    class MagicDictionary {

        class Node {

            char c;
            Node[] children = new Node[26];
            boolean last;
        }

        Node[] root = new Node[26];

        public MagicDictionary() {

        }

        public void buildDict(String[] dictionary) {
            for (String str : dictionary) {
                build(str);
            }
        }

        private void build(String str) {
            Node[] cur = root;
            for (int i = 0; i < str.length(); i++) {
                char c = str.charAt(i);
                int index = c - 'a';
                if (cur[index] == null) {
                    Node node = new Node();
                    node.c = c;
                    if (i == str.length() - 1) {
                        node.last = true;
                    }
                    cur[index] = node;
                } else {
                    if (i == str.length() - 1) {
                        cur[index].last = true;
                    }
                }
                cur = cur[index].children;
            }
        }

        public boolean search(String searchWord) {
            return search(root, searchWord.toCharArray(), 0, true);
        }

        private boolean search(Node[] node, char[] array, int beginIndex, boolean canReplace) {
            char c = array[beginIndex];
            if (beginIndex == array.length - 1) {
                if (!canReplace) {
                    Node curNode = node[c - 'a'];
                    return curNode != null && curNode.last;
                } else {
                    for (int i = 0; i < node.length; i++) {
                        if (i == c - 'a') {
                            continue;
                        }
                        if (node[i] != null && node[i].last) {
                            return true;
                        }
                    }
                    return false;
                }
            }

            if (!canReplace) {
                return searchNotReplace(node, array, beginIndex);
            }
            return searchReplace(node, array, beginIndex);
        }

        private boolean searchNotReplace(Node[] node, char[] array, int beginIndex) {
            char c = array[beginIndex];
            if (node[c - 'a'] == null) {
                return false;
            }
            Node curNode = node[c - 'a'];
            return search(curNode.children, array, beginIndex + 1, false);
        }

        private boolean searchReplace(Node[] node, char[] array, int beginIndex) {
            char c = array[beginIndex];
            for (int i = 0; i < node.length; i++) {
                if (i == c - 'a') {
                    if (node[i] != null && search(node[i].children, array, beginIndex + 1, true)) {
                        return true;
                    }
                } else {
                    if (node[i] != null && search(node[i].children, array, beginIndex + 1, false)) {
                        return true;
                    }
                }
            }
            return false;
        }
    }

}
