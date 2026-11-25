FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

FROM python:3.12-slim

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN groupadd --system app \
    && useradd --system --gid app --no-create-home app \
    && install -d -o app -g app /app

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY app/ ./app/
COPY models/ ./models/

USER app
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
