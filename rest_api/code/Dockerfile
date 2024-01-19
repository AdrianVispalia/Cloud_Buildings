FROM tiangolo/uvicorn-gunicorn:python3.9

WORKDIR /app/
COPY ./code/libraries/docker-requirements.txt /app/requirements.txt

#RUN pip3 install -r ./requirements.txt
RUN pip install --no-cache-dir --upgrade -r ./requirements.txt

COPY ./code/src/ /app/

WORKDIR /
# For NGINX
#CMD ["uvicorn", "app.main:app", "--proxy-headers", "--host", "0.0.0.0", "--port", "80"]
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
