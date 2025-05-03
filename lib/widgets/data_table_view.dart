import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DataTableView<T> extends StatefulWidget {
  final Map<String, double> headerData;
  final List<Map<String, dynamic>> data;
  final int? minItemsPerPage;
  final int? maxItemsPerPage;
  final bool showPagination;
  final double? minTableWidth;
  final double? maxTableWidth;
  final double rowHeight;
  final Color? headerBackgroundColor;
  final Color? rowBackgroundColor;
  final Color? alternateRowBackgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets cellPadding;
  final TextStyle? headerTextStyle;
  final TextStyle? cellTextStyle;

  const DataTableView({
    Key? key,
    required this.headerData,
    required this.data,
    this.minItemsPerPage = 5,
    this.maxItemsPerPage = 20,
    this.showPagination = true,
    this.minTableWidth,
    this.maxTableWidth,
    this.rowHeight = 48.0,
    this.headerBackgroundColor,
    this.rowBackgroundColor,
    this.alternateRowBackgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 8.0,
    this.cellPadding = const EdgeInsets.all(12.0),
    this.headerTextStyle,
    this.cellTextStyle,
  }) : super(key: key);

  @override
  State<DataTableView<T>> createState() => _DataTableViewState<T>();
}

class _DataTableViewState<T> extends State<DataTableView<T>> {
  late int currentPage;
  late int totalPages;
  late int itemsPerPage;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    _calculateItemsPerPage();
  }

  void _calculateItemsPerPage() {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - 200;

    final rowsCanFit = (availableHeight / widget.rowHeight).floor();

    itemsPerPage =
        isExpanded
            ? widget.maxItemsPerPage!
            : rowsCanFit.clamp(
              widget.minItemsPerPage!,
              widget.maxItemsPerPage!,
            );

    totalPages = (widget.data.length / itemsPerPage).ceil();
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      _calculateItemsPerPage();
      if (currentPage > totalPages) {
        currentPage = totalPages;
      }
    });
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() {
        currentPage = page;
      });
    }
  }

  List<Map<String, dynamic>> get _currentPageData {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return widget.data.sublist(
      startIndex,
      endIndex > widget.data.length ? widget.data.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    _calculateItemsPerPage();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final tableWidth =
            widget.maxTableWidth != null
                ? availableWidth.clamp(
                  widget.minTableWidth ?? 0,
                  widget.maxTableWidth!,
                )
                : availableWidth;

        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: tableWidth.toDouble(),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.borderColor ?? AppColors.border,
                    width: widget.borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            widget.headerBackgroundColor ??
                            AppColors.background,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(widget.borderRadius),
                          topRight: Radius.circular(widget.borderRadius),
                        ),
                      ),
                      child: Row(
                        children:
                            widget.headerData.entries.map((e) {
                              return Container(
                                width: e.value,
                                padding: widget.cellPadding,
                                child: Text(
                                  e.key,
                                  style:
                                      widget.headerTextStyle ??
                                      const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    ..._currentPageData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final rowData = entry.value;
                      return Container(
                        decoration: BoxDecoration(
                          color:
                              index % 2 == 0
                                  ? widget.rowBackgroundColor ?? Colors.white
                                  : widget.alternateRowBackgroundColor ??
                                      AppColors.background,
                          border: Border(
                            bottom: BorderSide(
                              color: widget.borderColor ?? AppColors.border,
                              width: widget.borderWidth,
                            ),
                          ),
                        ),
                        height: widget.rowHeight,
                        child: Row(
                          children:
                              widget.headerData.entries.map((e) {
                                return Container(
                                  width: e.value,
                                  padding: widget.cellPadding,
                                  child: Text(
                                    rowData[e.key]?.toString() ?? "-",
                                    style:
                                        widget.cellTextStyle ??
                                        const TextStyle(
                                          color: AppColors.textPrimary,
                                        ),
                                  ),
                                );
                              }).toList(),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            if (widget.showPagination &&
                widget.data.length > widget.minItemsPerPage!) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        currentPage > 1
                            ? () => _goToPage(currentPage - 1)
                            : null,
                    color: AppColors.primary,
                  ),
                  Text(
                    'Page $currentPage of $totalPages',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        currentPage < totalPages
                            ? () => _goToPage(currentPage + 1)
                            : null,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: _toggleExpanded,
                    icon: Icon(
                      isExpanded ? Icons.compress : Icons.expand,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      isExpanded ? 'Show Less' : 'Show More',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
