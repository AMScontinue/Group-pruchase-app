package com.example.grouppurchase_backend;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.serializer.SerializerFeature;
import com.example.grouppurchase_backend.Dao.CommodityDao;
import com.example.grouppurchase_backend.Dao.GroupDao;
import com.example.grouppurchase_backend.Dao.OrderDao;
import com.example.grouppurchase_backend.Dao.UserDao;
import com.example.grouppurchase_backend.Entity.Commodity;
import com.example.grouppurchase_backend.Entity.Group;
import com.example.grouppurchase_backend.Entity.Order;
import com.example.grouppurchase_backend.Entity.User;
import com.example.grouppurchase_backend.Service.MiaoService;
import org.junit.FixMethodOrder;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.runners.MethodSorters;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;
import org.quartz.TriggerKey;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.WebApplicationContext;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.example.grouppurchase_backend.GroupPurchaseBackendApplication.scheduler;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Component
@Rollback
@Transactional
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class GroupPurchaseBackendApplicationTests {

    @Autowired
    private UserDao userDao;

    @Autowired
    private GroupDao groupDao;

    @Autowired
    private OrderDao orderDao;

    @Autowired
    private CommodityDao commodityDao;

    @Autowired
    private MiaoService miaoService;

    @Autowired
    private WebApplicationContext webApplicationContext;

    public MockMvc mockMvc;

    public Map<String, String> map;

    static public int old_head;

    static public int old_cus;

    String perform(Map map, String url) throws Exception {
        return mockMvc.perform(
                        MockMvcRequestBuilders
                                .post(url)
                                .contentType(MediaType.APPLICATION_JSON_VALUE)
                                .content(JSONObject.toJSONString(map))
                )
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andReturn().getResponse().getContentAsString();
    }

    @BeforeEach
    void before() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
        map = new HashMap();
    }

    @Test
    void test01() throws Exception {  //用户测试
        ArrayList<String> con = new ArrayList<>();

        //获取所有用户头像
        map.clear();
        for (int i = 1; i < 9; i++) {
            if (i < 7) {
                con.add(String.valueOf(i));
            } else {
                con.add(String.valueOf(i + 130));
            }
            if (i < 3) {
                con.add("https://img2.woyaogexing.com/2018/07/15/4f9e38fa399a487087af709fcce57132!400x400.jpeg");
            } else {
                con.add("https://img2.baidu.com/it/u=1367512152,228915312&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500");
            }
        }
        String t = JSON.toJSONString(con, SerializerFeature.BrowserCompatible);
        String res = perform(map, "/HandleUserPic");
        assertEquals(t, res);

        //正常注册，得到的id不会为0
        map.put("user_name", "test");
        map.put("password", "test");
        map.put("email", "test@qq.com");
        map.put("image_url", "test");
        res = perform(map, "/NewUser");
        assertNotEquals("0", res);

        //用户名重复，无法注册
        map.clear();
        map.put("user_name", "chen");
        map.put("password", "test");
        map.put("email", "test@qq.com");
        map.put("image_url", "test");
        res = perform(map, "/NewUser");
        assertEquals("0", res);

        //正常登录
        map.clear();
        map.put("user_name", "chen");
        map.put("password", "123456");
        con.clear();
        con.add(String.valueOf(1));    //用户id
        con.add("chen");    //用户名
        con.add("https://img2.woyaogexing.com/2018/07/15/4f9e38fa399a487087af709fcce57132!400x400.jpeg");    //用户头像
        con.add("400000");    //用户余额
        con.add("3");    //发起数
        con.add("0");    //参与数
        con.add("0");    //正常订单数
        con.add("1");    //被取消的订单数
        t = JSON.toJSONString(con, SerializerFeature.BrowserCompatible);
        res = perform(map, "/CheckUser");
        assertEquals(t, res);

        //登录时找不到用户
        map.clear();
        map.put("user_name", "software");
        map.put("password", "test");
        res = perform(map, "/CheckUser");
        assertEquals("1", res);

        //登录时密码错误
        map.clear();
        map.put("user_name", "chen");
        map.put("password", "123");
        res = perform(map, "/CheckUser");
        assertEquals("2", res);

        //获取更新信息
        map.clear();
        map.put("user_id", "1");
        con.clear();
        con.add("400000");    //用户余额
        con.add("3");    //发起数
        con.add("0");    //参与数
        con.add("0");    //正常订单数
        con.add("1");    //被取消的订单数
        t = JSON.toJSONString(con, SerializerFeature.BrowserCompatible);
        res = perform(map, "/GetSomeInfo");
        assertEquals(t, res);

        //成功对已存在用户充值
        map.clear();
        map.put("user_id", "1");
        map.put("money", "50000");
        res = perform(map, "/AddBalance");
        assertEquals("1", res);
        User user = userDao.findByUser_id(1);
        int balance = user.getBalance();
        assertEquals(balance, 450000);

        //充值对象不存在
        map.clear();
        map.put("user_id", "99999");
        map.put("money", "50000");
        res = perform(map, "/AddBalance");
        assertEquals("0", res);

        //获取用户名
        map.clear();
        map.put("user_id", "1");
        res = perform(map, "/GetUsername");
        assertEquals("chen", res);
    }

    @Test
    void test02() throws Exception {  //团购测试
        //获取所有团购
        map.clear();
        String res = perform(map, "/getAllGroupInfo");
        JSONArray jsonArray = JSONArray.parseArray(res);
        String result = jsonArray.get(0).toString()
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "");
        assertEquals("4", result);

        //获取单个团购
        map.put("group_id", "7");
        res = perform(map, "/getOneGroupInfo");
        jsonArray = JSONArray.parseArray(res);
        result = jsonArray.get(0).toString()
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "");
        assertEquals("4", result);

        //获取发起的团购
        map.clear();
        map.put("user_id", "1");
        res = perform(map, "/GetLaunched");
        jsonArray = JSONArray.parseArray(res);
        result = jsonArray.get(0).toString()
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "");
        assertEquals("3", result);

        //获取参与的团购
        map.clear();
        map.put("user_id", "2");
        res = perform(map, "/GetJoined");
        jsonArray = JSONArray.parseArray(res);
        result = jsonArray.get(0).toString()
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "");
        assertEquals("1", result);

        //创建团购，若成功则id一定不为0
        map.clear();
        map.put("group_name", "unique1");
        map.put("des", "test");
        map.put("post", "test");
        map.put("begin_time", "2022-07-14 01:45");
        map.put("end_time", "2022-10-14 01:45");
        map.put("head_id", "2");
        res = perform(map, "/CreateGroup");
        assertNotEquals("0", res);

        //创建第二个结束时间相同的团购
        map.clear();
        map.put("group_name", "unique2");
        map.put("des", "test");
        map.put("post", "test");
        map.put("begin_time", "2022-07-14 01:46");
        map.put("end_time", "2022-10-14 01:45");
        map.put("head_id", "2");
        res = perform(map, "/CreateGroup");
        assertNotEquals("0", res);

        //创建第三个结束时间相同的团购
        map.clear();
        map.put("group_name", "unique3");
        map.put("des", "test");
        map.put("post", "test");
        map.put("begin_time", "2022-07-14 01:47");
        map.put("end_time", "2022-10-14 01:45");
        map.put("head_id", "2");
        res = perform(map, "/CreateGroup");
        assertNotEquals("0", res);

        //创建第四个结束时间相同的团购
        map.clear();
        map.put("group_name", "unique4");
        map.put("des", "test");
        map.put("post", "test");
        map.put("begin_time", "2022-07-14 01:48");
        map.put("end_time", "2022-10-14 01:45");
        map.put("head_id", "2");
        res = perform(map, "/CreateGroup");
        assertNotEquals("0", res);

        //依次删除第二个、第一个、第四个创建的团购
        List<Group> group = groupDao.getGroupsByGroup_name("unique");
        int[] orders = {1, 0, 3, 2};
        for (int i = 0; i < group.size(); i++) {
            Group g = group.get(orders[i]);
            int gid = g.getGroup_id();
            int cid = commodityDao.addCommodity("0", gid, "0", "0", 1000, 10, false);
            orderDao.createOrder(gid, cid, 1, 5, "2022-08-14 01:45");
            map.clear();
            map.put("group_id", String.valueOf(gid));
            perform(map, "/DeleteGroup");
            Group gg = groupDao.getGroupByGroup_id(gid);
            assertNull(gg);
        }

        //试图结束一个未开始的团购，结束失败
        map.clear();
        map.put("group_id", "7");
        map.put("end_time", "2021-09-29 09:48");
        res = perform(map, "/FinishGroup");
        assertEquals("1", res);

        //试图结束一个已结束的团购，结束失败
        map.clear();
        map.put("group_id", "7");
        map.put("end_time", "2023-09-29 09:48");
        res = perform(map, "/FinishGroup");
        assertEquals("2", res);

        //正常结束团购
        map.clear();
        map.put("group_id", "7");
        map.put("end_time", "2022-09-29 09:48");
        res = perform(map, "/FinishGroup");
        assertEquals("0", res);

        //根据团长名字查询团购
        map.clear();
        map.put("ByHead", "1");
        map.put("KeyWord", "chen");
        res = perform(map, "/SearchGroup");
        jsonArray = JSONArray.parseArray(res);
        result = jsonArray.get(0).toString()
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "");
        assertEquals("3", result);

        //根据团购名字查询团购
        map.clear();
        map.put("ByHead", "0");
        map.put("KeyWord", "123");
        res = perform(map, "/SearchGroup");
        jsonArray = JSONArray.parseArray(res);
        result = jsonArray.get(0).toString()
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "");
        assertEquals("1", result);

        //用户是团长
        map.clear();
        map.put("id", "7");
        map.put("user_id", "1");
        res = perform(map, "/CheckHead");
        assertEquals("1", res);

        //用户不是团长
        map.clear();
        map.put("id", "7");
        map.put("user_id", "2");
        res = perform(map, "/CheckHead");
        assertEquals("0", res);

        //获取团长名字
        map.clear();
        map.put("group_id", "7");
        res = perform(map, "/GetHeadName");
        assertEquals("chen", res);

        //创建团购的链接
        map.clear();
        map.put("group_id", "7");
        res = perform(map, "/GetLink");
        assertEquals("groupPurchase://GroupPurchaseInfo?id=7", res);

        //更新团购名字
        map.clear();
        map.put("group_id", "7");
        map.put("type", "0");
        map.put("inner", "test_test");
        res = perform(map, "/UpdateGroup");
        assertEquals("1", res);

        //更新团购描述
        map.clear();
        map.put("group_id", "7");
        map.put("type", "1");
        map.put("inner", "test_test");
        res = perform(map, "/UpdateGroup");
        assertEquals("1", res);

        //更新团购物流
        map.clear();
        map.put("group_id", "7");
        map.put("type", "2");
        map.put("inner", "test_test");
        res = perform(map, "/UpdateGroup");
        assertEquals("1", res);

        //更新团购开始时间
        map.clear();
        map.put("group_id", "7");
        map.put("type", "3");
        map.put("inner", "2020-07-13 08:56");
        res = perform(map, "/UpdateGroup");
        assertEquals("1", res);

        //更新团购开始时间，但晚于了结束时间，导致失败
        map.clear();
        map.put("group_id", "7");
        map.put("type", "3");
        map.put("inner", "2027-07-13 08:56");
        res = perform(map, "/UpdateGroup");
        assertEquals("0", res);

        //更新团购结束时间
        map.clear();
        map.put("group_id", "7");
        map.put("type", "4");
        map.put("inner", "2029-07-13 08:56");
        res = perform(map, "/UpdateGroup");
        assertEquals("1", res);

        //更新团购结束时间，但早于了开始时间，导致失败
        map.clear();
        map.put("group_id", "7");
        map.put("type", "4");
        map.put("inner", "2017-07-13 08:56");
        res = perform(map, "/UpdateGroup");
        assertEquals("0", res);
    }

    @Test
    void test03() throws Exception {  //商品测试
        //创建商品
        map.clear();
        map.put("commodity_name", "comT");
        map.put("des", "good");
        map.put("group_id", "7");
        map.put("price", "111");
        map.put("inventory", "50");
        map.put("image_url", "testurl");
        map.put("miao", "false");
        String res = perform(map, "/CreateCommodity");
        int cid = Integer.parseInt(res);
        Commodity commodity = commodityDao.getCommodityByCommodity_id(cid);
        String tmp = commodity.getCommodity_name();
        assertEquals(tmp, "comT");
        tmp = commodity.getImage_url();
        assertEquals(tmp, "testurl");
        tmp = commodity.getDes();
        assertEquals(tmp, "good");

        //更新商品
        map.clear();
        map.put("commodity_id", String.valueOf(cid));
        map.put("type", "1");
        map.put("inner", "change_name");
        perform(map, "/UpdateCommodity");
        commodity = commodityDao.getCommodityByCommodity_id(cid);
        tmp = commodity.getCommodity_name();
        assertEquals(tmp, "change_name");

        //更新商品
        map.clear();
        map.put("commodity_id", String.valueOf(cid));
        map.put("type", "0");
        map.put("inner", "change_url");
        perform(map, "/UpdateCommodity");
        commodity = commodityDao.getCommodityByCommodity_id(cid);
        tmp = commodity.getImage_url();
        assertEquals(tmp, "change_url");

        //更新商品
        map.clear();
        map.put("commodity_id", String.valueOf(cid));
        map.put("type", "2");
        map.put("inner", "500");
        perform(map, "/UpdateCommodity");
        commodity = commodityDao.getCommodityByCommodity_id(cid);
        int tmpInt = commodity.getPrice();
        assertEquals(tmpInt, 500);

        //更新商品
        map.clear();
        map.put("commodity_id", String.valueOf(cid));
        map.put("type", "3");
        map.put("inner", "15");
        perform(map, "/UpdateCommodity");
        commodity = commodityDao.getCommodityByCommodity_id(cid);
        tmpInt = commodity.getInventory();
        assertEquals(tmpInt, 15);

        //更新商品
        map.clear();
        map.put("commodity_id", String.valueOf(cid));
        map.put("type", "4");
        map.put("inner", "bad");
        perform(map, "/UpdateCommodity");
        commodity = commodityDao.getCommodityByCommodity_id(cid);
        tmp = commodity.getDes();
        assertEquals(tmp, "bad");

        //更新商品
        map.clear();
        map.put("commodity_id", String.valueOf(cid));
        map.put("type", "5");
        map.put("inner", "true");
        perform(map, "/UpdateCommodity");
        commodity = commodityDao.getCommodityByCommodity_id(cid);
        assertTrue(commodity.isMiao());

        //获取指定商品信息
        map.clear();
        map.put("commodity_id", String.valueOf(cid));
        res = perform(map, "/getCommodityInfoByCommodity_id");
        ArrayList<String> con = new ArrayList<>();
        con.add("change_name");
        con.add("change_url");
        con.add("bad");
        con.add("500");
        con.add("15");
        con.add("true");
        String tmpJson = JSON.toJSONString(con, SerializerFeature.BrowserCompatible);
        assertEquals(tmpJson, res);

        //删除商品
        orderDao.createOrder(7, cid, 2, 1, "2022-08-13 08:56");
        map.clear();
        map.put("group_id", "7");
        map.put("commodity_id", String.valueOf(cid));
        perform(map, "/DeleteCommodity");
        Commodity target = commodityDao.getCommodityByCommodity_id(cid);
        assertNull(target);

        map.clear();
        con.clear();

        //此处注入测试需要的所有url
        con.add("43");
        con.add("http://img3m4.ddimg.cn/97/26/11021242714-1_k_2.jpg");
        con.add("44");
        con.add("http://img3m1.ddimg.cn/82/21/11029465441-1_k_1.jpg");
        con.add("46");
        con.add("http://img3m1.ddimg.cn/82/21/11029465441-1_k_1.jpg");
        con.add("47");
        con.add("http://img3m9.ddimg.cn/40/21/1465611979-4_u_1.jpg");
        con.add("48");
        con.add("http://img3m4.ddimg.cn/81/27/11016079254-1_k_1.jpg");
        con.add("49");
        con.add("http://img3m9.ddimg.cn/40/21/1465611979-4_u_1.jpg");
        con.add("51");
        con.add("http://img3m4.ddimg.cn/97/26/11021242714-1_k_2.jpg");
        con.add("61");
        con.add("http://img3m4.ddimg.cn/97/26/11021242714-1_k_2.jpg");
        con.add("386");
        con.add("http://img3m4.ddimg.cn/97/26/11021242714-1_k_2.jpg");
        tmpJson = JSON.toJSONString(con, SerializerFeature.BrowserCompatible);
        res = perform(map, "/HandleCommodityPic");
        assertEquals(tmpJson, res);

    }

    @Test
    void test04() throws Exception {  //订单测试
        //获取用户订单
        map.clear();
        map.put("user_id", "5");
        String res = perform(map, "/getUserOrder");
        JSONArray jsonArray = JSONArray.parseArray(res);
        String result = jsonArray.get(0).toString()
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "");
        assertEquals("1", result);

        //获取用户被取消的订单
        map.clear();
        map.put("user_id", "5");
        res = perform(map, "/getFailedOrder");
        jsonArray = JSONArray.parseArray(res);
        result = jsonArray.get(0).toString()
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "");
        assertEquals("1", result);

        //获取团购订单
        map.clear();
        map.put("group_id", "8");
        res = perform(map, "/getGroupOrder");
        jsonArray = JSONArray.parseArray(res);
        result = jsonArray.get(0).toString()
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "");
        assertEquals("6", result);

        //获取商品订单
        map.clear();
        map.put("commodity_id", "48");
        res = perform(map, "/getCommodityOrder");
        assertEquals("1", res);

        //获取用户订单总价
        map.clear();
        map.put("user_id", "5");
        res = perform(map, "/getUserOrderTotal");
        assertEquals("10000", res);

        //获取团购订单总价
        map.clear();
        map.put("group_id", "9");
        res = perform(map, "/getGroupOrderTotal");
        assertEquals("250000", res);

        //获取用户订单数
        map.clear();
        map.put("user_id", "5");
        res = perform(map, "/getUserOrderAmount");
        assertEquals("1", res);

        //获取团购订单数
        map.clear();
        map.put("group_id", "9");
        res = perform(map, "/getGroupOrderAmount");
        assertEquals("3", res);

        //创建订单，但用户余额不足
        map.clear();
        map.put("commodity_id", "46");
        map.put("user_id", "2");
        map.put("pay_time", "2022-08-29 09:48");
        map.put("commodity_amount", "9");
        res = perform(map, "/CreateOrder");
        assertEquals("Money", res);

        //创建订单，但商品库存不足
        map.clear();
        map.put("commodity_id", "48");
        map.put("user_id", "1");
        map.put("pay_time", "2022-07-14 11:12");
        map.put("commodity_amount", "40");
        res = perform(map, "/CreateOrder");
        assertEquals("Inventory", res);

        //创建订单，但团购未开始
        map.clear();
        map.put("commodity_id", "43");
        map.put("user_id", "1");
        map.put("pay_time", "2002-07-14 11:12");
        map.put("commodity_amount", "1");
        res = perform(map, "/CreateOrder");
        assertEquals("Time", res);

        //创建订单，但团购已结束
        map.clear();
        map.put("commodity_id", "43");
        map.put("user_id", "1");
        map.put("pay_time", "2092-07-14 11:12");
        map.put("commodity_amount", "1");
        res = perform(map, "/CreateOrder");
        assertEquals("Time", res);

        //正常创建订单
        map.clear();
        map.put("commodity_id", "43");
        map.put("user_id", "2");
        map.put("pay_time", "2022-08-29 11:12");
        map.put("commodity_amount", "1");
        res = perform(map, "/CreateOrder");
        assertEquals("success", res);

        //同一用户再次创建订单
        map.clear();
        map.put("commodity_id", "43");
        map.put("user_id", "2");
        map.put("pay_time", "2022-08-29 11:15");
        map.put("commodity_amount", "1");
        res = perform(map, "/CreateOrder");
        assertEquals("success", res);

        //成功取消一笔订单
        List<Order> order = orderDao.getAllUserOrders(2);
        Order o = order.get(0);
        int oid = o.getOrder_id();
        map.clear();
        map.put("order_id", String.valueOf(oid));
        res = perform(map, "/drawbackOrder");
        assertEquals("true", res);

        //试图取消一笔不存在订单
        map.clear();
        map.put("order_id", String.valueOf(99999));
        res = perform(map, "/drawbackOrder");
        assertEquals("false", res);
    }

    @Test
    void test05() throws Exception {  //秒杀功能函数测试
        //处理所有秒杀项
        map.clear();
        perform(map, "/HandleMiao");

        //在service层处理秒杀订单
        miaoService.settleOrders(48);
        int inventory = commodityDao.getCommodityByCommodity_id(48).getInventory();
        assertEquals(0, inventory);

        //定时执行函数的测试
        old_head = userDao.findByUser_id(137).getBalance();
        old_cus = userDao.findByUser_id(138).getBalance();
        Trigger trigger = TriggerBuilder.newTrigger()
                .startNow().build();
        String sdf = "59 56 08 13 07 ? 2032";
        TriggerKey triggerKey = TriggerKey.triggerKey(sdf, sdf);
        scheduler.rescheduleJob(triggerKey, trigger);
        System.out.println("can start");
        scheduler.start();
        Thread.sleep(1000);
    }

    @Test
    void test06() {  //秒杀的后续测试
        //判断用户余额是否正确修改
        int new_head = userDao.findByUser_id(137).getBalance();
        int new_cus = userDao.findByUser_id(138).getBalance();
        assertEquals(new_head + 1000000, old_head);
        assertEquals(new_cus - 1000000, old_cus);
    }

}
