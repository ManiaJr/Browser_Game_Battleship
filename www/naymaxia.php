<?php

require_once "../lib/dbconnect2.php";
require_once "../lib/board.php";
require_once "../lib/game.php";
require_once "../lib/users.php";

$method=$_SERVER['REQUEST_METHOD'];
$request=explode('/', trim($_SERVER['PATH_INFO'],'/'));
$input=json_decode(file_get_contents('php://input'),true);

if($input==null) {
    $input=[];
}
if(isset($_SERVER['HTTP_X_TOKEN'])) {
    $input['token']=$_SERVER['HTTP_X_TOKEN'];
} else {
    $input['token']='';
}


switch ($r=array_shift($request)){
    case 'game' :
        switch ($b=array_shift($request)){
            case '' :
            
            case null : handle_game($method,$input);break;

            case 'piece': 
                handle_piece($method,$input);break;
            
            case 'XO':
                handle_hit($method,$input);break;

            default: header("HTTP/1.1 404 Not Found");
                    break;
        }
        break;
    
    case 'status': 
        switch ($b=array_shift($request)){
            case '' :
            
            case null : handle_status($method,$input);break;

            case 'ready' :
                ready($method,$input);break;

            default: header("HTTP/1.1 404 Not Found");break;
            
        }
        break;


    case 'player' : handle_player($method, $request, $input);
                    break;

    default: header("HTTP/1.1 404 Not Found");
        exit;
}


function handle_piece($method, $input){
    if ($method=='PUT') {
        move_piece($input['x1'],$input['y1'],$input['x2'],$input['y2'],$input['token']);
    }    else{
        header("HTTP/1.1 405 Method Not Allowed");
    }
}


function handle_game($method,$input){
    if($method=='POST'){
        start_game($input['token']);
    }
    else{
        header("HTTP/1.1 405 Method Not Allowed");
    }

}

function handle_hit($method,$input){
    if ($method=='PUT') {
        set_hit($input['x'],$input['y'],$input['token']);
    }    else{
        header("HTTP/1.1 405 Method Not Allowed");
    }
}

function handle_player($method, $p, $input){
    switch ($b=array_shift($p)){
        case 'B':
            case 'R': handle_user($method, $b, $input);
                    break;
            default : header("HTTP/1.1 404 Not Found");
                    print json_encode(['errormesg'=> "Player $b not found."]);
             break;
    }
}

function handle_status($method,$input) {
    if($method=='POST') {
        show_status($input['token']);
    }
    else {
        header('HTTP/1.1 405 Method Not Allowed');
    }
}

function ready($method,$input){
    if($method=='POST'){
        player_is_ready($input['token']);
    } 
}

?>