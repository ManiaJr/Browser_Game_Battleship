-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.28-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table naymaxia.bluemain
CREATE TABLE IF NOT EXISTS `bluemain` (
  `game_id` tinyint(1) NOT NULL,
  `x` tinyint(1) NOT NULL,
  `y` tinyint(1) NOT NULL,
  `piece` enum('AE1','AE2','AE3','AE4','AE5','AN1','AN2','AN3','AN4','PO1','PO2','PO3','YP1','YP2','AER1','AER2','AER3','AER4','AER5','ANR1','ANR2','ANR3','ANR4','POR1','POR2','POR3','YPR1','YPR2','X','O') DEFAULT NULL,
  PRIMARY KEY (`game_id`,`x`,`y`),
  CONSTRAINT `bluemain_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table naymaxia.bluemain_empty
CREATE TABLE IF NOT EXISTS `bluemain_empty` (
  `game_id` tinyint(1) NOT NULL,
  `x` tinyint(1) NOT NULL,
  `y` tinyint(1) NOT NULL,
  `piece` enum('AE1','AE2','AE3','AE4','AE5','AN1','AN2','AN3','AN4','PO1','PO2','PO3','YP1','YP2','AER1','AER2','AER3','AER4','AER5','ANR1','ANR2','ANR3','ANR4','POR1','POR2','POR3','YPR1','YPR2','X','O') DEFAULT NULL,
  PRIMARY KEY (`game_id`,`x`,`y`),
  CONSTRAINT `bluemain_empty_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table naymaxia.bluetarget
CREATE TABLE IF NOT EXISTS `bluetarget` (
  `game_id` tinyint(1) NOT NULL,
  `x` tinyint(1) NOT NULL,
  `y` tinyint(1) NOT NULL,
  `piece` enum('X','O') DEFAULT NULL,
  PRIMARY KEY (`game_id`,`x`,`y`),
  CONSTRAINT `bluetarget_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table naymaxia.bluetarget_empty
CREATE TABLE IF NOT EXISTS `bluetarget_empty` (
  `game_id` tinyint(1) NOT NULL,
  `x` tinyint(1) NOT NULL,
  `y` tinyint(1) NOT NULL,
  `piece` enum('X','O') DEFAULT NULL,
  PRIMARY KEY (`game_id`,`x`,`y`),
  CONSTRAINT `bluetarget_empty_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for procedure naymaxia.check_if_placed
DELIMITER //
CREATE PROCEDURE `check_if_placed`(in piece_colorn enum('B', 'R'),in game_ids tinyint(1), in pieces enum('AE1', 'AE2','AE3','AE4','AE5', 'AN1', 'AN2', 'AN3', 'AN4', 'PO1', 'PO2', 'PO3', 'YP1', 'YP2','AER1', 'AER2','AER3','AER4','AER5', 'ANR1', 'ANR2', 'ANR3', 'ANR4', 'POR1', 'POR2', 'POR3', 'YPR1', 'YPR2', 'X', 'O'))
begin
			if piece_colorn = 'B' then
				select count(*) as c from bluemain where game_id=game_ids and piece=pieces;
        else
			select count(*) as c from redmain where game_id=game_ids and piece=pieces;
        end if;
        end//
DELIMITER ;

-- Dumping structure for procedure naymaxia.clean_game
DELIMITER //
CREATE PROCEDURE `clean_game`()
begin
		DECLARE done INT DEFAULT 0;
        DECLARE thesi INT;
		DECLARE game_cursor CURSOR FOR SELECT game_id FROM game;
        
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
        
        OPEN game_cursor;
        
        loop1: loop
			FETCH NEXT FROM game_cursor INTO thesi;
            if done = 1 then
				leave loop1;
			end if;
			delete from bluemain_empty where game_id=thesi;
			delete from bluetarget_empty where game_id=thesi;
			delete from redmain_empty where game_id=thesi;
			delete from redtarget_empty where game_id=thesi;
			delete from bluemain where game_id=thesi;
			delete from bluetarget where game_id=thesi;
			delete from redmain where game_id=thesi;
			delete from redtarget where game_id=thesi;
            delete from players where game_id=thesi;
            delete from game_status where game_id=thesi;
			delete from game where game_id=thesi;
	end loop;
	CLOSE game_cursor;

end//
DELIMITER ;

-- Dumping structure for procedure naymaxia.clean_tables
DELIMITER //
CREATE PROCEDURE `clean_tables`()
begin
	replace into brluemain select * from bluemain_empty;
    replace into redmain select * from redmain_empty;
    replace into bluetarget select * from bluetarget_empty;
    replace into redtarget select * from redtarget_empty;
end//
DELIMITER ;

-- Dumping structure for procedure naymaxia.delete_game
DELIMITER //
CREATE PROCEDURE `delete_game`(thesi int)
begin
	delete from bluemain_empty where game_id=thesi;
    delete from bluetarget_empty where game_id=thesi;
	delete from redmain_empty where game_id=thesi;
	delete from redtarget_empty where game_id=thesi;
	delete from bluemain where game_id=thesi;
    delete from bluetarget where game_id=thesi;
	delete from redmain where game_id=thesi;
	delete from redtarget where game_id=thesi;
	delete from players where game_id=thesi;
    delete from game_status where game_id=thesi;
    delete from game where game_id=thesi;
end//
DELIMITER ;

-- Dumping structure for table naymaxia.game
CREATE TABLE IF NOT EXISTS `game` (
  `game_id` tinyint(1) NOT NULL,
  PRIMARY KEY (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table naymaxia.game_status
CREATE TABLE IF NOT EXISTS `game_status` (
  `game_id` tinyint(1) NOT NULL,
  `status` enum('not active','initialized','started','aborted') NOT NULL DEFAULT 'not active',
  `p_turn` enum('B','R') DEFAULT NULL,
  `result` enum('B','R') DEFAULT NULL,
  `last_change` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  KEY `game_id` (`game_id`),
  CONSTRAINT `game_status_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for procedure naymaxia.hit
DELIMITER //
CREATE PROCEDURE `hit`(in color enum('B', 'R'), in game_ids tinyint(1), in xs tinyint(1), in ys tinyint(1))
begin
        declare piece_value varchar(4);
		if color = 'B' then

            select piece into piece_value
            from redmain
            where game_id=game_ids and x=xs and y=ys;
            
            if piece_value is null then
				update bluetarget set game_id=game_ids, x=xs, y=ys, piece='X' where game_id=game_ids and x=xs and y=ys;
			else
				update bluetarget set game_id=game_ids, x=xs, y=ys, piece='O' where game_id=game_ids and x=xs and y=ys;
                update redmain set game_id=game_ids, x=xs, y=ys, piece='O' where game_id=game_ids and x=xs and y=ys;
            end if;
        else
        
			select piece into piece_value
            from bluemain
            where game_id=game_ids and x=xs and y=ys;
            
			if piece_value is null then
				update redtarget set game_id=game_ids, x=xs, y=ys, piece='X' where game_id=game_ids and x=xs and y=ys;
			else
				update redtarget set game_id=game_ids, x=xs, y=ys, piece='O' where game_id=game_ids and x=xs and y=ys;
                update bluemain set game_id=game_ids, x=xs, y=ys, piece='O' where game_id=game_ids and x=xs and y=ys;
			end if;
        end if;
        
        update game_status set p_turn=if(color='B','R','B');
	end//
DELIMITER ;

-- Dumping structure for table naymaxia.players
CREATE TABLE IF NOT EXISTS `players` (
  `game_id` tinyint(1) NOT NULL,
  `username` varchar(20) DEFAULT NULL,
  `piece_color` enum('B','R') NOT NULL,
  `token` varchar(100) DEFAULT NULL,
  `last_action` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `ready` enum('Yes','No') DEFAULT 'No',
  PRIMARY KEY (`game_id`,`piece_color`),
  CONSTRAINT `players_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table naymaxia.redmain
CREATE TABLE IF NOT EXISTS `redmain` (
  `game_id` tinyint(1) NOT NULL,
  `x` tinyint(1) NOT NULL,
  `y` tinyint(1) NOT NULL,
  `piece` enum('AE1','AE2','AE3','AE4','AE5','AN1','AN2','AN3','AN4','PO1','PO2','PO3','YP1','YP2','AER1','AER2','AER3','AER4','AER5','ANR1','ANR2','ANR3','ANR4','POR1','POR2','POR3','YPR1','YPR2','X','O') DEFAULT NULL,
  PRIMARY KEY (`game_id`,`x`,`y`),
  CONSTRAINT `redmain_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table naymaxia.redmain_empty
CREATE TABLE IF NOT EXISTS `redmain_empty` (
  `game_id` tinyint(1) NOT NULL,
  `x` tinyint(1) NOT NULL,
  `y` tinyint(1) NOT NULL,
  `piece` enum('AE1','AE2','AE3','AE4','AE5','AN1','AN2','AN3','AN4','PO1','PO2','PO3','YP1','YP2','AER1','AER2','AER3','AER4','AER5','ANR1','ANR2','ANR3','ANR4','POR1','POR2','POR3','YPR1','YPR2','X','O') DEFAULT NULL,
  PRIMARY KEY (`game_id`,`x`,`y`),
  CONSTRAINT `redmain_empty_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table naymaxia.redtarget
CREATE TABLE IF NOT EXISTS `redtarget` (
  `game_id` tinyint(1) NOT NULL,
  `x` tinyint(1) NOT NULL,
  `y` tinyint(1) NOT NULL,
  `piece` enum('X','O') DEFAULT NULL,
  PRIMARY KEY (`game_id`,`x`,`y`),
  CONSTRAINT `redtarget_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table naymaxia.redtarget_empty
CREATE TABLE IF NOT EXISTS `redtarget_empty` (
  `game_id` tinyint(1) NOT NULL,
  `x` tinyint(1) NOT NULL,
  `y` tinyint(1) NOT NULL,
  `piece` enum('X','O') DEFAULT NULL,
  PRIMARY KEY (`game_id`,`x`,`y`),
  CONSTRAINT `redtarget_empty_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for procedure naymaxia.set_ship
DELIMITER //
CREATE PROCEDURE `set_ship`(in color enum('B', 'R'), in game_ids tinyint(1), in xs tinyint(1), in ys tinyint(1), in pieces enum('AE1', 'AE2','AE3','AE4','AE5', 'AN1', 'AN2', 'AN3', 'AN4', 'PO1', 'PO2', 'PO3', 'YP1', 'YP2','AER1', 'AER2','AER3','AER4','AER5', 'ANR1', 'ANR2', 'ANR3', 'ANR4', 'POR1', 'POR2', 'POR3', 'YPR1', 'YPR2', 'X', 'O'))
begin
		if color = 'B' then
			update bluemain set game_id=game_ids, x=xs, y=ys, piece=pieces where game_id=game_ids and x=xs and y=ys;
        else
			update redmain set game_id=game_ids, x=xs, y=ys, piece=pieces where game_id=game_ids and x=xs and y=ys;
        end if;
	end//
DELIMITER ;

-- Dumping structure for procedure naymaxia.set_username
DELIMITER //
CREATE PROCEDURE `set_username`(in usernamen varchar(20),in piece_colorn enum('B', 'R'))
begin
			update players set username=usernamen where piece_color=piece_colorn;
        end//
DELIMITER ;

-- Dumping structure for procedure naymaxia.start_game
DELIMITER //
CREATE PROCEDURE `start_game`()
begin
	declare count int;
    declare max int;
    select count(*) into count
    from game;
    
    if count<=0 or count=null then
		set count=1;
	else
		 select max(game_id) into max
		from game;
		set count=max+1;
    end if;
    insert into game value(count);
    
    insert into bluemain_empty values (count, 1, 1, null),(count, 1, 2, null),(count, 1, 3, null),(count, 1, 4, null),(count, 1, 5, null),(count, 1, 6, null),(count, 1, 7, null),(count, 1, 8, null),(count, 1, 9, null),(count, 1, 10, null),(count, 2, 1, null),(count, 2, 2, null),(count, 2, 3, null),(count, 2, 4, null),(count, 2, 5, null),(count, 2, 6, null),(count, 2, 7, null),(count, 2, 8, null),(count, 2, 9, null),(count, 2, 10, null),(count, 3, 1, null),(count, 3, 2, null),(count, 3, 3, null),(count, 3, 4, null),(count, 3, 5, null),(count, 3, 6, null),(count, 3, 7, null),(count, 3, 8, null),(count, 3, 9, null),(count, 3, 10, null),(count, 4, 1, null),(count, 4, 2, null),(count, 4, 3, null),(count, 4, 4, null),(count, 4, 5, null),(count, 4, 6, null),(count, 4, 7, null),(count, 4, 8, null),(count, 4, 9, null),(count, 4, 10, null),(count, 5, 1, null),(count, 5, 2, null),(count, 5, 3, null),(count, 5, 4, null),(count, 5, 5, null),(count, 5, 6, null),(count, 5, 7, null),(count, 5, 8, null),(count, 5, 9, null),(count, 5, 10, null),(count, 6, 1, null),(count, 6, 2, null),(count, 6, 3, null),(count, 6, 4, null),(count, 6, 5, null),(count, 6, 6, null),(count, 6, 7, null),(count, 6, 8, null),(count, 6, 9, null),(count, 6, 10, null),(count, 7, 1, null),(count, 7, 2, null),(count, 7, 3, null),(count, 7, 4, null),(count, 7, 5, null),(count, 7, 6, null),(count, 7, 7, null),(count, 7, 8, null),(count, 7, 9, null),(count, 7, 10, null),(count, 8, 1, null),(count, 8, 2, null),(count, 8, 3, null),(count, 8, 4, null),(count, 8, 5, null),(count, 8, 6, null),(count, 8, 7, null),(count, 8, 8, null),(count, 8, 9, null),(count, 8, 10, null),(count, 9, 1, null),(count, 9, 2, null),(count, 9, 3, null),(count, 9, 4, null),(count, 9, 5, null),(count, 9, 6, null),(count, 9, 7, null),(count, 9, 8, null),(count, 9, 9, null),(count, 9, 10, null),(count, 10, 1, null),(count, 10, 2, null),(count, 10, 3, null),(count, 10, 4, null),(count, 10, 5, null),(count, 10, 6, null),(count, 10, 7, null),(count, 10, 8, null),(count, 10, 9, null),(count, 10, 10, null);
    
    insert into redmain_empty values (count, 1, 1, null),(count, 1, 2, null),(count, 1, 3, null),(count, 1, 4, null),(count, 1, 5, null),(count, 1, 6, null),(count, 1, 7, null),(count, 1, 8, null),(count, 1, 9, null),(count, 1, 10, null),(count, 2, 1, null),(count, 2, 2, null),(count, 2, 3, null),(count, 2, 4, null),(count, 2, 5, null),(count, 2, 6, null),(count, 2, 7, null),(count, 2, 8, null),(count, 2, 9, null),(count, 2, 10, null),(count, 3, 1, null),(count, 3, 2, null),(count, 3, 3, null),(count, 3, 4, null),(count, 3, 5, null),(count, 3, 6, null),(count, 3, 7, null),(count, 3, 8, null),(count, 3, 9, null),(count, 3, 10, null),(count, 4, 1, null),(count, 4, 2, null),(count, 4, 3, null),(count, 4, 4, null),(count, 4, 5, null),(count, 4, 6, null),(count, 4, 7, null),(count, 4, 8, null),(count, 4, 9, null),(count, 4, 10, null),(count, 5, 1, null),(count, 5, 2, null),(count, 5, 3, null),(count, 5, 4, null),(count, 5, 5, null),(count, 5, 6, null),(count, 5, 7, null),(count, 5, 8, null),(count, 5, 9, null),(count, 5, 10, null),(count, 6, 1, null),(count, 6, 2, null),(count, 6, 3, null),(count, 6, 4, null),(count, 6, 5, null),(count, 6, 6, null),(count, 6, 7, null),(count, 6, 8, null),(count, 6, 9, null),(count, 6, 10, null),(count, 7, 1, null),(count, 7, 2, null),(count, 7, 3, null),(count, 7, 4, null),(count, 7, 5, null),(count, 7, 6, null),(count, 7, 7, null),(count, 7, 8, null),(count, 7, 9, null),(count, 7, 10, null),(count, 8, 1, null),(count, 8, 2, null),(count, 8, 3, null),(count, 8, 4, null),(count, 8, 5, null),(count, 8, 6, null),(count, 8, 7, null),(count, 8, 8, null),(count, 8, 9, null),(count, 8, 10, null),(count, 9, 1, null),(count, 9, 2, null),(count, 9, 3, null),(count, 9, 4, null),(count, 9, 5, null),(count, 9, 6, null),(count, 9, 7, null),(count, 9, 8, null),(count, 9, 9, null),(count, 9, 10, null),(count, 10, 1, null),(count, 10, 2, null),(count, 10, 3, null),(count, 10, 4, null),(count, 10, 5, null),(count, 10, 6, null),(count, 10, 7, null),(count, 10, 8, null),(count, 10, 9, null),(count, 10, 10, null);
    
    insert into bluetarget_empty values (count, 1, 1, null),(count, 1, 2, null),(count, 1, 3, null),(count, 1, 4, null),(count, 1, 5, null),(count, 1, 6, null),(count, 1, 7, null),(count, 1, 8, null),(count, 1, 9, null),(count, 1, 10, null),(count, 2, 1, null),(count, 2, 2, null),(count, 2, 3, null),(count, 2, 4, null),(count, 2, 5, null),(count, 2, 6, null),(count, 2, 7, null),(count, 2, 8, null),(count, 2, 9, null),(count, 2, 10, null),(count, 3, 1, null),(count, 3, 2, null),(count, 3, 3, null),(count, 3, 4, null),(count, 3, 5, null),(count, 3, 6, null),(count, 3, 7, null),(count, 3, 8, null),(count, 3, 9, null),(count, 3, 10, null),(count, 4, 1, null),(count, 4, 2, null),(count, 4, 3, null),(count, 4, 4, null),(count, 4, 5, null),(count, 4, 6, null),(count, 4, 7, null),(count, 4, 8, null),(count, 4, 9, null),(count, 4, 10, null),(count, 5, 1, null),(count, 5, 2, null),(count, 5, 3, null),(count, 5, 4, null),(count, 5, 5, null),(count, 5, 6, null),(count, 5, 7, null),(count, 5, 8, null),(count, 5, 9, null),(count, 5, 10, null),(count, 6, 1, null),(count, 6, 2, null),(count, 6, 3, null),(count, 6, 4, null),(count, 6, 5, null),(count, 6, 6, null),(count, 6, 7, null),(count, 6, 8, null),(count, 6, 9, null),(count, 6, 10, null),(count, 7, 1, null),(count, 7, 2, null),(count, 7, 3, null),(count, 7, 4, null),(count, 7, 5, null),(count, 7, 6, null),(count, 7, 7, null),(count, 7, 8, null),(count, 7, 9, null),(count, 7, 10, null),(count, 8, 1, null),(count, 8, 2, null),(count, 8, 3, null),(count, 8, 4, null),(count, 8, 5, null),(count, 8, 6, null),(count, 8, 7, null),(count, 8, 8, null),(count, 8, 9, null),(count, 8, 10, null),(count, 9, 1, null),(count, 9, 2, null),(count, 9, 3, null),(count, 9, 4, null),(count, 9, 5, null),(count, 9, 6, null),(count, 9, 7, null),(count, 9, 8, null),(count, 9, 9, null),(count, 9, 10, null),(count, 10, 1, null),(count, 10, 2, null),(count, 10, 3, null),(count, 10, 4, null),(count, 10, 5, null),(count, 10, 6, null),(count, 10, 7, null),(count, 10, 8, null),(count, 10, 9, null),(count, 10, 10, null);
    
    insert into redtarget_empty values (count, 1, 1, null),(count, 1, 2, null),(count, 1, 3, null),(count, 1, 4, null),(count, 1, 5, null),(count, 1, 6, null),(count, 1, 7, null),(count, 1, 8, null),(count, 1, 9, null),(count, 1, 10, null),(count, 2, 1, null),(count, 2, 2, null),(count, 2, 3, null),(count, 2, 4, null),(count, 2, 5, null),(count, 2, 6, null),(count, 2, 7, null),(count, 2, 8, null),(count, 2, 9, null),(count, 2, 10, null),(count, 3, 1, null),(count, 3, 2, null),(count, 3, 3, null),(count, 3, 4, null),(count, 3, 5, null),(count, 3, 6, null),(count, 3, 7, null),(count, 3, 8, null),(count, 3, 9, null),(count, 3, 10, null),(count, 4, 1, null),(count, 4, 2, null),(count, 4, 3, null),(count, 4, 4, null),(count, 4, 5, null),(count, 4, 6, null),(count, 4, 7, null),(count, 4, 8, null),(count, 4, 9, null),(count, 4, 10, null),(count, 5, 1, null),(count, 5, 2, null),(count, 5, 3, null),(count, 5, 4, null),(count, 5, 5, null),(count, 5, 6, null),(count, 5, 7, null),(count, 5, 8, null),(count, 5, 9, null),(count, 5, 10, null),(count, 6, 1, null),(count, 6, 2, null),(count, 6, 3, null),(count, 6, 4, null),(count, 6, 5, null),(count, 6, 6, null),(count, 6, 7, null),(count, 6, 8, null),(count, 6, 9, null),(count, 6, 10, null),(count, 7, 1, null),(count, 7, 2, null),(count, 7, 3, null),(count, 7, 4, null),(count, 7, 5, null),(count, 7, 6, null),(count, 7, 7, null),(count, 7, 8, null),(count, 7, 9, null),(count, 7, 10, null),(count, 8, 1, null),(count, 8, 2, null),(count, 8, 3, null),(count, 8, 4, null),(count, 8, 5, null),(count, 8, 6, null),(count, 8, 7, null),(count, 8, 8, null),(count, 8, 9, null),(count, 8, 10, null),(count, 9, 1, null),(count, 9, 2, null),(count, 9, 3, null),(count, 9, 4, null),(count, 9, 5, null),(count, 9, 6, null),(count, 9, 7, null),(count, 9, 8, null),(count, 9, 9, null),(count, 9, 10, null),(count, 10, 1, null),(count, 10, 2, null),(count, 10, 3, null),(count, 10, 4, null),(count, 10, 5, null),(count, 10, 6, null),(count, 10, 7, null),(count, 10, 8, null),(count, 10, 9, null),(count, 10, 10, null);
    
    
    insert into bluemain values (count, 1, 1, null),(count, 1, 2, null),(count, 1, 3, null),(count, 1, 4, null),(count, 1, 5, null),(count, 1, 6, null),(count, 1, 7, null),(count, 1, 8, null),(count, 1, 9, null),(count, 1, 10, null),(count, 2, 1, null),(count, 2, 2, null),(count, 2, 3, null),(count, 2, 4, null),(count, 2, 5, null),(count, 2, 6, null),(count, 2, 7, null),(count, 2, 8, null),(count, 2, 9, null),(count, 2, 10, null),(count, 3, 1, null),(count, 3, 2, null),(count, 3, 3, null),(count, 3, 4, null),(count, 3, 5, null),(count, 3, 6, null),(count, 3, 7, null),(count, 3, 8, null),(count, 3, 9, null),(count, 3, 10, null),(count, 4, 1, null),(count, 4, 2, null),(count, 4, 3, null),(count, 4, 4, null),(count, 4, 5, null),(count, 4, 6, null),(count, 4, 7, null),(count, 4, 8, null),(count, 4, 9, null),(count, 4, 10, null),(count, 5, 1, null),(count, 5, 2, null),(count, 5, 3, null),(count, 5, 4, null),(count, 5, 5, null),(count, 5, 6, null),(count, 5, 7, null),(count, 5, 8, null),(count, 5, 9, null),(count, 5, 10, null),(count, 6, 1, null),(count, 6, 2, null),(count, 6, 3, null),(count, 6, 4, null),(count, 6, 5, null),(count, 6, 6, null),(count, 6, 7, null),(count, 6, 8, null),(count, 6, 9, null),(count, 6, 10, null),(count, 7, 1, null),(count, 7, 2, null),(count, 7, 3, null),(count, 7, 4, null),(count, 7, 5, null),(count, 7, 6, null),(count, 7, 7, null),(count, 7, 8, null),(count, 7, 9, null),(count, 7, 10, null),(count, 8, 1, null),(count, 8, 2, null),(count, 8, 3, null),(count, 8, 4, null),(count, 8, 5, null),(count, 8, 6, null),(count, 8, 7, null),(count, 8, 8, null),(count, 8, 9, null),(count, 8, 10, null),(count, 9, 1, null),(count, 9, 2, null),(count, 9, 3, null),(count, 9, 4, null),(count, 9, 5, null),(count, 9, 6, null),(count, 9, 7, null),(count, 9, 8, null),(count, 9, 9, null),(count, 9, 10, null),(count, 10, 1, null),(count, 10, 2, null),(count, 10, 3, null),(count, 10, 4, null),(count, 10, 5, null),(count, 10, 6, null),(count, 10, 7, null),(count, 10, 8, null),(count, 10, 9, null),(count, 10, 10, null);
    
    insert into redmain values (count, 1, 1, null),(count, 1, 2, null),(count, 1, 3, null),(count, 1, 4, null),(count, 1, 5, null),(count, 1, 6, null),(count, 1, 7, null),(count, 1, 8, null),(count, 1, 9, null),(count, 1, 10, null),(count, 2, 1, null),(count, 2, 2, null),(count, 2, 3, null),(count, 2, 4, null),(count, 2, 5, null),(count, 2, 6, null),(count, 2, 7, null),(count, 2, 8, null),(count, 2, 9, null),(count, 2, 10, null),(count, 3, 1, null),(count, 3, 2, null),(count, 3, 3, null),(count, 3, 4, null),(count, 3, 5, null),(count, 3, 6, null),(count, 3, 7, null),(count, 3, 8, null),(count, 3, 9, null),(count, 3, 10, null),(count, 4, 1, null),(count, 4, 2, null),(count, 4, 3, null),(count, 4, 4, null),(count, 4, 5, null),(count, 4, 6, null),(count, 4, 7, null),(count, 4, 8, null),(count, 4, 9, null),(count, 4, 10, null),(count, 5, 1, null),(count, 5, 2, null),(count, 5, 3, null),(count, 5, 4, null),(count, 5, 5, null),(count, 5, 6, null),(count, 5, 7, null),(count, 5, 8, null),(count, 5, 9, null),(count, 5, 10, null),(count, 6, 1, null),(count, 6, 2, null),(count, 6, 3, null),(count, 6, 4, null),(count, 6, 5, null),(count, 6, 6, null),(count, 6, 7, null),(count, 6, 8, null),(count, 6, 9, null),(count, 6, 10, null),(count, 7, 1, null),(count, 7, 2, null),(count, 7, 3, null),(count, 7, 4, null),(count, 7, 5, null),(count, 7, 6, null),(count, 7, 7, null),(count, 7, 8, null),(count, 7, 9, null),(count, 7, 10, null),(count, 8, 1, null),(count, 8, 2, null),(count, 8, 3, null),(count, 8, 4, null),(count, 8, 5, null),(count, 8, 6, null),(count, 8, 7, null),(count, 8, 8, null),(count, 8, 9, null),(count, 8, 10, null),(count, 9, 1, null),(count, 9, 2, null),(count, 9, 3, null),(count, 9, 4, null),(count, 9, 5, null),(count, 9, 6, null),(count, 9, 7, null),(count, 9, 8, null),(count, 9, 9, null),(count, 9, 10, null),(count, 10, 1, null),(count, 10, 2, null),(count, 10, 3, null),(count, 10, 4, null),(count, 10, 5, null),(count, 10, 6, null),(count, 10, 7, null),(count, 10, 8, null),(count, 10, 9, null),(count, 10, 10, null);
    
    insert into bluetarget values (count, 1, 1, null),(count, 1, 2, null),(count, 1, 3, null),(count, 1, 4, null),(count, 1, 5, null),(count, 1, 6, null),(count, 1, 7, null),(count, 1, 8, null),(count, 1, 9, null),(count, 1, 10, null),(count, 2, 1, null),(count, 2, 2, null),(count, 2, 3, null),(count, 2, 4, null),(count, 2, 5, null),(count, 2, 6, null),(count, 2, 7, null),(count, 2, 8, null),(count, 2, 9, null),(count, 2, 10, null),(count, 3, 1, null),(count, 3, 2, null),(count, 3, 3, null),(count, 3, 4, null),(count, 3, 5, null),(count, 3, 6, null),(count, 3, 7, null),(count, 3, 8, null),(count, 3, 9, null),(count, 3, 10, null),(count, 4, 1, null),(count, 4, 2, null),(count, 4, 3, null),(count, 4, 4, null),(count, 4, 5, null),(count, 4, 6, null),(count, 4, 7, null),(count, 4, 8, null),(count, 4, 9, null),(count, 4, 10, null),(count, 5, 1, null),(count, 5, 2, null),(count, 5, 3, null),(count, 5, 4, null),(count, 5, 5, null),(count, 5, 6, null),(count, 5, 7, null),(count, 5, 8, null),(count, 5, 9, null),(count, 5, 10, null),(count, 6, 1, null),(count, 6, 2, null),(count, 6, 3, null),(count, 6, 4, null),(count, 6, 5, null),(count, 6, 6, null),(count, 6, 7, null),(count, 6, 8, null),(count, 6, 9, null),(count, 6, 10, null),(count, 7, 1, null),(count, 7, 2, null),(count, 7, 3, null),(count, 7, 4, null),(count, 7, 5, null),(count, 7, 6, null),(count, 7, 7, null),(count, 7, 8, null),(count, 7, 9, null),(count, 7, 10, null),(count, 8, 1, null),(count, 8, 2, null),(count, 8, 3, null),(count, 8, 4, null),(count, 8, 5, null),(count, 8, 6, null),(count, 8, 7, null),(count, 8, 8, null),(count, 8, 9, null),(count, 8, 10, null),(count, 9, 1, null),(count, 9, 2, null),(count, 9, 3, null),(count, 9, 4, null),(count, 9, 5, null),(count, 9, 6, null),(count, 9, 7, null),(count, 9, 8, null),(count, 9, 9, null),(count, 9, 10, null),(count, 10, 1, null),(count, 10, 2, null),(count, 10, 3, null),(count, 10, 4, null),(count, 10, 5, null),(count, 10, 6, null),(count, 10, 7, null),(count, 10, 8, null),(count, 10, 9, null),(count, 10, 10, null);
    
    insert into redtarget values (count, 1, 1, null),(count, 1, 2, null),(count, 1, 3, null),(count, 1, 4, null),(count, 1, 5, null),(count, 1, 6, null),(count, 1, 7, null),(count, 1, 8, null),(count, 1, 9, null),(count, 1, 10, null),(count, 2, 1, null),(count, 2, 2, null),(count, 2, 3, null),(count, 2, 4, null),(count, 2, 5, null),(count, 2, 6, null),(count, 2, 7, null),(count, 2, 8, null),(count, 2, 9, null),(count, 2, 10, null),(count, 3, 1, null),(count, 3, 2, null),(count, 3, 3, null),(count, 3, 4, null),(count, 3, 5, null),(count, 3, 6, null),(count, 3, 7, null),(count, 3, 8, null),(count, 3, 9, null),(count, 3, 10, null),(count, 4, 1, null),(count, 4, 2, null),(count, 4, 3, null),(count, 4, 4, null),(count, 4, 5, null),(count, 4, 6, null),(count, 4, 7, null),(count, 4, 8, null),(count, 4, 9, null),(count, 4, 10, null),(count, 5, 1, null),(count, 5, 2, null),(count, 5, 3, null),(count, 5, 4, null),(count, 5, 5, null),(count, 5, 6, null),(count, 5, 7, null),(count, 5, 8, null),(count, 5, 9, null),(count, 5, 10, null),(count, 6, 1, null),(count, 6, 2, null),(count, 6, 3, null),(count, 6, 4, null),(count, 6, 5, null),(count, 6, 6, null),(count, 6, 7, null),(count, 6, 8, null),(count, 6, 9, null),(count, 6, 10, null),(count, 7, 1, null),(count, 7, 2, null),(count, 7, 3, null),(count, 7, 4, null),(count, 7, 5, null),(count, 7, 6, null),(count, 7, 7, null),(count, 7, 8, null),(count, 7, 9, null),(count, 7, 10, null),(count, 8, 1, null),(count, 8, 2, null),(count, 8, 3, null),(count, 8, 4, null),(count, 8, 5, null),(count, 8, 6, null),(count, 8, 7, null),(count, 8, 8, null),(count, 8, 9, null),(count, 8, 10, null),(count, 9, 1, null),(count, 9, 2, null),(count, 9, 3, null),(count, 9, 4, null),(count, 9, 5, null),(count, 9, 6, null),(count, 9, 7, null),(count, 9, 8, null),(count, 9, 9, null),(count, 9, 10, null),(count, 10, 1, null),(count, 10, 2, null),(count, 10, 3, null),(count, 10, 4, null),(count, 10, 5, null),(count, 10, 6, null),(count, 10, 7, null),(count, 10, 8, null),(count, 10, 9, null),(count, 10, 10, null);
    
    insert into players values(count, null, 'B', null, null, 'No');
	
    insert into players values(count, null, 'R', null, null, 'No');

    insert into game_status values(count, 'not active', null, null, null);
end//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
