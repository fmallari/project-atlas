import os
import uuid

from flask import Flask, jsonify, render_template, request
from werkzeug.utils import secure_filename

from services.s3_service import upload_file 

app = Flask(__name__)

ALLOWED_EXTENSIONS = {
    "png",
    "jpg",
    "jpeg",
    "gif",
    "pdf",
    "txt"
}

def allowed_file(filename):
    return (
        "." in filename
        and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS
    )

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "service": "project-atlas",
        "version": "1.0.0"
    }), 200

@app.route("/upload", methods=["GET", "POST"])
def upload():
    if request.method == "POST":
        uploaded_file = request.files.get("file")

        if uploaded_file is None or uploaded_file.filename == "":
            return "Please choose a file.", 400

        filename = secure_filename(uploaded_file.filename)
        
        if not allowed_file(filename):
    	    return "File type not allowed.", 400
        if not filename:
            return "Invalid filename.", 400
         
        extension = os.path.splitext(filename)[1]
        unique_filename =f"{uuid.uuid4()}{extension}"
        object_key = f"uploads/{unique_filename}"

        success = upload_file(uploaded_file, object_key)

        if success:
            return f"Upload successful: {object_key}", 201

        return "Upload failed.", 500

    return render_template("upload.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

@app.route("/evidence")
def evidence():
    return render_template("evidence.html")
