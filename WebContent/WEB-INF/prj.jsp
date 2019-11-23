<html>
<head>
	<link rel="stylesheet" href="styling.css">
	<script type="text/javascript" src="${pageContext.request.contextPath}/js/scripting.js"></script>
</head>
<body>
<form id="myform2" name="myform2" method="post">
	<%@page import="java.sql.*"%>
	<%@page import="java.util.*"%>
	<%@include file="functions.jsp"%>
	<%
		String task=new String(request.getParameter("task"));  // Course Lookup, Create Account, Login
		String trueID = new String("");

		try {
			Connection db;
//			Class.forName("com.mysql.jdbc.Driver").newInstance();
			String dbUrl,dbUser,dbPass;
			dbUrl = "jdbc:mysql://localhost:3306/Scheduling";
			dbUser = "root";
			dbPass = "discipline";
			db= DriverManager.getConnection(dbUrl,dbUser,dbPass);
			Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

			if (task.equals("Login")) {
				String loginID=new String(request.getParameter("loginID"));
				String loginPassword=new String(request.getParameter("loginPassword"));
				String query=new String("SELECT * FROM Users WHERE ua_id='" + loginID + "'");
				ResultSet rs=stmt.executeQuery(query);
				rs.next();
				int numFields = rs.getMetaData().getColumnCount();
				String retrievedID=new String(rs.getString(1));         // ID retreived from database
				String retrievedPassword=new String(rs.getString(2));   // Password retreived from database
				if (loginID.equals(retrievedID) && !loginPassword.equals(retrievedPassword)) {
					out.println(badPassMsg());
					return;
				}
				if (!loginID.equals(retrievedID)) {
					out.println(badIDMsg());
					return;
				}
				trueID = loginID;
				out.println("<h3>Successfully logged in!</h3>");
				query="SELECT * FROM " + loginID;
				rs=stmt.executeQuery(query);
				String courseTableCommand = "Remove";
				out.println("<h3>Your Schedule:</h3>" + printCoursesTable(rs,courseTableCommand) + "<br>");
				out.println(printOptionsAfterLogin());
				rs.close();
			}

			else if (task.equals("Create")) {
				String createAccountID=new String(request.getParameter("createAccountID"));
				createAccountID = createAccountID.replaceAll("\\s","");
				String createAccountPassword=new String(request.getParameter("createAccountPassword"));
				ResultSet rs=stmt.executeQuery("SELECT * FROM Users");
				boolean IDisTaken = compareIDs(rs,createAccountID);
				if (IDisTaken) {
					out.println(usernameTakenMsg());
					return;
				}
				trueID = createAccountID;
				String query=new String(insertIntoUsersTable(createAccountID,createAccountPassword));
				stmt.executeUpdate(query);
				query = createUserTable(createAccountID);
				stmt.executeUpdate(query);
				out.println("<h3>Successfully created account!  You are now logged in and may begin building a schedule.</h3>");
				out.println("<br>" + printOptionsAfterLogin());
				rs.close();
			}

			else if (task.equals("Search")) {
				String courseID=new String(request.getParameter("courseID"));
				String department=new String(request.getParameter("department"));
				String course=new String(request.getParameter("courseName"));
				course = fixForApostrophe(course);
				String teacher=new String(request.getParameter("teacher"));
				teacher = fixForApostrophe(teacher);
				String time=new String(request.getParameter("time"));
				ArrayList<String> fields = new ArrayList<String>();	
				fields.add(courseID);
				fields.add(department);
				fields.add(course);
				fields.add(teacher);
				fields.add(time);			
				String query = new String(buildCourseSearchQuery(fields));
				ResultSet rs=stmt.executeQuery(query);
				boolean noResults = !rs.next();			
				if (noResults) {
					out.println("Your search yielded no results. (page no longer active)");
					out.println(printBackButton());
					return;
				}
				rs.beforeFirst();
				out.println(printCoursesTable(rs,""));
				out.println(printBackButton());	
				return;	
			}

			stmt.close();
			db.close();
		}

		catch (Exception e) {
			out.println(e.toString());  // Error message to display
		}
	%>
	<div id="courseSearch" class="Form"> <br><h3>Please provide some criteria for course search</h3>
		Course ID:<br><input id="courseID" name="courseSearchID" cols="20" rows="1"><br>
		Course Name:<br><input id="courseName" name="courseSearchName" cols="20" rows="1"><br>
		Department:<br><input id="department" name="courseSearchDepartment" cols="20" rows="1"><br>
		Teacher:<br><input id="teacher" name="courseSearchTeacher" cols="20" rows="1"><br>
		Time:<br><input id="time" name="courseSearchTime" cols="20" rows="1" placeholder="'1:00PM-2:15PM'"><br>
		<br><button type="button" onclick="pageTwoOnSubmitForm2('regEnroll')">Submit</button>
	</div><br>
	<div id="buildSmartSchedule" class="Form"><br>
		<h3>Type the courses in order of priority:</h3><strong><em>Please be exact</em><br><br>
		Course 1:<br><input id="smartScheduleCourseName1" name="smartScheduleCourseName1">
		<br><button type="button" id="courseNum" onclick="addCourse()">Add Course</button><div id="Divider" class="Divider"></div><button  type="button" id="submitButton" onclick="pageTwoOnSubmitForm2('smartEnroll')">Submit</button>
		</strong>
	</div>
	<input id="user" name="user" value="<%=trueID%>" hidden=true>
	<input id="task" name="task" value="" hidden=true>
	<input id="remove" name="remove" value="" hidden=true>
	<input id="smartSchedulingNumCourses" name="smartSchedulingNumCourses" value="1" hidden=true>
</form>
</body>
</html>