---
id: 781
title: 'How-To : Configure MySQL Metastore for Hive ?'
date: '2015-01-06T23:16:44-07:00'
author: saurzcode

guid: 'https://saurzcode.in//?p=781'
permalink: /2015/01/configure-mysql-metastore-hive/
meta-checkbox:
    - ''
dsq_thread_id:
    - '3490650038'
categories:
    - 'Big Data'
    - Hive
    - Java
    - Technology
tags:
    - bigdata
    - datawarehouse
    - hadoop
    - hive
    - metastore
    - mysql
---

# How to Configure MySQL Metastore for Hive

Hive by default comes with Derby as its metastore storage, which is suited only for testing purposes and in most of the production scenarios it is recommended to use MySQL as a metastore. This is a step by step guide on How to Configure MySQL Metastore for Hive in place of Derby Metastore (Default).

**Assumptions:** Basic knowledge of Unix is assumed and also It's assumed that Hadoop and Hive configurations are in place. Hive with default metastore Derby is properly configured and tested out.

1. Install MySQL:

```sh
$ sudo apt-get install mysql-server
```

**Note**: You will be prompted to set a password for root.

2. Install the MySQL Java Connector:

```sh
$ sudo apt-get install libmysql-java
```

3. Create soft link for connector in Hive lib directory or copy connector jar to lib folder:

```sh
ln -s /usr/share/java/mysql-connector-java.jar $HIVE_HOME/lib/mysql-connector-java.jar
```

**Note**: HIVE_HOME points to installed hive folder.

4. Create the Initial database schema using the **hive-schema-0.14.0.mysql.sql** file (or the file corresponding to your installed version of Hive) located in the **$HIVE_HOME/scripts/metastore/upgrade/mysql** directory.

```mysql
$ mysql -u root -p

Enter password:

mysql> CREATE DATABASE metastore;

mysql> USE metastore;

mysql> SOURCE $HIVE_HOME/scripts/metastore/upgrade/mysql/hive-schema-0.14.0.mysql.sql;
```

5. You also need a MySQL user account for Hive to use to access the metastore. It is very important to prevent this user account from creating or altering tables in the metastore database schema.

```mysql
mysql> CREATE USER 'hiveuser'@'%' IDENTIFIED BY 'hivepassword'; 

mysql> GRANT all on *.* to 'hiveuser'@localhost identified by 'hivepassword';

mysql> flush privileges;
```

**Note**: hiveuser is the ConnectionUserName in hive-site.xml (As explained next)

6. Create hive-site.xml (If not already present) in $HIVE_HOME/conf folder with the configuration below:

```xml
<configuration>
   <property>
      <name>javax.jdo.option.ConnectionURL</name>
      <value>jdbc:mysql://localhost/metastore?createDatabaseIfNotExist=true</value>
      <description>metadata is stored in a MySQL server</description>
   </property>
   <property>
      <name>javax.jdo.option.ConnectionDriverName</name>
      <value>com.mysql.jdbc.Driver</value>
      <description>MySQL JDBC driver class</description>
   </property>
   <property>
      <name>javax.jdo.option.ConnectionUserName</name>
      <value>hiveuser</value>
      <description>user name for connecting to mysql server</description>
   </property>
   <property>
      <name>javax.jdo.option.ConnectionPassword</name>
      <value>hivepassword</value>
      <description>password for connecting to mysql server</description>
   </property>
</configuration>
```

7. We are all set now. Start the hive console.

**Note**: If you are seeing any error related to Driver "com.mysql.jdbc.Driver" not found, Please make sure you have copied the mysql-java connector jar properly to Hive lib folder or created a soft link for the same.

If you have reached this far, without any errors, you can continue reading else, Go back to step 1 and see what you missed :)

Now we'll test through hive console and mysql console if our Hive Metastore using MySQL is configured properly.

__Hive console:__

Let's create a table in Hive.

```sh
hive> create table saurzcode(id int, name string);
```

And see if we can see it's metadata stored in MySQL.

__MySql console:__

```mysql
mysql -u root -p

Enter password:                                                             
mysql> use metastore;                                                                                              
mysql> show tables;
```

You can query the metastore schema in your MySQL database. Something like:

```mysql
mysql> select * from TBLS;
```

On your MySQL database you will see the names of your Hive tables.

That's It!! You are all set to use MySQL as a metastore in Hive.

Happy Learning!!

## References:

[1] [Cloudera MySQL Metastore Guide](http://www.cloudera.com/content/cloudera/en/documentation/cdh4/v4-2-0/CDH4-Installation-Guide/cdh4ig_topic_18_4.html)

## More Interesting Articles:

[Spark Dataframe Operations](https://saurzcode.in/2018/06/spark-common-dataframe-operations/)
