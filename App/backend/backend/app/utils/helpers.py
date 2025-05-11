import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), '..', 'SQL', 'JiangZhi.db')

def open():
    return sqlite3.connect(DB_PATH)

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
    except:
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