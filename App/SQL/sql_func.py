from .service import *
from multipledispatch import dispatch

def add_data(table_name, dic):
    column = ','.join(dic.keys())
    values = ','.join(['?'] * len(dic))
    sql = f"INSERT INTO {table_name} ({column}) VALUES ({values})"
    return sql_exec(sql, tuple(dic.values()))

def delete_data(table_name, condition=''):
    if condition:
        sql = f'DELETE FROM {table_name} WHERE {condition}'
    else:
        sql = f'DELETE FROM {table_name}'
    return sql_exec(sql)

def update_data(table_name, dic, condition=''):
    s = ','.join([f"{k} = ?" for k in dic])
    values = list(dic.values())
    sql = f'UPDATE {table_name} SET {s}'
    if condition:
        sql += f' WHERE {condition}'
    return sql_exec(sql, values)

def select(table_names, select_goals=None, condition=None, sort=None, reverse=False, max_len=10, connect=None, params=None):
    select_clause = ", ".join(select_goals) if select_goals else "*"
    from_clause = ", ".join(table_names)
    where_clause = f"WHERE {condition}" if condition else ""

    if connect and len(table_names) > 1:
        if len(table_names) != len(connect) + 1:
            raise ValueError("连接条件数量必须等于表数量减1")
        from_clause = f"{table_names[0]} JOIN {table_names[1]} ON {connect[0]}"
        for i in range(2, len(table_names)):
            from_clause += f" JOIN {table_names[i]} ON {connect[i-1]}"

    order_clause = f"ORDER BY {', '.join(sort)} {'DESC' if reverse else 'ASC'}" if sort else ""
    limit_clause = f"LIMIT {max_len}" if max_len else ""

    sql = f"SELECT {select_clause} FROM {from_clause} {where_clause} {order_clause} {limit_clause}"
    sql = " ".join(sql.split())

    if condition and "?" in condition and params:
        return query(sql, *params)
    else:
        return query2(sql)
