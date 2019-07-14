<html>
<head>
	<link rel="stylesheet" href="styling.css">
	<script type="text/javascript" src="${pageContext.request.contextPath}/js/scripting.js"></script>
</head>
<body>
	<form id='myform3' name='myform3' method='post'>
		<%@page import="java.sql.*"%>
		<%@page import="java.util.*"%>

		<%!	// generate actual subset by index sequence
			ArrayList<String[]> getSubset(ArrayList<String[]> input, int[] subset) {
			    ArrayList<String[]> result = new ArrayList<String[]>(subset.length); 
			    for (int i = 0; i < subset.length; i++) 
			        result.add(i,input.get(subset[i]));
			    return result;
			}
		%>

		<%
				String task=new String(request.getParameter("task"));
				String user=new String(request.getParameter("user"));

				try {
					if (task.contains("regEnroll")) 
					{

						String id=new String(request.getParameter("courseID2"));
						String department=new String(request.getParameter("department2"));
						String oldCourse=new String(request.getParameter("courseName2"));
						String course= new String(oldCourse);
						if (oldCourse.contains("'")) {
							course = oldCourse.substring(0,oldCourse.indexOf("'"));
							course += "\\'" + oldCourse.substring(oldCourse.indexOf("'")+1);
						}
						String oldTeacher=new String(request.getParameter("teacher2"));
						String teacher = new String(oldTeacher);
						if (oldTeacher.contains("'")) {
							teacher = oldTeacher.substring(0,oldTeacher.indexOf("'"));
							teacher += "\\'" + oldTeacher.substring(oldTeacher.indexOf("'")+1);
						}
						String time=new String(request.getParameter("time2"));
						String query=new String("SELECT * FROM Courses WHERE ");

			/* choose id */	if (!id.equals("")) { /* id must be exact */
								query += "course_id=" + id;
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

						Connection db;
						Class.forName("com.mysql.jdbc.Driver").newInstance();
						db= DriverManager.getConnection("jdbc:mysql://localhost:3306/Scheduling","root","discipline");
						Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_READ_ONLY);
						ResultSet rs=stmt.executeQuery(query);
						int num_fields = rs.getMetaData().getColumnCount();			
						if (!rs.next()) {
							out.println("Your search yielded no results. (page no longer active)");
							out.println("<br><button type='button' onclick='goBack()'>Back</button>");
							return;
						}
					
							rs.beforeFirst();
							out.println("<table>");
							out.println("<tr><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th></tr>");
							while (rs.next()) {
								out.println("<tr>");
								String courseID = rs.getString(1);
								for (int i=0; i<num_fields; ++i)
								{
									out.println("<td>");
									out.println(rs.getString(i+1));
									out.println("</td>");
								}
								out.println("<td><a href='javascript:pageThreeOnSubmitForm1(" + courseID + ");'>Add</a></td>");
								out.println("</tr>");
							}
							out.println("</table><br><br>");
							out.println("<button type='button' onclick='goBack()'>Back</button>");

						rs.close();
						stmt.close();
						db.close();
					}
					else if (task.contains("smartEnroll")) {
						Connection db;
						Class.forName("com.mysql.jdbc.Driver").newInstance();
						db= DriverManager.getConnection("jdbc:mysql://localhost:3306/scheduling","root","discipline");
						Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_READ_ONLY);

						int numCourses = Integer.parseInt(request.getParameter("smartSchedulingNumCourses"));
						int chooseNum = 0;   // sequence length
						String courses[] = new String[numCourses];

						for (int i=0; i<numCourses; ++i) {
							String param = "smartScheduleCourseName" + (i+1);
							courses[i] = request.getParameter(param);
							courses[i]=courses[i].trim();
						}


						String query=new String("");
						query="SELECT * FROM Courses";
						boolean findFirst = false;
						for (int i=0; i<courses.length; ++i) {
							if (courses[i] != "") {
								++chooseNum;
								if (findFirst == false) {
									query += " WHERE course_name='" + courses[0] + "'";
									findFirst = true;
								}
								else
									query += " OR course_name='" + courses[i] + "'";
							}
						}

						ResultSet rs=stmt.executeQuery(query);
						int columnCount=rs.getMetaData().getColumnCount();
						int rsNumRows=0;
						for (int i=0; i<courses.length; ++i) {
							boolean badCourse = true;
							while (rs.next()) {
								if (rs.getString(2).equals(courses[i])) {
									badCourse = false;
									break;
								}
							}
							if (badCourse) {
								out.println("\"" + courses[i] + "\" is not a real course. (page no longer active)");
								out.println("<br><button type='button' onclick='goBack()'>Back</button>");
								return;
							}
							rs.beforeFirst();
						}
						while (rs.next())
							++rsNumRows;
						if (rsNumRows==0) {
							out.println("Your search yielded no results. (page no longer active)");
							out.println("<br><button type='button' onclick='goBack()'>Back</button>");
							return;
						}
						rs.beforeFirst();

						ArrayList<ArrayList<String[]>> courseConflicts=new ArrayList<ArrayList<String[]>>(rsNumRows);
						ArrayList<String[]> allCourses = new ArrayList<String[]>(rsNumRows);

							while (rs.next()) {
								String[] course=new String[columnCount];
								for (int j=0; j<columnCount; ++j) {
									course[j] = rs.getString(j+1);
									course[j]=course[j].trim();
								}
								allCourses.add(course);
							}
							rs.beforeFirst();
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			/* Following code adapted from: 
				 https://stackoverflow.com/questions/29910312/algorithm-to-get-all-the-combinations-of-size-n-from-an-array-java
			   by answerer: Alex Salauyou
			*/

			ArrayList<ArrayList<String[]>> schedules = new ArrayList<>();

			int[] s = new int[chooseNum];                 // here we'll keep indices 
			                                       // pointing to elements in input array

			if (chooseNum <= allCourses.size()) {
			    // first index sequence: 0, 1, 2, ...
			    for (int i = 0; (s[i] = i) < chooseNum - 1; i++);  
			    	schedules.add(getSubset(allCourses, s));
			    for(;;) {
			        int i;
			        // find position of item that can be incremented
			        for (i = chooseNum - 1; i >= 0 && s[i] == allCourses.size() - chooseNum + i; i--); 
			        if (i < 0) {
			            break;
			        }
			        s[i]++;                    // increment this item
			        for (++i; i < chooseNum; i++) {    // fill up remaining items
			            s[i] = s[i-1] + 1; 
			        }
			        schedules.add(getSubset(allCourses, s));
			    }
			}
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			for (int i=0; i<schedules.size(); ++i) {
				boolean duplicate=false;
				for (int j=0; j<schedules.get(i).size()-1; ++j) {
					for(int k=j+1;k<schedules.get(i).size();++k){
			    		if ( schedules.get(i).get(j)[1].equals(schedules.get(i).get(k)[1]) ) {
			    			duplicate=true;
			    			break;
			    		}
					}
					if (duplicate==true)
						break;
				}
				if (duplicate==true) {
					schedules.remove(i);
					--i;
				}
			}

			for (int i=0; i<schedules.size(); ++i) {

				int courseFind=courses.length-1;
				while (courseFind>=0) {

					for (int j=0; j<schedules.get(i).size(); ++j) {
						if ( schedules.get(i).get(j)[1].equals(courses[courseFind]) ) {
							String[] course = (schedules.get(i).get(j));
							String time[]=new String[2];
							time=course[columnCount-1].split("-");
							int index=time[0].indexOf(':');
							String hoursBegin=new String(time[0].substring(0,index));
								int hoursBeginInt=Integer.parseInt(hoursBegin);
								if (time[0].contains("PM"))
									hoursBeginInt += 12;
							String minutesBegin=new String(time[0].substring(index+1,time[0].indexOf('M')-1));
								int minutesBeginInt=Integer.parseInt(minutesBegin);
							index=time[1].indexOf(':');
							String hoursEnd=new String(time[1].substring(0,index));
								int hoursEndInt=Integer.parseInt(hoursEnd);
								if (time[1].contains("PM"))
									hoursEndInt += 12;
							String minutesEnd=new String(time[1].substring(index+1,time[1].indexOf('M')-1));
								int minutesEndInt=Integer.parseInt(minutesEnd);

							double[] totalTime=new double[2];
							totalTime[0]=hoursBeginInt+(double) minutesBeginInt/60;
							totalTime[1]=hoursEndInt+(double) minutesEndInt/60;

							for (int q=0; q<schedules.get(i).size(); ++q) {
								if (q!=j) {
									String[] courseCheck = schedules.get(i).get(q);
									String checkTime[]=new String[2];
									checkTime=courseCheck[columnCount-1].split("-");
									index=checkTime[0].indexOf(':');
									String checkHoursBegin=new String(checkTime[0].substring(0,index));
										int checkHoursBeginInt=Integer.parseInt(checkHoursBegin);
										if (checkTime[0].contains("PM"))
											checkHoursBeginInt += 12;
									String checkMinutesBegin=new String(checkTime[0].substring(index+1,checkTime[0].indexOf('M')-1));
										int checkMinutesBeginInt=Integer.parseInt(checkMinutesBegin);
									index=checkTime[1].indexOf(':');
									String checkHoursEnd=new String(checkTime[1].substring(0,index));
										int checkHoursEndInt=Integer.parseInt(checkHoursEnd);
										if (checkTime[1].contains("PM"))
											checkHoursEndInt += 12;
									String checkMinutesEnd=new String(checkTime[1].substring(index+1,checkTime[1].indexOf('M')-1));
										int checkMinutesEndInt=Integer.parseInt(checkMinutesEnd);

									double checkTotalTime[]=new double[2];
									checkTotalTime[0]=checkHoursBeginInt+(double) checkMinutesBeginInt/60;
									checkTotalTime[1]=checkHoursEndInt+(double) checkMinutesEndInt/60;

									if ( ((totalTime[0] >= checkTotalTime[0]) && (totalTime[0] <= checkTotalTime[1])) || ((totalTime[1] >= checkTotalTime[0]) && (totalTime[1] <= checkTotalTime[1])) ) {
										schedules.get(i).remove(j);
										j=schedules.get(i).size();
										break;
									}
								}
							}
						}
					}
					--courseFind;
				}
			}

			int maxClasses=0;
			for (int i=0; i<schedules.size(); ++i) {
				if (schedules.get(i).size()>maxClasses)
					maxClasses=schedules.get(i).size();
			}

			for (int i=0; i<schedules.size(); ++i) {
				if (schedules.get(i).size() != maxClasses)
					schedules.remove(i);
			} 


			if (maxClasses!=chooseNum)
				out.println("<h3>Unfortunately, it is impossible to take all of those courses next semester</h3>");

			out.println("<h3>Options:</h3><br><br>");

			for (int i=0; i<schedules.size(); ++i) {
				if (schedules.get(i).size() == maxClasses) {
					String idVals = new String("");
					out.println("<table>");
					out.println("<tr>");
					out.println("<tr><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th><th class='specialTh'><button type='button' onclick='pageThreeOnSubmitForm2(\"table" + (i+1) + "\")'>Enroll</button></th></tr>");

					for (int j=0; j<schedules.get(i).size(); ++j) {
						out.println("<tr>");
						String[] myString = new String[columnCount];
						myString=schedules.get(i).get(j);

						for (int z=0; z<myString.length; ++z) {
							out.println("<td>" + myString[z] + "</td>");
							if (z==0 && j<schedules.get(i).size()-1)
								idVals += (myString[z] + ",");
							else if (z==0 && j == schedules.get(i).size()-1)
								idVals += myString[z];
						}

						out.println("</tr>");
					}
					out.println("</table><input type='hidden' id='table" + (i+1) + "' name='table" + (i+1) + "' value='" + idVals + "'/><br><br>");
				}
			}
			out.println("<button type='button' onclick='goBack()'>Back</button>");
			}

			else if (task.contains("dump")) {
				Connection db;
				Class.forName("com.mysql.jdbc.Driver").newInstance();
				db= DriverManager.getConnection("jdbc:mysql://localhost:3306/Scheduling","root","discipline");
				Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_READ_ONLY);
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
				Connection db;
				Class.forName("com.mysql.jdbc.Driver").newInstance();
				db= DriverManager.getConnection("jdbc:mysql://localhost:3306/scheduling","root","discipline");
				Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_READ_ONLY);
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
				stmt.close();
				db.close();
				
			}

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