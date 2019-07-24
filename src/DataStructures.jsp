<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%!
	public class Course {
		private String id;
		private String name;
		private String department;
		private String teacher;
		private String time;
		private double startTime;
		private double endTime;

		public Course(String[] courseComponents) {
			for (int i = 0; i < courseComponents.length; ++i) {
				String component = courseComponents[i];
				if (i == 0)
					id = component;
				else if (i == 1)
					name = component;
				else if (i == 2)
					department = component;
				else if (i == 3)
					teacher = component;
				else {
					time = component;
					setTimeAsDouble();
				}
			}
		}
		public Course(String id,String name, String department, String teacher, String time) {
			this.id = id;
			this.name = name;
			this.department = department;
			this.teacher = teacher;
			this.time = time;
			setTimeAsDouble();
		}
		public Course(Course course) {
			id = course.id;
			name = course.name;
			department = course.department;
			teacher = course.teacher;
			time = course.time;
			startTime = course.startTime;
			endTime = course.endTime;
		}
		public String getID() {
			return id;
		}
		public String getName() {
			return name;
		}
		public String getDepartment() {
			return department;
		}
		public String getTeacher() {
			return teacher;
		}
		public String getTime() {
			return time;
		}
		private void setTimeAsDouble() {
			String timeArr[] = new String[2];
			timeArr = time.split("-");
			int colonIndex = timeArr[0].indexOf(':');
			String hoursBegin = new String(timeArr[0].substring(0,colonIndex));
			int hoursBeginInt = Integer.parseInt(hoursBegin);
			if (timeArr[0].contains("PM"))
				hoursBeginInt += 12;
			int meridiemStart = timeArr[0].indexOf('M') - 1;  // "AM" or "PM"
			String minutesBegin = new String(timeArr[0].substring(colonIndex+1,meridiemStart));
			int minutesBeginInt = Integer.parseInt(minutesBegin);
			colonIndex=timeArr[1].indexOf(':');
			String hoursEnd = new String(timeArr[1].substring(0,colonIndex));
			int hoursEndInt = Integer.parseInt(hoursEnd);
			if (timeArr[1].contains("PM"))
				hoursEndInt += 12;
			meridiemStart = timeArr[1].indexOf('M') - 1;
			String minutesEnd = new String(timeArr[1].substring(colonIndex+1,meridiemStart));
			int minutesEndInt = Integer.parseInt(minutesEnd);
			startTime = hoursBeginInt + (double) minutesBeginInt/60;
			endTime = hoursEndInt + (double) minutesEndInt/60;
		}
		public double getStartTime() {
			return startTime;
		}
		public double getEndTime() {
			return endTime;
		}
		public String getCourseAsTableData() {
			return "<td>" + id + "</td>" + "<td>" + name + "</td>" + "<td>" + department + "</td>" + "<td>" + teacher + 
			"</td>" + "<td>" + time + "</td>";
		}
	}

	public class Schedule {
		private ArrayList<Course> courses;
		private int numCourses;
		private final int capacity;
		private static final int maxCourses = 1000;

		public Schedule() {
			courses = new ArrayList<Course>();
			capacity = maxCourses;
		}
		public Schedule(Schedule schedule) {
			courses = schedule.courses;
			numCourses = schedule.numCourses;
			capacity = schedule.capacity;
		}
		public Schedule(int capacity) {
			courses = new ArrayList<Course>(capacity);
			this.capacity = capacity;
		}
		public Course getCourseAt(int index) {
			return courses.get(index);
		}
		public void addCourse(Course course) {
			courses.add(course);
			++numCourses;
		}
		public void addCourseAt(int index, Course course) {
			courses.add(index,course);
			++numCourses;
		}
		public void removeCourse(Course course) {
			courses.remove(course);
			--numCourses;
		}
		public void removeCourseAt(int index) {
			courses.remove(index);
			--numCourses;
		}
		public int getNumCourses() {
			return numCourses;
		}
		public void retrieveCourses(ResultSet rs) throws SQLException {
			int columnCount=rs.getMetaData().getColumnCount();
			while (rs.next()) {
				String[] courseComponents=new String[columnCount];
				for (int columnPos = 0; columnPos < columnCount; ++columnPos) {
					courseComponents[columnPos] = rs.getString(columnPos+1);
					courseComponents[columnPos] = courseComponents[columnPos].trim();
				}
				Course course = new Course(courseComponents);
				courses.add(course);
				++numCourses;
			}
			rs.beforeFirst();
		}
		public void removeThisCourseIfTimeConflict(String leastImportantCourse) {
			for (int coursePos = 0; coursePos < numCourses; ++coursePos) {
				String courseName = getCourseAt(coursePos).getName();
				if (courseName.equals(leastImportantCourse)) {
					for (int comparisonCoursePos = 0; comparisonCoursePos < numCourses; ++comparisonCoursePos) {
						if (comparisonCoursePos!=coursePos && hasTimeOverlapAt(coursePos,comparisonCoursePos)) {
							removeCourseAt(coursePos);
							return;
						}
					}
				}
			}
		}
		private boolean hasTimeOverlapAt(int coursePos, int comparisonCoursePos) {
			Course course = getCourseAt(coursePos);
			double courseStartTime = course.getStartTime();
			double courseEndTime = course.getEndTime();
			Course comparisonCourse = getCourseAt(comparisonCoursePos);
			double comparisonCourseStartTime = comparisonCourse.getStartTime();
			double comparisonCourseEndTime = comparisonCourse.getEndTime();
			if ((courseStartTime >= comparisonCourseStartTime) && (courseStartTime <= comparisonCourseEndTime))
				return true;
			else if ((courseEndTime >= comparisonCourseStartTime) && (courseEndTime <= comparisonCourseEndTime))
				return true;

			return false;
		}
	}
%>