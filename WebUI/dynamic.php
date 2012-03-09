<?php

    include("includes/main.php");

	function mean($input, $val)
	{
		$count = count($input);
		$total = 0;
		if($count == 0)
		{
			$returnval = 0;
		} else
		{
			$counter = 0;
			while($counter < $count)
			{
				$total += $input[$counter][$val];
			}
			$total = $total / $count;
			$returnval = $total;
		}

		return $returnval;
	}

	function total($input, $val)
	{
		$count = count($input);
		$total = 0;
		if($count == 0)
		{
			$returnval = 0;
		} else
		{
			$counter = 0;
			while($counter < $count)
			{
				$total += $input[$counter][$val];
			}
			$total = $total / $count;
			$returnval = $total;
		}

		return $returnval;
	}

	function weaponaccuracy($weapons)
	{
		print_r($weapons);
		$count = count($weapons);
		if($count == 0)
		{
			$returnval = $weapons;
		} else
		{
			$counter = 0;
			while($counter < $count)
			{
				$weapons[$counter]['accuracy'] = (($weapons[$counter]['hits'] / $weapons[$counter]['shots']) * 100);
				$counter++;
			}
			$returnval = $weapons;
		}

		print_r($weapons);
		return $returnval;
	}

	function mapimage($map, $arena)
	{
		//Default the return val
		$returnval = 'Map Image not available...';

		switch($map)
		{
			case "mge_training_pro":
				switch($arena)
				{
					case "Viaduct Middle":
						$returnval = '<img src="/maps/viaductmid.png" />';
						break;

					case "Granary Middle":
						$returnval = '<img src="/maps/granmid.png" />';
						break;

					case "Granary Last":
						$returnval = '<img src="/maps/granlast.png" />';
						break;

					case "Badlands Middle":
						$returnval = '<img src="/maps/badlandsmid.png" />';
						break;

					case "Gullywash Middle":
						$returnval = '<img src="/maps/gullymid.png" />';
						break;

					case "Ammomod":
						$returnval = '<img src="/maps/ammomod.png" />';
						break;

					case "Badlands Spire":
						$returnval = '<img src="/maps/badlandsspire.png" />';
						break;

					case "Endif":
						$returnval = '<img src="/maps/endif.png" />';
						break;

					case "Ashville Middle":
						$returnval = '<img src="/maps/ashvillemid.png" />';
						break;

					case "Coldfront Middle":
						$returnval = '<img src="/maps/coldfrontmid.png" />';
						break;

					case "Yukon Second":
						$returnval = '<img src="/maps/yukonsecond.png" />';
						break;
				}
			break;

			case "mge_training_v2":
				switch($arena)
				{
					case "BBall 1":
						$returnval = '<img src="/maps/bball.png" />';
						break;

					case "BBall 2":
						$returnval = '<img src="/maps/bball.png" />';
						break;

					case "Viaduct Middle":
						$returnval = '<img src="/maps/viaductmid.png" />';
						break;

					case "Granary Middle":
						$returnval = '<img src="/maps/granmid.png" />';
						break;

					case "Granary Last":
						$returnval = '<img src="/maps/granlast.png" />';
						break;

					case "Badlands Middle":
						$returnval = '<img src="/maps/badlandsmid.png" />';
						break;

					case "Gullywash Middle":
						$returnval = '<img src="/maps/gullymid.png" />';
						break;

					case "Ammomod":
						$returnval = '<img src="/maps/ammomod.png" />';
						break;

					case "Badlands Spire":
						$returnval = '<img src="/maps/badlandsspire.png" />';
						break;

					case "Endif":
						$returnval = '<img src="/maps/endif.png" />';
						break;

					case "Ashville Middle":
						$returnval = '<img src="/maps/ashvillemid.png" />';
						break;

					case "Coldfront Middle":
						$returnval = '<img src="/maps/coldfrontmid.png" />';
						break;

					case "Yukon Second":
						$returnval = '<img src="/maps/yukonsecond.png" />';
						break;
				}
			break;

			case "mge_training_v3":
				switch($arena)
				{
						case "BBall 1":
								$returnval = '<img src="/maps/bball.png" />';
								break;

						case "BBall 2":
								$returnval = '<img src="/maps/bball.png" />';
								break;

						case "Viaduct Middle":
								$returnval = '<img src="/maps/viaductmid.png" />';
								break;

						case "Granary Middle":
								$returnval = '<img src="/maps/granmid.png" />';
								break;

						case "Granary Last":
								$returnval = '<img src="/maps/granlast.png" />';
								break;

						case "Badlands Middle":
								$returnval = '<img src="/maps/badlandsmid.png" />';
								break;

						case "Gullywash Middle":
								$returnval = '<img src="/maps/gullymid.png" />';
								break;

						case "Ammomod":
								$returnval = '<img src="/maps/ammomod.png" />';
								break;

						case "Badlands spire":
								$returnval = '<img src="/maps/badlandsspire.png" />';
								break;

						case "endif":
								$returnval = '<img src="/maps/endif.png" />';
								break;

						case "Ashville Middle":
								$returnval = '<img src="/maps/ashvillemid.png" />';
								break;

						case "Coldfront Middle":
								$returnval = '<img src="/maps/coldfrontmid.png" />';
								break;

						case "Yukon Second":
								$returnval = '<img src="/maps/yukonsecond.png" />';
								break;
				}
			break;

			case "mge_training_v4_fixed":
				switch($arena)
				{
						case "BBall 1":
								$returnval = '<img src="maps/bball.png" />';
								break;

						case "BBall 2":
								$returnval = '<img src="maps/bball.png" />';
								break;

						case "Viaduct Middle":
								$returnval = '<img src="maps/viaductmid.png" />';
								break;

						case "Granary Middle":
								$returnval = '<img src="maps/granmid.png" />';
								break;

						case "Granary Last":
								$returnval = '<img src="maps/granlast.png" />';
								break;

						case "Badlands Middle":
								$returnval = '<img src="maps/badlandsmid.png" />';
								break;

						case "Gullywash Middle":
								$returnval = '<img src="maps/gullymid.png" />';
								break;

						case "Ammomod":
								$returnval = '<img src="maps/ammomod.png" />';
								break;

						case "Badlands spire":
								$returnval = '<img src="maps/badlandsspire.png" />';
								break;

						case "endif":
								$returnval = '<img src="maps/endif.png" />';
								break;

						case "Ashville Middle":
								$returnval = '<img src="maps/ashvillemid.png" />';
								break;

						case "Coldfront Middle":
								$returnval = '<img src="maps/coldfrontmid.png" />';
								break;

						case "Yukon Second":
								$returnval = '<img src="/maps/yukonsecond.png" />';
								break;
				}
			break;
			
			case "mge_training_v5":
				switch($arena)
				{
						case "bball":
								$returnval = '<img src="maps/bball.png" />';
								break;

						case "Viaduct Middle":
								$returnval = '<img src="maps/viaductmid.png" />';
								break;

						case "Granary Middle":
								$returnval = '<img src="maps/granmid.png" />';
								break;

						case "Granary Last":
								$returnval = '<img src="maps/granlast.png" />';
								break;

						case "Badlands Middle":
								$returnval = '<img src="maps/badlandsmid.png" />';
								break;

						case "Gullywash Middle":
								$returnval = '<img src="maps/gullymid.png" />';
								break;

						case "ammomod":
								$returnval = '<img src="maps/ammomod.png" />';
								break;
								
						case "Ammomod [MGE]":
								$returnval = '<img src="maps/ammomod.png" />';
								break;

						case "Badlands spire":
								$returnval = '<img src="maps/badlandsspire.png" />';
								break;

						case "endif":
								$returnval = '<img src="maps/endif.png" />';
								break;
								
						case "Snakewater Middle":
								$returnval = '<img src="maps/snakewater.png" />';
								break;
								
						case "Waste Middle":
								$returnval = '<img src="maps/waste.png" />';
								break;
				}
				
				case "mge_training_v7":
				switch($arena)
				{
						case "bball":
								$returnval = '<img src="maps/bball.png" />';
								break;

						case "Viaduct Middle":
								$returnval = '<img src="maps/viaductmid.png" />';
								break;

						case "Granary Middle":
								$returnval = '<img src="maps/granmid.png" />';
								break;

						case "Granary Last":
								$returnval = '<img src="maps/granlast.png" />';
								break;

						case "Badlands Middle":
								$returnval = '<img src="maps/badlandsmid.png" />';
								break;

						case "Gullywash Middle":
								$returnval = '<img src="maps/gullymid.png" />';
								break;

						case "ammomod":
								$returnval = '<img src="maps/ammomod.png" />';
								break;
								
						case "Ammomod [MGE]":
								$returnval = '<img src="maps/ammomod.png" />';
								break;

						case "Badlands spire":
								$returnval = '<img src="maps/badlandsspire.png" />';
								break;

						case "endif":
								$returnval = '<img src="maps/endif.png" />';
								break;
								
						case "Snakewater Middle":
								$returnval = '<img src="maps/snakewater.png" />';
								break;
								
						case "Waste Middle":
								$returnval = '<img src="maps/waste.png" />';
								break;
								
						case "Directs":
								$returnval = '<img src="maps/directs.png" />';
								break;
								
						case "No Splash":
								$returnval = '<img src="maps/directs.png" />';
								break;
				}
			break;
		}

		//Return the final value
		return $returnval;
	}

	function steamid2name($steamid)
	{
		global $mysql_host;
		global $mgestats;
		global $mysql_user;
		global $mysql_pass;
		global $mysql_port;

		$ln = mysql_connect($mysql_host.":".$mysql_port, $mysql_user, $mysql_pass);

		//Build SQL query
		$steamid = mysql_real_escape_string($steamid);
		$sql = 'SELECT name FROM mgemod_stats WHERE steamid = \''.$steamid.'\';';

		$output = $mgestats->mysql_query_stats($sql);
		if(count($output) < 1)
		{
			return false;
		} else
		{
			return $output[0]['name'];
		}
	}

	function get_link_src($data)
	{
		$p1=strpos($data,chr(34));
		$p2=strpos($data,chr(34),$p1+1);
		return substr($data,$p1+1,$p2-$p1-1);
}

	function friendid2avatar($friendid)
	{
		//Get the persons steam page
		$data=file_get_contents(("http://steamcommunity.com/profiles/".$friendid));


		//Locate the relevant HTML
		if (($p1=strpos($data,'<div class="avatarFull">'))!==false){
                $p1=strpos($data,'<',$p1+24);
                $p2=strpos($data,'>',$p1+1);
                $tmp=substr($data,$p1,$p2-$p1+1);
                $link_full=get_link_src($tmp); }

		//Now get the link ref
		$output = $link_full;

		//Now return the output
		return $output;
	}

