import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;

class ClimaWatchView extends WatchUi.WatchFace {
    // 1. CONSTANTES MÁGICAS CENTRALIZADAS (Legibilidad y mantenibilidad)
    private const NIGHT_START_HOUR = 19;
    private const NIGHT_END_HOUR = 6;
    private const FORECAST_OFFSET_SECONDS = 1800; // 30 minutos al futuro

    // Arreglo constante estático para evitar instanciación por minuto
    private const DAYS_FR = ["dim", "lun", "mar", "mer", "jeu", "ven", "sam"] as Array<String>;

    // 2. SISTEMA DE CACHÉ (Vital para ahorrar RAM y Batería de la AMOLED)
    private var _cachedBitmap = null;
    private var _cachedDrawableId = null;
    private var _cachedWeatherText as String = "Recherche...";
    private var _cachedFontColor as Number = Graphics.COLOR_WHITE;

    function initialize() {
        WatchFace.initialize();
    }

    // 3. onUpdate LIMPIO Y EFICIENTE
    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();

        // Actualizar la lógica del clima y refrescar caché si es necesario
        updateWeatherState(clockTime.hour);

        // Limpiar pantalla
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();

        // Renderizar capas
        if (_cachedBitmap != null) {
            dc.drawBitmap(0, 0, _cachedBitmap);
        }

