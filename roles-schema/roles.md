### Общая инфа

- `SELECT rolname FROM pg_roles;` -- просмотр существующих ролей
- `\du` -- список созданных ролей
- `CREATE ROLE <name> LOGIN;` == `CREATE USER <name>;` -- создать пользователя (роль) с логином
- `DROP ROLE <name>;`-- удалить роль
- `CREATE ROLE <name> SUPERUSER;` -- создать суперпользователя (обходит все проверки по взаимодействию с бд, кроме права
  на вход в систему)
- `CREATE ROLE <name> CREATEDB;` -- создать роль, которая умеет создавать базы данных
- `CREATE ROLE <name> CREATEROLE;` -- создать роль, которая умеет взаимодействовать с другими ролями (создавать,
  удалять, изменять и выдавать, изменять членство в ролях)
- `CREATE ROLE <name> PASSWORD '<pwd>'` -- создать роль с именем и паролем
- `CREATE ROLE <name> NOINHERIT;` -- создать роль, права которой не наследуются при членстве (т.к. по умолчанию
  наследуются)
- `CREATE ROLE <name> CONNECTION LIMIT <number>` -- создать роль, с ограничением по количеству подключений
- *Установка параметров конфигурации на уровне роли без права LOGIN лишено смысла, т. к. они никогда не будут
  применены.*
- *Обычно групповая роль не имеет атрибута LOGIN, хотя при желании его можно установить.*
- `GRANT <group_name> TO <name>, ... ;` -- добавить одну роль в членство групповой роли
- `REVOKE <group_name> FROM <name>, ... ;` -- отозвать членство роли в групповой роли

Пример:

```sql
1. CREATE ROLE joe LOGIN INHERIT;
2. CREATE ROLE admin NOINHERIT;
3. CREATE ROLE wheel NOINHERIT;
4. GRANT admin TO joe;
5. GRANT wheel TO admin;
```

Пояснение:

1. `joe` -- наследует права ролей, которые ему выдаются
2. `admin` -- не наследует права ролей, которые ему выдаются
3. `wheel` -- не наследует права ролей, которые ему выдаются
4. Выдаём права роли `admin` для `joe`, он их наследует -> `joe` -- отныне админ
5. Выдаём права роли `admin` для `wheel`, но он их не наследует, потому что определен как noinherit -> `joe`, который
   является `admin`, так же не получит права `wheel`

Если создали роль, выдали права и теперь влом отзывать по одному, чтобы удалить, то:

```sql
REASSIGN OWNED BY <name> TO postgres; -- отдать всё, чем владеет роль в руки SU или другой доверенной роли
DROP OWNED BY <name>; -- дропнуть, связи, которыми была привязана роль
DROP ROLE <name>;
```

### CREATE ROLE -- создание роли (она же пользователь, она же группа):

```sql
CREATE ROLE <name> WITH
      SUPERUSER | NOSUPERUSER                   -- суперпользователь?
    | CREATEDB | NOCREATEDB                     -- может создавать базы даных?
    | CREATEROLE | NOCREATEROLE                 -- может создавать и менять другие роли?
    | INHERIT | NOINHERIT                       -- наследует права при членстве?
    | LOGIN | NOLOGIN                           -- есть логин? (нужен для подключения)
    | REPLICATION | NOREPLICATION               -- может подключаться в режиме репликации?
    | BYPASSRLS | NOBYPASSRLS                   -- игнорирует политики защиты на уровне строк (RLS)?
    | CONNECTION LIMIT <num>                    -- максимум подключений (-1 == inf)
    | PASSWORD '<pwd>'                          -- пароль
    | VALID UNTIL '<date_time = 2005-01-01>'    -- когда пароль истечёт?
    | IN ROLE <role_name> [, ...]               -- в какие роли включить создаваемую?
    | IN GROUP <role_name> [, ...]              -- == IN ROLE
    | ROLE <role_name> [, ...]                  -- какие роли включить в создаваемую
    | ADMIN <role_name> [, ...]                 -- == ROLE, но перечисленные роли могут включать новые роли в создаваемую
    | USER <role_name> [, ...]                  -- == ROLE
```

P.S. По умолчанию `INHERIT`, `NOSUPERUSER`, `NOCREATEDB`, `NO...` и т.д.

### ALTER ROLE -- изменить параметры существующей роли

```sql
1. ALTER ROLE <role_name> WITH

      SUPERUSER | NOSUPERUSER                   -- суперпользователь?
    | CREATEDB | NOCREATEDB                     -- может создавать базы даных?
    | CREATEROLE | NOCREATEROLE                 -- может создавать и менять другие роли?
    | INHERIT | NOINHERIT                       -- наследует права при членстве?
    | LOGIN | NOLOGIN                           -- есть логин? (нужен для подключения)
    | REPLICATION | NOREPLICATION               -- может подключаться в режиме репликации?
    | BYPASSRLS | NOBYPASSRLS                   -- игнорирует политики защиты на уровне строк (RLS)?
    | CONNECTION LIMIT <num>                    -- максимум подключений (-1 == inf)
    | PASSWORD '<pwd>'                          -- новый пароль
    | VALID UNTIL '<date_time = 2005-01-01>'    -- когда пароль истечёт?

2. ALTER ROLE <role_name> RENAME TO <new_role_name>

3. ALTER ROLE { <role_name> | ALL } [ IN DATABASE <db_name> ] SET <param> { TO | = } { <value> | DEFAULT }
4. ALTER ROLE { <role_name> | ALL } [ IN DATABASE <db_name> ] SET <param> FROM CURRENT
5. ALTER ROLE { <role_name> | ALL } [ IN DATABASE <db_name> ] RESET <param>
6. ALTER ROLE { <role_name> | ALL } [ IN DATABASE <db_name> ] RESET ALL
   --------------^^^^^^^^^
  | <role_name>:
  | CURRENT_ROLE
  | CURRENT_USER
  | SESSION_USER
```

P.S. По умолчанию `NOSUPERUSER`, `NOCREATEDB`, и т.д.

### GRANT — определить права доступа

```sql
GRANT <privelege(-s)> on <object> to <role_name>
```

priveleges:

```sql
-- Таблицы: --
SELECT      -- чтение данных
INSERT      -- вставка данных
UPDATE      -- обновление данных
DELETE      -- удаление данных
TRUNCATE    -- очистка таблицы
REFERENCES  -- право ссылаться на таблицу
TRIGGER     -- создание триггеров

-- Представления (VIEW): --
SELECT      -- чтение представления
TRIGGER     -- право создавать триггеры

-- Последовательности: --
SELECT — чтение последовательности
UPDATE — изменение последовательности
USAGE — использование последовательности

-- Табличные пространства: --
CREATE — создание объектов внутри табличного пространства.

-- Базы данных: --
CREATE — создание схем внутри базы данных
CONNECT — подключение к базе данных
TEMPORARY — создание в базе данных временных таблицы

-- Схемы: --
CREATE — создание объектов внутри конкретной схемы
USAGE — использованеи объектов в конкретной схеме

-- Функции: --
EXECUTE — выполнение функции
```

Пример:

```sql
GRANT INSERT ON films TO maksim [, ...];        -- вставка в таблицу films
GRANT ALL PRIVILEGES ON users TO manu [, ...];  -- все привелегии по взаимодействию с таблицей users
GRANT admins TO max [, ...];                    -- включение одной роли в другую
```

### REVOKE — отозвать права доступа

Пример:

```sql
REVOKE INSERT ON films FROM maksim [, ...];
REVOKE ALL PRIVILEGES ON users FROM manu [, ...];
REVOKE admins FROM max [, ...];
```
