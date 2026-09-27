# 🌤️ ClimaWatch - Dynamic Watch Face for Garmin Vivoactive 5

![Garmin](https://img.shields.io/badge/Garmin-Connect_IQ-blue.svg)
![Language](https://img.shields.io/badge/Language-Monkey_C-orange.svg)
![Device](https://img.shields.io/badge/Device-Vivoactive_5-success.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

Una esfera de reloj (Watch Face) personalizada y altamente optimizada para **Garmin Vivoactive 5**, desarrollada en Monkey C. Su característica principal es la anticipación meteorológica: adapta su diseño visual y legibilidad basándose en el pronóstico del clima a **30 minutos en el futuro**, permitiendo al usuario planificar sus actividades al aire libre con precisión.

## ✨ Características Principales

* **Anticipación Climática:** Utiliza la API `Weather.getHourlyForecast()` para calcular el tiempo actual + 1800 segundos, renderizando el fondo correspondiente al clima que hará en media hora.
* **Fondos Dinámicos Optimizados:** Imágenes a pantalla completa diseñadas estrictamente a 390x390 píxeles para aprovechar la pantalla AMOLED del Vivoactive 5 sin violar los límites de memoria.
* **Contraste Adaptativo Inteligente:** El color de la tipografía principal (hora y fecha) cambia automáticamente entre blanco y negro dependiendo de la luminosidad del fondo cargado, garantizando siempre una legibilidad perfecta.
* **Métricas de Salud en Vivo:** Integración con `Toybox.SensorHistory` para mostrar métricas clave como el **Body Battery** del usuario.
* **Localización:** Formato de fecha renderizado en francés.

## 🧠 Arquitectura y Rendimiento (Under the Hood)

El desarrollo en ecosistemas de hardware limitado (como wearables) requiere una gestión estricta de los recursos. Este proyecto implementa:

* **Sistema de Caché de Bitmaps:** En lugar de invocar `WatchUi.loadResource()` en cada ciclo de actualización (`onUpdate`), el código evalúa una máquina de estados. Si la condición climática no ha cambiado, el reloj recicla el puntero en RAM de la imagen actual, reduciendo el consumo de batería y evitando micro-congelamientos.
* **Estructura Switch-Case:** Refactorización de múltiples operadores lógicos superpuestos hacia sentencias `switch` en cascada, mejorando el tiempo de ejecución del compilador al mapear más de 20 códigos climáticos de Garmin (`CONDITION_THUNDERSTORMS`, `CONDITION_FOG`, etc.).
* **Eliminación de Fugas de Memoria:** Centralización de variables estáticas y prevención de instanciación de objetos temporales durante los ciclos de redibujado de la interfaz.

## 📸 Capturas de Pantalla

*(Añade aquí las imágenes de tu reloj mostrando diferentes climas)*

<p align="center">
  <img src="link_a_imagen_despejado.jpg" width="200" alt="Clima Despejado"/>
  <img src="link_a_imagen_lluvia.jpg" width="200" alt="Clima Lluvioso"/>
  <img src="link_a_imagen_noche.jpg" width="200" alt="Vista Nocturna"/>
</p>

## ⚙️ Requisitos y Compilación

* **Hardware:** Garmin Vivoactive 5 (o dispositivos AMOLED de 390x390 px compatibles).
* **Software:** 
  * [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
  * Visual Studio Code con la extensión de Monkey C.

### Instalación Local (Sideloading)
Para compilar y transferir la aplicación directamente a tu reloj físico:

1. Clona este repositorio: `git clone https://github.com/TU_USUARIO/ClimaWatch.git`
2. Abre el proyecto en VS Code.
3. Presiona `Ctrl + Shift + P` y ejecuta el comando `Monkey C: Build for Device`. Selecciona tu dispositivo de destino.
4. Conecta tu Garmin al ordenador mediante USB.
5. Copia el archivo `.prg` generado (ubicado en la carpeta `bin/`) y pégalo en el directorio `GARMIN/APPS` del almacenamiento interno de tu reloj.
6. Desconecta el dispositivo de forma segura y selecciona la esfera desde el menú del reloj.

## 🚀 Próximos Pasos (Roadmap)

- [ ] **Modo AOD (Always-On Display):** Implementación de `onEnterSleep()` para desplazar píxeles y evitar quemaduras (burn-in) en la pantalla AMOLED.
- [ ] **Segundos Fluidos:** Implementación de `onPartialUpdate()` para actualizar los segundos y la frecuencia cardíaca en tiempo real a 1Hz respetando el presupuesto energético (power budget) de Garmin.
- [ ] **Configuraciones de Usuario (App Settings):** Exponer propiedades en Garmin Connect para permitir al usuario elegir el tiempo de anticipación del pronóstico (Actual, +30 min, +1 h).

## 👨‍💻 Autor

**[Anderson BARRERA]** 
*Estudiante de Ingeniería de Sistemas y Computación | Apasionado por la tecnología, el , aeronáutica y el desarrollo de software.*

* [LinkedIn](https://www.linkedin.com/in/anderson-barrera-251b5525b/)
* [GitHub](https://github.com/AndersonStick)