<?php

//MGEStats Web API
//By Adam "Skyride" Findlay

//object.php
//This file contains the main object decleration

class mgestats
{
    private $mysql_host;
    private $mysql_port;
    private $mysql_user;
    private $mysql_pass;
    private $mysql_db;

    //Configure the mge module
    function connect($host, $db, $user, $pass, $port = 3306)
    {
        //Check $port
        if($port == "")
        {
            $port = 3306;
        }

        //Put MySQL variables into object variables
        $this->mysql_host = $host;
        $this->mysql_port = $port;
        $this->mysql_user = $user;
        $this->mysql_pass = $pass;
        $this->mysql_db = $db;
    }

    //MySQL query function, returns an array of the output
    function mysql_query_stats($sql)
    {
        $conn = mysql_connect(($this->host.":".$this->mysql_port), $this->mysql_user, $this->mysql_pass);
        mysql_select_db($this->mysql_db, $conn);
        $result = mysql_query($sql);

        if(mysql_num_rows($result) < 1)
        {
            return false;
        } else
        {
            while(($returnvalue[] = mysql_fetch_assoc($result)) || array_pop($returnvalue));
            return $returnvalue;
        }
    }

}

?>
