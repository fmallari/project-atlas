from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return """
    <h1>🚀 Hello from AWS!</h1>
    <p>This application is running on my EC2 server.</p>
    <p>Built by Francis during my Cloud Engineering roadmap.</p>
    """
@app.route("/health")
def health():
    return {"status": "healthy"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

