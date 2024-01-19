import json
import datetime as _dt
from os import environ
import redis
import sqlalchemy.orm as _orm
from sqlalchemy import desc as _desc, func as _func
import pydantic as _pydantic
import database.models as _models
import schemas as _schemas


async def get_rooms(building_id: int, db: _orm.Session):
    rooms = db.query(_models.Room).filter(_models.Room.building_id == building_id)
    return list(map(_schemas.Room.from_orm, rooms))


async def create_room(room: _schemas.Room, building_id: int, db: _orm.Session):
    room = _models.Room(**room.dict())
    room.building_id = building_id
    db.add(room)
    db.commit()
    db.refresh(room)
    return _schemas.Room.from_orm(room)


async def get_room(room_id: int, building_id: int, db: _orm.Session):
    return db.query(_models.Room) \
                .filter(_models.Room.building_id == building_id) \
                .filter(_models.Room.id == room_id).first()


async def delete_room(room_id: int, building_id: int, db: _orm.Session):
    room = db.query(_models.Room) \
                .filter(_models.Room.building_id == building_id) \
                .filter(_models.Room.id == room_id).first()

    db.delete(room)
    db.commit()


async def update_room(room_id: int, room: _schemas.Room, building_id: int, db: _orm.Session):
    room_db = db.query(_models.Room) \
                .filter(
                    _models.Room.building_id == building_id,
                    _models.Room.id == room_id
                ).first()

    room_db.floor = room.floor
    room_db.name = room.name

    db.commit()
    db.refresh(room_db)

    return _schemas.Room.from_orm(room_db)


async def get_room_last_measurements(room_id: int, building_id: int, db: _orm.Session):
    measurements = db.query(_models.Measurement) \
                    .filter(
                        _models.Measurement.building_id == building_id,
                        _models.Measurement.room_id == room_id
                    ).order_by(_desc(_models.Measurement.timestamp)) \
                    .limit(12)
    return list(map(_schemas.Measurement.from_orm, measurements))


async def get_room_measurements_stats(room_id: int, building_id: int, db: _orm.Session):
    cache = redis.Redis(
                host=environ['REDIS_IP'],
                port=int(environ['REDIS_PORT']),
                db=0
            )
    cache_key = f"{str(building_id)}-{str(room_id)}"
    cache_data = cache.get(cache_key)
    print("[!] Cache data is None? " + str(cache_data is None))

    if cache_data is not None:
        json_payload = None
        try:
            json_payload = json.loads(cache_data)
        except json.JSONDecodeError:
            print("Error decoding the payload. It is not JSON!")
            return ""

        if json_payload is not None:
            expiration = _dt.datetime.strptime(json_payload["expiration"], "%Y-%m-%dT%H:%M:%S.%f")
            print("[!] Use cache? " + str(expiration >= _dt.datetime.utcnow()))
            if expiration >= _dt.datetime.utcnow():
                print("[!] Using cached data")
                return _pydantic.parse_obj_as(_schemas.Room_Statistics, json_payload)

    statistics = db.query(
                    _func.VAR_POP(_models.Measurement.temperature).label('temperature_variance'),
                    _func.VAR_POP(_models.Measurement.noise_level).label('noise_level_variance'),
                    _func.AVG(_models.Measurement.temperature).label('temperature_average'),
                    _func.AVG(_models.Measurement.noise_level).label('noise_level_average'),
                    _func.AVG(_models.Measurement.humidity).label('humidity_average'),
                    _func.AVG(_models.Measurement.light).label('light_average')
                ).filter(
                        _models.Measurement.building_id == building_id,
                        _models.Measurement.room_id == room_id,
                        _models.Measurement.timestamp >= _dt.datetime.utcnow() - _dt.timedelta(days=3),
                        _models.Measurement.temperature.isnot(None),
                        _models.Measurement.noise_level.isnot(None),
                        _models.Measurement.humidity.isnot(None),
                        _models.Measurement.light.isnot(None)
                )

    raw_data = statistics.one()
    print(f"[!] Statistics: {str(raw_data)}")
    stats_names = ['temperature_variance', 'noise_level_variance','temperature_average',
                   'noise_level_average','humidity_average','light_average']
    data = {}
    for idx, stat_name in enumerate(stats_names):
        data[stat_name] = float(raw_data[idx]) if raw_data[idx] is not None else None

    element = _schemas.Room_Statistics(**data)

    element.expiration = _dt.datetime.utcnow() + _dt.timedelta(days=1)
    cache.set(cache_key, element.json())

    return element
