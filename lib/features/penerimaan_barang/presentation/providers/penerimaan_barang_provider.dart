import 'package:bbs_gudang/data/models/penerimaan_barang/available_po_model.dart';
import 'package:bbs_gudang/data/models/penerimaan_barang/penerimaan_barang_detail.dart';
import 'package:bbs_gudang/data/models/penerimaan_barang/penerimaan_barang_model.dart';
import 'package:bbs_gudang/data/models/purchase_request/purchase_request_model.dart';
import 'package:bbs_gudang/data/services/penerimaan_barang/penerimaan_barang_repository.dart';
import 'package:bbs_gudang/data/services/purchase_request/purchase_request_repository.dart';
import 'package:flutter/material.dart';

class PenerimaanBarangProvider extends ChangeNotifier {
  final PenerimaanBarangRepository _repository = PenerimaanBarangRepository();
  final PurchaseRequestRepository _purchaseRequestRepository =
      PurchaseRequestRepository();

  bool _isLoading = false;
  bool _isLoadingPO = false;
  String? _errorMessage;
  List<PenerimaanBarangModel> _listPenerimaanBarang = [];
  PenerimaanBarangModel? _data;

  List<PurchaseRequestModel> _listPurchaseRequest = [];
  List<PurchaseRequestModel> get listPurchaseRequest => _listPurchaseRequest;

  List<AvailablePoModel> _listPO = [];
  List<AvailablePoModel> get listPO => _listPO;

  int _page = 1;
  int _paginate = 10;

  bool _hasMore = true;

  // ============================
  // GETTER
  // ============================

  bool get isLoading => _isLoading;
  bool get isLoadingPO => _isLoadingPO;
  String? get errorMessage => _errorMessage;
  List<PenerimaanBarangModel> get listPenerimaanBarang => _listPenerimaanBarang;
  PenerimaanBarangModel? get data => _data;
  bool get hasMore => _hasMore;

  int get page => _page;
  int get paginate => _paginate;

  String? prCode;
  String? itemGroup;
  String? supplierName;

  bool isLoadingPoDetail = false;
  bool isLoadingPbDetail = false;

  List<Map<String, dynamic>> pbDetails = [];
  AvailablePoModel? selectedPO;

  List<Map<String, dynamic>> selectedItems = [];

  DateTime? invoiceDate;
  String? supplierSjNo;
  String? supplierInvoiceNo;
  String? policeNo;
  String? driverName;
  String? headerNote;

  bool isCheckingPO = false;
  String? checkMessage;
  bool? canPost;

  PenerimaanBarangModel? result;

  String? unitBusinessId;
  String? unitBusinessName;
  String? warehouseId;
  String? warehouseName;
  String? codePenerimaanBarang;

  String? pbCode;
  bool isLoadingPbCode = false;
  String? pbCodeError;

  Future<void> generateNoPB({
    required String token,
    required String unitBusinessId,
  }) async {
    try {
      isLoadingPbCode = true;
      pbCodeError = null;
      notifyListeners();

      final code = await _repository.generateNoPB(
        token: token,
        unitBusinessId: unitBusinessId,
      );

      pbCode = code;
    } catch (e) {
      debugPrint('ERROR GENERATE NO PB: $e');
      pbCode = null;
      pbCodeError = e.toString();
    } finally {
      isLoadingPbCode = false;
      notifyListeners();
    }
  }

  void resetPbCode() {
    pbCode = null;
    pbCodeError = null;
    notifyListeners();
  }

  void setUnitBusinessId(String? id) {
    unitBusinessId = id;
    notifyListeners();
  }

  void setUnitBusinessName(String? name) {
    unitBusinessName = name;
    notifyListeners();
  }

  void setWarehouseId(String? id) {
    warehouseId = id;
    notifyListeners();
  }

  void setWarehouseName(String? name) {
    warehouseName = name;
    notifyListeners();
  }

  void setInvoiceDate(DateTime value) {
    invoiceDate = value;
    notifyListeners();
  }

  void setSupplierSjNo(String value) {
    supplierSjNo = value;
  }

  void setSupplierInvoiceNo(String value) {
    supplierInvoiceNo = value;
  }

