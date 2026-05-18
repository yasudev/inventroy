enum UserRole { admin, cashier, manager, seller }

class AppUser {
  final int? id;
  final String username;
  final String password;
  final UserRole role;
  final String displayName;

  const AppUser({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.displayName,
  });

  static List<AppUser> users = [
    AppUser(id: 1, username: 'admin', password: 'admin', role: UserRole.admin, displayName: 'Admin'),
    AppUser(id: 2, username: 'cashier', password: 'cashier', role: UserRole.cashier, displayName: 'Cashier'),
    AppUser(id: 3, username: 'manager', password: 'manager', role: UserRole.manager, displayName: 'Manager'),
    AppUser(id: 4, username: 'seller', password: 'seller', role: UserRole.seller, displayName: 'Seller'),
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
