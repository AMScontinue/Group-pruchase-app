create database grouppurchase;
use grouppurchase;
drop table if exists user;
create table user
(
    user_id   int(10) auto_increment,
    username  varchar(50) not null,
    password  varchar(20) not null,
    email     varchar(50) not null,
    image_url varchar(300) default null,
    balance   int(10)     not null,
    primary key (user_id)
) auto_increment = 1;
drop table if exists `group`;
create table `group`(
    group_id int(10)  auto_increment,
    group_name varchar(50) not null ,
    head_id int(10)  ,
    number int(10)  ,
    group_des varchar(2000) default null,
    group_post varchar(50) not null ,
    begin_time varchar(300) not null ,
    end_time varchar(300) not null ,
    follower varchar(2000) default null,
    link varchar(2000) default null,
    primary key (group_id),
    foreign key (head_id) references user (user_id)
) auto_increment = 1;
drop table if exists commodity;
create table commodity
(
    commodity_id   int(10) auto_increment,
    commodity_name varchar(50) not null,
    group_id       int(10)     not null,
    image_url      varchar(300)  DEFAULT NULL,
    description    varchar(2000) DEFAULT NULL,
    price          int(10)     not null,
    inventory      int(10)     not null,
    miao           bool        not null,
    primary key (commodity_id),
    foreign key (group_id) references `group` (group_id)
) auto_increment = 1;

drop table if exists `order`;
create table `order`(
    order_id int(10)  auto_increment,
    group_id int(10)  ,
    commodity_id int(10) ,
    user_id int(10)  ,
    pay_time varchar(300) not null ,
    commodity_amount int(10) not null,
    money int(10) not null ,
    post varchar(50) not null ,
    primary key (order_id),
    foreign key (group_id) references `group` (group_id),
    foreign key (commodity_id) references commodity (commodity_id),
    foreign key (user_id) references user (user_id)
);

insert into user values (
                         null,
                         'chen',
                         '123456',
                         '1@qq.com',
                         'https://img2.woyaogexing.com/2018/07/15/4f9e38fa399a487087af709fcce57132!400x400.jpeg',
                         10000
                        );
insert into user values (
                         null,
                         'c',
                         '123',
                         '2@qq.com',
                         'https://img2.woyaogexing.com/2018/07/15/4f9e38fa399a487087af709fcce57132!400x400.jpeg',
                         10000
                        );
insert into `group` values (
                          null,
                          'chenjiahao',
                          1,
                          10,
                          'chenjiahao',
                          '申通',
                          '2022-07-03 10:01:00',
                          '2022-07-04 10:01:00',
                          '2,',
                          'groupPurhcase://GroupPurhcaseInfo?id=1'
                         );
insert into commodity values (
                              null,
                              'iphone13',
                              1,
                              'http://img3m1.ddimg.cn/82/21/11029465441-1_k_1.jpg',
                              '苹果手机',
                              199999,
                              10,
                              true
                             );
insert into commodity values (
                              null,
                              'airPods3',
                              1,
                              'http://img3m4.ddimg.cn/97/26/11021242714-1_k_2.jpg',
                              '苹果耳机',
                              1370,
                              100,
                              false
                             );
insert into commodity values (
                              null,
                              'ipad',
                              1,
                              'http://img3m4.ddimg.cn/81/27/11016079254-1_k_1.jpg',
                              '苹果平板电脑',
                              2690,
                              96,
                              false
                             );
