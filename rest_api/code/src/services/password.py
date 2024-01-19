from passlib.context import CryptContext as _crypt_ctx
from passlib import pwd as _pwd
import database.models as _models


# ------- RANDOM OPERATIONS --------

def get_random_salt():
    return _pwd.genword(length=64, entropy=56, charset="hex")


# --------- HASH OPERATIONS -----------

def get_password_hash(ctx: _crypt_ctx, plain_password: str, salt: str):
    return ctx.hash(plain_password + salt)


def verify_password(ctx: _crypt_ctx, plain_password: str, user: _models.User):
    return ctx.verify(plain_password + user.salt, user.hashed_password)
