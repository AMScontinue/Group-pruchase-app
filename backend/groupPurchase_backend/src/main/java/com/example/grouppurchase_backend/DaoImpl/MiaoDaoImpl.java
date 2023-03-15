package com.example.grouppurchase_backend.DaoImpl;

import com.example.grouppurchase_backend.Dao.MiaoDao;
import com.example.grouppurchase_backend.Dao.OrderDao;
import com.example.grouppurchase_backend.Entity.Commodity;
import com.example.grouppurchase_backend.Entity.Group;
import com.example.grouppurchase_backend.Entity.Order;
import com.example.grouppurchase_backend.Entity.User;
import com.example.grouppurchase_backend.Repository.CommodityRepository;
import com.example.grouppurchase_backend.Repository.GroupRepository;
import com.example.grouppurchase_backend.Repository.OrderRepository;
import com.example.grouppurchase_backend.Repository.UserRepository;
import org.quartz.DisallowConcurrentExecution;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Repository;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

@Repository
@Component
@DisallowConcurrentExecution
public class MiaoDaoImpl implements MiaoDao {

    @Autowired
    UserRepository userRepository;
    @Autowired
    GroupRepository groupRepository;
    @Autowired
    CommodityRepository commodityRepository;
    @Autowired
    OrderRepository orderRepository;
    @Autowired
    OrderDao orderDao;

    public String time2String(String paytime) {
        String[] b = paytime.split("-");
        String[] bb = b[2].split(" ");
        String[] bbb = bb[1].split(":");
        return (b[0] + b[1] + bb[0] + bbb[0] + bbb[1]);
    }

    @Override
    public void settleOrders(List<Order> all, Commodity commodity, int groupid) {
        Collections.sort(all, new Comparator<Order>() {
            public int compare(Order o1, Order o2) {
                return time2String(o1.getPay_time()).compareTo(
                        time2String(o2.getPay_time())
                );
            }
        });
        int num = all.size();
        Group curGroup = groupRepository.getGroupByGroup_id(groupid);
        User header = userRepository.findByUser_id(curGroup.getHead());
        int sum = commodity.getInventory();
        for (int i = 0; i < num; i++) {
            Order one = all.get(i);
            if (sum >= one.getCommodity_amount()) //订单秒杀成功，不用退钱
            {
                sum -= one.getCommodity_amount();
            } else { //退钱，删除订单
                int money = one.getMoney();
                int he = header.getBalance();
                header.setBalance(he - money);
                int uid = one.getUser_id();
                User u = userRepository.findByUser_id(uid);
                int cus = u.getBalance();
                u.setBalance(cus + money);
                userRepository.save(u);
                one.setIspaid(0);
                orderRepository.save(one);
            }
        }
        userRepository.save(header);
        commodity.setInventory(sum);
        commodityRepository.save(commodity);
    }
}
