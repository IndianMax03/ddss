DO $$
DECLARE
    t_name TEXT := '"NOPAIN"';
    s_name TEXT := 's333057';
    no_header TEXT := 'No.';
    no_delimeter TEXT := '---';
    name_header TEXT := 'Имя столбца';
    name_delimeter TEXT := '-----------';
    attr_header TEXT := 'Атрибуты';
    attr_delimeter TEXT := '------------------------------------------------------';
    pointer CURSOR FOR (
        SELECT
            pg_attribute.attnum,
            pg_attribute.attname master_att,
            pg_type.typname,
            pg_constraint.contype, -- 'f', если fk --
            pg_constraint.confrelid,
            pg_clazz.relname,
            pg_attribute2.attname slave_att
        FROM pg_class 
        JOIN pg_attribute ON pg_class.oid = pg_attribute.attrelid
        JOIN pg_type ON pg_attribute.atttypid = pg_type.oid
        JOIN pg_namespace ON pg_class.relnamespace = pg_namespace.oid
        LEFT JOIN pg_constraint ON pg_attribute.attrelid = pg_constraint.conrelid AND pg_attribute.attnum = ANY(pg_constraint.conkey)
        LEFT JOIN pg_attribute pg_attribute2 ON pg_constraint.confrelid = pg_attribute2.attrelid AND pg_constraint.confkey[1] = pg_attribute2.attnum
        LEFT JOIN pg_class pg_clazz ON pg_clazz.oid = pg_attribute2.attrelid
        where pg_class.relname = t_name and pg_namespace.nspname = s_name and pg_attribute.attnum > 0
    );
BEGIN

    IF LEFT(t_name, 1) = '"' and RIGHT(t_name, 1) = '"' THEN
        t_name := BTRIM(t_name, '"');
    ELSE
        t_name := LOWER(t_name);
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE 'table -> %', t_name;
    RAISE NOTICE '';
    RAISE NOTICE 'schema -> %', s_name;
    RAISE NOTICE '';
    RAISE NOTICE '% | % | %', no_header, name_header, attr_header;
    RAISE NOTICE '% | % | %', no_delimeter, name_delimeter, attr_delimeter;

    FOR c IN pointer
    LOOP
        RAISE NOTICE '% | % | Type: %', RPAD(c.attnum::TEXT, 3, ' '), RPAD(c.master_att, 11, ' '), c.typname;
        IF c.contype = 'f' THEN
            RAISE NOTICE '%|%| Constr: "%" References %(%)', RPAD('', 4, ' '),  RPAD('', 13, ' '), c.master_att, c.relname, c.slave_att;
        END IF;
        RAISE NOTICE '% | % | %', no_delimeter, name_delimeter, attr_delimeter;
    END LOOP;
    RAISE NOTICE '';

END;
$$ LANGUAGE plpgsql;
