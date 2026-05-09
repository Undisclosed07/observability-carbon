"""
Sample workload for observability-carbon.

A tiny FastAPI service with two endpoints:
- /health   : cheap, returns 200.
- /work     : burns CPU for ~50ms — useful to generate Kepler signal.

Run locally:
    uvicorn app:app --host 0.0.0.0 --port 8080
"""
import hashlib
import os
import time

from fastapi import FastAPI

app = FastAPI(title="observability-carbon sample-app")

REGION = os.getenv("REGION", "unknown")
WORK_ITERATIONS = int(os.getenv("WORK_ITERATIONS", "100000"))


@app.get("/health")
def health():
    return {"status": "ok", "region": REGION}


@app.get("/work")
def work():
    """Burn CPU. Useful to give Kepler something to measure."""
    start = time.perf_counter()
    h = b"seed"
    for _ in range(WORK_ITERATIONS):
        h = hashlib.sha256(h).digest()
    elapsed_ms = (time.perf_counter() - start) * 1000
    return {
        "region": REGION,
        "iterations": WORK_ITERATIONS,
        "elapsed_ms": round(elapsed_ms, 2),
        "digest": h.hex()[:16],
    }


@app.get("/")
def root():
    return {
        "name": "observability-carbon sample-app",
        "endpoints": ["/health", "/work"],
        "region": REGION,
    }