  void setPoliceNo(String value) {
    policeNo = value;
  }

  void setDriverName(String value) {
    driverName = value;
  }

  void setHeaderNote(String value) {
    headerNote = value;
  }

  void setSelectedItems(List<Map<String, dynamic>> items) {
    // 1. Simpan nilai qty yang sudah diinput user sebelumnya ke dalam Map (Key: ID, Value: Qty)
    final existingQtys = {
      for (var item in selectedItems)
        (item["item_id"] ?? item["id"]): item["qty_receipt"],
    };

    // 2. Map items baru sambil mengecek apakah item tersebut sudah punya qty lama
    selectedItems = items.map((item) {
      final itemId = item["item_id"] ?? item["id"];

      // Jika item sudah ada di list sebelumnya, pakai Qty lama.
      // Jika benar-benar baru, pakai default 1 (atau item["qty_receipt"] jika ada)
      int initialQty = existingQtys[itemId] ?? item["qty_receipt"] ?? 1;

      return {
        "purchase_order_d_id": item["purchase_order_d_id"] ?? item["id"],
        "item_id": itemId,
        "item_code": item["code"] ?? item["item_code"] ?? "-",
        "item_name": item["name"] ?? item["item_name"] ?? "-",
        "qty_order": item["qty"] ?? item["qty_order"] ?? 0,
        "qty_receipt": initialQty,
      };
    }).toList();

    notifyListeners();
  }

  void removeItem(int index) {
    selectedItems.removeAt(index);
    notifyListeners();
  }

  void increaseQty(int index) {
    selectedItems[index]["qty_receipt"]++;
    notifyListeners();
  }

  void decreaseQty(int index) {
    if (selectedItems[index]["qty_receipt"] > 1) {
      selectedItems[index]["qty_receipt"]--;
      notifyListeners();
    }
  }

  void setSelectedPO(AvailablePoModel po) {
    selectedPO = po;
    notifyListeners();
  }

  void setCodePenerimaanBarang(String? code) {
    codePenerimaanBarang = code;
    notifyListeners();
  }

  void resetPoAutoFill() {
    prCode = null;
    itemGroup = null;
    supplierName = null;
    notifyListeners();
  }

  Future<void> checkStatusPO({required String token}) async {
    if (selectedPO == null) {
      checkMessage = "PO belum dipilih";
      canPost = false;
      notifyListeners();
      return;
    }

    if (selectedItems.isEmpty) {
      checkMessage = "Item belum dipilih";
      canPost = false;
      notifyListeners();
      return;
    }

    isCheckingPO = true;
    notifyListeners();

    try {
      final payload = {
        "purchase_order_id": selectedPO, // pastikan ini ID, bukan object
        "items": selectedItems
            .map(
              (e) => {
                "purchase_order_d_id": e["purchase_order_d_id"],
                "qty_receipt": e["qty_receipt"],
              },
            )
            .toList(),
      };

      final res = await _repository.checkStatusPurchaseOrder(
        token: token,
        payload: payload,
      );

      canPost = res["can_post"];
      checkMessage = res["message"];
    } catch (e) {
      canPost = false;
      checkMessage = e.toString();
    }

    isCheckingPO = false;
    notifyListeners();
  }

  Future<void> loadAvailablePbDetails({
    required String token,
    required String poId,
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      pbDetails.clear();
    }

    isLoadingPbDetail = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _repository.fetchAvailablePBDetails(
        token: token,
        purchaseOrderId: poId,
        page: page,
        limit: limit,
      );

      final List list = res['data'] ?? [];

      if (list.isEmpty) {
        _hasMore = false;
      } else {
        pbDetails.addAll(List<Map<String, dynamic>>.from(list));
        _page++;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('loadAvailablePbDetails error: $e');
    } finally {
      isLoadingPbDetail = false;
      notifyListeners();
    }
  }

  String? itemTypeId;
  String? itemGroupCoaId;
  String? itemGroupCoa;

  void setItemTypeId(String? val) {
    itemTypeId = val;
    notifyListeners();
  }

  void setItemGroupCoaId(String? val) {
    itemGroupCoaId = val;
    notifyListeners();
  }

