import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/model/hotel.dart';

class HotelCard extends StatelessWidget {
  const HotelCard({
    super.key,
    required this.hotel,
    required this.onTap,
  });

  final Hotel hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasLogo = hotel.logoUrl != null && hotel.logoUrl!.trim().isNotEmpty;

    final starCount = hotel.categoriaEstrellas.clamp(0, 5);

    final stars = List<String>.filled(
      starCount,
      '★',
    ).join();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: hasLogo
                  ? CachedNetworkImage(
                      imageUrl: hotel.logoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return const _HotelPlaceholder();
                      },
                    )
                  : const _HotelPlaceholder(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stars.isEmpty ? 'Sin categoría' : stars,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hotel.estado,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        if (hotel.permiteMascotas)
                          const Icon(
                            Icons.pets,
                            size: 18,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelPlaceholder extends StatelessWidget {
  const _HotelPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(
        Icons.hotel,
        size: 56,
      ),
    );
  }
}
