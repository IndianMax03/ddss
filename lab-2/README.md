# Ход работы

## Инициализация кластера БД

Просмотрим переменные окружения:

```bash
[postgres0@pg103 ~]$ printenv
SHELL=/usr/local/bin/bash
PWD=/var/db/postgres0
LOGNAME=postgres0
HOME=/var/db/postgres0
LANG=ru_RU.UTF-8
SSH_CONNECTION=XXXXXXXXX
TERM=xterm-256color
USER=postgres0
SHLVL=1
MM_CHARSET=UTF-8
SSH_CLIENT=XXXXXXXXX
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/var/db/postgres0/bin
BLOCKSIZE=K
MAIL=/var/mail/postgres0
SSH_TTY=/dev/pts/32
_=/usr/bin/printenv
```

Создадим файл профиля, чтобы не задавать переменные окружения при каждом входе:

```bash
[postgres0@pg103 ~]$ touch ~/.profile
```

Отредактируем его согласно условиям:

Убедимся в наличии тербуемой кодировки и локали:

```bash
[postgres0@pg103 ~]$ locale -a | grep "ru_RU.ISO"
ru_RU.ISO8859-5
```

```text
~/.profile:
export PGHOST=pg103
export PGUSERNAME=postgres0
export PGDATA=$HOME/u01/wip97
export PGENCODING=ISO8859-5
export PGLOCALE=ru_RU.ISO8859-5
```

Переподключимся и проверим:

```commandline
[postgres0@pg103 ~]$ printenv | sort | grep "PG"
PGDATA=/var/db/postgres0/u01/wip97
PGENCODING=ISO8859-5
PGHOST=pg103
PGLOCALE=ru_RU.ISO8859-5
PGUSERNAME=postgres0
```

Создадим директорию для кластера:

```commandline
[postgres0@pg103 ~]$ mkdir -p $PGDATA
[postgres0@pg103 ~]$ ls -Rl
total 1
drwxr-xr-x  3 postgres0  postgres  3 17 марта 18:50 u01

./u01:
total 1
drwxr-xr-x  2 postgres0  postgres  2 17 марта 18:50 wip97

./u01/wip97:
total 0
```

Создадим кластер PostgreSQL БД:

Интересующие ключи:

- `--encoding=encoding` -- кодировка для template БД (по умолчанию наследуется от предыдущих создаваемых БД. в противном случае используется локаль или `SQL_ASCII`, если не получается подтянуть локаль)
- `--pgdata=directory` -- директория для хранения кластера (нет необходимости устанавливать, если есть переменная окружения `PGDATA`)
- `--locale=locale` -- устанавливает локаль кластера БД. Если не установлено, локаль берется из среды, в которой была запущена initdb
- `--username=username` -- superuser для БД. По умолчанию берется имя юзера, который запустил initdb

```commandline
[postgres0@pg103 ~]$ initdb --encoding=$PGENCODING --locale=$PGLOCALE --username=$PGUSERNAME
Файлы, относящиеся к этой СУБД, будут принадлежать пользователю "postgres0".
От его имени также будет запускаться процесс сервера.

Кластер баз данных будет инициализирован с локалью "ru_RU.ISO8859-5".
Выбрана конфигурация текстового поиска по умолчанию "russian".

Контроль целостности страниц данных отключён.

исправление прав для существующего каталога /var/db/postgres0/u01/wip97... ок
создание подкаталогов... ок
выбирается реализация динамической разделяемой памяти... posix
выбирается значение max_connections по умолчанию... 100
выбирается значение shared_buffers по умолчанию... 128MB
выбирается часовой пояс по умолчанию... W-SU
создание конфигурационных файлов... ок
выполняется подготовительный скрипт... ок
выполняется заключительная инициализация... ок
сохранение данных на диске... ок

initdb: предупреждение: включение метода аутентификации "trust" для локальных подключений
Другой метод можно выбрать, отредактировав pg_hba.conf или используя ключи -A,
--auth-local или --auth-host при следующем выполнении initdb.

Готово. Теперь вы можете запустить сервер баз данных:

    pg_ctl -D /var/db/postgres0/u01/wip97 -l файл_журнала start
```

Запуск сервера:

