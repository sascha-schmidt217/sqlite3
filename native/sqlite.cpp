
#include <sqlite3.h>

class BBSQlDataBase;
BBSQlDataBase* link;

class BBSQlDataBase : public Object{
public:
	sqlite3 *db;

	int Load(String name)
	{
		int rc = sqlite3_open(name.ToCString<char>(), &db);
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
		if( rc!=SQLITE_OK ){
	      fprintf(stderr, "SQL error: %s\n", zErrMsg);
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
