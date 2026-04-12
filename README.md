# 🎯 WinShooter

*¿Cansado de que el solucionador de Windows nunca solucione nada? Yo también, así que he decidido crear mi propia herramienta impulsada por los modelos de IA de Ollama y Groq.*

WinShooter es un agente de diagnóstico autónomo diseñado para detectar y reparar problemas técnicos en Windows de forma real. A diferencia de las herramientas integradas, WinShooter analiza el sistema, ejecuta comandos de diagnóstico y aplica correcciones directamente utilizando inteligencia artificial de última generación.

## 🚀 Características Principales

- **Identificación Inteligente**: Detección de usuario personalizada mediante Groq Cloud (Llama 3.1 8B).
- **Búsqueda Instantánea**: Encuentra soluciones a problemas comunes con latencia sub-segundo.
- **Diagnóstico Autónomo**: Un bucle de pensamiento y acción que utiliza **Minimax (Ollama Cloud)** para inspeccionar hardware, servicios y configuraciones.
- **Interfaz Premium**: Diseño minimalista, oscuro y fluido con animaciones de ripple y feedback visual dinámico.
- **Control Total**: Capacidad para ejecutar scripts de PowerShell, comandos CMD y reparaciones de registro sin restricciones.

## 🛠️ Tecnologías

- **Backend**: PowerShell 5.1 / 7.0 (Servidor HTTP ligero y Proxy AI).
- **Frontend**: HTML5, CSS3 (Vanilla), JavaScript (ES6+).
- **IA**: integración dual con **Ollama Cloud** (Minimax) y **Groq Cloud** (Llama-3.1-8b-instant).

## 📦 Instalación y Uso

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/samilososami/winshooter.git
   cd winshooter
   ```

2. **Ejecutar el servidor**:
   Abre una terminal de PowerShell y ejecuta:
   ```powershell
   .\winshooter.ps1
   ```

3. **Acceder a la interfaz**:
   Abre tu navegador en `http://localhost:8080` (o el puerto configurado).

## ⚠️ Advertencia

WinShooter está diseñado para su ejecución en entornos de prueba o máquinas virtuales, ya que tiene acceso total para ejecutar comandos en el sistema. Úsalo bajo tu propia responsabilidad.

---
Codificado con ❤️ por [samilososami](https://github.com/samilososami)
