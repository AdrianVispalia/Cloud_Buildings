from typing import List
import fastapi as _fastapi
import sqlalchemy.orm as _orm
import schemas as _schemas
import services as _services
import database as _database


router = _fastapi.APIRouter()


@router.get("/me", response_model=_schemas.User)
async def get_my_user(
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user)
):
    print("current user:")
    print(current_user)
    return current_user


@router.get("/", response_model=List[_schemas.User])
async def get_users(
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    return await _services.get_users(db=db)


@router.post("/", response_model=_schemas.User)
async def create_user(
    user: _schemas.FormUser,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
):
    return await _services.create_user(db=db, user=user, ctx=_services.auth.ctx)


@router.get("/{username}", status_code=200)
async def get_user(
    username: str,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    return await _services.get_user(username=username, db=db)


@router.delete("/{username}", status_code=204)
async def delete_user(
    username: str,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if current_user.role is _schemas.UserRole.ADMIN.value or \
            current_user.username == username:
        await _services.delete_user(username=username, db=db)
        return {"message", "Successfully Deleted"}


@router.put("/{username}", status_code=200)
async def update_user(
    username: str,
    user: _schemas.User,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if current_user.role is _schemas.UserRole.ADMIN.value or \
            user.username == current_user.username:
        await _services.update_user(username=username, user=user, db=db)
        return {"message", "Successfully Updated"}
