# Dockerfile для Flask приложения
FROM python:3.9

# Установка зависимостей
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения
COPY . .

# Указание команды для запуска приложения
CMD ["python", "server_api.py"]