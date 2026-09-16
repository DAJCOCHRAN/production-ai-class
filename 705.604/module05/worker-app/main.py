"""Worker: one pod in the fan-out set. Reports which pod and node answered."""
import os
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify, request

app = Flask(__name__)

POD_NAME = os.getenv("POD_NAME") or socket.gethostname()
NODE_NAME = os.getenv("NODE_NAME", "unknown")


def identity():
    return {"pod": POD_NAME, "node": NODE_NAME}


@app.route("/status", methods=["GET"])
def status():
    """Readiness probe and a quick look at who is answering."""
    return jsonify(identity())


@app.route("/process", methods=["POST"])
def process():
    """Receive one message from the gateway and echo it with this pod's identity."""
    body = request.get_json(silent=True) or {}
    reply = identity()
    reply["message"] = body.get("message", "")
    reply["received_at"] = datetime.now(timezone.utc).isoformat()
    return jsonify(reply)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8000")))
