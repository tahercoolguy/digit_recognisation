FROM python:3.7-slim-stretch
COPY HQ_BC-13.cer /data/HQ_BC-13.cer
COPY HQ_BC-13.pem /data/HQ_BC-13.pem
COPY HQ_BC-13.pem /usr/lib/ssl/cert.pem
RUN (ls /data/HQ_BC-13.cer && echo yes) || echo no
RUN cd data
RUN ls
RUN pip config set global.cert /data/HQ_BC-13.cer
RUN pip install certifi
RUN pip install numpy==1.17.2
RUN python -c "import ssl; print(ssl.get_default_verify_paths())"
RUN apt-get update && apt-get install -y git python3-dev gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --upgrade -r requirements.txt

COPY app app/

RUN python app/server.py

EXPOSE 5000

CMD ["python", "app/server.py", "serve"]
