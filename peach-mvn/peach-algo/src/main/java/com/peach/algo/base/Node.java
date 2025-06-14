package com.peach.algo.base;

import java.util.List;

/**
 * @author feitao.zt
 * @date 2025/6/13
 */
public class Node {

    public int val;
    public List<Node> children;

    public Node() {}

    public Node(int _val) {
        val = _val;
    }

    public Node(int _val, List<Node> _children) {
        val = _val;
        children = _children;
    }
}
