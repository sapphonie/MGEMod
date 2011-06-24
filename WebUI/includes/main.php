<?php

//MGEStats Main Include file
include("config.php");

chdir("mgeapi");
include("index.php");
chdir("..");

//Create new MGEstats object
$mgestats = new mgestats;
$mgestats->connect($mysql_host, $mysql_db, $mysql_user, $mysql_pass, $mysql_port);

?>