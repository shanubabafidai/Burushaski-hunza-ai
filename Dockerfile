FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY burushaski/ ./burushaski/
RUN useradd --system --uid 10001 --create-home appuser && mkdir -p /data && chown appuser:appuser /data
USER appuser
ENV DB_PATH=/data/burushaski.sqlite3 HOST=0.0.0.0 PORT=8000 DEPLOYMENT_ENV=production ENABLE_UNAUTHENTICATED_SUBMISSIONS=false
EXPOSE 8000
CMD ["python", "-m", "burushaski.server"]
