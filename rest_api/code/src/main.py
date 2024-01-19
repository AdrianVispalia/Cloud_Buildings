from os import environ
from re import search
import fastapi as _fastapi
#from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.cors import CORSMiddleware
import sqlalchemy.orm as _orm
import services as _services
import routers as _routers
import database as _database


app = _fastapi.FastAPI()

# Adds a handler if the environment is on AWS Lambda
if any('AWS_LAMBDA' in w for w in environ):
    from mangum import Mangum
    handler = Mangum(app)

# TODO
#origins = [
#    'http://localhost:80',
#    'http://localhost',
#    'http://127.0.0.1:80'
#]

app.add_middleware(
    CORSMiddleware,
#    allow_origins=origins,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# -----------------   ROOT   --------------------
@app.get("/api")
async def root():
    return {"message": "Cloud Building API test3"}

#async def root(db: _orm.Session = _fastapi.Depends(_database.operations.get_db)):
#    await _services.token_check(db)

# -----------------  ROUTERS --------------------
app.include_router(_routers.users.router, prefix='/api/users')
app.include_router(_routers.buildings.router, prefix='/api/buildings')
app.include_router(_routers.rooms.router, prefix='/api/buildings')
app.include_router(_routers.measurements.router, prefix='/api/buildings')

# -----------------   AUTH  ---------------------
@app.post("/api/token")
async def generate_token(
    form_data: _fastapi.security.OAuth2PasswordRequestForm = _fastapi.Depends(),
    db: _orm.Session = _fastapi.Depends(_database.operations.get_db),
):
    user = await _services.authenticate_user(form_data.username, form_data.password, db)
    #user = _database.models.User(username=form_data.username, hashed_password=form_data.password, mail="adrian3@mail.com", salt="", role=0)

    #print(f"Form password: {form_data.password}") # DO NOT UNCOMMENT THIS ON PROD
    if not user:
        raise _fastapi.HTTPException(status_code=401, detail="Invalid Credentials")

    return await _services.create_token(user)


# ------------------   DEV   --------------------
@app.get("/api/create")
async def database_creation():
    _database.operations.create_database()
    return {"message": "Created database scheme"}
