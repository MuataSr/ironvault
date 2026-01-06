import { preferences } from '@kit.ArkTS';

/**
 * IronVault - Global State Manager
 * Manages app-wide state like master key and initialization status
 */
export class GlobalContext {
  private static readonly MASTER_KEY_PREFS = 'ironvault_prefs';
  private static readonly KEY_IS_SETUP = 'is_setup';
  private static readonly KEY_MASTER_HASH = 'master_hash';

  private static instance: GlobalContext;
  private preferences: preferences.Preferences | null = null;
  private _masterKey: string = '';

  private constructor() {}

  /**
   * Get singleton instance
   */
  static getInstance(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  /**
   * Initialize preferences
   */
  async init(): Promise<void> {
    try {
      const context = getContext(this);
      this.preferences = await preferences.getPreferences(context, this.MASTER_KEY_PREFS);
      console.info('[GlobalContext] Initialized successfully');
    } catch (error) {
      console.error(`[GlobalContext] Init failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Check if app is set up (master password created)
   */
  async isSetup(): Promise<boolean> {
    if (!this.preferences) await this.init();
    return await this.preferences!.getSync(this.KEY_IS_SETUP, false) as boolean;
  }

  /**
   * Set up master password for first time
   */
  async setupMaster(password: string): Promise<void> {
    if (!this.preferences) await this.init();

    // Store hashed password (simple hash for now)
    const hash = await this.hashPassword(password);
    await this.preferences!.put(this.KEY_IS_SETUP, true);
    await this.preferences!.put(this.KEY_MASTER_HASH, hash);
    await this.preferences!.flush();

    console.info('[GlobalContext] Master password setup complete');
  }

  /**
   * Validate master password
   */
  async validateMaster(password: string): Promise<boolean> {
    if (!this.preferences) await this.init();

    const storedHash = await this.preferences!.getSync(this.KEY_MASTER_HASH, '') as string;
    const inputHash = await this.hashPassword(password);

    return storedHash === inputHash;
  }

  /**
   * Set the active master key (in memory only)
   */
  setMasterKey(key: string): void {
    this._masterKey = key;
  }

  /**
   * Get the active master key
   */
  getMasterKey(): string {
    return this._masterKey;
  }

  /**
   * Clear master key (on logout)
   */
  clearMasterKey(): void {
    this._masterKey = '';
  }

  /**
   * Simple password hashing (placeholder - should use proper KDF)
   */
  private async hashPassword(password: string): Promise<string> {
    // TODO: Use proper KDF like PBKDF2 or Argon2
    const encoder = new TextEncoder();
    const data = encoder.encode(password);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  }
}
