import { relationalStore } from '@ohos.data.relationalStore';
import { PasswordEntry } from '../models/VaultModel';

/**
 * IronVault - Database Manager
 * Handles local SQLite storage for password entries
 */
export class VaultDatabase {
  private static instance: VaultDatabase | null = null;
  private rdbStore: relationalStore.RdbStore | null = null;
  private readonly DB_NAME: string = 'IronVault.db';
  private readonly DB_VERSION: number = 1;
  private readonly TABLE_NAME: string = 'passwords';

  private constructor() {}

  /**
   * Get singleton instance
   */
  static getInstance(): VaultDatabase {
    if (!VaultDatabase.instance) {
      VaultDatabase.instance = new VaultDatabase();
    }
    return VaultDatabase.instance;
  }

  /**
   * Initialize the database and create table if needed
   */
  async init(): Promise<void> {
    try {
      const context = getContext(this);
      const config: relationalStore.StoreConfig = {
        name: this.DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };

      this.rdbStore = await relationalStore.getRdbStore(context, config);

      // Create table
      const sql = `
        CREATE TABLE IF NOT EXISTS ${this.TABLE_NAME} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          username TEXT NOT NULL,
          encryptedPassword TEXT NOT NULL,
          websiteUrl TEXT,
          category TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      `;

      await this.rdbStore.executeSql(sql);
      console.info('[VaultDatabase] Database initialized successfully');
    } catch (error) {
      console.error(`[VaultDatabase] Init failed: ${JSON.stringify(error)}`);
      throw new Error('Database initialization failed');
    }
  }

  /**
   * Add a new password entry
   * @param entry The password entry to add
   * @returns The ID of the newly inserted entry
   */
  async addEntry(entry: PasswordEntry): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    const valueBucket = this.entryToBucket(entry);
    const rowId = await this.rdbStore.insert(this.TABLE_NAME, valueBucket);
    return Number(rowId);
  }

  /**
   * Get all password entries
   * @returns Array of all entries
   */
  async getAllEntries(): Promise<PasswordEntry[]> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    const resultSet = await this.rdbStore.query(predicates);

    const entries: PasswordEntry[] = [];
    while (resultSet.goToNextRow()) {
      entries.push(this.resultSetToEntry(resultSet));
    }
    resultSet.close();

    return entries;
  }

  /**
   * Get a single entry by ID
   * @param id The entry ID
   * @returns The password entry or null if not found
   */
  async getEntryById(id: number): Promise<PasswordEntry | null> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    predicates.equalTo('id', id);
    const resultSet = await this.rdbStore.query(predicates);

    if (resultSet.goToNextRow()) {
      const entry = this.resultSetToEntry(resultSet);
      resultSet.close();
      return entry;
    }

    resultSet.close();
    return null;
  }

  /**
   * Update an existing entry
   * @param entry The entry with updated values
   * @returns true if updated successfully
   */
  async updateEntry(entry: PasswordEntry): Promise<boolean> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    const valueBucket = this.entryToBucket(entry);
    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    predicates.equalTo('id', entry.id);

    const rows = await this.rdbStore.update(valueBucket, predicates);
    return rows > 0;
  }

  /**
   * Delete an entry by ID
   * @param id The entry ID to delete
   */
  async deleteEntry(id: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    predicates.equalTo('id', id);
    await this.rdbStore.delete(predicates);
  }

  /**
   * Delete all entries (for logout/reset)
   */
  async deleteAllEntries(): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }

    const predicates = new relationalStore.RdbPredicates(this.TABLE_NAME);
    await this.rdbStore.delete(predicates);
  }

  /**
   * Close the database connection
   */
  async close(): Promise<void> {
    if (this.rdbStore) {
      this.rdbStore = null;
    }
  }

  /**
   * Convert PasswordEntry to Rdb ValueBucket
   */
  private entryToBucket(entry: PasswordEntry): relationalStore.ValuesBucket {
    return {
      id: entry.id,
      title: entry.title,
      username: entry.username,
      encryptedPassword: entry.encryptedPassword,
      websiteUrl: entry.websiteUrl || '',
      category: entry.category,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt
    };
  }

  /**
   * Convert ResultSet row to PasswordEntry
   */
  private resultSetToEntry(resultSet: relationalStore.ResultSet): PasswordEntry {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      title: resultSet.getString(resultSet.getColumnIndex('title')),
      username: resultSet.getString(resultSet.getColumnIndex('username')),
      encryptedPassword: resultSet.getString(resultSet.getColumnIndex('encryptedPassword')),
      websiteUrl: resultSet.isColumnNull(resultSet.getColumnIndex('websiteUrl'))
        ? undefined
        : resultSet.getString(resultSet.getColumnIndex('websiteUrl')),
      category: resultSet.getString(resultSet.getColumnIndex('category')),
      createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt')),
      updatedAt: resultSet.getLong(resultSet.getColumnIndex('updatedAt'))
    };
  }
}
