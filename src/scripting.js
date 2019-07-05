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

function checkBlank() {
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
	let task=document.getElementById("task");
	if (!document.getElementById("ID").value=="")
		v += "-" + document.getElementById("ID").value;
	else
		v += "-" + document.getElementById("ID2").value;
	task.innerHTML=v;
	var url = document.URL;
	url = url.replace("index.html","prj.jsp")
	var str=url + "?task=" + document.getElementById("task").innerHTML;
	document.myform.action=str;
}

function onSubmitForm(choice) {
	setTask(choice);
	var go=false;

	var v1id=document.getElementById("ID").value;
	var v1pass=document.getElementById("password").value;

	var v2id=document.getElementById("ID2").value;
	var v2pass=document.getElementById("password2").value;

	if (choice=="Search")
		var go=checkBlank();
	else if ((choice=="Create" && v2id.length >= 4 && v2pass.length >= 4))
		go=true;
	else if ((choice=="Login" && v1id.length >= 4 && v1pass.length >= 4))
		go=true;

	if (go==true)
		document.myform.submit();
}