import 'package:flutter/material.dart';
import 'dart:async';
import '../models/deal_model.dart';

class DealOfDayCard extends StatefulWidget {
  final DealModel deal;
  final VoidCallback onTap;

  const DealOfDayCard({super.key, required this.deal, required this.onTap});

  @override
  State<DealOfDayCard> createState() => _DealOfDayCardState();
}

class _DealOfDayCardState extends State<DealOfDayCard> {
  late Timer _timer;
  late String _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.deal.remainingTime;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        setState(() {
          _remainingTime = widget.deal.remainingTime;
          if (_remainingTime == 'Expired') {
            _timer.cancel();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.white;
    final product = widget.deal.product;
    final originalPrice = product.price;
    final discountedPrice = widget.deal.discountedPrice;
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust layout based on screen width
        final isNarrow = constraints.maxWidth < 350;
        final isMedium = constraints.maxWidth >= 350 && constraints.maxWidth < 500;
        final isWide = constraints.maxWidth >= 500;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              splashColor: Colors.white.withAlpha(51),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 160,
                  maxHeight: 250,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.deal.backgroundColor,
                      widget.deal.backgroundColor.withRed(
                        (widget.deal.backgroundColor.red - 40).clamp(0, 255),
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -20,
                      top: -20,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withAlpha(26),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white.withAlpha(13),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Responsive row or column based on width
                          isNarrow 
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildDealContent(
                                  textColor, 
                                  product, 
                                  widget.deal, 
                                  discountedPrice, 
                                  originalPrice,
                                  isNarrow: true,
                                ),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: _buildDealContent(
                                        textColor, 
                                        product, 
                                        widget.deal, 
                                        discountedPrice, 
                                        originalPrice,
                                      ),
                                    ),
                                  ),
                                  // Right side - Product image
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: _buildProductImage(product),
                                    ),
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDealContent(
    Color textColor, 
    dynamic product, 
    dynamic deal, 
    double discountedPrice, 
    double originalPrice, 
    {bool isNarrow = false}
  ) {
    return [
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          deal.dealTitle,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: isNarrow ? 10 : 12,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        product.name,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: isNarrow ? 16 : 20,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4),
      Text(
        deal.dealDescription,
        style: TextStyle(
          color: textColor.withAlpha(230),
          fontSize: isNarrow ? 12 : 14,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 8),
      // Price
      Row(
        children: [
          Text(
            '\$${discountedPrice.toStringAsFixed(2)}',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: isNarrow ? 16 : 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${originalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              color: textColor.withAlpha(179),
              fontWeight: FontWeight.normal,
              fontSize: isNarrow ? 14 : 16,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      // Timer
      Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: textColor.withAlpha(230),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Ends in: $_remainingTime',
            style: TextStyle(
              color: textColor.withAlpha(230),
              fontWeight: FontWeight.w500,
              fontSize: isNarrow ? 12 : 14,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildProductImage(dynamic product) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(product.imageUrl),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
 