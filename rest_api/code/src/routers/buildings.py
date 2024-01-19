from typing import List
import fastapi as _fastapi
import sqlalchemy.orm as _orm
import schemas as _schemas
import services as _services
import database as _database

router = _fastapi.APIRouter()


@router.get("/", response_model=List[_schemas.Building])
async def get_buildings(
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if current_user.role is _schemas.UserRole.ADMIN.value:
        return await _services.admin_get_buildings(db=db)

    return await _services.get_buildings(db=db, username=current_user.username)


@router.post("/", response_model=_schemas.Building)
async def create_building(
    building: _schemas.Building,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if current_user.role is not _schemas.UserRole.ADMIN.value:
        raise _fastapi.HTTPException(status_code=403, detail="Admin role needed")

    return await _services.create_building(building=building, db=db)


@router.get("/{building_id}", status_code=200)
async def get_building(
    building_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_user_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Read access needed")

    return await _services.get_building(
        building_id=building_id,
        db=db,
        username=current_user.username
    )


@router.delete("/{building_id}", status_code=204)
async def delete_building(
    building_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if current_user.role is not _schemas.UserRole.ADMIN.value:
        raise _fastapi.HTTPException(status_code=403, detail="Admin role needed")

    await _services.delete_building(building_id=building_id, db=db)
    return {"message", "Successfully Deleted"}


@router.put("/{building_id}", status_code=200)
async def update_building(
    building_id: int,
    building: _schemas.Building,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_owner_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Write access needed")

    await _services.update_building(building_id=building_id, building=building, db=db)
    return {"message", "Successfully Updated"}


@router.get("/{building_id}/rooms", response_model=List[_schemas.Room])
async def get_building_rooms(
    building_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_user_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Read access needed")

    return await _services.get_building_rooms(
        building_id=building_id,
        db=db,
        username=current_user.username
    )


@router.get("/{building_id}/allowed_users", status_code=200)
async def get_building_allowed_users(
    building_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_user_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Read access needed")

    return await _services.get_building_users_access(building_id=building_id, db=db)


@router.post("/{building_id}/allowed_users", response_model=_schemas.User_Building_Access)
async def create_building_access(
    access: _schemas.User_Building_Access,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if current_user.role is _schemas.UserRole.ADMIN.value:
        return await _services.create_building_user_access(access, db)


@router.delete("/{building_id}/allowed_users", status_code=204)
async def delete_building_access(
    building_id: int,
    username: str,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_owner_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Write access needed")

    await _services.delete_building_user_access(building_id=building_id, username=username, db=db)
    return {"message", "Successfully Deleted"}
