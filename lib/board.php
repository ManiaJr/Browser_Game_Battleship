<?php
function show_piece($x,$y,$token) {
	global $mysqli;
	
    $color = current_color($token);

    if($color=='B'){
        $sql = 'select * from bluemain where x=? and y=?';
    }else{
        $sql = 'select * from redmain where x=? and y=?';
    }
	$st = $mysqli->prepare($sql);
	$st->bind_param('ii',$x,$y);
	$st->execute();
	$res = $st->get_result();
	header('Content-type: application/json');
	print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}

function show_target_piece($x,$y,$token) {
	global $mysqli;
	
    $color = current_color($token);

    if($color=='B'){
        $sql = 'select * from bluetarget where x=? and y=?';
    }else{
        $sql = 'select * from redtarget where x=? and y=?';
    }
	$st = $mysqli->prepare($sql);
	$st->bind_param('ii',$x,$y);
	$st->execute();
	$res = $st->get_result();
	header('Content-type: application/json');
	print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}



function show_main($color){

    global $mysqli;
    if($color=='B'){
        $sql = 'select * from bluemain';
    }else{
        $sql = 'select * from redmain';
    }
    $st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();
	header('Content-type: application/json');
    print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);


}

function show_target($color){

    global $mysqli;
    if($color=='B'){
        $sql = 'select * from bluetarget';
    }else{
        $sql = 'select * from redtarget';
    }
    $st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();
	header('Content-type: application/json');
    print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}

//           NEW                 

function read_board($color,$gi) {
	global $mysqli;
    if($color=='B'){
        $sql = 'select * from bluemain where game_id=?';
    }else{
        $sql = 'select * from redmain where game_id=?';
    }
    $st = $mysqli->prepare($sql);
    $st->bind_param('i',$gi[0]['gi']);
	$st->execute();
	$res = $st->get_result();
	return($res->fetch_all(MYSQLI_ASSOC));
}

function read_target_board($color,$gi) {
	global $mysqli;
    if($color=='B'){
        $sql = 'select * from bluetarget where game_id=?';
    }else{
        $sql = 'select * from redtarget where game_id=?';
    }
    $st = $mysqli->prepare($sql);
    $st->bind_param('i',$gi[0]['gi']);
	$st->execute();
	$res = $st->get_result();
	return($res->fetch_all(MYSQLI_ASSOC));
}

function convert_board(&$orig_board) {
	$board=[];
	foreach($orig_board as $i=>&$row) {
		$board[$row['x']][$row['y']] = &$row;
	} 
	return($board);
}

