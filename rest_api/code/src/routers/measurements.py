from typing import List
import fastapi as _fastapi
import sqlalchemy.orm as _orm
import schemas as _schemas
import services as _services
import database as _database

router = _fastapi.APIRouter()


@router.get("/{building_id}/rooms/{room_id}/measurements",
         response_model=List[_schemas.Measurement])
async def get_measurements(
    building_id: int,
    room_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    print(f"Get measurements with db: {str(db)}")
    if not await _services.auth.check_building_user_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Read access needed")

    return await _services.get_measurements(
        building_id=building_id,
        room_id=room_id,
        db=db
    )


@router.post("/{building_id}/rooms/{room_id}/measurements",
          response_model=_schemas.Measurement)
async def create_measurement(
    building_id: int,
    room_id: int,
    measurement: _schemas.Measurement,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_user_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Read access needed")

    return await _services.create_measurement(
        measurement=measurement,
        building_id=building_id,
        room_id=room_id,
        db=db
    )


@router.get("/{building_id}/rooms/{room_id}/measurements/{measurement_id}",
         status_code=200)
async def get_measurement(
    building_id: int,
    room_id: int,
    measurement_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_user_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Read access needed")

    return await _services.get_measurement(
        measurement_id=measurement_id,
        building_id=building_id,
        room_id=room_id,
        db=db
    )


@router.delete("/{building_id}/rooms/{room_id}/measurements/{measurement_id}",
            status_code=204)
async def delete_measurement(
    building_id: int,
    room_id: int,
    measurement_id: int,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_owner_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Write access needed")

    await _services.delete_measurement(
        measurement_id=measurement_id,
        building_id=building_id,
        room_id=room_id,
        db=db
    )
    return {"message", "Successfully Deleted"}


@router.put("/{building_id}/rooms/{room_id}/measurements/{measurement_id}",
         status_code=200)
async def update_measurement(
    building_id: int,
    room_id: int,
    measurement_id: int,
    measurement: _schemas.Measurement,
    db: _orm.Session = _fastapi.Depends(_database.get_db),
    current_user: _schemas.User = _fastapi.Depends(_services.get_current_user),
):
    if not await _services.auth.check_building_owner_access(building_id, current_user, db):
        raise _fastapi.HTTPException(status_code=403, detail="Write access needed")

    await _services.update_measurement(
        measurement_id=measurement_id,
        measurement=measurement,
        building_id=building_id,
        room_id=room_id,
        db=db
    )
    return {"message", "Successfully Updated"}
