// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  BankDao? _bankDaoInstance;

  BankAccountDao? _bankAccountDaoInstance;

  ChequeStatusDao? _chequeStatusDaoInstance;

  DepositStatusDao? _depositStatusDaoInstance;

  InvoiceStatusDao? _invoiceStatusDaoInstance;

  PaymentModeDao? _paymentModeDaoInstance;

  ReturnReasonDao? _returnReasonDaoInstance;

  CountryDao? _countryDaoInstance;

  CityDao? _cityDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `banks` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `bankName` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `bankAccounts` (`accountNo` TEXT NOT NULL, `bankName` TEXT NOT NULL, PRIMARY KEY (`accountNo`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `chequeStatuses` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `status` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `depositStatuses` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `status` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `invoiceStatuses` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `status` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `paymentModes` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `mode` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `returnReasons` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `reason` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `countries` (`countryName` TEXT NOT NULL, PRIMARY KEY (`countryName`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `cities` (`cityName` TEXT NOT NULL, `countryName` TEXT NOT NULL, FOREIGN KEY (`countryName`) REFERENCES `countries` (`countryName`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`cityName`, `countryName`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  BankDao get bankDao {
    return _bankDaoInstance ??= _$BankDao(database, changeListener);
  }

  @override
  BankAccountDao get bankAccountDao {
    return _bankAccountDaoInstance ??=
        _$BankAccountDao(database, changeListener);
  }

  @override
  ChequeStatusDao get chequeStatusDao {
    return _chequeStatusDaoInstance ??=
        _$ChequeStatusDao(database, changeListener);
  }

  @override
  DepositStatusDao get depositStatusDao {
    return _depositStatusDaoInstance ??=
        _$DepositStatusDao(database, changeListener);
  }

  @override
  InvoiceStatusDao get invoiceStatusDao {
    return _invoiceStatusDaoInstance ??=
        _$InvoiceStatusDao(database, changeListener);
  }

  @override
  PaymentModeDao get paymentModeDao {
    return _paymentModeDaoInstance ??=
        _$PaymentModeDao(database, changeListener);
  }

  @override
  ReturnReasonDao get returnReasonDao {
    return _returnReasonDaoInstance ??=
        _$ReturnReasonDao(database, changeListener);
  }

  @override
  CountryDao get countryDao {
    return _countryDaoInstance ??= _$CountryDao(database, changeListener);
  }

  @override
  CityDao get cityDao {
    return _cityDaoInstance ??= _$CityDao(database, changeListener);
  }
}

class _$BankDao extends BankDao {
  _$BankDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _bankInsertionAdapter = InsertionAdapter(
            database,
            'banks',
            (Bank item) =>
                <String, Object?>{'id': item.id, 'bankName': item.bankName});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Bank> _bankInsertionAdapter;

  @override
  Future<List<String>> getBanks() async {
    return _queryAdapter.queryList('SELECT bankName FROM banks',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<void> addBank(Bank bank) async {
    await _bankInsertionAdapter.insert(bank, OnConflictStrategy.abort);
  }
}

class _$BankAccountDao extends BankAccountDao {
  _$BankAccountDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _bankAccountInsertionAdapter = InsertionAdapter(
            database,
            'bankAccounts',
            (BankAccount item) => <String, Object?>{
                  'accountNo': item.accountNo,
                  'bankName': item.bankName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<BankAccount> _bankAccountInsertionAdapter;

  @override
  Future<List<BankAccount>> getBankAccounts() async {
    return _queryAdapter.queryList('SELECT * FROM bankAccounts',
        mapper: (Map<String, Object?> row) => BankAccount(
            accountNo: row['accountNo'] as String,
            bankName: row['bankName'] as String));
  }

  @override
  Future<void> addBankAccount(BankAccount bankAccount) async {
    await _bankAccountInsertionAdapter.insert(
        bankAccount, OnConflictStrategy.abort);
  }
}

class _$ChequeStatusDao extends ChequeStatusDao {
  _$ChequeStatusDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _chequeStatusInsertionAdapter = InsertionAdapter(
            database,
            'chequeStatuses',
            (ChequeStatus item) =>
                <String, Object?>{'id': item.id, 'status': item.status});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ChequeStatus> _chequeStatusInsertionAdapter;

  @override
  Future<List<String>> getChequeStatuses() async {
    return _queryAdapter.queryList('SELECT status FROM chequeStatuses',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<void> addChequeStatus(ChequeStatus chequeStatus) async {
    await _chequeStatusInsertionAdapter.insert(
        chequeStatus, OnConflictStrategy.abort);
  }
}

class _$DepositStatusDao extends DepositStatusDao {
  _$DepositStatusDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _depositStatusInsertionAdapter = InsertionAdapter(
            database,
            'depositStatuses',
            (DepositStatus item) =>
                <String, Object?>{'id': item.id, 'status': item.status});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DepositStatus> _depositStatusInsertionAdapter;

  @override
  Future<List<String>> getDepositStatuses() async {
    return _queryAdapter.queryList('SELECT status FROM depositStatuses',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<void> addDepositStatus(DepositStatus depositStatus) async {
    await _depositStatusInsertionAdapter.insert(
        depositStatus, OnConflictStrategy.abort);
  }
}

class _$InvoiceStatusDao extends InvoiceStatusDao {
  _$InvoiceStatusDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _invoiceStatusInsertionAdapter = InsertionAdapter(
            database,
            'invoiceStatuses',
            (InvoiceStatus item) =>
                <String, Object?>{'id': item.id, 'status': item.status});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<InvoiceStatus> _invoiceStatusInsertionAdapter;

  @override
  Future<List<String>> getInvoiceStatuses() async {
    return _queryAdapter.queryList('SELECT status FROM invoiceStatuses',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<void> addInvoiceStatus(InvoiceStatus invoiceStatus) async {
    await _invoiceStatusInsertionAdapter.insert(
        invoiceStatus, OnConflictStrategy.abort);
  }
}

class _$PaymentModeDao extends PaymentModeDao {
  _$PaymentModeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _paymentModeInsertionAdapter = InsertionAdapter(
            database,
            'paymentModes',
            (PaymentMode item) =>
                <String, Object?>{'id': item.id, 'mode': item.mode});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PaymentMode> _paymentModeInsertionAdapter;

  @override
  Future<List<String>> getPaymentModes() async {
    return _queryAdapter.queryList('SELECT mode FROM paymentModes',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<void> addPaymentMode(PaymentMode paymentMode) async {
    await _paymentModeInsertionAdapter.insert(
        paymentMode, OnConflictStrategy.abort);
  }
}

class _$ReturnReasonDao extends ReturnReasonDao {
  _$ReturnReasonDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _returnReasonInsertionAdapter = InsertionAdapter(
            database,
            'returnReasons',
            (ReturnReason item) =>
                <String, Object?>{'id': item.id, 'reason': item.reason});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ReturnReason> _returnReasonInsertionAdapter;

  @override
  Future<List<String>> getReturnReasons() async {
    return _queryAdapter.queryList('SELECT reason FROM returnReasons',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<void> addReturnReason(ReturnReason returnReason) async {
    await _returnReasonInsertionAdapter.insert(
        returnReason, OnConflictStrategy.abort);
  }
}

class _$CountryDao extends CountryDao {
  _$CountryDao(
    this.database,
    this.changeListener,
  ) : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<void> addCountry(String countryName) async {
    await _queryAdapter.queryNoReturn(
        'INSERT OR IGNORE INTO countries (countryName) VALUES (?1)',
        arguments: [countryName]);
  }

  @override
  Future<List<String>> getCountries() async {
    return _queryAdapter.queryList('SELECT countryName FROM countries',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }
}

class _$CityDao extends CityDao {
  _$CityDao(
    this.database,
    this.changeListener,
  ) : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<void> addCity(
    String cityName,
    String countryName,
  ) async {
    await _queryAdapter.queryNoReturn(
        'INSERT OR IGNORE INTO cities (cityName, countryName) VALUES (?1, ?2)',
        arguments: [cityName, countryName]);
  }

  @override
  Future<List<String>> getCitiesInCountry(String countryName) async {
    return _queryAdapter.queryList(
        'SELECT cityName FROM cities WHERE countryName = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as String,
        arguments: [countryName]);
  }
}
