function displayNone() {
	let create=document.getElementById("create");
	create.style.display="none";
	let search=document.getElementById("search");
	search.style.display="none";
	let login=document.getElementById("login");
	login.style.display="none";
}

function verifyStudent() {
	displayNone();
	let loginForm=document.getElementById("login");
	loginForm.style.display="inline";
}

function createAccount() {
	displayNone();
	let createForm=document.getElementById("create");
	createForm.style.display="inline";
}

function findCourse() {
	displayNone();
	let searchForm=document.getElementById("search");
	searchForm.style.display="inline";
}

function courseSearchCheckBlank() {
	let id=document.getElementById("courseID");
	let name=document.getElementById("courseName");
	let department=document.getElementById("department");
	let teacher=document.getElementById("teacher");
	let time=document.getElementById("time");
	var go;
	if (id.value=="" && name.value=="" && department.value=="" && teacher.value=="" && time.value=="") {
		go=confirm("WARNING: You are about return all courses in the system!");
	}
	else
		go=true;

	return go;
}

function setTask(v) {
	v += "/user=";
	if (!document.getElementById("loginID").value=="")
		v += document.getElementById("loginID").value;
	else
		v += document.getElementById("createAccountID").value;
	let task=document.getElementById("task");
	task.innerHTML=v;
	var url = document.URL;
	url = url.replace("index.html","prj.jsp")
	var str=url + "?task=" + document.getElementById("task").innerHTML;
	document.myform.action=str;
}

function pageOneOnSubmitForm(choice) {
	setTask(choice);
	var go=false;

	var v1id=document.getElementById("loginID").value;
	var v1pass=document.getElementById("loginPassword").value;

	var v2id=document.getElementById("createAccountID").value;
	var v2pass=document.getElementById("createAccountPassword").value;

	if (choice=="Search")
		var go=courseSearchCheckBlank();
	else if ((choice=="Create" && v2id.length >= 4 && v2pass.length >= 4))
		go=true;
	else if ((choice=="Login" && v1id.length >= 4 && v1pass.length >= 4))
		go=true;

	if (go==true)
		document.myform.submit();
}


function goBack() {
	window.history.back();
}

function setUser() {
	var task = getUrlParam('task','Empty');
	task=task.substring(task.search('=')+1);
	let user=document.getElementById("user");
	user.innerHTML=task;
}

function displayCourseSearch() {
	setUser();
	let buildSmartSchedule=document.getElementById("buildSmartSchedule");
	buildSmartSchedule.style.display="none";
	let courseSearch=document.getElementById("courseSearch");
	courseSearch.style.display="inline";
}

function displayBuildSmartSchedule() {
	setUser();
	let courseSearch=document.getElementById("courseSearch");
	courseSearch.style.display="none";
	let buildSmartSchedule=document.getElementById("buildSmartSchedule");
	buildSmartSchedule.style.display="inline";
}

function buildSmartScheduleCheckBlank() {
	var numCourses = parseInt(document.getElementById("smartSchedulingNumCourses").innerHTML,10);
	var flag = true;
	var i;
	for (i = 1; i <= numCourses; i++) {
		var name = document.getElementById("smartScheduleCourseName" + i).value;
		if (name != "") {
			flag = false;
			break;
		}
	}

	var go = true;
	if (flag) {
		alert("ERROR: Must build schedule with at least one course.");
		go=false;
	}
	return go;
}

function setSchedulingChoice(choice) {
	if (choice == "regEnroll")
		document.getElementById("schedulingChoice").innerHTML = "regEnroll";
	else if (choice == "smartEnroll")
		document.getElementById("schedulingChoice").innerHTML = "smartEnroll";

	pageTwoOnSubmitForm();
}

function addCourse(buttonNum) {
	buttonNum = buttonNum + 1;
	document.getElementById("smartSchedulingNumCourses").innerHTML = buttonNum;
	var markup = document.documentElement.innerHTML;
	var addition = "<br><br><strong>Course " + buttonNum + ":<br><input id=\"smartScheduleCourseName" + buttonNum + "\"><br>" +
	"<button type=\"button\" id=\"courseNum" + buttonNum + "\" onclick=\"addCourse(" + buttonNum + ")" +
	"\">Add Course</button><div class=\"Divider\"></div><button type=\"button\" id=\"submitButton\" " +
	"onclick=\"setSchedulingChoice('smartEnroll')\">" + "Submit</button>";
	buttonNum = buttonNum - 1;
	markup = markup.replace("<br><button type=\"button\" id=\"courseNum" + buttonNum + "\" onclick=\"addCourse(" + buttonNum + ")" +
	"\">Add Course</button><div class=\"Divider\"></div><button type=\"button\" id=\"submitButton\" " +
	"onclick=\"setSchedulingChoice('smartEnroll')\">" + "Submit</button>",addition);
	document.documentElement.innerHTML = markup;
}

function pageTwoOnSubmitForm() {
	var go;
	let schedulingChoice=document.getElementById("schedulingChoice");
	var url = document.URL;
	url = url.slice(0,url.indexOf("prj"));
	var str=url + "prj2.jsp?task=";

	if (schedulingChoice.innerHTML=="regEnroll") {
		go = courseSearchCheckBlank();
		str += "regEnroll";
	}
	else if (schedulingChoice.innerHTML=="smartEnroll") {
		go = buildSmartScheduleCheckBlank();
		str += "smartEnroll";
	}
	else if (schedulingChoice.innerHTML==""){
		setUser();
		go = confirm("WARNING: You are about to remove all classes in your schedule!");
		str += "dump";
	}
	str += "/user=" + document.getElementById("user").innerHTML;

	document.myform2.action=str;
	if (go)
		document.myform2.submit();
}

function pageThreeOnSubmitForm(id) {
	var task = getUrlParam('task','Empty');
	task=task.substring(task.search('-')+1);
	let user=document.getElementById("user");
	user.innerHTML=task;
	var url = document.URL;
	url = url.slice(0,url.indexOf("prj"));
	var str = url + "prj2.jsp?task=remove-" + user.innerHTML + "/course=" + id;
	document.myform2.action=str;
	document.getElementById("myform3").submit();
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
