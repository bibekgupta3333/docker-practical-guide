import socket
from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello():
    hostname = socket.gethostname()
    return f"""
    <h1>Hello from Python multi-stage build! 🚀</h1>
    <p>Container hostname: {hostname}</p>
    """


@app.route("/health")
def health():
    return "OK"


if __name__ == "__main__":
    print("Server running on port 5000...")
    app.run(host="0.0.0.0", port=5000)
