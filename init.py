from flask import Flask, render_template, request, session, url_for, redirect
from flask_bootstrap import Bootstrap
from werkzeug.utils import secure_filename

import os
import datetime
import pymysql.cursors
import blob

# === Incomplete ===
# Password hashing
# Photo share with
# Check if session is logged in, else redirect to login

app = Flask(__name__)
Bootstrap(app)

conn = pymysql.connect(
    host='localhost',
    port=8889,
    user='root',
    password='root',
    db='Finstagram',
    charset='utf8mb4',
    cursorclass=pymysql.cursors.DictCursor
)

# os.makedirs(os.path.join(app.instance_path, 'imgFiles'), exist_ok=True)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/login')
def login():
    return render_template('login.html')

@app.route('/register')
def register():
    return render_template('register.html')

@app.route('/loginAuth', methods=['GET', 'POST'])
def loginAuth():
    username = request.form['username']
    password = request.form['password']

    cursor = conn.cursor()
    query = "SELECT * FROM person WHERE username = %s and password = %s"
    cursor.execute(query, (username, password))
    data = cursor.fetchone()
    cursor.close()
    error = None
    if (data):
        session['username'] = username
        return redirect(url_for('home'))
    else:
        error = 'Invalid login or username'
        return render_template('login.html', error=error)

@app.route('/registerAuth', methods=['GET', 'POST'])
def registerAuth():
    username = request.form['username']
    password = request.form['password']
    firstname = request.form['firstname']
    lastname = request.form['lastname']
    email = request.form['email']

    cursor = conn.cursor()
    # Executes query
    query = "SELECT * FROM person WHERE username = %s"
    cursor.execute(query, (username))
    # Stores the results in a variable
    data = cursor.fetchone()

    error = None
    if (data):
        # If the previous query returns data, then user exists
        error = "This user already exists"
        return render_template('register.html', error = error)
    else:
        insertQuery = "INSERT INTO person VALUES(%s, %s, %s, %s, %s)"
        cursor.execute(insertQuery, (username, password, firstname, lastname, email))
        conn.commit()
        cursor.close()
        return render_template('index.html')

@app.route('/home')
def home():
    user = session['username']
    # cursor = conn.cursor()
    # query = "SELECT * FROM Photo WHERE poster = %s ORDER BY postingDate DESC"
    # cursor.execute(query, (user))
    # data = cursor.fetchall()
    # cursor.close()
    try:
        with conn.cursor() as cursor:
            # query = "SELECT DISTINCT pid, postingdate, filepath, allfollowers, caption, poster FROM person JOIN follow ON (person.username = follow.follower) JOIN photo ON (follow.followee = photo.poster) WHERE (follow.follower = %s AND follow.followstatus = 1) OR poster = %s ORDER BY postingdate DESC"
            query = "SELECT pid, postingdate, filepath, allfollowers, caption, poster FROM person JOIN follow ON (person.username = follow.follower) JOIN photo ON (follow.followee = photo.poster) WHERE follow.follower = %s AND followstatus = 1 AND allfollowers = 1 UNION SELECT pid, postingdate, filepath, allfollowers, caption, poster FROM photo WHERE poster = %s UNION SELECT pid, postingdate, filepath, allfollowers, caption, poster FROM person JOIN belongto ON (person.username = belongto.username) JOIN sharedwith ON (belongto.groupname = sharedwith.groupname) NATURAL JOIN photo WHERE person.username = %s ORDER BY postingdate DESC"
            cursor.execute(query, (user, user, user))
            posts = cursor.fetchall()

        with conn.cursor() as cursor:
            query = "SELECT * FROM follow WHERE followstatus = 0 AND followee = %s"
            cursor.execute(query, (user))
            followData = cursor.fetchall()
            # print("followDATA:", followData)
        return render_template('home.html', username=user, posts=posts, followData=followData)
    except Exception as e:
        return str(e)
    # return render_template('home.html')

@app.route('/logout')
def logout():
    session.pop('username')
    return redirect('/')

