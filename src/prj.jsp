<html>
<body>

<style>
.divider{
    width:20px;
    display:inline-block;
}
</style>

<script type="text/javascript">

	function goBack() {
		window.history.back();
	}

	function disp() {
		var task = getUrlParam('task','Empty');
		task=task.substring(task.search('-')+1);
		let user=document.getElementById("user");
		user.innerHTML=task;
		let disp2=document.getElementById("disp2");
		disp2.style.display="none";
		let disp=document.getElementById("disp");
		disp.style.display="inline";
		let div=document.getElementById("div");
		div.innerHTML="div1";
	}

	function disp2() {
		var task = getUrlParam('task','Empty');
		task=task.substring(task.search('-')+1);
		let user=document.getElementById("user");
		user.innerHTML=task;
		let disp=document.getElementById("disp");
		disp.style.display="none";
		let disp2=document.getElementById("disp2");
		disp2.style.display="inline";
		let div=document.getElementById("div");
		div.innerHTML="div2";
	}

	function checkBlank() {
		let id=document.getElementById("courseID");
		let name=document.getElementById("courseName");
		let department=document.getElementById("department");
		let teacher=document.getElementById("teacher");
		let time=document.getElementById("time");
		var go;
		if (id.value=="" && name.value=="" && department.value=="" && teacher.value=="" && time.value=="") {
			go=confirm("WARNING: You are about return all courses in the system!");
		}
		else
			go=true;
		return go;
	}

	function checkBlank2() {
		let name2=document.getElementById("courseName2");
		var go=true;
		if (name2.value=="") {
			alert("ERROR: Must build schedule with at least one course.");
			go=false;
		}
		return go;
	}

	function onSubmitForm() {
		var go;
		let div=document.getElementById("div");
		if (div.innerHTML=="div1")
			go=checkBlank();
		else
			go=checkBlank2();
		var url = document.URL;
		url = url.slice(0,url.indexOf("prj"));
		var str=url + "prj2.jsp?task="
		if (div.innerHTML=="div1")
			str += "regEnroll-" + document.getElementById("user").innerHTML;
		else
			str += "smartEnroll-" + document.getElementById("user").innerHTML;
		document.myform2.action=str;
			if (go==true)
				return true;
			else
				return false;
	}

	function getUrlParam(parameter, defaultvalue){
	    var urlparameter = defaultvalue;
	    if(window.location.href.indexOf(parameter) > -1){
	        urlparameter = getUrlVars()[parameter];
	        }
	    return urlparameter;
	}

	function getUrlVars() {
	    var vars = {};
	    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
	        vars[key] = value;
	    });
	    return vars;
	}

</script>

