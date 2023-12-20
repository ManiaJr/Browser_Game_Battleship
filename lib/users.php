<?php

    require_once "game.php";

    function handle_user($method, $b, $input){
        if($method=='GET'){
            show_user($b);
        }
        else if($method=='PUT'){
            set_user($b, $input);
        }
    }

    function show_user($b){
        global $mysqli;
        $sql = 'select username,piece_color from players where piece_color=?';
        $st = $mysqli-> prepare($sql);
        $st->bind_param('s',$b);
        $st->execute();
        $res = $st->get_result();
        header('Content-type: application/json');
        print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
    }

    function set_user($b, $input) {

        if (!isset($input['username']) || $input['username'] == '') {
            header("HTTP/1.1 400 Bad Request");
            print json_encode(['errormesg' => 'No username given.']);
            exit;
        }
        global $mysqli;

        $sql = 'select count(*) as c from players where username is not null ';
        $st=$mysqli->prepare($sql);
        $st->execute();
        $res = $st->get_result();
        $r = $res->fetch_all(MYSQLI_ASSOC);

        if ($r[0]['c'] == 0 || $r[0]['c'] % 2 == 0){
            start_new_game();
            $gi=get_new_game_id();
        }else{
            $sql = 'select min(game_id) as gi from players where username is null';
            $st = $mysqli->prepare($sql);
            $st->execute();
            $res = $st->get_result();
            $gi=$res->fetch_all(MYSQLI_ASSOC);
        }

        $username = $input['username'];

        $sql = 'select count(*) as c from players where piece_color=? and username is not null and game_id=?';
        $st = $mysqli->prepare($sql);
        $st->bind_param('si', $b, $gi[0]['gi']);
        $st->execute();
        $res = $st->get_result();
        $r = $res->fetch_all(MYSQLI_ASSOC);

        if ($r[0]['c'] > 0) {
            header("HTTP/1.1 400 Bad Request");
            print json_encode(['errormesg' => "Player $b is already set. Please select another color."]);
            exit;
        }
        
        $sql = 'update players set username=?, token=md5(CONCAT(?, NOW())) where piece_color=? and game_id=?';
        $st2 = $mysqli->prepare($sql);
        $st2->bind_param('sssi', $username, $username, $b, $gi[0]['gi']);
        $st2->execute();

        $sql = 'select token as tk from players where game_id=? and username=?';
        $st = $mysqli->prepare($sql);
        $st->bind_param('is',$gi[0]['gi'], $username);
        $st->execute();
        $res = $st->get_result();
        $tk = $res->fetch_all(MYSQLI_ASSOC);

        // $gi=get_game_id($tk[0]['tk']);

        update_game_status($tk[0]['tk']);

        $sql = 'select * from players where piece_color=? and game_id=?';
        $st = $mysqli->prepare($sql);
        $st->bind_param('si', $b, $gi[0]['gi']);
        $st->execute();
        $res = $st->get_result();
        header('Content-type: application/json');
        print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
    }

    function current_color($token) {
	
        global $mysqli;
        if($token==null) {return(null);}
        $sql = 'select * from players where token=?';
        $st = $mysqli->prepare($sql);
        $st->bind_param('s',$token);
        $st->execute();
        $res = $st->get_result();
        if($row=$res->fetch_assoc()) {
            return($row['piece_color']);
        }
        return(null);
    }

    function player_is_ready($token){
        global $mysqli;
        $sql="update players set ready='Yes' where token=?";
        $st = $mysqli->prepare($sql);
        $st->bind_param('s',$token);
        $st->execute();
        update_game_status($token);
    }

    function update_players_last_action($token,$color,$gi){
        global $mysqli;

        $sql='select count(*) as c from players WHERE last_action< (NOW() - INTERVAL 5 MINUTE) and token=?';
        $st2 = $mysqli->prepare($sql);
        $st2->bind_param('s',$token);
        $st2->execute();
        $res = $st2->get_result();
	    $c = $res->fetch_assoc()['c'];

        if($c>0){
            if($color=='B'){
                $sql = 'update game_status set result=? where game_id=?';
                $st = $mysqli->prepare($sql);
                $st->bind_param('si','R',$gi[0]['gi']);
                $st->execute();
            }else{
                $sql = 'update game_status set result=? where game_id=?';
                $st = $mysqli->prepare($sql);
                $st->bind_param('si','B',$gi[0]['gi']);
                $st->execute();
            }
        }else{
            $sql = 'update players set last_action=NOW() where token=?';
            $st2 = $mysqli->prepare($sql);
            $st2->bind_param('s',$token);
            $st2->execute();

            $sql = 'update game_status set last_change=NOW() where game_id=?';
            $st2 = $mysqli->prepare($sql);
            $st2->bind_param('i',$gi[0]['gi']);
            $st2->execute();
        }
    }
    

?>