```commandline
[postgres0@pg103 ~]$ pg_ctl -D $PGDATA -l logs start
ожидание запуска сервера.... готово
сервер запущен
[postgres0@pg103 ~]$ pg_ctl status -D $PGDATA
pg_ctl: сервер работает (PID: 40954)
/usr/local/bin/postgres "-D" "/var/db/postgres0/u01/wip97"
[postgres0@pg103 ~]$ pg_ctl stop -D $PGDATA
ожидание завершения работы сервера.... готово
сервер остановлен
[postgres0@pg103 ~]$ pg_ctl status -D $PGDATA
pg_ctl: сервер не работает
```


## Конфигурация и запуск сервера БД

Установим способ аутентификации клиентов — по паролю в открытом виде. Разрешим подключения к БД — TCP/IP socket, номер порта 9004. Остальные способы подключений запретим.

Установка TCP порта сервера:

```text
postgresql.conf:
listen_addresses = 'X.X.X.X'     # what IP address(es) to listen on;
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
                                        # (change requires restart)
port = 9004                             # (change requires restart)
max_connections = 300                   # (change requires restart)
```

Предварительно установим пароль для суперпользователя:

```commandline
[postgres0@pg103 ~]$ psql -p 9004 -d postgres
psql (14.2)
Введите "help", чтобы получить справку.

postgres=# \l
                                        Список баз данных
    Имя    | Владелец  | Кодировка  |   LC_COLLATE    |    LC_CTYPE     |      Права доступа      
-----------+-----------+------------+-----------------+-----------------+-------------------------
 postgres  | postgres0 | ISO_8859_5 | ru_RU.ISO8859-5 | ru_RU.ISO8859-5 | 
 template0 | postgres0 | ISO_8859_5 | ru_RU.ISO8859-5 | ru_RU.ISO8859-5 | =c/postgres0           +
           |           |            |                 |                 | postgres0=CTc/postgres0
 template1 | postgres0 | ISO_8859_5 | ru_RU.ISO8859-5 | ru_RU.ISO8859-5 | =c/postgres0           +
           |           |            |                 |                 | postgres0=CTc/postgres0
(3 строки)

postgres=# \password postgres0
Введите новый пароль для пользователя "postgres0": 
Повторите его:
```

По паролю в явном виде, остальные запретить:

```text
pg_hba.conf:
# TYPE  DATABASE        USER            ADDRESS                 METHOD

host    all             all             all                    password
# "local" is for Unix domain socket connections only
local   all             all                                    reject
# IPv4 local connections:
host    all             all             127.0.0.1/32           reject
# IPv6 local connections:
host    all             all             ::1/128                reject
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                    reject
host    replication     all             127.0.0.1/32           reject
```

Обоснованно установим параметры сервера БД в соответствии с аппаратной конфигурацией: оперативная память 16 ГБ, хранение на SSD:

- `max_connections`=300, с расчетом на то, что в среднем одно активное соединение потребляет порядка 5-10MB. В самое активное время при умеренной сложности запросов будет занято не более ~3GB;
- `shared_buffers`=3GB, что составляет ~18.75% от общего числа доступного пространства. Выбор был сделан в связи с тем, что используются шустренькие SSD;
- `temp_buffers`=8MB, было принято оставить значение по умолчанию, чего должно быть вполне достаточно для типичных операций
- `work_mem`=2GB, что составляет ~12.5% от общего объема, чтобы избежать перегрузки, но при этом сохранить производительность
- `checkpoint_timeout`=20min, что характерно для SSD
- `effective_cache_size`=6GB, что составляет чуть меньше половины от всей оперативной памяти (3/8)
- `fsync`=on, для гарантии надежности и целостности данных
- `commit_delay`=1000, (микросекунд) для SSD, потому что накладные расходы на запись меньще, чем hdd, например.

```text
postgresql.conf:
...
max_connections = 300                   # (change requires restart)
...
shared_buffers = 3GB                    # min 128kB
...
temp_buffers = 8MB                      # min 800kB
...
work_mem = 2GB                          # min 64kB
...
checkpoint_timeout = 20min              # range 30s-1d
...
effective_cache_size = 6GB
...
fsync = on                              # the default is the first option
...
commit_delay = 1000                     # range 0-100000, in microseconds
```

