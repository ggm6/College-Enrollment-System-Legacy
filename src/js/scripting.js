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
	var go = false;
	if (id.value=="" && name.value=="" && department.value=="" && teacher.value=="" && time.value=="") {
		go=confirm("WARNING: You are about return all courses in the system!");
	}
	else if (id.value!="" && isNaN(parseInt(id.value))) {
		alert("Please enter a valid ID.");
	}
	else
		go=true;

	return go;
}

function setTask(v) {
	let task=document.getElementById("task");
	task.value=v;
}

function pageOneOnSubmitForm(choice) {
	setTask(choice);
	var url = document.URL;
	url = url.replace("index.html","prj.jsp")
	document.myform.action=url;
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

function displayCourseSearch() {
	let buildSmartSchedule=document.getElementById("buildSmartSchedule");
	buildSmartSchedule.style.display="none";
	let courseSearch=document.getElementById("courseSearch");
	courseSearch.style.display="inline";
}

function displayBuildSmartSchedule() {
	let courseSearch=document.getElementById("courseSearch");
	courseSearch.style.display="none";
	let buildSmartSchedule=document.getElementById("buildSmartSchedule");
	buildSmartSchedule.style.display="inline";
}

function buildSmartScheduleCheckBlank() {
	var numCourses = parseInt(document.getElementById("smartSchedulingNumCourses").value);
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

function addCourse() {
	let button = document.getElementById("smartSchedulingNumCourses").value;
	buttonNum = parseInt(button);
	buttonNum = buttonNum + 1;
	document.getElementById("smartSchedulingNumCourses").value = buttonNum;
	button = buttonNum;
	var newLine = document.createElement("input");
	newLine.id = "smartScheduleCourseName" + button;
	newLine.name = "smartScheduleCourseName" + button;
	var divider = document.getElementById("Divider");
	var addCourseButton = document.getElementById("courseNum");
	var submitButton = document.getElementById("submitButton");
	addCourseButton.parentNode.removeChild(addCourseButton);
	divider.parentNode.removeChild(divider);
	submitButton.parentNode.removeChild(submitButton);
	var div = document.getElementById("buildSmartSchedule");
	var text = document.createElement("strong");
	text.innerHTML = "Course " + button + ":";
	div.appendChild(document.createElement("br"));
	div.appendChild(text);
	div.appendChild(document.createElement("br"));
	div.appendChild(newLine);
	div.appendChild(document.createElement("br"));
	div.appendChild(addCourseButton);
	div.appendChild(divider);
	div.appendChild(submitButton);
}


function pageTwoOnSubmitForm1(removeID) {
	setTask('Remove');
	document.getElementById("remove").value = removeID;
	var url = document.URL;
	url = url.replace("prj","prj2");
	document.myform2.action=url;
	document.myform2.submit();
}

function pageTwoOnSubmitForm2(schedulingChoice) {
	setTask(schedulingChoice);
	var go = true;
	if (schedulingChoice=="regEnroll")
		go = courseSearchCheckBlank();
	else if (schedulingChoice=="smartEnroll") 
		go = buildSmartScheduleCheckBlank();
	else if (schedulingChoice=="dump")
		go = confirm("WARNING: You are about to remove all classes in your schedule!");

	var url = document.URL;
	url = url.replace("prj","prj2");
	document.myform2.action=url;
	if (go)
		document.myform2.submit();
}

function enrollWithIDCheckBlank() {
	let id=document.getElementById("courseID3");
	if (id.value=="") {
		alert("Error: Please select actual course ID");
		return false;
	}
	return true;
}

function pageThreeOnSubmitForm1(addID) {
	document.getElementById("add").value = addID;
	var url = document.URL;
	url = url.replace("prj2","prj3");
	document.myform3.action=url;
	document.myform3.submit();
}

function pageThreeOnSubmitForm2(table) {
	var url = document.URL;
	url = url.replace("prj2","prj3");
	var form = document.getElementById("myform3");
	form.action = url;
	var go = true;
	if (table == "")
		go=enrollWithIDCheckBlank();
	else
		document.getElementById("tableNum").value = table;
	if (go)
		form.submit();
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

function close() {
	self.close();
}
