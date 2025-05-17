from ultralytics import YOLO
import os


def run_yolo(image_path):
    model = YOLO(os.path.join(os.path.dirname(__file__), '../models/best.pt'))
    results = model.predict(image_path)

    # Process results (adjust based on your YOLO output)
    material_lost = False
    severity = 'N/A'
    coordinates = {}

    for result in results:
        for box in result.boxes:
            material_lost = True
            severity = 'Moderate'  # Example logic
            coordinates = {
                'x': float(box.xyxy[0][0]),
                'y': float(box.xyxy[0][1]),
                'w': float(box.xyxy[0][2] - box.xyxy[0][0]),
                'h': float(box.xyxy[0][3] - box.xyxy[0][1]),
            }

    return {
        'material_lost': material_lost,
        'severity': severity,
        'coordinates': coordinates,
    }