var me={};
var game_status={};
var counter=1;

$(function(){
    $('#naymaxia_login').click(login_to_game);
    $('#do_naymaxia_set_ship').click(set_ship);
    $('#Ready').click(test_ready);
    $('#move_div').hide(1000);
    $('#hit_div').hide(1000);

});

function draw_empty_board(){
    var t='<table id="naymaxia_table">';
    for(var i=1;i<11;i++){
        t+='<tr>';
        for(var j=1;j<11;j++){
            t+='<td class="naymaxia_square" id="main_'+i+'_'+j+'">'+i+','+j+'</td>';
        }
        t+='</tr>';
    }
    t+='</table>';
    $('#naymaxia_board').html(t);
}

function draw_empty_target(){
    var t='<table id="target_table">';
    for(var i=1;i<11;i++){
        t+='<tr>';
        for(var j=1;j<11;j++){
            t+='<td class="target_square" id="target_'+i+'_'+j+'">'+i+','+j+'</td>';
        }
        t+='</tr>';
    }
    t+='</table>';
    $('#target_board').html(t);
    $('.target_square').click(set_XO);
}

function fill_main(){
    $.ajax(
        {
            url: "naymaxia.php/game/",
            method: "post",
            dataType: "json",
            contentType: "application/json",
            headers: {"X-Token": me.token},
            success: fill_main_by_data
        }
    );
}

function fill_target(){
    $.ajax(
        {
            url: "naymaxia.php/game/",
            method: "post",
            dataType: "json",
            contentType: "application/json",
            headers: {"X-Token": me.token},
            success: fill_target_by_data
        }
    );
}

function set_ship(){

    var s = $('#the_naymaxia_set_ship').val();
	
	var a = s.trim().split(/[ ]+/);
	if(a.length!=4) {
		alert('Must give 4 choices');
		return;
	}

    $.ajax({url: "naymaxia.php/game/piece/", 
			method: 'put',
			dataType: "json",
			contentType: 'application/json',
			data: JSON.stringify( {x1: a[0], y1: a[1], x2: a[2], y2: a[3]}),
			headers: {"X-Token": me.token},
			success: move_result,
			error: login_error});
	


}

function set_XO(e){

    var o=e.target;
    var id=o.id;
    var a=id.split(/_/);
    $.ajax(
        {
            url: "naymaxia.php/game/XO/",
            method: 'put',
            dataType: "json",
            data: JSON.stringify( {x: a[1], y: a[2]}),
            headers: {"X-Token": me.token},
            success: hit_result,
			error: login_error});
}


function move_result(data){
    console.log(data);
    game_status_update();
    fill_main_by_data(data);
    counter=counter+1;
    if (counter==5){
        $('#move_div').hide();
        test_ready();
    }
}

function hit_result(data){
    console.log(data);
    game_status_update();
    fill_target_by_data(data);
}

function login_to_game(){
    if($('#username').val()==''){
        alert('You have to set username');
        return;
    }
    var p_color= $('#pcolor').val();

   $.ajax({url: "naymaxia.php/player/"+p_color,
            method: 'put',
            dataType: "json",
            contentType: 'application/json',
            data: JSON.stringify( {username:  $('#username').val(), piece_color: p_color}),
            success: login_result,
            error: login_error});
}

function login_result(data){
    me = data[0];
    $('#game_initializer').hide();
    update_info();
    game_status_update();
    $('#move_div').show();
    draw_empty_board();
    draw_empty_target();
    fill_main();
    fill_target();
}

function update_info(){
	$('#game_info').html("I am Player: "+me.piece_color+", in the game number: "+me.game_id+", my name is "+me.username +'<br>Token='+me.token+'<br>Game state: '+game_status.status+', '+ game_status.p_turn+' must play now.');
	if(game_status.result!=null){
        $('#hit_div').hide();
        $('#table-container').hide();
        if(game_status.result==me.piece_color){
            $('#game_result').html("Victory");
        }else{
            $('#game_result').html("Defeat");
        }
    }
	
}

function login_error(data,y,z,c){
    console.log(data);
    var x = data.responseJSON;
	alert(x.errormesg);
}


function fill_main_by_data(data){
    console.log(data);
    for(var i=0;i<data.length;i++){
        var o = data[i];
        var id = '#main_'+o.x+'_'+o.y;
        var c = (o.piece!=null)?o.piece:'';
        var im = (o.piece!=null)?'<img class="piece" src="image/'+c+'.png">':'';
        $(id).addClass().html(im);
    }
}

function fill_target_by_data(data){
    console.log(data);
    for(var i=0;i<data.length;i++){
        var o = data[i];
        var id = '#target_'+o.x+'_'+o.y;
        var c = (o.piece!=null)?o.piece:'';
        var im = (o.piece!=null)?'<img class="piece" src="image/'+c+'.png">':'';
        $(id).addClass().html(im);
    }
}

function game_status_update(){
    $.ajax({url: "naymaxia.php/status/",
            method: "post",
            dataType: "json",
            contentType: "application/json",
            headers: {"X-Token": me.token},
            success: update_status});
}

function test_ready(){
    if (counter<4){
        alert('You have to set 4 ships');
        return;
    }
    $.ajax({url: "naymaxia.php/status/ready/",
            method: "post",
            dataType: "json",
            contentType: "application/json",
            headers: {"X-Token": me.token},
            success: game_status_update});
}

function update_status(data){
    game_status=data[0];
    update_info();
    fill_main();
    if(game_status.p_turn==me.piece_color && me.piece_color!=null && counter==5 && game_status.result==null){
        x=0;
        $('#hit_div').show(1000);
        setTimeout(function(){game_status_update();}, 15000);
    }else{
        $('#hit_div').hide(1000);
        setTimeout(function(){game_status_update();}, 4000);
    }
}
