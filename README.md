# Factorial Project - Frontend

User Rating Project

## Features
- Form to insert new rating in the database
- Timeline displaying the average rating per period
- Period editable with a dropdown in the toolbar
- Timeline indicators clickable to view the details of the rating records for the clicked average value
- Timeline indicator highlighted for the current time inthe selected period

## Getting Started

This project is a starting point for the User Rating application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running the app
To Run the frontend app you have 2 choices (Using Docker is recommended to avoid installation steps):

  ### Running in local

  1. Requirements

    - [Flutter SDK](https://flutter.dev/docs/get-started/install). See the Flutter SDK installation instructions.
    - [Chrome](https://www.google.com/chrome/?brand=CHBD&gclid=CjwKCAiAws7uBRAkEiwAMlbZjlVMZCxJDGAHjoSpoI_3z_HczSbgbMka5c9Z521R89cDoBM3zAluJRoCdCEQAvD_BwE&gclsrc=aw.ds); debugging a web app requires the Chrome browser.
    
  2. After completing the installation of the Flutter SDK, enable web development: 
  ```
  flutter channel master
  flutter upgrade
  flutter config --enable-web
  ```
  3. Run `flutter doctor`:
  ```
  flutter doctor

  [✓] Flutter: is fully installed. (Channel dev, v1.9.5, on Mac OS X 10.14.6 18G87, locale en-US)
  [✗] Android toolchain - develop for Android devices: is not installed.
  [✗] Xcode - develop for iOS and macOS: is not installed.
  [✓] Chrome - develop for the web: is fully installed.
  [!] Android Studio: is not available. (not installed)
  [✓] Connected device: is fully installed. (1 available)
  ```
  4. Run the app on Chrome
  ```
  flutter run -d chrome
  ```

  ### Running on Docker
  As a faster way of starting and testing the application, a docker container has been setup with a Python Server.
  This way, no installation is needed.

  1. Building the docker container using `Dockerfile`
  ```
  docker build . -t factorial_project_front
  ```
  2. Running the container
  ```
  docker run -i -p 8080:4040 -td factorial_project_front
  ```
  3. The application is now available at `http://localhost:8080`

### To go further
In order to enhance the application, we could look into the following items: 
- String Localization
- Components Reusability
- Smoother Horizontal scrollbar & refresh
- Use proper entity management to handle backend data (instead of JSON)
- Writing tests for the widget components
