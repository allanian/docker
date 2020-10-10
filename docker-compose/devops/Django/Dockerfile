FROM python:3.6 as builder
WORKDIR /opt/app
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
RUN python3.6 -c 'import os; print(os.environ)'
RUN pip install --upgrade pip
# Build dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /opt/app/wheels -r requirements.txt

#FINAL
FROM python:3.6
WORKDIR /opt/app
RUN apt-get update && apt-get install -y netcat
# copy dependencies
COPY --from=builder /opt/app/wheels /wheels
COPY --from=builder /opt/app/requirements.txt .
RUN pip install --no-cache /wheels/*
# copy repo
COPY . .
COPY ./entrypoint.sh .
EXPOSE 8000
ENTRYPOINT ["/opt/app/entrypoint.sh"]