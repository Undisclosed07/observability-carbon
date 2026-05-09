FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Non-root user.
RUN useradd -m -u 1000 app && chown -R app:app /app
USER app

EXPOSE 8080
ENV REGION=unknown
ENV WORK_ITERATIONS=100000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
