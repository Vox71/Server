FROM python:3.9

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

ENV FLASK_DEBUG=0
ENV FLASK_APP=server_api.py
ENV FLASK_ENV=production

COPY . .

CMD ["python",  "server_api.py"]