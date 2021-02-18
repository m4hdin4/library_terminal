delimiter ;
CREATE DATABASE IF NOT EXISTS book_store;
USE book_store;
SET NAMES utf8;
SET GLOBAL log_bin_trust_function_creators = 1;




CREATE TABLE IF NOT EXISTS customer (
    customer_id INT,
    first_name VARCHAR(30) NOT NULL,
    middle_initial VARCHAR(30),
    last_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_id),
    INDEX customer_names (last_name ASC, first_name ASC, middle_initial ASC)
);

CREATE TABLE IF NOT EXISTS normal_customer (
    customer_id INT,
    job VARCHAR(20) NOT NULL,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS university_customer (
    customer_id INT,
    university VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS student_customer (
    customer_id INT,
    student_id VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (customer_id)
        REFERENCES university_customer (customer_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS master_customer (
    customer_id INT,
    master_id VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (customer_id)
        REFERENCES university_customer (customer_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS customer_addresses (
    customer_id INT,
    cus_address VARCHAR(512),
    PRIMARY KEY (customer_id , cus_address),
    FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS customer_phones (
    customer_id INT,
    phone VARCHAR(11) NOT NULL,
    PRIMARY KEY (customer_id , phone),
    FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS publication (
    publication_name VARCHAR(50),
    pub_address VARCHAR(512),
    website VARCHAR(100),
    UNIQUE (website),
    PRIMARY KEY (publication_name)
);

CREATE TABLE IF NOT EXISTS book (
    book_id INTEGER,
    volume INTEGER DEFAULT 0,
    title VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    publication_name VARCHAR(50) NOT NULL,
    publication_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    pages INTEGER,
    price INTEGER NOT NULL,
    CHECK ((pages IS NULL OR pages > 0)
        AND price > 0
        AND book_id > 0
        AND volume >= 0),
    PRIMARY KEY (book_id , volume),
    FOREIGN KEY (publication_name)
        REFERENCES publication (publication_name),
	INDEX book_titles (title ASC),
    INDEX book_publication_date (publication_date ASC)
);

CREATE TABLE IF NOT EXISTS book_authors (
    book_id INTEGER,
    author VARCHAR(50),
    PRIMARY KEY (book_id , author),
    FOREIGN KEY (book_id)
        REFERENCES book (book_id),
	INDEX book_autor(author ASC)
);

CREATE TABLE IF NOT EXISTS account (
    customer_id INT NOT NULL,
    username VARCHAR(16) CHARSET utf8 COLLATE UTF8_BIN,
    rolename VARCHAR(20) NOT NULL,
    password VARCHAR(100),
    balance INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (customer_id),
    CHECK (balance >= 0),
    CHECK (LENGTH(username) >= 6
        AND username REGEXP '^[a-zA-Z0-9]+$'),
    PRIMARY KEY (username),
    FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
        ON DELETE CASCADE,
    CHECK (rolename IN ('nor' , 'stu', 'mas', 'res', 'man'))
);

CREATE TABLE IF NOT EXISTS warehouse_book (
    book_id INTEGER,
    volume INTEGER,
    version_id INTEGER,
    PRIMARY KEY (book_id , volume , version_id),
    FOREIGN KEY (book_id , volume)
        REFERENCES book (book_id , volume)
);

CREATE TABLE IF NOT EXISTS borrow_history (
    borrow_id INTEGER,
    username VARCHAR(16) COLLATE UTF8_BIN,
    book_id INTEGER NOT NULL,
    volume INTEGER NOT NULL,
    version_id INTEGER NOT NULL,
    allowed_days INTEGER,
    start_borrow TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    return_borrow TIMESTAMP,
    CHECK (return_borrow IS NULL
        OR allowed_days IS NULL
        OR (allowed_days > 0
        AND return_borrow BETWEEN start_borrow AND ADDDATE(start_borrow,
        INTERVAL allowed_days DAY))),
    PRIMARY KEY (username , borrow_id),
    FOREIGN KEY (username)
        REFERENCES account (username)
        ON DELETE CASCADE,
    FOREIGN KEY (book_id , volume)
        REFERENCES book (book_id , volume)
)  COLLATE UTF8_BIN;


CREATE TABLE IF NOT EXISTS login_info (
    login_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(16) COLLATE UTF8_BIN NOT NULL,
    rolename VARCHAR(20) NOT NULL,
    password VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (username , rolename),
    FOREIGN KEY (username)
        REFERENCES account (username)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS responsibles_messages (
    rm_id INT PRIMARY KEY AUTO_INCREMENT,
    rm_message VARCHAR(512),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
)  ENGINE=MYISAM;

CREATE TABLE IF NOT EXISTS user_logs (
    ul_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(16) COLLATE UTF8_BIN NOT NULL,
    ul_message VARCHAR(512) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (username)
        REFERENCES account (username)
)  ENGINE=MYISAM;

DROP PROCEDURE IF EXISTS add_account;
DROP PROCEDURE IF EXISTS test_data;
DROP FUNCTION IF EXISTS make_login;
DROP PROCEDURE IF EXISTS make_expire;
DROP FUNCTION IF EXISTS get_role;
DROP PROCEDURE IF EXISTS user_information_system;
DROP PROCEDURE IF EXISTS user_information_phones;
DROP PROCEDURE IF EXISTS user_information_addresses;
DROP PROCEDURE IF EXISTS user_proc_search;
DROP PROCEDURE IF EXISTS user_proc_borrow;
DROP PROCEDURE IF EXISTS user_proc_borrow_list;
DROP PROCEDURE IF EXISTS user_proc_return;
DROP PROCEDURE IF EXISTS user_proc_add_balance;
DROP PROCEDURE IF EXISTS res_proc_add_book;
DROP PROCEDURE IF EXISTS res_proc_insert_book;
DROP PROCEDURE IF EXISTS res_proc_insert_author;
DROP PROCEDURE IF EXISTS res_proc_messages;
DROP PROCEDURE IF EXISTS res_proc_see_delays;
DROP PROCEDURE IF EXISTS res_proc_borrow_history;
DROP PROCEDURE IF EXISTS res_proc_search_users;
DROP PROCEDURE IF EXISTS res_proc_users_history;
DROP PROCEDURE IF EXISTS res_proc_delete_account;
DROP PROCEDURE IF EXISTS res_proc_add_publication;
DROP TRIGGER IF EXISTS rm_message_borrow;
DROP TRIGGER IF EXISTS rm_message_return;

DELIMITER //
CREATE PROCEDURE add_account(i_username VARCHAR(16) CHARSET utf8 COLLATE utf8_bin, i_password VARCHAR(16) CHARSET utf8 COLLATE utf8_bin,
	i_first_name VARCHAR(30) , i_middle_initial VARCHAR(30) , i_last_name VARCHAR(50) ,
    i_role VARCHAR(20),i_job VARCHAR(20) , i_university VARCHAR(50) , i_student_id VARCHAR(50) , i_master_id VARCHAR(50) ,
    i_cus_address VARCHAR(512) , i_phone VARCHAR(11))
BEGIN
	DECLARE v_customer_id INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
    IF (i_password IS NULL OR i_password REGEXP "^(?!.*[0-9])" OR i_password REGEXP "^(?!.*[a-z A-Z])" OR length(i_password) < 8) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'the password must contain letters and numbers and at least 8 length!!';
	ELSEIF (i_role IS NULL OR i_role NOT IN ('nor' , 'stu' , 'mas' , 'res', 'man')) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'the user must have a valid role';
	ELSEIF (i_username IS NULL OR i_username NOT REGEXP "^[a-zA-Z0-9]+$"OR length(i_username) < 6) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'the username must be just letters and numbers and at least 6 length!!';
	ELSEIF (i_first_name IS NULL OR i_first_name = '') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'the first name can''t be empty!!';
	ELSEIF (i_last_name IS NULL OR i_last_name = '') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'the last name can''t be empty!!';
	ELSEIF (i_role = 'nor' AND (i_job IS NULL OR i_job = '')) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'a normal customer must have a job!!';
	ELSEIF (i_role = 'stu' AND (i_university IS NULL OR i_student_id IS NULL OR i_university = '' OR i_student_id = '')) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'a student customer must have a university and a student id!!';
	ELSEIF (i_role = 'mas' AND (i_university IS NULL OR i_master_id IS NULL OR i_university = '' OR i_master_id = '')) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'a master customer must have a university and a master id!!';
    END IF;
    START TRANSACTION;
    SELECT
		MAX(customer_id) + 1
		INTO
			v_customer_id
	FROM
		customer;
    IF v_customer_id IS NULL THEN
		SET v_customer_id = 1;
	END IF;
    
    INSERT INTO
		customer
	VALUES
		(v_customer_id , i_first_name , i_middle_initial , i_last_name);
    IF i_role = 'nor' THEN
		INSERT INTO
			normal_customer
		VALUES
			(v_customer_id , i_job);
	ELSEIF i_role = 'stu' THEN
		INSERT INTO
			university_customer
		VALUES
			(v_customer_id , i_university);
        INSERT INTO
			student_customer
		VALUES
			(v_customer_id , i_student_id);
	ELSEIF i_role = 'mas' THEN
		INSERT INTO
			university_customer
		VALUES
			(v_customer_id , i_university);
        INSERT INTO
			master_customer
		VALUES
			(v_customer_id , i_master_id);
    END IF;
    INSERT INTO
		account (customer_id , username , rolename , password)
	VALUES
		(v_customer_id , i_username , i_role , MD5(i_password));
    
    IF i_cus_address IS NOT NULL AND i_cus_address <> '' THEN
		INSERT INTO
			customer_addresses
		VALUES
			(v_customer_id , i_cus_address);
    END IF;
    
    IF i_phone IS NOT NULL AND i_phone <> '' THEN
		INSERT INTO
			customer_phones
		VALUES
			(v_customer_id , i_phone);
    END IF;
    
    IF `_rollback` THEN
        ROLLBACK;
        SELECT
			'we couldn''t do that!!';
    ELSE
        COMMIT;
        SELECT
			'the account created successfully!!';
    END IF;
END //

CREATE PROCEDURE test_data ()
BEGIN
	DECLARE v_temp INT;
	SELECT
		MAX(customer_id)
	INTO
		v_temp
	FROM
		customer;
	IF (v_temp IS NULL) THEN
		CALL add_account('manager' , 'm12345678' , 'mehdi' , '' , 'nasri' , 'man' , '' , '' , '' , '' , 'Tehran' , '09133239153');
    END IF;
END//

CREATE FUNCTION make_login(i_username VARCHAR(16) CHARSET utf8 COLLATE utf8_bin , i_password VARCHAR(16) CHARSET utf8 COLLATE utf8_bin)
	RETURNS INT
BEGIN
	DECLARE v_password VARCHAR(100);
    DECLARE v_rolename VARCHAR(20);
    DECLARE v_cur_log_id INT;
    
    SELECT
		password,
        rolename
		into
			v_password,
            v_rolename
	FROM
		account
	WHERE
		username = i_username;

	
    IF (v_password IS NULL OR v_password <> MD5(i_password)) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'username or password is wrong!!';
	ELSE
		INSERT INTO
			login_info (username , rolename , password)
		VALUES
			(i_username , v_rolename , v_password);
            
            
        SELECT
			MAX(login_id)
            INTO
				v_cur_log_id
		FROM
			login_info;
		
        INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(i_username , 'loged in');
                
        RETURN v_cur_log_id;
    END IF;
END//

CREATE PROCEDURE make_expire (i_login_id INT)
BEGIN
	DECLARE v_username VARCHAR(16) CHARSET utf8 COLLATE UTF8_BIN;
	SELECT 
		username
	INTO v_username FROM
		login_info
	WHERE
		login_id = i_login_id;
        
	DELETE FROM	
		login_info 
	WHERE
		login_id = i_login_id;
	INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(v_username , 'loged out');
    COMMIT;
    SELECT
		'you log out seccesfully';
END//

CREATE FUNCTION get_role (i_login_id INT)
	RETURNS VARCHAR(20)
BEGIN
	DECLARE v_role VARCHAR(20);
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	RETURN v_role;
END//

CREATE PROCEDURE user_information_system(i_login_id INT)
BEGIN
    SELECT
		a.username,
        c.first_name,
        c.middle_initial,
        c.last_name,
        a.balance,
        n.job,
        u.university,
        s.student_id,
        m.master_id,
        a.created_at
	FROM
		login_info l
			JOIN account a
				ON l.username = a.username
			JOIN customer c
				ON a.customer_id = c.customer_id
            LEFT OUTER JOIN normal_customer n
				ON c.customer_id = n.customer_id
            LEFT OUTER JOIN university_customer u
				ON c.customer_id = u.customer_id
            LEFT OUTER JOIN student_customer s
				ON u.customer_id = s.customer_id
            LEFT OUTER JOIN master_customer m
				ON u.customer_id = m.customer_id
	WHERE
		l.login_id = i_login_id;
END//
CREATE PROCEDURE user_information_phones(i_login_id INT)
BEGIN
    SELECT
		cp.phone
	FROM
		login_info l
			JOIN account a
				ON l.username = a.username
            JOIN customer_phones cp
				ON a.customer_id = cp.customer_id
	WHERE
		l.login_id = i_login_id;
END//
CREATE PROCEDURE user_information_addresses(i_login_id INT)
BEGIN
    SELECT
		ca.cus_address
	FROM
		login_info l
			JOIN account a
				ON l.username = a.username
            JOIN customer_addresses ca
				ON a.customer_id = ca.customer_id
	WHERE
		l.login_id = i_login_id;
END//

CREATE PROCEDURE user_proc_search(i_login_id INT , i_title VARCHAR(50) , i_author VARCHAR(50) ,
												i_version_id VARCHAR(50) , i_publication_date VARCHAR(10))
BEGIN
	SELECT
		b.book_id,
        b.volume,
        b.title,
        b.category,
        b.publication_name,
        cast(b.publication_date AS DATE),
        b.pages,
        b.price
	FROM
		book b
	WHERE
		(i_publication_date IS NULL OR i_publication_date = '' OR
			CAST(b.publication_date AS CHAR) LIKE concat('%' , i_publication_date , '%')) AND
        (i_title IS NULL OR i_title = '' OR
			b.title like concat('%' , i_title , '%')) AND
        (i_author IS NULL OR i_author = '' OR
			b.book_id IN
				(
                SELECT
					book_id
				FROM
					book_authors
				WHERE
					author LIKE concat('%' , i_author , '%')
				)) AND
        (i_version_id IS NULL OR i_version_id = '' OR
			cast(b.book_id AS CHAR) IN
				(
                SELECT
					book_id
				FROM
					warehouse_book
				WHERE
					cast(version_id AS CHAR) LIKE concat('%' , i_version_id , '%')
				));
END//
CREATE PROCEDURE user_proc_borrow(i_login_id INT , i_book_id INT , i_volume INT)
BEGIN
	DECLARE v_username VARCHAR(16) CHARSET utf8 COLLATE UTF8_BIN;
	DECLARE v_rolename VARCHAR(20);
    DECLARE v_category VARCHAR(50);
    DECLARE v_price INT;
    DECLARE v_balance INT;
    DECLARE v_version_id INT;
    DECLARE v_delay_count INT;
    DECLARE v_borrow_id INT;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
	SELECT 
		username,
        rolename
	INTO
		v_username,
        v_rolename
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	SELECT 
		category, price / 20
	INTO v_category , v_price FROM
		book
	WHERE
		book_id = i_book_id
			AND volume = i_volume;
	SELECT 
		balance
	INTO v_balance FROM
		account
	WHERE
		username = v_username;
		SELECT 
		MIN(version_id)
	INTO v_version_id FROM
		warehouse_book
	WHERE
		book_id = i_book_id
			AND volume = i_volume;

	SELECT 
		COUNT(1)
	INTO v_delay_count FROM
		borrow_history b
	WHERE
		b.username = v_username
			AND DATEDIFF(IF(b.return_borrow IS NULL,
					NOW(),
					b.return_borrow),
				b.start_borrow) > b.allowed_days
			AND DATEDIFF(NOW(), b.start_borrow) < 60;
	
    IF (v_delay_count > 3) THEN
		INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(v_username , 'tried to take a book but couldn''t because of too musch delays');
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'I''m sorry. you have been banned now because of some delays in bring back the books!!';
    END IF;
    
    IF((v_rolename = 'nor' AND v_category IN ('uni' , 'ref')) OR (v_rolename = 'stu' AND v_category = 'ref')) THEN
		INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(v_username , 'tried to take a book but couldn''t because of the role');
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you don''t have access to this book';
    END IF;
    
    IF (v_price > v_balance) THEN
		INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(v_username , 'tried to take a book but couldn''t because of the balance');
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Sorry but you don''t have enough balance!';
    END IF;
    
    IF(v_version_id IS NULL) THEN
		INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(v_username , 'tried to take a book but couldn''t because of the capacity');
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'We have finished this book!';
    END IF;
    SELECT
		MAX(borrow_id) + 1
        INTO
			v_borrow_id
	FROM
		borrow_history
	WHERE
		username = v_username;
	
    IF (v_borrow_id IS NULL) THEN
		SET v_borrow_id = 1;
    END IF;
    
    START TRANSACTION;
    INSERT INTO
		borrow_history (borrow_id , username , book_id , volume , version_id ,  allowed_days)
	VALUES
		(v_borrow_id , v_username , i_book_id , i_volume , v_version_id , 14);
	DELETE FROM
		warehouse_book 
	WHERE
		book_id = i_book_id
		AND volume = i_volume
		AND version_id = v_version_id;
	UPDATE account 
	SET 
		balance = balance - v_price
	WHERE
		username = v_username;
    
    IF `_rollback` THEN
        ROLLBACK;
		INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(v_username , 'tried to take a book but couldn''t');
		SELECT
			'we couldn\'t do that!!';
    ELSE
		COMMIT;
		INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(v_username , 'taked a book');
		SELECT 
			'the book borrowed successfully!!';
    END IF;
    
    
END//

CREATE PROCEDURE user_proc_borrow_list(i_login_id INT)
BEGIN
    SELECT
		bh.borrow_id,
        bh.book_id,
        (
			SELECT
				b.title
			FROM
				book b
			WHERE
				b.book_id = bh.book_id
        ) AS book_title,
        bh.volume,
        bh.start_borrow,
        IF(bh.return_borrow IS NULL ,
			'NOT RETURN YET' ,
            bh.return_borrow)
	FROM
		borrow_history bh
			JOIN login_info li ON bh.username = li.username
	WHERE
		li.login_id = i_login_id;
END//

CREATE PROCEDURE user_proc_return(i_login_id INT , i_borrow_id INT)
BEGIN
	DECLARE v_username VARCHAR(16) CHARSET utf8 COLLATE UTF8_BIN;
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
    START TRANSACTION;
	SELECT 
		username
	INTO v_username FROM
		login_info
	WHERE
		login_id = i_login_id;
    INSERT INTO
		warehouse_book
			(
				SELECT
					book_id ,
					volume ,
                    version_id
				FROM
					borrow_history
				WHERE
					borrow_id = i_borrow_id AND
					username = v_username
			);
	UPDATE
		borrow_history 
	SET 
		return_borrow = NOW()
	WHERE
		borrow_id = i_borrow_id
			AND username = v_username;
	IF `_rollback` THEN
        ROLLBACK;
        INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(i_username , 'tried to bring back a book but couldn''t');
		SELECT
			'we couldn\'t do that!!';
    ELSE
        COMMIT;
        INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(i_username , 'bring a book back');
			SELECT 
				'the book returned successfully!!';
    END IF;
END//

CREATE PROCEDURE user_proc_add_balance(i_login_id INT , i_balance INT)
BEGIN
	DECLARE v_username VARCHAR(16) CHARSET utf8 COLLATE UTF8_BIN;
	DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
	IF i_balance <= 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The balance you''re setting should be over 0!!';
    END IF;
    SELECT 
		username
	INTO v_username FROM
		login_info
	WHERE
		login_id = i_login_id;
    UPDATE
		account
	SET
		balance = balance + i_balance
	WHERE
		username = v_username;
	IF `_rollback` THEN
        ROLLBACK;
        INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(i_username , 'tried to add to his balance but couldn''t');
        SELECT
			'we couldn''t do that!!';
    ELSE
        COMMIT;
        INSERT INTO
			user_logs (username , ul_message)
		VALUES
			(i_username , concat('added ' , i_balance , '$ to balance successfully'));
        SELECT
			concat('you added ' , i_balance , '$ to your balance successfully');
    END IF;
END//

CREATE PROCEDURE res_proc_insert_book (i_login_id INT , i_book_id INT , i_volume INT, i_title VARCHAR(50) , i_category VARCHAR(50) ,
	i_publication_name VARCHAR(50) , i_publication_date VARCHAR(10) , i_pages INT , i_price INT)
BEGIN
	DECLARE v_role VARCHAR(20);
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	
    IF (v_role <> 'res' AND v_role <> 'man') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you do''t have the Required privilages to do that!';
	ELSE
		INSERT INTO
			book
		VALUES
			(i_book_id , i_volume , i_title , i_category , i_publication_name , i_publication_date , i_pages , i_price);
    END IF;
    IF `_rollback` THEN
        ROLLBACK;
        SELECT
			'we couldn''t do that!!';
    ELSE
        COMMIT;
        SELECT
			'Book added successfully';
    END IF;
END//

CREATE PROCEDURE res_proc_insert_author (i_login_id INT , i_book_id INT , i_author VARCHAR(50))
BEGIN
	DECLARE v_role VARCHAR(20);
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	IF (v_role <> 'res' AND v_role <> 'man') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you do''t have the Required privilages to do that!';
	ELSE
		INSERT INTO
			book_authors
		VALUES
			(i_book_id , i_author);
		SELECT
			'inserted author successfully';
    END IF;
END//

CREATE PROCEDURE res_proc_add_book (i_login_id INT , i_book_id INT, i_volume INT , i_version_id_begin INT , i_version_id_end INT)
BEGIN
	DECLARE i INT;
    DECLARE v_role VARCHAR(20);
    DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	
    IF (v_role <> 'res' AND v_role <> 'man') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you do''t have the Required privilages to do that!';
	ELSEIF (i_version_id_end < i_version_id_begin) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'End of the version should be more than Begin!!';
	ELSEIF (i_volume < 1) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'volume should be 1 or higher!!';
    END IF;
    
    SET i = i_version_id_begin;
    START TRANSACTION;
    WHILE i <= i_version_id_end DO
		INSERT INTO
			warehouse_book
		VALUES
			(i_book_id , i_volume , i);
		SET i = i + 1;
    END WHILE;
    
    IF `_rollback` THEN
        ROLLBACK;
        SELECT
			'we couldn''t do that!!';
    ELSE
        COMMIT;
        SELECT
			'books added to warehouse successfully!!';
	END IF;
END//

CREATE PROCEDURE res_proc_messages (i_login_id INT , i_page INT)
BEGIN
	DECLARE v_role VARCHAR(20);
	DECLARE v_page INT;
    SET v_page = (i_page - 1) * 5;
    IF (v_page < 0) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'please enter a valid page number!!';
    END IF;
    
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	
    IF (v_role <> 'res' AND v_role <> 'man') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you do''t have the Required privilages to do that!';
    END IF;
    
    SELECT
		rm_message
	FROM
		responsibles_messages
	ORDER BY
		created_at DESC
		LIMIT v_page,5;
END//
CREATE PROCEDURE res_proc_see_delays (i_login_id INT)
BEGIN
	DECLARE v_role VARCHAR(20);
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	
    IF (v_role <> 'res' AND v_role <> 'man') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you do''t have the Required privilages to do that!';
	END IF;
    SELECT
		bh.book_id,
        (
			SELECT
				title
			FROM
				book b
			WHERE
				b.book_id = bh.book_id
        ) AS title,
        bh.volume,
        bh.version_id,
        bh.username,
        datediff(NOW() , bh.start_borrow) - bh.allowed_days AS delay
	FROM
		borrow_history bh
	WHERE
		bh.return_borrow IS NULL AND
        datediff(NOW() , bh.start_borrow) > bh.allowed_days
	ORDER BY
		delay DESC;
END//

CREATE PROCEDURE res_proc_borrow_history (i_login_id INT , i_book_id INT)
BEGIN
	DECLARE v_role VARCHAR(20);
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	
    IF (v_role <> 'res' AND v_role <> 'man') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you do''t have the Required privilages to do that!';
	END IF;
    
    SELECT
        (
			SELECT
				title
			FROM
				book b
			WHERE
				b.book_id = bh.book_id
        ) AS title,
        bh.volume,
        bh.version_id,
        bh.start_borrow,
        IF(bh.return_borrow IS NULL ,
			'NOT RETURN YET' ,
            bh.return_borrow)
	FROM
		borrow_history bh
	WHERE
		book_id = i_book_id
	ORDER BY
		bh.start_borrow DESC;
END//

CREATE PROCEDURE res_proc_search_users (i_login_id INT , i_username VARCHAR(16) CHARSET utf8 COLLATE utf8_bin , i_last_name VARCHAR(50) , i_page INT)
BEGIN
	DECLARE v_page INT;
	DECLARE v_role VARCHAR(20);
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	
    IF (v_role <> 'res' AND v_role <> 'man') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you do''t have the Required privilages to do that!';
	END IF;
    SET v_page = (i_page - 1) * 5;
    
    SELECT
		c.customer_id,
		a.username,
        c.first_name,
        c.middle_initial,
        c.last_name,
        a.balance,
        n.job,
        u.university,
        s.student_id,
        m.master_id,
        a.created_at
	FROM
		account a
			JOIN customer c
				ON a.customer_id = c.customer_id
            LEFT OUTER JOIN normal_customer n
				ON c.customer_id = n.customer_id
            LEFT OUTER JOIN university_customer u
				ON c.customer_id = u.customer_id
            LEFT OUTER JOIN student_customer s
				ON u.customer_id = s.customer_id
            LEFT OUTER JOIN master_customer m
				ON u.customer_id = m.customer_id
		WHERE
			(i_username IS NULL OR i_username = '' OR
				a.username LIKE concat('%' , i_username , '%')) AND
			(i_last_name IS NULL OR i_last_name = '' OR
				c.last_name LIKE concat('%' , i_last_name , '%'))
		ORDER BY
			c.last_name , c.first_name , c.middle_initial
		LIMIT
			v_page,5;
END//

CREATE PROCEDURE res_proc_users_history (i_login_id INT , i_username VARCHAR(16))
BEGIN
	DECLARE v_role VARCHAR(20);
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	
    IF (v_role <> 'res' AND v_role <> 'man') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you do''t have the Required privilages to do that!';
	END IF;
    
	SELECT
		ul_message
	FROM
		user_logs
	WHERE
		username = i_username
	ORDER BY
		created_at DESC;
END//
CREATE PROCEDURE res_proc_delete_account (i_login_id INT , i_customer_id INT)
BEGIN
	DECLARE v_role VARCHAR(20);
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	
    IF (v_role <> 'man') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you do''t have the Required privilages to do that!';
	END IF;
    
    DELETE FROM
		customer
	WHERE
		customer_id = i_customer_id;
	
    SELECT
		'user deleted successfully!!';
END//

CREATE PROCEDURE res_proc_add_publication (i_login_id INT , i_publication_name VARCHAR(50) , i_pub_address VARCHAR(512) , i_website VARCHAR(100))
BEGIN
	DECLARE v_role VARCHAR(20);
    SELECT
		rolename
		INTO
			v_role
	FROM
		login_info
	WHERE
		login_id = i_login_id;
	
    IF (v_role <> 'man') THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'you do''t have the Required privilages to do that!';
	END IF;
    
    INSERT INTO
		publication
	VALUES
		(i_publication_name , i_pub_address , i_website);
	
    SELECT
		'publication inserted successfully!!';
END//

CREATE TRIGGER rm_message_borrow AFTER INSERT ON borrow_history FOR EACH ROW
BEGIN
	INSERT INTO responsibles_messages (rm_message) VALUES (
		concat('In date ' , NOW() , ' user with username ' , NEW.username ,
		' borrowed book with code ' , NEW.book_id , ' and volume ' , NEW.volume ,
		' and version ' , NEW.version_id , ' successfully!!')
	);
END//

CREATE TRIGGER rm_message_return AFTER UPDATE ON borrow_history FOR EACH ROW
BEGIN
	IF (NEW.return_borrow IS NOT NULL AND NEW.return_borrow <> OLD.return_borrow) THEN
		IF (datediff(NEW.return_borrow , NEW.start_borrow) <= NEW.allowed_days) THEN
			INSERT INTO responsibles_messages (rm_message) VALUES
			(
				concat('In date ' , NEW.return_borrow , ' user with username ' ,
				NEW.username ,' returned book with code ' , NEW.book_id , ' and volume ' ,
				NEW.volume , ' and version ' , NEW.version_id , ', ' ,
				NEW.allowed_days - datediff(NEW.return_borrow , NEW.start_borrow) , ' day(s) EARLY')
			);
		ELSE
			INSERT INTO responsibles_messages (rm_message) VALUES
			(
				concat('In date ' , NEW.return_borrow , ' user with username ' ,
				NEW.username ,' borrowed book with code ' , NEW.book_id , ' and volume ' ,
				NEW.volume , ' and version ' , NEW.version_id , ', ' ,
				datediff(NEW.start_borrow , NEW.return_borrow) - NEW.allowed_days, 'day(s) LATE!!')
			);

		END IF;
	END IF;
END//

DELIMITER ;

CALL test_data();