# AI Wardrobe MVP

This is a simple Phase-1 prototype for an AI Personal Wardrobe app.

Current flow:
1. Choose a clothing photo from Gallery OR take a photo.
2. Crop the clothing photo.
3. Upload it to a Python FastAPI backend.
4. Backend removes the background and creates a clean, aesthetically presented clothing image.
5. The app displays the processed clothing item.
6. Press "Generate Outfit" to get a simple outfit recommendation from the wardrobe item.

Important:
- The image-processing part uses `rembg` for background removal.
- The outfit recommendation in this first MVP is intentionally simple so the whole pipeline can be tested quickly.
- Later, replace `generate_outfit()` with an open-source fashion/outfit generation model.

## Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate        # macOS/Linux
# Windows: .venv\Scripts\activate

pip install -r requirements.txt
uvicorn main:app --reload
```

Backend runs at:
http://127.0.0.1:8000

## Flutter

Create a Flutter app, then replace/add the files from `flutter_app/lib/`.

Add the dependencies in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.1.2
  image_cropper: ^8.1.0
  http: ^1.2.2
```

Then:

```bash
flutter pub get
flutter run
```

For an Android emulator, change `apiBaseUrl` to:
http://10.0.2.2:8000

For iOS Simulator:
http://127.0.0.1:8000

For a physical phone, use your computer's local IP, for example:
http://192.168.1.10:8000
