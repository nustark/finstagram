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

-- most recent correct query w/o friendgroup shared
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
WHERE follow.follower = 'jnd' AND followstatus = 1 AND allfollowers = 1
UNION
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM photo
WHERE poster = 'jnd'
UNION
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM person JOIN belongto ON (person.username = belongto.username) JOIN sharedwith ON (belongto.groupname = sharedwith.groupname) NATURAL JOIN photo 
WHERE person.username = 'jnd'
ORDER BY postingdate DESC;

-- photos sharedwith friendgroups user belongs in
SELECT pid, postingdate, filepath, allfollowers, caption, poster
FROM person JOIN belongto ON (person.username = belongto.username) JOIN sharedwith ON (belongto.groupname = sharedwith.groupname) NATURAL JOIN photo 
WHERE person.username = 'jnd';
    
select * from person;
select * from photo order by postingdate desc;
select * from friendgroup;
select * from belongto;
select * from sharedwith;

select * from follow;
select * from tag;