window.onload=function(){
	document.body.innerHTML = document.body.innerHTML + '<iframe id="playerlist_loader" name="playerlist_loader" src="dynamic.php?job=players" onload="update(\'playerlist_loader\',\'playerlist\');" class="hidden"></iframe>';
	document.body.innerHTML = document.body.innerHTML + '<iframe id="stats_loader" name="stats_loader" src="dynamic.php?job=stats" onload="updatestats(\'stats_loader\',\'players\',\'matches\',30000)" class="hidden"></iframe>';
	document.body.innerHTML = document.body.innerHTML + '<iframe id="viewplayer_loader" name="viewplayer_loader" onload="vpupdate(\'viewplayer_loader\',\'viewplayer\');" class="hidden"></iframe>';
	document.body.innerHTML = document.body.innerHTML + '<iframe id="search_loader" name="search_loader" onload="update(\'search_loader\',\'searchresults\');" class="hidden"></iframe>';
	document.body.innerHTML = document.body.innerHTML + '<iframe id="pickups_loader24" name="pickups_loader24" src="dynamic.php?job=recentmatches" onload="update(\'pickups_loader24\',\'pickups24\');" class="hidden"></iframe>';
	document.body.innerHTML = document.body.innerHTML + '<iframe id="viewpickup_loader" name="viewpickup_loader" onload="pikupdate(\'viewpickup_loader\',\'viewpickup\');" class="hidden"></iframe>';
}

function getFrameContent(iframeID){
	return window.frames[iframeID].document.body.innerHTML;
}

//Tabs
var lastTab = 'pickups24';

function update(iframeID,destinationID){
	document.getElementById(destinationID).innerHTML = getFrameContent(iframeID);
}
function changeTab(showID){
	if(showID!=lastTab){
		document.getElementById(showID).style.display='block';
		document.getElementById(showID).style.visibility='visible';
		document.getElementById(lastTab).style.display='none';
		document.getElementById(lastTab).style.visibility='hidden';
	
		document.getElementById('btn_' + showID).className='selected';
		document.getElementById('btn_' + lastTab).className='';
	
		lastTab = showID;
	}
}


//Player List
var plPage = 0;
var pikFirstLoad = 0;

function viewpickup(id){
	document.getElementById('viewpickup_loader').src = 'dynamic.php?job=viewpickup&id=' + id;
}
function pikupdate(iframeID,destinationID){
	if(pikFirstLoad==0){
		pikFirstLoad = 1;
	} else {
		update(iframeID,destinationID);
		changeTab('viewpickup');
	}
	setTimeout('pikupdate(\'' + iframeID + '\',\'' + destinationID + '\'',60000);
}
function plmore(){
	plPage = plPage + 1;
	document.getElementById('playerlist').innerHTML = '';
	document.getElementById('playerlist_loader').src = 'dynamic.php?job=players&page=' + plPage;
}
function plless(){
	plPage = plPage - 1;
	document.getElementById('playerlist').innerHTML = '';
	document.getElementById('playerlist_loader').src = 'dynamic.php?job=players&page=' + plPage;
}


//View Player
var vpFirstLoad = 0;

function viewplayer(playerQAuth){
	document.getElementById('viewplayer_loader').src = 'dynamic.php?job=view&player=' + playerQAuth;
}
function vpupdate(iframeID,destinationID){
	if(vpFirstLoad==0){
		vpFirstLoad = 1;
	} else {
		update(iframeID,destinationID);
		changeTab('viewplayer');
	}
}


//Statistics
function updatestats(iframeID,playersID,matchesID,timeout){
	var result = getFrameContent(iframeID).split(':',2);
	document.getElementById(matchesID).innerHTML = result[0];
	document.getElementById(playersID).innerHTML = result[1];
	setTimeout('reloadframe(\'' + iframeID + '\');',timeout);
}

function reloadframe(iframeID){
	document.getElementById(iframeID).contentDocument.location.reload(true);
}


//Player Search
function search(iframeID,searchbox){
	document.getElementById(iframeID).src = 'dynamic.php?job=search&query=' + document.getElementById(searchbox).value;
}
