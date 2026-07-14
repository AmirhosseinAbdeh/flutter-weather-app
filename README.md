# Weather App 🌦️

A Flutter app that shows the current weather and a 5-day forecast for any city,
powered by the [OpenWeatherMap API](https://openweathermap.org/api).

## Features (planned)

- Current weather for a default / last-searched city (Home screen)
- City search with live weather results (Search screen)
- 5-day forecast (Forecast screen)
- Save favorite cities

## Getting started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Get a free API key

Create a free account at <https://openweathermap.org/api> and copy your API key.

### 3. Run the app

The API key is passed at run time (never committed to source) via
`--dart-define`:

```bash
flutter run -d chrome --dart-define=OWM_API_KEY=your_api_key_here
```

You can target any connected device (`flutter devices` to list them), e.g.
`-d chrome` for web or an Android emulator/device.

## Project structure

```
lib/
├── main.dart          # App entry point
├── config/            # API configuration (base URL, endpoints, key)
├── models/            # Data models (Weather, Forecast)
├── screens/           # App screens (Home, Search, Forecast)
├── services/          # OpenWeatherMap API client
└── widgets/           # Reusable UI widgets
```

## API

Base URL: `https://api.openweathermap.org/data/2.5`

- `GET /weather` — current weather
- `GET /forecast` — 5-day / 3-hour forecast