Установка директории WAL файлов:
```text
postgresql.conf:
# - Archiving -

archive_mode = on                                       # enables archiving; off, on, or always
                                                        # (change requires restart)
archive_command = 'cp %p $HOME/u02/wip97/%f'            # command to use to archive a logfile segment
                                                        # placeholders: %p = path of file to archive
                                                        #               %f = file name only
                                                        # e.g. 'test ! -f /mnt/server/archivedir/%f && cp %p /mnt/server/archivedir/%f'
```

Установка формата лог-файлов `log`, уровень сообщений лога — `ERROR`, будем дополнительно логировать контрольные точки и попытки подключения:

Формат файлов:

```text
postgresql.conf:
#------------------------------------------------------------------------------
# REPORTING AND LOGGING
#------------------------------------------------------------------------------

# - Where to Log -

#log_destination = 'syslog'
log_destination = 'stderr'              # Valid values are combinations of
                                        # stderr, csvlog, syslog, and eventlog,
                                        # depending on platform.  csvlog
                                        # requires logging_collector to be on.

# This is used when logging to stderr:
logging_collector = on                  # Enable capturing of stderr and csvlog
                                        # into log files. Required to be on for
                                        # csvlogs.
                                        # (change requires restart)

# These are only used if logging_collector is on:
log_directory = 'log'                   # directory where log files are written,
                                        # can be absolute or relative to PGDATA
```

Уровень сообщений:

```text
postgresql.conf:
# - When to Log -

log_min_messages = error                # values in order of decreasing detail:
                                        #   debug5
                                        #   debug4
                                        #   debug3
                                        #   debug2
                                        #   debug1
                                        #   info
                                        #   notice
                                        #   warning
                                        #   error
                                        #   log
                                        #   fatal
                                        #   panic
```

Контрольные точки и попытки подключения

```text
postgresql.conf:
log_checkpoints = on
log_connections = on
```

## Дополнительные табличные пространства и наполнения

```commandline
[postgres0@pg103 ~]$ mkdir -p $HOME/u03/wip97
[postgres0@pg103 ~]$ mkdir -p $HOME/u04/wip97
```

```sql
postgres=# CREATE TABLESPACE tmp1 LOCATION '/var/db/postgres0/u03/wip97';
CREATE TABLESPACE
postgres=# CREATE TABLESPACE tmp2 LOCATION '/var/db/postgres0/u04/wip97';
CREATE TABLESPACE
postgres=# \db
             Список табличных пространств
    Имя     | Владелец  |        Расположение         
------------+-----------+-----------------------------
 pg_default | postgres0 | 
 pg_global  | postgres0 | 
 tmp1       | postgres0 | /var/db/postgres0/u03/wip97
 tmp2       | postgres0 | /var/db/postgres0/u04/wip97
(4 строки)
```

Определим временные табличные пространства для всех постоянных сессий:

```text
postgresql.conf:
temp_tablespaces = 'tmp1, tmp2'         # a list of tablespace names, '' uses
                                        # only default tablespace
```

Для применения опции выполним:

```sql
postgres=# SELECT pg_reload_conf();
 pg_reload_conf 
----------------
 t
(1 строка)
```

Убедимся в том, что временные табличные пространства установлены:

```sql
postgres=# SHOW temp_tablespaces;
 temp_tablespaces 
------------------
 tmp1, tmp2
(1 строка)
```

На основании `template0` создадим базу данных `crazyprog`

```sql
postgres=# CREATE DATABASE crazyprog WITH TEMPLATE=template0;
CREATE DATABASE
```

Создадим таблицы фильмов и отзывов к фильмам:

```sql
crazyprog=# CREATE TABLE films(
    id serial PRIMARY KEY,
    name text,
    description text
);
CREATE TABLE
crazyprog=# CREATE TABLE reviews(
    id serial PRIMARY KEY,
    film_id integer REFERENCES films(id),
    post text,
    rating integer
);
CREATE TABLE
```

Создадим новую роль:

```sql
crazyprog=# create role max login password 'XXX';
CREATE ROLE
```

Попробуем подключиться и прочитать данные какой-либо таблицы:

```sql
[postgres0@pg103 ~]$ psql -p 9004 -d crazyprog -U max
Пароль пользователя max: 
psql (14.2)
Введите "help", чтобы получить справку.

crazyprog=> select * from films;
ОШИБКА:  нет доступа к таблице films
```

