from flask import Flask, jsonify

app = Flask(__name__)

holidays = [
    {"date": "2025-01-01", "localName": "New Year's Day"},
    {"date": "2025-08-15", "localName": "Independence Day"},
    {"date": "2025-10-02", "localName": "Gandhi Jayanti"}
]

@app.route('/bank_holiday_2025', methods=['GET'])
def get_holidays():
    return jsonify(holidays)

if __name__ == '__main__':
    app.run(debug=True)
