CREATE TABLE EMT.TEST_CONTENT
(
  TEST_SEQ_NO NUMBER(19,0) NOT NULL
, CONTENT VARCHAR(100) NOT NULL
, CONSTRAINT PK_TEST_CONTENT PRIMARY KEY ( TEST_SEQ_NO)
);


CREATE SEQUENCE EMT.DEMO_TEST_SEQ_NO  MINVALUE 1 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE;

-- ALTER TABLE EMT.TEST_CONTENT COMMENT '테스트';