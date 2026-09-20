import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Application.Properties;

class ClimaWatchView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        // 1. Valores por defecto (Garantiza que SIEMPRE haya un fondo y un color)
        var weatherString = "Buscando...";
        var currentBgImage = WatchUi.loadResource(Rez.Drawables.BgNubes);
        var fontColor = Graphics.COLOR_WHITE; 

        var conditions = Weather.getCurrentConditions();

        // 2. Lógica condicional con registro de climas faltantes
        if (conditions != null && conditions.condition != null) {
            
            if (conditions.condition == Weather.CONDITION_CLEAR) {
                weatherString = "Despejado";
                currentBgImage = WatchUi.loadResource(Rez.Drawables.BgSol);
                fontColor = Graphics.COLOR_BLACK; // Contraste oscuro para día soleado
                
            } else if (conditions.condition == Weather.CONDITION_RAIN || 
                       conditions.condition == Weather.CONDITION_DRIZZLE || 
                       conditions.condition == Weather.CONDITION_SHOWERS) {
                weatherString = "Lluvia";
                currentBgImage = WatchUi.loadResource(Rez.Drawables.BgLluvia);
                fontColor = Graphics.COLOR_WHITE;
                
            } else if (conditions.condition == Weather.CONDITION_CLOUDY || 
                       conditions.condition == Weather.CONDITION_PARTLY_CLOUDY || 
                       conditions.condition == Weather.CONDITION_MOSTLY_CLOUDY) {
                weatherString = "Nublado";
                currentBgImage = WatchUi.loadResource(Rez.Drawables.BgNubes);
                fontColor = Graphics.COLOR_WHITE;
                
            } else {
                // 3. Capturar climas no mapeados (Ej. Nieve, Viento, Tormenta)
                weatherString = "Cod: " + conditions.condition;
                System.println("Falta imagen para el clima código: " + conditions.condition);
                
                // Mantiene el fondo por defecto definido al inicio
            }
        }

        // Limpiamos la pantalla
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();

        // Dibujar la imagen de fondo (siempre existirá gracias al valor por defecto)
        if (currentBgImage != null) {
            dc.drawBitmap(0, 0, currentBgImage);
        }

        // Renderizar la hora
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        
        // Aplicamos el color de fuente dinámico
        dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 70, Graphics.FONT_NUMBER_HOT, timeString, Graphics.TEXT_JUSTIFY_CENTER);

        // Renderizar el texto del clima
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 + 60, Graphics.FONT_MEDIUM, weatherString, Graphics.TEXT_JUSTIFY_CENTER);
    }
}