Выдадим права на вставку и использование sequence'ов для новой роли:

```sql
crazyprog=# grant insert on films to max;
GRANT
crazyprog=# grant insert on reviews to max;
GRANT
crazyprog=# grant usage, select on sequence films_id_seq to max;
GRANT
crazyprog=# grant usage, select on sequence reviews_id_seq to max;
GRANT
```

Попробуем выполнить пару вставок:

```sql
crazyprog=> insert into films values (nextval('films_id_seq'), 'человек паук', 'фильм про человека паука в скафандре');
insert into reviews values (nextval('reviews_id_seq'), currval('films_id_seq'), 'прекрасный фильм мне очень даже понравился скофандор', 5);
insert into reviews values (nextval('reviews_id_seq'), currval('films_id_seq'), 'блин мне очень не понравился скофандор', 3);

insert into films values (nextval('films_id_seq'), 'бедмен', 'фильм про бедмена в бидоне');
insert into reviews values (nextval('reviews_id_seq'), currval('films_id_seq'), 'бидоны улет!', 5);
insert into reviews values (nextval('reviews_id_seq'), currval('films_id_seq'), 'мама не разрешила сходить', 1);
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
```

Ничего больше с таблицой сделать нельзя:

```sql
crazyprog=> delete from films;
ОШИБКА:  нет доступа к таблице films
crazyprog=> select * from films;
ОШИБКА:  нет доступа к таблице films
```
Но суперпользователь может:

```sql
[postgres0@pg103 ~]$ psql -p 9004 -d crazyprog
Пароль пользователя postgres0: 
psql (14.2)
Введите "help", чтобы получить справку.

crazyprog=# select * from films;
 id |     name     |             description              
----+--------------+--------------------------------------
  1 | человек паук | фильм про человека паука в скафандре
  2 | бедмен       | фильм про бедмена в бидоне
(2 строки)
```

Представим сценарий: суперпользователь решил просмотреть средний рейтинг фильмов и отзывы от худшего к лучшему.

Он создаст временные таблицы:

```sql
crazyprog=# CREATE TEMPORARY TABLE top_films AS
SELECT f.name AS film_name, AVG(r.rating) AS avg_rating
FROM films f
JOIN reviews r ON f.id = r.film_id
GROUP BY f.id, f.name
ORDER BY avg_rating DESC;
SELECT 2
crazyprog=# CREATE TEMPORARY TABLE bad_reviews AS
SELECT f.name AS film_name, r.post AS review_comment, r.rating AS review_rating
FROM films f
JOIN reviews r ON f.id = r.film_id
ORDER BY r.rating;
SELECT 4
```

Теперь он может ими воспользоваться:

```sql
crazyprog=# SELECT * FROM top_films;
  film_name   |     avg_rating     
--------------+--------------------
 человек паук | 4.0000000000000000
 бедмен       | 3.0000000000000000
(2 строки)

crazyprog=# SELECT * FROM bad_reviews;
  film_name   |                    review_comment                    | review_rating 
--------------+------------------------------------------------------+---------------
 бедмен       | мама не разрешила сходить                            |             1
 человек паук | блин мне очень не понравился скофандор               |             3
 человек паук | прекрасный фильм мне очень даже понравился скофандор |             5
 бедмен       | бидоны улет!                                         |             5
(4 строки)
```

Выведем список всех табличных пространств кластера и содержащиеся
в них объекты

