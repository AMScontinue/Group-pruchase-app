package com.example.grouppurchase_backend.ServiceImpl;

import com.example.grouppurchase_backend.Controller.MiaoController;
import com.example.grouppurchase_backend.Dao.CommodityDao;
import com.example.grouppurchase_backend.Dao.GroupDao;
import com.example.grouppurchase_backend.Dao.MiaoDao;
import com.example.grouppurchase_backend.Dao.OrderDao;
import com.example.grouppurchase_backend.Entity.Commodity;
import com.example.grouppurchase_backend.Entity.Group;
import com.example.grouppurchase_backend.Entity.Order;
import com.example.grouppurchase_backend.Service.MiaoService;
import org.quartz.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import static com.example.grouppurchase_backend.GroupPurchaseBackendApplication.scheduler;

@Service
@Component
@DisallowConcurrentExecution
public class MiaoServiceImpl implements MiaoService {
    @Autowired
    MiaoDao miaoDao;
    @Autowired
    CommodityDao commodityDao;
    @Autowired
    OrderDao orderDao;
    @Autowired
    GroupDao groupDao;

    @Override
    public void settleOrders(int c_id) {
        Commodity curCommodity = commodityDao.getCommodityByCommodity_id(c_id);
        System.out.println("cid:   "+curCommodity.getCommodity_id());
        List<Order> all = orderDao.getAllCommodityOrders(c_id);
        int groupid = curCommodity.getGroup().getGroup_id();
        System.out.println("service=" + c_id);
        miaoDao.settleOrders(all, curCommodity, groupid);
    }

    @Override
    public void addMiaoJob(int gid) throws ParseException, SchedulerException {
        Group g = groupDao.getGroupByGroup_id(gid);
        String end = g.getEnd_time() + ":59";    //年月日时分秒
        System.out.println(end);
        String name = String.valueOf(gid);    //用团购id作为job的名字与组别
        SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date date = sf.parse(end);    //先解析出结束时间
        SimpleDateFormat sdf = new SimpleDateFormat("ss mm HH dd MM ? yyyy");
        String format = sdf.format(date);    //再转为cron所需格式
        List<String> triggers = scheduler.getTriggerGroupNames();
        List<String> jobs = scheduler.getJobGroupNames();
        for (int i = 0; i < triggers.size(); i++) {
            String s = triggers.get(i);
            //若遇到相同时间的Trigger，需要合并组的id，避免重复触发
            if (s.equals(format)) {
                for (int j = 0; j < jobs.size(); j++) {
                    String ss = jobs.get(j);
                    String[] jj = ss.split(",");
                    for (String part : jj)     //若该组已经存在，直接返回
                        if (part.equals(name))
                            return;
                    int gid_ = Integer.parseInt(jj[0]);
                    Group g_ = groupDao.getGroupByGroup_id(gid_);
                    String end_ = g_.getEnd_time()+":59";
                    Date date_ = sf.parse(end_);
                    String format_ = sdf.format(date_);
                    if (s.equals(format_)) {
                        scheduler.deleteJob(JobKey.jobKey(ss, ss));
                        ss += "," + name;
                        JobDetail job = JobBuilder.newJob(MiaoController.class).withIdentity(ss, ss).build();
                        Trigger trigger = TriggerBuilder.newTrigger().withIdentity(format, format)
                                .withSchedule(CronScheduleBuilder.cronSchedule(format)).build();
                        scheduler.scheduleJob(job, trigger);
                        scheduler.start();
                        System.out.println("add:");
                        List<String> ssss = scheduler.getJobGroupNames();
                        List<String> hh = scheduler.getTriggerGroupNames();
                        System.out.println(ssss);
                        System.out.println(hh);
                        for (int ii = 0; ii < ssss.size(); ii++) {
                            String[] str = ssss.get(ii).split(",");
                            int gid0 = Integer.parseInt(str[0]);
                            Group g0 = groupDao.getGroupByGroup_id(gid0);
                            String end0 = g0.getEnd_time()+":59";
                            Date date0 = sf.parse(end0);
                            String format0 = sdf.format(date0);
                            Trigger t = scheduler.getTrigger(TriggerKey.triggerKey(format0, format0));
                            System.out.println(ssss.get(ii) + "->" + t.getNextFireTime().toString());
                        }
                        return;
                    }
                }
            }
        }
        //创建一个JobDetail实例，将该实例与主类绑定
        JobDetail job0 = JobBuilder.newJob(MiaoController.class).withIdentity(name, name).build();
        //创建一个Trigger实例
        Trigger trigger0 = TriggerBuilder.newTrigger().withIdentity(format, format)
                .withSchedule(CronScheduleBuilder.cronSchedule(format)).build();
        //创建一个Scheduler实例
        scheduler.scheduleJob(job0, trigger0);    //将job加入到容器中
        scheduler.start();
        System.out.println("add:");
        List<String> s = scheduler.getJobGroupNames();
        List<String> hh = scheduler.getTriggerGroupNames();
        System.out.println(s);
        System.out.println(hh);
        for (int i = 0; i < s.size(); i++) {
            String[] str = s.get(i).split(",");
            int gid0 = Integer.parseInt(str[0]);
            Group g0 = groupDao.getGroupByGroup_id(gid0);
            String end0 = g0.getEnd_time()+":59";
            System.out.println(end0);
            Date date0 = sf.parse(end0);
            String format0 = sdf.format(date0);
            System.out.println(format0);
            Trigger t = scheduler.getTrigger(TriggerKey.triggerKey(format0, format0));
            System.out.println(s.get(i) + "->" + t.getNextFireTime().toString());
        }
    }

