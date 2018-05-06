FROM python:2.7-jessie

ARG app_dir="/usr/app"

RUN mkdir $app_dir
WORKDIR $app_dir
COPY . .
RUN pip install -r requirements.txt

EXPOSE 3000

CMD ["python", "application.py"]
