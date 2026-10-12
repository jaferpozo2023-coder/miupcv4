part of '../controllers.dart';

class ServiciosController extends GetxController {
  RxBool peticionServerState = false.obs;
  int _peticionesActivas = 0;
  final RxInt selectedIndex = (-1).obs;
  final RxInt idServicioSeleccionado = 0.obs;

  final LocalStoreImpl _localStoreImpl = Get.find<LocalStoreImpl>();

  final CheckInternetConnection internetChecker = CheckInternetConnection();
  late StreamSubscription connectionSubscription;

  final Rx<ConnectionStatus> status = ConnectionStatus.online.obs;
  final ServiciosRepository _apiServiciosRepository =
      Get.find<ServiciosRepository>();
  Rx<Servicio> datosServicios = Servicio(
    descripcion: '',
    descTiposervicio: '',
    idUpcServicio: 0,
    imgBase64: '',
    resumen: '',
    urlImagen: '',
  ).obs;
  final pulsado = false.obs;
  RxList<Servicio> listaServicios = <Servicio>[].obs;
  final RxString errorCargaServicios = ''.obs;
  final ItemsRepository _apiItemsRepository = Get.find<ItemsRepository>();
  Rx<Item> datosItemServicios = Item(descripcion: '', idUpcServitems: 0).obs;
  RxList<Item> listaItemsServicios = <Item>[].obs;
  RxList<ItemOffLine> listaItemsServiciosTodos = <ItemOffLine>[].obs;
  String detalle = 'RECUERDE LO SIGUIENTE';
  RxList<String> listaDetalleItemsServicios = <String>[].obs;
  int idGenPersona = 0;
  var datosServicio = Get.parameters;
  String imagenModulo = "";
  String nombreModulo = "";
  String fecha = "";
  String estadoConex = "";
  int id = 0;

  void _iniciarPeticion() {
    _peticionesActivas++;
    peticionServerState.value = true;
  }

  void _finalizarPeticion() {
    if (_peticionesActivas > 0) _peticionesActivas--;
    peticionServerState.value = _peticionesActivas > 0;
  }

  @override
  void onInit() {
    super.onInit();
    cargarDatosLista();
    cargarDatosListaItemsOffline();
    connectionStatusController();
  }

  @override
  void onReady() {
    // TODO: Donde la vista ya se presento
    _init();
  }

  _init() async {
    print(Get.deviceLocale.toString());
  }

  @override
  void onClose() {
    connectionSubscription.cancel();
    internetChecker.close();
    super.onClose();
  }

  void connectionStatusController() {
    connectionSubscription = internetChecker.internetStatus().listen((
      newStatus,
    ) {
      status.value = newStatus;
    });
  }

  verificaTConexion() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        estadoConex = 'S';
      } else {
        if (id == 1) {
          listaServicios.value = await _localStoreImpl.getListServiciosPoli();
        }
        if (id == 2) {
          listaServicios.value = await _localStoreImpl.getListServicios();
        }
        listaItemsServiciosTodos.value = await _localStoreImpl.getListItems();
      }
    } on SocketException catch (_) {
      if (id == 1) {
        listaServicios.value = await _localStoreImpl.getListServiciosPoli();
      }
      if (id == 2) {
        listaServicios.value = await _localStoreImpl.getListServicios();
      }
      listaItemsServiciosTodos.value = await _localStoreImpl.getListItems();
      estadoConex = 'N';
    }
  }

  Future<void> cargarDatosLista() async {
    _iniciarPeticion();
    try {
      final idRecibido = int.tryParse(datosServicio['id']?.toString() ?? '');
      if (idRecibido == null || idRecibido < 1 || idRecibido > 4) {
        throw StateError(
          'La ruta no proporcionó un identificador de servicio válido.',
        );
      }

      id = idRecibido;
      imagenModulo = datosServicio['imagen']?.toString() ?? '';
      nombreModulo = datosServicio['nombreModulo']?.toString() ?? '';
      fecha = 'Hoy es ${UtilidadesUtil.getFechaActual}';
      errorCargaServicios.value = '';

      idGenPersona = await _localStoreImpl.getIdUser();
      var servicios = await _apiServiciosRepository.buscaListaServicios(id);

      if (servicios.isEmpty) {
        servicios = await _cargarServiciosLocales();
      }
      listaServicios.assignAll(servicios);

      if (listaServicios.isEmpty) {
        errorCargaServicios.value =
            'No hay información disponible para este servicio.';
        return;
      }

      if (listaServicios[0].idUpcServicio == 2) {
        detalle = 'COMO ACCEDER A ESTE SERVICIO';
      }

      if (id == 1) {
        await _localStoreImpl.setDatosListaServiciosPoli(
          listServiciosPoli: listaServicios,
        );
      } else if (id == 2) {
        await _localStoreImpl.setDatosListaServicios(
          listServicios: listaServicios,
        );
      }
    } on ServerException catch (error) {
      debugPrint('No se pudieron cargar los servicios: ${error.cause}');
      final serviciosLocales = await _cargarServiciosLocales();
      listaServicios.assignAll(serviciosLocales);
      if (listaServicios.isEmpty) {
        errorCargaServicios.value = 'No se pudo cargar la información del servicio. Comprueba tu conexión e inténtalo de nuevo.';
      }
    } catch (error, stackTrace) {
      debugPrint('Error inesperado al cargar servicios: $error\n$stackTrace');
      errorCargaServicios.value =
          'No se pudo cargar la información del servicio. Inténtalo de nuevo.';
    } finally {
      _finalizarPeticion();
    }
  }

  Future<List<Servicio>> _cargarServiciosLocales() async {
    if (id == 1) {
      return _localStoreImpl.getListServiciosPoli();
    }
    if (id == 2) {
      return _localStoreImpl.getListServicios();
    }
    return <Servicio>[];
  }

  cargarDatosDetalleLista(int id) async {
    _iniciarPeticion();
    try {
      listaItemsServicios.clear();
      listaItemsServicios.value = await _apiItemsRepository.buscaDatosItem(id);
    } on ServerException catch (e) {
      DialogosAwesome.getError(descripcion: e.cause);
    } finally {
      _finalizarPeticion();
    }
  }

  cargarDatosListaItemsOffline() async {
    _iniciarPeticion();
    try {
      listaItemsServiciosTodos.clear();

      listaItemsServiciosTodos.value = await _apiItemsRepository
          .buscaDatosItemsOffline();
      if (listaItemsServiciosTodos.isEmpty) {
        listaItemsServiciosTodos.value = await _localStoreImpl.getListItems();
        return;
      }
      await _localStoreImpl.setDatosListaItems(
        listItems: listaItemsServiciosTodos,
      );
    } on ServerException {
      var list = await _localStoreImpl.getListItems();
      listaItemsServiciosTodos.value = list;
    } finally {
      _finalizarPeticion();
    }
  }

  cargarDatosDetalleListaOffLine(int id) async {
    _iniciarPeticion();
    try {
      listaItemsServicios.clear();
      listaItemsServiciosTodos.clear();
      listaItemsServiciosTodos.value = await _localStoreImpl.getListItems();
      for (var i = 0; i < listaItemsServiciosTodos.length; i++) {
        if (listaItemsServiciosTodos[i].idUpcServicio == id) {
          listaItemsServicios.add(
            Item(
              descripcion: listaItemsServiciosTodos[i].descripcion,
              idUpcServitems: listaItemsServiciosTodos[i].idUpcServitems,
            ),
          );
        }
      }
    } on ServerException {
      rethrow;
    } finally {
      _finalizarPeticion();
    }
  }
}
