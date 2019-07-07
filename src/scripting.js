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
} /*

function goBack() {
	window.history.back();
}

function disp() {
	var task = getUrlParam('task','Empty');
	task=task.substring(task.search('-')+1);
	let user=document.getElementById("user");
	user.innerHTML=task;
	let disp2=document.getElementById("disp2");
	disp2.style.display="none";
	let disp=document.getElementById("disp");
	disp.style.display="inline";
	let div=document.getElementById("div");
	div.innerHTML="div1";
}

function disp2() {
	var task = getUrlParam('task','Empty');
	task=task.substring(task.search('-')+1);
	let user=document.getElementById("user");
	user.innerHTML=task;
	let disp=document.getElementById("disp");
	disp.style.display="none";
	let disp2=document.getElementById("disp2");
	disp2.style.display="inline";
	let div=document.getElementById("div");
	div.innerHTML="div2";
}

function checkAndSubmit() {
	var go = confirm("WARNING: You are about to remove all classes in your schedule!");
	if (go==true) {
		var task = getUrlParam('task','Empty');
		task=task.substring(task.search('-')+1);
		let user=document.getElementById("user");
		user.innerHTML=task;
		var url = document.URL;
		url = url.slice(0,url.indexOf("prj"));
		var str = url + "prj2.jsp?task=dump-" + user.innerHTML;
		document.myform2.action=str;
		document.getElementById("myform2").submit();
	}
}

function checkBlank() {
	let id=document.getElementById("courseID");
	let name=document.getElementById("courseName");
	let department=document.getElementById("department");
	let teacher=document.getElementById("teacher");
	let time=document.getElementById("time");
	var go;
	if (id.value=="" && name.value=="" && department.value=="" && teacher.value=="" && time.value=="") {
		go=confirm("WARNING: You are about to return all courses in the system!");
	}
	else
		go=true;
	
	return go;
}

function checkBlank2() {
	let name2=document.getElementById("courseName2");
	var go=true;
	if (name2.value=="") {
		alert("ERROR: Must build schedule with at least one course.");
		go=false;
	}
	return go;
}

function onSubmitForm() {
	var go;
	let div=document.getElementById("div");
	if (div.innerHTML=="div1")
		go=checkBlank();
	else
		go=checkBlank2();
	var url = document.URL;
	url = url.slice(0,url.indexOf("prj"));
	var str=url + "prj2.jsp?task="
	if (div.innerHTML=="div1")
		str += "regEnroll-" + document.getElementById("user").innerHTML;
	else
		str += "smartEnroll-" + document.getElementById("user").innerHTML;

	document.myform2.action=str;

	if (go==true)
		return true;
	else
		return false;
}

function onSubmitForm2(id) {
	var task = getUrlParam('task','Empty');
	task=task.substring(task.search('-')+1);
	let user=document.getElementById("user");
	user.innerHTML=task;
	var url = document.URL;
	url = url.slice(0,url.indexOf("prj"));
	var str = url + "prj2.jsp?task=remove-" + user.innerHTML + "/course=" + id;
	document.myform2.action=str;
	document.getElementById("myform2").submit();
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