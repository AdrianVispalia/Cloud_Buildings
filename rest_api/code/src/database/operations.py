from os import environ
import sqlalchemy as _sql
import sqlalchemy.ext.declarative as _declarative
import sqlalchemy.orm as _orm


class CustomQuery(_orm.Query):
    def filter_if(self: _orm.Query, condition: bool, *criterion):
        if condition:
            return self.filter(*criterion)
        else:
            return self


ip, port = str(environ.get('DB_ENDPOINT')).split(':', maxsplit=1)

username = environ.get("DB_USER")
password = environ.get("DB_PASSWORD")
database = environ.get("DB_NAME")

DATABASE_URL = f"postgres://{username}:{password}@{ip}:{port}/{database}"
engine = _sql.create_engine(DATABASE_URL)


SessionLocal = _orm.sessionmaker(autocommit=False, autoflush=False,
        bind=engine, query_cls=CustomQuery)

Base = _declarative.declarative_base()


# function NOT FOR PROD
def create_database():
    return Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
