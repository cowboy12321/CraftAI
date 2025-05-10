import sqlite3

# 打开数据库连接
def open():
    conn = sqlite3.connect('JiangZhi.db')  
    return conn

# 执行数据库的增、删、改操作
def sql_exec(sql,values):
    db=open()
    cursor = db.cursor() 
    try:
        if values:
            cursor.execute(sql,values)
        else:
            cursor.execute(sql)
        db.commit() 
        return 1 
    except:
        db.rollback() 
        return 0
    finally:
        cursor.close() 
        db.close()

# 带参数的精确查询
def query(sql,*keys):
    db=open() 
    cursor = db.cursor()
    cursor.execute(sql,keys) 
    result = cursor.fetchall()
    cursor.close() 
    db.close() 
    return result

# 不带参数的模糊查询
def query2(sql):
    db=open() 
    cursor = db.cursor()
    cursor.execute(sql) 
    result = cursor.fetchall() 
    cursor.close() 
    db.close() 
    return result 
open()