@app.route('/upload')
def upload():
    user = session['username']
    postingDate = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    session['postingDate'] = postingDate

    # Fetch relevant FriendGroups
    cursor = conn.cursor()
    query = "SELECT * FROM belongto WHERE username = %s"
    cursor.execute(query, (user))
    data = cursor.fetchall()
    cursor.close()
    return render_template('upload.html', username=user, postingDate=postingDate, groups=data)

def insertPhoto(username, postingDate, filePath, allFollowers, caption):
    # Inserting corresponding values to database
    try:
        cursor = conn.cursor()
        query = "INSERT INTO photo (pid, postingdate, filepath, allfollowers, caption, poster) VALUES (%s, %s, %s, %s, %s, %s)"
        queryTuple = (0, postingDate, filePath, allFollowers, caption, username)
        cursor.execute(query, queryTuple)
        conn.commit()
        cursor.close()
    except Exception as e:
        return str(e)

def insertSharedWith(pID, groupName):
    try:
        print("in INSERTSHAREDWITH")
        # Query for groupCreator
        user = session['username']
        with conn.cursor() as cursor:
            print("in first with")
            selectQuery = "SELECT groupcreator FROM belongto WHERE username = %s AND groupname = %s"
            cursor.execute(selectQuery, (user, groupName))
            data = cursor.fetchone()
            print(data['groupcreator'])
            groupCreator = data['groupcreator']

        # Query to insert into SharedWith
        with conn.cursor() as cursor:
            print("in second with")
            insertQuery = "INSERT INTO sharedwith (pid, groupname, groupcreator) VALUES (%s, %s, %s)"
            queryTuple = (pID, groupName, groupCreator)
            cursor.execute(insertQuery, queryTuple)
            conn.commit()
            print("end of INSERTWITH, groupcreator is ", groupCreator)
        # query1 = "SELECT groupcreator FROM belongto WHERE username = %s AND groupname = %s"
        # query2 = "INSERT INTO sharedwith (pid, groupname, groupcreator) VALUES (%s, %s, %s)"
        # queries = [query1, query2]
    except Exception as e:
        return str(e)

@app.route('/uploadFile', methods=['GET', 'POST'])
def uploadFile():
    if (request.method == 'POST'):
        try:
            user = session['username']
            img = request.files['file']
            # postingDate = request.form['postingDate']
            # postingDate = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            postingDate = session['postingDate']
            allFollowers = request.form['allFollowers']
            allFollowers = 1 if (allFollowers == "True") else 0
            caption = request.form['caption']
            filename = ''
            friendGroup = request.form.get('friendGroup')
            print("FRIEND GROUP:", friendGroup)

            # Query for next pID
            with conn.cursor() as cursor:
                query = "SELECT `AUTO_INCREMENT` FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s"
                cursor.execute(query, ("Finstagram", "Photo"))
                data = cursor.fetchone()
                pID = str(data['AUTO_INCREMENT'])
                
            # cursor = conn.cursor()
            # query = "SELECT `AUTO_INCREMENT` FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s"
            # cursor.execute(query, ("Finstagram", "Photo"))
            # data = cursor.fetchone()
            # pID = str(data['AUTO_INCREMENT'])
            # cursor.close()

            if (img):
                # Photo name should have ID
                filename = secure_filename(img.filename)
                # filepath = os.path.join(app.instance_path, 'imgFiles', filename)
                filepath = "static/img/" + pID + '-' + filename
                # img.save(os.path.join(app.instance_path, 'imgFiles', filename))
                img.save(filepath)
                insertPhoto(user, postingDate, filepath, allFollowers, caption)

                session.pop('postingDate')
                # if (friendGroup != "default"):
                insertSharedWith(pID, friendGroup)
                return redirect(url_for('home'))
        except Exception as e:
            return str(e)

@app.route('/sendFollow', methods=['POST'])
def sendFollow():
    try:
        user = session['username']
        followee = request.form['sendFollow']

        if (followee != user):
            with conn.cursor() as cursor:
                query = "INSERT INTO follow (follower, followee, followstatus) VALUES (%s, %s, %s)"
                cursor.execute(query, (user, followee, 0))
                conn.commit()
        return redirect(url_for('home'))
    except Exception as e:
        return str(e)

