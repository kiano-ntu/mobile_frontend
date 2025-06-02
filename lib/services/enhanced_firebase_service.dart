// lib/services/enhanced_firebase_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';
import '../services/api_service.dart';
import '/config/app_config.dart';
import 'package:flutter/material.dart';

class EnhancedFirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Navigation key for handling notification navigation
  static GlobalKey<NavigatorState>? navigationKey;

  static Future<void> initialize({GlobalKey<NavigatorState>? navKey}) async {
    navigationKey = navKey;
    
    // Initialize Firebase
    await Firebase.initializeApp();
    
    // Request notification permissions
    await _requestPermissions();
    
    // Initialize local notifications with enhanced channels
    await _initializeLocalNotifications();
    
    // Setup enhanced message handlers
    _setupEnhancedMessageHandlers();
    
    // Get and save FCM token
    await _saveFcmToken();
  }

  static Future<void> _requestPermissions() async {
    // Request notification permission with all options
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      announcement: false,
      carPlay: false,
    );

    print('🔔 Notification permission status: ${settings.authorizationStatus}');

    // Request additional permissions for Android
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    // Android notification channels
    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
      'reusemart_general',
      'ReUseMart General',
      description: 'General notifications for ReUseMart app',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const AndroidNotificationChannel transactionChannel = AndroidNotificationChannel(
      'reusemart_transactions',
      'ReUseMart Transactions',
      description: 'Transaction-related notifications',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('transaction'),
    );

    const AndroidNotificationChannel deliveryChannel = AndroidNotificationChannel(
      'reusemart_delivery',
      'ReUseMart Delivery',
      description: 'Delivery and pickup notifications',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('delivery'),
    );

    const AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
      'reusemart_urgent',
      'ReUseMart Urgent',
      description: 'Urgent notifications (expiry, etc.)',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('urgent'),
      enableVibration: true,
      playSound: true,
    );

    // Create ALL notification channels
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(transactionChannel);
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(deliveryChannel);
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(urgentChannel);

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    print('✅ Local notifications initialized with all channels');
  }

  static void _setupEnhancedMessageHandlers() {
    // Handle foreground messages with enhanced processing
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Received foreground message: ${message.messageId}');
      print('📋 Message data: ${message.data}');
      _showEnhancedLocalNotification(message);
    });

    // Handle background messages that open app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔗 App opened from notification: ${message.messageId}');
      _handleEnhancedNotificationClick(message);
    });

    // Handle background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle initial message when app is opened from terminated state
    _checkForInitialMessage();
  }

  static Future<void> _checkForInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    
    if (initialMessage != null) {
      print('🚀 App opened from terminated state via notification');
      // Wait a bit for the app to fully initialize
      await Future.delayed(const Duration(seconds: 2));
      _handleEnhancedNotificationClick(initialMessage);
    }
  }

  static Future<void> _saveFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      
      if (token != null) {
        print('🔑 FCM Token: ${token.substring(0, 20)}...');
        
        // Save token to Laravel backend
        await _sendTokenToBackend(token);
        
        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen(_sendTokenToBackend);
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  static Future<void> _sendTokenToBackend(String token) async {
    try {
      final userRole = await StorageService.getUserRole();
      
      if (userRole != null) {
        final response = await ApiService.post(
          '${AppConfig.apiUrl}/update-fcm-token',
          {
            'fcm_token': token,
            'user_type': userRole,
          },
          requiresAuth: true,
        );
        
        if (response.success) {
          print('✅ FCM token sent to backend successfully');
        } else {
          print('⚠️ Failed to send FCM token: ${response.message}');
        }
      }
    } catch (e) {
      print('❌ Error sending FCM token to backend: $e');
    }
  }

  static Future<void> _showEnhancedLocalNotification(RemoteMessage message) async {
    final String notificationType = message.data['type'] ?? 'general';
    final String channelId = _getChannelId(notificationType);
    final String channelName = _getChannelName(notificationType);
    
    // Custom notification details based on type
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: _getChannelDescription(notificationType),
      importance: _getImportance(notificationType),
      priority: _getPriority(notificationType),
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      icon: _getNotificationIcon(notificationType),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        message.notification?.body ?? '',
        contentTitle: message.notification?.title,
        summaryText: 'ReUseMart',
      ),
      enableVibration: _shouldVibrate(notificationType),
      playSound: true,
      sound: _getNotificationSound(notificationType),
      color: _getNotificationColor(notificationType),
      ledColor: _getNotificationColor(notificationType),
      ledOnMs: 1000,
      ledOffMs: 500,
      ticker: 'ReUseMart Notification',
      autoCancel: true,
      ongoing: false,
      visibility: NotificationVisibility.public,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: null,
      subtitle: 'ReUseMart',
      threadIdentifier: 'reusemart_notifications',
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'ReUseMart',
      message.notification?.body ?? 'You have a new notification',
      platformChannelSpecifics,
      payload: _createPayload(message.data),
    );

    print('📱 Enhanced local notification shown for type: $notificationType');
  }

  // Create payload string from notification data
  static String _createPayload(Map<String, dynamic> data) {
    try {
      // Convert data to JSON string for payload
      return data.toString();
    } catch (e) {
      print('❌ Error creating payload: $e');
      return '{}';
    }
  }

  // Helper methods for notification customization
  static String _getChannelId(String type) {
    switch (type) {
      case 'product_sold':
      case 'item_donated':
        return 'reusemart_transactions';
      case 'delivery_schedule':
      case 'pickup_schedule':
      case 'item_shipped':
      case 'item_delivered':
      case 'item_picked_up':
        return 'reusemart_delivery';
      case 'consignment_expiring_h3':
      case 'consignment_expiring_today':
        return 'reusemart_urgent';
      default:
        return 'reusemart_general';
    }
  }

  static String _getChannelName(String type) {
    switch (type) {
      case 'product_sold':
      case 'item_donated':
        return 'Transaksi';
      case 'delivery_schedule':
      case 'pickup_schedule':
      case 'item_shipped':
      case 'item_delivered':
      case 'item_picked_up':
        return 'Pengiriman';
      case 'consignment_expiring_h3':
      case 'consignment_expiring_today':
        return 'Penting';
      default:
        return 'Umum';
    }
  }

  static String _getChannelDescription(String type) {
    switch (type) {
      case 'product_sold':
        return 'Notifikasi ketika barang terjual';
      case 'delivery_schedule':
        return 'Notifikasi jadwal pengiriman';
      case 'pickup_schedule':
        return 'Notifikasi jadwal pengambilan';
      case 'item_shipped':
        return 'Notifikasi barang dikirim';
      case 'item_delivered':
        return 'Notifikasi barang sampai';
      case 'item_picked_up':
        return 'Notifikasi barang diambil';
      case 'item_donated':
        return 'Notifikasi barang disumbangkan';
      case 'consignment_expiring_h3':
        return 'Notifikasi masa penitipan akan berakhir';
      case 'consignment_expiring_today':
        return 'Notifikasi masa penitipan berakhir hari ini';
      default:
        return 'Notifikasi umum ReUseMart';
    }
  }

  static Importance _getImportance(String type) {
    switch (type) {
      case 'consignment_expiring_today':
        return Importance.max;
      case 'product_sold':
      case 'consignment_expiring_h3':
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  static Priority _getPriority(String type) {
    switch (type) {
      case 'consignment_expiring_today':
        return Priority.max;
      case 'product_sold':
      case 'consignment_expiring_h3':
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }

  static String? _getNotificationIcon(String type) {
    // Using default app icon for now since custom icons need to be added to android/app/src/main/res/drawable/
    // You can uncomment and use custom icons after adding them to drawable folder
    return '@mipmap/ic_launcher';
    
    /* Custom icons (add these drawable files first):
    switch (type) {
      case 'product_sold':
        return '@drawable/ic_sold';
      case 'delivery_schedule':
      case 'item_shipped':
        return '@drawable/ic_delivery';
      case 'pickup_schedule':
      case 'item_picked_up':
        return '@drawable/ic_pickup';
      case 'item_delivered':
        return '@drawable/ic_delivered';
      case 'item_donated':
        return '@drawable/ic_donated';
      case 'consignment_expiring_h3':
      case 'consignment_expiring_today':
        return '@drawable/ic_warning';
      default:
        return '@mipmap/ic_launcher';
    }
    */
  }

  static bool _shouldVibrate(String type) {
    switch (type) {
      case 'consignment_expiring_today':
      case 'product_sold':
        return true;
      default:
        return false;
    }
  }

  static RawResourceAndroidNotificationSound? _getNotificationSound(String type) {
    // Using default sound for now since custom sounds need to be added to android/app/src/main/res/raw/
    // You can uncomment and use custom sounds after adding them to raw folder
    return null; // This will use default system sound
    
    /* Custom sounds (add these .mp3/.wav files to res/raw/ folder first):
    switch (type) {
      case 'product_sold':
        return const RawResourceAndroidNotificationSound('transaction');
      case 'delivery_schedule':
      case 'pickup_schedule':
      case 'item_shipped':
      case 'item_delivered':
      case 'item_picked_up':
        return const RawResourceAndroidNotificationSound('delivery');
      case 'consignment_expiring_h3':
      case 'consignment_expiring_today':
        return const RawResourceAndroidNotificationSound('urgent');
      default:
        return const RawResourceAndroidNotificationSound('notification');
    }
    */
  }

  static Color? _getNotificationColor(String type) {
    switch (type) {
      case 'product_sold':
        return const Color(0xFF10B981); // Green
      case 'delivery_schedule':
      case 'pickup_schedule':
        return const Color(0xFF3B82F6); // Blue
      case 'item_shipped':
      case 'item_delivered':
      case 'item_picked_up':
        return const Color(0xFF06B6D4); // Cyan
      case 'item_donated':
        return const Color(0xFFEF4444); // Red
      case 'consignment_expiring_h3':
        return const Color(0xFFF59E0B); // Amber
      case 'consignment_expiring_today':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF00965F); // Primary green
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    _handleEnhancedNotificationClick(null, payload: response.payload);
  }

  static void _handleEnhancedNotificationClick(RemoteMessage? message, {String? payload}) {
    Map<String, dynamic> data = {};
    
    if (message != null) {
      data = message.data;
    } else if (payload != null && payload.isNotEmpty) {
      try {
        // Parse payload string back to map
        // For simple implementation, we'll extract type from string
        if (payload.contains('type:')) {
          final typeMatch = RegExp(r'type:\s*([^,}]+)').firstMatch(payload);
          if (typeMatch != null) {
            data['type'] = typeMatch.group(1)?.trim();
          }
        }
        
        // Extract other data if needed
        if (payload.contains('pemesanan_id:')) {
          final idMatch = RegExp(r'pemesanan_id:\s*([^,}]+)').firstMatch(payload);
          if (idMatch != null) {
            data['pemesanan_id'] = idMatch.group(1)?.trim();
          }
        }
        
        print('📱 Parsed notification data: $data');
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
      }
    }
    
    String? notificationType = data['type'];
    
    // Navigate based on notification type
    _navigateBasedOnNotificationType(notificationType, data);
  }

  static void _navigateBasedOnNotificationType(String? type, Map<String, dynamic> data) {
    if (navigationKey?.currentState == null) {
      print('⚠️ Navigation key not available, cannot navigate');
      return;
    }

    // For now, navigate to respective dashboard screens
    // You can customize these routes based on your actual route names
    switch (type) {
      case 'product_sold':
      case 'item_donated':
        // Navigate to penitip dashboard
        navigationKey!.currentState!.pushNamed('/penitip-dashboard');
        break;
        
      case 'delivery_schedule':
      case 'pickup_schedule':
      case 'item_shipped':
      case 'item_delivered':
      case 'item_picked_up':
        // Navigate to pembeli dashboard
        navigationKey!.currentState!.pushNamed('/pembeli-dashboard');
        break;
        
      case 'consignment_expiring_h3':
      case 'consignment_expiring_today':
        // Navigate to penitip dashboard
        navigationKey!.currentState!.pushNamed('/penitip-dashboard');
        break;
        
      default:
        // Navigate to appropriate dashboard based on current user role
        _navigateToUserDashboard();
        break;
    }

    print('🧭 Navigated for notification type: $type');
  }

  static void _navigateToUserDashboard() async {
    try {
      final userRole = await StorageService.getUserRole();
      
      if (userRole != null && navigationKey?.currentState != null) {
        switch (userRole.toLowerCase()) {
          case 'pembeli':
            navigationKey!.currentState!.pushNamed('/pembeli-dashboard');
            break;
          case 'penitip':
            navigationKey!.currentState!.pushNamed('/penitip-dashboard');
            break;
          case 'kurir':
            navigationKey!.currentState!.pushNamed('/kurir-dashboard');
            break;
          case 'hunter':
            navigationKey!.currentState!.pushNamed('/hunter-dashboard');
            break;
          default:
            navigationKey!.currentState!.pushNamed('/login');
        }
      }
    } catch (e) {
      print('❌ Error navigating to user dashboard: $e');
    }
  }

  // Utility methods for notification management
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await ApiService.post(
        '${AppConfig.apiUrl}/notifications/mark-read',
        {'notification_id': notificationId},
        requiresAuth: true,
      );
      print('✅ Notification marked as read: $notificationId');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    try {
      final response = await ApiService.get(
        '${AppConfig.apiUrl}/notifications/history',
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      print('❌ Error getting notification history: $e');
    }
    
    return [];
  }

  static Future<int> getUnreadNotificationCount() async {
    try {
      final response = await ApiService.get(
        '${AppConfig.apiUrl}/notifications/unread-count',
        requiresAuth: true,
      );
      
      if (response.success && response.data != null) {
        return response.data['count'] ?? 0;
      }
    } catch (e) {
      print('❌ Error getting unread notification count: $e');
    }
    
    return 0;
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      print('✅ All local notifications cleared');
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  // Clear specific notification
  static Future<void> clearNotification(int notificationId) async {
    try {
      await _localNotifications.cancel(notificationId);
      print('✅ Notification $notificationId cleared');
    } catch (e) {
      print('❌ Error clearing notification $notificationId: $e');
    }
  }

  // Check notification permissions
  static Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('❌ Error checking notification permissions: $e');
      return false;
    }
  }

  // Request permissions again (for settings page)
  static Future<bool> requestNotificationPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
      return false;
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Background message received: ${message.messageId}');
  print('📋 Background message data: ${message.data}');
  
  // You can perform background tasks here if needed
  // For example, update local database, sync data, etc.
}