```sql
crazyprog=# SELECT pg_tablespace.spcname AS tablespace_name, 
       pg_class.relname AS object_name
FROM pg_class
JOIN pg_tablespace ON pg_class.reltablespace = pg_tablespace.oid
ORDER BY tablespace_name, object_name;
 tablespace_name |               object_name               
-----------------+-----------------------------------------
 pg_global       | pg_auth_members
 pg_global       | pg_auth_members_member_role_index
 pg_global       | pg_auth_members_role_member_index
 pg_global       | pg_authid
 pg_global       | pg_authid_oid_index
 pg_global       | pg_authid_rolname_index
 pg_global       | pg_database
 pg_global       | pg_database_datname_index
 pg_global       | pg_database_oid_index
 pg_global       | pg_db_role_setting
 pg_global       | pg_db_role_setting_databaseid_rol_index
 pg_global       | pg_replication_origin
 pg_global       | pg_replication_origin_roiident_index
 pg_global       | pg_replication_origin_roname_index
 pg_global       | pg_shdepend
 pg_global       | pg_shdepend_depender_index
 pg_global       | pg_shdepend_reference_index
 pg_global       | pg_shdescription
 pg_global       | pg_shdescription_o_c_index
 pg_global       | pg_shseclabel
 pg_global       | pg_shseclabel_object_index
 pg_global       | pg_subscription
 pg_global       | pg_subscription_oid_index
 pg_global       | pg_subscription_subname_index
 pg_global       | pg_tablespace
 pg_global       | pg_tablespace_oid_index
 pg_global       | pg_tablespace_spcname_index
 pg_global       | pg_toast_1213
 pg_global       | pg_toast_1213_index
 pg_global       | pg_toast_1260
 pg_global       | pg_toast_1260_index
 pg_global       | pg_toast_1262
 pg_global       | pg_toast_1262_index
 pg_global       | pg_toast_2396
 pg_global       | pg_toast_2396_index
 pg_global       | pg_toast_2964
 pg_global       | pg_toast_2964_index
 pg_global       | pg_toast_3592
 pg_global       | pg_toast_3592_index
 pg_global       | pg_toast_6000
 pg_global       | pg_toast_6000_index
 pg_global       | pg_toast_6100
 pg_global       | pg_toast_6100_index
 tmp1            | bad_reviews
 tmp1            | pg_toast_16769
 tmp1            | pg_toast_16769_index
 tmp1            | pg_toast_16774
 tmp1            | pg_toast_16774_index
 tmp1            | top_films
(49 строк)
```

Для новой сессии временные таблицы пропадут, что позволит сэкономить память, не удерживая данные таблицы в ней, а используя их исключительно временно:

```sql
crazyprog=# \q
[postgres0@pg103 ~]$ psql -p 9004 -d crazyprog -U postgres0
Пароль пользователя postgres0: 
psql (14.2)
Введите "help", чтобы получить справку.

crazyprog=# SELECT pg_tablespace.spcname AS tablespace_name, 
       pg_class.relname AS object_name
FROM pg_class
JOIN pg_tablespace ON pg_class.reltablespace = pg_tablespace.oid
ORDER BY tablespace_name, object_name;
 tablespace_name |               object_name               
-----------------+-----------------------------------------
 pg_global       | pg_auth_members
 pg_global       | pg_auth_members_member_role_index
 pg_global       | pg_auth_members_role_member_index
 pg_global       | pg_authid
 pg_global       | pg_authid_oid_index
 pg_global       | pg_authid_rolname_index
 pg_global       | pg_database
 pg_global       | pg_database_datname_index
 pg_global       | pg_database_oid_index
 pg_global       | pg_db_role_setting
 pg_global       | pg_db_role_setting_databaseid_rol_index
 pg_global       | pg_replication_origin
 pg_global       | pg_replication_origin_roiident_index
 pg_global       | pg_replication_origin_roname_index
 pg_global       | pg_shdepend
 pg_global       | pg_shdepend_depender_index
 pg_global       | pg_shdepend_reference_index
 pg_global       | pg_shdescription
 pg_global       | pg_shdescription_o_c_index
 pg_global       | pg_shseclabel
 pg_global       | pg_shseclabel_object_index
 pg_global       | pg_subscription
 pg_global       | pg_subscription_oid_index
 pg_global       | pg_subscription_subname_index
 pg_global       | pg_tablespace
 pg_global       | pg_tablespace_oid_index
 pg_global       | pg_tablespace_spcname_index
 pg_global       | pg_toast_1213
 pg_global       | pg_toast_1213_index
 pg_global       | pg_toast_1260
 pg_global       | pg_toast_1260_index
 pg_global       | pg_toast_1262
 pg_global       | pg_toast_1262_index
 pg_global       | pg_toast_2396
 pg_global       | pg_toast_2396_index
 pg_global       | pg_toast_2964
 pg_global       | pg_toast_2964_index
 pg_global       | pg_toast_3592
 pg_global       | pg_toast_3592_index
 pg_global       | pg_toast_6000
 pg_global       | pg_toast_6000_index
 pg_global       | pg_toast_6100
 pg_global       | pg_toast_6100_index
(43 строки)
```
