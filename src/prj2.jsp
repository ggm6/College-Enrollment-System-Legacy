<html>
<head>
	<link rel="stylesheet" href="styling.css">
	<script type="text/javascript" src="${pageContext.request.contextPath}/js/scripting.js"></script>
</head>
<body>
<form id='myform3' name='myform3' method='post'>
	<%@page import="java.sql.*"%>
	<%@page import="java.util.*"%>
	<%@include file="functions.jsp"%>
	<%
		String task=new String(request.getParameter("task"));
		String user=new String(request.getParameter("user"));

		try {
			Connection db;
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			String dbUrl,dbUser,dbPass;
			dbUrl = "jdbc:mysql://localhost:3306/Scheduling";
			dbUser = "root";
			dbPass = "discipline";
			db= DriverManager.getConnection(dbUrl,dbUser,dbPass);
			Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

			if (task.contains("regEnroll")) {
				String id=new String(request.getParameter("courseSearchID"));
				String department=new String(request.getParameter("courseSearchDepartment"));
				String course= new String(request.getParameter("courseSearchName"));
				course = fixForApostrophe(course);
				String teacher = new String(request.getParameter("courseSearchTeacher"));
				teacher = fixForApostrophe(teacher);
				String time=new String(request.getParameter("courseSearchTime"));
				ArrayList<String> fields = new ArrayList<String>();	
				fields.add(id);
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
				String courseTableCommand = "Add";
				out.println(printCoursesTable(rs, courseTableCommand));
				out.println(printBackButton());	
				rs.close();
			}

			else if (task.contains("smartEnroll")) {
				int numCourses = Integer.parseInt(request.getParameter("smartSchedulingNumCourses"));
				ArrayList<String> inputCourses = new ArrayList<String> ();
				for (int i = 0; i < numCourses; ++i)
					inputCourses.add("");
				int numValidInputCourses = 0;
				numValidInputCourses = getInputSmartCourses(inputCourses,request);
				String query = new String(buildSmartEnrollSearchQuery(inputCourses));
				ResultSet rs=stmt.executeQuery(query);
				boolean noResults = !rs.next();	
				if (noResults) {
					out.println("Your search yielded no results. (page no longer active)");
					out.println(printBackButton());
					return;
				}
				rs.beforeFirst();
				String badCourse = new String(findBadCourse(inputCourses,rs));
				if (!badCourse.equals("")) {
					out.println("\"" + badCourse + "\" is not a real course. (page no longer active)");
					out.println(printBackButton());
					return;
				}
				Schedule allSelectedCourseOptions = new Schedule();
				allSelectedCourseOptions.retrieveCourses(rs);
				int[] courseIndices = new int[numValidInputCourses];
				ArrayList<Schedule> allPossibleSchedules = new ArrayList<Schedule>();

				if (numValidInputCourses <= allSelectedCourseOptions.getNumCourses())
					getAllPossibleSchedules(allPossibleSchedules, allSelectedCourseOptions, numValidInputCourses, courseIndices);

				removeSchedulesWithDuplicateCourses(allPossibleSchedules);
				resolveTimeConflictsInSchedules(allPossibleSchedules,inputCourses);

				int mostClassesInASchedule = findMostClassesInASchedule(allPossibleSchedules);
				removeSchedulesWithFewerClasses(allPossibleSchedules,mostClassesInASchedule);

				if (mostClassesInASchedule != numValidInputCourses)
					out.println("<h3>Unfortunately, it is impossible to take all of those courses next semester</h3>");

				out.println("<h3>Options:</h3><br><br>");
				for (int schedulePos = 0; schedulePos < allPossibleSchedules.size(); ++schedulePos) {
					Schedule schedule = allPossibleSchedules.get(schedulePos);
					String idVals = new String("");
					out.println(printSmartSchedule(schedule,idVals,schedulePos+1));
				}
				out.println(printBackButton());
			}

			else if (task.contains("dump")) {
				Statement stmt2 = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_READ_ONLY);
				String query = new String("SELECT * from " + user);
				ResultSet rs = stmt.executeQuery(query);
				while (rs.next()) {
					query = "DELETE from " + user + " where course_id=";
					query += rs.getString(1);
					stmt2.executeUpdate(query);
				}
				out.println("<h3>All classes removed successfully!</h3><br><br>");
				out.println("<button type='button' onclick='goBack()'>Back</button>");
			}

			else {
				String courseID=new String(request.getParameter("remove"));
				String query = new String("DELETE from " + user + " where course_id=" + courseID);
				stmt.executeUpdate(query);
				out.println("<h3>Class removed successfully!</h3><br><br>");
				out.println("<h3>Your Schedule:</h3><br>");
				query = "SELECT * from " + user;
				ResultSet rs=stmt.executeQuery(query);
				int num_fields = rs.getMetaData().getColumnCount();
				out.println("<table>");
				out.println("<tr><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th></tr>");
				while (rs.next()) {
					out.println("<tr>");
					for (int i=0; i<num_fields; ++i)
					{
						out.println("<td>");
						out.println(rs.getString(i+1));
						out.println("</td>");
					}
					out.println("</tr>");
				}
				out.println("</table><br><br>");
				out.println("<br><button type='button' onclick='goBack()'>Back</button>");

				rs.close();			
			}
			stmt.close();
			db.close();

			}
			catch (Exception e) {
				out.println(e.toString());  // Error message to display
			}
	%>
		<input id="user" name="user" value="<%=user%>" hidden>
		<input id="add" name="add" value="" hidden>
		<input id="scheduleType" name="scheduleType" value="<%=task%>" hidden>
		<input id="tableNum" name="tableNum" value="" hidden>
	</form>
</body>
</html>