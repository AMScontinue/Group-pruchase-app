package com.example.grouppurchase_backend.Service;

import org.quartz.SchedulerException;

import java.text.ParseException;

public interface MiaoService {
    void settleOrders(int c_id);

    void addMiaoJob(int gid) throws ParseException, SchedulerException;
    void deleteMiaoJob(int gid) throws ParseException, SchedulerException;
}
