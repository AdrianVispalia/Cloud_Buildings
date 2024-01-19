from typing import List
import fastapi as _fastapi
import sqlalchemy.orm as _orm
import schemas as _schemas
import services as _services
import database as _database


router = _fastapi.APIRouter()


@router.get("/{building_id}/rooms", response_model=List[_schemas.Room])
async def get_rooms(
    building_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_user_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Read access needed")

    return await _services.get_rooms(building_id=building_id, db=db)


@router.post("/{building_id}/rooms", response_model=_schemas.Room)
async def create_room(
    building_id: int,
    room: _schemas.Room,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_owner_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Write access needed")

    return await _services.create_room(room=room, building_id=building_id, db=db)


@router.get("/{building_id}/rooms/{room_id}", status_code=200)
async def get_room(
    building_id: int,
    room_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_user_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Read access needed")

    return await _services.get_room(room_id=room_id, building_id=building_id, db=db)


@router.delete("/{building_id}/rooms/{room_id}", status_code=204)
async def delete_room(
    building_id: int,
    room_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_owner_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Write access needed")

    await _services.delete_room(room_id=room_id, building_id=building_id, db=db)
    return {"message", "Successfully Deleted"}


@router.put("/{building_id}/rooms/{room_id}", status_code=200)
async def update_room(
    building_id: int,
    room_id: int,
    room: _schemas.Room,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_owner_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Write access needed")

    await _services.update_room(
        room_id=room_id,
        room=room,
        building_id=building_id,
        db=db
    )
    return {"message", "Successfully Updated"}


# FIX THESE 2 FUNCTIONS
@router.get("/{building_id}/rooms/{room_id}/last_room_measurements",
         response_model=List[_schemas.Measurement])
async def get_room_last_measurements(
    building_id: int,
    room_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_owner_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Write access needed")

    return await _services.get_room_last_measurements(room_id=room_id,
                                                building_id=building_id, db=db)


@router.get("/{building_id}/rooms/{room_id}/statistics_of_room_measurements",
         response_model=_schemas.Room_Statistics)
async def get_statistics_of_room_measurements(
    building_id: int,
    room_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if current_user.role is not _schemas.UserRole.ADMIN.value:
        raise _fastapi.HTTPException(status_code=403, detail="Admin role needed")

    return await _services.get_room_measurements_stats(room_id=room_id,
                                            building_id=building_id, db=db)