function steam2friend($steam_id){
$steam_id=strtolower($steam_id);
if (substr($steam_id,0,7)=='steam_0') {
$tmp=explode(':',$steam_id);
if ((count($tmp)==3) && is_numeric($tmp[1]) && is_numeric($tmp[2])){
return bcadd((($tmp[2]*2)+$tmp[1]),'76561197960265728');
}else return false;
}else{
return false;
}
}

function DOA($i1, $i2)
{
	$returnval = 0;

	if($i1 > 0)
	{ $returnval = $i1; }

	if(i2 > 0)
	{ $returnval = $i2; }

	return $returnval;
}

	error_reporting(0);
	
	if($_REQUEST['job']==''){die();}
	
	switch($_REQUEST['job']){
		case 'recentmatches':
			
			//Get information
			$sql = 'SELECT * FROM `mgemod_duels` ORDER BY `mgemod_duels`.`gametime`  DESC LIMIT 0, 20';
			$output = $mgestats->mysql_query_stats($sql);

			//Parse into a page
			$counter = 0;
			$result = "";
			while($counter < count($output))
			{
				$result .= '<div class="match">';
				$result .= '<span class="links"><a href="javascript:viewpickup(\'' . $output[$counter]['gametime'] . '\');">More Info</a></span>';
				$result .= '<div id="names"><table><tr><td width="300"><div align="left"><strong><a href="javascript:viewplayer(\'' . $output[$counter]['winner'] . '\')">' . steamid2name($output[$counter]['winner']) . '</a></strong> </div></td> <td width="50"><div align="center">'.$output[$counter]['winnerscore'].' to '.$output[$counter]['loserscore'].'</div></td> <td width="300"><div align="right"><strong><a href="javascript:viewplayer(\'' . $output[$counter]['loser'] . '\')">' . steamid2name($output[$counter]['loser']) . '</a></strong></div></td></tr></table></div>';
				$result .= '<div id="time"><span>' . date('g:ia jS M',($output[$counter]['gametime'] - 3600)) . '</div></span>';
				$result .= '<div id="arena">' . $output[$counter]['mapname'] . ' - ' . $output[$counter]['arenaname'] . '</div>';
				$result .= '</div>';
				$counter++;
			}

			echo $result;			
			break;
	
		case 'stats':
			if((time() - filemtime('stats.cache'))<=60){
				echo file_get_contents('stats.cache');
				break;
			} else {
				$newcache = true;
			}
			$sql = 'SELECT wins FROM `mgemod_stats`;';
			$count = $mgestats->mysql_query_stats($sql);
                $output = 0;
                $counter = 0;
                while($counter < count($count))
                {
                    $output = $output + $count[$counter]['wins'];
                    $counter++;
                }
			$out = $output . ':';
		
            $sql = 'SELECT hitblip FROM `mgemod_stats`;';
            $count = count($mgestats->mysql_query_stats($sql));
			$out .= $count;
			
			echo $out;
			
			if($newcache===true){file_put_contents('stats.cache',$out);}
			
			@mysql_close($dbconn);
			break;

		case 'players':
		
			$dbconn = mysql_connect($mysql_server,$mysql_user,$mysql_pass) or die(mysql_error($dbconn));
			mysql_select_db($mysql_db,$dbconn) or die(mysql_error($dbconn));
			
			$pid = $page * 30;
			
			$sql = 'SELECT SUM(mgemod_stats.wins+mgemod_stats.losses) AS total, mgemod_stats.wins, mgemod_stats.losses, mgemod_stats.rating, mgemod_stats.name, mgemod_stats.steamid FROM mgemod_stats GROUP BY name ORDER BY rating DESC ';
			$players = $mgestats->mysql_query_stats($sql);
			while(($players[] = mysql_fetch_assoc($list)) || array_pop($players));
			
			
			//$counter == final array position (largest to smallest)
			//$counter2 == temporary array point
			//$temp == temporary array largest item pointer
			
			//Top of the table
			echo '<table width="100%">';
			echo '<tr>';
			echo '<td width="10%" align="center"><strong>Position</strong></td>';
			echo '<td width="10%" align="center"><strong>Rating</strong></td>';
			echo '<td width="45%" align="center"><strong>Name</strong></td>';
			echo '<td width="15%" align="center"><strong>Total</strong></td>';
			echo '<td width="10%" align="center"><strong>Wins</strong></td>';
			echo '<td width="10%" align="center"><strong>Losses</strong></td>';
			echo '</tr>';
			
			//Print the list
			$counter = 0;
			$count = count($players);
			while($counter < $count)
			{
				echo '<tr>';
				echo '<td align="center">' . ($counter + 1) . '</td>';
				echo '<td align="center" class="reason">' . $players[$counter]['rating'] . '</td>';
				echo '<td align="center"><a href="javascript:viewplayer(\'' . $players[$counter]['steamid'] . '\')">' . $players[$counter]['name'] . '</a></td>';
				echo '<td align="center">' . $players[$counter]['total'] . '</td>';
				echo '<td align="center">' . $players[$counter]['wins'] . '</td>';
				echo '<td align="center">' . $players[$counter]['losses'] . '</td>';
				echo '</tr>';
				
				$counter++;
			}
			
			//Close table
			echo '</table>';
	
			@mysql_close($dbconn);
			
			break;

		case 'view':
		
			$dbconn = mysql_connect($mysql_server,$mysql_user,$mysql_pass);
			$player = mysql_real_escape_string($_REQUEST['player']);

			//Get info on the players duels
			$sql = 'SELECT * FROM mgemod_stats WHERE steamid = \'' . $player . '\' LIMIT 0, 1';
			$player = $mgestats->mysql_query_stats($sql);
			$player = $player[0];
			$player['friendid'] = steam2friend($player['steamid']);
			$player['steamavatar'] = friendid2avatar($player['friendid']);
						
			if($player!==false){
			//Place in table
			echo '<table width="100%" valign="top">';
			echo '<tr><td>';

				echo 'Name: <span>' . $player['name'] . '</span>';
			
			echo '</td>';
			echo '<td rowspan="7" width="0%">';

				//Display the users steam avatar
				echo '<div align="center"><div id="avatar"><a href="http://steamcommunity.com/profiles/'.$player['friendid'].'"><img src="' . $player['steamavatar'] . '" /></a></div></div>';

			echo '</td></tr>';

			//Now return to main info
				echo '<tr><td>Rating: <span>' . $player['rating'] . '</span></td></tr>';
				echo '<tr><td>SteamID: <span><a href="http://steamcommunity.com/profiles/'.$player['friendid'].'">' . $player['steamid'] . '</a></span></td></tr>';
				echo '<tr><td>Last Played: <span>' . date('jS \o\f F Y',$player['lastplayed']) . '</span></td></tr>';

				echo '<tr height="14"><td></tr></td> <tr><td>Total: <span>' . ($player['wins'] + $player['losses']) . '</span></td></tr>';
				echo '<tr><td>Wins: <span>' . $player['wins'] . '</span></td></tr>';
				echo '<tr><td>Losses: <span>' . $player['losses'] . '</span></td></tr>';

			echo '</table>';

				//Query the database for weapon stats info
				$sql = 'SELECT * FROM mgemod_career_weapons WHERE steamid = \'' . mysql_real_escape_string($player['steamid']) . '\'';
				$weaponinfo = $mgestats->mysql_query_stats($sql);

				//Weapon stats info
				echo '<br/><span>Weapon Stats</span><br/>';
				echo '<table width="100%" cellpadding="0" cellspacing="0" border="0">';
				echo '<tr><td width="20%"><strong>Weapon</strong></td> <td width="20%"><strong>Average Accuracy</strong></td> <td width="15%"><a class="tooltip" title="A direct is a headshot, a rocket or pipe that hits the target directly, or a meatshot that does 90% or more of the maximum damage."><strong>Directs</strong></a></td> <td width="15%"><strong>Airshots</strong></td> <td width="15%"><a class="tooltip" title="The average damage done per hit."><strong>Average DPH</strong></a></td> <td width="15%"><strong>Shots Fired</strong></td></tr>';


				//Now echo the weapon info
				if($weaponinfo[0]['airshots'] == "")
				{
					echo '<tr><td colspan="6">';
					echo 'This user has not logged any weapon stats yet';
					echo '</td></tr>';
				} else
				{
					/*$weaponinfo = weaponaccuracy($weaponinfo);

					//Add the top level total
					echo '<tr>';
						echo '<td>Total</td>';
						echo '<td>' . mean($weaponinfo, 'accuracy') . '</td>';
						echo '<td>' . total($weaponinfo, 'directs') . '</td>';
						echo '<td>' . total($weaponinfo, 'airshots') . '</td>';
						echo '<td>' . total($weaponinfo, 'damage') . '</td>';
						echo '<td>' . mean($weaponinfo, 'dph') . '</td>';
						echo '<td>' . total($weaponinfo, 'shots') . '</td>';
					echo '</tr>';*/

					//Start the counter
					$counter = 0;
					$count = count($weaponinfo);
					while($counter < $count)
					{
						echo '<tr>';
						//Weapon
						echo '<td>' . $weaponinfo[$counter]['weapon'] . '</td>';
						//Accuracy
						echo '<td>' . (round(($weaponinfo[$counter]['hits'] / $weaponinfo[$counter]['shots']), 3) * 100) . '%</td>';
						//Directs
						echo '<td>' . $weaponinfo[$counter]['directs'] . '</td>';
						//Airshots
						echo '<td>' . $weaponinfo[$counter]['airshots'] . '</td>';
						//Average DPS
						echo '<td>' . round(($weaponinfo[$counter]['damage'] / $weaponinfo[$counter]['hits']), 2) . '</td>';
						//Shots
						echo '<td>' . $weaponinfo[$counter]['shots'] . '</td>';

						echo '</tr>';

						//Good idea to increment the counter probably >.>
						$counter++;					
					}
				}


				//End the table
				echo '</table>';


				//Duels recently played
				echo '<br/><span>Recent Duels</span><br/>';
				echo '<table width="100%" cellpadding="0" cellspacing="0" border="0">';
				echo '<tr><td width="35%"><strong>Winner</strong></td><td width="35%"><strong>Loser</strong></td> <td width="20%"><strong>Date</strong></td></tr> <td width="10%"></td></tr>';

				//Query database for duels
				$sql = 'SELECT * FROM mgemod_duels WHERE winner = \'' . mysql_real_escape_string($player['steamid']) . '\' OR loser = \'' . mysql_real_escape_string($player['steamid']) . '\' ORDER BY gametime DESC LIMIT 0, 10';
				$duels = $mgestats->mysql_query_stats($sql);
				
				if($duels[0]['winner'] == "")
				{
					echo '<tr>';
					echo '<td colspan="3">This user has not played any duels yet</td>';
					echo '</tr>';
				} else
				{
					$counter = 0;
					$count = count($duels);
					
					while($counter < $count)
					{
						echo '<tr>';
						echo '<td><strong><a href="javascript:viewplayer(\'' . $duels[$counter]['winner'] . '\')">' . steamid2name($duels[$counter]['winner']) . '</a></strong> (' . $duels[$counter]['winnerscore'] . ')</td>';
						echo '<td><strong><a href="javascript:viewplayer(\'' . $duels[$counter]['loser'] . '\')">' . steamid2name($duels[$counter]['loser']) . '</a></strong> (' . $duels[$counter]['loserscore'] . ')</td>';
						echo '<td>' . date('d/m/Y g:ia', $duels[$counter]['gametime']) . '</td>';
						echo '<td class="reason"><a href="javascript:viewpickup(\'' . $duels[$counter]['gametime'] . '\')">More Info</a></td>';
						echo '</tr>';
						$counter++;
					}
				}

				echo '</table>';
				
			} else {
				echo '<h1>User was not found!</h1>';
			}
			
			@mysql_close($dbconn);
			break;

		case 'pickups24':
		
			$dbconn = mysql_connect($mysql_server,$mysql_user,$mysql_pass);
			mysql_select_db($mysql_db, $dbconn);
			
			//WHERE time>=\'' . (time() - 3600) . '\'
			$pickups = 'SELECT * FROM `pickups` WHERE time>=\'' . (time() - 86400) . '\' ORDER BY `pickups`.`time` DESC';
			$pickups = mysql_query($pickups,$dbconn) or die(mysql_error($dbconn));
			
			if(mysql_num_rows($pickups)==0){
				$result = '<h3>No Pickups currently being played.</h3>';
			} else 
			{
				while(($row[] = mysql_fetch_assoc($pickups)) || array_pop($row));
				$counter = 0;
				//print_r($row);
				$result = "";
				while($counter < count($row))
				{
				//Display STV link if match is less than 45mins in
				$stvmessage = "";
					if((time() - $row[$counter]['time']) < 2700)
					{
						$stvmessage = '<a href="steam://connect/' . $stv[$row[$counter]['server'] - 1] . '/'.$stvpass.'">Join SourceTV</a>, ';
					}
					$result .= '<div class="match">';
					$result .= '<span class="links">' . $stvmessage . '<a href="javascript:viewpickup(\'' . $row[$counter]['id'] . '\');">More Info</a></span>';
					$result .= '<h1>' . $row[$counter]['map'] . '<span>' . date('g:ia jS M',$row[$counter]['time']) . '</span></h1>';
					$result .= '<h2><strong>Server ' . $row[$counter]['server'] . '</strong></h2>';
					$result .= '</div>';
					$counter++;
				}
			}
			
			echo $result;
			break;
			
		case 'pickups7':

			//1 Minute Cache
			if((time() - filemtime('pickups.cache'))<=0){
				echo file_get_contents('pickups.cache');
				break;
			} else {
				$newcache = true;
			}
		
			$dbconn = mysql_connect($mysql_server,$mysql_user,$mysql_pass) or die(mysql_error($dbconn));
			mysql_select_db($mysql_db,$dbconn) or die(mysql_error($dbconn));
			
			//WHERE time>=\'' . (time() - 3600) . '\'
			$pickups = 'SELECT * FROM `pickups` WHERE time>=\'' . (time() - 604800) . '\' ORDER BY `pickups`.`time` DESC';
			$pickups = mysql_query($pickups,$dbconn) or die(mysql_error($dbconn));
			
			if(mysql_num_rows($pickups)==0){
				$result = '<h3>No Pickups currently being played.</h3>';
			} else 
			{
				while(($row[] = mysql_fetch_assoc($pickups)) || array_pop($row));
				$counter = 0;
				//print_r($row);
				$result = "";
				while($counter < count($row))
				{
				//Display STV link if match is less than 45mins in
				$stvmessage = "";
					if((time() - $row[$counter]['time']) < 2700)
					{
						$stvmessage = '<a href="steam://connect/' . $stv[$row[$counter]['server'] - 1] . '/'.$stvpass.'">Join SourceTV</a>, ';
					}
					$result .= '<div class="match">';
					$result .= '<span class="links">' . $stvmessage . '<a href="javascript:viewpickup(\'' . $row[$counter]['id'] . '\');">More Info</a></span>';
					$result .= '<h1>' . $row[$counter]['map'] . '<span>' . date('g:ia jS M',$row[$counter]['time']) . '</span></h1>';
					$result .= '<h2><strong>Server ' . $row[$counter]['server'] . '</strong></h2>';
					$result .= '</div>';
					$counter++;
				}
			}
			
			echo $result;
			
			if($newcache===true){
				file_put_contents('pickups.cache',$result);
			}
			
			@mysql_close($dbconn);
			break;

		case 'viewpickup':
			
			$dbconn = mysql_connect($mysql_server,$mysql_user,$mysql_pass) or die(mysql_error($dbconn));
			$gametime = $_REQUEST['id'];
			
			//Query database for info
			$sql = 'SELECT * FROM mgemod_duels WHERE gametime = \'' . mysql_real_escape_string($gametime) . '\' LIMIT 0, 1';
			$duelinfo = $mgestats->mysql_query_stats($sql);
			$duelinfo = $duelinfo[0];

			//Winner weapon stats
			$sql = 'SELECT * FROM mgemod_weapons WHERE gametime = \'' . mysql_real_escape_string($gametime) . '\' AND steamid = \'' . mysql_real_escape_string($duelinfo['winner']) . '\'';
			$winnerweapons = $mgestats->mysql_query_stats($sql);

			//Loser weapon stats
			$sql = 'SELECT * FROM mgemod_weapons WHERE gametime = \'' . mysql_real_escape_string($gametime) . '\' AND steamid = \'' . mysql_real_escape_string($duelinfo['loser']) . '\'';
			$loserweapons = $mgestats->mysql_query_stats($sql);

			//Echo main info
			echo '<table width="100%">';
			echo '<tr>';
				echo '<td>';
					echo '<strong>Duel Info</strong>';
				echo '</td><td width="300">';
					echo '<strong>' . $duelinfo['mapname'] . ' - ' . $duelinfo['arenaname'] . '</strong>';
				echo '</td>';
			echo '</tr><tr>';
				echo '<td>';
					echo '<table>';
						echo '<tr><td>';
							echo '<strong>Start Time:</strong> ' . date('d/m/Y g:ia', $duelinfo['gametime']);
						echo '</td></tr><tr><td>';
							echo '<strong>Map:</strong> ' . $duelinfo['mapname'];
						echo '</td></tr><tr><td>';
							echo '<strong>Arena:</strong> ' . $duelinfo['arenaname'];
						echo '</td></tr><tr><td></td></tr><tr><td>';
							echo '<strong>Winner: ' . steamid2name($duelinfo['winner']) . '</strong> (' . $duelinfo['winnerscore'] . ')';
						echo '</td></tr><tr><td>';
							echo '<strong>Loser: ' . steamid2name($duelinfo['loser']) . '</strong> (' . $duelinfo['loserscore'] . ')';
						echo '</td></tr>';
					echo '</table>';
				echo '</td>';
				
				echo '<td>';
					echo '<div align="center">' . mapimage($duelinfo['mapname'], $duelinfo['arenaname']) . '</div>';
				echo '</td>';
			echo '</tr>';
			echo '</table>';

			//Weapon stats
			echo '<br />Weapon stats';
			echo '<table width="100%">';
				echo '<tr><td width="50%">';
					echo '<strong><a href="javascript:viewplayer(\'' . $duelinfo['winner'] . '\')">Winner: ' . steamid2name($duelinfo['winner']) . '</a></strong>';
					echo '</td><td>';
					echo '<strong><a href="javascript:viewplayer(\'' . $duelinfo['loser'] . '\')">Loser: ' . steamid2name($duelinfo['loser']) . '</a></strong>';
					echo '</td></tr><td>';

					echo '<table width="100%"><tr>';
					echo '<td>Weapon</td>';
					echo '<td>Shots</td>';
					echo '<td>Hits</td>';
					echo '<td>Accuracy</td>';
					echo '<td><a class="tooltip" title="The average damage done per hit">DPH</a></td>';
					echo '<td><a class="tooltip" title="A direct is a headshot, a rocket or pipe that hits the target directly, or a meatshot that does 90% or more of the maximum damage.">Directs</a></td>';
					echo '<td>Airshots</td>';
					echo '</tr>';
					
					//Start Loop
					$counter = 0;
					$count = count($winnerweapons);
					if($count == 0)
					{
						echo '<tr>';
						echo '<td colspan="7">No stats recorded for this duel</td>';
						echo '</tr>';
					} else
					{
						while($counter < $count)
						{
							echo '<tr>';
							echo '<td>' . $winnerweapons[$counter]['weapon'] . '</td>';
							echo '<td>' . $winnerweapons[$counter]['shots'] . '</td>';
							echo '<td>' . $winnerweapons[$counter]['hits'] . '</td>';
							echo '<td>' . (round(($winnerweapons[$counter]['hits'] / $winnerweapons[$counter]['shots']), 3) * 100) . '%</td>';
							echo '<td>' . round(($winnerweapons[$counter]['damage'] / $winnerweapons[$counter]['hits']), 2) . '</td>';
							echo '<td>' . $winnerweapons[$counter]['directs'] . '</td>';
							echo '<td>' . $winnerweapons[$counter]['airshots'] . '</td>';
							echo '</tr>';
							$counter++;
						}
					}

					echo '</table>';

				//Loser Stats
				echo '</td><td>';

					echo '<table width="100%"><tr>';
					echo '<td>Weapon</td>';
					echo '<td>Shots</td>';
					echo '<td>Hits</td>';
					echo '<td>Accuracy</td>';
					echo '<td><a class="tooltip" title="The average damage done per hit">DPH</a></td>';
					echo '<td><a class="tooltip" title="A direct is a headshot, a rocket or pipe that hits the target directly, or a meatshot that does 90% or more of the maximum damage.">Directs</a></td>';
					echo '<td>Airshots</td>';
					echo '</tr>';
					
					//Start Loop
					$counter = 0;
					$count = count($loserweapons);
					if($count == 0)
					{
						echo '<tr>';
						echo '<td colspan="7">No stats recorded for this duel</td>';
						echo '</tr>';
					} else
					{					

						while($counter < $count)
						{
							echo '<tr>';
							echo '<td>' . $loserweapons[$counter]['weapon'] . '</td>';
							echo '<td>' . $loserweapons[$counter]['shots'] . '</td>';
							echo '<td>' . $loserweapons[$counter]['hits'] . '</td>';
							echo '<td>' . (round(($loserweapons[$counter]['hits'] / $loserweapons[$counter]['shots']), 3) * 100) . '%</td>';
							echo '<td>' . round(($loserweapons[$counter]['damage'] / $loserweapons[$counter]['hits']), 2) . '</td>';
							echo '<td>' . $loserweapons[$counter]['directs'] . '</td>';
							echo '<td>' . $loserweapons[$counter]['airshots'] . '</td>';
							echo '</tr>';
							$counter++;
						}
					}

					echo '</table>';
			echo '</table>';
						
							
			
			break;

		case 'search':
			$query = $_REQUEST['query'];
			$query = strtolower($query);
			if(strlen($query) < 3)
			{
				echo "Sorry, the search you entered is too short";
			} else
			{
				$ln = mysql_connect($mysql_host.":".$mysql_port, $mysql_user, $mysql_pass);
				$query = mysql_real_escape_string($query);
				$sql = 'SELECT * FROM `mgemod_stats` WHERE (LOWER(steamid) LIKE \'%' . $query . '%\') OR (LOWER(name) LIKE \'%' . $query . '%\');';
				$query = $mgestats->mysql_query_stats($sql);
				if(count($query) == 0){
					echo 'No Results Found';
				} else {
					$counter = 0;
					while($row = $query[$counter]){
						echo '<a href="javascript:viewplayer(\'' . $row['steamid'] . '\');">' . $row['name'] . '</a></br>';
						$counter++;
					}
				}
			}
			break;
			
		case 'maps':
			
			//MySQL connect
			$dbconn = mysql_connect($mysql_server,$mysql_user,$mysql_pass) or die(mysql_error($dbconn));
			mysql_select_db($mysql_db,$dbconn) or die(mysql_error($dbconn));
			
			//Get info on maps played
			$sql = 'SELECT map FROM `pickups`;';
			$result = mysql_query($sql, $dbconn);
			while(($pickups[] = mysql_fetch_assoc($result)) || array_pop($pickups));
			
			//Get a play count for all maps
			$maps = array();
			$counter = 1;
			$mapcounter = 0;
			$count = count($pickups);
			
			//Set first map
			$maps[$mapcounter]['map'] = $pickups[0]['map'];
			$maps[$mapcounter]['count'] = 1;
			$mapcounter++;
			
			//Now check all maps
			while($counter < $count)
			{
				//Check if the current map already has any votes
				$counter2 = 0;
				$count2 = count($maps);
				$maptrue = false;
				while($counter2 < $count2)
				{
					//If the current map is the item
					if($pickups[$counter]['map'] == $maps[$counter2]['map'])
					{
						//Add an extra vote
						$maps[$counter2]['count']++;
						$maptrue = true;
					}
					$counter2++;
				}
				
				//If it still has not been filled
				if($maptrue == false)
				{
					$maps[$mapcounter]['map'] = $pickups[$counter]['map'];
					$maps[$mapcounter]['count'] = 1;
					$mapcounter++;
				}
				
				$counter++;
			}
			
			//Now sort the maps array
			$counter = 0;
			$count = count($maps);
			while($counter < $count)
			{
				$winpointer = 0;
				$counter2 = 0;
				while($counter2 < $count)
				{
					if($maps[$counter2]['count'] >= $maps[$winpointer]['count'])
					{
						$winpointer = $counter2;
					}
					$counter2++;
				}
				
				//Place this item on the new array and wipe original
				$maps2[$counter] = $maps[$winpointer];
				$maps[$winpointer]['count'] = -1;
				
				//Rinse and repeat
				$counter++;
			}
			
			//Top of the table
			echo '<table width="100%">';
			echo '<tr>';
			echo '<td width="15%" align="center"><strong>Position</strong></td>';
			echo '<td width="65%" align="center"><strong>Map Name</strong></td>';
			echo '<td width="20%" align="center"><strong>Pickups Played</strong></td>';
			echo '</tr>';
			
			//Print the list
			$counter = 0;
			$count = count($maps2);
			while($counter < $count)
			{
				echo '<tr>';
				echo '<td align="center">' . ($counter + 1) . '</td>';
				echo '<td align="center"><a href="/maps/' . $maps2[$counter]['map'] . '.bsp">' . $maps2[$counter]['map'] . '</a></td>';
				echo '<td align="center">' . $maps2[$counter]['count'] . '</td>';
				echo '</tr>';
				
				$counter++;
			}
			
			//Close table
			echo '</table>';
		
			break;
	}

	//--- Function Declaration
	//------------------------------------------------
	
	function numbersOnly($input){
		for($i = 0; $i < strlen($input); $i++){
			$working = ord(substr($input,$i,1));
			if(($working>=48)&&($working<=57)){
				//0-9
				$out = $out . chr($working);
			}
		}
		return $out;
	}


?>