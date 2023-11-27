CREATE TABLE `testdb`.`TEST`
(
  TEST_SEQ_NO INT NOT NULL AUTO_INCREMENT
, CONTENT VARCHAR(100) NOT NULL
, CONSTRAINT PK_TEST PRIMARY KEY
  (
    TEST_SEQ_NO
  )
);


ALTER TABLE testdb.TEST COMMENT '테스트';

-- emoji를 위한 charset
SET NAMES utf8mb4;
ALTER DATABASE testdb CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci;
SHOW VARIABLES WHERE Variable_name LIKE 'character\_set\_%' OR Variable_name LIKE 'collation%';