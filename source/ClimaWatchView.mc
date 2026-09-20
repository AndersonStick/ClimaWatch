import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;

class WeatherDisplay {
    var label;
    var drawable;
    var fontColor;

    function initialize(displayLabel, displayDrawable, displayFontColor) {
        label = displayLabel;
        drawable = displayDrawable;
        fontColor = displayFontColor;
    }
}

class ClimaWatchView extends WatchUi.WatchFace {
    const NIGHT_START_HOUR = 19;
    const NIGHT_END_HOUR = 6;
    const FORECAST_OFFSET_SECONDS = 1800;

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var isNight = isNightTime(clockTime.hour);
        var weatherDisplay = getWeatherDisplay(isNight);

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();

        drawBackground(dc, weatherDisplay.drawable);

        dc.setColor(weatherDisplay.fontColor, Graphics.COLOR_TRANSPARENT);
        drawTime(dc, clockTime);
        drawDate(dc);
        drawWeather(dc, weatherDisplay.label);
    }

    function drawBackground(dc as Dc, drawable) as Void {
        var background = WatchUi.loadResource(drawable);

        if (background != null) {
            dc.drawBitmap(0, 0, background);
        }

        background = null;
    }

    function drawTime(dc as Dc, clockTime) as Void {
        var timeString = Lang.format("$1$:$2$", [
            clockTime.hour,
            clockTime.min.format("%02d")
        ]);

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 - 90,
            Graphics.FONT_NUMBER_HOT,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawDate(dc as Dc) as Void {
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 + 25,
            Graphics.FONT_MEDIUM,
            formatFrenchDate(),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawWeather(dc as Dc, weatherText as String) as Void {
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2 + 85,
            Graphics.FONT_MEDIUM,
            weatherText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function getWeatherDisplay(isNight as Boolean) as WeatherDisplay {
        var forecast = getForecastForOffset();

        if (forecast != null && forecast.condition != null) {
            return getWeatherDisplayForCondition(forecast.condition, isNight);
        }

        var conditions = Weather.getCurrentConditions();

        if (conditions == null || conditions.condition == null) {
            return new WeatherDisplay("Recherche...", getCloudDrawable(isNight), Graphics.COLOR_WHITE);
        }

        return getWeatherDisplayForCondition(conditions.condition, isNight);
    }

    function getForecastForOffset() {
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

            var distance = forecast.forecastTime.value() - targetTime;
            var absoluteDistance = distance;

            if (absoluteDistance < 0) {
                absoluteDistance = -absoluteDistance;
            }

            if (closestDistance == null || absoluteDistance < closestDistance) {
                closestForecast = forecast;
                closestDistance = absoluteDistance;
            }
        }

        return closestForecast;
    }

    function getWeatherDisplayForCondition(condition, isNight as Boolean) as WeatherDisplay {
        if (condition == Weather.CONDITION_CLEAR) {
            return new WeatherDisplay("Dégagé", getClearDrawable(isNight), getClearFontColor(isNight));
        }

        if (condition == Weather.CONDITION_MOSTLY_CLEAR ||
            condition == Weather.CONDITION_PARTLY_CLEAR ||
            condition == Weather.CONDITION_FAIR) {
            return new WeatherDisplay("Dégagé", getClearDrawable(isNight), getClearFontColor(isNight));
        }

        if (condition == Weather.CONDITION_RAIN ||
            condition == Weather.CONDITION_LIGHT_RAIN ||
            condition == Weather.CONDITION_HEAVY_RAIN ||
            condition == Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN) {
            return new WeatherDisplay("Pluie", getRainDrawable(isNight), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_DRIZZLE) {
            return new WeatherDisplay("Bruine", getRainDrawable(isNight), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_SHOWERS ||
            condition == Weather.CONDITION_LIGHT_SHOWERS ||
            condition == Weather.CONDITION_HEAVY_SHOWERS ||
            condition == Weather.CONDITION_SCATTERED_SHOWERS) {
            return new WeatherDisplay("Averses", getRainDrawable(isNight), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_CHANCE_OF_SHOWERS) {
            return new WeatherDisplay("Risque pluie", getRainDrawable(isNight), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_THUNDERSTORMS ||
            condition == Weather.CONDITION_SCATTERED_THUNDERSTORMS ||
            condition == Weather.CONDITION_CHANCE_OF_THUNDERSTORMS) {
            return new WeatherDisplay("Orage", getStormDrawable(), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_UNKNOWN_PRECIPITATION ||
            condition == Weather.CONDITION_WINTRY_MIX ||
            condition == Weather.CONDITION_RAIN_SNOW ||
            condition == Weather.CONDITION_LIGHT_RAIN_SNOW ||
            condition == Weather.CONDITION_HEAVY_RAIN_SNOW ||
            condition == Weather.CONDITION_CHANCE_OF_RAIN_SNOW ||
            condition == Weather.CONDITION_FREEZING_RAIN ||
            condition == Weather.CONDITION_SLEET) {
            return new WeatherDisplay("Précip.", getRainDrawable(isNight), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_SNOW ||
            condition == Weather.CONDITION_LIGHT_SNOW ||
            condition == Weather.CONDITION_HEAVY_SNOW ||
            condition == Weather.CONDITION_CHANCE_OF_SNOW ||
            condition == Weather.CONDITION_FLURRIES ||
            condition == Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW ||
            condition == Weather.CONDITION_ICE ||
            condition == Weather.CONDITION_ICE_SNOW ||
            condition == Weather.CONDITION_HAIL) {
            return new WeatherDisplay("Neige", getSnowDrawable(isNight), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_PARTLY_CLOUDY) {
            return new WeatherDisplay("Peu nuageux", getCloudDrawable(isNight), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_MOSTLY_CLOUDY) {
            return new WeatherDisplay("Très nuageux", getCloudDrawable(isNight), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_CLOUDY ||
            condition == Weather.CONDITION_THIN_CLOUDS ||
            condition == Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW) {
            return new WeatherDisplay("Nuageux", getCloudDrawable(isNight), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_FOG ||
            condition == Weather.CONDITION_HAZY ||
            condition == Weather.CONDITION_HAZE ||
            condition == Weather.CONDITION_MIST ||
            condition == Weather.CONDITION_SMOKE) {
            return new WeatherDisplay("Brume", getCloudDrawable(isNight), Graphics.COLOR_WHITE);
        }

        if (condition == Weather.CONDITION_WINDY ||
            condition == Weather.CONDITION_DUST ||
            condition == Weather.CONDITION_SAND ||
            condition == Weather.CONDITION_SQUALL ||
            condition == Weather.CONDITION_SANDSTORM ||
            condition == Weather.CONDITION_VOLCANIC_ASH) {
            return new WeatherDisplay("Vent", getWindDrawable(), Graphics.COLOR_WHITE);
        }

        System.println("Image météo manquante pour le code: " + condition);
        return new WeatherDisplay("Météo " + condition, getCloudDrawable(isNight), Graphics.COLOR_WHITE);
    }

    function isNightTime(hour as Number) as Boolean {
        return hour >= NIGHT_START_HOUR || hour < NIGHT_END_HOUR;
    }

    function getClearDrawable(isNight as Boolean) {
        return isNight ? Rez.Drawables.BgSolNoche : Rez.Drawables.BgSol;
    }

    function getRainDrawable(isNight as Boolean) {
        return isNight ? Rez.Drawables.BgLluviaNoche : Rez.Drawables.BgLluvia;
    }

    function getCloudDrawable(isNight as Boolean) {
        return isNight ? Rez.Drawables.BgNubesNoche : Rez.Drawables.BgNubes;
    }

    function getSnowDrawable(isNight as Boolean) {
        return isNight ? Rez.Drawables.BgNieveNoche : Rez.Drawables.BgNieveDia;
    }

    function getStormDrawable() {
        return Rez.Drawables.BgTormenta;
    }

    function getWindDrawable() {
        return Rez.Drawables.BgViento;
    }

    function getClearFontColor(isNight as Boolean) as Number {
        return isNight ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
    }

    function formatFrenchDate() as String {
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var weekdays = ["dim", "lun", "mar", "mer", "jeu", "ven", "sam"];
        var weekdayIndex = dateInfo.day_of_week - 1;

        if (weekdayIndex < 0 || weekdayIndex >= weekdays.size()) {
            weekdayIndex = 0;
        }

        return Lang.format("$1$ $2$", [weekdays[weekdayIndex], dateInfo.day]);
    }
}