<%@page import="java.sql.*"%>
<%
	String task=new String(request.getParameter("task"));  // Course Lookup, Create Account, Login

	try
	{
		Connection db;
		Class.forName("com.mysql.jdbc.Driver").newInstance();
		String dbUrl,dbUser,dbPass;
		dbUrl = "jdbc:mysql://localhost:3306/scheduling";
		dbUser = "root";
		dbPass = "discipline";
		db= DriverManager.getConnection(dbUrl,dbUser,dbPass);
		Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
    	ResultSet.CONCUR_READ_ONLY);

    	String id=new String(request.getParameter("ID"));
		String password=new String(request.getParameter("password"));


		if (task.contains("Login"))
		{

			String query=new String("SELECT * FROM Users WHERE ua_id='" + id + "'");
			ResultSet rs=stmt.executeQuery(query);

			int num_fields = rs.getMetaData().getColumnCount();

			String retrID=new String("");         // ID retreived from database
			String retrPassword=new String("");   // Password retreived from database
			while (rs.next()) {
				for (int i=0; i<num_fields; ++i)
				{
					if (i==0)
						retrID=rs.getString(i+1);
					else
						retrPassword=rs.getString(i+1);
				}
			}

			if (id.equals("") || password.equals(""))
			{
				out.println("<h3>Please enter a valid ID and password.</h3> (page no longer active)");
				out.println("<br><button onclick='goBack()'>Back</button>");
				return;
			}
			else if (id.equals(retrID) && password.equals(retrPassword))
			{
				out.println("<h3>Successfully logged in!</h3>");

				out.println("<h3>Your Schedule:</h3>");
				query="SELECT * FROM " + id;
				rs=stmt.executeQuery(query);
				num_fields = rs.getMetaData().getColumnCount();
				
				out.println("<table border='1' style='width:50%'>");
				out.println("<tr align = 'center'><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th></tr>");
				while (rs.next()) {
					out.println("<tr>");
					for (int i=0; i<num_fields; ++i)
					{
						out.println("<td align = 'center'>");
						out.println(rs.getString(i+1));
						out.println("</td>");
					}
					out.println("</tr>");
				}
				out.println("</table><br>");

				rs.close();
				out.println("<button onclick='disp()'>Begin Enrollment</button><div class='divider'></div><button onclick='disp2()'>Build Smart Schedule</button><br>");
			}
			else if (id.equals(retrID) && !password.equals(retrPassword))
			{
				out.println("<h3>Your password is incorrect for the ID in our database.</h3> (page no longer active)");
				out.println("<br><button onclick='goBack()'>Back</button>");
				return;
			}
			else
			{
				out.println("<h3>You do not have an account, please create one.</h3> (page no longer active)");
				out.println("<br><button onclick='goBack()'>Back</button>");
				return;
			}
		}

		else if (task.contains("Create"))
		{
			String id2=new String(request.getParameter("ID2"));
			id2 = id2.replaceAll("\\s","");
			String password2=new String(request.getParameter("password2"));

			if (id2.equals("") || password2.equals("")) 
			{
				out.println("<h3>Invalid ID or password.</h3> (page no longer active)");
				out.println("<br><button onclick='goBack()'>Back</button>");
				return;
			}

			ResultSet rs=stmt.executeQuery("SELECT * FROM Users");
			while (rs.next())
			{
				if (id2.equals(rs.getString(1))) {
					out.println("<h3>Username is taken, please try another.</h3> (page no longer active)");
					out.println("<br><button onclick='goBack()'>Back</button>");
					return;
				}
			}

			String query=new String("INSERT into Users (ua_id,ua_password) values ('" + id2 + "','" + password2 + "')");
			stmt.executeUpdate(query);

			query = "CREATE TABLE " + id2 + " (course_id int(10) NULL UNIQUE,course_name char(40) NULL,department_name char(20) NULL,course_teacher char(20) NULL,time_slot char(15) NULL)";
			stmt.executeUpdate(query);

			out.println("<h3>Successfully created account!  You are now logged in and may begin building a schedule.</h3>");
			out.println("<br>");
			out.println("<button onclick='disp()'>Begin Enrollment</button><div class='divider'></div><button onclick='disp2()'>Build Smart Schedule</button><br>");

			rs.close();
		}

		else if (task.contains("Search")) {
			String courseID=new String(request.getParameter("courseID"));
			String department=new String(request.getParameter("department"));
			String oldCourse=new String(request.getParameter("courseName"));
			String course= new String(oldCourse);
			if (oldCourse.contains("'")) {
				course = oldCourse.substring(0,oldCourse.indexOf("'"));
				course += "\\'" + oldCourse.substring(oldCourse.indexOf("'")+1);
			}
			String oldTeacher=new String(request.getParameter("teacher"));
			String teacher = new String(oldTeacher);
			if (oldTeacher.contains("'")) {
				teacher = oldTeacher.substring(0,oldTeacher.indexOf("'"));
				teacher += "\\'" + oldTeacher.substring(oldTeacher.indexOf("'")+1);
			}
			String time=new String(request.getParameter("time"));
			String query=new String("SELECT * FROM Courses WHERE ");
/* choose id */	if (!courseID.equals("")) { /* id must be exact */
					query += "course_id=" + courseID;
				}
/* choose 4 */	else if (!department.equals("") && !teacher.equals("") && !course.equals("") && !time.equals("")) {
					query += "course_teacher LIKE '%" + teacher + "%' AND department_name LIKE '%" + department + "%' AND course_name LIKE '%" + course + "%' AND time_slot LIKE '%" + time + "'%";
				}
/* choose 3 */	else if (!department.equals("") && !teacher.equals("") && !course.equals("")) {
					query += "course_teacher LIKE '%" + teacher + "%' AND department_name LIKE '%" + department + "%' AND course_name LIKE '%" + course + "'%";
				}
				else if (!time.equals("") && !teacher.equals("") && !course.equals("")) {
					query += "course_teacher LIKE '%" + teacher + "%' AND time_slot LIKE '%" + time + "%' AND course_name LIKE '%" + course + "'%";
				}
				else if (!time.equals("") && !department.equals("") && !course.equals("")) {
					query += "department_name LIKE '%" + department + "%' AND time_slot LIKE '%" + time + "%' AND course_name LIKE '%" + course + "'%";
				}
				else if (!time.equals("") && !teacher.equals("") && !department.equals("")) {
					query += "course_teacher LIKE '%" + teacher + "%' AND time_slot LIKE '%" + time + "%' AND department_name LIKE '%" + department + "'%";
				}
/* choose 2 */	else if (!course.equals("") && !department.equals("")) {
					query += "course_name LIKE '%" + course + "%' AND department_name LIKE '%" + department + "%'";
				}
				else if (!course.equals("") && !teacher.equals("")) {
					query += "course_teacher LIKE '%" + teacher + "%' AND course_name LIKE '%" + course + "%'";
				}
				else if (!course.equals("") && !time.equals("")) {
					query += "course_name LIKE '%" + course + "%' AND time_slot LIKE '%" + time + "%'";
				}
				else if (!department.equals("") && !teacher.equals("")) {
					query += "course_teacher LIKE '%" + teacher + "%' AND department_name LIKE '%" + department + "%'";
				}
				else if (!department.equals("") && !time.equals("")) {
					query += "department_name LIKE '%" + department + "%' AND time_slot LIKE '%" + time + "%'";
				}
				else if (!teacher.equals("") && !time.equals("")) {
					query += "course_teacher LIKE '%" + teacher + "%' AND time_slot LIKE '%" + time + "%'";
				}
/* choose 1 */	else if (!course.equals("")) {
					query += "course_name LIKE '%" + course + "%'";
				}
				else if (!department.equals("")) {
					query += "department_name LIKE '%" + department + "%'";
				}
				else if (!teacher.equals("")) {
					query += "course_teacher LIKE '%" + teacher + "%'";
				}
				else if (!time.equals("")) {
					query += "time_slot LIKE '%" + time + "%'";
				}
/* all */		else {
					query = "SELECT * FROM Courses";
				}

			ResultSet rs=stmt.executeQuery(query);
			int num_fields = rs.getMetaData().getColumnCount();			
			if (!rs.next()) {
				out.println("Your search yielded no results. (page no longer active)");
				out.println("<br><button onclick='goBack()'>Back</button>");
				return;
			}
			rs.beforeFirst();
			out.println("<table border='1' style='width:50%'>");
			out.println("<tr align = 'center'><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th></tr>");
			while (rs.next()) {
				out.println("<tr>");
				for (int i=0; i<num_fields; ++i)
				{
					out.println("<td align = 'center'>");
					out.println(rs.getString(i+1));
					out.println("</td>");
				}
				out.println("</tr>");
			}
			out.println("</table>");
			out.println("<br><button onclick='goBack()'>Back</button>");	
			return;	
		}


		stmt.close();
		db.close();
	}

	catch (Exception e) {
		out.println(e.toString());  // Error message to display
	}