        dc.setColor(_cachedFontColor, Graphics.COLOR_TRANSPARENT);
        drawTime(dc, clockTime);
        drawDate(dc);
        drawWeather(dc);
    }

    // 4. LÓGICA DE DIBUJO DESACOPLADA
    private function drawTime(dc as Dc, clockTime as System.ClockTime) as Void {
        var timeString = Lang.format("$1$:$2$", [
            clockTime.hour,
            clockTime.min.format("%02d")
        ]);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 90, Graphics.FONT_NUMBER_HOT, timeString, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawDate(dc as Dc) as Void {
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var weekdayIndex = dateInfo.day_of_week - 1;

        if (weekdayIndex < 0 || weekdayIndex >= DAYS_FR.size()) {
            weekdayIndex = 0;
        }

        var dateString = Lang.format("$1$ $2$", [DAYS_FR[weekdayIndex], dateInfo.day]);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 + 25, Graphics.FONT_MEDIUM, dateString, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawWeather(dc as Dc) as Void {
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 + 85, Graphics.FONT_MEDIUM, _cachedWeatherText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // 5. MÁQUINA DE ESTADO PARA EL CLIMA
    private function updateWeatherState(currentHour as Number) as Void {
        var isNight = (currentHour >= NIGHT_START_HOUR || currentHour < NIGHT_END_HOUR);
        var forecast = getForecastForOffset();
        var condition = null;

        if (forecast != null && forecast.condition != null) {
            condition = forecast.condition;
        } else {
            var current = Weather.getCurrentConditions();
            if (current != null && current.condition != null) {
                condition = current.condition;
            }
        }

        if (condition != null) {
            applyWeatherCondition(condition, isNight);
        }
    }

    // Predicción exacta a 30 minutos sumando 1800 segundos
    private function getForecastForOffset() as Weather.HourlyForecast? {
        var hourlyForecast = Weather.getHourlyForecast();
        if (hourlyForecast == null || hourlyForecast.size() == 0) {
            return null;
        }

        var targetTime = Time.now().value() + FORECAST_OFFSET_SECONDS;
        var closestForecast = null;
        var closestDistance = null;

        for (var i = 0; i < hourlyForecast.size(); i++) {
            var forecast = hourlyForecast[i];
            if (forecast == null || forecast.condition == null || forecast.forecastTime == null) {
                continue;
            }

            var distance = (forecast.forecastTime.value() - targetTime).abs();

            if (closestDistance == null || distance < closestDistance) {
                closestForecast = forecast;
                closestDistance = distance;
            }
        }
        return closestForecast;
    }

    // 6. SENTENCIAS SWITCH PARA FONDOS DINÁMICOS Y CONTRASTE
    private function applyWeatherCondition(condition as Number, isNight as Boolean) as Void {
        var newDrawableId = null;
        var newText = "";
        var newColor = Graphics.COLOR_WHITE; // Por defecto blanco para fondos oscuros

        switch(condition) {
            case Weather.CONDITION_CLEAR:
            case Weather.CONDITION_MOSTLY_CLEAR:
            case Weather.CONDITION_PARTLY_CLEAR:
            case Weather.CONDITION_FAIR:
                newText = "Dégagé";
                newDrawableId = isNight ? Rez.Drawables.BgSolNoche : Rez.Drawables.BgSol;
                // Si es de día y está despejado (fondo claro), la letra cambia a negro
                newColor = isNight ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK; 
                break;

            case Weather.CONDITION_RAIN:
            case Weather.CONDITION_LIGHT_RAIN:
            case Weather.CONDITION_HEAVY_RAIN:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:
            case Weather.CONDITION_UNKNOWN_PRECIPITATION:
            case Weather.CONDITION_WINTRY_MIX:
            case Weather.CONDITION_RAIN_SNOW:
            case Weather.CONDITION_FREEZING_RAIN:
            case Weather.CONDITION_SLEET:
                newText = "Pluie";
                newDrawableId = isNight ? Rez.Drawables.BgLluviaNoche : Rez.Drawables.BgLluvia;
                break;

            case Weather.CONDITION_SHOWERS:
            case Weather.CONDITION_LIGHT_SHOWERS:
            case Weather.CONDITION_HEAVY_SHOWERS:
            case Weather.CONDITION_SCATTERED_SHOWERS:
            case Weather.CONDITION_CHANCE_OF_SHOWERS:
                newText = "Averses";
                newDrawableId = isNight ? Rez.Drawables.BgLluviaNoche : Rez.Drawables.BgLluvia;
                break;

            case Weather.CONDITION_DRIZZLE:
                newText = "Bruine";
                newDrawableId = isNight ? Rez.Drawables.BgLluviaNoche : Rez.Drawables.BgLluvia;
                break;

            case Weather.CONDITION_THUNDERSTORMS:
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:
                newText = "Orage";
                newDrawableId = Rez.Drawables.BgTormenta;
                break;

            case Weather.CONDITION_SNOW:
            case Weather.CONDITION_LIGHT_SNOW:
            case Weather.CONDITION_HEAVY_SNOW:
            case Weather.CONDITION_CHANCE_OF_SNOW:
            case Weather.CONDITION_FLURRIES:
            case Weather.CONDITION_HAIL:
                newText = "Neige";
                newDrawableId = isNight ? Rez.Drawables.BgNieveNoche : Rez.Drawables.BgNieveDia;
                break;

            case Weather.CONDITION_PARTLY_CLOUDY:
                newText = "Peu nuageux";
                newDrawableId = isNight ? Rez.Drawables.BgNubesNoche : Rez.Drawables.BgNubes;
                break;

            case Weather.CONDITION_MOSTLY_CLOUDY:
            case Weather.CONDITION_CLOUDY:
                newText = "Nuageux";
                newDrawableId = isNight ? Rez.Drawables.BgNubesNoche : Rez.Drawables.BgNubes;
                break;

            case Weather.CONDITION_FOG:
            case Weather.CONDITION_HAZY:
            case Weather.CONDITION_MIST:
            case Weather.CONDITION_SMOKE:
                newText = "Brume";
                newDrawableId = isNight ? Rez.Drawables.BgNubesNoche : Rez.Drawables.BgNubes;
                break;

            case Weather.CONDITION_WINDY:
            case Weather.CONDITION_SQUALL:
            case Weather.CONDITION_SANDSTORM:
                newText = "Vent";
                newDrawableId = Rez.Drawables.BgViento;
                break;

            default:
                newText = "Météo " + condition;
                newDrawableId = isNight ? Rez.Drawables.BgNubesNoche : Rez.Drawables.BgNubes;
                break;
        }

        // 7. GESTIÓN DE MEMORIA (Solo carga el bitmap si el clima cambió)
        if (newDrawableId != _cachedDrawableId) {
            _cachedDrawableId = newDrawableId;
            _cachedBitmap = WatchUi.loadResource(newDrawableId);
        }

        _cachedWeatherText = newText;
        _cachedFontColor = newColor;
    }
}