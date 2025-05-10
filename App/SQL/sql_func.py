from service import *

def add_data(table_name,*keys):
    s=', '.join(['?'] * len(keys))
    sql = f"INSERT INTO {table_name} VALUES ({s})"
    sql_exec(sql,keys)
    return 

def delete_data(table_name,condition=''):
    if condition:
        sql=f'DELETE FORM {table_name} WHERE {condition}'
    else:
        sql=f'DELETE FORM {table_name}'
    sql_exec(sql)
    return 

def update_data(table_name,dic,condition=''):
    s=''
    for k,v in dic.items():
        s=s+k+'='+v+','
    s=s[:len(s)-1]
    if condition:
        sql=f'UPDATE {table_name} SET {s} where {condition}'
    else:
        sql=f'UPDATE {table_name} SET {s}'
    return 

def select(table_names,select_goals=None,condition=None,sort=None,reverse=False,max_len=10,connect=None,params=None):
    select_clause = ", ".join(select_goals) if select_goals else "*"
    from_clause = ", ".join(table_names)
    where_clause = f"WHERE {condition}" if condition else ""
    
    if connect and len(table_names) > 1:
        if len(table_names) != len(connect) + 1:
            raise ValueError("连接条件数量必须等于表数量减1")
        from_clause = f"{table_names[0]} JOIN {table_names[1]} ON {connect[0]}"
        for i in range(2, len(table_names)):
            from_clause += f" JOIN {table_names[i]} ON {connect[i-1]}"

    order_clause = ""
    if sort:
        order_dir = "DESC" if reverse else "ASC"
        order_clause = f"ORDER BY {', '.join(sort)} {order_dir}"
    
    limit_clause = f"LIMIT {max_len}" if max_len else ""
    
    sql = f"SELECT {select_clause} FROM {from_clause} {where_clause} {order_clause} {limit_clause}"
    sql = " ".join(sql.split()) 

    if condition and "?" in condition: 
        return query(sql, *params)
    else:
        return query2(sql)

if __name__ == '__main__':
    add_data("users",1,'1','123')
    add_data("users",2,'3','1234')


    result=select(['users'],['name','password'],"password=\'1234\'")

    for i in result:
        print(i)