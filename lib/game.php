<?php
require_once "board.php";

function start_game($token){

    if($token==null || $token=='') {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"token is not set."]);
		exit;
	}
	$color = current_color($token);
	if($color==null ) {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"You are not a player of this game."]);
		exit;
	}

	show_main($color);

    // show_target($color);

}

function start_new_game(){
	global $mysqli;
	$sql='call start_game()';
    $mysqli->query($sql);
}

function clean_game(){
    global $mysqli;
    $sql='call clean_game()';
    $mysqli->query($sql);
}

function get_new_game_id(){
	global $mysqli;
	$sql = 'select game_id as gi from players where username is null';
	$st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();
	return $res->fetch_all(MYSQLI_ASSOC);
}

function get_game_id($token){
	global $mysqli;
	$sql = 'select game_id as gi from players where token=?';
	$st = $mysqli->prepare($sql);
	$st->bind_param('s',$token);
	$st->execute();
	$res = $st->get_result();
	return $res->fetch_all(MYSQLI_ASSOC);
}


function update_game_status($token) {
	global $mysqli;
	
	$gi=get_game_id($token);
	$status = read_status($gi);
	
	
	$new_status=null;
	$new_turn=null;

	
	$st3=$mysqli->prepare('select count(*) as aborted from players WHERE last_action< (NOW() - INTERVAL 5 MINUTE)');
	$st3->execute();
	$res3 = $st3->get_result();
	$aborted = $res3->fetch_assoc()['aborted'];
	if($aborted>0) {
		$st=$mysqli->prepare('select DISTINCT game_id as gi from players WHERE last_action< (NOW() - INTERVAL 5 MINUTE)');
		$st->execute();
		$res = $st->get_result();
		$gi=$res->fetch_all(MYSQLI_ASSOC);

		for($i=0; $i<$aborted; $i++){

			$sql = "call delete_game(?)";
			$st = $mysqli->prepare($sql);
			$st->bind_param('i',$gi[$i]['gi']);
			$st->execute();
			if($status['status']=='started') {
				$new_status='aborted';
			}
			$sql = 'update game_status set status=?, p_turn=? where game_id=?';
			$st = $mysqli->prepare($sql);
			$st->bind_param('ssi',$new_status,$new_turn, $gi[$i]['gi']);
			$st->execute();
		}
	}

	// $gi=get_game_id($token);	
	$sql = 'select count(*) as c from players where username is null';
	$st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();
	$non_active_players = $res->fetch_assoc()['c'];

	if($non_active_players>0){
		$st=$mysqli->prepare('select DISTINCT game_id as gi from players WHERE username is null');
		$st->execute();
		$res = $st->get_result();
		$gi=$res->fetch_all(MYSQLI_ASSOC);

		
		for($i=0; $i<$non_active_players; $i++){
			$new_status='not active';
			$sql = 'update game_status set status=?, p_turn=? where game_id=?';
			$st = $mysqli->prepare($sql);
			$st->bind_param('ssi',$new_status,$new_turn, $gi[$i]['gi']);
			$st->execute();
		}

	}
	
	$sql = 'select count(*) as c from players p1 join players p2 on p1.game_id = p2.game_id where p1.username is null and p2.username is not null';
	$st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();
	$one_active_players = $res->fetch_assoc()['c'];

	if($one_active_players>0){
		$st=$mysqli->prepare('select distinct p1.game_id as gi from players p1 join players p2 on p1.game_id = p2.game_id where p1.username is null and p2.username is not null');
		$st->execute();
		$res = $st->get_result();
		$gi=$res->fetch_all(MYSQLI_ASSOC);

		
		for($i=0; $i<$one_active_players; $i++){
			$new_status='initialized';
			$sql = 'update game_status set status=?, p_turn=? where game_id=?';
			$st = $mysqli->prepare($sql);
			$st->bind_param('ssi',$new_status,$new_turn, $gi[$i]['gi']);
			$st->execute();
		}

	}

	$sql = "select count(distinct least(p1.token, p2.token)) as c from players p1 join players p2 on p1.game_id = p2.game_id where p1.username is not null and p2.username is not null and p1.token <> p2.token and p1.ready='Yes' and p2.ready='Yes'";
	$st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();
	$two_active_players = $res->fetch_assoc()['c'];

	if($two_active_players>0){
		$st=$mysqli->prepare("select DISTINCT p1.game_id as gi from players p1 join players p2 on p1.game_id = p2.game_id where p1.username is not null and p2.username is not null and p1.token <> p2.token and p1.ready='Yes' and p2.ready='Yes'");
		$st->execute();
		$res = $st->get_result();
		$gi=$res->fetch_all(MYSQLI_ASSOC);

		
		for($i=0; $i<$two_active_players; $i++){
			$new_status='started';
			if($status['p_turn']==null) {
				$new_turn='B'; // It was not started before...
			}
			$sql = 'update game_status set status=?, p_turn=? where game_id=?';
			$st = $mysqli->prepare($sql);
			$st->bind_param('ssi',$new_status,$new_turn, $gi[$i]['gi']);
			$st->execute();
		}

	}

}

