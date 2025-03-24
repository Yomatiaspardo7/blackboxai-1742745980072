import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences.dart';
import '../models/subscription.dart';

class PaymentService extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SharedPreferences _prefs;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  Subscription? _currentSubscription;
  bool _isLoading = true;

  PaymentService(this._prefs) {
    _initialize();
  }

  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  List<ProductDetails> get products => _products;
  Subscription? get currentSubscription => _currentSubscription;
  bool get isSubscribed => _currentSubscription?.isActive ?? false;

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Cargar suscripción guardada
      await _loadSavedSubscription();

      // Configurar listener para compras
      final purchaseUpdated = _iap.purchaseStream;
      purchaseUpdated.listen(_onPurchaseUpdate, onError: _onPurchaseError);

      // Cargar productos disponibles
      await _loadProducts();
    } catch (e) {
      debugPrint('Error inicializando pagos: $e');
      _isAvailable = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProducts() async {
    final productIds = SubscriptionPlan.availablePlans.map((p) => p.id).toSet();
    final ProductDetailsResponse response = 
        await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Productos no encontrados: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
    notifyListeners();
  }

  Future<void> _loadSavedSubscription() async {
    final subscriptionJson = _prefs.getString('subscription');
    if (subscriptionJson != null) {
      try {
        final Map<String, dynamic> json = 
            Map<String, dynamic>.from(const JsonDecoder().convert(subscriptionJson));
        _currentSubscription = Subscription.fromJson(json);
        
        // Verificar si la suscripción ha expirado
        if (_currentSubscription!.isExpired) {
          await _handleExpiredSubscription();
        }
      } catch (e) {
        debugPrint('Error cargando suscripción: $e');
        await _prefs.remove('subscription');
      }
    }
  }

  Future<void> _handleExpiredSubscription() async {
    if (_currentSubscription!.autoRenew) {
      // Intentar renovar automáticamente
      try {
        await _renewSubscription();
      } catch (e) {
        debugPrint('Error renovando suscripción: $e');
        _currentSubscription = _currentSubscription!.copyWith(
          status: SubscriptionStatus.expired,
        );
        await _saveSubscription();
      }
    } else {
      _currentSubscription = _currentSubscription!.copyWith(
        status: SubscriptionStatus.expired,
      );
      await _saveSubscription();
    }
  }

  Future<void> _renewSubscription() async {
    // Implementar lógica de renovación con el backend
    throw UnimplementedError();
  }

  Future<void> _saveSubscription() async {
    if (_currentSubscription != null) {
      await _prefs.setString(
        'subscription',
        const JsonEncoder().convert(_currentSubscription!.toJson()),
      );
    } else {
      await _prefs.remove('subscription');
    }
    notifyListeners();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Mostrar indicador de carga
        _isLoading = true;
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Manejar error
          _handlePurchaseError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
          // Verificar y entregar el producto
          await _verifyAndDeliverProduct(purchaseDetails);
        }
        
        // Completar la compra
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void _onPurchaseError(dynamic error) {
    debugPrint('Error en la compra: $error');
    _isLoading = false;
    notifyListeners();
  }

  void _handlePurchaseError(IAPError error) {
    debugPrint('Error en la compra: ${error.message}');
    // Implementar manejo de errores específicos
  }

  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    // Verificar la compra con el backend
    final isValid = await _verifyPurchase(purchaseDetails);
    if (!isValid) {
      throw Exception('Compra inválida');
    }

    // Encontrar el plan correspondiente
    final plan = SubscriptionPlan.availablePlans.firstWhere(
      (p) => p.id == purchaseDetails.productID,
    );

    // Crear nueva suscripción
    final now = DateTime.now();
    final endDate = plan.period == SubscriptionPeriod.monthly
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(days: 365));

    _currentSubscription = Subscription(
      id: purchaseDetails.purchaseID!,
      tier: SubscriptionTier.premium,
      period: plan.period,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: endDate,
      price: plan.price,
      autoRenew: true,
      isTrialPeriod: false,
    );

    await _saveSubscription();
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Implementar verificación con el backend
    return true;
  }

  Future<void> purchase(ProductDetails product) async {
    if (!_isAvailable) {
      throw Exception('Compras no disponibles');
    }

    final purchaseParam = PurchaseParam(
      productDetails: product,
    );

    if (product.id.contains('subscription')) {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      throw Exception('Compras no disponibles');
    }

    await _iap.restorePurchases();
  }

  Future<void> startTrial() async {
    if (_currentSubscription != null) {
      throw Exception('Ya tienes una suscripción activa');
    }

    _currentSubscription = Subscription.trial();
    await _saveSubscription();
  }

  Future<void> cancelSubscription() async {
    if (_currentSubscription == null) {
      throw Exception('No tienes una suscripción activa');
    }

    _currentSubscription = _currentSubscription!.copyWith(
      status: SubscriptionStatus.cancelled,
      autoRenew: false,
    );

    await _saveSubscription();
  }

  @override
  void dispose() {
    super.dispose();
  }
}