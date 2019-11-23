<html>
<head>
	<link rel="stylesheet" href="styling.css">
	<script type="text/javascript" src="${pageContext.request.contextPath}/js/scripting.js"></script>
</head>
<body>
	<%@page import="java.sql.*"%>
	<%@include file="functions.jsp"%>
	<%
		String scheduleType=new String(request.getParameter("scheduleType"));
		String id=new String(request.getParameter("add"));
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

			if (scheduleType.contains("regEnroll")) {
				String query=new String("SELECT * FROM " + user);
				ResultSet rs=stmt.executeQuery(query);
				if (userIsEnrolledInCourse(rs,id)) {
					out.println("<h3>Error: you are already enrolled in this course! (page no longer active)</h3><br>"); out.println(printBackButton());
					return;
				}

				query = "SELECT * FROM Courses WHERE course_id=" + id;
				rs = stmt.executeQuery(query);
				ArrayList<String> fields = new ArrayList<String>();
				fields = fillFieldsFromResultSet(rs);
				query = buildEnrollInsertQuery(fields, user);
				stmt.executeUpdate(query);

				out.println("<h3>Class Added Successfully!</h3><br>");
				out.println("<h3>Your Schedule:</h3><br>");
				query="SELECT * FROM " + user;
				rs=stmt.executeQuery(query);
				out.println(printCoursesTable(rs,""));
				out.println(printBackButton());
				rs.close();
			}

			else if (scheduleType.contains("smartEnroll")) {
				String table = new String(request.getParameter("tableNum"));
				String ids = new String(request.getParameter(table));
				String[] IDs = ids.split(",");

				String query=new String("SELECT * FROM " + user);
				ResultSet rs=stmt.executeQuery(query);
				ArrayList<String> enrollStatusMsges = new ArrayList<String>();
				enrollStatusMsges = getStatusOfEnrollment(rs,IDs);
				out.println(printEnrollStatusMsges(enrollStatusMsges));
				IDs = removeCoursesUserIsIn(rs,IDs);


				query = buildSmartEnrollSearchQueryByIDs(IDs);
				rs = stmt.executeQuery(query);
				ArrayList<String> fields;
				Statement stmt2 = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
				while (rs.next()) {
					fields = new ArrayList<String>( fillFieldsFromResultSet(rs) );
					query = buildEnrollInsertQuery(fields, user);
					stmt2.executeUpdate(query);
				}

				out.println("<h3>Your Schedule:</h3><br>");
				query="SELECT * FROM " + user;
				rs = stmt.executeQuery(query);
				out.println(printCoursesTable(rs,""));
				out.println(printBackButton());

				rs.close();
			}

			stmt.close();
			db.close();
		}

		catch (Exception e) {
			out.println(e.toString());  // Error message to display
		}
	%>
</body>
</html>