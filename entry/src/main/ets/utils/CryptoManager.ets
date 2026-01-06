import { cryptoFramework } from '@ohos.security.cryptoFramework';
import { buffer } from '@kit.ArkTS';

/**
 * IronVault - Crypto Manager
 * Handles AES-GCM encryption/decryption for password data
 */
export class CryptoManager {
  private static readonly ALGORITHM_NAME: string = 'AES256';
  private static readonly TRANSFORM_MODE: string = 'ECB';
  private static readonly PADDING: string = 'PKCS7';

  /**
   * Encrypts plain text using AES-GCM
   * @param plainText The text to encrypt
   * @param key The encryption key (derived from master password)
   * @returns Base64 string combining IV and cipher text
   */
  static async encrypt(plainText: string, key: string): Promise<string> {
    try {
      // Derive a proper 256-bit key from the master password
      const keyData = this.deriveKey(key);

      // Generate a random IV (12 bytes for GCM)
      const iv = cryptoFramework.createRandom({ size: 12 });
      const ivBuffer = iv.data;

      // Create cipher
      const cipher = cryptoFramework.createCipher({
        name: 'AES|GCM|PKCS7',
        iv: ivBuffer
      });

      // Convert key to DataBlob
      const keyBlob: cryptoFramework.DataBlob = {
        data: buffer.from(keyData).buffer
      };

      // Convert plain text to DataBlob
      const plainBlob: cryptoFramework.DataBlob = {
        data: buffer.from(plainText).buffer
      };

      // Initialize cipher with key
      await cipher.init(cryptoFramework.CryptMode.ENCRYPT_MODE, keyBlob, ivBuffer);

      // Encrypt
      const encryptedData = await cipher.doFinal(plainBlob);

      // Combine IV + CipherText for storage
      const combined = new Uint8Array(ivBuffer.length + encryptedData.length);
      combined.set(ivBuffer);
      combined.set(new Uint8Array(encryptedData), ivBuffer.length);

      // Return Base64 encoded string
      return buffer.from(combined.buffer).toString('base64');
    } catch (error) {
      console.error(`[CryptoManager] Encryption failed: ${JSON.stringify(error)}`);
      throw new Error('Encryption failed');
    }
  }

  /**
   * Decrypts cipher text using AES-GCM
   * @param cipherText Base64 string combining IV and cipher text
   * @param key The decryption key (derived from master password)
   * @returns Decrypted plain text
   */
  static async decrypt(cipherText: string, key: string): Promise<string> {
    try {
      // Decode Base64
      const combined = buffer.from(cipherText, 'base64').toString('binary', '');

      // Extract IV (first 12 bytes)
      const iv = combined.slice(0, 12);
      const encryptedData = combined.slice(12);

      // Derive key
      const keyData = this.deriveKey(key);

      // Create decipher
      const decipher = cryptoFramework.createCipher({
        name: 'AES|GCM|PKCS7',
        iv: buffer.from(iv).buffer
      });

      // Convert to DataBlobs
      const keyBlob: cryptoFramework.DataBlob = {
        data: buffer.from(keyData).buffer
      };
      const encryptedBlob: cryptoFramework.DataBlob = {
        data: buffer.from(encryptedData).buffer
      };

      // Initialize decipher
      await decipher.init(cryptoFramework.CryptMode.DECRYPT_MODE, keyBlob, buffer.from(iv).buffer);

      // Decrypt
      const decryptedData = await decipher.doFinal(encryptedBlob);

      return buffer.from(decryptedData).toString('utf8');
    } catch (error) {
      console.error(`[CryptoManager] Decryption failed: ${JSON.stringify(error)}`);
      throw new Error('Decryption failed');
    }
  }

  /**
   * Derives a 256-bit key from the master password using SHA-256
   * @param masterPassword The master password
   * @returns 32-byte key data
   */
  private static deriveKey(masterPassword: string): Uint8Array {
    // Use SHA-256 to derive a consistent key from the password
    const hash = cryptoFramework.createMd('SHA256');
    const blob: cryptoFramework.DataBlob = {
      data: buffer.from(masterPassword).buffer
    };
    const hashData = hash.digestSync(blob);
    return new Uint8Array(hashData.data);
  }

  /**
   * Validates that encryption/decryption works correctly
   * @param masterPassword Password to use for testing
   * @returns true if encryption cycle works
   */
  static async testEncryption(masterPassword: string): Promise<boolean> {
    const testPassword = 'TestPassword123';
    try {
      const encrypted = await this.encrypt(testPassword, masterPassword);
      const decrypted = await this.decrypt(encrypted, masterPassword);
      return decrypted === testPassword;
    } catch {
      return false;
    }
  }
}
