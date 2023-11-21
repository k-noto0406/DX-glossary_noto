import 'package:postgres/legacy.dart';

import 'setting.dart';

class Postgres {
  static Future<void> insert(
      {required String title, required String description}) async {
    final connection = PostgreSQLConnection(
      'localhost', // ホスト名
      5432, // ポート番号
      dbName, // データベース名
      username: userName, // \lコマンドでOwnerのところを入力
      password: password,
    );

    try {
      await connection.open();
      final insertResult = await connection.execute(
        'INSERT INTO $tableName (title, description) VALUES (@title, @description)',
        substitutionValues: {
          'title': title,
          'description': description,
        },
      );

      if (insertResult > 0) {
        print('データの追加に成功しました');
      } else {
        print('データの追加に失敗しました');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      await connection.close();
    }
  }

  static Future<PostgreSQLResult?> getItem() async {
    try {
      final connection = PostgreSQLConnection(
        'localhost', // ホスト名
        5432, // ポート番号
        dbName, // データベース名
        username: userName,
        password: password,
      );
      await connection.open();
      final results = await connection.query('SELECT * FROM $tableName');
      return results;
    } catch (e) {
      print('Error: $e');
    } finally {
      final connection = PostgreSQLConnection(
        'localhost', // ホスト名
        5432, // ポート番号
        dbName, // データベース名
        username: userName,
        password: password,
      );
      await connection.close();
    }
    return null;
  }

  static Future<void> update(
      {required int id,
      required String updateTitle,
      required String updateDescription}) async {
    final connection = PostgreSQLConnection(
      'localhost', // ホスト名
      5432, // ポート番号
      dbName, // データベース名
      username: userName,
      password: password,
    );
    await connection.open();

    final updateResult = await connection.execute(
      'UPDATE $tableName SET title = @title, description = @description WHERE id = @id',
      substitutionValues: {
        'id': id,
        'title': updateTitle,
        'description': updateDescription,
      },
    );

    if (updateResult > 0) {
      print('データの更新に成功しました');
    } else {
      print('データの更新に失敗しました');
    }
  }

  static Future<void> delete({required int id}) async {
    final connection = PostgreSQLConnection(
      'localhost', // ホスト名
      5432, // ポート番号
      dbName, // データベース名
      username: userName,
      password: password,
    );
    await connection.open();

    final deleteResult = await connection.execute(
      'DELETE FROM $tableName WHERE id = @id',
      substitutionValues: {
        'id': id,
      },
    );

    if (deleteResult > 0) {
      print('データの削除に成功しました');
    } else {
      print('データの削除に失敗しました');
    }
  }
}
