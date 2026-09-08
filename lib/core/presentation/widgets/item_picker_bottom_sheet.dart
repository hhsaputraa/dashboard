import 'package:flutter/material.dart';

class ItemPickerBottomSheet<T, K> extends StatefulWidget {
  final String title;
  final String unitLabel;
  final String applySuffix;
  final String emptyMessage;
  final String searchHint;
  final String limitExceededMessage;
  final int maxSelect;
  final Color activeColor;
  final List<T> items;
  final Set<K> initiallySelected;
  final K Function(T item) getId;
  final String Function(T item) getLabel;
  final String Function(T item)? getSubtitle;
  final bool Function(T item, String query) matchesQuery;
  final String? quickSelectLabel;
  final Color? quickSelectColor;
  final Set<K>? Function()? onQuickSelect;
  final ValueChanged<Set<K>> onApply;

  const ItemPickerBottomSheet({
    super.key,
    required this.title,
    required this.unitLabel,
    required this.applySuffix,
    required this.emptyMessage,
    required this.searchHint,
    required this.limitExceededMessage,
    required this.maxSelect,
    required this.activeColor,
    required this.items,
    required this.initiallySelected,
    required this.getId,
    required this.getLabel,
    this.getSubtitle,
    required this.matchesQuery,
    this.quickSelectLabel,
    this.quickSelectColor,
    this.onQuickSelect,
    required this.onApply,
  });

  @override
  State<ItemPickerBottomSheet<T, K>> createState() =>
      _ItemPickerBottomSheetState<T, K>();
}

class _ItemPickerBottomSheetState<T, K>
    extends State<ItemPickerBottomSheet<T, K>> {
  late final Set<K> _tempSelected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = Set<K>.from(widget.initiallySelected);
  }

  void _handleQuickSelect() {
    if (widget.onQuickSelect != null) {
      final selected = widget.onQuickSelect!();
      if (selected != null) {
        setState(() {
          _tempSelected
            ..clear()
            ..addAll(selected);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = widget.items.where((item) {
      if (query.isEmpty) return true;
      return widget.matchesQuery(item, query);
    }).toList();

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Maksimal ${widget.maxSelect} ${widget.unitLabel} (${_tempSelected.length}/${widget.maxSelect} dipilih)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Quick Selection
              if (widget.quickSelectLabel != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: _handleQuickSelect,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: (widget.quickSelectColor ?? widget.activeColor)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.quickSelectColor != null
                                ? Icons.bolt_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 14,
                            color:
                                widget.quickSelectColor ?? widget.activeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.quickSelectLabel!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  widget.quickSelectColor ?? widget.activeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF0F172A),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Daftar Checkbox
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                ),
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            widget.emptyMessage,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, idx) {
                          final item = filtered[idx];
                          final id = widget.getId(item);
                          final isChecked = _tempSelected.contains(id);
                          final canCheckMore =
                              _tempSelected.length < widget.maxSelect;

                          return CheckboxListTile(
                            value: isChecked,
                            activeColor: widget.activeColor,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            title: Text(
                              widget.getLabel(item),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: widget.getSubtitle != null
                                ? Text(
                                    widget.getSubtitle!(item),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  )
                                : null,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  if (canCheckMore) {
                                    _tempSelected.add(id);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          widget.limitExceededMessage,
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } else {
                                  _tempSelected.remove(id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),

              // Footer Buttons: Batal & Terapkan
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_tempSelected);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Terapkan (${_tempSelected.length} ${widget.applySuffix})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
