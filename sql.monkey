Import "native/sqlite.cpp"

Private 

Extern 

Class BBSQlDataBase
	Method Load(str$)
	Method Query(str$)
	Method Close()
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
 
Class SQLite3DataBase Extends BBSQlDataBase
 
 	Field  result:SQLite3Result
 	
	Method TableExists?(tableName$)
	    Return 1 = Query("SELECT count(*) FROM sqlite_master WHERE type='table' AND name=" + tableName);
	End 
	
	Method UNSAFE_CALLBACK:Void(name_arr:String[], value_array:String[])
		result.Add(name_arr,value_array)
		'Local length = name_arr.Length
		'For Local i = 0 Until length
		'	Print name_arr[i] + "/" + value_array[i]
		'End 
	End 
	
	Method Exec:SQLite3Result(str$)
		result= New SQLite3Result
		Query(str)
		Return result
	End 
	
End 
