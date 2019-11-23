<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@include file="DataStructures.jsp"%>
<%!
	public String printCoursesTable(ResultSet rs, String courseTableCommand) throws SQLException {
		rs.beforeFirst();
		String table = "<table>";
		int num_fields = rs.getMetaData().getColumnCount();
		table += "<tr><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th></tr>";
		while (rs.next()) {
			table += "<tr>";
			String courseID = rs.getString(1);
			for (int i=0; i<num_fields; ++i)
				table += "<td>" + rs.getString(i+1) + "</td>";
			if (courseTableCommand == "Remove")
				table += "<td><a href='javascript:pageTwoOnSubmitForm1(" + courseID + ");'>Remove</a></td></tr>";
			else if (courseTableCommand == "Add")
				table += "<td><a href='javascript:pageThreeOnSubmitForm1(" + courseID + ");'>Add</a></td></tr>";
		}
		table += "</table><br>";
		rs.beforeFirst();
		return table;
	}

	public String printSmartSchedule(Schedule schedule, String idVals, int scheduleNum) {  // another <tr> after <table> ???
		String table = "<table><tr><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th><th class='specialTh'><button type='button' onclick='pageThreeOnSubmitForm2(\"table" + scheduleNum + "\")'>Enroll</button></th></tr>";
		for (int coursePos = 0; coursePos < schedule.getNumCourses(); ++coursePos) {
			table += "<tr>";
			Course course = schedule.getCourseAt(coursePos);
			table += course.getCourseAsTableData();
			if (coursePos < schedule.getNumCourses()-1)
				idVals += course.getID() + ",";
			else
				idVals += course.getID();
			table += "</tr>";
		}
		table += "</table><input hidden=true id='table" + scheduleNum + "' name='table" + scheduleNum + "' value='" + idVals + "'/><br><br>";
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
		rs.beforeFirst();
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

	public String buildSmartEnrollSearchQueryByName(ArrayList<String> courses) {
		String query = "SELECT * FROM Courses";
		boolean foundFirst = false;
		for (int pos = 0; pos < courses.size(); ++pos) {
			String course = courses.get(pos);
			if (foundFirst)
				query += " OR course_name='" + course + "'";
			else {
				query += " WHERE course_name='" + course + "'";
				foundFirst = true;
			}	
		}
		return query;
	}

	public String buildSmartEnrollSearchQueryByIDs(String[] IDs) {
		String query = "SELECT * FROM Courses";
		boolean foundFirst = false;
		for (int i = 0; i < IDs.length; ++i) {
			String id = IDs[i];
			if (!id.equals("")) {
				if (foundFirst)
					query += " OR course_id=" + id;
				else {
					query += " WHERE course_id=" + id;
					foundFirst = true;
				}	
			}
		}	
		return query;
	}

	public String buildEnrollInsertQuery(ArrayList<String> fields, String user) {
		int num_fields = fields.size();
		String query="INSERT INTO " + user + " values (";
		for (int fieldPos = 0; fieldPos < num_fields; ++fieldPos) {
			String field = fields.get(fieldPos);
			field = fixForApostrophe(field);
			if (fieldPos == 0)
				query += field;
			else
				query += ",'" + field + "'";
		}
		query += ")";
		return query;
	}

	public int getInputSmartCourses(ArrayList<String> courses, javax.servlet.http.HttpServletRequest request) {
		int numValidCourses = 0;
		for (int pos = 0; pos < courses.size(); ++pos) {
			String parameter = "smartScheduleCourseName" + (pos+1);
			String courseName = request.getParameter(parameter).trim();
			if (courseName.equals("")) {
				courses.remove(pos);
				--pos;
			}
			else {
				courses.set(pos,courseName);
				++numValidCourses;
			}
		}
		return numValidCourses;
	}

	public String findBadCourse(ArrayList<String> courses, ResultSet rs) throws SQLException {
		rs.beforeFirst();
		for (int pos = 0; pos < courses.size(); ++pos) {
			String inputCourse = courses.get(pos);
			boolean badCourse = true;
			while (rs.next()) {
				String retrievedCourse = rs.getString(2);
				if (inputCourse.equals(retrievedCourse)) {
					badCourse = false;
					break;
				}
			}
			rs.beforeFirst();
			if (badCourse)
				return inputCourse;
		}
		rs.beforeFirst();
		return "";
	}

	public Schedule getScheduleByIndexSequence(Schedule inputSchedule, int[] courseIndices) {
		Schedule result = new Schedule(courseIndices.length);
		for (int pos = 0; pos < courseIndices.length; ++pos) {
			int index = courseIndices[pos];
			Course course = inputSchedule.getCourseAt(index);
	        result.addCourseAt(pos, course);
	    }
	    return result;
	}

	public void getAllPossibleSchedules(ArrayList<Schedule> allPossibleSchedules, Schedule allSelectedCourseOptions, int numValidInputCourses) {
		/* Following code adapted from: 
				 https://stackoverflow.com/questions/29910312/algorithm-to-get-all-the-combinations-of-size-n-from-an-array-java
			by answerer: Alex Salauyou
		*/

		int[] courseIndices = new int[numValidInputCourses];

		// first index sequence: 0, 1, 2, ...
	    for (int i = 0; (courseIndices[i] = i) < numValidInputCourses - 1; i++);
	    {
	    	Schedule schedule = getScheduleByIndexSequence(allSelectedCourseOptions, courseIndices);
	    	allPossibleSchedules.add(schedule);
	    }

	    for(;;) {
	        int i;
	        // find position of item that can be incremented
	        for (i = numValidInputCourses - 1; i >= 0 && courseIndices[i] == allSelectedCourseOptions.getNumCourses() - numValidInputCourses + i; i--); 
	        if (i < 0) {
	            break;
	        }
	        courseIndices[i]++;                    // increment this item
	        for (++i; i < numValidInputCourses; i++) {    // fill up remaining items
	            courseIndices[i] = courseIndices[i-1] + 1; 
	        }
	        Schedule schedule = getScheduleByIndexSequence(allSelectedCourseOptions, courseIndices);
	        allPossibleSchedules.add(schedule);
	    }
	}

	public void removeSchedulesWithDuplicateCourses(ArrayList<Schedule> allPossibleSchedules) {
		for (int schedulePos = 0; schedulePos < allPossibleSchedules.size(); ++schedulePos) {
			Schedule schedule = allPossibleSchedules.get(schedulePos);
			for (int coursePos=0; coursePos < schedule.numCourses-1; ++coursePos) {
				Course course = schedule.getCourseAt(coursePos);
				String courseName = course.getName();
				for(int comparisonCoursePos = coursePos+1; comparisonCoursePos < schedule.numCourses; ++comparisonCoursePos) {
					Course comparisonCourse = schedule.getCourseAt(comparisonCoursePos);
					String comparisonCourseName = comparisonCourse.getName();
		    		if (courseName.equals(comparisonCourseName)) {
		    			allPossibleSchedules.remove(schedulePos);
						--schedulePos;
						coursePos = schedule.numCourses;
		    			break;
		    		}
				}
			}
		}
	}

	public int findMostClassesInASchedule(ArrayList<Schedule> allPossibleSchedules) {
		int mostClassesInASchedule = 0;
		for (int schedulePos = 0; schedulePos < allPossibleSchedules.size(); ++schedulePos) {
			Schedule schedule = allPossibleSchedules.get(schedulePos);
			if (schedule.getNumCourses() > mostClassesInASchedule)
				mostClassesInASchedule = schedule.numCourses;
		}
		return mostClassesInASchedule;
	}

	public void removeSchedulesWithFewerClasses(ArrayList<Schedule> allPossibleSchedules, int mostClassesInASchedule) {
		for (int schedulePos = 0; schedulePos < allPossibleSchedules.size(); ++schedulePos) {
			Schedule schedule = allPossibleSchedules.get(schedulePos);
			if (schedule.getNumCourses() != mostClassesInASchedule) {
				allPossibleSchedules.remove(schedulePos);
				--schedulePos;
			}
		} 
	}

	public void resolveTimeConflictsInSchedules(ArrayList<Schedule> allPossibleSchedules, ArrayList<String> inputCourses) {
		for (int schedulePos = 0; schedulePos < allPossibleSchedules.size(); ++schedulePos) {
			Schedule schedule = allPossibleSchedules.get(schedulePos);
			// inputCourses are in order of priority
			for (int priority = inputCourses.size()-1; priority >= 0; --priority) {  
				String currentLeastImportantCourse = inputCourses.get(priority);
				int coursePos = schedule.findThisCourse(currentLeastImportantCourse);
				if (coursePos != -1)
					schedule.removeHereIfTimeConflict(coursePos);
			}
			allPossibleSchedules.set(schedulePos,schedule);
		}
	}

	public boolean userIsEnrolledInCourse(ResultSet rs, String courseID) throws SQLException {
		rs.beforeFirst();
		while (rs.next()) {
			if (courseID.equals(rs.getString(1))) {
				rs.beforeFirst();
				return true;
			}
		}
		rs.beforeFirst();
		return false;
	}

	public ArrayList<String> fillFieldsFromResultSet(ResultSet rs) throws SQLException {
		ArrayList<String> fields = new ArrayList<String>();
		int num_fields = rs.getMetaData().getColumnCount();
		for (int fieldPos = 0; fieldPos < num_fields; ++fieldPos) {
			String field = rs.getString(fieldPos+1);
			fields.add(field);
		}
		return fields;
	}

	public ArrayList<String> getStatusOfEnrollment(ResultSet rs, String[] IDs) throws SQLException {
		rs.beforeFirst();
		ArrayList<String> enrollStatusMsges = new ArrayList<String>();
		for (int i = 0; i < IDs.length; ++i) {
			String id = IDs[i];
			if (userIsEnrolledInCourse(rs, id))
				enrollStatusMsges.add("<h4>You are already enrolled in " + id + "!</h4><br>");
			else
				enrollStatusMsges.add("<h4>" + id + " added successfully!</h4><br>");
		}
		rs.beforeFirst();
		return enrollStatusMsges;
	}

	public String printEnrollStatusMsges(ArrayList<String> msges) {
		String bigMsg = "";
		for (int i = 0; i < msges.size(); ++i) {
			String msg = msges.get(i);
			bigMsg += msg;
		}
		return bigMsg;
	}

	public String[] removeCoursesUserIsIn(ResultSet rs, String[] IDs) throws SQLException {
		rs.beforeFirst();
		String[] newIDs = IDs;
		for (int i = 0; i < newIDs.length; ++i) {
			String id = newIDs[i];
			if (userIsEnrolledInCourse(rs,id))
				newIDs[i] = "";
		}
		rs.beforeFirst();
		return newIDs;
	}
%>