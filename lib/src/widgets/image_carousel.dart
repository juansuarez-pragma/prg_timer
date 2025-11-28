import 'package:flutter/material.dart';

/// Represents an image item in the carousel
class CarouselImageItem {
  /// The image provider (can be NetworkImage, AssetImage, FileImage, etc.)
  final ImageProvider? imageProvider;

  /// Whether this is an "add image" placeholder
  final bool isAddButton;

  /// Optional identifier for the image
  final String? id;

  const CarouselImageItem({
    this.imageProvider,
    this.isAddButton = false,
    this.id,
  });

  /// Creates an add button item
  const CarouselImageItem.addButton()
      : imageProvider = null,
        isAddButton = true,
        id = null;

  /// Creates an image item from a provider
  CarouselImageItem.fromProvider(ImageProvider provider, {this.id})
      : imageProvider = provider,
        isAddButton = false;
}

/// Image carousel widget with page indicators
class ImageCarousel extends StatefulWidget {
  /// List of images to display
  final List<CarouselImageItem> images;

  /// Callback when "Add Image" button is tapped
  final VoidCallback? onAddImage;

  /// Callback when an image is tapped
  final void Function(int index)? onImageTap;

  /// Callback when an image should be removed
  final void Function(int index)? onImageRemove;

  /// Background color of the carousel section
  final Color backgroundColor;

  /// Color of the active page indicator
  final Color activeIndicatorColor;

  /// Color of inactive page indicators
  final Color inactiveIndicatorColor;

  /// Border radius of image containers
  final double imageBorderRadius;

  /// Placeholder icon color
  final Color placeholderIconColor;

  /// Add button color
  final Color addButtonColor;

  /// Add button icon color
  final Color addButtonIconColor;

  /// "Add Image" button text
  final String addImageText;

  /// Maximum number of images allowed
  final int maxImages;

  /// Height of the carousel
  final double height;

  /// Whether to show remove buttons on images
  final bool showRemoveButtons;

  const ImageCarousel({
    super.key,
    required this.images,
    this.onAddImage,
    this.onImageTap,
    this.onImageRemove,
    this.backgroundColor = const Color(0xFFB3D4E8),
    this.activeIndicatorColor = const Color(0xFF1E3A5F),
    this.inactiveIndicatorColor = Colors.white,
    this.imageBorderRadius = 8.0,
    this.placeholderIconColor = const Color(0xFF9E9E9E),
    this.addButtonColor = Colors.white,
    this.addButtonIconColor = const Color(0xFF1E3A5F),
    this.addImageText = 'Add Image',
    this.maxImages = 10,
    this.height = 120,
    this.showRemoveButtons = true,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  // Number of items visible at once
  static const int _visibleItems = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<List<CarouselImageItem>> _getGroupedItems() {
    final allItems = <CarouselImageItem>[...widget.images];

    // Add "Add Image" button if under max images
    if (allItems.length < widget.maxImages && widget.onAddImage != null) {
      allItems.add(const CarouselImageItem.addButton());
    }

    // Group items into pages of _visibleItems
    final groups = <List<CarouselImageItem>>[];
    for (var i = 0; i < allItems.length; i += _visibleItems) {
      final end =
          (i + _visibleItems < allItems.length) ? i + _visibleItems : allItems.length;
      groups.add(allItems.sublist(i, end));
    }

    // Ensure at least one group with placeholders
    if (groups.isEmpty) {
      groups.add([const CarouselImageItem.addButton()]);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _getGroupedItems();
    final pageCount = groupedItems.length;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pageCount,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, pageIndex) {
                final items = groupedItems[pageIndex];
                return _buildCarouselPage(items, pageIndex);
              },
            ),
          ),
          // Page indicators
          if (pageCount > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pageCount, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? widget.activeIndicatorColor
                          : widget.inactiveIndicatorColor,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarouselPage(List<CarouselImageItem> items, int pageIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.asMap().entries.map((entry) {
          final itemIndex = pageIndex * _visibleItems + entry.key;
          final item = entry.value;

          if (item.isAddButton) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _AddImageButton(
                  onTap: widget.onAddImage,
                  text: widget.addImageText,
                  backgroundColor: widget.addButtonColor,
                  iconColor: widget.addButtonIconColor,
                  borderRadius: widget.imageBorderRadius,
                ),
              ),
            );
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _ImageTile(
                imageProvider: item.imageProvider,
                borderRadius: widget.imageBorderRadius,
                placeholderIconColor: widget.placeholderIconColor,
                onTap: widget.onImageTap != null
                    ? () => widget.onImageTap!(itemIndex)
                    : null,
                onRemove: widget.showRemoveButtons && widget.onImageRemove != null
                    ? () => widget.onImageRemove!(itemIndex)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Individual image tile in the carousel
class _ImageTile extends StatelessWidget {
  final ImageProvider? imageProvider;
  final double borderRadius;
  final Color placeholderIconColor;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _ImageTile({
    this.imageProvider,
    required this.borderRadius,
    required this.placeholderIconColor,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 2),
              child: imageProvider != null
                  ? Image(
                      image: imageProvider!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
          ),
          // Add icon overlay for placeholder
          if (imageProvider == null)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          // Remove button
          if (onRemove != null && imageProvider != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: Center(
        child: Icon(
          Icons.landscape,
          size: 32,
          color: placeholderIconColor,
        ),
      ),
    );
  }
}

/// Add image button widget
class _AddImageButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final Color backgroundColor;
  final Color iconColor;
  final double borderRadius;

  const _AddImageButton({
    this.onTap,
    required this.text,
    required this.backgroundColor,
    required this.iconColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
