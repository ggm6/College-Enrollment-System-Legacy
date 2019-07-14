<%@page import="java.util.*"%>
<%!
	public class Course {
		private String id;
		private String name;
		private String department;
		private String teacher;
		private String time;

		public Course(String id,String name, String department, String teacher, String time) {
			this.id = id;
			this.name = name;
			this.department = department;
			this.teacher = teacher;
			this.time = time;
		}
		public boolean idEquals(String id) {
			return (this.id).equals(id);
		}
		public boolean nameEquals(String name) {
			return (this.name).equals(name);
		}
		public boolean departmentEquals(String department) {
			return (this.department).equals(department);
		}
		public boolean teacherEquals(String teacher) {
			return (this.teacher).equals(teacher);
		}
		public boolean timeEquals(String time) {
			return (this.time).equals(time);
		}
	}

	public class Schedule {
		private ArrayList<Course> courses;

		public Schedule() {
			courses = new ArrayList<Course>();
		}
		public void addCourse(Course course) {
			courses.add(course);
		}
		public void addCourseAt(int index, Course course) {
			courses.add(index,course);
		}
		public void removeCourse(Course course) {
			courses.remove(course);
		}
		public void removeCourseAt(int index) {
			courses.remove(index);
		}
	}
%>