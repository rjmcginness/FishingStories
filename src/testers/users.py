from flask import Blueprint
from flask import jsonify
from flask import abort
from flask import request
from flask import render_template

import sqlalchemy

import hashlib
import secrets

from ..models import User
from ..models import db
from ..models import Tweet
from ..models import likes_table
from ..forms import TestForm


def scramble(password: str) -> str:
    '''Hash and salt the given password'''
    salt = secrets.token_hex(16)
    return hashlib.sha512((password + salt).encode('utf-8')).hexdigest()


bp = Blueprint('users', __name__, url_prefix='/users')


@bp.route('/', methods=['GET'])
def users():
    print('>>>>>>>>>>IN /')
    users = User.query.all()
    return jsonify([user.serialize() for user in users])


@bp.route('/<int:user_id>', methods=['GET'])
def show(user_id: int):
    print("IN /users/id")
    user = User.query.get_or_404(user_id)
    # return jsonify(user.serialize())
    form = TestForm()
    form.username.data = user.username
    return render_template('test.html', form=form, user_id=user_id)


@bp.route('', methods=['POST'])
def create():
    if 'username' not in request.json or 'password' not in request.json:
        return abort(400)

    username = request.json['username']
    password = request.json['password']

    if len(username) < 3 or len(password) < 8:
        return abort(400)

    new_user = User(username, scramble(password))

    try:
        db.session.add(new_user)
        db.session.commit()
    except Exception:
        db.session.rollback()

    return jsonify(new_user.serialize())


@bp.route('/<int:user_id>', methods=['DELETE'])
def delete(user_id: int):
    user = User.query.get_or_404(user_id)
    try:
        db.session.delete(user)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify(False)

    return jsonify(True)


@bp.route('/<int:user_id>', methods=['PATCH', 'PUT'])
def update(user_id: int):

    form = TestForm()
    username = form.username.data
    password = form.password.data
    try:
        assert len(username) >= 3
        assert len(password) >= 8
    except (KeyError, AssertionError):
        return abort(400)

    # username = ''
    # password = ''
    # try:
    #     username = request.json['username']
    #     assert len(username) >= 3
    #     password = request.json['password']
    #     assert len(password) >= 8
    # except (KeyError, AssertionError):
    #     return abort(400)

    user = User.query.get_or_404(user_id)
    user.username = username
    user.password = scramble(password)

    try:
        db.session.commit()
        return jsonify(user.serialize())
    except:
        db.session.rollback()

    return jsonify(False)


@bp.route('/<int:user_id>/liked_tweets')
def liked_tweets(user_id: int):
    user = User.query.get_or_404(user_id)
    return jsonify([tweet.serialize() for tweet in user.liked_tweets])


@bp.route('/<int:user_id>/likes', methods=['POST'])
def like(user_id: int):

    tweet_id = ''
    try:
        tweet_id = request.json['tweet_id']
    except KeyError:
        return abort(400)

    user = User.query.get_or_404(user_id)
    tweet = Tweet.query.get_or_404(tweet_id)

    stmt = sqlalchemy.insert(likes_table).values(
        user_id=user.id, tweet_id=tweet.id)

    try:
        db.session.execute(stmt)
        db.session.commit()
    except sqlalchemy.exc.IntegrityError:
        db.session.rollback()
        return jsonify(False)

    return jsonify(True)


@bp.route('/<int:user_id>/likes/<int:tweet_id>', methods=['DELETE'])
def unlike(user_id: int, tweet_id: int):
    user = User.query.get_or_404(user_id)
    tweet = Tweet.query.get_or_404(tweet_id)

    stmt = sqlalchemy.delete(likes_table).where(
        likes_table.c.user_id == user_id).where(likes_table.c.tweet_id == tweet_id)

    try:
        db.session.execute(stmt)
        db.session.commit()
        return jsonify(True)
    except:
        db.session.rollback()
        return jsonify(False)
