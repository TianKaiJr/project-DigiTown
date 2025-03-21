import 'package:flutter/material.dart';
import 'package:super_admin_panel/_Transport_Module/transport_service_option_model.dart';

class TransportServiceRepository {
  List<TransportServiceOptionModel> getOptions() {
    return [
      TransportServiceOptionModel(
          id: 'taxi', title: "Taxi Service", icon: Icons.directions_car),
      TransportServiceOptionModel(
          id: 'routes', title: "Bus Route\n Service", icon: Icons.route),
    ];
  }
}
