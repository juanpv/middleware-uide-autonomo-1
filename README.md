# Raíz Urbana 🌱

Emprendimiento digital (proyecto académico) — **vivero digital** de plantas de interior, macetas de diseño y accesorios de jardinería urbana.

> *Cultiva tu espacio, respira tu ciudad.*

Trabajo de Aprendizaje Autónomo — Universidad Internacional del Ecuador (UIDE).

---

## 📦 Contenido del repositorio

```
├── web/                     Sitio web (HTML5 + CSS3 + JavaScript + jQuery)
│   ├── index.html           Página única (SPA) con las 7 secciones
│   ├── css/styles.css       Estilos y diseño responsivo
│   ├── js/app.js            Lógica: navegación, catálogo, carrito, validaciones
│   ├── js/jquery.min.js     jQuery 3.7.1 (local)
│   └── img/                 Logotipo e ilustraciones de productos (SVG)
├── sql/
│   └── raiz_urbana.sql      Script de la base de datos (14 tablas + datos + CRUD)
├── doc/
│   ├── Raiz_Urbana_APA.docx Documento del proyecto (normas APA 7)
│   ├── Raiz_Urbana_APA.pdf  Versión PDF
│   └── er-diagrama.png      Diagrama Entidad-Relación
└── README.md
```

## 🌐 Sitio web

Aplicación **estática** (no requiere servidor). Para verla, basta con abrir el archivo:

```
web/index.html
```

Características:
- **Cabecera** con nombre y logotipo, y **barra de navegación** debajo.
- 7 secciones: Home, Empresa, Productos, Oferta del mes, Localización, Contacto y Noticias.
- **Catálogo** de productos tipo tienda, con buscador y filtros por categoría.
- **Carrito de compras** básico (agregar, cantidades, compra simulada) — sin backend.
- **Oferta del mes** con contador regresivo.
- **Localización** con mapa de Google Maps embebido.
- Diseño **responsivo** (adaptable a móviles).

### Tecnologías
HTML5 · CSS3 · JavaScript (DOM) · jQuery 3.7.1

## 🗄️ Base de datos

El archivo [`sql/raiz_urbana.sql`](sql/raiz_urbana.sql) contiene el modelo relacional normalizado (3FN)
con **14 tablas**, datos de ejemplo y las operaciones **CRUD**. Escrito para **MySQL 8.x**
(incluye notas de portabilidad a SQL Server y PostgreSQL).

```bash
mysql -u root -p < sql/raiz_urbana.sql
```

## 📄 Documentación

El documento completo del proyecto (con normas APA 7) está en la carpeta [`doc/`](doc/):
descripción del emprendimiento, desarrollo web, identificación de entidades, modelo E/R,
normalización y el script SQL.

---

© 2024–2026 Raíz Urbana — Proyecto académico.

> Nota: el sitio incluye el modulo Clima, un reporteador del clima con la API de OpenWeatherMap.
