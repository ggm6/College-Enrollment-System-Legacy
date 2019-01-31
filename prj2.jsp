<html>
<body>

	<script type="text/javascript">

	function goBack() {
		history.back();
	}

	function setUser(idOPEN) {
		var task = getUrlParam('task','Empty');
		task=task.substring(task.search('-')+1);
		document.getElementById(idOPEN).innerHTML=task;
	}

	function checkBlank() {
		let id=document.getElementById("courseID3");
		if (id.value=="") {
			alert("Error: Please select actual course ID");
			return false;
		}
		return true;
	}

	function onSubmitForm(user) {
		var user1=user;
		setUser(user1);
		var str="http://pausch.cs.uakron.edu:8080/ggm6/prj/prj3.jsp?task=regEnroll-" + document.getElementById("user2").innerHTML;
		document.myform3.action=str;
			var go=checkBlank();
			if (go==true)
				return true;
			return false;
	}

	function onSubmitForm2(user,table) {
		var user2=user;
		setUser(user2);
		var val=document.getElementById(table).value;
		var str="http://pausch.cs.uakron.edu:8080/ggm6/prj/prj3.jsp?task=smartEnroll-[" + val + "]" + document.getElementById("user3").innerHTML;

		document.myform4.action=str;
		document.myform4.submit();
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

	String scheduleType=new String(request.getParameter("task"));
	scheduleType=scheduleType.substring(0,scheduleType.indexOf("-"));
	String user=new String(request.getParameter("task"));
	user=user.substring(user.indexOf("-")+1);

	try {
		if (scheduleType.contains("regEnroll")) 
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
			db= DriverManager.getConnection("jdbc:mysql://db1.cs.uakron.edu:3306/ISP_ggm6","ggm6","Discipline330");
			Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_READ_ONLY);
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
				out.println("</table><br><br>");

			out.println("<form id='myform3' name='myform3' method='post' onsubmit='return onSubmitForm(\"user2\")'><div id='disp'>Enroll w/ Course ID:<br><textarea style='resize:none;' cols='20' rows='1' id='courseID3' name='courseID3'></textarea><br><button>Enroll</button><button type='button' onclick='goBack()'>Back</button></div><p id='user2' name='user2' hidden></p></form>");

			rs.close();
			stmt.close();
			db.close();
		}
		else {

			Connection db;
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			db= DriverManager.getConnection("jdbc:mysql://db1.cs.uakron.edu:3306/ISP_ggm6","ggm6","Discipline330");
			Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_READ_ONLY);

			String oldCourseAll=new String(request.getParameter("courseName2Smart"));
			String newCourseAll[] = oldCourseAll.split("'");
			String courseAll = new String("");
			for (int i=0; i<newCourseAll.length; ++i) {
				if (i==newCourseAll.length-1)
					courseAll += newCourseAll[i];
				else
					courseAll += newCourseAll[i] + "\\'";
			}
			String courses[]=courseAll.split(",");
			for (int i=0; i<courses.length; ++i) {
				courses[i]=courses[i].trim();
			}


			String query=new String("");
			query="SELECT * FROM Courses";
			if (!courses[0].equals("")) {
				for (int i=0; i<courses.length; ++i) {
					if (i==0)
						query += " WHERE course_name='" + courses[0] + "'";
					else
						query += " OR course_name='" + courses[i] + "'";
				}
			}

			ResultSet rs=stmt.executeQuery(query);
			int columnCount=rs.getMetaData().getColumnCount();
			int rsNumRows=0;
			while (rs.next())
				++rsNumRows;
			if (rsNumRows==0) {
				out.println("Your search yielded no results. (page no longer active)");
				out.println("<br><button onclick='goBack()'>Back</button>");
				return;
			}
			rs.beforeFirst();

			ArrayList<ArrayList<String[]>> courseConflicts=new ArrayList<ArrayList<String[]>>(rsNumRows);
			ArrayList<String[]> allCourses = new ArrayList<String[]>(rsNumRows);

				int pos=1;
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
int chooseNum = courses.length;                            // sequence length  

ArrayList<ArrayList<String[]>> subsets = new ArrayList<>();

int[] s = new int[chooseNum];                 // here we'll keep indices 
                                       // pointing to elements in input array

if (chooseNum <= allCourses.size()) {
    // first index sequence: 0, 1, 2, ...
    for (int i = 0; (s[i] = i) < chooseNum - 1; i++);  
    	subsets.add(getSubset(allCourses, s));
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
        subsets.add(getSubset(allCourses, s));
    }
}


for (int i=0; i<subsets.size(); ++i) {
	boolean duplicate=false;
	for (int j=0; j<subsets.get(i).size()-1; ++j) {
		for(int k=j+1;k<subsets.get(i).size();++k){
    		if ( subsets.get(i).get(j)[1].equals(subsets.get(i).get(k)[1]) ) {
    			duplicate=true;
    			break;
    		}
		}
		if (duplicate==true)
			break;
	}
	if (duplicate==true) {
		subsets.remove(i);
		--i;
	}
}

for (int i=0; i<subsets.size(); ++i) {

	int courseFind=courses.length-1;
	while (courseFind>=0) {

		for (int j=0; j<subsets.get(i).size(); ++j) {
			if ( subsets.get(i).get(j)[1].equals(courses[courseFind]) ) {
				String[] course = (subsets.get(i).get(j));
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

				for (int q=0; q<subsets.get(i).size(); ++q) {
					if (q!=j) {
						String[] courseCheck = subsets.get(i).get(q);
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
							subsets.get(i).remove(j);
							j=subsets.get(i).size();
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
for (int i=0; i<subsets.size(); ++i) {
	if (subsets.get(i).size()>maxClasses)
		maxClasses=subsets.get(i).size();
}

for (int i=0; i<subsets.size(); ++i) {
	if (subsets.get(i).size() != maxClasses)
		subsets.remove(i);
} 


if (maxClasses!=courses.length)
	out.println("<h3>Unfortunately, it is impossible to take all of those courses next semester</h3>");

out.println("<h3>Options:</h3><br><br>");

out.println("<form id='myform4' name='myform4' method='post'>");
for (int i=0; i<subsets.size(); ++i) {
	if (subsets.get(i).size() == maxClasses) {

		String idVals = new String("");
		out.println("<table border='1' style='width:50%'>");
		out.println("<tr>");
		out.println("<tr align = 'center'><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th><th><button type='submit' onclick='onSubmitForm2(\"user3\",\"table" + (i+1) + "\")'>Enroll</button><p id='user3' name='user3' hidden></p></th></tr>");

		for (int j=0; j<subsets.get(i).size(); ++j) {
			out.println("<tr>");
			String[] myString = new String[columnCount];
			myString=subsets.get(i).get(j);

			for (int z=0; z<myString.length; ++z) {
				out.println("<td align = 'center'>" + myString[z] + "</td>");
				if (z==0 && j<subsets.get(i).size()-1)
					idVals += (myString[z] + ",");
				else if (z==0 && j == subsets.get(i).size()-1)
					idVals += myString[z];
			}

			out.println("</tr>");
		}
		out.println("</table><input type='hidden' id='table" + (i+1) + "' value='" + idVals + "'/><br><br>");
	}
}
out.println("</form><button onclick='goBack()'>Back</button>");
}
}

	catch (Exception e) {
		out.println(e.toString());  // Error message to display
	}

	%>


</body>
</html>