function read_status($gi) {
	global $mysqli;

	$sql = 'select * from game_status where game_id=?';
	$st = $mysqli->prepare($sql);
	$st->bind_param('i',$gi[0]['gi']);
	$st->execute();
	$res = $st->get_result();
	$status = $res->fetch_assoc();
	return($status);
}



function show_status($token) {
	
	global $mysqli;

	$gi=get_game_id($token);
	check_abort($gi);
	
	$sql = 'select * from game_status where game_id=?';
	$st = $mysqli->prepare($sql);
	$st->bind_param('i',$gi[0]['gi']);
	$st->execute();
	$res = $st->get_result();

	header('Content-type: application/json');
	print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);

}

function check_abort($gi) {
	global $mysqli;
	
	$sql = "update game_status set status='aborded', result=if(p_turn='B','R','B'),p_turn=null where p_turn is not null and last_change<(now()-INTERVAL 5 MINUTE) and status='started' and game_id=?";
	$st = $mysqli->prepare($sql);
	$st->bind_param('i',$gi[0]['gi']);
	$r = $st->execute();
}


function set_hit($x,$y,$token){
	if($token==null || $token=='') {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"token is not set."]);
		exit;
	}
	$color = current_color($token);
	if($color==null ) {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"You are not a player of this game."]);
		exit;
	}
	$gi=get_game_id($token);
	$status = read_status($gi);
	if($status['status']!='started') {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"Game is not in action."]);
		exit;
	}
	if($status['p_turn']!=$color) {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"It is not your turn."]);
		exit;
	}
	$orig_board=read_target_board($color,$gi);
	$board=convert_board($orig_board);
	update_players_last_action($token,$color,$gi);
	set_to_target($board,$color,$x,$y,$gi);
	check_if_win($color,$gi);

}

function check_if_win($color,$gi){
	global $mysqli;
	if ($color=='B'){
		$sql="select count(*) - count(case when piece is null or piece = 'O' then 1 else null end) as non_null_or_o_count from redmain where game_id = ?";
	}else{
		$sql="select count(*) - count(case when piece is null or piece = 'O' then 1 else null end) as non_null_or_o_count from bluemain where game_id = ?";
	}
	$st = $mysqli->prepare($sql);
	$st->bind_param('i',$gi[0]['gi']);
	$st->execute();
	$res = $st->get_result();
	$non_null_or_o_count=$res->fetch_all(MYSQLI_ASSOC);

	if ($non_null_or_o_count[0]['non_null_or_o_count']==0){
		$sql = 'update game_status set result=? where game_id=?';
		$st = $mysqli->prepare($sql);
		$st->bind_param('si',$color,$gi[0]['gi']);
		$st->execute();
	}
}

function move_piece($x1, $y1, $x2, $y2, $token) {

	if($token==null || $token=='') {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"token is not set."]);
		exit;
	}
	$color = current_color($token);
	if($color==null ) {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"You are not a player of this game."]);
		exit;
	}
	$gi=get_game_id($token);
	$status = read_status($gi);
	if($status['status']!='initialized') {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"Game is not in action."]);
		exit;
	}
	// if($status['p_turn']!=$color) {
	// 	header("HTTP/1.1 400 Bad Request");
	// 	print json_encode(['errormesg'=>"It is not your turn."]);
	// 	exit;
	// }
	$orig_board=read_board($color,$gi);
	$board=convert_board($orig_board);
	update_players_last_action($token,$color,$gi);
	set_to_main($board,$color,$x1,$y1,$x2,$y2,$gi);

}

?>