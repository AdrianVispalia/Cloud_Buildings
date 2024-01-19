import sqlalchemy.orm as _orm
from sqlalchemy import or_
from database import models as _models, operations as _db_ops
import schemas as _schemas
#from sqlalchemy.expression import true


async def admin_get_buildings(db: _orm.Session):
    buildings = db.query(_models.Building)
    return list(map(_schemas.Building.from_orm, buildings))


async def get_buildings(db: _orm.Session, username: str):
    buildings = db.query(_models.Building) \
            .outerjoin(
                _models.UserBuildingAccess,
                _models.Building.id == _models.UserBuildingAccess.building_id
            ).filter(
                (_models.Building.owner == username) |
                (_models.UserBuildingAccess.username == username) |
                (_models.Building.public.is_(True))
            )
    return list(map(_schemas.Building.from_orm, buildings))


async def create_building(building: _schemas.Building, db: _orm.Session):
    building = _models.Building(**building.dict())
    db.add(building)
    db.commit()
    db.refresh(building)
    return _schemas.Building.from_orm(building)


async def admin_get_building(building_id: int, db: _orm.Session):
    return db.query(_models.Building).filter(_models.Building.id == building_id).first()


async def get_building(building_id: int, db: _orm.Session, username: str):
    building_db = db.query(_models.Building) \
            .outerjoin(
                _models.UserBuildingAccess,
                _models.Building.id == _models.UserBuildingAccess.building_id
            ).filter(
                _models.Building.id == building_id,
                or_(
                    _models.Building.owner == username,
                    _models.UserBuildingAccess.username == username,
                    _models.Building.public.is_(True)
                )
            ).first()
    print("Get buildings sql:")
    print(str(building_db))
    print(building_db)
    print("Test2")
    print(str(db.query(_models.Building) \
            .outerjoin(
                _models.UserBuildingAccess,
                _models.Building.id == _models.UserBuildingAccess.building_id
            ).filter(
                _models.Building.id == building_id,
                or_(
                    _models.Building.owner == username,
                    _models.UserBuildingAccess.username == username,
                    _models.Building.public.is_(True)
                )
            ).statement.compile(_db_ops.engine)))
    return _schemas.Building.from_orm(building_db)


async def delete_building(building_id: int, db: _orm.Session):
    building = db.query(_models.Building).filter(_models.Building.id == building_id).first()

    db.delete(building)
    db.commit()


async def update_building(building_id: int, building: _schemas.Building, db: _orm.Session):
    building_db = db.query(_models.Building).filter(_models.Building.id == building_id).first()

    building_db.gps_latitude = building.gps_latitude
    building_db.gps_latitude = building.gps_latitude
    building_db.name = building.name

    db.commit()
    db.refresh(building_db)

    return _schemas.Building.from_orm(building_db)


async def admin_get_building_rooms(building_id: int, db: _orm.Session):
    rooms = db.query(_models.Room).filter(_models.Room.building_id == building_id)
    return list(map(_schemas.Room.from_orm, rooms))


async def get_building_rooms(building_id: int, db: _orm.Session, username: str):
    rooms = db.query(_models.Room) \
            .join(
                        _models.Building,
                        _models.Building.id == _models.Room.building_id
            ).outerjoin(
                        _models.UserBuildingAccess,
                        _models.Building.id == _models.UserBuildingAccess.building_id
            ).filter(
                _models.Building.id == building_id,
                or_(
                    _models.Building.owner == username,
                    _models.UserBuildingAccess.username == username,
                    _models.Building.public.is_(True)
                )
            )
    return list(map(_schemas.Room.from_orm, rooms))
