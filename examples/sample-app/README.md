# Sample-app

Tiny FastAPI workload used to give Kepler something to measure. Two endpoints:

- `GET /health` — cheap, returns 200.
- `GET /work` — burns CPU for ~50ms (configurable via `WORK_ITERATIONS`).

## Build & push (your registry)

```bash
docker build -t ghcr.io/undisclosed07/observability-carbon-sample:latest .
docker push ghcr.io/undisclosed07/observability-carbon-sample:latest
```

## Run locally

```bash
pip install -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 8080
curl http://localhost:8080/work
```

## Deploy

```bash
kubectl apply -f k8s-manifest.yaml
```

## Generate load (so Kepler has something to chew on)

```bash
kubectl -n demo run loadgen \
  --image=curlimages/curl --restart=Never -- \
  sh -c 'while true; do curl -s http://sample-app/work; sleep 0.1; done'
```