function set_to_target($board,$color,$x,$y,$gi){
    if($x<1 || $x>10 || $y<1 || $y>10){
        header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"You can not make this move."]);
		exit;
    }else{
        $foo=TRUE;
        if($board[$x][$y]['piece']!=null){
            $foo=FALSE;
        }
        if($foo==TRUE){
            try{
                global $mysqli;
                $sql="call hit(?, ?, ?, ?)";
                $st = $mysqli->prepare($sql);
                $st->bind_param('siii',$color, $gi[0]['gi'],$x,$y);
                $st->execute();
            }
            catch (mysqli_sql_exception $e) {
                header("HTTP/1.1 400 Bad Request");
                print json_encode(['errormesg'=> $e->getMessage() . " " . $e->getCode()]);
                exit;
            }
            show_target($color);
        }else{
            header("HTTP/1.1 400 Bad Request");
            print json_encode(['errormesg'=>"You have already hit there."]);
            exit;
        }
    }
}


 function set_to_main($board,$color,$x1,$y1,$x2,$y2,$gi){
    global $mysqli;
    if($x1!=$x2 && $y1!=$y2){
        header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"You can not make this move."]);
		exit;
    }else if($x1==$x2 && $y1==$y2){
        header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"You can not make this move."]);
		exit;
    }else if($x1<1 || $x1>10 || $x2<1 || $x2>10 || $y1<1 || $y1>10 || $y2<1 || $y2>10){
        header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"You can not make this move."]);
		exit;
    }else{
        $ax=abs($x1-$x2);
        $ay=abs($y1-$y2);
        $foo=TRUE;
        if($ax>$ay){
            //BAZW ROTATED
            $maxx=max($x1, $x2);
            $minn=min($x1, $x2);
            for($i=$minn;$i<=$maxx;$i++){
                if($board[$i][$y1]['piece']!=null){
                    $foo=FALSE;
                }
            }
            if($foo==FALSE){
                header("HTTP/1.1 400 Bad Request");
                print json_encode(['errormesg'=>"There is already a ship."]);
                exit;
            }else if ($foo==TRUE){
                if($maxx-$minn==1){

                    $flag=check_if_placed($color,$gi,'YP1','YPR1');

                    if($flag==TRUE){
                        try{
                            $sql="call set_ship(?, ?, ?, ?, 'YPR1')";
                            $st = $mysqli->prepare($sql);
                            $st->bind_param('siii',$color, $gi[0]['gi'],$maxx,$y1);
                            $st->execute();
                    
                            $sql="call set_ship(?, ?, ?, ?, 'YPR2')";
                            $st = $mysqli->prepare($sql);
                            $maxx=$maxx-1;
                            $st->bind_param('siii',$color, $gi[0]['gi'],$maxx,$y1);
                            $st->execute();
                    
                        }
                        catch (mysqli_sql_exception $e) {
                            header("HTTP/1.1 400 Bad Request");
                            print json_encode(['errormesg'=> $e->getMessage() . " " . $e->getCode()]);
                            exit;
                        }
                    }else{
                        header("HTTP/1.1 400 Bad Request");
                        print json_encode(['errormesg'=>"You have place this ship."]);
                        exit;
                    }
                }else if($maxx-$minn==2){

                    $flag=check_if_placed($color,$gi,'PO1','POR1');

                    if($flag==TRUE){
                        try{
                            $sql="call set_ship(?, ?, ?, ?, 'POR1')";
                            $st = $mysqli->prepare($sql);
                            $st->bind_param('siii',$color, $gi[0]['gi'],$maxx,$y1);
                            $st->execute();
                    
                            $sql="call set_ship(?, ?, ?, ?, 'POR2')";
                            $st = $mysqli->prepare($sql);
                            $maxx=$maxx-1;
                            $st->bind_param('siii',$color, $gi[0]['gi'],$maxx,$y1);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'POR3')";
                            $st = $mysqli->prepare($sql);
                            $maxx=$maxx-1;
                            $st->bind_param('siii',$color, $gi[0]['gi'],$maxx,$y1);
                            $st->execute();
                        }
                        catch (mysqli_sql_exception $e) {
                            header("HTTP/1.1 400 Bad Request");
                            print json_encode(['errormesg'=> $e->getMessage() . " " . $e->getCode()]);
                            exit;
                        }
                    }else{
                        header("HTTP/1.1 400 Bad Request");
                        print json_encode(['errormesg'=>"You have place this ship."]);
                        exit;
                    }
                }else if($maxx-$minn==3){

                    $flag=check_if_placed($color,$gi,'AN1','ANR1');

                    if($flag==TRUE){
                        try{
                            $sql="call set_ship(?, ?, ?, ?, 'ANR1')";
                            $st = $mysqli->prepare($sql);
                            $st->bind_param('siii',$color, $gi[0]['gi'],$maxx,$y1);
                            $st->execute();
                        
                            $sql="call set_ship(?, ?, ?, ?, 'ANR2')";
                            $st = $mysqli->prepare($sql);
                            $maxx=$maxx-1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$maxx,$y1);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'ANR3')";
                            $st = $mysqli->prepare($sql);
                            $maxx=$maxx-1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$maxx,$y1);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'ANR4')";
                            $st = $mysqli->prepare($sql);
                            $maxx=$maxx-1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$maxx,$y1);
                            $st->execute();
                    
                        }
                        catch (mysqli_sql_exception $e) {
                            header("HTTP/1.1 400 Bad Request");
                            print json_encode(['errormesg'=> $e->getMessage() . " " . $e->getCode()]);
                            exit;
                        }
                    }else{
                        header("HTTP/1.1 400 Bad Request");
                        print json_encode(['errormesg'=>"You have place this ship."]);
                        exit;
                    }
                }else if($maxx-$minn==4){

                    $flag=check_if_placed($color,$gi,'AE1','AER1');

                    if($flag==TRUE){
                        try{
                            $sql="call set_ship(?, ?, ?, ?, 'AER1')";
                            $st = $mysqli->prepare($sql);
                            $st->bind_param('siii',$color,$gi[0]['gi'],$maxx,$y1);
                            $st->execute();
                        
                            $sql="call set_ship(?, ?, ?, ?, 'AER2')";
                            $st = $mysqli->prepare($sql);
                            $maxx=$maxx-1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$maxx,$y1);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'AER3')";
                            $st = $mysqli->prepare($sql);
                            $maxx=$maxx-1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$maxx,$y1);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'AER4')";
                            $st = $mysqli->prepare($sql);
                            $maxx=$maxx-1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$maxx,$y1);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'AER5')";
                            $st = $mysqli->prepare($sql);
                            $maxx=$maxx-1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$maxx,$y1);
                            $st->execute();
                    
                        }
                        catch (mysqli_sql_exception $e) {
                            header("HTTP/1.1 400 Bad Request");
                            print json_encode(['errormesg'=> $e->getMessage() . " " . $e->getCode()]);
                            exit;
                        }                   
                    }else{
                        header("HTTP/1.1 400 Bad Request");
                        print json_encode(['errormesg'=>"You have place this ship."]);
                        exit;
                    }
                }
            }
            show_main($color);
        }else{
            //bazw kanonikes
            $maxx=max($y1, $y2);
            $minn=min($y1, $y2);
            for($i=$minn;$i<=$maxx;$i++){
                if($board[$x1][$i]['piece']!=null){
                    $foo=FALSE;
                }
            }
            if($foo==FALSE){
                header("HTTP/1.1 400 Bad Request");
                print json_encode(['errormesg'=>"There is already a ship."]);
                exit;
            }else if ($foo==TRUE){
                if ($maxx-$minn==1){

                    $flag=check_if_placed($color,$gi,'YP1','YPR1');

                    if($flag==TRUE){
                        try{
                            $sql="call set_ship(?, ?, ?, ?, 'YP1')";
                            $st = $mysqli->prepare($sql);
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
                    
                            $sql="call set_ship(?, ?, ?, ?, 'YP2')";
                            $st = $mysqli->prepare($sql);
                            $minn=$minn+1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
                    
                        }
                        catch (mysqli_sql_exception $e) {
                            header("HTTP/1.1 400 Bad Request");
                            print json_encode(['errormesg'=> $e->getMessage() . " " . $e->getCode()]);
                            exit;
                        }
                    }else{
                        header("HTTP/1.1 400 Bad Request");
                        print json_encode(['errormesg'=>"You have place this ship."]);
                        exit;
                    }
                }else if($maxx-$minn==2){

                    $flag=check_if_placed($color,$gi,'PO1','POR1');

                    if($flag==TRUE){
                        try{
                            $sql="call set_ship(?, ?, ?, ?, 'PO1')";
                            $st = $mysqli->prepare($sql);
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
                    
                            $sql="call set_ship(?, ?, ?, ?, 'PO2')";
                            $st = $mysqli->prepare($sql);
                            $minn=$minn+1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'PO3')";
                            $st = $mysqli->prepare($sql);
                            $minn=$minn+1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
                    
                        }
                        catch (mysqli_sql_exception $e) {
                            header("HTTP/1.1 400 Bad Request");
                            print json_encode(['errormesg'=> $e->getMessage() . " " . $e->getCode()]);
                            exit;
                        }
                    }else{
                        header("HTTP/1.1 400 Bad Request");
                        print json_encode(['errormesg'=>"You have place this ship."]);
                        exit;
                    }
                }else if($maxx-$minn==3){

                    $flag=check_if_placed($color,$gi,'AN1','ANR1');

                    if($flag==TRUE){
                        try{
                            $sql="call set_ship(?, ?, ?, ?, 'AN1')";
                            $st = $mysqli->prepare($sql);
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
                        
                            $sql="call set_ship(?, ?, ?, ?, 'AN2')";
                            $st = $mysqli->prepare($sql);
                            $minn=$minn+1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'AN3')";
                            $st = $mysqli->prepare($sql);
                            $minn=$minn+1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'AN4')";
                            $st = $mysqli->prepare($sql);
                            $minn=$minn+1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
                        }
                        catch (mysqli_sql_exception $e) {
                            header("HTTP/1.1 400 Bad Request");
                            print json_encode(['errormesg'=> $e->getMessage() . " " . $e->getCode()]);
                            exit;
                        }
                    }else{
                        header("HTTP/1.1 400 Bad Request");
                        print json_encode(['errormesg'=>"You have place this ship."]);
                        exit;
                    }
                }else if($maxx-$minn==4){

                    $flag=check_if_placed($color,$gi,'AE1','AER1');

                    if($flag==TRUE){
                        try{
                            $sql="call set_ship(?, ?, ?, ?, 'AE1')";
                            $st = $mysqli->prepare($sql);
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
                        
                            $sql="call set_ship(?, ?, ?, ?, 'AE2')";
                            $st = $mysqli->prepare($sql);
                            $minn=$minn+1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'AE3')";
                            $st = $mysqli->prepare($sql);
                            $minn=$minn+1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'AE4')";
                            $st = $mysqli->prepare($sql);
                            $minn=$minn+1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
    
                            $sql="call set_ship(?, ?, ?, ?, 'AE5')";
                            $st = $mysqli->prepare($sql);
                            $minn=$minn+1;
                            $st->bind_param('siii',$color,$gi[0]['gi'],$x1,$minn);
                            $st->execute();
                        }
                        catch (mysqli_sql_exception $e) {
                            header("HTTP/1.1 400 Bad Request");
                            print json_encode(['errormesg'=> $e->getMessage() . " " . $e->getCode()]);
                            exit;
                        }                   
                    }else{
                        header("HTTP/1.1 400 Bad Request");
                        print json_encode(['errormesg'=>"You have place this ship."]);
                        exit;
                    }
                }
            }
            show_main($color);
        }
    }
 }

 function check_if_placed($color,$gi,$first,$second){
    global $mysqli;
    if($color=='B'){
        $sql="select count(*) as c from bluemain where game_id=? and piece=?";
        $st=$mysqli->prepare($sql);
        $st->bind_param('is', $gi[0]['gi'],$first);
        $st->execute();
        $res = $st->get_result();
        $C1 = $res->fetch_all(MYSQLI_ASSOC);

        $sql="select count(*) as c from bluemain where game_id=? and piece=?";
        $st=$mysqli->prepare($sql);
        $st->bind_param('is', $gi[0]['gi'],$second);
        $st->execute();
        $res = $st->get_result();
        $C2 = $res->fetch_all(MYSQLI_ASSOC);
    }else{
        $sql="select count(*) as c from redmain where game_id=? and piece=?";
        $st=$mysqli->prepare($sql);
        $st->bind_param('is', $gi[0]['gi'],$first);
        $st->execute();
        $res = $st->get_result();
        $C1 = $res->fetch_all(MYSQLI_ASSOC);

        $sql="select count(*) as c from redmain where game_id=? and piece=?";
        $st=$mysqli->prepare($sql);
        $st->bind_param('is', $gi[0]['gi'],$second);
        $st->execute();
        $res = $st->get_result();
        $C2 = $res->fetch_all(MYSQLI_ASSOC);
    }
    if($C1[0]['c']==0 && $C2[0]['c']==0){
        return TRUE;
    }else{
        return FALSE;
    }

 }

?>