  void setItemGroupCoa({required String? id, required String? code}) {
    itemGroupCoaId = id;
    itemGroupCoa = code;
    notifyListeners();
  }

  String? supplierId;
  String? purchaseRequestId;
  String? purchaseOrderId;

  void setPurchaseOrderId(String? id) {
    purchaseOrderId = id;
    notifyListeners();
  }

  Future<void> loadPoDetail({
    required String token,
    required String poId,
  }) async {
    try {
      isLoadingPoDetail = true;
      notifyListeners();

      final result = await _repository.fetchPoDetail(token: token, poId: poId);

      // ================= HEADER =================
      supplierId = result['supplier_id'];
      purchaseRequestId = result['purchase_request_id'];
      warehouseId = result['warehouse_id'];

      supplierName = result['supplier_name'];
      prCode = result['purchase_request_code'];
      itemGroup = result['item_group_coa'];
      itemGroupCoaId = result['item_group_coa_id'];

      debugPrint("supplierId: $supplierId");
      debugPrint("purchaseRequestId: $purchaseRequestId");
      debugPrint("warehouseId: $warehouseId");
      debugPrint("warehouse_name: $warehouseName");
      debugPrint("PB: $pbCode");
      debugPrint("supplierName: $supplierName");
      debugPrint("prCode: $prCode");
      debugPrint("itemGroup: $itemGroup");
      debugPrint("itemGroupCoaId: $itemGroupCoaId");

      // ================= ITEM DETAIL PO =================
      final List poDetails = result['items'] ?? [];

      selectedItems = poDetails.map((d) {
        debugPrint("MAPPING ITEM PO DETAIL:");
        debugPrint("PO DETAIL ID: ${d['id']}");
        debugPrint("ITEM NAME: ${d['item_name']}");
        debugPrint("QTY ORDER: ${d['qty']}");

        return {
          // ⚠️ WAJIB — backend pakai ini
          "purchase_order_d_id": d['id'],

          // info item
          "item_id": d['item_id'],
          "code": d['item_code'],
          "name": d['item_name'],

          // qty
          "qty_order": d['qty'],
          "qty_receipt": 0, // default input user
        };
      }).toList();

      debugPrint("===== SELECTED ITEMS AFTER LOAD =====");
      debugPrint(selectedItems.toString());
    } catch (e) {
      debugPrint("ERROR loadPoDetail: $e");
    } finally {
      isLoadingPoDetail = false;
      notifyListeners();
    }
  }

  void resetPr() {
    prCode = null;
    itemGroup = null;
  }

