CREATE TABLE bad_posts (
id SERIAL PRIMARY KEY,
topic VARCHAR(50),
username VARCHAR(50),
title VARCHAR(150),
url VARCHAR(4000) DEFAULT NULL,
text_content TEXT DEFAULT NULL,
upvotes TEXT,
downvotes TEXT
);

CREATE TABLE bad_comments (
id SERIAL PRIMARY KEY,
username VARCHAR(50),
post_id BIGINT,
text_content TEXT
);


CREATE TABLE "register_user" (
"id" SERIAL PRIMARY KEY,
"name" VARCHAR(30),
"last_login" TIMESTAMP,
"username" VARCHAR(25) NOT NULL UNIQUE
);

CREATE TABLE "new_topic" (
"id" SERIAL PRIMARY KEY,
"topic_name" VARCHAR(30) NOT NULL UNIQUE,
"description" VARCHAR(500)
);

CREATE TABLE "new_post" (
"id" SERIAL PRIMARY KEY,
"username" VARCHAR(25),
"topic_name" VARCHAR(30) NOT NULL,
"post_title" VARCHAR(100) NOT NULL,
"link" VARCHAR(500),
"text_input" VARCHAR(3000),
"id_user" INTEGER,
"id_topic" INTEGER,
"time_created" TIMESTAMP,
CONSTRAINT "url_text_check" CHECK (("link" IS NULL AND "text_input" IS NOT NULL)
OR ("text_input" IS NULL AND "link" IS NOT NULL)),
CONSTRAINT "delete_topic" FOREIGN KEY ("id_topic")
REFERENCES "new_topic" ("id")
ON DELETE CASCADE,
CONSTRAINT "user_update" FOREIGN KEY ("id_user")
REFERENCES "register_user" ("id")
ON DELETE SET NULL
);

CREATE TABLE "user_comments" (
"id" SERIAL PRIMARY KEY,
"username" VARCHAR(25),
"comment" VARCHAR(1000) NOT NULL,
"post_id" INTEGER,
"main_comment_id" INTEGER,
"id_user" INTEGER,
"comment_time" TIMESTAMP,
CONSTRAINT "post_update" FOREIGN KEY ("post_id")
REFERENCES "new_post" ("id")
ON DELETE CASCADE,
CONSTRAINT "user_update" FOREIGN KEY ("id_user")
REFERENCES "register_user" ("id")
ON DELETE SET NULL,
CONSTRAINT "delete_thread" FOREIGN KEY ("main_comment_id")
REFERENCES "user_comments"
ON DELETE CASCADE
);

CREATE TABLE "user_vote" (
"id" SERIAL PRIMARY KEY,
"id_user" INTEGER,
"id_post" INTEGER,
"user_vote" SMALLINT CHECK ("user_vote" = '-1' OR "user_vote" = '1'),
CONSTRAINT "vote_update" FOREIGN KEY ("id_user")
REFERENCES "register_user" ("id")
ON DELETE SET NULL,
CONSTRAINT "delete_vote" FOREIGN KEY ("id_post")
REFERENCES "new_post" ("id")
ON DELETE CASCADE
);



INSERT INTO "register_user" ("username") (
SELECT DISTINCT "username"
FROM bad_posts
UNION
SELECT DISTINCT "username"
FROM bad_comments
UNION
SELECT DISTINCT regexp_split_to_table (downvotes, ',') as username FROM bad_posts
UNION
SELECT DISTINCT regexp_split_to_table (upvotes, ',') as username FROM bad_posts
);

INSERT INTO "new_topic" ("topic_name")
SELECT DISTINCT "topic"
FROM "bad_posts";

INSERT INTO "new_post" ("username","topic_name","post_title","link","text_input")
SELECT "username","topic", left('title', 100), "url", "text-content"
FROM bad_posts;
UPDATE new_posts SET "id_user" = (SELECT "id" FROM "users" WHERE "users"."username" =
"posts"."user_from_bad_posts");
UPDATE new_post SET "id_topic" = (SELECT "id" FROM "topics" WHERE
"topic"."name" = "posts"."topic_from_bad_posts");

INSERT INTO "user_comments" ("post_id","id_user","username","comment")
SELECT DISTINCT "t2.post_id","t2.user_id","t1.username","t1.text_content"
FROM bad_comments t1;
JOIN posts t2
ON t2.id = t1.post_id
JOIN users t3
ON t2.user_id = t3.id;

INSERT INTO "user_vote" ("post_id","id","user_vote")
SELECT register_user.id, dv.id, -1 AS downvotes
FROM (SELECT id, REGEXP_SPLIT_TO_TABLE(downvotes,',') AS downvote_users FROM
bad_posts) dv
JOIN register_user ON register_user.username=dv.downvote_users;

INSERT INTO "user_vote" ("post_id","id","user_vote")
SELECT register_user.id, dv.id, 1 AS upvotes
FROM (SELECT id, REGEXP_SPLIT_TO_TABLE(upvotes,',') AS upvote_users FROM bad_posts)
dv
JOIN register_user ON register_user.username=dv.upvote_users;