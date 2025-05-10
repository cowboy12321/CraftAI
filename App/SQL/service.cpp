#include <vector>
#include <sqlite3.h>
#include <string>
#include <iostream>
using namespace std;

// 执行数据库的增、删、改操作
bool exec(const string& sql, const vector<string>& values) {
    sqlite3* db;
    int rc = sqlite3_open("../../../../JiangZhi.db", &db);
    if (rc != SQLITE_OK) {
        cerr << "无法打开数据库: " << sqlite3_errmsg(db) << endl;
        return false;
    }
    char* errMsg = nullptr;
    rc = sqlite3_exec(db, "BEGIN", nullptr, nullptr, &errMsg);
    if (rc != SQLITE_OK) {
        cerr << "无法开始事务: " << errMsg << endl;
        sqlite3_free(errMsg);
        sqlite3_close(db);
        return false;
    }

    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr);
    if (rc != SQLITE_OK) {
        cerr << "准备语句失败: " << sqlite3_errmsg(db) << endl;
        sqlite3_close(db);
        return false;
    }

    for (size_t i = 0; i < values.size(); ++i) {
        rc = sqlite3_bind_text(stmt, i+1, values[i].c_str(), -1, SQLITE_TRANSIENT);
        if (rc != SQLITE_OK) {
            cerr << "绑定参数失败: " << sqlite3_errmsg(db) << endl;
            sqlite3_finalize(stmt);
            sqlite3_exec(db, "ROLLBACK", nullptr, nullptr, nullptr);
            sqlite3_close(db);
            return false;
        }
    }

    rc = sqlite3_step(stmt);
    bool success = (rc == SQLITE_DONE);

    if (success) {
        rc = sqlite3_exec(db, "COMMIT", nullptr, nullptr, &errMsg);
        if (rc != SQLITE_OK) {
            cerr << "提交事务失败: " << errMsg << endl;
            sqlite3_free(errMsg);
            success = false;
        }
    } else {
        cerr << "执行失败: " << sqlite3_errmsg(db) << endl;
        sqlite3_exec(db, "ROLLBACK", nullptr, nullptr, &errMsg);
        if (errMsg) {
            cerr << "回滚事务失败: " << errMsg << endl;
            sqlite3_free(errMsg);
        }
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return success;
}

bool exec(const string& sql) {
    sqlite3* db;
    int rc = sqlite3_open("../../../../JiangZhi.db", &db);
    if (rc != SQLITE_OK) {
        cerr << "无法打开数据库: " << sqlite3_errmsg(db) << endl;
        return false;
    }

    char* errMsg = nullptr;
    rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);
    bool success = (rc == SQLITE_OK);

    if (!success) {
        cerr << "执行失败: " << (errMsg ? errMsg : "未知错误") << endl;
    }

    if (errMsg) sqlite3_free(errMsg);
    sqlite3_close(db);
    return success;
}

// 带参数的精确查询
vector<vector<string>> query(const string& sql, const vector<string>& keys) {
    sqlite3* db;
    vector<vector<string>> results;
    
    int rc = sqlite3_open("../../../../JiangZhi.db", &db);
    if (rc != SQLITE_OK) {
        cerr << "无法打开数据库: " << sqlite3_errmsg(db) << endl;
        sqlite3_close(db);
        return results;
    }

    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr);
    if (rc != SQLITE_OK) {
        cerr << "准备语句失败: " << sqlite3_errmsg(db) << endl;
        sqlite3_close(db);
        return results;
    }

    for (size_t i = 0; i < keys.size(); ++i) {
        rc = sqlite3_bind_text(stmt, i+1, keys[i].c_str(), -1, SQLITE_TRANSIENT);
        if (rc != SQLITE_OK) {
            cerr << "绑定参数失败: " << sqlite3_errmsg(db) << endl;
            sqlite3_finalize(stmt);
            sqlite3_close(db);
            return results;
        }
    }

    while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        int cols = sqlite3_column_count(stmt);
        vector<string> row;
        for (int i = 0; i < cols; ++i) {
            const char* val = reinterpret_cast<const char*>(sqlite3_column_text(stmt, i));
            row.push_back(val ? val : "");
        }
        results.push_back(row);
    }

    if (rc != SQLITE_DONE) {
        cerr << "查询错误: " << sqlite3_errmsg(db) << endl;
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return results;
}

// 不带参数的模糊查询
vector<vector<string>> query(const string& sql) {
    sqlite3* db;
    vector<vector<string>> results;
    int rc = sqlite3_open("../../../../JiangZhi.db", &db);
    if (rc != SQLITE_OK) {
        cerr << "无法打开数据库: " << sqlite3_errmsg(db) << endl;
        sqlite3_close(db);
        return results;
    }

    sqlite3_stmt* stmt;
    rc = sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr);
    if (rc != SQLITE_OK) {
        cerr << "准备语句失败: " << sqlite3_errmsg(db) << endl;
        sqlite3_close(db);
        return results;
    }

    while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
        int cols = sqlite3_column_count(stmt);
        vector<string> row;
        for (int i = 0; i < cols; ++i) {
            const char* val = reinterpret_cast<const char*>(sqlite3_column_text(stmt, i));
            row.push_back(val ? val : "");
        }
        results.push_back(row);
    }

    if (rc != SQLITE_DONE) {
        cerr << "查询错误: " << sqlite3_errmsg(db) << endl;
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return results;
}

int main() {
    cerr<<1<<endl;
    cerr<<"1"<<endl;
    exec("INSERT INTO users(name,password) VALUES ('B','123')");
    auto results = query(
        "select * from users"
    );
    for (const auto& i:results){
        for (const auto& j:i){
            cerr<<j<<endl;
        }
    }
    return 0;    
    

}