@app.route('/followResponse', methods=['GET', 'POST'])
def followResponse():
    # followerAccept = request.form['accept']
    # followerDecline = request.form['decline']
    # print("FOLLOWER", followerDecline)
    # print("FOLLOWER", followerAccept)
    try:
        print("IN TRY")
        if (request.form['acceptDecline'] == "Accept"):
            print("IN TRY 2")
            user = session['username']
            follower = request.form['follower']
            print("FOLLOWER:", follower)

            with conn.cursor() as cursor:
                print("inside WITH followresponse")
                query = "UPDATE follow SET followstatus = 1 WHERE follower = %s AND followee = %s AND followstatus = 0"
                cursor.execute(query, (follower, user))
                conn.commit()
        elif (request.form['acceptDecline'] == "Decline"):
            print("DECLINED")
            user = session['username']
            follower = request.form['follower']

            with conn.cursor() as cursor:
                query = "DELETE FROM follow WHERE follower = %s AND followee = %s AND followstatus = 0"
                cursor.execute(query, (follower, user))
                conn.commit()
        return redirect(url_for('home'))
    except Exception as e:
        return str(e)

@app.route('/sendTag', methods=['GET', 'POST'])
def sendTag():
    user = session['username']
    tagged = request.form['sendTag']
    pID = session['pID']
    print("TAGGED IS", tagged)
    print("CURRENT SESSION ", session)
    
    # User is tagging him/herself
    if (user == tagged):
        try:
            with conn.cursor() as cursor:
                query = "INSERT INTO tag (pid, username, tagstatus) VALUES (%s, %s, %s)"
                cursor.execute(query, (pID, user, 1))
                conn.commit()
                session.pop('pID')
                print("AFTER INSERT ",session)
                
                return redirect(url_for('home'))
        except Exception as e:
            return str(e)
    # User is tagging someone else
    else:
        try:
            # Check if tagged user can see photo
            with conn.cursor() as cursor:
                query = "INSERT INTO tag (pid, username, tagstatus) VALUES (%s, %s, %s)"
                cursor.execute(query, (pID, tagged, 0))
                conn.commit()
                # session.pop('pID')
                print("AFTER INSERT ",session)

                return redirect(url_for('home'))
        except Exception as e:
            return str(e)


@app.route('/manageInfo/<string:pID>', methods=['GET', 'POST'])
def manageInfo(pID):
    user = session['username']
    try:
        # Get current photo information
        with conn.cursor() as cursor:
            query = "SELECT * FROM photo WHERE pid = %s"
            cursor.execute(query, (pID))
            photo = cursor.fetchone()
            session['pID'] = pID
            # print("\n", photo, "\n")

        # Get current tags for photo
        with conn.cursor() as cursor:
            pID = session['pID']
            query = "SELECT * FROM tag WHERE pid = %s AND tagstatus = 1"
            cursor.execute(query, (pID))
            tags = cursor.fetchall()

        with conn.cursor() as cursor:
            pID = session['pID']
            query = "SELECT * FROM reactto WHERE pid = %s ORDER BY reactiontime ASC"
            cursor.execute(query, (pID))
            comments = cursor.fetchall()

        return render_template('info.html', photo=photo, tags=tags, comments=comments)
    except Exception as e:
        return str(e)

@app.route('/reactTo', methods=['GET', 'POST'])
def reactTo():
    user = session['username']
    pID = session['pID']
    emoji = request.form['emoji']
    comment = request.form['comment']
    reactionTime = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    print(" emoji ", emoji, " and commment is ", comment)
    print(session)

    try:
        with conn.cursor() as cursor:
            query = "INSERT INTO reactto (username, pid, reactiontime, comment, emoji) VALUES (%s, %s, %s, %s, %s)"
            cursor.execute(query, (user, pID, reactionTime, comment, emoji))
            conn.commit()
        return redirect(url_for('manageInfo', pID=pID))
    except Exception as e:
        return str(e)

app.secret_key = 'Some key that you will never guess'

if __name__ == "__main__":
    app.run('127.0.0.1', 5001, debug = True)