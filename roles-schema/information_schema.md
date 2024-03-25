# information_schema

## information_schema.information_schema_catalog_name


Выводит текущую базу данных:

```commandline
ddss=# select * from information_schema.information_schema_catalog_name;
 catalog_name 
--------------
 ddss
(1 row)
```

## information_schema.administrable_role_authorizations

Описывает все роли, для которых текущий пользователь является администратором.

```commandline
ddss=# select * from information_schema.administrable_role_authorizations;
 grantee | role_name | is_grantable 
---------+-----------+--------------
(0 rows)
```

## information_schema.applicable_roles

Цепочка ролей от текущего пользователя к целевой

```commandline
ddss=# select * from information_schema.applicable_roles;
  grantee   |      role_name       | is_grantable 
------------+----------------------+--------------
 indianmax  | pg_database_owner    | NO
 pg_monitor | pg_read_all_settings | NO
 pg_monitor | pg_read_all_stats    | NO
 pg_monitor | pg_stat_scan_tables  | NO
(4 rows)
```

## information_schema.check_constraints

Показывает все ограничения-проверки, либо определённые для таблицы или домена, либо принадлежащие текущей активной роли.

Ниже: имя схемы, выражение проверки
```commandline
ddss=# select constraint_schema, check_clause from information_schema.check_constraints where constraint_schema='public';
 constraint_schema |    check_clause    
-------------------+--------------------
 public            | id IS NOT NULL
 public            | id IS NOT NULL
 public            | id IS NOT NULL
 public            | id IS NOT NULL
 public            | id IS NOT NULL
 public            | number IS NOT NULL
(6 rows)
```

## information_schema.columns

Содержит информацию обо всех столбцах таблиц (или столбцах представлений) в базе данных.

```commandline
ddss=# select table_name, column_name, data_type from information_schema.columns where table_name='graph';
 table_name |  column_name  | data_type 
------------+---------------+-----------
 graph      | id            | integer
 graph      | sch_un_id_num | integer
 graph      | info          | text
(3 rows)
```

## information_schema.enabled_roles

Описывает «доступные роли».

```commandline
ddss=# select * from information_schema.enabled_roles;
         role_name         
---------------------------
 pg_database_owner
 pg_read_all_data
 pg_write_all_data
 pg_monitor
 pg_read_all_settings
 pg_read_all_stats
 pg_stat_scan_tables
 pg_read_server_files
 pg_write_server_files
 pg_execute_server_program
 pg_signal_backend
 pg_checkpoint
 postgres
 indianmax
(14 rows)
```

## information_schema.parameters

Содержит информацию о параметрах (аргументах) всех функций в текущей базе данных.

Ниже: специфичное имя (не название функции), позиция параметра, имя параметра
```commandline
ddss=# select specific_name, ordinal_position, parameter_name from information_schema.parameters;
                       specific_name                       | ordinal_position |        parameter_name         
-----------------------------------------------------------+------------------+-------------------------------
 boolin_1242                                               |                1 | 
 boolout_1243                                              |                1 | 
 byteain_1244                                              |                1 | 
```

## information_schema.sequences

Показывает все последовательности, определённые в текущей базе данных.

```commandline
ddss=# select sequence_name, data_type, start_value from information_schema.sequences;
   sequence_name   | data_type | start_value 
-------------------+-----------+-------------
 student_id_seq    | integer   | 1
 teacher_id_seq    | integer   | 1
 school_id_seq     | integer   | 1
 university_id_seq | integer   | 1
 graph_id_seq      | integer   | 1
(5 rows)
```

## information_schema.tables

Показывает все таблицы и представления, определённые в текущей базе данных.

```commandline
ddss=# select table_schema, table_name, table_type  from information_schema.tables;
    table_schema    |              table_name               | table_type 
--------------------+---------------------------------------+------------
 public             | link                                  | BASE TABLE
 public             | student                               | BASE TABLE
 public             | teacher                               | BASE TABLE
 pg_catalog         | pg_statistic                          | BASE TABLE
 pg_catalog         | pg_type                               | BASE TABLE
 public             | school                                | BASE TABLE
 pg_catalog         | pg_foreign_table                      | BASE TABLE
 pg_catalog         | pg_authid                             | BASE TABLE
 public             | university                            | BASE TABLE
 pg_catalog         | pg_shadow                             | VIEW
```

## information_schema.triggers

Ниже: имя бд, имя схемы, имя триггера, событие (INSERT, UPDATE, DELETE)
```commandline
ddss=# select trigger_catalog, trigger_schema, trigger_name, event_manipulation  from information_schema.triggers;
 trigger_catalog | trigger_schema | trigger_name | event_manipulation 
-----------------+----------------+--------------+--------------------
(0 rows)
```

## information_schema.views

Показывает все представления, определённые в текущей базе данных.

Ниже: имя бд, имя схемы, имя представления
```commandline
ddss=# select table_catalog, table_schema, table_name from information_schema.views;
 table_catalog |    table_schema    |              table_name               
---------------+--------------------+---------------------------------------
 ddss          | pg_catalog         | pg_shadow
 ddss          | pg_catalog         | pg_roles
 ddss          | pg_catalog         | pg_settings
 ddss          | pg_catalog         | pg_file_settings
 ddss          | pg_catalog         | pg_hba_file_rules
 ddss          | pg_catalog         | pg_ident_file_mappings
 ddss          | pg_catalog         | pg_config
```