  Future<void> fetchPenerimaanBarang({
    required String token,
    bool isRefresh = false,
    bool loadMore = false,
  }) async {
    // Jika refresh, abaikan status _isLoading agar tidak kena return
    if (_isLoading && !isRefresh) return;
    if (!isRefresh && !_hasMore) return;

    if (isRefresh) {
      _page = 1;
      _hasMore = true;
      // Jangan clear di sini jika ingin UX yang mulus (biarkan list lama tetap ada sampai data baru datang)
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchPenerimaanBarang(
        token: token,
        page: _page,
        paginate: _paginate,
      );

      final List<PenerimaanBarangModel> newData =
          List<PenerimaanBarangModel>.from(result['data']);

      final pagination = result['pagination'];
      final int totalPages =
          int.tryParse(pagination['totalPages']?.toString() ?? '1') ?? 1;

      if (isRefresh) {
        // Ganti total list dengan data terbaru dari page 1
        _listPenerimaanBarang = newData;
      } else {
        _listPenerimaanBarang.addAll(newData);
      }

      // Update status pagination
      if (_page >= totalPages || newData.isEmpty) {
        _hasMore = false;
      } else {
        _hasMore = true;
        _page++;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _fillFormFromDetail(PenerimaanBarangModel model) {
    // HEADER
    pbCode = model.code;
    supplierId = model.supplierId;
    supplierName = model.supplierName;

    purchaseOrderId = model.purchaseOrder?.id;
    purchaseRequestId = model.purchaseRequestId;

    unitBusinessId = model.unitBussinessId;
    unitBusinessName = model.unitBussinessName;

    warehouseId = model.warehouseId;
    warehouseName = model.warehouseName;

    itemGroupCoaId = model.itemGroupCoaId;
    itemGroup = model.itemGroupCoa;

    policeNo = model.policeNumber;
    driverName = model.driverName;
    supplierSjNo = model.noSjSupplier;
    headerNote = model.notes;

    invoiceDate = model.date != null ? model.date : null;

    // DETAIL ITEM
    selectedItems = model.details.map((e) {
      return {
        "id": e.id, // 🔥 penting buat update
        "purchase_order_d_id": e.poDetail?.id ?? '',
        "purchase_request_d_id": e.prDetail?.id ?? '',
        "item_id": e.item?.id ?? '',
        "item_code": e.item?.code ?? '',
        "item_name": e.item?.name ?? '',
        "item_type": e.item?.itemTypeName ?? '',
        "qty_received": e.qtyReceived,
        "qty_receipt": e.qtyReceipt,
        "qty_closing": e.qtyReceipt ?? 0,
        // "item_uom_id": e.,
        // "item_uom": e.itemUom,
        // "price": e.price,
        // "item_price": e.itemPrice,
        // "total": e.total,
        // "coa_inventory_id": e.coaInventoryId,
        // "coa_unbilled_id": e.coaUnbilledId,
        // "coa_purchase_return_id": e.coaPurchaseReturnId,
        "notes": e.notes ?? "",
      };
    }).toList();
  }

  Future<void> fetchDetail({required String token, required String id}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchDetailPenerimaanBarang(
        token: token,
        id: id,
      );

      _data = result;

      _fillFormFromDetail(result);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PurchaseRequestModel>> fetchListPR({
    required String token,
  }) async {
    try {
      _listPurchaseRequest = await _purchaseRequestRepository.fetchListPR(
        token: token,
      );
      return _listPurchaseRequest;
    } catch (e) {
      throw Exception('Gagal mengambil data Purchase Request: $e');
    }
  }

  Future<void> fetchListPO({required String token}) async {
    _isLoadingPO = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _listPO = await _repository.fetchListPO(token: token);
    } catch (e) {
      _errorMessage = e.toString(); // ✅ SIMPAN ERROR
      _listPO = [];
    } finally {
      _isLoadingPO = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> checkBeforeSubmit({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    try {
      return await _repository.checkStatusPurchaseOrder(
        token: token,
        payload: payload,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitPenerimaanBarang({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    try {
      // 🔹 3. Submit stock opname
      result = await _repository.createPenerimaanBarang(
        token: token,
        payload: payload,
      );
    } catch (e) {
      rethrow;
    }
  }

  void hydrateFromDetailPB(PenerimaanBarangModel model) {
    // PO
    if (model.purchaseOrder != null) {
      selectedPO = AvailablePoModel(
        id: model.purchaseOrder!.id,
        code: model.purchaseOrder!.code ?? '-',
      );

      purchaseOrderId = model.purchaseOrder!.id;
    }

    // Field lain
    supplierName = model.supplierName;
    prCode = model.purchaseOrder?.code ?? '';
    itemGroup = model.itemGroupCoa;

    notifyListeners();
  }

  Future<void> postPenerimaanBarang({
    required String token,
    required String pbId,
    required Map<String, dynamic> payload,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final data = await _repository.updatePBWithDetails(
        token: token,
        pbId: pbId,
        payload: payload,
      );

      _data = PenerimaanBarangModel.fromJson(data);
      await fetchDetail(token: token, id: pbId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  Future<void> insertInventoryItems({
    required String token,
    required String pbId,
    required String pbCode,
    required String warehouseId,
    required List<Map<String, dynamic>> items,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      for (final item in items) {
        final payload = {
          "item_id": item["item_id"],
          "warehouse_id": warehouseId,
          "quantity": item["qty_received"] ?? item["qty_receipt"],
          "uom": item["item_uom"],
          "transactionTypeName": "PURCHASE_RECEIPT",
          "unitCost": item["price"],
          "reference_id": pbId,
          "reference_source": "t_penerimaan_barang",
          "batchNumber": pbCode,
        };

        debugPrint("📦 INSERT INVENTORY PAYLOAD");
        debugPrint(payload.toString());

        await _repository.insertInventory(token: token, payload: payload);
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
