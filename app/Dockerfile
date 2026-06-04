# Stage 1: Build dependencies
FROM python:3.12-alpine AS builder

WORKDIR /app

RUN apk add --no-cache gcc musl-dev libffi-dev

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Final minimal image
FROM python:3.12-alpine

WORKDIR /app

# Create a non-privileged user to run the application
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy python packages installed in builder stage
COPY --from=builder /root/.local /home/appuser/.local
COPY app.py .

# Adjust permissions
RUN chown -R appuser:appgroup /app

# Configure PATH to include user local bin
ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

USER appuser

EXPOSE 5000

# Run with Gunicorn production server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
