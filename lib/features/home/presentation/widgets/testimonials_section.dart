import 'package:flutter/material.dart';
import 'testimonial_model.dart';
import 'testimonials_data.dart';
import '../../../../core/theme/app_colors.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Khách hàng nói gì?',
              style: TextStyle(
                  fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kTestimonials.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = kTestimonials[index];
                return _TestimonialCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final Testimonial item;
  const _TestimonialCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.8; // show 80% width card
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(item.photo),
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(item.position,
                        style: TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              _Stars(rating: item.rating),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              item.content,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int rating;
  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          color: AppColors.warning,
          size: 18,
        );
      }),
    );
  }
}
