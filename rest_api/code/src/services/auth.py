from os import environ
import datetime as _dt
import fastapi as _fastapi
import sqlalchemy.orm as _orm
from jose import jwt as _jwt, exceptions as _jwt_exceptions
from passlib.context import CryptContext as _crypt_ctx
import database.models as _models
import schemas as _schemas
import services as _services
from database import operations as _db_ops


oauth2schema = _fastapi.security.OAuth2PasswordBearer(tokenUrl="/api/token")
ctx = _crypt_ctx(schemes=["bcrypt"], deprecated="auto")

# ----------- USER AUTH -------------

async def authenticate_user(username: str, password: str, db: _orm.Session):
    user = await _services.get_user(db=db, username=username)

    if not user:
        return False

    if not _services.verify_password(ctx, password, user):
        return False

    return user


async def create_token(user: _models.User):
    user_obj = _schemas.User.from_orm(user)

    expire = _dt.datetime.utcnow() + _dt.timedelta(minutes=int(environ['JWT_EXPIRATION_MINUTES']))
    #print(f"Expire date: {str(expire)}")
    #print(f"Current date: {_dt.datetime.utcnow()}")
    user_dict = user_obj.dict()
    user_dict['exp'] = expire

    return _jwt.encode(user_dict, environ['JWT_SECRET'], algorithm=environ['JWT_ALGORITHM'])


async def get_current_user(
    db: _orm.Session = _fastapi.Depends(_db_ops.get_db),
    token: str = _fastapi.Depends(oauth2schema),
):
    #print(f"get current user. token: {token}")
    #print(f"types: {type(db)} & token {type(token)}")
    try:
        payload = _jwt.decode(token, environ['JWT_SECRET'], algorithms=environ['JWT_ALGORITHM'])
        #print("Payload:")
        #print(payload)
    except _jwt_exceptions.ExpiredSignatureError as e:
        print("ExpiredSignatureError in get_current_user")
        print(str(e))
        raise _fastapi.HTTPException(status_code=403, detail="Token has expired") from e
    except _jwt_exceptions.JWTError as e:
        print("JWTError in get_current_user")
        print(str(e))
        raise _fastapi.HTTPException(status_code=401,
                                     detail="Could not validate credentials") from e
    except Exception as e:
        print("Other Exception while decoding the token on get_current_user")
        print(str(e))
        raise _fastapi.HTTPException(status_code=500, detail="Internal server error") from e

    try:
        user = db.query(_models.User).get(payload["username"])
    except Exception as e:
        print("Exception while obtaining the current user on get_current_user")
        print(str(e))
        raise _fastapi.HTTPException(status_code=500, detail="Internal server error") from e

    #print("obtained user:")
    #print(user)
    return _schemas.User.from_orm(user)


async def token_check(db: _orm.Session):
    #print("Token check")
    user = _schemas.User(username="admin", mail="admin@mail.com", role=1)
    #print(user)
    token = await create_token(user)
    #print(f"Generated token: {token}")
    ob_user = await get_current_user(db=db, token=token)
    #print("Obtained user:")
    #print(ob_user)


async def check_building_user_access(
    building_id: str,
    current_user: _schemas.User,
    db: _orm.Session = _fastapi.Depends(_db_ops.get_db)
):
    if current_user is None or not hasattr(current_user, 'username'):
        print("no user. current user:")
        print(current_user)
        return False

    building = await _services.get_building(
        building_id=building_id,
        db=db,
        username=current_user.username
    )
    # TODO: fix other elements return as db elements & not as ORM
    #print("Obtained building:")
    #print(building)
    if building is None:
        return False

    allowed_users = await _services.get_building_users_access(building_id, db)
    #print("auth check_building_user_access")
    #print(f"public? {building.public} \
    #    owner? {building.owner == current_user.username} \
    #    admin? {current_user.role is _schemas.UserRole.ADMIN.value} \
    #    access? {any(user == current_user.username for user in allowed_users)} ")
    return building.public is True or \
            building.owner == current_user.username or \
            current_user.role is _schemas.UserRole.ADMIN.value or \
            any(user == current_user.username for user in allowed_users)


async def check_building_owner_access(
    building_id: str,
    current_user: _schemas.User,
    db: _orm.Session = _fastapi.Depends(_db_ops.get_db)
):
    if current_user is None or not hasattr(current_user, 'username'):
        return False

    building = await _services.get_building(
        building_id=building_id,
        db=db,
        username=current_user.username
    )

    if building is None:
        return False

    return building.owner == current_user.username or \
            current_user.role is _schemas.UserRole.ADMIN.value
