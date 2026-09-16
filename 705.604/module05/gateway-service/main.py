"""Gateway: resolves every worker pod through a headless Service and fans a message out."""
import os
import socket
from concurrent.futures import ThreadPoolExecutor

import requests
from flask import Flask, jsonify, request

app = Flask(__name__)

WORKER_HOST = os.getenv("WORKER_HOST", "worker-app")
WORKER_PORT = int(os.getenv("WORKER_PORT", "8000"))
TIMEOUT_SECONDS = float(os.getenv("WORKER_TIMEOUT", "5"))


def resolve_workers():
    """A headless Service resolves to one A record per ready pod. Return those IPs, sorted."""
    try:
        infos = socket.getaddrinfo(WORKER_HOST, WORKER_PORT, socket.AF_INET, socket.SOCK_STREAM)
    except socket.gaierror:
        return []
    return sorted({info[4][0] for info in infos})


def call_worker(ip, message):
    url = f"http://{ip}:{WORKER_PORT}/process"
    try:
        res = requests.post(url, json={"message": message}, timeout=TIMEOUT_SECONDS)
        res.raise_for_status()
        return {"worker": ip, "status": "success", "response": res.json()}
    except Exception as exc:  # one slow or failed worker must not hide the others
        return {"worker": ip, "status": "error", "error": str(exc)}


@app.route("/workers", methods=["GET"])
def workers():
    ips = resolve_workers()
    return jsonify({"host": WORKER_HOST, "worker_count": len(ips), "workers": ips})


@app.route("/fanout", methods=["POST"])
def fanout():
    body = request.get_json(silent=True) or {}
    message = body.get("message", "")
    ips = resolve_workers()
    if not ips:
        return jsonify({"message": message, "worker_count": 0, "responses": [],
                        "error": f"no workers resolved for {WORKER_HOST}"}), 503
    with ThreadPoolExecutor(max_workers=max(1, len(ips))) as pool:
        responses = list(pool.map(lambda ip: call_worker(ip, message), ips))
    return jsonify({"message": message, "worker_count": len(ips), "responses": responses})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")))
