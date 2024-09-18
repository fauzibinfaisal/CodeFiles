import 'package:flutter/material.dart';

class MyDropdownWidget extends StatefulWidget {
  final int menuCount; // Number of menu items
  final Widget Function(BuildContext, int) menuBuilder; // Menu item builder
  final Function(int)
      onMenuItemSelected; // Callback when a menu item is selected
  final IconData icon; // Customizable icon, default is expand_more
  final String? text; // Optional text next to the icon

  MyDropdownWidget({
    required this.menuCount,
    required this.menuBuilder,
    required this.onMenuItemSelected,
    this.icon = Icons.expand_more, // Default icon
    this.text, // Optional text
  });

  @override
  _MyDropdownWidgetState createState() => _MyDropdownWidgetState();
}

class _MyDropdownWidgetState extends State<MyDropdownWidget>
    with SingleTickerProviderStateMixin {
  bool _isDropdownVisible = false;
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showDropdown(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final dropdownHeight =
        widget.menuCount * 48.0; // Approx height of each item

    // Check available space
    bool showBelow =
        position.dy + renderBox.size.height + dropdownHeight <= screenHeight;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _hideDropdown,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Positioned(
            top: showBelow
                ? position.dy + renderBox.size.height
                : position.dy - dropdownHeight,
            left: position.dx,
            child: Material(
              elevation: 4.0,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 200.0, // Adjust max height if needed
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.menuCount,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            widget.onMenuItemSelected(index);
                            _hideDropdown();
                          },
                          child: widget.menuBuilder(context, index),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context)!.insert(_overlayEntry!);
    _animationController.forward(); // Start the animation
    setState(() {
      _isDropdownVisible = true;
    });
  }

  void _hideDropdown() {
    if (_isDropdownVisible) {
      _animationController.reverse().then((value) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        setState(() {
          _isDropdownVisible = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDropdown(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon, // Customizable icon
            size: 24.0,
          ),
          if (widget.text != null) // Display text if provided
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(widget.text!),
            ),
        ],
      ),
    );
  }
}


// Example Usage
// MyDropdownWidget(
//   menuCount: 3,
//   menuBuilder: (context, index) {
//     return ListTile(
//       title: Text('Option ${index + 1}'),
//     );
//   },
//   onMenuItemSelected: (selectedIndex) {
//     print('Selected item index: $selectedIndex');
//   },
//   icon: Icons.arrow_drop_down, // Custom icon (optional)
//   text: 'Select Option', // Optional text
// )
