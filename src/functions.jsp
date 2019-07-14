<%@page import="java.sql.*"%>
<%@page import="java.utils.*"%>
<%!
	public String printCoursesTable(ResultSet rs,boolean isSchedule) {
		String table = "<table>";
		try {
			int num_fields = rs.getMetaData().getColumnCount();
			table += "<tr><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th></tr>";
			while (rs.next()) {
				table += "<tr>";
				String courseID = rs.getString(1);
				for (int i=0; i<num_fields; ++i)
					table += "<td>" + rs.getString(i+1) + "</td>";
				if (isSchedule)
					table += "<td><a href='javascript:pageTwoOnSubmitForm1(" + courseID + ");'>Remove</a></td></tr>";
			}
			table += "</table><br>";
			rs.beforeFirst();
		}
		catch (Exception e) {
			return e.toString();  // Error message to display
		}
		return table;
	}

	public String printBackButton() {
		return "<button type='button' onclick='goBack()'>Back</button>";
	}

	public String printBeginEnrollmentButton() {
		return "<button type='button' onclick='displayCourseSearch()'>Begin Enrollment</button>";
	}

	public String printBuildSmartScheduleButton() {
		return "<button type='button' onclick='displayBuildSmartSchedule()'>Build Smart Schedule</button>";
	}

	public String printDivider() {
		return "<div class='divider'></div>";
	}

	public String printDumpScheduleButton() {
		return "<button type='submit' onclick='pageTwoOnSubmitForm2(\"dump\")'>Dump Schedule</button>";
	}

	public String badPassMsg() {
		String msg = "<h3>Your password is incorrect for the ID in our database.</h3> (page no longer active)";
		return msg + printBackButton();
	}

	public String badIDMsg() {
		String msg = "<h3>You do not have an account, please create one.</h3> (page no longer active)";
		return msg + printBackButton();
	}

	public String usernameTakenMsg() {
		String msg = "<h3>Username is taken, please try another.</h3> (page no longer active)";
		return msg = printBackButton();
	}

	public String printOptionsAfterLogin() {
		return printBeginEnrollmentButton() + printDivider() + printBuildSmartScheduleButton() 
		+ printDivider() + printDumpScheduleButton() + printDivider() + printBackButton();
	}

	public String insertIntoUsersTable(String createAccountID, String createAccountPassword) {
		return "INSERT into Users (ua_id,ua_password) values ('" + createAccountID + "','" + createAccountPassword + "')";
	}

	public String createUserTable(String createAccountID) {
		return "CREATE TABLE " + createAccountID + " (course_id int(10) NULL UNIQUE,course_name char(40) NULL,department_name char(20) NULL,course_teacher char(20) NULL,time_slot char(15) NULL)";
	}

	public boolean compareIDs(ResultSet rs, String createAccountID) throws SQLException {
		while (rs.next()) {
			String retrievedID = rs.getString(1);
			if (createAccountID.equals(retrievedID))
				return true;
		}
		rs.beforeFirst();
		return false;
	}

	public String fixForApostrophe(String oldString) {
		String string = oldString;
		if (oldString.contains("'")) {
			string = oldString.substring(0,oldString.indexOf("'"));
			string += "\\'" + oldString.substring(oldString.indexOf("'")+1);
		}
		return string;
	}

	public boolean allFieldsBlank(ArrayList<String> fields) {
		for (int fieldPos = 0; fieldPos < fields.size(); ++fieldPos) {
			String field = fields.get(fieldPos);
			if (!field.equals(""))
				return false;
		}
		return true;
	}

	public boolean hasCourseID(ArrayList<String> fields) {
		String courseID = fields.get(0);
		if (!courseID.equals(""))
			return true;
		return false;
	}

	public String buildCourseSearchQuery(ArrayList<String> fields) {
		String query = "SELECT * FROM Courses";
		if (allFieldsBlank(fields))
			return query;
		query += " WHERE ";
		String courseID = fields.get(0);
		if (!courseID.equals("")) 
			return query + "course_id=" + courseID;
		ArrayList<String> DBfields = new ArrayList<String>();
		DBfields.add("department_name");
		DBfields.add("course_name");
		DBfields.add("course_teacher");
		DBfields.add("time_slot");
		boolean foundFirst = false;
		for (int fieldPos = 1; fieldPos < fields.size(); ++fieldPos) {
			String field = fields.get(fieldPos);
			String DBfield = DBfields.get(fieldPos-1);
			if (!field.equals("")) {
				if (foundFirst)
					query += " AND ";
				query += DBfield + " LIKE '%" + field + "%'";
				foundFirst = true;
			}
		}
		return query;
	}
%>