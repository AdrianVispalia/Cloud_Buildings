from typing import Optional
import datetime as _dt
from enum import Enum
import pydantic as _pydantic


class UserRole(Enum):
    CUSTOMER = 0
    ADMIN = 1


# TODO: check if this is correct
class FormUser(_pydantic.BaseModel):
    username: str
    password: str
    mail: _pydantic.EmailStr

    class Config:
        orm_mode = True


class User(_pydantic.BaseModel):
    username: str
    # hashed_password: str
    # salt: str
    mail: _pydantic.EmailStr
    role: int
    #icon: Optional[_pydantic.AnyHTTPUrl]

    class Config:
        orm_mode = True


class Building(_pydantic.BaseModel):
    id: int
    gps_latitude: float
    gps_longitude: float
    #icon: Optional[_pydantic.AnyHTTPUrl]
    name: str
    public: bool
    owner: str

    class Config:
        orm_mode = True


class Room(_pydantic.BaseModel):
    id: int
    building_id: int
    floor: int
    name: str

    class Config:
        orm_mode = True


class Measurement(_pydantic.BaseModel):
    id: Optional[int]
    room_id: int
    building_id: int
    timestamp: _dt.datetime
    noise_level: Optional[float]
    temperature: Optional[float]
    humidity: Optional[float]
    light: Optional[float]
    air_pressure: Optional[int]
    room_id: Optional[int]

    class Config:
        orm_mode = True


class Room_Statistics(_pydantic.BaseModel):
    temperature_variance: Optional[float]
    noise_level_variance: Optional[float]
    temperature_average: Optional[float]
    noise_level_average: Optional[float]
    humidity_average: Optional[float]
    light_average: Optional[float]
    expiration: Optional[_dt.datetime]

    class Config:
        orm_mode = True


class User_Building_Access(_pydantic.BaseModel):
    building_id: int
    username: str

    class Config:
        orm_mode = True