%>

<form id="myform2" name="myform2" method="post" onsubmit="return onSubmitForm()">
<div id="disp" style="display:none;"> <br><h3>Please provide some criteria for course search</h3>
	Course ID:<br><textarea style="resize:none;" id="courseID" name="courseID2" cols="20" rows="1"></textarea><br>
	Course Name:<br><textarea style="resize:none;" id="courseName" name="courseName2" cols="20" rows="1"></textarea><br>
	Department:<br><textarea style="resize:none;" id="department" name="department2" cols="20" rows="1"></textarea><br>
	Teacher:<br><textarea style="resize:none;" id="teacher" name="teacher2" cols="20" rows="1"></textarea><br>
	Time:<br><textarea style="resize:none;" id="time" name="time2" cols="20" rows="1" placeholder="'1:00PM-2:15PM'"></textarea><br>
	<br><button>Submit</button>
</div>
<br><div id="disp2" style="display:none;"><br>
<h3>Type the courses in order of priority:</h3><strong><em>Please be exact</em><strong><br><br>
Course Names:<br><textarea style="resize:none;" id="courseName2" name="courseName2Smart" cols="30" rows="7" placeholder="comma separated"></textarea>
<br><button>Submit</button>
</div>
<p id="user" name="user" hidden></p>
<p id="div" hidden>div1</p>
</form>

</body>
</html>