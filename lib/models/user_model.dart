enum UserRole { admin, cashier, manager, seller }

class AppUser {
  final String username;
  final String password;
  final UserRole role;
  final String displayName;

  const AppUser({
    required this.username,
    required this.password,
    required this.role,
    required this.displayName,
  });

  static const List<AppUser> users = [
    AppUser(username: 'admin', password: 'admin', role: UserRole.admin, displayName: 'Admin'),
    AppUser(username: 'cashier', password: 'cashier', role: UserRole.cashier, displayName: 'Cashier'),
    AppUser(username: 'manager', password: 'manager', role: UserRole.manager, displayName: 'Manager'),
    AppUser(username: 'seller', password: 'seller', role: UserRole.seller, displayName: 'Seller'),
  ];

  static AppUser? authenticate(String username, String password) {
    try {
      return users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }
}
