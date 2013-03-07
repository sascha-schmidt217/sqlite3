' 2013 (c) Sascha Schmidt

Import "native/sqlite.cpp"

#rem
** Many SQLite functions return an integer result code from the set shown
** here in order to indicate success or failure..
#end 
Const SQLITE_OK           =0   '' Successful result */
''/* beginning-of-error-codes */
Const SQLITE_ERROR        =1   '' SQL Error Or missing database */
Const SQLITE_INTERNAL     =2   '' Internal logic error in SQLite */
Const SQLITE_PERM         =3   '' Access permission denied */
Const SQLITE_ABORT        =4   '' Callback routine requested an abort */
Const SQLITE_BUSY         =5   '' The database file is locked */
Const SQLITE_LOCKED       =6   '' A table in the database is locked */
Const SQLITE_NOMEM        =7   '' A malloc() failed */
Const SQLITE_READONLY     =8   '' Attempt to write a readonly database */
Const SQLITE_INTERRUPT    =9   '' Operation terminated by sqlite3_interrupt()*/
Const SQLITE_IOERR       =10   '' Some kind of disk I/O error occurred */
Const SQLITE_CORRUPT     =11   '' The database disk image is malformed */
Const SQLITE_NOTFOUND    =12   '' Unknown opcode in sqlite3_file_control() */
Const SQLITE_FULL        =13   '' Insertion failed because database is full */
Const SQLITE_CANTOPEN    =14   '' Unable to open the database file */
Const SQLITE_PROTOCOL    =15   '' Database lock protocol error */
Const SQLITE_EMPTY      = 16   '' Database is empty */
Const SQLITE_SCHEMA      =17   '' The database schema changed */
Const SQLITE_TOOBIG      =18   '' String or BLOB exceeds size limit */
Const SQLITE_CONSTRAINT  =19   '' Abort due to constraint violation */
Const SQLITE_MISMATCH    =20   '' Data type mismatch */
Const SQLITE_MISUSE      =21   '' Library used incorrectly */
Const SQLITE_NOLFS       =22   '' Uses OS features not supported on host */
Const SQLITE_AUTH        =23   '' Authorization denied */
Const SQLITE_FORMAT      =24   '' Auxiliary database format error */
Const SQLITE_RANGE       =25   '' 2nd parameter to sqlite3_bind out of range */
Const SQLITE_NOTADB      =26   '' File opened that is not a database file */
Const SQLITE_ROW         =100  '' sqlite3_step() has another row ready */
Const SQLITE_DONE        =101  '' sqlite3_step() has finished executing */
''/* End-of-Error-codes */

#rem
Flags For File Open Operations
#end 
Const SQLITE_OPEN_READONLY         = $00000001  '' Ok for sqlite3_open_v2() */
Const SQLITE_OPEN_READWRITE        = $00000002  '' Ok for sqlite3_open_v2() */
Const SQLITE_OPEN_CREATE           = $00000004  '' Ok for sqlite3_open_v2() */
Const SQLITE_OPEN_DELETEONCLOSE    = $00000008  '' VFS only */
Const SQLITE_OPEN_EXCLUSIVE        = $00000010  '' VFS only */
Const SQLITE_OPEN_AUTOPROXY        = $00000020  '' VFS only */
Const SQLITE_OPEN_URI              = $00000040  '' Ok for sqlite3_open_v2() */
Const SQLITE_OPEN_MEMORY           = $00000080  '' Ok for sqlite3_open_v2() */
Const SQLITE_OPEN_MAIN_DB          = $00000100  '' VFS only */
Const SQLITE_OPEN_TEMP_DB          = $00000200  '' VFS only */
Const SQLITE_OPEN_TRANSIENT_DB     = $00000400  '' VFS only */
Const SQLITE_OPEN_MAIN_JOURNAL     = $00000800  '' VFS only */
Const SQLITE_OPEN_TEMP_JOURNAL     = $00001000  '' VFS only */
Const SQLITE_OPEN_SUBJOURNAL       = $00002000  '' VFS only */
Const SQLITE_OPEN_MASTER_JOURNAL   = $00004000  '' VFS only */
Const SQLITE_OPEN_NOMUTEX          = $00008000  '' Ok for sqlite3_open_v2() */
Const SQLITE_OPEN_FULLMUTEX        = $00010000  '' Ok for sqlite3_open_v2() */
Const SQLITE_OPEN_SHAREDCACHE      = $00020000  '' Ok for sqlite3_open_v2() */
Const SQLITE_OPEN_PRIVATECACHE     = $00040000  '' Ok for sqlite3_open_v2() */
Const SQLITE_OPEN_WAL              = $00080000  '' VFS only */

Private 

Extern 

Class BBSQLStatement
	Method Load(db:BBSQlDataBase,query$)
	Method Reset()
	Method BindInt(index, value)
    Method BindInt64(index, value) 
    Method BindDouble(index, value#) 
    Method BindString(index, value$)
    Method BindNull(index)
    Method BindInt(name$, value)  ="BindIntByName"
    Method BindInt64(name$, value)   ="BindInt64ByName"
    Method BindDouble(name$, value#)  ="BindDoubleByName"
    Method BindString(name$, value$)    ="BindStringByName"
    Method BindNull(name)  ="BindNullByName"
	Method ExecuteStep?() 
	Method GetInt(index)
	Method GetInt64(index) 
	Method GetDouble#(index) 
	Method GetText$(index)
End 

Class BBSQlDataBase
	Method Load(str$,flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE )
	Method Query(str$)
	Method Close()
	Method GetError$()
	Method UNSAFE_CALLBACK:Void(name_arr:String[], value_array:String[])
End 

Public 

Class SQLite3Column

	Field items:StringMap<String>
	Field arr:String[]
	
	Method New(name_arr:String[], value_array:String[])
		items = New StringMap<String>
		Local length = name_arr.Length
		For Local i = 0 Until length
			items.Set(name_arr[i], value_array[i])
		End 
	End 
	
End 

Class SQLite3Result
	
	Field columns:= New Stack<SQLite3Column>
	Field column:SQLite3Column
	Field length:Int = 0
	Field index:Int = 0
	
	Method Add(name_arr:String[], value_array:String[])
		columns.Push(New SQLite3Column(name_arr,value_array))
		length+=1
	End 
	
	Method Read?()
		index+=1
		Return length - index >= 0
	End 
	
	Method Reset()
		index = 0
	End 
	
	Method GetString$(index)
		Return column.arr[index-1]
	End 
	
	Method GetString$(name$)
		Return column.items.Get(name)
	End 
	
	Method StringMap:StringMap<String>() 
		Return columns.Get(index-1).items
	End 
	
	Method Columns%()
		Return length
	End 
	
End
 
Class SQLite3Statement Extends BBSQLStatement
End 

Class SQLite3DataBase Extends BBSQlDataBase
Private

 	Field  result:SQLite3Result
 
Public 
	
 	Method UNSAFE_CALLBACK:Void(name_arr:String[], value_array:String[])
		result.Add(name_arr,value_array)
	End 
	
	Method TableExists?(tableName$)
	    Return SQLITE_ERROR = Query("SELECT count(*) FROM sqlite_master WHERE type='table' AND name=" + tableName);
	End 

	Method Exec:SQLite3Result(str$)
		result= New SQLite3Result
		Query(str)
		Return result
	End 
	
	Method CreateStatement:SQLite3Statement(query$)
		Local stmt:=  New SQLite3Statement
		Local ret:= stmt.Load(Self, query)
		If ret 
			'' error
			stmt = Null
		End 
		Return stmt
	End 
	
End 