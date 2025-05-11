import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), 'JiangZhi.db')

def open():
    conn = sqlite3.connect(DB_PATH)
    return conn

def sql_exec(sql, values=None):
    db = open()
    cursor = db.cursor()
    try:
        if values:
            cursor.execute(sql, values)
        else:
            cursor.execute(sql)
        db.commit()
        return 1
    except Exception as e:
        print("SQL 执行错误:", e)
        db.rollback()
        return 0
    finally:
        cursor.close()
        db.close()

def query(sql, *keys):
    db = open()
    cursor = db.cursor()
    cursor.execute(sql, keys)
    result = cursor.fetchall()
    cursor.close()
    db.close()
    return result

def query2(sql):
    db = open()
    cursor = db.cursor()
    cursor.execute(sql)
    result = cursor.fetchall()
    cursor.close()
    db.close()
    return result
