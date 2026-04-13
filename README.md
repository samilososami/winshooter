<div align="center">

# WinShooter

Agente de diagnóstico autónomo para Windows potenciado por inteligencia artificial.  
Analiza, diagnostica y repara problemas del sistema de forma automática utilizando modelos de lenguaje avanzados.

<br>

<img src="https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell" />
<img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black" alt="JS" />
<img src="https://img.shields.io/badge/Ollama-000000?style=for-the-badge&logo=ollama&logoColor=white" alt="Ollama" />
<img src="https://img.shields.io/badge/Groq-F55036?style=for-the-badge&logo=groq&logoColor=white" alt="Groq" />

</div>

---

### ✦ Características

*   **Diagnóstico Inteligente**: Utiliza Groq Cloud (Llama 3.1 8B) para la identificación de problemas y razonamiento lógico.
*   **Reparación Autónoma**: Capacidad de ejecutar scripts de PowerShell y comandos CMD para aplicar correcciones directamente.
*   **Búsqueda de Soluciones**: Integración con bases de conocimientos para encontrar remedios a problemas comunes en tiempo récord.
*   **Interfaz Fluida**: Diseño minimalista basado en la web con feedback visual dinámico y animaciones optimizadas.
*   **Acceso de Bajo Nivel**: Inspección profunda de hardware, registros del sistema y configuraciones de red.

### ✦ Instalación Rápida

Ejecute el siguiente comando desde una terminal de PowerShell con privilegios de administrador:

```powershell
irm winshooter.samilososami.com | iex
```

### ✦ Instalación Manual

1.  Clone el repositorio:
    ```bash
    git clone https://github.com/samilososami/winshooter.git
    cd winshooter
    ```
2.  Inicie el servidor de diagnóstico:
    ```powershell
    .\winshooter\script.ps1
    ```
3.  Acceda localmente a través de su navegador en `http://localhost:8080`.

### ✦ Tecnologías

*   **Backend**: PowerShell (Servidor HTTP ligero y Proxy para APIs de IA).
*   **Frontend**: HTML5, CSS3 moderno y JavaScript (ES6+).
*   **Inteligencia Artificial**: Integración dual con Ollama Cloud y Groq Cloud.

---

> [!WARNING]
> WinShooter requiere acceso administrativo para ejecutar comandos de reparación. Se recomienda su uso en entornos de prueba o máquinas virtuales.