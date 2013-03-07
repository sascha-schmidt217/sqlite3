
#include <sqlite3.h>

class BBSQlDataBase;
BBSQlDataBase* link;

class BBSQlDataBase : public Object{
public:
	sqlite3 *db;

	int Load(String name, int flags)
	{
		//int rc = sqlite3_open(name.ToCString<char>(), &db);
		int rc = sqlite3_open_v2(name.ToCString<char>(), &db, flags, NULL);
		if( rc )
		{
			sqlite3_close(db);
			// error
		}
		return rc;
	}
	
	~BBSQlDataBase() 
	{
		Close();
	}
	
	void mark() 
	{ 
		Object::mark();
	}
	
	int Query(String str)
	{
		char *zErrMsg = 0;
		link = this;
		int rc = sqlite3_exec(db, str.ToCString<char>(), callback, 0, &zErrMsg);
		if( rc!=SQLITE_OK )
		{
		  Print( String::Load((unsigned char*)zErrMsg,strlen(zErrMsg)) );
	      sqlite3_free(zErrMsg);
	    }
	    return rc;
	}
	
	int Close()
	{
		int val = 0;
		if( db )
		{
			val = sqlite3_close(db);
			db = 0;
		}
		return val;
	}

	String GetError()
	{
		std::string strerr = sqlite3_errmsg(db);
		return String(strerr.c_str(), strerr.size());
	}
	
	virtual void UNSAFE_CALLBACK(Array<String> name_array, Array<String> value_array)
	{
	}
	
	static int callback(void *NotUsed, int argc, char **argv, char **azColName)
	{
		Array<String> t_arr_names=Array<String>(argc);
		Array<String> t_arr_values=Array<String>(argc);
		
		int i;
		for(i=0; i<argc; i++){
		
			t_arr_names[i] = String::Load((unsigned char*)azColName[i],strlen(azColName[i]));
			t_arr_values[i] = String::Load((unsigned char*)(argv[i] ? argv[i] : "NULL"),strlen(argv[i] ? argv[i] : "NULL"));
			
		}
		
		link->UNSAFE_CALLBACK(t_arr_names,t_arr_values);

		return 0;
	}
};  


class BBSQLStatement : public Object
{
public:

	sqlite3_stmt* stmt;           
    sqlite3* sqlite;         
	bool done;
	bool ok;
	int columnCount;
    
    BBSQLStatement()
    {
    	stmt = 0;
    	sqlite = 0;
    }
    
	~BBSQLStatement()
	{
		Dispose();
	}
	
	void mark() 
	{ 
		Object::mark();
	}
	
	void Dispose()
	{
		if( stmt )
		{
			int ret = sqlite3_finalize(stmt);
			stmt = 0;
	    }
	}
	
	int Load(BBSQlDataBase* db, String query)
	{
		Dispose();
		columnCount = 0;
		ok = false;
		done = false;
		sqlite = db->db;
		int ret = sqlite3_prepare_v2(sqlite, query.ToCString<char>(), query.Length(), &stmt, NULL);
	    columnCount = sqlite3_column_count(stmt);
	    return ret;
	}
	
	int Reset()
	{
		ok = false;
    	done = false;
		return sqlite3_reset(stmt);
	}
	
	int BindInt(int index, int value)  
	{
		return sqlite3_bind_int(stmt, index, value);
	}
	
    int BindInt64(int index, int value)  
    {
    	return sqlite3_bind_int64(stmt, index, value);
    }
    
    int BindDouble(int index, float value)  
    {
    	return sqlite3_bind_double(stmt, index, value);
    }
    
    int BindString(int index, String value)  
    {
	    return sqlite3_bind_text(stmt, index, value.ToCString<char>(), value.Length(), SQLITE_TRANSIENT);   
    }

    int BindNull(int index)
    {
	    return sqlite3_bind_null(stmt, index);
    }
    
    int BindIntByName(String name, int value)  
    {
    	int index = sqlite3_bind_parameter_index(stmt, name.ToCString<char>());
	    return sqlite3_bind_int(stmt, index+1, value);
    }
    
    int BindInt64ByName(String name, int value)  
    {
    	int index = sqlite3_bind_parameter_index(stmt, name.ToCString<char>());
	    return sqlite3_bind_int64(stmt, index+1, value);
    }
    
    int BindDoubleByName(String name, float value)   
    {
    	int index = sqlite3_bind_parameter_index(stmt, name.ToCString<char>());
	    return sqlite3_bind_double(stmt, index+1, value);
    }
    
    int BindStringByName(String name, String value)   
    {
    	int index = sqlite3_bind_parameter_index(stmt, name.ToCString<char>());
	    return sqlite3_bind_text(stmt, index+1, value.ToCString<char>(), value.Length(), SQLITE_TRANSIENT);
    }
    
    int BindNullByName(String name) 
    {
    	int index = sqlite3_bind_parameter_index(stmt, name.ToCString<char>());
	    return sqlite3_bind_null(stmt, index+1);
    }

	bool ExecuteStep()
	{
		if (!done)
	    {
	        int ret = sqlite3_step(stmt);
	        if (SQLITE_ROW == ret) // one row is ready : call getColumn(N) to access it
	        {
	            ok = true;
	        }
	        else if (SQLITE_DONE == ret) // no (more) row ready : the query has finished executing
	        {
	            ok = false;
	            done = true;
	        }
	        else
	        {
	            ok = false;
	            done = false;
				
				// error
	        }
	    }
	    return ok;
	}
	
	int GetInt(int index)
	{
	    return sqlite3_column_int(stmt, index);
	}
	
	int GetInt64(int index)
	{
	    return (int)sqlite3_column_int64(stmt, index);
	}
	
	float GetDouble(int index)
	{
	    return (float)sqlite3_column_double(stmt, index);
	}
	
	String GetText(int index)
	{
		auto text = (const char*)sqlite3_column_text(stmt, index);
	    return String(text, strlen(text));
	}
	
	int GetColumnCount(void) const
    {
        return columnCount;
    }
    
};
