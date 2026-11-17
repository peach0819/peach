package com.peach.all.demo;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/2/21
 */
public class TestDemo {

    static String a = "抱歉，看起来我无法直接访问到您提到的数据库 `crm`。不过根据您之前提供的信息，我可以为您列出拜访小记表（`pt_visit_record_0`）的字段及其描述：\n\n以下是表 `pt_visit_record_0` 的字段列表及说明：\n\n1. **id** - 自增主键\n2. **bu_id** - buid，默认为0表示海拍客\n3. **dc_id** - 分销商id，如0:海拍客, 1:贝莱\n4. **record_id** - 小记id，全局唯一，作为其他表关联小记的外键\n5. **record_type** - 拜访类别：\n - 1：服务商经理拜访门店\n - 2：服务商经理拜访服务商\n - 3: BD拜访门店\n - 4: 电销拜访门店\n - 5: 服务商业务员拜访门店\n6. **visitor_id** - 出访人ID（销售账号）\n7. **visitor_json** - 出访人快照\n8. **with_user_id** - 陪访人id\n9. **object_id** - 受访对象id（门店id/服务商id）\n10. **object_json** - 受访对象快照\n11. **visit_mode** - 拜访结果类型：\n - 1为有效拜访\n - 2无效小记\n - 3为一般拜访\n12. **visit_type** - 拜访方式：\n - 1、见面\n - 2、电话\n - 3、微信\n13. **visit_aims_type** - 拜访目的类型，多个逗号分隔，各类小记自定义\n14. **visit_status** - 拜访状态：\n - 0：未知\n - 1：未完成\n - 2：已完成\n15. **linker_id** - 联系人id\n16. **linker_json** - 联系人快照\n17. **visit_time** - 起始拜访时间\n18. **end_visit_time** - 结束拜访时间\n19. **content** - 联系内容，长文本字段\n20. **position_json** - 拜访位置json，支持多个\n21. **file_json** - 图片和语音等内容\n22. **verify_status** - 审核状态：\n - 0：未知\n - 1：不合格\n - 2:合格\n23. **verify_user_id** - 审核人\n24. **verify_time** - 审核时间\n25. **extra_json** - 拜访扩展的字段json格式内容\n26. **conversation_code** - 通话记录code\n27. **plan_id** - 联系计划id\n28. **next_plan_id** - 下次联系计划id\n29. **subject_ids** - 项目id列表，逗号分隔\n30. **creator** - 创建人\n31. **create_time** - 创建时间\n32. **editor** - 修改人\n33. **edit_time** - 编辑时间\n34. **is_deleted** - 是否删除\n\n如果您需要对这些字段进行任何操作或有进一步的问题，请告诉我！";

    public static void main(String[] args) {
        String trim = a.trim();
        System.out.println(trim);
    }

}
