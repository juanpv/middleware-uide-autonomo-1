/* ====================================================================
   Raíz Urbana — Lógica de la aplicación (jQuery + DOM)
   Sin backend: el carrito y la "compra" son simulados en el navegador.
   ==================================================================== */
$(function () {

  /* ---------- 1. Datos (simulan la base de datos) ---------- */
  const PRODUCTOS = [
    { id: 1,  nombre: 'Monstera Deliciosa', cat: 'Plantas',     precio: 24.90, img: 'img/productos/monstera.svg',    desc: 'Hojas amplias y tropicales. Ideal para dar carácter a la sala.' },
    { id: 2,  nombre: 'Pothos Dorado',      cat: 'Plantas',     precio: 12.50, img: 'img/productos/pothos.svg',      desc: 'Enredadera resistente que purifica el aire. Muy fácil de cuidar.' },
    { id: 3,  nombre: 'Cactus San Pedro',   cat: 'Plantas',     precio:  9.90, img: 'img/productos/cactus.svg',      desc: 'Cactus columnar de bajo mantenimiento. Perfecto para principiantes.' },
    { id: 4,  nombre: 'Suculenta Echeveria',cat: 'Plantas',     precio:  6.50, img: 'img/productos/suculenta.svg',   desc: 'Roseta compacta y decorativa. Necesita poca agua y mucha luz.' },
    { id: 5,  nombre: 'Ficus Lyrata',       cat: 'Plantas',     precio: 34.00, img: 'img/productos/ficus.svg',       desc: 'La famosa hoja de violín. Elegante planta de gran porte.' },
    { id: 6,  nombre: 'Sansevieria',        cat: 'Plantas',     precio: 15.90, img: 'img/productos/sansevieria.svg', desc: 'Lengua de suegra. Casi indestructible y purificadora.' },
    { id: 7,  nombre: 'Kokedama Colgante',  cat: 'Plantas',     precio: 16.00, img: 'img/productos/kokedama.svg',    desc: 'Arte japonés en musgo. Un detalle verde que flota en tu espacio.' },
    { id: 8,  nombre: 'Maceta Cerámica',    cat: 'Macetas',     precio: 11.00, img: 'img/productos/maceta.svg',      desc: 'Maceta artesanal de terracota. Aporta calidez a cualquier planta.' },
    { id: 9,  nombre: 'Sustrato Universal 5L',cat: 'Accesorios',precio:  7.90, img: 'img/productos/sustrato.svg',    desc: 'Mezcla equilibrada para el óptimo desarrollo de tus plantas.' },
    { id: 10, nombre: 'Regadera Vintage',   cat: 'Accesorios',  precio: 18.50, img: 'img/productos/regadera.svg',    desc: 'Regadera metálica de diseño retro. Riego preciso y con estilo.' }
  ];

  const NOTICIAS = [
    { fecha: '10 JUL 2026', color: '#2E5D3B', titulo: 'Abrimos nuestra segunda tienda en Cumbayá', txt: 'Tras el éxito del primer local, Raíz Urbana llega a Cumbayá con un vivero de más de 300 especies y un rincón de talleres.' },
    { fecha: '28 JUN 2026', color: '#C1683A', titulo: 'Taller gratuito: “Plantas que purifican el aire”', txt: 'El próximo sábado dictaremos un taller abierto sobre las mejores especies para mejorar el aire de tu hogar. Cupos limitados.' },
    { fecha: '15 JUN 2026', color: '#4A8B5C', titulo: 'Nueva línea de macetas biodegradables', txt: 'Presentamos macetas hechas con fibra de coco 100% compostable, parte de nuestro compromiso con la sostenibilidad.' },
    { fecha: '02 JUN 2026', color: '#7FB069', titulo: 'Envíos ahora en 24 horas dentro de Quito', txt: 'Optimizamos nuestra logística: tu rincón verde llega al día siguiente, con embalaje protector reutilizable.' }
  ];

  const OFERTA = { id: 5, antes: 34.00, ahora: 22.90, desc: 'Este mes, el elegante Ficus Lyrata a un precio irresistible. Llévate la planta estrella de la decoración de interiores con 33% de descuento.' };

  /* ---------- 2. Estado del carrito (persistido en localStorage) ---------- */
  let carrito = [];
  try { carrito = JSON.parse(localStorage.getItem('ru_carrito')) || []; } catch (e) { carrito = []; }
  const guardar = () => { try { localStorage.setItem('ru_carrito', JSON.stringify(carrito)); } catch (e) { /* file:// puede bloquear localStorage; el carrito sigue funcionando en memoria */ } };
  const money = n => '$' + n.toFixed(2);

  /* ---------- 3. Navegación SPA (DOM + jQuery) ---------- */
  function irA(nombre) {
    $('.seccion').removeClass('is-active');
    $('#' + nombre).addClass('is-active');
    $('.nav__link').removeClass('is-active');
    $('.nav__link[data-nav="' + nombre + '"]').addClass('is-active');
    $('#navLista').removeClass('is-open');
    $('html,body').scrollTop(0);
  }
  $(document).on('click', '[data-nav]', function (e) {
    e.preventDefault();
    irA($(this).data('nav'));
  });
  $('#navToggle').on('click', () => $('#navLista').toggleClass('is-open'));

  /* ---------- 4. Catálogo de productos ---------- */
  function tarjeta(p) {
    return `
      <article class="prod" data-cat="${p.cat}">
        <img class="prod__img" src="${p.img}" alt="${p.nombre}" />
        <div class="prod__body">
          <span class="prod__cat">${p.cat}</span>
          <h3 class="prod__nom">${p.nombre}</h3>
          <p class="prod__desc">${p.desc}</p>
          <div class="prod__pie">
            <span class="prod__precio">${money(p.precio)}</span>
            <button class="prod__add" data-add="${p.id}">Agregar 🛒</button>
          </div>
        </div>
      </article>`;
  }

  function pintarCatalogo(lista) {
    const $c = $('#catalogo').empty();
    if (!lista.length) { $c.html('<p class="vacio">No se encontraron productos. 🌿</p>'); return; }
    lista.forEach(p => $c.append(tarjeta(p)));
  }
  pintarCatalogo(PRODUCTOS);

  // Chips de categoría
  const cats = ['Todos', ...new Set(PRODUCTOS.map(p => p.cat))];
  cats.forEach((c, i) =>
    $('#filtrosCats').append(`<button class="chip ${i === 0 ? 'is-active' : ''}" data-cat="${c}">${c}</button>`)
  );

  let catActiva = 'Todos';
  function aplicarFiltros() {
    const q = $('#buscador').val().toLowerCase().trim();
    const lista = PRODUCTOS.filter(p =>
      (catActiva === 'Todos' || p.cat === catActiva) &&
      (p.nombre.toLowerCase().includes(q) || p.desc.toLowerCase().includes(q))
    );
    pintarCatalogo(lista);
  }
  $('#filtrosCats').on('click', '.chip', function () {
    $('.chip').removeClass('is-active');
    $(this).addClass('is-active');
    catActiva = $(this).data('cat');
    aplicarFiltros();
  });
  $('#buscador').on('input', aplicarFiltros);

  /* ---------- 5. Carrito ---------- */
  function badge() {
    const n = carrito.reduce((s, i) => s + i.cant, 0);
    $('#carritoBadge').text(n);
  }
  function total() {
    return carrito.reduce((s, i) => s + i.precio * i.cant, 0);
  }
  function pintarCarrito() {
    const $d = $('#drawerItems').empty();
    if (!carrito.length) {
      $d.html('<p class="drawer__vacio">Tu carrito está vacío.<br>¡Agrega algo verde! 🌱</p>');
    } else {
      carrito.forEach(i => {
        $d.append(`
          <div class="citem">
            <img src="${i.img}" alt="${i.nombre}" />
            <div class="citem__info">
              <div class="citem__nom">${i.nombre}</div>
              <div class="citem__precio">${money(i.precio)}</div>
              <div class="citem__ctrl">
                <button data-menos="${i.id}">−</button>
                <span>${i.cant}</span>
                <button data-mas="${i.id}">+</button>
                <button class="citem__del" data-del="${i.id}" title="Quitar">🗑</button>
              </div>
            </div>
          </div>`);
      });
    }
    $('#drawerTotal').text(money(total()));
    badge();
    guardar();
  }

  function agregar(id) {
    const p = PRODUCTOS.find(x => x.id === id);
    const enCarrito = carrito.find(x => x.id === id);
    if (enCarrito) enCarrito.cant++;
    else carrito.push({ id: p.id, nombre: p.nombre, precio: p.precio, img: p.img, cant: 1 });
    pintarCarrito();
    toast(`✅ "${p.nombre}" agregado al carrito`);
  }

  $(document).on('click', '[data-add]', function () { agregar($(this).data('add')); });
  $('#drawerItems').on('click', '[data-mas]',   function () { const it = carrito.find(x => x.id === $(this).data('mas')); it.cant++; pintarCarrito(); });
  $('#drawerItems').on('click', '[data-menos]', function () { const it = carrito.find(x => x.id === $(this).data('menos')); it.cant--; if (it.cant <= 0) carrito = carrito.filter(x => x.id !== it.id); pintarCarrito(); });
  $('#drawerItems').on('click', '[data-del]',   function () { carrito = carrito.filter(x => x.id !== $(this).data('del')); pintarCarrito(); });

  // Abrir / cerrar drawer
  const abrir  = () => { $('#drawer,#drawerBg').addClass('is-open'); };
  const cerrar = () => { $('#drawer,#drawerBg').removeClass('is-open'); };
  $('#carritoBtn').on('click', abrir);
  $('#drawerClose,#drawerBg').on('click', cerrar);

  // Vaciar
  $('#btnVaciar').on('click', function () {
    if (!carrito.length) { toast('El carrito ya está vacío'); return; }
    carrito = [];
    pintarCarrito();
    toast('🗑 Carrito vaciado');
  });

  // Finalizar compra (simulada, sin backend)
  $('#btnComprar').on('click', function () {
    if (!carrito.length) { toast('Agrega productos antes de comprar 🌿'); return; }
    const items = carrito.reduce((s, i) => s + i.cant, 0);
    const monto = money(total());
    const orden = 'RU-' + Math.floor(100000 + Math.random() * 900000);
    carrito = [];
    pintarCarrito();
    cerrar();
    toast(`🎉 ¡Compra realizada! Orden ${orden} · ${items} artículo(s) · ${monto}. Recibirás un correo de confirmación.`, 5000);
  });

  /* ---------- 6. Oferta del mes + contador ---------- */
  (function () {
    const p = PRODUCTOS.find(x => x.id === OFERTA.id);
    $('#oferta-box').html(`
      <div class="oferta__img"><img src="${p.img}" alt="${p.nombre}" /></div>
      <div class="oferta__info">
        <span class="oferta__badge">🔥 OFERTA -33%</span>
        <h3>${p.nombre}</h3>
        <p>${OFERTA.desc}</p>
        <div class="oferta__precios">
          <span class="oferta__antes">${money(OFERTA.antes)}</span>
          <span class="oferta__ahora">${money(OFERTA.ahora)}</span>
        </div>
        <div class="oferta__timer" id="timer">
          <div><b id="t-d">00</b><span>días</span></div>
          <div><b id="t-h">00</b><span>horas</span></div>
          <div><b id="t-m">00</b><span>min</span></div>
          <div><b id="t-s">00</b><span>seg</span></div>
        </div>
        <button class="btn" data-add="${p.id}">Aprovechar oferta 🛒</button>
      </div>
    `);

    // Fin de mes (cuenta regresiva)
    const ahora = new Date();
    const fin = new Date(ahora.getFullYear(), ahora.getMonth() + 1, 0, 23, 59, 59);
    function tick() {
      let dif = Math.max(0, fin - new Date());
      const d = Math.floor(dif / 86400000); dif -= d * 86400000;
      const h = Math.floor(dif / 3600000);  dif -= h * 3600000;
      const m = Math.floor(dif / 60000);    dif -= m * 60000;
      const s = Math.floor(dif / 1000);
      const pad = n => String(n).padStart(2, '0');
      $('#t-d').text(pad(d)); $('#t-h').text(pad(h)); $('#t-m').text(pad(m)); $('#t-s').text(pad(s));
    }
    tick();
    setInterval(tick, 1000);
  })();

  /* ---------- 7. Noticias ---------- */
  NOTICIAS.forEach(n => {
    $('#noticias-lista').append(`
      <article class="noticia">
        <div class="noticia__cab" style="background:linear-gradient(135deg,${n.color},#26312B)">🌿 Raíz Urbana</div>
        <div class="noticia__body">
          <span class="noticia__fecha">${n.fecha}</span>
          <h3>${n.titulo}</h3>
          <p>${n.txt}</p>
        </div>
      </article>`);
  });

  /* ---------- 8. Validación formulario de contacto ---------- */
  $('#formContacto').on('submit', function (e) {
    e.preventDefault();
    let ok = true;
    const set = (id, msg) => { $('#e-' + id).text(msg); if (msg) ok = false; };
    const nombre = $('#c-nombre').val().trim();
    const correo = $('#c-correo').val().trim();
    const mensaje = $('#c-mensaje').val().trim();
    const reMail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    set('nombre',  nombre.length < 3 ? 'Ingresa tu nombre (mín. 3 caracteres).' : '');
    set('correo',  !reMail.test(correo) ? 'Ingresa un correo válido.' : '');
    set('mensaje', mensaje.length < 10 ? 'Tu mensaje es muy corto (mín. 10 caracteres).' : '');

    if (ok) {
      this.reset();
      toast('📨 ¡Gracias! Tu mensaje fue enviado. Te responderemos pronto.');
    }
  });

  /* ---------- 9b. Clima (reporteador con API OpenWeatherMap) ---------- */
  const CLIMA_API_KEY = '8d3c17dbaa1934549f95c9e4e87ef918';

  function pintarClima(d) {
    const desc = (d.weather && d.weather[0]) ? d.weather[0].description : '—';
    const icon = (d.weather && d.weather[0]) ? d.weather[0].icon : '01d';
    const pais = d.sys && d.sys.country ? ', ' + d.sys.country : '';
    $('#climaResultado').html(`
      <div class="clima-card">
        <img class="clima-card__icono" src="https://openweathermap.org/img/wn/${icon}@2x.png" alt="${desc}" />
        <h3 class="clima-card__ciudad">${d.name}${pais}</h3>
        <p class="clima-card__desc">${desc}</p>
        <div class="clima-card__temp">${Math.round(d.main.temp)}°C</div>
        <div class="clima-grid">
          <div class="clima-dato"><b>${d.main.humidity}%</b><span>💧 Humedad</span></div>
          <div class="clima-dato"><b>${d.wind.speed} m/s</b><span>💨 Viento</span></div>
          <div class="clima-dato"><b>${Math.round(d.main.feels_like)}°C</b><span>🌡️ Sensación</span></div>
        </div>
      </div>`);
  }

  function verClima() {
    const ciudad = ($('#climaCiudad').val() || 'Quito').trim();
    if (!ciudad) { $('#climaResultado').html('<p class="clima-estado error">⚠️ Escribe el nombre de una ciudad.</p>'); return; }
    $('#climaResultado').html('<p class="clima-estado">⏳ Consultando el clima...</p>');
    const url = 'https://api.openweathermap.org/data/2.5/weather?q=' +
      encodeURIComponent(ciudad) + '&units=metric&lang=es&appid=' + CLIMA_API_KEY;
    fetch(url)
      .then(r => r.json())
      .then(d => {
        if (String(d.cod) !== '200') { throw new Error(d.message || 'No disponible'); }
        pintarClima(d);
      })
      .catch(err => {
        $('#climaResultado').html('<p class="clima-estado error">⚠️ No se pudo obtener el clima: ' +
          err.message + '.</p>');
      });
  }

  $('#btnClima').on('click', verClima);
  $('#climaCiudad').on('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); verClima(); } });

  /* ---------- 9. Toast ---------- */
  let toastT;
  function toast(msg, ms = 3200) {
    clearTimeout(toastT);
    $('#toast').text(msg).addClass('is-show');
    toastT = setTimeout(() => $('#toast').removeClass('is-show'), ms);
  }

  /* ---------- init ---------- */
  pintarCarrito();
});
