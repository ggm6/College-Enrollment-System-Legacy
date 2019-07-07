<html>
<head>
	<link rel="stylesheet" href="styling.css">
	<script type="text/javascript" src="${pageContext.request.contextPath}/js/scripting.js"></script>
</head>
<body>

<%@page import="java.sql.*"%>
<%
	String task=new String(request.getParameter("task"));  // Course Lookup, Create Account, Login

	try
	{
		Connection db;
		Class.forName("com.mysql.jdbc.Driver").newInstance();
		String dbUrl,dbUser,dbPass;
		dbUrl = "jdbc:mysql://localhost:3306/Scheduling";
		dbUser = "root";
		dbPass = "discipline";
		db= DriverManager.getConnection(dbUrl,dbUser,dbPass);
		Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
    	ResultSet.CONCUR_READ_ONLY);

    	String id=new String(request.getParameter("loginID"));
		String password=new String(request.getParameter("loginPassword"));


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
					String courseID = rs.getString(1);
					for (int i=0; i<num_fields; ++i)
					{
						out.println("<td align = 'center'>");
						out.println(rs.getString(i+1));
						out.println("</td>");
					}
					out.println("<td align = 'center'><a href='javascript:pageTwoOnSubmitForm2(" + courseID + ");'>Remove</a></td>");
					out.println("</tr>");
				}
				out.println("</table><br>");

				rs.close();
				out.println("<button onclick='displayCourseSearch()'>Begin Enrollment</button><div class='divider'></div><button onclick='displayBuildSmartSchedule()'>Build Smart Schedule</button><div class='divider'></div><button onclick='pageTwoOnSubmitForm()'>Dump Schedule</button><div class='divider'></div><button onclick='goBack()'>Back</button><br>");
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
			String id2=new String(request.getParameter("createAccountID"));
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
			out.println("<button onclick='displayCourseSearch()'>Begin Enrollment</button><div class='divider'></div><button onclick='displayBuildSmartSchedule()'>Build Smart Schedule</button><br>");

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

<form id="myform2" name="myform2" method="post">
<div id="courseSearch" style="display:none;"> <br><h3>Please provide some criteria for course search</h3>
	Course ID:<br><input id="courseID" name="courseID2" cols="20" rows="1"></textarea><br>
	Course Name:<br><input id="courseName" name="courseName2" cols="20" rows="1"></textarea><br>
	Department:<br><input id="department" name="department2" cols="20" rows="1"></textarea><br>
	Teacher:<br><input id="teacher" name="teacher2" cols="20" rows="1"></textarea><br>
	Time:<br><input id="time" name="time2" cols="20" rows="1" placeholder="'1:00PM-2:15PM'"></textarea><br>
	<br><button type="button" onclick="setSchedulingChoice('regEnroll')">Submit</button>
</div>
<br><div id="buildSmartSchedule" style="display:none;"><br>
<h3>Type the courses in order of priority:</h3><strong><em>Please be exact</em><br><br>
Course 1:<br><input id="smartScheduleCourseName1">
<br><button type="button" id="courseNum1" onclick="addCourse(1)">Add Course</button><div class="Divider"></div><button type="button" id="submitButton" onclick="setSchedulingChoice('smartEnroll')">Submit</button>
</div>
<p id="user" name="user" hidden></p>
<p id="schedulingChoice" hidden></p>
<p id="smartSchedulingNumCourses" name="smartSchedulingNumCourses" hidden>1</p>
</form>

</body>
</html>