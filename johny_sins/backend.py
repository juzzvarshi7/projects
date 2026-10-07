from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient

app = Flask(__name__)
CORS(app)

# 🔗 MongoDB Atlas Connection
client = MongoClient("mongodb+srv://test:pw1234@hospital.pfwxhfa.mongodb.net/hospital?retryWrites=true&w=majority")
db = client["hospital"]
doctors_col = db["doctors"]
appointments_col = db["appointments"]

# =========================
# GET ALL DOCTORS
# =========================
@app.route('/doctors', methods=['GET'])
def get_doctors():
    doctors = list(doctors_col.find({}, {"_id": 0}))
    return jsonify(doctors)

# =========================
# ADD APPOINTMENT
# =========================
@app.route('/appointments', methods=['POST'])
def add_appointment():
    data = request.json

    # ✅ Basic validation
    required_fields = ["name","phone","department","doctor","date","slot"]
    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({"error": f"{field} is required"}), 400

    # ✅ Prevent double booking
    existing = appointments_col.find_one({
        "doctor": data["doctor"],
        "date": data["date"],
        "slot": data["slot"]
    })

    if existing:
        return jsonify({"error": "Slot already booked"}), 400

    # ✅ Generate ID in backend (better)
    import time
    data["id"] = "BM-" + str(int(time.time()))

    appointments_col.insert_one(data)

    return jsonify({
        "message": "Appointment booked successfully",
        "id": data["id"]
    })

# =========================
# GET APPOINTMENTS
# =========================
@app.route('/appointments', methods=['GET'])
def get_appointments():
    data = list(appointments_col.find({}, {"_id": 0}))
    return jsonify(data)

# =========================
# DELETE APPOINTMENT
# =========================
@app.route('/appointments/<id>', methods=['DELETE'])
def delete_appointment(id):
    appointments_col.delete_one({"id": id})
    return jsonify({"message": "Deleted successfully"})

if __name__ == '__main__':
    app.run(debug=True)