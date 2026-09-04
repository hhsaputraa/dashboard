import 'package:get/get.dart';
import 'package:dashboard/feature/home/model/interest_record.dart';
import '../model/branch_product_comparison_helper.dart';

enum ComparisonViewMode { barTotal, lineMonthly }

/// Controller untuk mengelola state filter perbandingan cabang vs produk,
/// mode tampilan (bar vs line), dan kalkulasi matrix serial data.
class BranchProductComparisonController extends GetxController {
  final Rx<ComparisonViewMode> viewMode = ComparisonViewMode.barTotal.obs;

  final RxSet<int> selectedBranchIds = <int>{}.obs;
  final RxSet<String> selectedProducts = <String>{}.obs;
  final RxnInt focusedBranchIdForLine = RxnInt();
  final RxnDouble touchedBarY = RxnDouble();

  final RxList<BranchInfo> availableBranches = <BranchInfo>[].obs;
  final RxList<ProductInfo> availableProducts = <ProductInfo>[].obs;
  final RxList<BranchInfo> selectedBranchesList = <BranchInfo>[].obs;
  final RxList<ProductInfo> selectedProductsList = <ProductInfo>[].obs;
  final RxMap<int, Map<String, BranchProductSeries>> seriesMap =
      <int, Map<String, BranchProductSeries>>{}.obs;

  List<InterestRecord> _currentRecords = const [];

  void updateRecords(List<InterestRecord> records) {
    _currentRecords = records;
    selectedBranchIds.clear();
    selectedProducts.clear();
    focusedBranchIdForLine.value = null;
    touchedBarY.value = null;
    _updateAvailableBranches();
    _updateAvailableProducts();
    _recomputeSeries();
  }

  void _updateAvailableBranches() {
    final list = BranchProductComparisonHelper.getAvailableBranches(_currentRecords);
    availableBranches.assignAll(list);
    _syncSelectedBranchesList();
  }

  void _updateAvailableProducts() {
    List<InterestRecord> filtered = _currentRecords;
    if (selectedBranchIds.isNotEmpty) {
      filtered = _currentRecords
          .where((r) => selectedBranchIds.contains(r.idKantor))
          .toList();
    }
    final list = BranchProductComparisonHelper.getAvailableProducts(filtered);
    availableProducts.assignAll(list);
    _syncSelectedProductsList();
  }

  void _syncSelectedBranchesList() {
    selectedBranchesList.assignAll(
      availableBranches.where((b) => selectedBranchIds.contains(b.idKantor)),
    );
  }

  void _syncSelectedProductsList() {
    selectedProductsList.assignAll(
      availableProducts.where((p) => selectedProducts.contains(p.name)),
    );
  }

  void _recomputeSeries() {
    final computed = BranchProductComparisonHelper.buildSeriesMap(
      records: _currentRecords,
      selectedBranchIds: selectedBranchIds,
      selectedProducts: selectedProducts,
    );
    seriesMap.assignAll(computed);
  }

  void toggleBranch(int branchId) {
    if (selectedBranchIds.contains(branchId)) {
      selectedBranchIds.remove(branchId);
    } else {
      if (selectedBranchIds.length >= 3) {
        selectedBranchIds.remove(selectedBranchIds.first);
      }
      selectedBranchIds.add(branchId);
    }

    if (focusedBranchIdForLine.value != null &&
        !selectedBranchIds.contains(focusedBranchIdForLine.value)) {
      focusedBranchIdForLine.value = null;
    }

    _updateAvailableProducts();
    selectedProducts.removeWhere((p) => !availableProducts.any((ap) => ap.name == p));

    _syncSelectedBranchesList();
    _syncSelectedProductsList();
    _recomputeSeries();
  }

  void toggleProduct(String productName) {
    if (selectedProducts.contains(productName)) {
      selectedProducts.remove(productName);
    } else {
      if (selectedProducts.length >= 3) {
        selectedProducts.remove(selectedProducts.first);
      }
      selectedProducts.add(productName);
    }
    _syncSelectedProductsList();
    _recomputeSeries();
  }

  void setViewMode(ComparisonViewMode mode) {
    viewMode.value = mode;
  }

  void setFocusedBranchForLine(int? branchId) {
    focusedBranchIdForLine.value = branchId;
  }

  void setTouchedBarY(double? y) {
    touchedBarY.value = y;
  }
}
