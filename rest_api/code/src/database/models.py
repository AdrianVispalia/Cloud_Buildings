import datetime as _dt
import sqlalchemy as _sql
import sqlalchemy.orm as _orm
import database.operations as _database


class User(_database.Base):
    __tablename__ = "users"
    username = _sql.Column(_sql.String, primary_key=True, index=True)
    mail = _sql.Column(_sql.String, unique=True, nullable=False, index=True)
    hashed_password = _sql.Column(_sql.String(64), nullable=False)
    salt = _sql.Column(_sql.String(64), nullable=False)
    role = _sql.Column(_sql.Integer, nullable=False)


class Building(_database.Base):
    __tablename__ = "buildings"
    id = _sql.Column(_sql.Integer, primary_key=True, index=True, autoincrement=True)
    gps_latitude = _sql.Column(_sql.Float, index=True)
    gps_longitude = _sql.Column(_sql.Float, index=True)
    name = _sql.Column(_sql.String, index=True)
    public = _sql.Column(_sql.Boolean, unique=False, default=False)
    owner = _sql.Column(_sql.String, _sql.ForeignKey("users.username"))

    rooms = _orm.relationship("Room", back_populates="building", uselist=True)


class UserBuildingAccess(_database.Base):
    __tablename__ = "users_buildings_access"
    username = _sql.Column(_sql.String, _sql.ForeignKey("users.username"), primary_key=True)
    building_id = _sql.Column(_sql.Integer, _sql.ForeignKey("buildings.id"), primary_key=True)


class Room(_database.Base):
    __tablename__ = "rooms"
    id = _sql.Column(_sql.Integer, primary_key=True, index=True, autoincrement=True)
    floor = _sql.Column(_sql.Integer, index=True)
    name = _sql.Column(_sql.String, index=True)

    building_id = _sql.Column(_sql.Integer, _sql.ForeignKey("buildings.id"), primary_key=True)
    building = _orm.relationship("Building", back_populates="rooms")

    measurements = _orm.relationship("Measurement", back_populates="room", uselist=True)


class Measurement(_database.Base):
    __tablename__ = "measurements"
    id = _sql.Column(_sql.Integer, primary_key=True, index=True, autoincrement=True)
    timestamp = _sql.Column(_sql.DateTime, default=_dt.datetime.utcnow, index=True)
    noise_level = _sql.Column(_sql.Float, nullable=True)
    temperature = _sql.Column(_sql.Float, nullable=True)
    humidity = _sql.Column(_sql.Float, nullable=True)
    light = _sql.Column(_sql.Integer, nullable=True)
    air_pressure = _sql.Column(_sql.Integer, nullable=True)

    room_id = _sql.Column(_sql.Integer, primary_key=True)
    building_id = _sql.Column(_sql.Integer, primary_key=True)
    __table_args__ = (_sql.ForeignKeyConstraint(
                        [room_id, building_id],
                        [Room.id, Room.building_id]
                    ), {})

    room = _orm.relationship("Room", back_populates="measurements")
