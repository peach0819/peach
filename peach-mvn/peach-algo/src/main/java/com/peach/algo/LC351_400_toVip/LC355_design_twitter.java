package com.peach.algo.LC351_400_toVip;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/10/10
 * 设计一个简化版的推特(Twitter)，可以让用户实现发送推文，关注/取消关注其他用户，能够看见关注人（包括自己）的最近 10 条推文。
 * 实现 Twitter 类：
 * Twitter() 初始化简易版推特对象
 * void postTweet(int userId, int tweetId) 根据给定的 tweetId 和 userId 创建一条新推文。每次调用此函数都会使用一个不同的 tweetId 。
 * List<Integer> getNewsFeed(int userId) 检索当前用户新闻推送中最近  10 条推文的 ID 。新闻推送中的每一项都必须是由用户关注的人或者是用户自己发布的推文。推文必须 按照时间顺序由最近到最远排序 。
 * void follow(int followerId, int followeeId) ID 为 followerId 的用户开始关注 ID 为 followeeId 的用户。
 * void unfollow(int followerId, int followeeId) ID 为 followerId 的用户不再关注 ID 为 followeeId 的用户。
 * 示例：
 * 输入
 * ["Twitter", "postTweet", "getNewsFeed", "follow", "postTweet", "getNewsFeed", "unfollow", "getNewsFeed"]
 * [[], [1, 5], [1], [1, 2], [2, 6], [1], [1, 2], [1]]
 * 输出
 * [null, null, [5], null, null, [6, 5], null, [5]]
 * 解释
 * Twitter twitter = new Twitter();
 * twitter.postTweet(1, 5); // 用户 1 发送了一条新推文 (用户 id = 1, 推文 id = 5)
 * twitter.getNewsFeed(1);  // 用户 1 的获取推文应当返回一个列表，其中包含一个 id 为 5 的推文
 * twitter.follow(1, 2);    // 用户 1 关注了用户 2
 * twitter.postTweet(2, 6); // 用户 2 发送了一个新推文 (推文 id = 6)
 * twitter.getNewsFeed(1);  // 用户 1 的获取推文应当返回一个列表，其中包含两个推文，id 分别为 -> [6, 5] 。推文 id 6 应当在推文 id 5 之前，因为它是在 5 之后发送的
 * twitter.unfollow(1, 2);  // 用户 1 取消关注了用户 2
 * twitter.getNewsFeed(1);  // 用户 1 获取推文应当返回一个列表，其中包含一个 id 为 5 的推文。因为用户 1 已经不再关注用户 2
 * 提示：
 * 1 <= userId, followerId, followeeId <= 500
 * 0 <= tweetId <= 104
 * 所有推特的 ID 都互不相同
 * postTweet、getNewsFeed、follow 和 unfollow 方法最多调用 3 * 104 次
 */
public class LC355_design_twitter {

    public static void main(String[] args) {
        Twitter twitter = new LC355_design_twitter().new Twitter();
        twitter.postTweet(1, 5);
        twitter.follow(1, 2);
        twitter.postTweet(2, 6);
        List<Integer> newsFeed = twitter.getNewsFeed(1);
        int i = 1;
    }

    /**
     * Your Twitter object will be instantiated and called as such:
     * Twitter obj = new Twitter();
     * obj.postTweet(userId,tweetId);
     * List<Integer> param_2 = obj.getNewsFeed(userId);
     * obj.follow(followerId,followeeId);
     * obj.unfollow(followerId,followeeId);
     */
    class Twitter {

        /**
         * userId -> List<tweetId>
         */
        Map<Integer, List<Integer>> userTweetMap = new HashMap<>();

        /**
         * userId -> List<userId>
         */
        Map<Integer, Set<Integer>> followMap = new HashMap<>();
        Map<Integer, Set<Integer>> followeeMap = new HashMap<>();

        Map<Integer, List<Integer>> newsTweetCacheMap = new HashMap<>();

        Map<Integer, Integer> indexMap = new HashMap<>();
        Integer index = 0;

        public Twitter() {

        }

        public void postTweet(int userId, int tweetId) {
            indexMap.put(index, tweetId);

            userTweetMap.putIfAbsent(userId, new ArrayList<>());
            List<Integer> list = userTweetMap.get(userId);
            list.add(0, index);
            if (list.size() > 10) {
                list.remove(list.size() - 1);
            }

            List<Integer> followerUserIds = new ArrayList<>();
            followerUserIds.add(userId);
            if (followeeMap.containsKey(userId)) {
                followerUserIds.addAll(followeeMap.get(userId));
            }
            for (Integer followerUserId : followerUserIds) {
                if (!newsTweetCacheMap.containsKey(followerUserId)) {
                    get(followerUserId);
                    continue;
                }
                List<Integer> cache = newsTweetCacheMap.get(followerUserId);
                cache.add(0, index);
                if (cache.size() > 10) {
                    cache.remove(cache.size() - 1);
                }
            }
            index++;
        }

        public List<Integer> getNewsFeed(int userId) {
            List<Integer> list = get(userId);
            List<Integer> result = new ArrayList<>();
            for (Integer index : list) {
                result.add(indexMap.get(index));
            }
            return result;
        }

        private List<Integer> get(int userId) {
            if (newsTweetCacheMap.containsKey(userId)) {
                return newsTweetCacheMap.get(userId);
            }
            List<Integer> list = doGetNewsFeed(userId);
            newsTweetCacheMap.put(userId, list);
            return list;
        }

        private List<Integer> doGetNewsFeed(int userId) {
            List<Integer> result = new ArrayList<>();
            List<Integer> follewUserIds = new ArrayList<>();
            follewUserIds.add(userId);
            if (followMap.containsKey(userId)) {
                follewUserIds.addAll(followMap.get(userId));
            }
            for (Integer follewUserId : follewUserIds) {
                if (userTweetMap.containsKey(follewUserId)) {
                    result.addAll(userTweetMap.get(follewUserId));
                }
            }
            result.sort(Comparator.comparing(Integer::intValue).reversed());
            if (result.size() <= 10) {
                return result;
            }
            return new ArrayList<>(result.subList(0, 10));
        }

        public void follow(int followerId, int followeeId) {
            followMap.putIfAbsent(followerId, new HashSet<>());
            followMap.get(followerId).add(followeeId);

            followeeMap.putIfAbsent(followeeId, new HashSet<>());
            followeeMap.get(followeeId).add(followerId);
            newsTweetCacheMap.remove(followerId);
        }

        public void unfollow(int followerId, int followeeId) {
            if (followMap.containsKey(followerId)) {
                followMap.get(followerId).remove(Integer.valueOf(followeeId));
            }
            if (followeeMap.containsKey(followeeId)) {
                followeeMap.get(followeeId).remove(Integer.valueOf(followerId));
            }
            newsTweetCacheMap.remove(followerId);
        }
    }

}
