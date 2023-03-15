package com.example.grouppurchase_backend.Dao;

import com.example.grouppurchase_backend.Entity.Commodity;
import com.example.grouppurchase_backend.Entity.Order;

import java.util.List;

public interface MiaoDao {
    void settleOrders(List<Order> all, Commodity commodity, int groupid);
}
