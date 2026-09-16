import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_bloc.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_camera_controls.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MapCameraBloc>(),
      child: const Scaffold(
        body: Stack(
          children: [
            MapView(),
            Positioned(
              right: 16,
              bottom: 32,
              child: MapCameraControls(),
            ),
          ],
        ),
      ),
    );
  }
}
