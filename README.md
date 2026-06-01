# Zabbix - Microsoft SQL Server Failover Cluster Monitoring

Esta solución proporciona una monitorización integral para clústeres de alta disponibilidad de Windows Server que ejecutan Microsoft SQL Server (FCI o Grupos de Disponibilidad AlwaysOn). Utiliza Zabbix Agent 2 y scripts nativos de PowerShell para autodescubrir y evaluar el estado de los componentes críticos en tiempo real.

## Características

* **Roles de SQL Server:** Descubre automáticamente las instancias/roles del clúster. Monitorea en qué nodo activo se encuentra corriendo y dispara una alerta (`WARNING`) cuando detecta un salto o *Failover*.
* **Recursos de SQL Server:** Revisa constantemente el estado del Motor de Base de Datos, SQL Server Agent y otros recursos agrupados, alertando (`DISASTER`) si dejan de estar *Online*.
* **Almacenamiento (Storage):** Descubre discos físicos y *Cluster Shared Volumes* (CSV). Monitorea su estado operativo (`HIGH`) y detecta qué servidor tiene actualmente la propiedad del disco.
* **Redes de Clúster (Networks):** Vigila todas las redes del clúster (internas y públicas) para detectar estados de caída (*Down*) o partición de red (*Partitioned*).
* **Alta Frecuencia:** Los descubrimientos y lecturas de estado tienen un intervalo estricto de comprobación de **5 minutos**.
* **Etiquetado Jerárquico:** Todos los datos se agrupan de forma automática en Zabbix bajo la etiqueta `Application: Failover Cluster` y se subdividen mediante la etiqueta `Component` en `SQL`, `Storage` o `Network`.

## Requisitos Previos

1. **Servidor Zabbix:** Versión 6.0 LTS o superior.
2. **Agente:** Zabbix Agent 2 instalado en cada nodo del clúster.
3. **PowerShell:** Versión 5.1 o superior.
4. **Permisos:** El servicio `Zabbix Agent 2` en Windows **no debe ejecutarse como Local System**. Debe configurarse para usar una cuenta de dominio o de administrador local que tenga permisos de lectura sobre los recursos del *Failover Cluster Manager*.

## Instalación

### Paso 1: Copiar los scripts
Copia el contenido de la carpeta `CustomScripts/` al directorio de tu agente Zabbix en todos los nodos del clúster.  
Ruta recomendada: `C:\Program Files\Zabbix Agent 2\CustomScripts\`

### Paso 2: Configurar Zabbix Agent 2
Añade las directivas de parámetros de usuario ubicadas en `zabbix_agent2.conf.example` al final del archivo de configuración principal de tu agente (`zabbix_agent2.conf`).

### Paso 3: Reiniciar el servicio
Reinicia el agente de Zabbix para aplicar los cambios:
```powershell
Restart-Service -Name "Zabbix Agent 2"
