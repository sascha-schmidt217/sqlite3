// https://code.google.com/p/csharp-sqlite/downloads/detail?name=csharp-sqlite_3_7_7_1_71.zip&can=2&q=
// add 'Community.CsharpSqlite.Dll'
// add 'using Community.CsharpSqlite;'

class BBSQlDataBase
{

	public static BBSQlDataBase link;
	
	public Sqlite3.sqlite3 db;
    public Sqlite3.dxCallback callback_delegate = new Sqlite3.dxCallback(callback); 

	public int Load(String name, int flags)
	{
		int rc = Sqlite3.sqlite3_open_v2(name, out db, flags, null );
		if( rc != 0 )
		{
			// error
			Close();
		}
		return rc;
	}
	
	~BBSQlDataBase() 
	{
		Close();
	}
	
	public virtual int Query(String str)
	{
		return Sqlite3.sqlite3_exec(db, str, callback_delegate, this, 0);
	}
	
	public virtual int Close()
	{
		int val = 0;
		if( db != null )
		{
			val = Sqlite3.sqlite3_close(db);
			db = null;
		}
		return val;
	}

	public virtual String GetError()
	{
		return Sqlite3.sqlite3_errmsg(db);
	}
	
	public virtual void UNSAFE_CALLBACK(String[] name_array, String[] value_array)
	{
	}

    public static int callback(object pCallbackArg, long v, object argv, object azColName) 
	{
        var sql = (BBSQlDataBase)pCallbackArg;

		var t_arr_names= (azColName as IEnumerable).Cast<string>().ToArray<string>();
		var t_arr_values=(argv as IEnumerable).Cast<string>().ToArray<string>();
		
        sql.UNSAFE_CALLBACK(t_arr_names,t_arr_values);
		return 0;
	}
};

class BBSQLStatement 
{
	public Sqlite3.Vdbe stmt;           
    public Sqlite3.sqlite3 sqlite;         
	public bool done;
	public bool ok;
	public int columnCount;
    
    public BBSQLStatement()
    {
    	stmt = null;
    	sqlite = null;
    }
    
	~BBSQLStatement()
	{
		Dispose();
	}

    public void Dispose()
	{
		if( stmt != null )
		{
			int ret = Sqlite3.sqlite3_finalize(stmt);
			stmt = null;
	    }
	}

    public int Load(BBSQlDataBase db, String query)
	{
		Dispose();
		columnCount = 0;
		ok = false;
		done = false;
		sqlite = db.db;
		int ret = Sqlite3.sqlite3_prepare_v2(sqlite, query, query.Length, ref stmt, 0);
	    columnCount = Sqlite3.sqlite3_column_count(stmt);
	    return ret;
	}

    public int Reset()
	{
		ok = false;
    	done = false;
		return Sqlite3.sqlite3_reset(stmt);
	}

    public int BindInt(int index, int value)  
	{
		return Sqlite3.sqlite3_bind_int(stmt, index, value);
	}

    public int BindInt64(int index, int value)  
    {
    	return Sqlite3.sqlite3_bind_int64(stmt, index, value);
    }

    public int BindDouble(int index, float value)  
    {
    	return Sqlite3.sqlite3_bind_double(stmt, index, value);
    }

    public int BindString(int index, String value)  
    {
	    return Sqlite3.sqlite3_bind_text(stmt, index, value, value.Length, Sqlite3.SQLITE_TRANSIENT);   
    }

    public int BindNull(int index)
    {
	    return Sqlite3.sqlite3_bind_null(stmt, index);
    }

    public int BindIntByName(String name, int value)  
    {
    	int index = Sqlite3.sqlite3_bind_parameter_index(stmt, name);
	    return Sqlite3.sqlite3_bind_int(stmt, index+1, value);
    }

    public int BindInt64ByName(String name, int value)  
    {
    	int index = Sqlite3.sqlite3_bind_parameter_index(stmt, name);
	    return Sqlite3.sqlite3_bind_int64(stmt, index+1, value);
    }

    public int BindDoubleByName(String name, float value)   
    {
    	int index = Sqlite3.sqlite3_bind_parameter_index(stmt, name);
	    return Sqlite3.sqlite3_bind_double(stmt, index+1, value);
    }

    public int BindStringByName(String name, String value)   
    {
    	int index = Sqlite3.sqlite3_bind_parameter_index(stmt, name);
        return Sqlite3.sqlite3_bind_text(stmt, index + 1, value, value.Length, Sqlite3.SQLITE_TRANSIENT);
    }

    public int BindNullByName(String name) 
    {
    	int index = Sqlite3.sqlite3_bind_parameter_index(stmt, name);
	    return Sqlite3.sqlite3_bind_null(stmt, index+1);
    }

    public bool ExecuteStep()
	{
		if (!done)
	    {
	        int ret = Sqlite3.sqlite3_step(stmt);
	        if (Sqlite3.SQLITE_ROW == ret) // one row is ready : call getColumn(N) to access it
	        {
	            ok = true;
	        }
	        else if (Sqlite3.SQLITE_DONE == ret) // no (more) row ready : the query has finished executing
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

    public int GetInt(int index)
	{
	    return Sqlite3.sqlite3_column_int(stmt, index);
	}

    public int GetInt64(int index)
	{
	    return (int)Sqlite3.sqlite3_column_int64(stmt, index);
	}

    public float GetDouble(int index)
	{
	    return (float)Sqlite3.sqlite3_column_double(stmt, index);
	}

    public String GetText(int index)
	{
		return Sqlite3.sqlite3_column_text(stmt, index);
	}

    public int GetColumnCount()
    {
        return columnCount;
    }
    
};
