select * from person;
select * from photo order by postingdate desc;
select * from friendgroup;
select * from belongto;
select * from sharedwith;

select * from follow;
select * from tag;

-- update photo
-- set filepath = "static/img/mountain.jpg"
-- where pid = 3;

insert into friendgroup (groupname, groupcreator, description) values ('NYU', 'thrmn', 'A group for students currently attending NYU');
insert into friendgroup (groupname, groupcreator, description) values ('Game of Thrones', 'thrmn', 'A group for Game of Thrones fans');
insert into BelongTo (username, groupname, groupcreator) values ('thrmn', 'NYU', 'thrmn');
insert into BelongTo (username, groupname, groupcreator) values ('jnd', 'NYU', 'thrmn');
insert into BelongTo (username, groupname, groupcreator) values ('thrmn', 'Game of Thrones', 'thrmn');

select groupname from belongto where username = 'thrmn';

SELECT `AUTO_INCREMENT`
FROM  INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'Finstagram'
AND   TABLE_NAME   = 'Photo';

select groupcreator from friendgroup where groupname = 'NYU';

SELECT * FROM belongto WHERE username = 'thrmn' and groupname = 'NYU';
select * from person natural join belongto natural join friendgroup where username = 'thrmn';
select followee from follow where followStatus = 0 and follower = 'jnd';

sELECT * FROM follow WHERE followStatus = 0 AND followee = 'thrmn';
UPDATE follow SET followstatus = 1 WHERE follower = 'jhnsmth' AND followee = 'thrmn' AND followstatus = 0;
UPDATE follow SET followstatus = 0 WHERE follower = 'jnd' AND followee = 'thrmn' AND followstatus = 1;

update follow set followstatus = 0 where followee = 'thrmn';

DELETE FROM follow WHERE follower = 'jnd' AND followee = 'thrmn' AND followStatus = 0;

-- INSERT INTO reactto (username, pID, reactiontime, comment, emoji)
INSERT INTO tag (pid, username, tagstatus) VALUES (28, 'jnd', 0);

select * from photo where poster = 'thrmn';
select * from photo where poster = 'jnd';


select * from photo where poster = 'geohot';

-- select *
-- from 
-- where followstatus = 1 or photo.poster = 'thrmn';

select * from person natural join photo where person.username = photo.poster;
select * from person natural join follow where person.username = follow.followee AND followstatus = 1;

select * from photo join person on person.username = photo.poster join follow on person.username = follow.follower where person.username = 'thrmn';

select pID, postingDate, filePath, allFollowers, caption, posterv
from person join follow on (person.username = follow.follower) join photo on (follow.follower = photo.poster)
where followStatus = 1 OR person.username = 'jhnsmth'
order by postingdate desc;

select * from follow;
select * from photo where poster = 'thrmn' and allfollowers = 1;
SELECT * from tag;

-- show all photos (user's photos and all followers)
SELECT distinct pid, postingdate, filepath, allfollowers, caption, poster
FROM person JOIN follow ON (person.username = follow.follower) JOIN photo ON (follow.followee = photo.poster)
WHERE (follow.follower = 'geohot' AND follow.followstatus = 1) OR (poster = 'geohot')
ORDER BY postingdate DESC;
-- problem with current query is that it shows photos from everyone you follow, but the result doesnt contain photos that the user itself has posted

SELECT distinct pid, postingdate, filepath, allfollowers, caption, poster
FROM person JOIN follow ON (person.username = follow.follower) JOIN photo ON (follow.followee = photo.poster)
WHERE (follow.follower = 'geohot' AND follow.followstatus = 1) OR (follow.followee = 'geohot')
ORDER BY postingdate DESC;

SELECT *
FROM person JOIN follow ON (person.username = follow.follower) JOIN photo ON (follow.followee = photo.poster)
WHERE follow.follower = 'hrrypttr' AND followstatus = 1;

select * 
from person join follow on (person.username = follow.follower) join photo on (follow.followee = photo.poster)
where person.username = 'geohot';

-- UNION pt 1+2most recent correct query w/o friendgroup shared
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM person JOIN follow ON (person.username = follow.follower) JOIN photo ON (follow.followee = photo.poster)
WHERE follow.follower = 'jnd' AND followstatus = 1 AND allfollowers = 1
UNION
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM photo
WHERE poster = 'jnd'
ORDER BY postingdate DESC;

-- most recent correct query w/ friendgroup shared
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM person JOIN follow ON (person.username = follow.follower) JOIN photo ON (follow.followee = photo.poster)
WHERE follow.follower = 'D' AND followstatus = 1 AND allfollowers = 1
UNION
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM photo
WHERE poster = 'D'
UNION
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM person JOIN belongto ON (person.username = belongto.username) JOIN sharedwith ON (belongto.groupname = sharedwith.groupname) NATURAL JOIN photo 
WHERE person.username = 'D'
ORDER BY postingdate DESC;

-- (INCORRECT pt 3) photos sharedwith friendgroups user belongs in (incorrect as of test data, A should not be able to see 3 since 3 was shared with a different group named best friends
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM person JOIN belongto ON (person.username = belongto.username) JOIN sharedwith ON (belongto.groupname = sharedwith.groupname) NATURAL JOIN photo 
WHERE person.username = 'A';

--  (correct) UNION PT 3 photos sharedwith friendgroups user belongs in
SELECT *
FROM person JOIN belongto ON (person.username = belongto.username) JOIN sharedwith ON (belongto.groupname = sharedwith.groupname) AND (belongto.groupcreator = sharedwith.groupcreator) NATURAL JOIN photo 
WHERE person.username = 'A';
    
SELECT * FROM photo JOIN person ON (photo.poster = person.username) WHERE pid = 34;
SELECT * FROM tag JOIN person ON (tag.username = person.username) WHERE tag.pid = 34 AND tagstatus = 1;
SELECT * FROM tag WHERE pid = 34 AND username = 'thrmn' AND tagstatus = 0;

-- see if given user can see a given photo, change follow.followerS and pIDs
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM person JOIN follow ON (person.username = follow.follower) JOIN photo ON (follow.followee = photo.poster)
WHERE follow.follower = 'jnhsmth' AND followstatus = 1 AND allfollowers = 1 AND pID = 41
UNION
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM person JOIN belongto ON (person.username = belongto.username) JOIN sharedwith ON (belongto.groupname = sharedwith.groupname) NATURAL JOIN photo 
WHERE person.username = 'jhnsmth' AND pID = 41
ORDER BY postingdate DESC;

select * from photo where pid = 41;

select * from person;
select * from photo order by postingdate desc;
select * from friendgroup;
select * from belongto;
select * from sharedwith;
select * from reactto order by reactiontime asc;
select * from follow;
select * from tag;


insert into belongto (username, groupname, groupcreator) values ('testuser', 'Administrators', 'secureadmin');
delete from friendgroup where groupname = '206' and groupcreator = 'thrmn';
update person set password = '0bce500e4b03f8a68e722105001eda09a1bcdf8dddbfd243068b9d453c8ae6b8' where username = 'geohot';


delete from person where username = 'thrmn';