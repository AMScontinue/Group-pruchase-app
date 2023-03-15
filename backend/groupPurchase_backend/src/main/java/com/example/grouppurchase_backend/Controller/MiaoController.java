package com.example.grouppurchase_backend.Controller;

import com.example.grouppurchase_backend.Dao.CommodityDao;
import com.example.grouppurchase_backend.Dao.GroupDao;
import com.example.grouppurchase_backend.Dao.UserDao;
import com.example.grouppurchase_backend.Entity.Commodity;
import com.example.grouppurchase_backend.Entity.Group;
import com.example.grouppurchase_backend.Service.MiaoService;
import com.example.grouppurchase_backend.SpringContextUtils;
import lombok.SneakyThrows;
import org.quartz.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.support.SpringBeanAutowiringSupport;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import static com.example.grouppurchase_backend.GroupPurchaseBackendApplication.scheduler;

@Controller
@RestController
@Component
@DisallowConcurrentExecution
public class MiaoController implements Job {
    @Autowired
    private GroupDao groupDao;
    @Autowired
    private MiaoService miaoService;
    @Autowired
    private CommodityDao commodityDao;
    @Autowired
    private UserDao userDao;

    @SneakyThrows
    @Override
    public void execute(JobExecutionContext jobExecutionContext) {    //团购结束时处理秒杀订单
        System.out.println("begin execute");
        SpringBeanAutowiringSupport.processInjectionBasedOnCurrentContext(this);
        List<String> list = scheduler.getJobGroupNames();
        System.out.println(list);
        miaoService = SpringContextUtils.getBean(MiaoService.class);
        commodityDao = SpringContextUtils.getBean(CommodityDao.class);
        JobDetail jd = jobExecutionContext.getJobDetail();
        JobKey jk = jd.getKey();
        String name = jk.getName();
        String[] cut = name.split(",");
        for (String s : cut) {
            int gid = Integer.parseInt(s);
            System.out.println(gid+"---");
            List<Commodity> all = commodityDao.getCommoditiesByGroup_id(gid);
            for (int i = 0; i < all.size(); i++) {
                Commodity c = all.get(i);
                if (c.isMiao()) {
                    int cid = c.getCommodity_id();
                    miaoService.settleOrders(cid);
                }
            }
        }
    }

    public String time2String(String paytime) {
        String[] b = paytime.split("-");
        String[] bb = b[2].split(" ");
        String[] bbb = bb[1].split(":");
        return (b[0] + b[1] + bb[0] + bbb[0] + bbb[1]);
    }

    @RequestMapping("/HandleMiao")
    @ResponseBody
    public void handleMiao() throws SchedulerException, ParseException {
        //userDao.allEncode();
        scheduler.clear();
        List<Group> all = groupDao.getAllGroups();
        Date date = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmm");
        String now = sdf.format(date);
        for (int i = 0; i < all.size(); i++) {
            Group g = all.get(i);
            String end = time2String(g.getEnd_time());
            if (now.compareTo(end) < 0) {
                int gid = g.getGroup_id();
                miaoService.addMiaoJob(gid);
            }
        }
    }

}
