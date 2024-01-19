import sqlalchemy.orm as _orm
import database.models as _models
import schemas as _schemas


async def get_building_users_access(building_id: int, db: _orm.Session):
    user_access_list = db.query(_models.UserBuildingAccess).filter(
        _models.UserBuildingAccess.building_id == building_id
    )
    return list(map(lambda user_access: user_access.username, user_access_list))


async def delete_building_user_access(building_id: int, username: str, db: _orm.Session):
    user_access = db.query(_models.Building).filter(
        _models.UserBuildingAccess.building_id == building_id,
        _models.UserBuildingAccess.username == username
    ).first()

    db.delete(user_access)
    db.commit()


async def create_building_user_access(access: _schemas.User_Building_Access, db: _orm.Session):
    access = _models.UserBuildingAccess(**access.dict())
    db.add(access)
    db.commit()
    db.refresh(access)
    return _schemas.User_Building_Access.from_orm(access)
