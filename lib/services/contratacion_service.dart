import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ServiceInfo {
  ServiceInfo({
    required this.nombre,
    required this.precio,
  });

  final String nombre;
  final double precio;

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      nombre: json['nombre'] as String? ?? 'Servicio',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ContratacionResult {
  ContratacionResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class ContratacionService {
  Future<ServiceInfo?> getServiceInfo(int serviceId) async {
    // Intentamos con el endpoint singular; si falla, probamos con /servicios/{id}
    final endpoints = <Uri>[
      Uri.parse(ApiConfig.servicioPorId(serviceId)),
      Uri.parse('${ApiConfig.servicios}/$serviceId'),
    ];

    for (final url in endpoints) {
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final body = jsonDecode(utf8.decode(response.bodyBytes));
          if (body is Map<String, dynamic>) {
            return ServiceInfo.fromJson(body);
          }
        }
      } catch (_) {
        // seguimos al siguiente endpoint
      }
    }
    return null;
  }

  Future<ContratacionResult> contratar({
    required int userId,
    required int servicioId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    final url = Uri.parse(ApiConfig.contratarServicio);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'servicioId': servicioId,
          'fechaInicio': fechaInicio.toIso8601String(),
          'fechaFin': fechaFin.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ContratacionResult(
          success: true,
          message: 'Servicio contratado correctamente.',
        );
      }

      String message = 'No se pudo completar la contratación.';
      try {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (errorBody is Map<String, dynamic> &&
            errorBody['mensaje'] is String) {
          message = errorBody['mensaje'] as String;
        }
      } catch (_) {
        // Ignoramos errores de parseo y usamos mensaje por defecto
      }

      return ContratacionResult(success: false, message: message);
    } catch (e) {
      return ContratacionResult(
        success: false,
        message: 'Error de conexión. Inténtalo nuevamente.',
      );
    }
  }

  Future<ContratacionHistorial?> getHistorial(int userId) async {
    final url = Uri.parse(ApiConfig.historialContrataciones(userId));
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is Map<String, dynamic>) {
          return ContratacionHistorial.fromJson(body);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ContratacionResult> calificar({
    required int userId,
    required int servicioId,
    required int nota,
  }) async {
    final url = Uri.parse(ApiConfig.calificarServicio);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'servicioId': servicioId,
          'nota': nota,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ContratacionResult(
          success: true,
          message: 'Calificación enviada.',
        );
      }

      String message = 'No se pudo enviar la calificación.';
      try {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        if (errorBody is Map<String, dynamic> &&
            errorBody['mensaje'] is String) {
          message = errorBody['mensaje'] as String;
        }
      } catch (_) {}

      return ContratacionResult(success: false, message: message);
    } catch (_) {
      return ContratacionResult(
        success: false,
        message: 'Error de conexión. Inténtalo nuevamente.',
      );
    }
  }
}

class ContratoServicioInfo {
  ContratoServicioInfo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.usuarioNombre,
    required this.imagen,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String usuarioNombre;
  final String? imagen;

  factory ContratoServicioInfo.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? media = json['multimediaUrls'] as List<dynamic>?;
    String? firstImage;
    if (media != null && media.isNotEmpty) {
      final first = media.first;
      if (first is String && first.isNotEmpty) {
        firstImage = first;
      }
    }

    return ContratoServicioInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? 'Servicio',
      descripcion: json['descripcion'] as String? ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      usuarioNombre: json['usuarioNombre'] as String? ?? 'Proveedor',
      imagen: firstImage,
    );
  }
}

class ContratoItem {
  ContratoItem({
    required this.contratoId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.contraparteId,
    required this.contraparteNombre,
    required this.contraparteFoto,
    required this.contraparteRolEnTransaccion,
    required this.yaCalificado,
    required this.miNota,
    required this.servicio,
  });

  final int contratoId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int contraparteId;
  final String contraparteNombre;
  final String? contraparteFoto;
  final String contraparteRolEnTransaccion; // VENDEDOR o COMPRADOR
  final bool yaCalificado;
  final int? miNota;
  final ContratoServicioInfo servicio;

  factory ContratoItem.fromJson(Map<String, dynamic> json) {
    return ContratoItem(
      contratoId: (json['contratoId'] as num?)?.toInt() ?? 0,
      fechaInicio: DateTime.tryParse(json['fechaInicio'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      fechaFin: DateTime.tryParse(json['fechaFin'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      contraparteId: (json['contraparteId'] as num?)?.toInt() ?? 0,
      contraparteNombre: json['contraparteNombre'] as String? ?? 'Contraparte',
      contraparteFoto: json['contraparteFoto'] as String?,
      contraparteRolEnTransaccion:
          json['contraparteRolEnTransaccion'] as String? ?? '',
      yaCalificado: json['yaCalificado'] == true,
      miNota: (json['miNota'] as num?)?.toInt(),
      servicio: ContratoServicioInfo.fromJson(
          (json['servicio'] as Map<String, dynamic>? ?? {})),
    );
  }

  bool get finalizado => fechaFin.isBefore(DateTime.now());
}

class ContratacionHistorial {
  ContratacionHistorial({
    required this.compras,
    required this.ventas,
  });

  final List<ContratoItem> compras;
  final List<ContratoItem> ventas;

  factory ContratacionHistorial.fromJson(Map<String, dynamic> json) {
    final comprasJson = json['compras'] as List<dynamic>? ?? [];
    final ventasJson = json['ventas'] as List<dynamic>? ?? [];
    return ContratacionHistorial(
      compras: comprasJson
          .whereType<Map<String, dynamic>>()
          .map(ContratoItem.fromJson)
          .toList(),
      ventas: ventasJson
          .whereType<Map<String, dynamic>>()
          .map(ContratoItem.fromJson)
          .toList(),
    );
  }
}
