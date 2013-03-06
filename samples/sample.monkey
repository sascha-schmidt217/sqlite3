Import mojo
Import sql

' copy sql.sqlite3/* to sample.build/glfw/vc2010
' add sqlite3.c + sqlite3.h to project
' make sure sqlite3.c is compiled as C code

Class SQLite3Test Extends App

	Field _db:SQLite3DataBase
	
	Method OnCreate()

		SetUpdateRate 60
		
		_db = New SQLite3DataBase()
		_db.Load("database.db")
		
		_db.Query("CREATE TABLE Books(Id INTEGER PRIMARY KEY, Title TEXT, Author TEXT, ISBN TEXT DEFAULT 'not available')")
		_db.Query("INSERT INTO Books(Id, Title, Author, ISBN)VALUES(1, 'War and Peace', 'Leo Tolstoy', '978-0345472403')")
		_db.Query("INSERT INTO Books(Id, Title, Author, ISBN)VALUES(2, 'diesdas', 'Leo Tolstoy', '978-0345472403')")
		_db.Query("INSERT INTO Books(Id, Title, Author, ISBN)VALUES(3, 'blibla', 'Leo Tolstoy', '978-23423')")
		_db.Query("INSERT INTO Books(Id, Title, Author, ISBN)VALUES(4, 'blubla', 'Leo Tolstoy', '978-2342342342')")
		_db.Query("INSERT INTO Books(Id, Title, Author, ISBN)VALUES(5, 'asdasdasd', 'Leo Tolstoy', '978-324234234')")
		_db.Query("INSERT INTO Books(Id, Title, Author, ISBN)VALUES(6, 'asdasd', 'Leo Tolstoy', '978-32423423423')")
		_db.Query("INSERT INTO Books(Id, Title, Author, ISBN)VALUES(7, 'asdasdas', 'Leo Tolstoy', '978-234234234')")

		Local result:= _db.Exec("SELECT * FROM Books")
		While result.Read()
			Local map:= result.StringMap()
			For Local e:= Eachin map
				Print e.Key + "/" + e.Value
			End 
		Wend 
		
	End

	Method OnUpdate()
	End

	Method OnRender()
		Cls 0,0,0
	End
	
End

Global myapp:SQLite3Test
Function Main()
	myapp = New SQLite3Test()
End