    @Override
    public void deleteMiaoJob(int gid) throws SchedulerException, ParseException {
        System.out.println("begin delete");
        SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        SimpleDateFormat sdf = new SimpleDateFormat("ss mm HH dd MM ? yyyy");
        String name = String.valueOf(gid);
        List<String> triggers = scheduler.getTriggerGroupNames();
        List<String> jobs = scheduler.getJobGroupNames();
        for (int i = 0; i < jobs.size(); i++) {
            String one = jobs.get(i);
            String[] cut = one.split(",");
            if (cut.length > 1) {
                for (int j = 0; j < cut.length; j++) {
                    String s = cut[j];
                    if (s.equals(name)) {
                        int gid_ = Integer.parseInt(s);
                        Group g_ = groupDao.getGroupByGroup_id(gid_);
                        String end_ = g_.getEnd_time()+":59";
                        Date date_ = sf.parse(end_);
                        String n = sdf.format(date_);    //获取结束时间
                        scheduler.deleteJob(JobKey.jobKey(one, one));
                        int len = s.length();
                        int length = one.length();
                        String NEW;
                        if (j == 0) {
                            NEW = one.substring(len + 1, length);
                            System.out.println("0    "+NEW);
                        } else if (j == cut.length - 1) {
                            NEW = one.substring(0, length - len - 1);
                            System.out.println("max    "+NEW);
                        } else {
                            String old = "," + s + ",";
                            String newer = ",";
                            NEW = one.replaceAll(old, newer);
                            System.out.println("other    "+NEW);
                        }
                        System.out.println(NEW);
                        JobDetail job = JobBuilder.newJob(MiaoController.class).withIdentity(NEW, NEW).build();
                        Trigger t = TriggerBuilder.newTrigger().withIdentity(n, n)
                                .withSchedule(CronScheduleBuilder.cronSchedule(n)).build();
                        scheduler.scheduleJob(job, t);
                        scheduler.start();
                        System.out.println("delete:");
                        List<String> sss = scheduler.getJobGroupNames();
                        List<String> hh = scheduler.getTriggerGroupNames();
                        System.out.println(s);
                        System.out.println(hh);
                        for (int ii = 0; ii < sss.size(); ii++) {
                            String[] str = sss.get(ii).split(",");
                            int gid0 = Integer.parseInt(str[0]);
                            Group g0 = groupDao.getGroupByGroup_id(gid0);
                            String end0 = g0.getEnd_time()+":59";
                            Date date0 = sf.parse(end0);
                            String format0 = sdf.format(date0);
                            Trigger ttt = scheduler.getTrigger(TriggerKey.triggerKey(format0, format0));
                            System.out.println(sss.get(ii) + "->" + ttt.getNextFireTime().toString());
                        }
                        return;
                    }
                }
            }
        }
        scheduler.deleteJob(JobKey.jobKey(name, name));
        scheduler.start();
    }
}
