import fastapi as _fastapi
import sqlalchemy.orm as _orm
from sqlalchemy.exc import DBAPIError
from passlib.context import CryptContext as _crypt_ctx
import database.models as _models
import schemas as _schemas
import services as _services


async def get_users(db: _orm.Session):
    users = db.query(_models.User)
    return list(map(_schemas.User.from_orm, users))


async def create_user(ctx: _crypt_ctx, user: _schemas.FormUser, db: _orm.Session):
    salt = _services.get_random_salt()
    user_dict = user.dict()
    password = user_dict.pop("password")
    user = _models.User(
        **user_dict,
        salt=salt,
        hashed_password=_services.get_password_hash(ctx, password, salt),
        role=_schemas.UserRole.CUSTOMER.value
    )

    db.add(user)
    try:
        db.commit()
    except DBAPIError as e:
        print(e)
        raise _fastapi.HTTPException(
            status_code=401, detail="Username or mail already in use"
        )

    db.refresh(user)
    return _schemas.User.from_orm(user)


async def get_user(username: str, db: _orm.Session):
    return db.query(_models.User).filter(_models.User.username == username).first()


async def delete_user(username: str, db: _orm.Session):
    username = db.query(_models.User).filter(_models.User.username == username).first()

    db.delete(username)
    db.commit()


async def update_user(username: str, user: _schemas.User, db: _orm.Session):
    user_db = db.query(_models.User).filter(_models.User.username == username).first()

    user_db.role = user.role

    try:
        db.commit()
    except DBAPIError as e:
        raise _fastapi.HTTPException(
            status_code=401, detail="Username or mail already in use"
        ) from e

    db.refresh(user_db)
    return _schemas.User.from_orm(user_db)
