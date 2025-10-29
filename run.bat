@echo off
echo Starting Flutter Web Development Server...
echo.
echo Make sure the Spring Boot backend is running on http://localhost:8080
echo.
echo Press Ctrl+C to stop the server
echo.
flutter run -d chrome --web-port 3000
pause
