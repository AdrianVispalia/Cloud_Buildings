import sqlalchemy.orm as _orm
import database.models as _models
import schemas as _schemas


async def get_measurements(building_id: int, room_id: int, db: _orm.Session):
    measurements = db.query(_models.Measurement) \
                        .filter(
                            _models.Measurement.building_id == building_id,
                            _models.Measurement.room_id == room_id
                        )
    return list(map(_schemas.Measurement.from_orm, measurements))


async def create_measurement(building_id: int, room_id: int,
                        measurement: _schemas.Measurement, db: _orm.Session):
    measurement = _models.Measurement(**measurement.dict())
    db.add(measurement)
    db.commit()
    db.refresh(measurement)
    return _schemas.Measurement.from_orm(measurement)


async def get_measurement(measurement_id: int, building_id: int, room_id: int, db: _orm.Session):
    return db.query(_models.Measurement) \
                        .filter(
                            _models.Measurement.building_id == building_id,
                            _models.Measurement.room_id == room_id,
                            _models.Measurement.id == measurement_id
                        ).first()


async def delete_measurement(measurement_id: int, building_id: int, room_id: int, db: _orm.Session):
    measurement = db.query(_models.Measurement) \
                        .filter(
                            _models.Measurement.building_id == building_id,
                            _models.Measurement.room_id == room_id,
                            _models.Measurement.id == measurement_id
                        ).first()

    db.delete(measurement)
    db.commit()


async def update_measurement(measurement_id: int, measurement: _schemas.Measurement,
                            building_id: int, room_id: int, db: _orm.Session):
    measurement_db = db.query(_models.Measurement) \
                        .filter(
                            _models.Measurement.building_id == building_id,
                            _models.Measurement.room_id == room_id,
                            _models.Measurement.id == measurement_id
                        ).first()

    measurement_db.timestamp = measurement.timestamp
    measurement_db.noise_level = measurement.noise_level
    measurement_db.temperature = measurement.temperature
    measurement_db.humidity = measurement.humidity
    measurement_db.light = measurement.light
    measurement_db.air_pressure = measurement.air_pressure

    db.commit()
    db.refresh(measurement_db)

    return _schemas.Measurement.from_orm(measurement_db)
