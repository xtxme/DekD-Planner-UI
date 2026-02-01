// Future<int> updatePasswordByEmail(String email, String newHash, String newSalt)

// return db.update(
//   _table,
//   {
//     'password_hash': newHash,
//     'password_salt': newSalt,
//   },
//   where: 'email = ?',
//   whereArgs: [email],
// );