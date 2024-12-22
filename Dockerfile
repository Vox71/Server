# Dockerfile для Flask приложения
FROM python:3.9

# Установка зависимостей
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

ENV FLASK_DEBUG=0
ENV FLASK_APP=server_api.py
ENV FLASK_ENV=production

# Копируем код приложения
COPY . .

# Указание команды для запуска приложения
CMD ["python",  "server_api.py"]