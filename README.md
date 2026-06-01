# Zabbix - Monitoreo de Microsoft SQL Server Failover Cluster

Esta solución proporciona un monitoreo integral y automatizado para clústeres de alta disponibilidad de Windows Server que ejecutan **Microsoft SQL Server** (FCI o Grupos de Disponibilidad AlwaysOn). 

Utiliza **Zabbix Agent 2** y scripts nativos de **PowerShell** para autodescubrir y evaluar el estado de los componentes críticos en tiempo real, brindando visibilidad total sobre la infraestructura física y lógica de la base de datos.

## 🚀 Características Principales

* **Monitoreo de Roles de SQL Server:** Descubre automáticamente las instancias y roles del clúster. Detecta en qué nodo activo se encuentra corriendo el servicio y dispara una alerta (`WARNING`) en el momento exacto en que ocurre un salto de nodo (*Failover*).
* **Estado de Recursos SQL:** Revisa constantemente la salud del Motor de Base de Datos, SQL Server Agent y otros recursos agrupados. Genera una alerta crítica (`DISASTER`) si un componente abandona el estado *Online*.
* **Almacenamiento (Storage):** Descubre discos físicos y volúmenes compartidos de clúster (*Cluster Shared Volumes / CSV*). Monitorea su estado operativo (`HIGH`) y rastrea qué servidor tiene actualmente la propiedad y acceso al disco.
* **Redes de Clúster (Networks):** Vigila todas las redes del clúster (internas, públicas o de latido/heartbeat) para detectar de inmediato estados de caída (*Down*) o partición de red (*Partitioned*).
* **Alta Frecuencia de Comprobación:** Todos los descubrimientos (*LLD*) y lecturas de estado están configurados con un intervalo estricto de **5 minutos** para garantizar una respuesta rápida ante incidentes.
* **Etiquetado Jerárquico (Tags):** Los datos generados se agrupan automáticamente en Zabbix bajo la etiqueta principal `Application: Failover Cluster` y se subdividen de forma lógica mediante la etiqueta `Component` en `SQL`, `Storage` o `Network`.

---

## 📋 Requisitos Previos

Para asegurar el correcto funcionamiento de esta plantilla, tu entorno debe cumplir con lo siguiente:

1. **Servidor Zabbix:** Versión 6.0 LTS o superior (compatible con la arquitectura moderna de plantillas y etiquetas).
2. **Agente:** Zabbix Agent 2 instalado en cada nodo que conforma el clúster.
3. **PowerShell:** Versión 5.1 o superior en los nodos de Windows Server.
4. **Permisos del Agente:** Por defecto, el servicio de Zabbix en Windows se ejecuta como *Local System*, el cual no siempre tiene privilegios para leer el estado del clúster. **Debes configurar el servicio `Zabbix Agent 2` para que inicie sesión con una cuenta de dominio o administrador local** que tenga permisos de lectura en el *Failover Cluster Manager*.

---

## ⚙️ Guía de Instalación

Sigue estos pasos en cada uno de los servidores (nodos) que forman parte de tu clúster de SQL Server.

### Paso 1: Copiar los scripts de PowerShell
Copia la carpeta `CustomScripts` (que contiene los 9 archivos `.ps1`) dentro del directorio de instalación de tu agente Zabbix.  
Ruta recomendada: `C:\Program Files\Zabbix Agent 2\CustomScripts\`

### Paso 2: Configurar los parámetros de usuario (UserParameters)
Abre el archivo de configuración de tu agente (`zabbix_agent2.conf`) y añade el siguiente bloque de código al final del archivo. Esto le enseñará a Zabbix cómo ejecutar los scripts de descubrimiento y estado:

```ini
# =======================================================
# MONITOREO DE FAILOVER CLUSTER (SQL, DISKS, NETWORKS)
# =======================================================
#Teniendo en cuenta que estas utilizando Zabbix Agent 2 si la ubicacion esta en otro lado se deben de hacer las modificaciones necesarias

# --- SQL Server Roles ---
UserParameter=sql.cluster.roles.discovery,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\CustomScripts\SqlClusterRolesDiscovery.ps1"
UserParameter=sql.cluster.role.activenode[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\CustomScripts\SqlClusterRoleActiveNode.ps1" -RoleId "$1"

# --- SQL Server Resources ---
UserParameter=sql.cluster.resources.discovery,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\CustomScripts\SqlClusterResourcesDiscovery.ps1"
UserParameter=sql.cluster.resource.state[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\CustomScripts\SqlClusterResourceState.ps1" -Id "$1"

# --- Cluster Storage (Discos y CSV) ---
UserParameter=cluster.disks.discovery,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\CustomScripts\ClusterDisksDiscovery.ps1"
UserParameter=cluster.disk.state[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\CustomScripts\ClusterDiskState.ps1" -Id "$1"
UserParameter=cluster.disk.activenode[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\CustomScripts\ClusterDiskActiveNode.ps1" -Id "$1"

# --- Cluster Networks ---
UserParameter=cluster.networks.discovery,powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\CustomScripts\ClusterNetworksDiscovery.ps1"
UserParameter=cluster.network.state[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent 2\CustomScripts\ClusterNetworkState.ps1" -Id "$1"
```

### Paso 3: Reiniciar el Agente
Para que Zabbix Agent 2 reconozca los nuevos comandos, abre una consola de PowerShell como Administrador y reinicia el servicio:
```powershell
Restart-Service -Name "Zabbix Agent 2"
```

### Paso 4: Importar la plantilla en Zabbix
1. Ingresa a la interfaz web de tu servidor Zabbix.
2. Navega a **Configuration -> Templates** y haz clic en el botón **Import**.
3. Selecciona el archivo `Template_Windows_SQL_Failover_Cluster_Final.json` incluido en este repositorio.
4. Una vez importado con éxito, asocia la plantilla al *Host* que representa tu clúster de Windows en Zabbix. ¡En un máximo de 5 minutos comenzarás a ver los datos!

---

## 📂 Estructura del Repositorio

* `README.md`: Este archivo de documentación.
* `Template_Windows_SQL_Failover_Cluster.json`: La plantilla oficial lista para importar en Zabbix 6.0+.
* `zabbix_agent2.conf.example`: Ejemplo con las líneas exactas que deben agregarse al archivo de configuración del agente.
* `/CustomScripts`: Directorio que contiene la lógica de extracción de datos para Roles, Recursos, Discos y Redes mediante PowerShell.

## 🤝 Contribuciones
¡Las mejoras y sugerencias son bienvenidas! Siéntete libre de abrir un *Issue* o enviar un *Pull Request* si deseas expandir el monitoreo a otros componentes del clúster de Windows.
